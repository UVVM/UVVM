-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/stan/VITAL/ISERDES2.vhd,v 1.22 2010/07/14 18:07:45 robh Exp $
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
--  /   /                        Source Synchronous Input Deserializer for the Spartan Series
-- /___/   /\      Filename    : ISERDES2.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
-- Revision:
--       1.0:  01/03/08 - Initial version.
--       1.1:  02/29/08:  Changed name to ISERDES2
--                        removed mc_ from signal names
--       1.2:  08/15/08:  remove DQIP, DQIN per yml
--                        IR478802 force unused outputs 0 based on DATA_WIDTH
--                        IR478802 force outputs X for 1 clk after BITSLIP 
--       1.3:  08/22/08:  IR480003 Changed serialized input to DDLY by default
--                        add param to select D if desired
--       1.4:  08/27/08:  Remove DDLY, DDLY2 pins. Use D input per IO SOLN TEAM
--                        IR481178 - phase detector moved to master
--       1.5:  09/19/08:  Fix up Phase Detector and STRING handling
--       1.6:  09/30/08:  IR489891 Change ci_int reset
--       1.7:  10/13/08:  IR492154 Add CE0 as enable on FFs
--       1.8:  11/05/08:  add CE0 as enable on bitslip_counter
--                        fixup input/output delays
--       1.9:  11/20/08:  connect CFB0, CFB1, DFB
--       1.10: 12/11/08:  delay internal ioce by 1 ioclk
--       1.11: 01/06/09:  CR502438 sync bitslip couter to clk_int
--       1.12: 01/22/09:  Add default values to inputs
--       1.13  02/12/09:  CR507431 Input shift reg and bitslip changes to match HW
--       1.14: 02/26/09:  CR510115 Changes for verilog vhdl sim differences
--       1.15: 03/11/09:  CR511632 missing 10ps on sample signal
--       1.16: 04/22/09:  CR519002 change to match HW phase detector function
--                        CR519029 change to match HW bitslip function
--       1.17: 06/03/09:  CR523941 update phase detector logic
--       1.18: 07/08/09:  CR524403 Add NONE to valid serdes_mode values
--       1.19: 11/16/09:  CR539199 Reset logic on bitslip counter. GSR vs RST.
--       1.20: 06/30/10:  CR567507, 567508 Connect D to FABRICOUT
-- End Revision
-------------------------------------------------------

----- CELL ISERDES2 -----

library std;
    use std.textio.all;
library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_textio.all;
use IEEE.STD_LOGIC_unsigned.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

  entity ISERDES2 is
    generic (
      BITSLIP_ENABLE : boolean := FALSE;
      DATA_RATE      : string := "SDR";
      DATA_WIDTH     : integer := 1;
      INTERFACE_TYPE : string := "NETWORKING";
      SERDES_MODE    : string := "NONE"
    );

    port (
      CFB0                 : out std_ulogic;
      CFB1                 : out std_ulogic;
      DFB                  : out std_ulogic;
      FABRICOUT            : out std_ulogic;
      INCDEC               : out std_ulogic;
      Q1                   : out std_ulogic;
      Q2                   : out std_ulogic;
      Q3                   : out std_ulogic;
      Q4                   : out std_ulogic;
      SHIFTOUT             : out std_ulogic;
      VALID                : out std_ulogic;
      BITSLIP              : in std_ulogic := 'L';
      CE0                  : in std_ulogic := 'H';
      CLK0                 : in std_ulogic;
      CLK1                 : in std_ulogic;
      CLKDIV               : in std_ulogic;
      D                    : in std_ulogic;
      IOCE                 : in std_ulogic := 'H';
      RST                  : in std_ulogic := 'L';
      SHIFTIN              : in std_ulogic      
    );
  end ISERDES2;

  architecture ISERDES2_V of ISERDES2 is
    
    constant IN_DELAY : time := 1 ps;
    constant OUT_DELAY : time := 100 ps;

    constant INCLK_DELAY : time := 0 ps;
    constant OUTCLK_DELAY : time := 0 ps;

    
    constant MODULE_NAME : string  := "ISERDES2";
    constant PAD : string := "                       ";
    signal SERDES_MODE_PAD : string(1 to 6) := (others => ' ');
    signal INTERFACE_TYPE_PAD : String(1 to 20) := (others => ' ');
    signal BITSLIP_ENABLE_BINARY : std_ulogic;
    signal DATA_RATE_BINARY : std_ulogic;
    signal DATA_WIDTH_BINARY : std_logic_vector(7 downto 0);
    signal INTERFACE_TYPE_BINARY : std_ulogic;
    signal SERDES_MODE_BINARY : std_ulogic;
    
