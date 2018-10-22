------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  
-- /___/   /\     Filename : SYSMON.vhd
-- \   \  /  \    Timestamp : 
--  \___\/\___\
-- Revision:
--    03/24/06 - Initial version.
--    06/26/06 - remove SIM_MONITOR_FILE from file definition (CR 234006).
--    08/04/06 - Change tmp_dr_ram_out out range from 83 to 87 (CR235676).
--               Add 100 ps delay to output (CR235566).
--    08/30/06 - GSR only reset DRP port (CR 422678).
--    09/06/06 - Add internal 1 ns reset at time 0 (422678).
--    09/07/06 - Match verilog model: alarm_update pulse etc. (CR 424061).
--    09/26/06 - Update error messages; Make unipolar same as bipolar for external channels;
--             - etc. (CR426629).
--    10/26/06 - Add tipd for analog channel although not used (CR423564).
--    10/30/06 - Match HW timing (CR 428185)
--    12/13/06 - Reset eoc_out_temp1 when calibration channel (CR430923)
--               Change INIT_42 to 0800 (CR 429642).
--    07/17/07 - Add SIM_DEVICE attribute and allow clock divider lower to 2 for MBLANC.
--    04/15/08 - DEN need toggled and can not just pull high (CR471205).
--    09/02/08 - Change MBLANC to VIRTEX6.
--    10/09/08 - Change OT temperature max from 120 degree to 125 degree.(CR491781)
--    02/20/09 - Add V6 changes.
--    05/21/09 - Remove alarm bits from status_reg (CR522721)
--    12/18/09 - Move deallocate statement before return statement(CR541730)
--    01/05/10 - Use real() for integer to real conversion (CR542934)
--    03/22/11 - use INIT_53 for ot upper limit (CR602195)
--    08/12/11 - initial dr_sram in DRP block (CR613802)
-- End Revision

----- CELL SYSMON -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.NUMERIC_STD.all;

library STD;
use STD.TEXTIO.all;




library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity SYSMON is

generic (


                INIT_40 : bit_vector := X"0000";
                INIT_41 : bit_vector := X"0000";
                INIT_42 : bit_vector := X"0800";
                INIT_43 : bit_vector := X"0000";
                INIT_44 : bit_vector := X"0000";
                INIT_45 : bit_vector := X"0000";
                INIT_46 : bit_vector := X"0000";
                INIT_47 : bit_vector := X"0000";
                INIT_48 : bit_vector := X"0000";
                INIT_49 : bit_vector := X"0000";
                INIT_4A : bit_vector := X"0000";
                INIT_4B : bit_vector := X"0000";
                INIT_4C : bit_vector := X"0000";
                INIT_4D : bit_vector := X"0000";
                INIT_4E : bit_vector := X"0000";
                INIT_4F : bit_vector := X"0000";
                INIT_50 : bit_vector := X"0000";
                INIT_51 : bit_vector := X"0000";
                INIT_52 : bit_vector := X"0000";
                INIT_53 : bit_vector := X"0000";
                INIT_54 : bit_vector := X"0000";
                INIT_55 : bit_vector := X"0000";
                INIT_56 : bit_vector := X"0000";
                INIT_57 : bit_vector := X"0000";
                SIM_DEVICE : string := "VIRTEX5";
                SIM_MONITOR_FILE : string := "design.txt"
  );

port (
                ALM : out std_logic_vector(2 downto 0);
                BUSY : out std_ulogic;
                CHANNEL : out std_logic_vector(4 downto 0);
                DO : out std_logic_vector(15 downto 0);
                DRDY : out std_ulogic;
                EOC : out std_ulogic;
                EOS : out std_ulogic;
                JTAGBUSY : out std_ulogic;
                JTAGLOCKED : out std_ulogic;
                JTAGMODIFIED : out std_ulogic;
                OT : out std_ulogic;

                CONVST : in std_ulogic;
                CONVSTCLK : in std_ulogic;
                DADDR : in std_logic_vector(6 downto 0);
                DCLK : in std_ulogic;
                DEN : in std_ulogic;
                DI : in std_logic_vector(15 downto 0);
                DWE : in std_ulogic;
                RESET : in std_ulogic;
                VAUXN : in std_logic_vector(15 downto 0);
                VAUXP : in std_logic_vector(15 downto 0);
                VN : in std_ulogic;
                VP : in std_ulogic
     );



end SYSMON;