-- FF outputs
  signal qs            : std_logic_vector(3 downto 0) := "XXXX";
  signal qc            : std_logic_vector(3 downto 0) := "XXXX";
  signal qt            : std_logic_vector(3 downto 0) := "XXXX";
  signal qg            : std_logic_vector(3 downto 0) := "XXXX";

  signal sample         : std_ulogic := '0';

-- CE signals
  signal ci_int         : std_ulogic := '0';
  signal ci_int_m       : std_ulogic := '0';
  signal ci_int_s       : std_ulogic := '0';
  signal ci_int_m_sync  : std_ulogic := '0';
  signal ci_int_s_sync  : std_ulogic := '0';
  signal ioce_int       : std_ulogic := '0';
  signal io_ce_dly      : std_logic_vector(6 downto 0) := (others => '0');
  signal bitslip_counter  : std_logic_vector(2 downto 0) := CONV_STD_LOGIC_VECTOR(8-DATA_WIDTH+1, 3);

-- Phase detector signals
  signal E3                : std_ulogic := '0';
  signal valid_capture     : std_ulogic := '0';
  signal incdec_capture    : std_ulogic := '0';
  signal edge_counter      : std_logic_vector(3 downto 0) := (others => '0');
  signal event_occured     : std_ulogic := '0'; 
  signal incdec_reg        : std_ulogic := '0'; 
  signal drp_event         : std_logic_vector(1 downto 0) := "01";
  signal plus1             : std_ulogic := '0';
  signal gvalid            : std_ulogic := '1';
  signal pre_event         : std_ulogic := '0';
  signal en_lower_baud  : std_ulogic := '0';
  signal e3_f              : std_ulogic := '0';
  signal incr_d            : std_ulogic := '0';
  signal incdec_latch      : std_ulogic := '0';
  signal VALID_delay_gated : std_ulogic := '0';

-- Other nodes
  signal cascade_in_int : std_ulogic := '0';
  signal ismaster_int   : std_ulogic := '0';
  signal qmuxSel_int    : std_logic_vector(1 downto 0) := (others => '0');
  signal enBitslip_int  : std_ulogic := '0';
  signal qout_en        : std_logic_vector(3 downto 0) := (others => '0');

-- clk doubler signals 
  signal clka_int       : std_ulogic := '0';
  signal clkb_int       : std_ulogic := '0';
  signal clk_int        : std_ulogic := '0';

-- Attribute settings 
  signal data_rate_int  : std_ulogic := '0';
  signal attr_err_flag  : std_ulogic := '0';
  signal interface_type_err_flag : std_ulogic := '0';
  signal bitslip_enable_err_flag : std_ulogic := '0';
  signal data_rate_err_flag      : std_ulogic := '0';
  signal data_width_err_flag     : std_ulogic := '0';
  signal serdes_mode_err_flag    : std_ulogic := '0';


  ---------------------
  --  INPUT PATH DELAYs
  --------------------
    signal CFB0_out : std_ulogic;
    signal CFB1_out : std_ulogic;
    signal DFB_out : std_ulogic;
    signal FABRICOUT_out : std_ulogic;
    signal INCDEC_out : std_ulogic;
    signal Q1_out : std_ulogic;
    signal Q2_out : std_ulogic;
    signal Q3_out : std_ulogic;
    signal Q4_out : std_ulogic;
    signal SHIFTOUT_out : std_ulogic;
    signal VALID_out : std_ulogic;
    
    signal CFB0_outdelay : std_ulogic;
    signal CFB1_outdelay : std_ulogic;
    signal DFB_outdelay : std_ulogic;
    signal FABRICOUT_outdelay : std_ulogic;
    signal INCDEC_outdelay : std_ulogic;
    signal Q1_outdelay : std_ulogic;
    signal Q2_outdelay : std_ulogic;
    signal Q3_outdelay : std_ulogic;
    signal Q4_outdelay : std_ulogic;
    signal SHIFTOUT_outdelay : std_ulogic;
    signal VALID_outdelay : std_ulogic;
    
    signal BITSLIP_ipd : std_ulogic;
    signal CE0_ipd : std_ulogic;
    signal CLK0_ipd : std_ulogic;
    signal CLK1_ipd : std_ulogic;
    signal CLKDIV_ipd : std_ulogic;
    signal D_ipd : std_ulogic;
    signal IOCE_ipd : std_ulogic;
    signal RST_ipd : std_ulogic;
    signal SHIFTIN_ipd : std_ulogic;
    
    signal BITSLIP_indelay : std_ulogic;
    signal CE0_indelay : std_ulogic;
    signal CLK0_indelay : std_ulogic;
    signal CLK1_indelay : std_ulogic;
    signal CLKDIV_indelay : std_ulogic;
    signal D_indelay : std_ulogic;
    signal IOCE_indelay : std_ulogic;
    signal RST_indelay : std_ulogic;
    signal SHIFTIN_indelay : std_ulogic;
    signal GSR_dly : std_ulogic;
    
    begin
    GSR_dly <= GSR;
    CFB0_out <= CFB0_outdelay after OUT_DELAY;
    CFB1_out <= CFB1_outdelay after OUT_DELAY;
    DFB_out <= DFB_outdelay after OUT_DELAY;
    FABRICOUT_out <= FABRICOUT_outdelay after OUT_DELAY;
    INCDEC_out <= INCDEC_outdelay after OUT_DELAY;
    Q1_out <= Q1_outdelay after OUT_DELAY;
    Q2_out <= Q2_outdelay after OUT_DELAY;
    Q3_out <= Q3_outdelay after OUT_DELAY;
    Q4_out <= Q4_outdelay after OUT_DELAY;
    SHIFTOUT_out <= SHIFTOUT_outdelay after OUT_DELAY;
    VALID_out <= VALID_outdelay after OUT_DELAY;
    
    CLK0_ipd <= CLK0;
    CLK1_ipd <= CLK1;
    CLKDIV_ipd <= CLKDIV;
    
    BITSLIP_ipd <= BITSLIP;
    CE0_ipd <= CE0;
    D_ipd <= D;
    IOCE_ipd <= IOCE;
    RST_ipd <= RST;
    SHIFTIN_ipd <= SHIFTIN;
    
    CLK0_indelay <= CLK0_ipd after INCLK_DELAY;
    CLK1_indelay <= CLK1_ipd after INCLK_DELAY;
    CLKDIV_indelay <= CLKDIV_ipd after INCLK_DELAY;
    
    BITSLIP_indelay <= BITSLIP_ipd after IN_DELAY;
    CE0_indelay <= CE0_ipd after IN_DELAY;
    D_indelay <= D_ipd after IN_DELAY;
    IOCE_indelay <= IOCE_ipd after IN_DELAY;
    RST_indelay <= RST_ipd after IN_DELAY;
    SHIFTIN_indelay <= SHIFTIN_ipd after IN_DELAY;
    