architecture SYSMON_V of SYSMON is
 
  ---------------------------------------------------------------------------
  -- Function SLV_TO_INT converts a std_logic_vector TO INTEGER
  ---------------------------------------------------------------------------
  function SLV_TO_INT(SLV: in std_logic_vector
                      ) return integer is

    variable int : integer;
  begin
    int := 0;
    for i in SLV'high downto SLV'low loop
      int := int * 2;
      if SLV(i) = '1' then
        int := int + 1;
      end if;
    end loop;
    return int;
  end;


  ---------------------------------------------------------------------------
  -- Function ADDR_IS_VALID checks for the validity of the argument. A FALSE
  -- is returned if any argument bit is other than a '0' or '1'.
  ---------------------------------------------------------------------------
  function ADDR_IS_VALID (
    SLV : in std_logic_vector
    ) return boolean is

    variable IS_VALID : boolean := TRUE;

  begin
    for I in SLV'high downto SLV'low loop
      if (SLV(I) /= '0' AND SLV(I) /= '1') then
        IS_VALID := FALSE;
      end if;
    end loop;
    return IS_VALID;
  end ADDR_IS_VALID;

  ---------------------------------------------------------------------------
  -- Function SLV_TO_STR returns a string version of the std_logic_vector
  -- argument.
  ---------------------------------------------------------------------------
  function SLV_TO_STR (
    SLV : in std_logic_vector
    ) return string is

    variable j : integer := SLV'length;
    variable STR : string (SLV'length downto 1);
  begin
    for I in SLV'high downto SLV'low loop
      case SLV(I) is
        when '0' => STR(J) := '0';
        when '1' => STR(J) := '1';
        when 'X' => STR(J) := 'X';
        when 'U' => STR(J) := 'U';
        when others => STR(J) := 'X';
      end case;
      J := J - 1;
    end loop;
    return STR;
  end SLV_TO_STR;

  function real2int( real_in : in real) return integer is
    variable int_value : integer;
    variable tmpt : time;
    variable tmpt1 : time;
    variable tmpa : real;
    variable tmpr : real;
    variable int_out : integer;
  begin
    tmpa := abs(real_in);
    tmpt := tmpa * 1 ps;
    int_value := (tmpt / 1 ps ) * 1;
    tmpt1 := int_value * 1 ps;
      tmpr := real(int_value);  

    if ( real_in < 0.0000) then
       if (tmpr > tmpa) then
           int_out := 1 - int_value;
       else
           int_out := -int_value;
       end if;
    else
      if (tmpr > tmpa) then 
           int_out := int_value - 1;
      else
           int_out := int_value;
      end if;
    end if;
    return int_out;
  end real2int;


    FUNCTION  To_Upper  ( CONSTANT  val    : IN String
                         ) RETURN STRING IS
        VARIABLE result   : string (1 TO val'LENGTH) := val;
        VARIABLE ch       : character;
    BEGIN
        FOR i IN 1 TO val'LENGTH LOOP
            ch := result(i);
            EXIT WHEN ((ch = NUL) OR (ch = nul));
            IF ( ch >= 'a' and ch <= 'z') THEN
                  result(i) := CHARACTER'VAL( CHARACTER'POS(ch)
                                       - CHARACTER'POS('a')
                                       + CHARACTER'POS('A') );
            END IF;
        END LOOP;
        RETURN result;
    END To_Upper;

    procedure get_token(buf : inout LINE; token : out string;
                            token_len : out integer) 
    is
       variable index : integer := buf'low;
       variable tk_index : integer := 0;
       variable old_buf : LINE := buf; 
    BEGIN
         while ((index <= buf' high) and ((buf(index) = ' ') or
                                         (buf(index) = HT))) loop
              index := index + 1; 
         end loop;
        
         while((index <= buf'high) and ((buf(index) /= ' ') and 
                                    (buf(index) /= HT))) loop 
              tk_index := tk_index + 1;
              token(tk_index) := buf(index);
              index := index + 1; 
         end loop;
   
         token_len := tk_index;
        
         buf := new string'(old_buf(index to old_buf'high));
           old_buf := NULL;
    END;

    procedure skip_blanks(buf : inout LINE) 
    is
         variable index : integer := buf'low;
         variable old_buf : LINE := buf; 
    BEGIN
         while ((index <= buf' high) and ((buf(index) = ' ') or 
                                       (buf(index) = HT))) loop
              index := index + 1; 
         end loop;
         buf := new string'(old_buf(index to old_buf'high));
           old_buf := NULL;
    END;

    procedure infile_format
    is
         variable message_line : line;
    begin

    write(message_line, string'("***** SYSMON Simulation Analog Data File Format ******"));
    writeline(output, message_line);
    write(message_line, string'("NAME: design.txt or user file name passed with generic sim_monitor_file"));
    writeline(output, message_line);
    write(message_line, string'("FORMAT: First line is header line. Valid column name are: TIME TEMP VCCINT VCCAUX VP VN VAUXP[0] VAUXN[0] ...."));
    writeline(output, message_line);
    write(message_line, string'("TIME must be in first column."));
    writeline(output, message_line);
    write(message_line, string'("Time value need to be integer in ns scale"));
    writeline(output, message_line);
    write(message_line, string'("Analog  value need to be real and contain a decimal  point '.', zero should be 0.0, 3 should be 3.0"));
    writeline(output, message_line);
    write(message_line, string'("Each line including header line can not have extra space after the last character/digit."));
    writeline(output, message_line);
    write(message_line, string'("Each data line must have same number of columns as the header line."));
    writeline(output, message_line);
    write(message_line, string'("Comment line start with -- or //"));
    writeline(output, message_line);
    write(message_line, string'("Example:"));
    writeline(output, message_line);
    write(message_line, string'("TIME TEMP VCCINT  VP VN VAUXP[0] VAUXN[0]"));
    writeline(output, message_line);
    write(message_line, string'("000  125.6  1.0  0.7  0.4  0.3  0.6"));
    writeline(output, message_line);
    write(message_line, string'("200  25.6   0.8  0.5  0.3  0.8  0.2"));
    writeline(output, message_line);

    end infile_format;

    type     REG_FILE   is  array (integer range <>) of 
                            std_logic_vector(15 downto 0);
    signal   dr_sram     :  REG_FILE(16#40# to 16#57#);
--    signal   dr_sram     :  REG_FILE(16#40# to 16#57#) := 
--               ( 
--                16#40# => TO_STDLOGICVECTOR(INIT_40),
--                16#41# => TO_STDLOGICVECTOR(INIT_41),
--                16#42# => TO_STDLOGICVECTOR(INIT_42),
--                16#43# => TO_STDLOGICVECTOR(INIT_43),
 --               16#44# => TO_STDLOGICVECTOR(INIT_44),
--                16#45# => TO_STDLOGICVECTOR(INIT_45),
--                16#46# => TO_STDLOGICVECTOR(INIT_46),
--                16#47# => TO_STDLOGICVECTOR(INIT_47),
--                16#48# => TO_STDLOGICVECTOR(INIT_48),
--                16#49# => TO_STDLOGICVECTOR(INIT_49),
--                16#4A# => TO_STDLOGICVECTOR(INIT_4A),
--                16#4B# => TO_STDLOGICVECTOR(INIT_4B),
--                16#4C# => TO_STDLOGICVECTOR(INIT_4C),
--                16#4D# => TO_STDLOGICVECTOR(INIT_4D),
--                16#4E# => TO_STDLOGICVECTOR(INIT_4E),
--                16#4F# => TO_STDLOGICVECTOR(INIT_4F),
--                16#50# => TO_STDLOGICVECTOR(INIT_50),
--                16#51# => TO_STDLOGICVECTOR(INIT_51),
--                16#52# => TO_STDLOGICVECTOR(INIT_52),
--                16#53# => TO_STDLOGICVECTOR(INIT_53),
--                16#54# => TO_STDLOGICVECTOR(INIT_54),
--                16#55# => TO_STDLOGICVECTOR(INIT_55),
--                16#56# => TO_STDLOGICVECTOR(INIT_56),
--                16#57# => TO_STDLOGICVECTOR(INIT_57)
--             );

       type     adc_statetype    is (INIT_STATE, ACQ_STATE, CONV_STATE, 
                                   ADC_PRE_END, END_STATE, SINGLE_SEQ_STATE);
       type     ANALOG_DATA    is array (0 to 31) of real;
       type     DR_data_reg    is array (0 to 63) of 
                                  std_logic_vector(15 downto 0);
       type     ACC_ARRAY      is array (0 to 31) of integer;
       type     int_array      is array(0 to 31) of integer;
       type     seq_array      is array(32 downto 0 ) of integer;

       signal   ot_limit_reg     : std_logic_vector(15 downto 0) := "1100101000000000";
--       signal   ot_limit_reg     : UNSIGNED(15 downto 0) := "1100101000000000";
       signal   adc_state         : adc_statetype := CONV_STATE;
       signal   next_state        : adc_statetype;
       signal   cfg_reg0         : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   cfg_reg0_adc     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   cfg_reg0_seq     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   cfg_reg1         : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   cfg_reg1_init    : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   cfg_reg2         : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq1_0           : std_logic_vector(1 downto 0) := "00";
       signal   curr_seq1_0      : std_logic_vector(1 downto 0) := "00";
       signal   curr_seq1_0_lat  : std_logic_vector(1 downto 0) := "00";
       signal   busy_r           : std_ulogic := '0';
       signal   busy_r_rst       : std_ulogic := '0';
       signal   busy_rst         : std_ulogic := '0';
       signal   busy_conv        : std_ulogic := '0';
       signal   busy_out_tmp     : std_ulogic := '0';
       signal   busy_out_dly     : std_ulogic := '0';
       signal   busy_out_sync    : std_ulogic := '0';
       signal   busy_out_low_edge : std_ulogic := '0';
       signal   shorten_acq      : integer := 1;
       signal   busy_seq_rst     : std_ulogic := '0';
       signal   busy_sync1       : std_ulogic := '0';
       signal   busy_sync2       : std_ulogic := '0';
       signal   busy_sync_fall   : std_ulogic := '0';
       signal   busy_sync_rise   : std_ulogic := '0';
       signal   cal_chan_update  : std_ulogic := '0';
       signal   first_cal_chan   : std_ulogic := '0';
       signal   seq_reset_flag   : std_ulogic := '0';
       signal   seq_reset_flag_dly   : std_ulogic := '0';
       signal   seq_reset_dly   : std_ulogic := '0';
       signal   seq_reset_busy_out  : std_ulogic := '0';
       signal   rst_in_not_seq   : std_ulogic := '0';
       signal   rst_in_out       : std_ulogic := '0';
       signal   rst_lock_early   : std_ulogic := '0';
       signal   conv_count       : integer := 0;
       signal   acq_count       : integer := 1;
       signal   do_out_rdtmp     : std_logic_vector(15 downto 0);
       signal   rst_in1          : std_ulogic := '0';
       signal   rst_in2          : std_ulogic := '0';
       signal   int_rst          : std_ulogic := '1';
       signal   rst_input_t      : std_ulogic := '0';
       signal   rst_in           : std_ulogic := '0';
       signal   ot_en            : std_logic := '1';
       signal   curr_clkdiv_sel  : std_logic_vector(7 downto 0) 
                                                  := "00000000";
       signal   curr_clkdiv_sel_int : integer := 0;
       signal   adcclk           : std_ulogic := '0';
       signal   adcclk_div1      : std_ulogic := '0';
       signal   sysclk           : std_ulogic := '0';
       signal   curr_adc_resl    : std_logic_vector(2 downto 0) := "010";
       signal   nx_seq           : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   curr_seq         : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   acq_cnt          : integer := 0;
       signal   acq_chan         : std_logic_vector(4 downto 0) := "00000";
       signal   acq_chan_index   : integer := 0;
       signal   acq_chan_lat     : std_logic_vector(4 downto 0) := "00000";
       signal   curr_chan        : std_logic_vector(4 downto 0) := "00000";
       signal   curr_chan_dly    : std_logic_vector(4 downto 0) := "00000";
       signal   curr_chan_lat    : std_logic_vector(4 downto 0) := "00000";
       signal   curr_avg_set     : std_logic_vector(1 downto 0) := "00";
       signal   acq_avg          : std_logic_vector(1 downto 0) := "00";
       signal   curr_e_c         : std_logic:= '0';
       signal   acq_e_c          : std_logic:= '0';
       signal   acq_b_u          : std_logic:= '0';
       signal   curr_b_u         : std_logic:= '0';
       signal   acq_acqsel       : std_logic:= '0';
       signal   curr_acq         : std_logic:= '0';
       signal   seq_cnt          : integer := 0;
       signal   busy_rst_cnt     : integer := 0;
       signal   adc_s1_flag      : std_ulogic := '0';
       signal   adc_convst       : std_ulogic := '0';
       signal   conv_start       : std_ulogic := '0';
       signal   conv_end         : std_ulogic := '0'; 
       signal   eos_en           : std_ulogic := '0';
       signal   eos_tmp_en       : std_ulogic := '0';
       signal   seq_cnt_en       : std_ulogic := '0'; 
       signal   eoc_en           : std_ulogic := '0';
       signal   eoc_en_delay       : std_ulogic := '0';
       signal   eoc_out_tmp     : std_ulogic := '0';
       signal   eos_out_tmp     : std_ulogic := '0';
       signal   eoc_out_tmp1     : std_ulogic := '0';
       signal   eos_out_tmp1     : std_ulogic := '0';
       signal   eoc_up_data      : std_ulogic := '0';
       signal   eoc_up_alarm    : std_ulogic := '0';
       signal   conv_time        : integer := 17;
       signal   conv_time_cal_1  : integer := 69;
       signal   conv_time_cal    : integer := 69;
       signal   conv_result      : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   conv_result_reg  : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   data_written     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   conv_result_int  : integer := 0;
       signal   conv_result_int_resl  : integer := 0;
       signal   analog_in_uni    : ANALOG_DATA :=(others=>0.0); 
       signal   analog_in_diff   : ANALOG_DATA :=(others=>0.0); 
       signal   analog_in        : ANALOG_DATA :=(others=>0.0); 
       signal   analog_in_comm   : ANALOG_DATA :=(others=>0.0); 
       signal   chan_val_tmp   : ANALOG_DATA :=(others=>0.0); 
       signal   chan_valn_tmp   : ANALOG_DATA :=(others=>0.0); 
       signal   data_reg         : DR_data_reg
                                  :=( 36 to 39 => "1111111111111111",
                                     others=>"0000000000000000");
       signal   tmp_data_reg_out : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   tmp_dr_sram_out  : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_chan_reg1    : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_chan_reg2    : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_acq_reg1     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_acq_reg2     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_avg_reg1     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_avg_reg2     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_du_reg1      : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_du_reg2      : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_count        : integer := 1;
       signal   seq_count_en     : std_ulogic := '0';
       signal   conv_acc         : ACC_ARRAY :=(others=>0);
       signal   conv_avg_count   : ACC_ARRAY :=(others=>0);
       signal   conv_acc_vec     : std_logic_vector (20 downto 1);
       signal   conv_acc_result  : std_logic_vector(15 downto 0);
       signal   seq_status_avg   : integer := 0;
       signal   curr_chan_index       : integer := 0;
       signal   curr_chan_index_lat   : integer := 0;
       signal   conv_avg_cnt     : int_array :=(others=>0);
       signal   analog_mux_in    : real := 0.0;
       signal   adc_temp_result  : real := 0.0;
       signal   adc_intpwr_result : real := 0.0;
       signal   adc_ext_result    : real := 0.0;
       signal   seq_reset        : std_ulogic := '0';
       signal   seq_en           : std_ulogic := '0';
       signal   seq_en_drp       : std_ulogic := '0';
       signal   seq_en_init      : std_ulogic := '0';
       signal   seq_en_dly       : std_ulogic := '0';
       signal   seq_num          : integer := 0;
       signal   seq_mem          : seq_array :=(others=>0);
       signal   adc_seq_reset       : std_ulogic := '0';
       signal   adc_seq_en          : std_ulogic := '0';
       signal   adc_seq_reset_dly   : std_ulogic := '0';
       signal   adc_seq_en_dly      : std_ulogic := '0';
       signal   adc_seq_reset_hold  : std_ulogic := '0';
       signal   adc_seq_en_hold     : std_ulogic := '0';
       signal   rst_lock            : std_ulogic := '1';
       signal   sim_file_flag       : std_ulogic := '0';
       signal   gsr_in              : std_ulogic := '0';
       signal   convstclk_in       : std_ulogic := '0';
       signal   convst_raw_in      : std_ulogic := '0';
       signal   convst_in          : std_ulogic := '0';
       signal   dclk_in            : std_ulogic := '0';
       signal   den_in             : std_ulogic := '0';
       signal   rst_input          : std_ulogic := '0';
       signal   dwe_in             : std_ulogic := '0';
       signal   di_in              : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   daddr_in           : std_logic_vector(6 downto 0) := "0000000";
       signal   daddr_in_lat       : std_logic_vector(6 downto 0) := "0000000";
       signal   daddr_in_lat_int   : integer := 0;
       signal   drdy_out_tmp1      : std_ulogic := '0';
       signal   drdy_out_tmp2      : std_ulogic := '0';
       signal   drdy_out_tmp3      : std_ulogic := '0';
       signal   drdy_out_tmp4      : std_ulogic := '0';
       signal   drp_update         : std_ulogic := '0';
       signal   alarm_en           : std_logic_vector(2 downto 0) := "111";
       signal   alarm_update       : std_ulogic := '0';
       signal   adcclk_tmp         : std_ulogic := '0';
       signal   ot_out_reg         : std_ulogic := '0';
       signal   alarm_out_reg      : std_logic_vector(2 downto 0) := "000";
       signal   conv_end_reg_read  :  std_logic_vector(3 downto 0) := "0000";
       signal   busy_reg_read      : std_ulogic := '0';
       signal   single_chan_conv_end : std_ulogic := '0';
       signal   first_acq          : std_ulogic := '1';
       signal   conv_start_cont    : std_ulogic := '0';
       signal   conv_start_sel     : std_ulogic := '0';
       signal   reset_conv_start   : std_ulogic := '0';
       signal   reset_conv_start_tmp   : std_ulogic := '0';
       signal   busy_r_rst_done    : std_ulogic := '0';
       signal   op_count           : integer := 15;
       signal   sim_device_int : std_ulogic := '0';
       signal   rst_in1_tmp5 : std_ulogic := '0';
       signal   rst_in1_tmp6 : std_ulogic := '0';
       signal   rst_in2_tmp5 : std_ulogic := '0';
       signal   rst_in2_tmp6 : std_ulogic := '0';
       signal   soft_reset : std_ulogic := '0';
       signal   status_reg : std_logic_vector(15 downto 0);
       signal   acq_e_c_tmp5 : std_ulogic := '0';
       signal   acq_e_c_tmp6 : std_ulogic := '0';
       signal   cfg_reg0_adc_tmp5 : std_logic_vector(15 downto 0) := X"0000";
       signal   cfg_reg0_adc_tmp6 : std_logic_vector(15 downto 0) := X"0000";
       signal   cfg_reg0_seq_tmp5 : std_logic_vector(15 downto 0) := X"0000";
       signal   cfg_reg0_seq_tmp6 : std_logic_vector(15 downto 0) := X"0000";
      

-- Input/Output Pin signals

        signal   DI_ipd  :  std_logic_vector(15 downto 0);
        signal   DADDR_ipd  :  std_logic_vector(6 downto 0);
        signal   DEN_ipd  :  std_ulogic;
        signal   DWE_ipd  :  std_ulogic;
        signal   DCLK_ipd  :  std_ulogic;
        signal   CONVSTCLK_ipd  :  std_ulogic;
        signal   RESET_ipd  :  std_ulogic;
        signal   CONVST_ipd  :  std_ulogic;

        signal   do_out  :  std_logic_vector(15 downto 0) := "0000000000000000";
        signal   drdy_out  :  std_ulogic := '0';
        signal   ot_out  :  std_ulogic := '0';
        signal   alarm_out  :  std_logic_vector(2 downto 0) := "000";
        signal   channel_out  :  std_logic_vector(4 downto 0) := "00000";
        signal   eoc_out  :  std_ulogic := '0';
        signal   eos_out  :  std_ulogic := '0';
        signal   busy_out  :  std_ulogic := '0';

        signal   DI_dly  :  std_logic_vector(15 downto 0);
        signal   DADDR_dly  :  std_logic_vector(6 downto 0);
        signal   DEN_dly  :  std_ulogic;
        signal   DWE_dly  :  std_ulogic;
        signal   DCLK_dly  :  std_ulogic;
        signal   CONVSTCLK_dly  :  std_ulogic;
        signal   RESET_dly  :  std_ulogic;
        signal   CONVST_dly  :  std_ulogic;

begin 

   BUSY <= busy_out after 100 ps;
   DRDY <= drdy_out after 100 ps;
   EOC <= eoc_out after 100 ps;
   EOS <= eos_out after 100 ps;
   OT <= ot_out after 100 ps;
   DO <= do_out after 100 ps;
   CHANNEL <= channel_out after 100 ps;
   ALM <= alarm_out after 100 ps;

   convst_raw_in <= CONVST;
   convstclk_in <= CONVSTCLK;
   dclk_in <= DCLK;
   den_in <= DEN;
   rst_input <= RESET;
   dwe_in <= DWE;
   di_in <= Di;
   daddr_in <= DADDR;

   gsr_in <= GSR;
   convst_in <= '1' when (convst_raw_in = '1' or convstclk_in = '1') else  '0';
   JTAGLOCKED <= '0';
   JTAGMODIFIED <= '0';
   JTAGBUSY <= '0';

   DEFAULT_CHECK : process
       variable init40h_tmp : std_logic_vector(15 downto 0);
       variable init41h_tmp : std_logic_vector(15 downto 0);
       variable init42h_tmp : std_logic_vector(15 downto 0);
       variable init4eh_tmp : std_logic_vector(15 downto 0);
       variable init53h_tmp : std_logic_vector(15 downto 0);
       variable init40h_tmp_chan : integer;
       variable init42h_tmp_clk : integer;
       variable tmp_value : std_logic_vector(7 downto 0);
   begin
        init40h_tmp := TO_STDLOGICVECTOR(INIT_40);
        init40h_tmp_chan := SLV_TO_INT(SLV=>init40h_tmp(4 downto 0));
        init41h_tmp := TO_STDLOGICVECTOR(INIT_41);
        init42h_tmp := TO_STDLOGICVECTOR(INIT_42);
        tmp_value :=  init42h_tmp(15 downto 8);
        init42h_tmp_clk := SLV_TO_INT(SLV=>tmp_value);
        init4eh_tmp := TO_STDLOGICVECTOR(INIT_4E);
        init53h_tmp := TO_STDLOGICVECTOR(INIT_53);
 
        if ((init41h_tmp(13 downto 12)="11") and (init40h_tmp(8)='1') and (init40h_tmp_chan /= 3 ) and (init40h_tmp_chan < 16)) then
          assert false report " Attribute Syntax warning : The attribute INIT_40 bit[8] must be set to 0 on SYSMON. Long acquistion mode is only allowed for external channels."
          severity warning;
        end if;

        if ((init41h_tmp(13 downto 12) /="11") and (init4eh_tmp(10 downto 0) /= "00000000000") and (init4eh_tmp(15 downto 12) /= "0000")) then
           assert false report " Attribute Syntax warning : The attribute INIT_4E Bit[15:12] and bit[10:0] must be set to 0. Long acquistion mode is only allowed for external channels."
          severity warning;
        end if;

        if ((init41h_tmp(13 downto 12)="11") and (init40h_tmp(9) = '1') and (init40h_tmp(4 downto 0) /= "00011") and (init40h_tmp_chan < 16)) then 
          assert false report " Attribute Syntax warning : The attribute INIT_40 bit[9] must be set to 0 on SYSMON. Event mode timing can only be used with external channels, and only in single channel mode."
          severity warning;
        end if;

        if ((init41h_tmp(13 downto 12)="11") and (init40h_tmp(13 downto 12) /= "00") and (INIT_48 /=X"0000") and (INIT_49 /= X"0000")) then
           assert false report " Attribute Syntax warning : The attribute INIT_48 and INIT_49 must be set to 0000h in single channel mode and averaging enabled."
          severity warning;
        end if;

        if (init42h_tmp(1 downto 0) /= "00") then
             assert false report
             " Attribute Syntax Error : The attribute INIT_42 Bit[1:0] must be set to 00."
              severity Error;
        end if;

        if (SIM_DEVICE = "VIRTEX6") then
          sim_device_int <= '1';
        else
          sim_device_int <= '0';
          if (init42h_tmp_clk < 8) then
             assert false report
             " Attribute Syntax Error : The attribute INIT_42 Bit[15:8] is the ADC Clock divider and must be equal or greater than 8."
              severity failure;
          end if;
        end if;

        if (INIT_43 /= "0000000000000000") then
             assert false report
             " Warning : The attribute INIT_43 must   be set to 0000."
             severity warning;
        end if;

        if (INIT_44 /= "0000000000000000") then
             assert false report
             " Warning : The attribute INIT_44 must   be set to 0000."
             severity warning;
        end if;

        if (INIT_45 /= "0000000000000000") then
             assert false report
             " Warning : The attribute INIT_45 must   be set to 0000."
             severity warning;
        end if;

        if (INIT_46 /= "0000000000000000") then
             assert false report
             " Warning : The attribute INIT_46 must   be set to 0000."
             severity warning;
        end if;

        if (INIT_47 /= "0000000000000000") then
             assert false report
             " Warning : The attribute INIT_47 must   be set to 0000."
             severity warning;
        end if;

         wait;
   end process;


   curr_chan_index <= SLV_TO_INT(curr_chan);
   curr_chan_index_lat <= SLV_TO_INT(curr_chan_lat);

  CHEK_COMM_P : process( busy_r )
       variable Message : line;
  begin 
  if (busy_r'event and busy_r = '1' ) then
   if (rst_in = '0' and acq_b_u = '0' and ((acq_chan_index = 3) or (acq_chan_index >= 16 and acq_chan_index <= 31))) then
      if ( chan_valn_tmp(acq_chan_index) > chan_val_tmp(acq_chan_index)) then
       Write ( Message, string'("Input File Warning: The N input for external channel "));
       Write ( Message, acq_chan_index);
       Write ( Message, string'(" must be smaller than P input when in unipolar mode (P="));
       Write ( Message, chan_val_tmp(acq_chan_index));
       Write ( Message, string'(" N="));
       Write ( Message, chan_valn_tmp(acq_chan_index));
       Write ( Message, string'(") for SYSMON."));
      assert false report Message.all severity warning;
      DEALLOCATE (Message);
    end if;

     if (( chan_valn_tmp(acq_chan_index) > 0.5) or  (chan_valn_tmp(acq_chan_index) < 0.0)) then
       Write ( Message, string'("Input File Warning: The N input for external channel "));
       Write ( Message, acq_chan_index);
       Write ( Message, string'(" should be between 0V to 0.5V when in unipolar mode (N="));
       Write ( Message, chan_valn_tmp(acq_chan_index));
      Write ( Message, string'(") for SYSMON."));
      assert false report Message.all severity warning;
      DEALLOCATE (Message);
    end if;

   end if;
  end if;
  end process;

  busy_mkup_p : process( dclk_in, rst_in_out)
  begin
    if (rst_in_out = '1') then
       busy_rst <= '1';
       rst_lock <= '1';
       rst_lock_early <= '1';
       busy_rst_cnt <= 0;
    elsif (rising_edge(dclk_in)) then
       if (rst_lock = '1') then
          if (busy_rst_cnt < 29) then
               busy_rst_cnt <= busy_rst_cnt + 1;
               if ( busy_rst_cnt = 26) then
                    rst_lock_early <= '0';
               end if;
          else
               busy_rst <= '0';
               rst_lock <= '0';
          end if;
       end if;
    end if;
  end process;

  busy_out_p : process (busy_rst, busy_conv, rst_lock)
  begin
     if (rst_lock = '1') then
         busy_out <= busy_rst;
     else
         busy_out <= busy_conv;
     end if;
  end process;      

  busy_conv_p : process (dclk_in, rst_in)
  begin
    if (rst_in = '1') then
       busy_conv <= '0';
       cal_chan_update <= '0';
    elsif (rising_edge(dclk_in)) then
        if (seq_reset_flag = '1'  and curr_clkdiv_sel_int <= 3)  then
             busy_conv <= busy_seq_rst;
        elsif (busy_sync_fall = '1') then
            busy_conv <= '0';
        elsif (busy_sync_rise = '1') then
            busy_conv <= '1';
        end if;

        if (conv_count = 21 and curr_chan = "01000" ) then
              cal_chan_update  <= '1';
         else
              cal_chan_update  <= '0';
         end if;
    end if;
  end process;

  busy_sync_p : process (dclk_in, rst_lock)
  begin
     if (rst_lock = '1') then 
        busy_sync1 <= '0';
        busy_sync2 <= '0';
     elsif (rising_edge (dclk_in)) then 
         busy_sync1 <= busy_r;
         busy_sync2 <= busy_sync1;
     end if;
  end process;

  busy_sync_fall <= '1' when (busy_r = '0' and busy_sync1 = '1') else '0';
  busy_sync_rise <= '1' when (busy_sync1 = '1' and busy_sync2 = '0') else '0';

  busy_seq_rst_p : process
    variable tmp_uns_div : unsigned(7 downto 0);
  begin
     if (falling_edge(busy_out) or rising_edge(busy_r)) then
        if (seq_reset_flag = '1' and seq1_0 = "00" and curr_clkdiv_sel_int <= 3) then
           wait until (rising_edge(dclk_in));
           wait  until (rising_edge(dclk_in));
           wait  until (rising_edge(dclk_in));
           wait  until (rising_edge(dclk_in));
           wait  until (rising_edge(dclk_in));
           busy_seq_rst <= '1';
        elsif (seq_reset_flag = '1' and seq1_0 /= "00" and curr_clkdiv_sel_int <= 3) then
            wait  until (rising_edge(dclk_in));
            wait  until (rising_edge(dclk_in));
            wait  until (rising_edge(dclk_in));
            wait  until (rising_edge(dclk_in));
            wait  until (rising_edge(dclk_in));
            wait  until (rising_edge(dclk_in));
            wait  until (rising_edge(dclk_in));
           busy_seq_rst <= '1';
        else
           busy_seq_rst <= '0';
        end if;
     end if;
    wait on busy_out, busy_r;
   end process;

  chan_out_p : process(busy_out, rst_in_out, cal_chan_update)
  begin
   if (rst_in_out = '1') then
         channel_out <= "00000";
   elsif (rising_edge(busy_out) or rising_edge(cal_chan_update)) then
           if ( busy_out = '1' and cal_chan_update = '1') then
                channel_out <= "01000";
           end if;
   elsif (falling_edge(busy_out)) then
                channel_out <= curr_chan;
                curr_chan_lat <= curr_chan;
   end if;
  end process;

  INT_RST_GEN_P : process
  begin
    int_rst <= '1';
    wait until (rising_edge(dclk_in));
    wait until (rising_edge(dclk_in));
    int_rst <= '0';
    wait;
  end process;

  rst_input_t <= rst_input or int_rst or soft_reset after 1 ps;

  RST_DE_SYNC_P: process(dclk_in, rst_input_t)
  begin
    if (sim_device_int = '0') then
      if (rst_input_t = '1') then
              rst_in2_tmp5 <= '1';
              rst_in1_tmp5 <= '1';
      elsif (dclk_in'event and dclk_in='1') then
              rst_in2_tmp5 <= rst_in1_tmp5;
              rst_in1_tmp5 <= rst_input_t;
      end if;
     end if;
  end process;

  RST_DE_SYNC_V6_P: process(adcclk, rst_input_t)
  begin
    if (sim_device_int = '1') then
      if (rst_input_t = '1') then
              rst_in2_tmp6 <= '1';
              rst_in1_tmp6 <= '1';
      elsif (adcclk'event and adcclk='1') then
              rst_in2_tmp6 <= rst_in1_tmp6;
              rst_in1_tmp6 <= rst_input_t;
      end if;
     end if;
  end process;

    rst_in2 <= rst_in2_tmp6 when (sim_device_int = '1') else rst_in2_tmp5;
    rst_in_not_seq <= rst_in2;
    rst_in <= rst_in2 or seq_reset_dly;
    rst_in_out <= rst_in2 or seq_reset_busy_out;

  seq_reset_dly_p : process
  begin
   if (rising_edge(seq_reset)) then
    wait until rising_edge(dclk_in);
    wait until rising_edge(dclk_in);
       seq_reset_dly <= '1';
    wait until rising_edge(dclk_in);
    wait until falling_edge(dclk_in);
       seq_reset_busy_out <= '1';
    wait until rising_edge(dclk_in);
    wait until rising_edge(dclk_in);
    wait until rising_edge(dclk_in);
       seq_reset_dly <= '0';
       seq_reset_busy_out <= '0';
   end if;
    wait on seq_reset, dclk_in;
  end process;


  seq_reset_flag_p : process (seq_reset_dly, busy_r)
    begin
       if (rising_edge(seq_reset_dly)) then
          seq_reset_flag <= '1';
       elsif (rising_edge(busy_r)) then
          seq_reset_flag <= '0';
       end if;
    end process;

  seq_reset_flag_dly_p : process (seq_reset_flag, busy_out)
    begin
       if (rising_edge(seq_reset_flag)) then
          seq_reset_flag_dly <= '1';
       elsif (rising_edge(busy_out)) then
           seq_reset_flag_dly <= '0';
       end if;
    end process;

  first_cal_chan_p : process ( busy_out)
    begin
      if (rising_edge(busy_out )) then
          if (seq_reset_flag_dly = '1' and  acq_chan = "01000" and seq1_0 = "00") then
                  first_cal_chan <= '1';
          else 
                  first_cal_chan <= '0';
          end if;
      end if;
    end process;


  ADC_SM: process (adcclk, rst_in, sim_file_flag)
  begin
     if (sim_file_flag = '1') then
        adc_state <= INIT_STATE;
     elsif (rst_in = '1' or rst_lock_early = '1') then
        adc_state <= INIT_STATE;
     elsif (adcclk'event and adcclk = '1') then
         adc_state <= next_state;
     end if;
  end process;

  next_state_p : process (adc_state, eos_en, conv_start , conv_end, curr_seq1_0_lat)
  begin
      case (adc_state) is
      when INIT_STATE => next_state <= ACQ_STATE;

      when  ACQ_STATE => if (conv_start = '1') then
                                  next_state <= CONV_STATE;
                              else
                                  next_state <= ACQ_STATE;
                              end if;

      when  CONV_STATE => if (conv_end = '1') then
                                   next_state <= END_STATE;
                               else
                                   next_state <= CONV_STATE;
                                end if;

      when  END_STATE => if (curr_seq1_0_lat = "01")  then
                                if (eos_en = '1') then
                                    next_state <= SINGLE_SEQ_STATE;
                                else
                                    next_state <= ACQ_STATE;
                                end if;
                            else
                                next_state <= ACQ_STATE;
                            end if;

      when  SINGLE_SEQ_STATE => next_state <= INIT_STATE;

      when  others => next_state <= INIT_STATE;
    end case;
  end process;

  seq_en_init_p : process
  begin
      seq_en_init <= '0';
      if (cfg_reg1_init(13 downto 12) /= "11" ) then
          wait for 20 ps;
          seq_en_init <= '1';
          wait for 150 ps;
          seq_en_init <= '0';
      end if;
      wait;
  end process;

  
      seq_en <= seq_en_init or  seq_en_drp;

  drdy_out_p : process
  begin
    if (gsr_in = '1') then
         drdy_out <= '0';
    elsif (rising_edge(drdy_out_tmp3)) then
      wait until rising_edge(dclk_in);
         drdy_out  <= '1';
      wait until rising_edge(dclk_in);
         drdy_out <= '0';
    end if;
    wait on drdy_out_tmp3, gsr_in;
  end process;


  DRPORT_DO_OUT_P : process(dclk_in, gsr_in)
       variable message : line;
       variable di_str : string (16 downto 1);
       variable daddr_str : string (7 downto  1);
       variable di_40 : std_logic_vector(4 downto 0);
       variable valid_daddr : boolean := false;
       variable address : integer;
       variable tmp_value : integer := 0;
       variable tmp_value1 : std_logic_vector (7 downto 0);
       variable en_data_flag : integer := 0;
       variable init53h_tmp : std_logic_vector (15 downto 0);
       variable first_time : boolean := true;
  begin
      if (first_time = true) then
          dr_sram(16#40#) <= TO_STDLOGICVECTOR(INIT_40);
          dr_sram(16#41#) <= TO_STDLOGICVECTOR(INIT_41);
          dr_sram(16#42#) <= TO_STDLOGICVECTOR(INIT_42);
          dr_sram(16#43#) <= TO_STDLOGICVECTOR(INIT_43);
          dr_sram(16#44#) <= TO_STDLOGICVECTOR(INIT_44);
          dr_sram(16#45#) <= TO_STDLOGICVECTOR(INIT_45);
          dr_sram(16#46#) <= TO_STDLOGICVECTOR(INIT_46);
          dr_sram(16#47#) <= TO_STDLOGICVECTOR(INIT_47);
          dr_sram(16#48#) <= TO_STDLOGICVECTOR(INIT_48);
          dr_sram(16#49#) <= TO_STDLOGICVECTOR(INIT_49);
          dr_sram(16#4A#) <= TO_STDLOGICVECTOR(INIT_4A);
          dr_sram(16#4B#) <= TO_STDLOGICVECTOR(INIT_4B);
          dr_sram(16#4C#) <= TO_STDLOGICVECTOR(INIT_4C);
          dr_sram(16#4D#) <= TO_STDLOGICVECTOR(INIT_4D);
          dr_sram(16#4E#) <= TO_STDLOGICVECTOR(INIT_4E);
          dr_sram(16#4F#) <= TO_STDLOGICVECTOR(INIT_4F);
          dr_sram(16#50#) <= TO_STDLOGICVECTOR(INIT_50);
          dr_sram(16#51#) <= TO_STDLOGICVECTOR(INIT_51);
          dr_sram(16#52#) <= TO_STDLOGICVECTOR(INIT_52);
          init53h_tmp := TO_STDLOGICVECTOR(INIT_53);
          if (init53h_tmp(3 downto 0)="0011")  then
             dr_sram(16#53#) <= init53h_tmp;
             ot_limit_reg  <= init53h_tmp;
          else
            dr_sram(16#53#) <= X"CA00";
            ot_limit_reg  <= X"CA00";
          end if;
          dr_sram(16#54#) <= TO_STDLOGICVECTOR(INIT_54);
          dr_sram(16#55#) <= TO_STDLOGICVECTOR(INIT_55);
          dr_sram(16#56#) <= TO_STDLOGICVECTOR(INIT_56);
          dr_sram(16#57#) <= TO_STDLOGICVECTOR(INIT_57);
        first_time := false;
      end if;
       
     if (gsr_in = '1') then 
         daddr_in_lat  <= "0000000";
         do_out <= "0000000000000000";
     elsif (rising_edge(dclk_in)) then
       if (den_in = '1') then
         if (drdy_out_tmp1 = '0') then
             drdy_out_tmp1 <= '1';
             en_data_flag := 1;
             daddr_in_lat  <= daddr_in;
          else 
            if (daddr_in /= daddr_in_lat) then
              Write ( Message, string'(" Warning : input pin DEN on SYSMON can not continue set to high. Need wait DRDY high and then set DEN high again."));
              assert false report Message.all  severity warning;
              DEALLOCATE(Message);
            end if;
          end if;
        else
           drdy_out_tmp1 <= '0';
        end if;
        
        drdy_out_tmp2 <= drdy_out_tmp1;
        drdy_out_tmp3 <= drdy_out_tmp2;
        drdy_out_tmp4 <= drdy_out_tmp3;

        if (drdy_out_tmp1 = '1') then
            en_data_flag := 0;
        end if;

        if (drdy_out_tmp3 = '1') then
            do_out <= do_out_rdtmp;
        end if;
 
        if (den_in = '1') then
           valid_daddr := addr_is_valid(daddr_in);
           if (valid_daddr) then
               address := slv_to_int(daddr_in);
               if (sim_device_int = '1') then
                 if (  (address > 88 or (address >= 39 and address < 63))) then
                 Write ( Message, string'(" Invalid Input Warning : The DADDR "));
                 Write ( Message, string'(SLV_TO_STR(daddr_in)));
                 Write ( Message, string'("  is not defined. The data in this location is invalid."));
                 assert false report Message.all  severity warning;
                 DEALLOCATE(Message);
                 end if;
               else
                 if (  (address > 88 or (address >= 13 and address <= 15)
                    or (address >= 39 and address <= 63))) then
                 Write ( Message, string'(" Invalid Input Warning : The DADDR "));
                 Write ( Message, string'(SLV_TO_STR(daddr_in)));
                 Write ( Message, string'("  is not defined. The data in this location is invalid."));
                 assert false report Message.all  severity warning;
                 DEALLOCATE(Message);
                 end if;
               end if;
            end if;
         end if;


-- write  all available daddr addresses

        if (dwe_in = '1' and en_data_flag = 1) then  
           if (valid_daddr and address >= 64 and address <= 87) then
           
               dr_sram(address) <= di_in;
           end if;

          if (sim_device_int = '1') then 
            if (address = 3) then
                 soft_reset <= '1';
            end if;
            if ( address = 83) then
                 if (di_in(3 downto 0) = "0011") then
                    ot_limit_reg(15 downto 4)  <= di_in(15 downto 4);
                 end if;
             end if;
          end if;

          if (sim_device_int = '1') then
            if ( address = 42 and  di_in( 2 downto 0) /= "000") then
             Write ( Message, string'(" Invalid Input Error : The DI bit[2:0] "));
             Write ( Message, bit_vector'(TO_BITVECTOR(di_in(2 downto 0))));
             Write ( Message, string'("  at DADDR "));
             Write ( Message, bit_vector'(TO_BITVECTOR(daddr_in)));
             Write ( Message, string'(" of SYSMON is invalid. These must be set to 000."));
             assert false report Message.all  severity error;
           end if;
         else
           if ( address = 42 and  di_in( 1 downto 0) /= "00") then
             Write ( Message, string'(" Invalid Input Error : The DI bit[1:0] "));
             Write ( Message, bit_vector'(TO_BITVECTOR(di_in(1 downto 0))));
             Write ( Message, string'("  at DADDR "));
             Write ( Message, bit_vector'(TO_BITVECTOR(daddr_in)));
             Write ( Message, string'(" of SYSMON is invalid. These must be set to 00."));
             assert false report Message.all  severity error;
           end if;
          end if;

           tmp_value1 := di_in(15 downto 8) ; 
           tmp_value := SLV_TO_INT(SLV=>tmp_value1);

          if (sim_device_int = '1') then
           if ( address = 42 and  tmp_value < 8) then
             Write ( Message, string'(" Invalid Input Error : The DI bit[15:8] "));
             Write ( Message, bit_vector'(TO_BITVECTOR(di_in(15 downto 8))));
             Write ( Message, string'("  at DADDR "));
             Write ( Message, bit_vector'(TO_BITVECTOR(daddr_in)));
             Write ( Message, string'(" of SYSMON is invalid. Bit[15:8] of Control Register 42h is the ADC Clock divider and must be equal or greater than 8."));
             assert false report Message.all  severity failure;
           end if;
          end if;

           if ( (address >= 43 and  address <= 47) and di_in(15 downto 0) /= "0000000000000000") then
             Write ( Message, string'(" Invalid Input Error : The DI value "));
             Write ( Message, bit_vector'(TO_BITVECTOR(di_in)));
             Write ( Message, string'("  at DADDR "));
             Write ( Message, bit_vector'(TO_BITVECTOR(daddr_in)));
             Write ( Message, string'(" of SYSMON is invalid. These must be set to 0000."));
             assert false report Message.all  severity error;
             DEALLOCATE(Message);
           end if;

          tmp_value := SLV_TO_INT(SLV=>di_in(4 downto 0));
      
          if (address = 40) then

           if (((tmp_value = 6) or ( tmp_value = 7) or ((tmp_value >= 10) and (tmp_value <= 15)))) then
             Write ( Message, string'(" Invalid Input Warning : The DI bit[4:0] at DADDR "));
             Write ( Message, bit_vector'(TO_BITVECTOR(daddr_in)));
             Write ( Message, string'(" is  "));
            Write ( Message, bit_vector'(TO_BITVECTOR(di_in(4 downto 0))));
             Write ( Message, string'(", which is invalid analog channel."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;

           if ((cfg_reg1(13 downto 12)="11") and (di_in(8)='1') and (tmp_value /= 3) and (tmp_value < 16)) then
             Write ( Message, string'(" Invalid Input Warning : The DI value is "));
             Write ( Message, bit_vector'(TO_BITVECTOR(di_in)));
             Write ( Message, string'(" at DADDR "));
             Write ( Message, bit_vector'(TO_BITVECTOR(daddr_in)));
             Write ( Message, string'(". Bit[8] of DI must be set to 0. Long acquistion mode is only allowed for external channels."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;

           if ((cfg_reg1(13 downto 12)="11") and (di_in(9)='1') and (tmp_value /= 3) and (tmp_value < 16)) then
             Write ( Message, string'(" Invalid Input Warning : The DI value is "));
             Write ( Message, bit_vector'(TO_BITVECTOR(di_in)));
             Write ( Message, string'(" at DADDR "));
             Write ( Message, bit_vector'(TO_BITVECTOR(daddr_in)));
             Write ( Message, string'(". Bit[9] of DI must be set to 0. Event mode timing can only be used with external channels."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;

           if ((cfg_reg1(13 downto 12)="11") and (di_in(13 downto 12)/="00") and (seq_chan_reg1 /= X"0000") and (seq_chan_reg2 /= X"0000")) then
             Write ( Message, string'(" Invalid Input Warning : The Control Regiter 48h and 49h are "));
             Write ( Message, bit_vector'(TO_BITVECTOR(seq_chan_reg1)));
             Write ( Message, string'(" and  "));
             Write ( Message, bit_vector'(TO_BITVECTOR(seq_chan_reg2)));
             Write ( Message, string'(". Those registers should be set to 0000h in single channel mode and averaging enabled."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;
        end if;

          tmp_value := SLV_TO_INT(SLV=>cfg_reg0(4 downto 0));

          if (address = 41 and en_data_flag = 1) then

           if ((di_in(13 downto 12)="11") and (cfg_reg0(8)='1') and (tmp_value /= 3) and (tmp_value < 16)) then
             Write ( Message, string'(" Invalid Input Warning : The Control Regiter 40h value is "));
             Write ( Message, bit_vector'(TO_BITVECTOR(cfg_reg0)));
             Write ( Message, string'(". Bit[8] of Control Regiter 40h must be set to 0. Long acquistion mode is only allowed for external channels."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;

           if ((di_in(13 downto 12)="11") and (cfg_reg0(9)='1') and (tmp_value /= 3) and (tmp_value < 16)) then
             Write ( Message, string'(" Invalid Input Warning : The Control Regiter 40h value is "));
             Write ( Message, bit_vector'(TO_BITVECTOR(cfg_reg0)));
             Write ( Message, string'(". Bit[9] of Control Regiter 40h must be set to 0. Event mode timing can only be used with external channels."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;

           if ((di_in(13 downto 12) /= "11") and (seq_acq_reg1(10 downto 0) /= "00000000000") and (seq_acq_reg1(15 downto 12) /= "0000")) then
             Write ( Message, string'(" Invalid Input Warning : The Control Regiter 4Eh is "));
             Write ( Message, bit_vector'(TO_BITVECTOR(seq_acq_reg1)));
             Write ( Message, string'(". Bit[15:12] and bit[10:0] of this register must be set to 0. Long acquistion mode is only allowed for external channels."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;

           if ((di_in(13 downto 12) = "11") and (cfg_reg0(13 downto 12) /= "00") and (seq_chan_reg1 /= X"0000") and (seq_chan_reg2 /= X"0000")) then
             Write ( Message, string'(" Invalid Input Warning : The Control Regiter 48h and 49h are "));
             Write ( Message, bit_vector'(TO_BITVECTOR(seq_chan_reg1)));
             Write ( Message, string'(" and  "));
             Write ( Message, bit_vector'(TO_BITVECTOR(seq_chan_reg2)));
             Write ( Message, string'(". Those registers should be set to 0000h in single channel mode and averaging enabled."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;
        end if;
       end if;



        if (daddr_in = "1000001"  and en_data_flag = 1) then
           if (dwe_in = '1' and den_in = '1') then

                if (di_in(13 downto 12) /= cfg_reg1(13 downto 12)) then
                            seq_reset <= '1';
                else
                            seq_reset <= '0';
                end if;

                if (di_in(13 downto 12) /= "11" ) then
                            seq_en_drp <= '1';
                else
                            seq_en_drp <= '0';
                end if;
             else  
                        seq_reset <= '0';
                        seq_en_drp <= '0';
             end if;
        else 
            seq_reset <= '0';
            seq_en_drp <= '0';
        end if;
        if (soft_reset = '1') then
           soft_reset <= '0';
        end if;
     end if;
  end process;

  tmp_dr_sram_out <= dr_sram(daddr_in_lat_int) when (daddr_in_lat_int >= 64 and
                daddr_in_lat_int <= 87) else "0000000000000000";

--  status_reg <= ("000000000000" &  ot_out & alarm_out(2 downto 0));
  status_reg <= ("000000000000" &  ot_out & "000");

  

  tmp_data_reg_out <= data_reg(daddr_in_lat_int) when (daddr_in_lat_int >= 0 and
                daddr_in_lat_int <= 38) else "0000000000000000";

  do_out_rdtmp_p : process( daddr_in_lat, tmp_data_reg_out, tmp_dr_sram_out ) 
      variable Message : line;
      variable valid_daddr : boolean := false;
  begin
           valid_daddr := addr_is_valid(daddr_in_lat);
           daddr_in_lat_int <= slv_to_int(daddr_in_lat);
           if (valid_daddr) then
              if ((daddr_in_lat_int > 88) or 
                               (daddr_in_lat_int >= 13 and daddr_in_lat_int <= 15)
                or (daddr_in_lat_int >= 39 and daddr_in_lat_int < 63)) then 
                    do_out_rdtmp <= "XXXXXXXXXXXXXXXX";
              end if;
        
              if (daddr_in_lat_int = 63) then
                 if (sim_device_int = '1') then
                   do_out_rdtmp <= status_reg;
                 else
                   do_out_rdtmp <= "XXXXXXXXXXXXXXXX";
                 end if;
              end if;

              if ((daddr_in_lat_int >= 0 and  daddr_in_lat_int <= 12) or 
              (daddr_in_lat_int >= 16 and daddr_in_lat_int <= 38)) then

                   do_out_rdtmp <= tmp_data_reg_out;

               elsif (daddr_in_lat_int >= 64 and daddr_in_lat_int <= 87) then
 
                    do_out_rdtmp <= tmp_dr_sram_out;
             end if;
          end if;
   end process;

-- end DRP RAM


  cfg_reg0 <= dr_sram(16#40#);
  cfg_reg1 <= dr_sram(16#41#);
  cfg_reg2 <= dr_sram(16#42#);
  seq_chan_reg1 <= dr_sram(16#48#);
  seq_chan_reg2 <= dr_sram(16#49#);
  seq_avg_reg1 <= dr_sram(16#4A#);
  seq_avg_reg2 <= dr_sram(16#4B#);
  seq_du_reg1 <= dr_sram(16#4C#);
  seq_du_reg2 <= dr_sram(16#4D#);
  seq_acq_reg1 <= dr_sram(16#4E#);
  seq_acq_reg2 <= dr_sram(16#4F#);

  seq1_0 <= cfg_reg1(13 downto 12);

  drp_update_p : process 
    variable seq_bits : std_logic_vector( 1 downto 0);
   begin
    if (rst_in = '1') then
       wait until (rising_edge(dclk_in));
       wait until (rising_edge(dclk_in));
           seq_bits := seq1_0;
    elsif (rising_edge(drp_update)) then
       seq_bits := curr_seq1_0;
    end if;

    if (rising_edge(drp_update) or (rst_in = '1')) then
       if (seq_bits = "00") then 
         alarm_en <= "000";
         ot_en <= '1';
       else 
         ot_en  <= not cfg_reg1(0);
         alarm_en <= not cfg_reg1(3 downto 1);
       end if;
    end if;
      wait on drp_update, rst_in;
   end process;


-- Clock divider, generate  and adcclk

    sysclk_p : process(dclk_in)
    begin
      if (rising_edge(dclk_in)) then
          sysclk <= not sysclk;
      end if;
    end process;


    curr_clkdiv_sel_int_p : process (curr_clkdiv_sel)
    begin
        curr_clkdiv_sel_int <= SLV_TO_INT(curr_clkdiv_sel);
    end process;

    clk_count_p : process(dclk_in)
       variable clk_count : integer := -1;
    begin
     
       if (rising_edge(dclk_in)) then
        if (curr_clkdiv_sel_int > 2 ) then 
            if (clk_count >= curr_clkdiv_sel_int - 1) then
                clk_count := 0;
            else
                clk_count := clk_count + 1;
            end if;

            if (clk_count > (curr_clkdiv_sel_int/2) - 1) then
               adcclk_tmp <= '1';
            else
               adcclk_tmp <= '0';
            end if;
        else
             adcclk_tmp <= not adcclk_tmp;
         end if;
      end if;
   end process;

        curr_clkdiv_sel <= cfg_reg2(15 downto 8);
        adcclk_div1 <= '0' when (curr_clkdiv_sel_int > 2) else '1';
        adcclk <=  not sysclk when adcclk_div1 = '1' else adcclk_tmp;

-- end clock divider

-- latch configuration registers
    acq_latch_p : process ( seq1_0, adc_s1_flag, curr_seq, cfg_reg0_adc, rst_in)
    begin
        if ((seq1_0 = "01" and adc_s1_flag = '0') or seq1_0 = "10") then
            acq_acqsel <= curr_seq(8);
        elsif (seq1_0 = "11") then
            acq_acqsel <= cfg_reg0_adc(8);
        else
            acq_acqsel <= '0';
        end if;

        if (rst_in = '0') then
          if (seq1_0 /= "11" and  adc_s1_flag = '0') then
            acq_avg <= curr_seq(13 downto 12);
            acq_chan <= curr_seq(4 downto 0);
            acq_b_u <= curr_seq(10);
          else 
            acq_avg <= cfg_reg0_adc(13 downto 12);
            acq_chan <= cfg_reg0_adc(4 downto 0);
            acq_b_u <= cfg_reg0_adc(10);
          end if;
        end if;
    end process;

    acq_chan_index <= SLV_TO_INT(acq_chan);

    conv_end_reg_read_P : process ( adcclk, rst_in)
    begin
       if (rst_in = '1') then
           conv_end_reg_read <= "0000";
       elsif (rising_edge(adcclk)) then
           conv_end_reg_read(3 downto 1) <= conv_end_reg_read(2 downto 0);  
           conv_end_reg_read(0) <= single_chan_conv_end or conv_end;
       end if;
   end process;

-- synch to DCLK
       busy_reg_read_P : process ( dclk_in, rst_in)
    begin
       if (rst_in = '1') then
           busy_reg_read <= '1';
       elsif (rising_edge(dclk_in)) then
           busy_reg_read <= not conv_end_reg_read(2);
       end if;
   end process;

   cfg_reg0_adc <= cfg_reg0_adc_tmp6 when sim_device_int = '1' else cfg_reg0_adc_tmp5;
   cfg_reg0_seq <= cfg_reg0_seq_tmp6 when sim_device_int = '1' else cfg_reg0_seq_tmp5;
   acq_e_c <= acq_e_c_tmp6 when sim_device_int = '1' else acq_e_c_tmp5;

   cfg_reg0_adc5_P : process
      variable  first_after_reset : std_ulogic := '1';
   begin
     if (sim_device_int = '0') then
       if (rst_in='1') then
          cfg_reg0_seq_tmp5 <= X"0000";
          cfg_reg0_adc_tmp5  <= X"0000";
          acq_e_c_tmp5 <= '0';
          first_after_reset := '1';
       elsif (falling_edge(busy_reg_read) or falling_edge(rst_in)) then
          wait until (rising_edge(dclk_in));
          wait until (rising_edge(dclk_in));
          wait until (rising_edge(dclk_in));
          if (first_after_reset = '1') then
             first_after_reset := '0';
             cfg_reg0_adc_tmp5 <= cfg_reg0;
             cfg_reg0_seq_tmp5 <= cfg_reg0;
          else
             cfg_reg0_adc_tmp5 <= cfg_reg0_seq;
             cfg_reg0_seq_tmp5 <= cfg_reg0;
          end if;
          acq_e_c_tmp5 <= cfg_reg0(9);
       end if;
     end if;
       wait on busy_reg_read, rst_in;
   end process;

   cfg_reg0_adc6_P : process
      variable  first_after_reset : std_ulogic := '1';
   begin
     if (sim_device_int = '1') then
       if (rst_in='1') then
          cfg_reg0_seq_tmp6 <= X"0000";
          cfg_reg0_adc_tmp6  <= X"0000";
          acq_e_c_tmp6 <= '0';
          first_after_reset := '1';
       elsif (falling_edge(busy_out) or falling_edge(rst_in)) then
          wait until (rising_edge(dclk_in));
          wait until (rising_edge(dclk_in));
          wait until (rising_edge(dclk_in));
          if (first_after_reset = '1') then
             first_after_reset := '0';
             cfg_reg0_adc_tmp6 <= cfg_reg0;
             cfg_reg0_seq_tmp6 <= cfg_reg0;
          else
             cfg_reg0_adc_tmp6 <= cfg_reg0_seq;
             cfg_reg0_seq_tmp6 <= cfg_reg0;
          end if;
          acq_e_c_tmp6 <= cfg_reg0(9);
        end if;
       end if;
       wait on busy_out, rst_in;
   end process;

   busy_r_p : process(conv_start, busy_r_rst, rst_in)
   begin
      if (rst_in = '1') then
         busy_r <= '0';
      elsif (rising_edge(conv_start) and rst_lock = '0') then
          busy_r <= '1';
      elsif (rising_edge(busy_r_rst)) then
          busy_r <= '0';
      end if;
   end process;

   curr_seq1_0_p : process( busy_out)
   begin
     if (falling_edge( busy_out)) then
        if (adc_s1_flag = '1') then
            curr_seq1_0 <= "00";
        else
            curr_seq1_0 <= seq1_0;
        end if;
     end if;
   end process;

   start_conv_p : process ( conv_start, rst_in)
      variable       Message : line;
   begin
     if (rst_in = '1') then
        analog_mux_in <= 0.0;
        curr_chan <= "00000";
     elsif (rising_edge(conv_start)) then
        if ( ((acq_chan_index = 3) or (acq_chan_index >= 16 and acq_chan_index <= 31))) then
            analog_mux_in <= analog_in_diff(acq_chan_index);
        else
             analog_mux_in <= analog_in_uni(acq_chan_index);
        end if;
        curr_chan <= acq_chan;
        curr_seq1_0_lat <= curr_seq1_0;
          
        if (acq_chan_index = 6 or acq_chan_index = 7 or (acq_chan_index >= 10 and acq_chan_index <= 15)) then
            Write ( Message, string'(" Invalid Input Warning : The analog channel  "));
            Write ( Message, acq_chan_index);
            Write ( Message, string'(" to SYSMON is invalid."));
            assert false report Message.all severity warning;
        end if;
           
        if ((seq1_0 = "01" and adc_s1_flag = '0') or seq1_0 = "10" or seq1_0 = "00") then
                curr_avg_set <= curr_seq(13 downto 12);
                curr_b_u <= curr_seq(10);
                curr_e_c <= '0';
                curr_acq <= curr_seq(8);
            else 
                curr_avg_set <= acq_avg;
                curr_b_u <= acq_b_u;
                curr_e_c <= cfg_reg0(9);
                curr_acq <= cfg_reg0(8);
        end if;
      end if; 

    end  process;

-- end latch configuration registers

-- sequence control

     seq_en_dly <= seq_en after 1 ps;

    seq_num_p : process(seq_en_dly)
       variable seq_num_tmp : integer := 0;
       variable si_tmp : integer := 0;
       variable si : integer := 0;
    begin
     if (rising_edge(seq_en_dly)) then
       if (seq1_0  = "01" or seq1_0 = "10") then
          seq_num_tmp := 0;
          for I in 0 to 15 loop
              si := I;
              if (seq_chan_reg1(si) = '1') then
                 seq_num_tmp := seq_num_tmp + 1;
                 seq_mem(seq_num_tmp) <= si;
              end if;
          end loop;
          for I in 16 to 31 loop
              si := I;
              si_tmp := si-16;
              if (seq_chan_reg2(si_tmp) = '1') then
                   seq_num_tmp := seq_num_tmp + 1;
                   seq_mem(seq_num_tmp) <= si;
              end if;
          end loop;
          seq_num <= seq_num_tmp;
        elsif (seq1_0  = "00") then
           seq_num <= 4;
           seq_mem(1) <= 0;
           seq_mem(2) <= 8;
           seq_mem(3) <= 9;
           seq_mem(4) <= 10;
         end if;
     end if;
   end process;


   curr_seq_p : process(seq_count, seq_en_dly)
      variable seq_curr_i : std_logic_vector(4 downto 0);
      variable seq_curr_index : integer;
      variable tmp_value : integer;
      variable curr_seq_tmp : std_logic_vector(15  downto 0);
    begin
    if (seq_count'event or falling_edge(seq_en_dly)) then
      seq_curr_index := seq_mem(seq_count);
      seq_curr_i := STD_LOGIC_VECTOR(TO_UNSIGNED(seq_curr_index, 5));
      curr_seq_tmp := "0000000000000000";
      if (seq_curr_index >= 0 and seq_curr_index <= 15) then
          curr_seq_tmp(2 downto 0) := seq_curr_i(2 downto 0);
          curr_seq_tmp(4 downto 3) := "01";
          curr_seq_tmp(8) := seq_acq_reg1(seq_curr_index);
          curr_seq_tmp(10) := seq_du_reg1(seq_curr_index);
          if (seq1_0 = "00") then
             curr_seq_tmp(13 downto 12) := "01";
          elsif (seq_avg_reg1(seq_curr_index) = '1') then
             curr_seq_tmp(13 downto 12) := cfg_reg0(13 downto 12);
          else
             curr_seq_tmp(13 downto 12) := "00";
          end if;
          if (seq_curr_index >= 0 and seq_curr_index <= 7) then
             curr_seq_tmp(4 downto 3) := "01";
          else
             curr_seq_tmp(4 downto 3) := "00";
          end if;
      elsif (seq_curr_index >= 16 and seq_curr_index <= 31) then
          tmp_value := seq_curr_index -16;
          curr_seq_tmp(4 downto 0) := seq_curr_i;
          curr_seq_tmp(8) := seq_acq_reg2(tmp_value);
          curr_seq_tmp(10) := seq_du_reg2(tmp_value);
          if (seq_avg_reg2(tmp_value) = '1') then
             curr_seq_tmp(13 downto 12) := cfg_reg0(13 downto 12);
          else
             curr_seq_tmp(13 downto 12) := "00";
          end if;
      end if;
      curr_seq <= curr_seq_tmp;
   end if;
   end process;

   eos_en_p : process (adcclk, rst_in)
   begin
        if (rst_in = '1') then 
            seq_count <= 1;
            eos_en <= '0';
        elsif (rising_edge(adcclk)) then
            if ((seq_count = seq_num  ) and (adc_state = CONV_STATE and next_state = END_STATE)
                 and  (curr_seq1_0_lat /= "11") and rst_lock = '0') then
                eos_tmp_en <= '1';
            else
                eos_tmp_en <= '0';
            end if;

            if ((eos_tmp_en = '1') and (seq_status_avg = 0))  then
                eos_en <= '1';
            else
                eos_en <= '0';
            end if;

            if (eos_tmp_en = '1' or curr_seq1_0_lat = "11") then
                seq_count <= 1;
            elsif (seq_count_en = '1' ) then
               if (seq_count >= 32) then
                  seq_count <= 1;
               else
                seq_count <= seq_count +1;
               end if;
            end if;
        end if; 
   end process;

-- end sequence control

-- Acquisition

   busy_out_dly <= busy_out after 10 ps;

   short_acq_p : process(adc_state, rst_in, first_acq)
   begin
       if (rst_in = '1') then
           shorten_acq <= 0;
       elsif (adc_state'event or first_acq'event) then
         if  ((busy_out_dly = '0') and (adc_state=ACQ_STATE) and (first_acq='1')) then
           shorten_acq <= 1;
         else
           shorten_acq <= 0;
         end if;
       end if;
   end process;

   acq_count_p : process (adcclk, rst_in)
   begin
        if (rst_in = '1') then
            acq_count <= 1;
            first_acq <= '1';
        elsif (rising_edge(adcclk)) then
            if (adc_state = ACQ_STATE and rst_lock = '0' and acq_e_c = '0') then 
                first_acq <= '0';

                if (acq_acqsel = '1') then
                    if (acq_count <= 11) then
                        acq_count <= acq_count + 1 + shorten_acq;
                    end if;
                else 
                    if (acq_count <= 4) then
                        acq_count <= acq_count + 1 + shorten_acq;
                    end if;
                end if;

                if (next_state = CONV_STATE) then
                    if ((acq_acqsel = '1' and acq_count < 10) or (acq_acqsel = '0' and acq_count < 4)) then
                    assert false report "Warning: Acquisition time not enough for SYSMON."
                    severity warning;
                    end if;
                end if;
            else
                if (first_acq = '1') then
                    acq_count <= 1;
                else
                    acq_count <= 0;
                end if;
            end if;
        end if; 
    end process;

    conv_start_con_p: process(adc_state, acq_acqsel, acq_count)
    begin
      if (adc_state = ACQ_STATE) then
        if (rst_lock = '0') then
         if ((seq_reset_flag = '0' or (seq_reset_flag = '1' and curr_clkdiv_sel_int > 3))
           and ((acq_acqsel = '1' and acq_count > 10) or (acq_acqsel = '0' and acq_count > 4))) then
                 conv_start_cont <= '1';
         else
                 conv_start_cont <= '0';
         end if;
       end if;
     else
         conv_start_cont <= '0';
     end if;
   end process;
 
   conv_start_sel <= convst_in when (acq_e_c = '1') else conv_start_cont;
   reset_conv_start_tmp <= '1' when (conv_count=2) else '0';
   reset_conv_start <= rst_in or reset_conv_start_tmp;
  
   conv_start_p : process(conv_start_sel, reset_conv_start)
   begin
      if (reset_conv_start ='1') then
          conv_start <= '0';
      elsif (rising_edge(conv_start_sel)) then
          conv_start <= '1';
      end if;
   end process;

-- end acquisition


-- Conversion
    conv_result_p : process (adc_state, next_state, curr_chan, curr_chan_index, analog_mux_in, curr_b_u)
       variable conv_result_int_i : integer := 0;
       variable conv_result_int_tmp : integer := 0;
       variable conv_result_int_tmp_rl : real := 0.0;
       variable adc_analog_tmp : real := 0.0;
    begin
        if ((adc_state = CONV_STATE and next_state = END_STATE) or adc_state = END_STATE) then
            if (curr_chan = "00000") then    -- temperature conversion
                    adc_analog_tmp := (analog_mux_in + 273.0) * 130.0382;
                    adc_temp_result <= adc_analog_tmp;
                    if (adc_analog_tmp >= 65535.0) then
                        conv_result_int_i := 65535;
                    elsif (adc_analog_tmp < 0.0) then
                        conv_result_int_i := 0;
                    else 
                        conv_result_int_tmp := real2int(adc_analog_tmp);
                        conv_result_int_tmp_rl := real(conv_result_int_tmp);
                        if (adc_analog_tmp - conv_result_int_tmp_rl > 0.9999) then
                            conv_result_int_i := conv_result_int_tmp + 1;
                        else
                            conv_result_int_i := conv_result_int_tmp;
                        end if;
                    end if;
                    conv_result_int <= conv_result_int_i;
                    conv_result <= STD_LOGIC_VECTOR(TO_UNSIGNED(conv_result_int_i, 16));
            elsif (curr_chan = "00001" or curr_chan = "00010") then     -- internal power conversion
                    adc_analog_tmp := analog_mux_in * 65536.0 / 3.0;
                    adc_intpwr_result <= adc_analog_tmp;
                    if (adc_analog_tmp >= 65535.0) then
                        conv_result_int_i := 65535;
                    elsif (adc_analog_tmp < 0.0) then
                        conv_result_int_i := 0;
                    else 
                       conv_result_int_tmp := real2int(adc_analog_tmp);
                        conv_result_int_tmp_rl := real(conv_result_int_tmp);
                        if (adc_analog_tmp - conv_result_int_tmp_rl > 0.9999) then
                            conv_result_int_i := conv_result_int_tmp + 1;
                        else
                            conv_result_int_i := conv_result_int_tmp;
                        end if;
                    end if;
                    conv_result_int <= conv_result_int_i;
                    conv_result <= STD_LOGIC_VECTOR(TO_UNSIGNED(conv_result_int_i, 16));
            elsif ((curr_chan = "00011") or ((curr_chan_index >= 16) and  (curr_chan_index <= 31))) then
                    adc_analog_tmp :=  (analog_mux_in) * 65536.0;
                    adc_ext_result <= adc_analog_tmp;
                    if (curr_b_u = '1')  then
                        if (adc_analog_tmp > 32767.0) then
                             conv_result_int_i := 32767;
                        elsif (adc_analog_tmp < -32768.0) then
                             conv_result_int_i := -32768;
                        else 
                            conv_result_int_tmp := real2int(adc_analog_tmp);
                            conv_result_int_tmp_rl := real(conv_result_int_tmp);
                            if (adc_analog_tmp - conv_result_int_tmp_rl > 0.9999) then
                                conv_result_int_i := conv_result_int_tmp + 1;
                            else
                                conv_result_int_i := conv_result_int_tmp;
                            end if;
                        end if;
                    conv_result_int <= conv_result_int_i;
                    conv_result <= STD_LOGIC_VECTOR(TO_SIGNED(conv_result_int_i, 16));
                    else
                       if (adc_analog_tmp  > 65535.0) then
                             conv_result_int_i := 65535;
                        elsif (adc_analog_tmp  < 0.0) then
                             conv_result_int_i := 0;
                        else
                            conv_result_int_tmp := real2int(adc_analog_tmp);
                            conv_result_int_tmp_rl := real(conv_result_int_tmp);
                            if (adc_analog_tmp - conv_result_int_tmp_rl > 0.9999) then
                                conv_result_int_i := conv_result_int_tmp + 1;
                            else
                                conv_result_int_i := conv_result_int_tmp;
                            end if;
                        end if;
                    conv_result_int <= conv_result_int_i;
                    conv_result <= STD_LOGIC_VECTOR(TO_UNSIGNED(conv_result_int_i, 16));
                    end if;
            else 
                conv_result_int <= 0;
                conv_result <= "0000000000000000";
            end if;
         end if;

    end process;


    conv_count_p : process (adcclk, rst_in)
    begin
        if (rst_in = '1') then
            conv_count <= 6;
            conv_end <= '0';
            seq_status_avg <= 0;
            busy_r_rst <= '0';
            busy_r_rst_done <= '0';
            for i in 0 to 31 loop
                conv_avg_count(i) <= 0;     -- array of integer
            end loop;
            single_chan_conv_end <= '0';
        elsif (rising_edge(adcclk)) then
            if (adc_state = ACQ_STATE) then
               if (busy_r_rst_done = '0') then
                    busy_r_rst <= '1';
               else
                    busy_r_rst <= '0';
               end if;
               busy_r_rst_done <= '1';
            end if;

            if (adc_state = ACQ_STATE and conv_start = '1') then
                conv_count <= 0;
                conv_end <= '0';
            elsif (adc_state = CONV_STATE ) then
                busy_r_rst_done <= '0';
                conv_count <= conv_count + 1;

                if (((curr_chan /= "01000" ) and (conv_count = conv_time )) or 
              ((curr_chan = "01000") and (conv_count = conv_time_cal_1) and (first_cal_chan = '1'))
              or ((curr_chan = "01000") and (conv_count = conv_time_cal) and (first_cal_chan = '0'))) then
                    conv_end <= '1';
                else
                    conv_end <= '0';
                end if;
            else  
                conv_end <= '0';
                conv_count <= 0;
            end if;

           single_chan_conv_end <= '0';
           if ( (conv_count = conv_time) or (conv_count = 44)) then
                   single_chan_conv_end <= '1';
           end if;

            if (adc_state = CONV_STATE and next_state = END_STATE and rst_lock = '0') then
                case curr_avg_set is
                    when "00" => eoc_en <= '1';
                                conv_avg_count(curr_chan_index) <= 0;
                    when "01" =>
                                if (conv_avg_count(curr_chan_index) = 15) then
                                  eoc_en <= '1';
                                  conv_avg_count(curr_chan_index) <= 0;
                                  seq_status_avg <= seq_status_avg - 1;
                                else 
                                  eoc_en <= '0';
                                  if (conv_avg_count(curr_chan_index) = 0) then
                                      seq_status_avg <= seq_status_avg + 1;
                                  end if;
                                  conv_avg_count(curr_chan_index) <= conv_avg_count(curr_chan_index) + 1;
                                end if;
                   when "10" =>
                                if (conv_avg_count(curr_chan_index) = 63) then
                                    eoc_en <= '1';
                                    conv_avg_count(curr_chan_index) <= 0;
                                    seq_status_avg <= seq_status_avg - 1;
                                else 
                                    eoc_en <= '0';
                                    if (conv_avg_count(curr_chan_index) = 0) then
                                        seq_status_avg <= seq_status_avg + 1;
                                    end if;
                                    conv_avg_count(curr_chan_index) <= conv_avg_count(curr_chan_index) + 1;
                                end if;
                    when "11" => 
                                if (conv_avg_count(curr_chan_index) = 255) then
                                    eoc_en <= '1';
                                    conv_avg_count(curr_chan_index) <= 0;
                                    seq_status_avg <= seq_status_avg - 1;
                                else 
                                    eoc_en <= '0';
                                    if (conv_avg_count(curr_chan_index) = 0) then
                                        seq_status_avg <= seq_status_avg + 1;
                                    end if;
                                    conv_avg_count(curr_chan_index) <= conv_avg_count(curr_chan_index) + 1;
                                end if;
                   when  others => eoc_en <= '0';
                end case;
            else
                eoc_en <= '0';
            end if;

            if (adc_state = END_STATE) then
                   conv_result_reg <= conv_result;
            end if;
        end if;
   end process;

-- end conversion

   
-- average
    
    conv_acc_result_p : process(adcclk, rst_in)
       variable conv_acc_vec : std_logic_vector(23 downto 0);
       variable conv_acc_vec_int  : integer;
    begin
        if (rst_in = '1') then 
            for j in 0 to 31 loop
                conv_acc(j) <= 0;
            end loop;
            conv_acc_result <= "0000000000000000";
        elsif (rising_edge(adcclk)) then
            if (adc_state = CONV_STATE and  next_state = END_STATE) then
                if (curr_avg_set /= "00" and rst_lock /= '1') then
                    conv_acc(curr_chan_index) <= conv_acc(curr_chan_index) + conv_result_int;
                else
                    conv_acc(curr_chan_index) <= 0;
                end if;
            elsif (eoc_en = '1') then
                conv_acc_vec_int := conv_acc(curr_chan_index);
                if ((curr_b_u = '1') and (((curr_chan_index >= 16) and (curr_chan_index <= 31))
                   or (curr_chan_index = 3))) then
                    conv_acc_vec := STD_LOGIC_VECTOR(TO_SIGNED(conv_acc_vec_int, 24));
                else
                    conv_acc_vec := STD_LOGIC_VECTOR(TO_UNSIGNED(conv_acc_vec_int, 24));
                end if;
                case curr_avg_set(1 downto 0) is
                  when "00" => conv_acc_result <= "0000000000000000";
                  when "01" => conv_acc_result <= conv_acc_vec(19 downto 4);
                  when "10" => conv_acc_result <= conv_acc_vec(21 downto 6);
                  when "11" => conv_acc_result <= conv_acc_vec(23 downto 8);
                  when others => conv_acc_result <= "0000000000000000";
                end case;
                conv_acc(curr_chan_index) <= 0;
            end if;
        end if;
    end process;

-- end average   

-- single sequence
    adc_s1_flag_p : process(adcclk, rst_in)
    begin
        if (rst_in = '1') then
            adc_s1_flag <= '0';
        elsif (rising_edge(adcclk)) then 
            if (adc_state = SINGLE_SEQ_STATE) then
                adc_s1_flag <= '1';
            end if;
        end if;
    end process;


--  end state
    eos_eoc_p: process(adcclk, rst_in)
    begin
        if (rst_in = '1') then
            seq_count_en <= '0';
            eos_out_tmp <= '0';
            eoc_out_tmp <= '0';
        elsif (rising_edge(adcclk)) then
            if ((adc_state = CONV_STATE and next_state = END_STATE) and (curr_seq1_0_lat /= "11")
                  and (rst_lock = '0')) then
                seq_count_en <= '1';
            else
                seq_count_en <= '0';
            end if;

            if (rst_lock = '0') then
                 eos_out_tmp <= eos_en;
                 eoc_en_delay <= eoc_en;
                 eoc_out_tmp <= eoc_en_delay;
            else 
                 eos_out_tmp <= '0';
                 eoc_en_delay <= '0';
                 eoc_out_tmp <= '0';
            end if;
        end if;
   end process;

    data_reg_p : process(eoc_out, rst_in_not_seq)
       variable tmp_uns1 : unsigned(15 downto 0);
       variable tmp_uns2 : unsigned(15 downto 0);
       variable tmp_uns3 : unsigned(15 downto 0);
    begin
        if (rst_in_not_seq = '1') then
            for k in  32 to  39 loop
                if (k >= 36) then
                    data_reg(k) <= "1111111111111111";
                else
                    data_reg(k) <= "0000000000000000";
                end if;
            end loop;
        elsif (rising_edge(eoc_out)) then
            if ( rst_lock = '0') then
                if ((curr_chan_index >= 0 and curr_chan_index <= 3) or 
                          (curr_chan_index >= 16 and curr_chan_index <= 31)) then
                    if (curr_avg_set = "00") then
                        data_reg(curr_chan_index) <= conv_result_reg;
                    else
                        data_reg(curr_chan_index) <= conv_acc_result;
                    end if;
                end if;
                if (curr_chan_index = 4) then
                    data_reg(curr_chan_index) <= X"D555";
                end if;
                if (curr_chan_index = 5) then
                    data_reg(curr_chan_index) <= X"0000";
                end if;
                if (curr_chan_index = 0 or curr_chan_index = 1 or curr_chan_index = 2) then
                    tmp_uns2 := UNSIGNED(data_reg(32 + curr_chan_index));
                    tmp_uns3 := UNSIGNED(data_reg(36 + curr_chan_index));
                    if (curr_avg_set = "00") then
                        tmp_uns1 := UNSIGNED(conv_result_reg);
                        if (tmp_uns1 > tmp_uns2) then
                            data_reg(32 + curr_chan_index) <= conv_result_reg;
                         end if;
                        if (tmp_uns1 < tmp_uns3) then
                            data_reg(36 + curr_chan_index) <= conv_result_reg;
                        end if;
                    else 
                        tmp_uns1 := UNSIGNED(conv_acc_result);
                        if (tmp_uns1 > tmp_uns2) then
                            data_reg(32 + curr_chan_index) <= conv_acc_result;
                        end if;
                        if (tmp_uns1 < tmp_uns3) then
                            data_reg(36 + curr_chan_index) <= conv_acc_result;
                        end if;
                    end if;
                end if;
           end if;
       end if;
     end process;

    data_written_p : process(busy_r, rst_in_not_seq)
    begin
       if (rst_in_not_seq = '1') then
            data_written <= X"0000";
       elsif (falling_edge(busy_r)) then
          if (curr_avg_set = "00") then
               data_written <= conv_result_reg;
           else
              data_written <= conv_acc_result;
           end if;
       end if;
    end process;

-- eos and eoc

    eoc_out_tmp1_p : process (eoc_out_tmp, eoc_out, rst_in)
    begin
           if (rst_in = '1') then
              eoc_out_tmp1 <= '0';
           elsif (rising_edge(eoc_out)) then
               eoc_out_tmp1 <= '0';
           elsif (rising_edge(eoc_out_tmp)) then
               if (curr_chan /= "01000") then
                  eoc_out_tmp1 <= '1';
               else
                  eoc_out_tmp1 <= '0';
               end if;
           end if;
    end process;

    eos_out_tmp1_p : process (eos_out_tmp, eos_out, rst_in)
    begin
           if (rst_in = '1') then
              eos_out_tmp1 <= '0';
           elsif (rising_edge(eos_out)) then
               eos_out_tmp1 <= '0';
           elsif (rising_edge(eos_out_tmp)) then
               eos_out_tmp1 <= '1';
           end if;
    end process;

    busy_out_low_edge <= '1' when (busy_out='0' and busy_out_sync='1') else '0';

    eoc_eos_out_p : process (dclk_in, rst_in)
    begin
      if (rst_in = '1') then
          op_count <= 15;
          busy_out_sync <= '0';
          drp_update <= '0';
          alarm_update <= '0';
          eoc_out <= '0';
          eos_out <= '0';
      elsif ( rising_edge(dclk_in)) then
         busy_out_sync <= busy_out;   
         if (op_count = 3) then
            drp_update <= '1';
          else 
            drp_update <= '0';
          end if;
          if (op_count = 5 and eoc_out_tmp1 = '1') then
             alarm_update <= '1';
          else
             alarm_update <= '0';
          end if;
          if (op_count = 9 ) then
             eoc_out <= eoc_out_tmp1;
          else
             eoc_out <= '0';
          end if;
          if (op_count = 9) then
             eos_out <= eos_out_tmp1;
          else
             eos_out <= '0';
          end if;
          if (busy_out_low_edge = '1') then
              op_count <= 0;
          elsif (op_count < 15) then
              op_count <= op_count +1;
          end if;
      end if;
   end process;

-- end eos and eoc


-- alarm

    alm_reg_p : process(alarm_update, rst_in_not_seq )
       variable  tmp_unsig1 : unsigned(15 downto 0);
       variable  tmp_unsig2 : unsigned(15 downto 0);
       variable  tmp_unsig3 : unsigned(15 downto 0);
    begin
     if (rst_in_not_seq = '1') then
        ot_out_reg <= '0';
        alarm_out_reg <= "000";
     elsif (rising_edge(alarm_update)) then
       if (rst_lock = '0') then
          if (curr_chan_lat = "00000") then
            tmp_unsig1 := UNSIGNED(data_written);
            tmp_unsig2 := UNSIGNED(dr_sram(16#57#));
--            if (tmp_unsig1 >= ot_limit_reg) then
            if (data_written >= ot_limit_reg) then
                ot_out_reg <= '1';
            elsif (tmp_unsig1 < tmp_unsig2)  then
                ot_out_reg <= '0';
            end if;
            tmp_unsig2 := UNSIGNED(dr_sram(16#50#));
            tmp_unsig3 := UNSIGNED(dr_sram(16#54#));
            if ( tmp_unsig1 > tmp_unsig2) then
                     alarm_out_reg(0) <= '1';
            elsif (tmp_unsig1 <= tmp_unsig3) then
                     alarm_out_reg(0) <= '0';
            end if;
          end if;
          tmp_unsig1 := UNSIGNED(data_written);
          tmp_unsig2 := UNSIGNED(dr_sram(16#51#));
          tmp_unsig3 := UNSIGNED(dr_sram(16#55#));
          if (curr_chan_lat = "00001") then
             if ((tmp_unsig1 > tmp_unsig2) or (tmp_unsig1 < tmp_unsig3)) then
                      alarm_out_reg(1) <= '1';
             else
                      alarm_out_reg(1) <= '0';
             end if;
          end if;
          tmp_unsig1 := UNSIGNED(data_written);
          tmp_unsig2 := UNSIGNED(dr_sram(16#52#));
          tmp_unsig3 := UNSIGNED(dr_sram(16#56#));
          if (curr_chan_lat = "00010") then
              if ((tmp_unsig1 > tmp_unsig2) or (tmp_unsig1 < tmp_unsig3)) then
                      alarm_out_reg(2) <= '1';
                 else
                      alarm_out_reg(2) <= '0';
              end if;
          end if;
     end if;
    end if;
   end process;


    alm_p : process(ot_out_reg, ot_en, alarm_out_reg, alarm_en)
    begin
             ot_out <= ot_out_reg and ot_en;
             alarm_out(0) <= alarm_out_reg(0) and alarm_en(0);
             alarm_out(1) <= alarm_out_reg(1) and alarm_en(1);
             alarm_out(2) <= alarm_out_reg(2) and alarm_en(2);
      end process;

-- end alarm


  READFILE_P : process
      file in_file : text;
      variable open_status : file_open_status;
      variable in_buf    : line;
      variable str_token : string(1 to 12);
      variable str_token_in : string(1 to 12);
      variable str_token_tmp : string(1 to 12);
      variable next_time     : time := 0 ps; 
      variable pre_time : time := 0 ps; 
      variable time_val : integer := 0;
      variable a1   : real;

      variable commentline : boolean := false;
      variable HeaderFound : boolean := false;
      variable read_ok : boolean := false;
      variable token_len : integer;
      variable HeaderCount : integer := 0;

      variable vals : ANALOG_DATA := (others => 0.0);
      variable valsn : ANALOG_DATA := (others => 0.0);
      variable inchannel : integer := 0 ;
      type int_a is array (0 to 41) of integer;
      variable index_to_channel : int_a := (others => -1);
      variable low : integer := -1;
      variable low2 : integer := -1;
      variable sim_file_flag1 : std_ulogic := '0';
      variable file_line : integer := 0;

      type channm_array is array (0 to 31 ) of string(1 to  12);
      constant chanlist_p : channm_array := (
       0 => "TEMP" & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL,
       1 => "VCCINT" & NUL & NUL & NUL & NUL & NUL & NUL,
       2 => "VCCAUX" & NUL & NUL & NUL & NUL & NUL & NUL,	
       3 => "VP" & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL,
       4 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       5 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       6 => "xxxxxxxxxxxx",
       7 => "xxxxxxxxxxxx",
       8 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       9 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       10 => "xxxxxxxxxxxx",
       11 => "xxxxxxxxxxxx",
       12 => "xxxxxxxxxxxx",
       13 => "xxxxxxxxxxxx",
       14 => "xxxxxxxxxxxx",
       15 => "xxxxxxxxxxxx",
       16 => "VAUXP[0]" & NUL & NUL & NUL & NUL,
       17 => "VAUXP[1]" & NUL & NUL & NUL & NUL,
       18 => "VAUXP[2]" & NUL & NUL & NUL & NUL,
       19 => "VAUXP[3]" & NUL & NUL & NUL & NUL,
       20 => "VAUXP[4]" & NUL & NUL & NUL & NUL,
       21 => "VAUXP[5]" & NUL & NUL & NUL & NUL,
       22 => "VAUXP[6]" & NUL & NUL & NUL & NUL,
       23 => "VAUXP[7]" & NUL & NUL & NUL & NUL,
       24 => "VAUXP[8]" & NUL & NUL & NUL & NUL,
       25 => "VAUXP[9]" & NUL & NUL & NUL & NUL,
       26 => "VAUXP[10]" & NUL & NUL & NUL,
       27 => "VAUXP[11]" & NUL & NUL & NUL,
       28 => "VAUXP[12]" & NUL & NUL & NUL,
       29 => "VAUXP[13]" & NUL & NUL & NUL,
       30 => "VAUXP[14]" & NUL & NUL & NUL,
       31 => "VAUXP[15]" & NUL & NUL & NUL
      );
       
      constant chanlist_n : channm_array := (
       0 => "xxxxxxxxxxxx",
       1 => "xxxxxxxxxxxx",
       2 => "xxxxxxxxxxxx",
       3 => "VN" & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL,
       4 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       5 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       6 => "xxxxxxxxxxxx",
       7 => "xxxxxxxxxxxx",
       8 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       9 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       10 => "xxxxxxxxxxxx",
       11 => "xxxxxxxxxxxx",
       12 => "xxxxxxxxxxxx",
       13 => "xxxxxxxxxxxx",
       14 => "xxxxxxxxxxxx",
       15 => "xxxxxxxxxxxx",
       16 => "VAUXN[0]" & NUL & NUL & NUL & NUL,
       17 => "VAUXN[1]" & NUL & NUL & NUL & NUL,
       18 => "VAUXN[2]" & NUL & NUL & NUL & NUL,
       19 => "VAUXN[3]" & NUL & NUL & NUL & NUL,
       20 => "VAUXN[4]" & NUL & NUL & NUL & NUL,
       21 => "VAUXN[5]" & NUL & NUL & NUL & NUL,
       22 => "VAUXN[6]" & NUL & NUL & NUL & NUL,
       23 => "VAUXN[7]" & NUL & NUL & NUL & NUL,
       24 => "VAUXN[8]" & NUL & NUL & NUL & NUL,
       25 => "VAUXN[9]" & NUL & NUL & NUL & NUL,
       26 => "VAUXN[10]" & NUL & NUL & NUL,
       27 => "VAUXN[11]" & NUL & NUL & NUL,
       28 => "VAUXN[12]" & NUL & NUL & NUL,
       29 => "VAUXN[13]" & NUL & NUL & NUL,
       30 => "VAUXN[14]" & NUL & NUL & NUL,
       31 => "VAUXN[15]" & NUL & NUL & NUL
           );

  begin
 
    file_open(open_status, in_file, SIM_MONITOR_FILE, read_mode);
    if (open_status /= open_ok) then
         assert false report
         "*** Warning: The analog data file for SYSMON was not found. Use the SIM_MONITOR_FILE generic to specify the input analog data file name or use default name: design.txt. "
         severity warning; 
         sim_file_flag1 := '1';
         sim_file_flag <= '1';
    end if;

   if ( sim_file_flag1 = '0') then
      while (not endfile(in_file) and (not HeaderFound)) loop
        commentline := false;
        readline(in_file, in_buf);
        file_line := file_line + 1;
        if (in_buf'LENGTH > 0 ) then
          skip_blanks(in_buf);
        
          low := in_buf'low;
          low2 := in_buf'low+2;
           if ( low2 <= in_buf'high) then
              if ((in_buf(in_buf'low to in_buf'low+1) = "//" ) or 
                  (in_buf(in_buf'low to in_buf'low+1) = "--" )) then
                 commentline := true;
               end if;

               while((in_buf'LENGTH > 0 ) and (not commentline)) loop
                   HeaderFound := true;
                   get_token(in_buf, str_token_in, token_len);
                   str_token_tmp := To_Upper(str_token_in);
                   if (str_token_tmp(1 to 4) = "TEMP") then
                      str_token := "TEMP" & NUL & NUL & NUL & NUL & NUL 
                                                  & NUL & NUL & NUL;
                   else
                      str_token := str_token_tmp;
                   end if;

                   if(token_len > 0) then
                    HeaderCount := HeaderCount + 1;
                   end if;
       
                   if (HeaderCount=1) then
                      if (str_token(1 to token_len) /= "TIME") then
                         infile_format;
                         assert false report
                  " Analog Data File Error : No TIME label is found in the input file for SYSMON."
                         severity failure;
                      end if;
                   elsif (HeaderCount > 1) then
                      inchannel := -1;
                      for i in 0 to 31 loop
                          if (chanlist_p(i) = str_token) then
                             inchannel := i;
                             index_to_channel(headercount) := i;
                           end if;
                       end loop;
                       if (inchannel = -1) then
                         for i in 0 to 31 loop
                           if ( chanlist_n(i) = str_token) then
                             inchannel := i;
                             index_to_channel(headercount) := i+32;
                           end if;
                         end loop;
                       end if;
                       if (inchannel = -1 and token_len >0) then
                           infile_format;
                           assert false report
                    "Analog Data File Error : No valid channel name in the input file for SYSMON. Valid names: TEMP VCCINT VCCAUX VP VN VAUXP[1] VAUXN[1] ....."
                           severity failure;
                       end if;
                  else
                       infile_format;
                       assert false report
                    "Analog Data File Error : NOT found header in the input file for SYSMON. The header is: TIME TEMP VCCINT VCCAUX VP VN VAUXP[1] VAUXN[1] ..."
                           severity failure;
                  end if;

           str_token_in := NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
                           NUL & NUL & NUL & NUL;
        end loop;
        end if;
       end if;
      end loop;

-----  Read Values
      while (not endfile(in_file)) loop
        commentline := false;
        readline(in_file, in_buf);
        file_line := file_line + 1;
        if (in_buf'length > 0) then
           skip_blanks(in_buf);
        
           if (in_buf'low < in_buf'high) then
             if((in_buf(in_buf'low to in_buf'low+1) = "//" ) or 
                    (in_buf(in_buf'low to in_buf'low+1) = "--" )) then
              commentline := true;
             end if;
 
          if(not commentline and in_buf'length > 0) then
            for i IN 1 to HeaderCount Loop
              if ( i=1) then
                 read(in_buf, time_val, read_ok);
                if (not read_ok) then
                  infile_format;
                  assert false report
                   " Analog Data File Error : The time value should be integer in ns scale and the last time value needs bigger than simulation time."
                  severity failure;
                 end if;
                 next_time := time_val * 1 ns; 
              else
               read(in_buf, a1, read_ok);
               if (not read_ok) then
                  assert false report
                    "*** Analog Data File Error: The data type should be REAL, e.g. 3.0  0.0  -0.5 "
                  severity failure;
               end if;
               inchannel:= index_to_channel(i);
              if (inchannel >= 32) then
                valsn(inchannel-32):=a1;
              else
                vals(inchannel):=a1;
              end if;
            end if;
           end loop;  -- i loop

           if ( now < next_time) then
               wait for ( next_time - now ); 
           end if;
           for i in 0 to 31 loop
                 chan_val_tmp(i) <= vals(i);
                 chan_valn_tmp(i) <= valsn(i);
                 analog_in_diff(i) <= vals(i)-valsn(i);
                 analog_in_uni(i) <= vals(i);
           end loop;
        end if;
        end if;
       end if;
      end loop;  -- while loop
      file_close(in_file);
    end if;
    wait;
  end process READFILE_P;



end SYSMON_V;