--####################################################################
--#####                     Initialize                           #####
--####################################################################
      
      INIPROC : process
      variable AttrDataWidth_var : std_logic_vector(3 downto 0) := (others => 'X');
      variable SERDES_MODE_STRING : string(1 to 8) := SERDES_MODE & PAD(1 to 8-SERDES_MODE'length);
      variable INTERFACE_TYPE_STRING : String(1 to 22) := INTERFACE_TYPE & PAD(1 to 22-INTERFACE_TYPE'length);
      begin
-------------------------------------------------
------ DATA_RATE Check
-------------------------------------------------
        if((DATA_RATE = "SDR") or (DATA_RATE = "sdr")) then
          DATA_RATE_BINARY <= '1';
          data_rate_int <= '1';
        elsif((DATA_RATE = "DDR") or (DATA_RATE= "ddr")) then
          DATA_RATE_BINARY <= '0';
         data_rate_int <= '0';
        else
          data_rate_err_flag <= '1';
          wait for 1 ps;
          GenericValueCheckMessage
           (  HeaderMsg  => " Attribute Syntax Error ",
              GenericName => " DATA_RATE ",
              EntityName => MODULE_NAME,
              GenericValue => DATA_RATE,
              Unit => "",
              ExpectedValueMsg => " The Legal values for this attribute are ",
              ExpectedGenericValue => " DDR or SDR.",
              TailMsg => "",
              MsgSeverity => Warning 
          );
       end if;

-------------------------------------------------
------ SERDES_MODE Check
-------------------------------------------------
        SERDES_MODE_PAD <= SERDES_MODE_STRING(1 to SERDES_MODE_PAD'length);
        if((SERDES_MODE_STRING = "NONE    ") or (SERDES_MODE_STRING = "none    "))then
          ismaster_int <= '1';
          SERDES_MODE_BINARY <= '0';
        elsif((SERDES_MODE_STRING = "MASTER  ") or (SERDES_MODE_STRING = "master  "))then
          ismaster_int <= '1';
          SERDES_MODE_BINARY <= '0';
        elsif((SERDES_MODE_STRING = "SLAVE   ") or (SERDES_MODE_STRING = "slave   "))then 
          ismaster_int <= '0';
          SERDES_MODE_BINARY <= '1';
        else
          serdes_mode_err_flag <= '1';
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
       end if;

-------------------------------------------------
------ BITSLIP_ENABLE Check
-------------------------------------------------
      case BITSLIP_ENABLE is
        when FALSE   =>  BITSLIP_ENABLE_BINARY <= '0';
                         enBitslip_int <= '0';
        when TRUE    =>  BITSLIP_ENABLE_BINARY <= '1';
                         enBitslip_int <= '1';
        when others  =>
          bitslip_enable_err_flag <= '1';
          wait for 1 ps;
          GenericValueCheckMessage
           (  HeaderMsg  => " Attribute Syntax Error ",
              GenericName => " BITSLIP_ENABLE ",
              EntityName => MODULE_NAME,
              GenericValue => BITSLIP_ENABLE,
              Unit => "",
              ExpectedValueMsg => " The Legal values for this attribute are ",
              ExpectedGenericValue => " TRUE or FALSE.",
              TailMsg => "",
              MsgSeverity => Warning 
          );
      end case;
-------------------------------------------------
------ DATA_WIDTH Check
-------------------------------------------------
      if ((DATA_WIDTH >= 1) and (DATA_WIDTH <= 8)) then
        DATA_WIDTH_BINARY <= CONV_STD_LOGIC_VECTOR(DATA_WIDTH, 8);
        AttrDataWidth_var := CONV_STD_LOGIC_VECTOR(DATA_WIDTH, 4);
      else
         data_width_err_flag <= '1';
         wait for 1 ps;
         GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error ",
             GenericName => " DATA_WIDTH ",
             EntityName => MODULE_NAME,
             GenericValue => DATA_WIDTH,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " 1, 2, 3, 4, 5, 6, 7, or 8 ",
             TailMsg => "",
             MsgSeverity => Warning
         );
      end if;

-------------------------------------------------
------ INTERFACE_TYPE Check
-------------------------------------------------
      INTERFACE_TYPE_PAD <= INTERFACE_TYPE_STRING (1 to INTERFACE_TYPE_PAD'length);
      if   (INTERFACE_TYPE_STRING = "NETWORKING            ") then 
         qmuxSel_int <= "01";
      elsif(INTERFACE_TYPE_STRING = "NETWORKING_PIPELINED  ") then 
         qmuxSel_int <= "10";
      elsif(INTERFACE_TYPE_STRING = "RETIMED               ") then 
         qmuxSel_int <= "11";
      else
         interface_type_err_flag <= '1';
         wait for 1 ps;
         GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error ",
             GenericName => " INTERFACE_TYPE ",
             EntityName => MODULE_NAME,
             GenericValue => INTERFACE_TYPE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " NETWORKING, NETWORKING_PIPELINED or RETIMED.",
             TailMsg => "",
             MsgSeverity => Warning 
         );
      end if;

      if((DATA_WIDTH > 4) and (SERDES_MODE_STRING = "SLAVE   ")) then 
         cascade_in_int <= '1';
      else
         cascade_in_int <= '0';
      end if;

      if    (DATA_WIDTH = 1) then
         if (SERDES_MODE_STRING = "SLAVE   ") then
            qout_en <= "0000";
         else
            qout_en <= "1000";
         end if;
      elsif (DATA_WIDTH = 2) then
         if (SERDES_MODE_STRING = "SLAVE   ") then
            qout_en <= "0000";
         else
            qout_en <= "1100";
         end if;
      elsif (DATA_WIDTH = 3) then
         if (SERDES_MODE_STRING = "SLAVE   ") then
            qout_en <= "0000";
         else
            qout_en <= "1110";
         end if;
      elsif (DATA_WIDTH = 4) then
         if (SERDES_MODE_STRING = "SLAVE   ") then
            qout_en <= "0000";
         else
            qout_en <= "1111";
         end if;
      elsif (DATA_WIDTH = 5) then
         if (SERDES_MODE_STRING = "SLAVE   ") then
            qout_en <= "1000";
         else
            qout_en <= "1111";
         end if;
      elsif (DATA_WIDTH = 6) then
         if (SERDES_MODE_STRING = "SLAVE   ") then
            qout_en <= "1100";
         else
            qout_en <= "1111";
         end if;
      elsif (DATA_WIDTH = 7) then
         if (SERDES_MODE_STRING = "SLAVE   ") then
            qout_en <= "1110";
         else
            qout_en <= "1111";
         end if;
      elsif (DATA_WIDTH = 8) then
         if (SERDES_MODE_STRING = "SLAVE   ") then
            qout_en <= "1111";
         else
            qout_en <= "1111";
         end if;
      end if;

     if ( (interface_type_err_flag = '1') or 
          (bitslip_enable_err_flag = '1') or 
          (data_rate_err_flag = '1') or 
          (data_width_err_flag = '1') or 
          (serdes_mode_err_flag = '1') ) then
        attr_err_flag <= '1';
        wait for 1 ps;
        ASSERT FALSE REPORT "Attribute Errors Detected, Simulation Stops" SEVERITY Error;
      end if;

      wait;
      end process INIPROC;
--####################################################################
--#####                       DDR doubler                        #####
--####################################################################
  prcs_ddr_dblr_clk0:process(CLK0_indelay)
  begin
     if(rising_edge(CLK0_indelay)) then
        clka_int <= '1',
                    '0' after 10 ps;
     end if;
  end process prcs_ddr_dblr_clk0;


  prcs_ddr_dblr_clk1:process(CLK1_indelay)
  begin
     if(rising_edge(CLK1_indelay) and (DATA_RATE = "DDR")) then
         clkb_int <= '1', 
                     '0' after 10 ps;
     end if;
  end process prcs_ddr_dblr_clk1;

  clk_int <= clka_int or clkb_int;

--####################################################################
--#####                   Input Shift Registers                  #####
--####################################################################
  prcs_qs:process(clk_int, GSR_dly, RST_indelay)
  begin
     if((GSR_dly = '1') or (RST_indelay = '1'))then
         qs <= "0000"; 
     elsif(rising_edge(clk_int) and (GSR_dly = '0') and
           (RST_indelay = '0')) then 
         if (CE0_indelay = '1')then
            if(cascade_in_int = '1') then
               qs(3) <= SHIFTIN_indelay; 
            else
               qs(3) <= D_indelay; 
            end if;  
         end if;  
         qs(2 downto 0) <= qs(3 downto 1);
     end if;

   end process prcs_qs;

--####################################################################
--#####                           ShiftOut                      #####
--####################################################################
--    Output Input sample if this is the Slave (used by the Phase Detector in Master)
--    Output S0 if this is the Master (used to cascade shift register in Slave)
  prcs_sample:process(clk_int, GSR_dly, RST_indelay)
  begin
     if((GSR_dly = '1') or (RST_indelay = '1'))then
         sample <= '0';
     elsif(rising_edge(clk_int) and (GSR_dly = '0') and (RST_indelay = '0') and (CE0_indelay = '1'))then
         sample <= D_indelay after 10 ps;
     end if;
  end process prcs_sample;
    
  prcs_shiftout:process(qs(0), sample)
  begin
    if((SERDES_MODE_PAD = "MASTER") or (SERDES_MODE_PAD = "NONE  ")) then
       SHIFTOUT_outdelay <= qs(0);
    else
       SHIFTOUT_outdelay <= sample;
    end if;
  end process prcs_shiftout;
    
  prcs_dfb:process(D_indelay)
  begin
    DFB_outdelay <= D_indelay;
    FABRICOUT_outdelay <= D_indelay;
  end process prcs_dfb;
    
  prcs_cfb0:process(CLK0_indelay)
  begin
    CFB0_outdelay <= CLK0_indelay;
  end process prcs_cfb0;
    
  prcs_cfb1:process(CLK1_indelay)
  begin
    CFB1_outdelay <= CLK1_indelay;
  end process prcs_cfb1;
--####################################################################
--#####                   Capture-In Registers                   #####
--####################################################################
  prcs_qc:process(clk_int, GSR_dly, RST_indelay)
  begin
     if((GSR_dly = '1') or (RST_indelay = '1'))then
         qc <= "0000"; 
     elsif(rising_edge(clk_int) and (GSR_dly = '0') and (RST_indelay = '0') and (ci_int = '1') and (CE0_indelay = '1'))then
         qc <= qs;
     end if;
  end process prcs_qc;
--####################################################################
--#####                   Transfer Out Registers                 #####
--####################################################################
  prcs_qt:process(clk_int, GSR_dly, RST_indelay)
  begin
     if((GSR_dly = '1') or (RST_indelay = '1'))then
         qt <= "0000"; 
     elsif(rising_edge(clk_int) and (GSR_dly = '0') and (RST_indelay = '0') and (ioce_int = '1') and (CE0_indelay = '1'))then
         qt <= qc;
     end if;
  end process prcs_qt;
--####################################################################
--#####                   GCLK Registers                         #####
--####################################################################
  prcs_qg:process(CLKDIV_indelay, GSR_dly, RST_indelay)
  begin
     if((GSR_dly = '1') or (RST_indelay = '1'))then
         qg <= "0000"; 
     elsif(rising_edge(CLKDIV_indelay) and (GSR_dly = '0') and (RST_indelay = '0') and (CE0_indelay = '1'))then
         qg <= qt;
     end if;
  end process prcs_qg;
--####################################################################
--#####                   BITSLIP function                       #####
--####################################################################
  prcs_ioce_int:process(clk_int)
  begin
     if(rising_edge(clk_int)) then
       ioce_int <= IOCE_indelay;
     end if;  
  end process prcs_ioce_int;

  prcs_bitslip:process(clk_int)
  begin
     if(GSR_dly = '1') then
       io_ce_dly <= "0000000";
     elsif(rising_edge(clk_int)) then
       io_ce_dly <= (ioce_int & io_ce_dly(6 downto 1));
     end if;  
  end process prcs_bitslip;

  prcs_bitslip_counter:process(CLKDIV_indelay, RST_indelay)
  begin
     if((GSR_dly = '1') or (RST_indelay = '1'))then
        bitslip_counter <= CONV_STD_LOGIC_VECTOR(8 - DATA_WIDTH + 1, 3);
     elsif(rising_edge(CLKDIV_indelay) and (BITSLIP_ENABLE = true) and (BITSLIP_indelay = '1')) then
        if(bitslip_counter = "111") then
            bitslip_counter <= CONV_STD_LOGIC_VECTOR(8-DATA_WIDTH, 3);
        else 
            bitslip_counter <= bitslip_counter + 1 ;
        end if;
     end if;
  end process prcs_bitslip_counter;
--####################################################################
--#####               Generate CaptureIn (CI) signal             #####
--####################################################################
  ci_int <= ci_int_m_sync when bitslip_counter(2) = '1' else ci_int_s_sync;
  prcs_ci_m:process(ioce_int, io_ce_dly, bitslip_counter)
  begin
     case bitslip_counter(1 downto 0) is
         when "00" => ci_int_m <= io_ce_dly(4) after 1 ps;
         when "01" => ci_int_m <= io_ce_dly(5) after 1 ps;
         when "10" => ci_int_m <= io_ce_dly(6) after 1 ps;
         when "11" => ci_int_m <= ioce_int after 1 ps;
         when others =>
     end case;
  end process prcs_ci_m;

  prcs_ci_s:process(ioce_int, io_ce_dly, bitslip_counter)
  begin
     case bitslip_counter(1 downto 0) is
         when "00" => ci_int_s <= io_ce_dly(0) after 1 ps;
         when "01" => ci_int_s <= io_ce_dly(1) after 1 ps;
         when "10" => ci_int_s <= io_ce_dly(2) after 1 ps;
         when "11" => ci_int_s <= io_ce_dly(3) after 1 ps;
         when others =>
     end case;
  end process prcs_ci_s;

  prcs_ci_sync:process(clk_int)
  begin
     if(rising_edge(clk_int))then
        ci_int_m_sync <= ci_int_m;
        ci_int_s_sync <= ci_int_s;
     end if;
  end process prcs_ci_sync;
--####################################################################
--#####               Phase Detector Function                    #####
--####################################################################

  VALID_delay_gated <= VALID_outdelay and gvalid;

  prcs_E3:process(SHIFTIN_indelay)
  begin
     if((SERDES_MODE_PAD = "MASTER") or (SERDES_MODE_PAD = "NONE  ")) then
        E3 <= SHIFTIN_indelay;
     end if;
  end process prcs_E3;
 
  prcs_phasedet:process(clk_int, GSR_dly, RST_indelay)
  begin
     if((GSR_dly = '1') or (RST_indelay = '1'))then
         event_occured      <= '0'; 
         incdec_reg         <= '0'; 
         edge_counter       <=  "0000"; 
         valid_capture      <= '0'; 
         incdec_capture     <= '0'; 
         pre_event          <= '0';
         e3_f               <= '0';
         incr_d             <= '0';
         incdec_latch       <= '0';
     elsif(rising_edge(clk_int) and ((SERDES_MODE_PAD = "MASTER") or (SERDES_MODE_PAD = "NONE  ")) and (CE0_indelay = '1'))then
         e3_f          <= E3;
         if (drp_event(1) = '1') then
            pre_event     <= qs(3) xor qs(2);
         elsif (drp_event(0) = '1') then
            pre_event     <= ((not qs(3)) and qs(2));
         else
            pre_event     <= qs(3) and not qs(2);
         end if;
         event_occured <= pre_event and not((qs(3) xor qs(2)) and en_lower_baud);
         if ( plus1 = '1') then
            incr_d        <= not (qs(3) xor e3_f);
         else
            incr_d        <= not (qs(3) xor E3);
         end if;
         incdec_reg    <= incr_d;
         if (ioce_int = '1') then
            incdec_latch  <= (event_occured and incdec_reg);
         elsif ((event_occured and not edge_counter(0)) = '1') then
            incdec_latch  <= incdec_reg;
         else
            incdec_latch  <= incdec_latch;
         end if;
         if (ioce_int = '1') then
            edge_counter  <= ("000" & event_occured);
         elsif (event_occured = '0') then
            edge_counter  <= edge_counter;
         elsif (not(edge_counter(0) and (incdec_reg xor incdec_latch))) = '1' then
            edge_counter  <= (edge_counter(2 downto 0) & '1');
         else
            edge_counter  <= ('0' & edge_counter(3 downto 1));
         end if;
         if(ioce_int = '1') then 
           valid_capture  <= edge_counter(0) after 100 ps;
           incdec_capture <= incdec_latch after 100 ps;
         end if;
     end if;
  end process prcs_phasedet;

  prcs_phaseout:process(CLKDIV_indelay, GSR_dly, RST_indelay)
  begin
     if((GSR_dly = '1') or (RST_indelay = '1'))then
        VALID_outdelay  <= '0';
        INCDEC_outdelay <= '0';
     elsif(rising_edge(CLKDIV_indelay) and ((SERDES_MODE_PAD = "MASTER") or (SERDES_MODE_PAD = "NONE  ")) and (CE0_indelay = '1'))then
        VALID_outdelay  <= valid_capture;
        INCDEC_outdelay <= incdec_capture;
     end if;
  end process prcs_phaseout;

--####################################################################
--#####                     OUTPUT MUXES                         #####
--####################################################################

  prcs_Q4:process(qs(3), qc(3), qt(3), qg(3))
  begin
     if (qout_en(3) = '0') then
        Q4_outdelay <= '0';
     else
     case qmuxSel_int is
         when "00" =>   Q4_outdelay <= qs(3);
         when "01" =>   Q4_outdelay <= qc(3);
         when "10" =>   Q4_outdelay <= qt(3);
         when "11" =>   Q4_outdelay <= qg(3);
         when others => Q4_outdelay <= qs(3);
     end case;
     end if;
  end process prcs_Q4;

  prcs_Q3:process(qs(2), qc(2), qt(2), qg(2))
  begin
     if (qout_en(2) = '0') then
        Q3_outdelay <= '0';
     else
     case qmuxSel_int is
         when "00" =>   Q3_outdelay <= qs(2);
         when "01" =>   Q3_outdelay <= qc(2);
         when "10" =>   Q3_outdelay <= qt(2);
         when "11" =>   Q3_outdelay <= qg(2);
         when others => Q3_outdelay <= qs(2);
     end case;
     end if;
  end process prcs_Q3;

  prcs_Q2:process(qs(1), qc(1), qt(1), qg(1))
  begin
     if (qout_en(1) = '0') then
        Q2_outdelay <= '0';
     else
     case qmuxSel_int is
         when "00" =>   Q2_outdelay <= qs(1);
         when "01" =>   Q2_outdelay <= qc(1);
         when "10" =>   Q2_outdelay <= qt(1);
         when "11" =>   Q2_outdelay <= qg(1);
         when others => Q2_outdelay <= qs(1);
     end case;
     end if;
  end process prcs_Q2;

  prcs_Q1:process(qs(0), qc(0), qt(0), qg(0))
  begin
     if (qout_en(0) = '0') then
        Q1_outdelay <= '0';
     else
     case qmuxSel_int is
         when "00" =>   Q1_outdelay <= qs(0);
         when "01" =>   Q1_outdelay <= qc(0);
         when "10" =>   Q1_outdelay <= qt(0);
         when "11" =>   Q1_outdelay <= qg(0);
         when others => Q1_outdelay <= qs(0);
     end case;
     end if;
  end process prcs_Q1;

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
    CFB0 <= CFB0_out;
    CFB1 <= CFB1_out;
    DFB <= DFB_out;
    FABRICOUT <= FABRICOUT_out;
    INCDEC <= INCDEC_out;
    Q1 <= Q1_out;
    Q2 <= Q2_out;
    Q3 <= Q3_out;
    Q4 <= Q4_out;
    SHIFTOUT <= SHIFTOUT_out;
    VALID <= VALID_out;
--####################################################################
    end ISERDES2_V;
