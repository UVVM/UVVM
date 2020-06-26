------------------------------------------------------------------------------/
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Function Simulation Library Component
--  /   /                  Configuration Simulation Model
-- /___/   /\     Filename : SIM_CONFIG_S6.vhd
-- \   \  /  \    Timestamp : 
--  \___\/\___\
--
-- Revision:
--    07/20/09 - Initial version.
--    09/17/09 - Remove DCMLOCK pin (CR530867)
--    10/02/09 - Not write to frame out file after icap_init_done=1 (CR535320)
--    11/25/09 - Fix CRC (CR538766)
--    12/17/09 - Allow ICAP use without RBT file (CR537437) 
--    01/12/10 - Reverse bits for readback (CR544212)
--    02/04/10 - Support MMCM lock wait function (CR547918)
--    02/24/10 - Change Tprog to 500 ns (CR550552)
--    03/02/10 - Desync when icap initial done (CR551856)
--    03/03/10 - set mode_sample_flag to 0 when mode pin set wrong (CR552316)
--    03/11/10 - Not check crc when icap initial time (553387)
--    05/19/10 - Not reset startup_set_pulse when rw_en=0 (CR559852)
--    03/08/11 - generate BUSY one cycle after CE (CR595935)
--    05/03/11 - byte swap for abort_status (CR605126)
--    07/01/11 - Generate startup_set_pulse when rw_en=1 (595934)
--    10/26/11 - Use negedge for csi_sync (CR631238)
--    03/29/12 - Fixed async RDWRB and CSIB abort flag to sync (CR 649104)
--    06/04/12 - Fixed async RDWRB (CR 649104)
--    06/20/12 - Fixed RDWRB (CR 664479)
--    10/10/12 - Changed cfg_Tpl to 5us (scaled), changed cfg_Tpl and cfg_Tprog
--               to generic (CR 680996).
--    11/14/12 - Fixed crc_bypass (CR 678735).
-- End Revision
--------------------------------------------------------------------------------


----- CELL SIM_CONFIG_S6  -----
library IEEE;
use IEEE.std_logic_1164.all;


library STD;
use STD.TEXTIO.all;
library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity SIM_CONFIG_S6 is
  generic (
    cfg_Tprog : time := 500000 ps;   -- min PROG must be low, 300 ns
    cfg_Tpl : time := 5 us;  -- max program latency 5 ms but scaled to 5 us.
    DEVICE_ID : bit_vector := X"00000000";
    ICAP_SUPPORT : boolean := false
    );
  port (
    BUSY : out std_ulogic := '0';
    CSOB : out std_ulogic := '1';
    DONE : inout std_ulogic := '0';
    CCLK : in  std_ulogic := '0';
    D : inout std_logic_vector(15 downto 0);
    CSIB : in  std_ulogic := '0';
    INITB : inout std_ulogic := 'H';
    M : in  std_logic_vector(1 downto 0) := "00";
    PROGB : in  std_ulogic := '0';
    RDWRB : in  std_ulogic := '0'
    );

end SIM_CONFIG_S6;

architecture SIM_CONFIG_S6_V of SIM_CONFIG_S6 is

  function crc_next (
      crc_currf : in std_logic_vector(21 downto 0);
      crc_inputf : in std_logic_vector(21 downto 0)
      ) return  std_logic_vector
   is
      variable i_crc : integer;
      variable crc_next_v : std_logic_vector(21 downto 0);
  begin
    i_crc := 21;
    for i in 21 downto 16 loop
       crc_next_v(i_crc) := crc_currf(i_crc-1) xor crc_inputf(i_crc);
        i_crc := i_crc -1;
    end loop;

    crc_next_v(15) := crc_currf(14) xor crc_inputf(15) xor crc_currf(21);

    i_crc := 14;
   for i in 14 downto 13 loop
       crc_next_v(i_crc) := crc_currf(i_crc-1) xor crc_inputf(i_crc);
       i_crc := i_crc -1;
   end loop;


   crc_next_v(12) := crc_currf(11) xor crc_inputf(12) xor crc_currf(21);

   i_crc := 11;
   for i in 11 downto 8 loop
       crc_next_v(i_crc) := crc_currf(i_crc-1) xor crc_inputf(i_crc);
       i_crc := i_crc -1;
   end loop;

   crc_next_v(7) := crc_currf(6) xor crc_inputf(7) xor crc_currf(21);

   i_crc := 6;
   for i in 6 downto 1 loop
       crc_next_v(i_crc) := crc_currf(i_crc-1) xor crc_inputf(i_crc);
       i_crc := i_crc -1;
   end loop;

   crc_next_v(0) :=  crc_inputf(0) xor crc_currf(21);

   return crc_next_v;
  end crc_next;

function bit_revers8 ( din8 : in std_logic_vector(7 downto 0))
                   return  std_logic_vector is
  variable bit_rev8 : std_logic_vector(7 downto 0);
  begin
      bit_rev8(0) := din8(7);
      bit_rev8(1) := din8(6);
      bit_rev8(2) := din8(5);
      bit_rev8(3) := din8(4);
      bit_rev8(4) := din8(3);
      bit_rev8(5) := din8(2);
      bit_rev8(6) := din8(1);
      bit_rev8(7) := din8(0);

     return bit_rev8;
  end bit_revers8;

  constant STARTUP_PH0 : std_logic_vector(2 downto 0) := "000";
  constant STARTUP_PH1 : std_logic_vector(2 downto 0) := "001";
  constant STARTUP_PH2 : std_logic_vector(2 downto 0) := "010";
  constant STARTUP_PH3 : std_logic_vector(2 downto 0) := "011";
  constant STARTUP_PH4 : std_logic_vector(2 downto 0) := "100";
  constant STARTUP_PH5 : std_logic_vector(2 downto 0) := "101";
  constant STARTUP_PH6 : std_logic_vector(2 downto 0) := "110";
  constant STARTUP_PH7 : std_logic_vector(2 downto 0) := "111";
  constant FRAME_RBT_OUT_FILENAME : string := "frame_data_s6_rbt_out.txt";

  signal GSR : std_ulogic := '1';
  signal GTS : std_ulogic := '1';
  signal GWE : std_ulogic := '0';
  signal cclk_in : std_ulogic;
  signal csi_b_in : std_ulogic;
  signal prog_b_in : std_ulogic;
  signal rdwr_b_in : std_ulogic;
  signal busy_o : std_ulogic := '0';
  signal busy_out : std_ulogic := '0';
  signal icap_clr: std_ulogic := '0';
  signal buswidth_tmp : std_logic_vector(1 downto 0) := "00";
  signal buswidth : std_logic_vector(1 downto 0);
  signal crc_err_flag_reg : std_ulogic := '0';
  signal crc_err_flag_tot : std_ulogic;
  signal mode_sample_flag : std_ulogic := '0';
  signal init_b_out : std_ulogic := '1';
  signal init_b_in : std_ulogic;
  signal done_o : std_ulogic := '0';
  signal done_in : std_ulogic ;
  signal por_b : std_ulogic := '0';
  signal prog_b_t : std_ulogic;
  signal m_in : std_logic_vector(1 downto 0);
  signal mode_pin_in : std_logic_vector(1 downto 0) := "00";
  signal d_in : std_logic_vector(15 downto 0) := "0000000000000000";
  signal d_out : std_logic_vector(15 downto 0) := "0000000000000000";
  signal prog_pulse_low_edge : time := 0 ps;
  signal prog_pulse_low : time := 0 ps;
  signal wr_cnt : integer := 0;
  signal conti_data_cnt : integer := 0;
  signal rd_data_cnt : integer := 0;
  signal abort_cnt : integer := 0;
  signal csbo_flag : std_ulogic := '0';
  signal pack_in_reg : std_logic_vector(15 downto 0) := X"0000";
  signal reg_addr : std_logic_vector(5 downto 0) := "000000";
  signal rd_reg_addr : std_logic_vector(5 downto 0) := "000000";
  signal  new_data_in_flag : std_ulogic := '0';
  signal wr_flag : std_ulogic := '0';
  signal rd_flag : std_ulogic := '0';
  signal cmd_wr_flag : std_ulogic := '0';
  signal cmd_rd_flag : std_ulogic := '0';
  signal bus_sync_flag : std_ulogic := '0';
  signal csi_sync : std_ulogic := '0';
  signal rd_sw_en : std_ulogic := '0';
  signal conti_data_flag : std_ulogic := '0';
  signal conti_data_flag_set : std_ulogic := '0';
  signal st_state :  std_logic_vector(2 downto 0) := STARTUP_PH0;
  signal nx_st_state :  std_logic_vector(2 downto 0) := STARTUP_PH0;
  signal startup_begin_flag : std_ulogic := '0';
  signal startup_end_flag : std_ulogic := '0';
  signal cmd_reg_new_flag : std_ulogic := '0';
  signal far_maj_min_flag : std_ulogic := '0';
  signal crc_reset : std_ulogic := '0';
  signal crc_rst : std_ulogic := '0';
  signal crc_ck : std_ulogic := '0';
  signal crc_err_flag : std_ulogic := '0';
  signal crc_en : std_ulogic := '0';
  signal desync_flag : std_ulogic := '0';
  signal desync_flag_tmp : std_ulogic := '0';
  signal icap_desynch : std_ulogic := '0';
  signal  crc_curr : std_logic_vector(21 downto 0) := "0000000000000000000000";
  signal gwe_out : std_ulogic := '0';
  signal gts_out : std_ulogic := '1';
  signal d_o : std_logic_vector(15 downto 0) := "0000000000000000";
  signal outbus : std_logic_vector(15 downto 0) := "0000000000000000";
  signal outbus1 : std_logic_vector(15 downto 0) := "0000000000000000";
  signal reboot_set : std_ulogic := '0';
  signal gsr_set : std_ulogic := '0';
  signal  gts_usr_b : std_ulogic := '1';
  signal done_pin_drv : std_ulogic := '0';
  signal crc_bypass : std_ulogic := '0';
  signal reset_on_err : std_ulogic := '0';
  signal sync_timeout : std_ulogic := '0';
  signal crc_reg : std_logic_vector (31 downto 0);
  signal idcode_reg : std_logic_vector (31 downto 0);
  signal idcode_reg1 : std_logic_vector (31 downto 0) := TO_STDLOGICVECTOR(DEVICE_ID);
  signal idcode_tmp : std_logic_vector (31 downto 0);
  signal far_min_reg : std_logic_vector (15 downto 0);
  signal far_maj_reg : std_logic_vector (15 downto 0);
  signal fdri_reg    : std_logic_vector (15 downto 0);
  signal fdro_reg    : std_logic_vector (15 downto 0);
  signal cwdt_reg    : std_logic_vector (15 downto 0);
  signal ctl_reg     : std_logic_vector (15 downto 0) := "0000000010000001";
  signal cmd_reg     : std_logic_vector (4 downto 0);
  signal general1_reg : std_logic_vector (15 downto 0);
  signal mask_reg    : std_logic_vector (15 downto 0) := "0000000000000000";
  signal lout_reg    : std_logic_vector (15 downto 0);
  signal cor1_reg    : std_logic_vector (15 downto 0) := "0X11011100000000";
  signal cor2_reg    : std_logic_vector (15 downto 0) := "0000100111101110";
  signal pwrdn_reg   : std_logic_vector (15 downto 0) := "X00010001000X001";
  signal flr_reg     : std_logic_vector (15 downto 0);
  signal snowplow_reg : std_logic_vector (15 downto 0);
  signal hc_opt_reg  : std_logic_vector (15 downto 0);
  signal csbo_reg    : std_logic_vector (15 downto 0);
  signal general2_reg : std_logic_vector (15 downto 0);
  signal general3_reg : std_logic_vector (15 downto 0);
  signal general4_reg : std_logic_vector (15 downto 0);
  signal general5_reg : std_logic_vector (15 downto 0);
  signal eye_mask_reg : std_logic_vector (15 downto 0);
  signal cbc_reg : std_logic_vector (15 downto 0);
  signal seu_reg : std_logic_vector (15 downto 0);
  signal bootsts_reg : std_logic_vector (15 downto 0);
  signal mode_reg    : std_logic_vector (15 downto 0);
  signal pu_gwe_reg  : std_logic_vector (15 downto 0);
  signal pu_gts_reg  : std_logic_vector (15 downto 0);
  signal mfwr_reg    : std_logic_vector (15 downto 0);
  signal cclk_freq_reg : std_logic_vector (15 downto 0);
  signal seu_opt_reg : std_logic_vector (15 downto 0);
  signal exp_sign_reg : std_logic_vector (31 downto 0);
  signal rdbk_sign_reg : std_logic_vector (31 downto 0);
  signal shutdown_set : std_ulogic := '0';
  signal desynch_set : std_ulogic := '0';
  signal done_cycle_reg : std_logic_vector (2 downto 0) := "100";
  signal gts_cycle_reg : std_logic_vector (2 downto 0) := "101";
  signal gwe_cycle_reg : std_logic_vector (2 downto 0) := "110";
  signal ghigh_b : std_ulogic := '0';
  signal eos_startup : std_ulogic := '0';
  signal startup_set : std_ulogic := '0';
  signal startup_set_pulse  : std_logic_vector (1 downto 0) := "00";
  signal abort_out_en : std_ulogic := '0';
  signal id_error_flag : std_ulogic := '0';
  signal iprog_b : std_ulogic := '1';
  signal abort_flag_wr : std_ulogic := '0';
  signal abort_flag_rd : std_ulogic := '0';
  signal abort_status : std_logic_vector (15 downto 0) := "0000000000000000";
  signal persist_en : std_ulogic := '0';
  signal rst_sync : std_ulogic := '0';
  signal init_rst : std_ulogic := '0';
  signal  abort_dis: std_ulogic := '0';
  signal lock_cycle_reg : std_logic_vector (2 downto 0) := "000";
  signal rbcrc_no_pin : std_ulogic := '0';
  signal abort_flag_rst : std_ulogic := '0';
  signal gsr_st_out : std_ulogic := '1';
  signal gsr_cmd_out : std_ulogic := '0';
  signal d_o_en : std_ulogic := '0';
  signal stat_reg : std_logic_vector (15 downto 0) := X"0000";
  signal rst_intl : std_ulogic := '0';
  signal rw_en : std_ulogic := '0';
  signal gsr_out : std_ulogic := '1';
  signal cfgerr_b_flag : std_ulogic  := '1';
  signal abort_flag : std_ulogic := '0';
  signal  downcont : std_logic_vector (27 downto 0)  := "0000000000000000000000000000";
  signal  downcont_int : integer := 0;
  signal type2_flag : std_ulogic := '0';
  signal rst_en : std_ulogic := '0';
  signal prog_b_a : std_ulogic := '1';
  signal csbo_b_out : std_ulogic := '1';
  signal pll_locked : std_ulogic;
  signal init_b_t : std_ulogic;
  signal d_out_en : std_ulogic := '0';
  signal device_id_reg : std_logic_vector (31 downto 0)  := TO_STDLOGICVECTOR(DEVICE_ID);
  signal icap_on : std_ulogic := '0';
  signal icap_bw : std_logic_vector (1 downto 0)  := "10";
  signal icap_init_done : std_ulogic := '0'; 
  file  f_fd : text;
  signal frame_data_wen : std_ulogic := '0';

begin

    BUSY <= busy_out;
    CSOB <= csbo_b_out;
    INITB <=  (not crc_err_flag_tot) when mode_sample_flag = '1' else init_b_out when init_b_out ='0' else 'H';
    DONE <= done_o;
    done_in <= DONE;
    init_b_in <= INITB;

    cclk_in <= CCLK;
    pll_locked <= '0' when unisim.VCOMPONENTS.PLL_LOCKG = '0' else '1';
    csi_b_in <= CSIB;
    d_in <= D;
    D <=  d_out when d_out_en = '1' else "ZZZZZZZZZZZZZZZZ";

    m_in <= M;
    prog_b_in <= PROGB;
    rdwr_b_in <= RDWRB;

    INIPROC : process
     variable open_status : file_open_status;
     variable read_ok : boolean := false;
    begin
          if (ICAP_SUPPORT = true) then
              icap_on <= '1';
          else
              icap_on <= '0';
          end if;

          if (DEVICE_ID = X"00000000" and ICAP_SUPPORT = false ) then
             assert FALSE report "Attribute Syntax Error : The attribute DEVICE_ID on  SIM_CONFIG_S6 is not set." severity error;
          end if;

     if (ICAP_SUPPORT  =  true) then

       file_open(open_status, f_fd, FRAME_RBT_OUT_FILENAME, write_mode);
       if (open_status = open_ok) then
            frame_data_wen <= '1';
       end if;
     else
        frame_data_wen <= '0';
     end if;

      wait;
    end process;

    GSR <= gsr_out;
    GTS <= gts_out;
    GWE <= gwe_out;
    busy_out <= busy_o;
    csbo_b_out <= '0' when (csbo_flag= '1') else '1';
    cfgerr_b_flag <= rw_en and (not id_error_flag) and (not crc_err_flag_reg);
    crc_err_flag_tot <= id_error_flag or crc_err_flag_reg;
    d_out <= abort_status when (abort_out_en = '1') else outbus1;
    d_out_en <= d_o_en;
    crc_en <=  '0' when (icap_init_done = '1') else '1';

   outbus1_p : process(outbus)
   begin
      outbus1(7 downto 0) <= bit_revers8(outbus(7 downto 0));
      outbus1(15 downto 8) <= bit_revers8(outbus(15 downto 8));
   end process;

    process (abort_out_en, csi_b_in, rdwr_b_in, rd_flag) begin
    if (abort_out_en='1') then
       d_o_en <= '1';
    else
       d_o_en <= rdwr_b_in and (not csi_b_in) and rd_flag;
    end if;
    end process;

    process  begin
        if (csi_b_in = '1' and  NOW > 0 ps) then
           busy_o <= '1';
        else
          if (abort_flag = '1') then
            busy_o <= '1';
          else 
--            wait until (rising_edge(cclk_in));
--            wait until (rising_edge(cclk_in));
            wait until (rising_edge(cclk_in));
            busy_o <= '0';
          end if;
        end if;
        wait on csi_b_in, abort_flag, cclk_in;
    end process;

    process  begin
      if (prog_b_in'event and prog_b_in = '0') then
         rst_en <= '0';
         wait for cfg_Tprog;
         wait for 1 ps;
         rst_en <= '1';
      end if;
      wait on prog_b_in;
    end process;

     init_b_t <= init_b_in;

  process (rst_en, init_rst, prog_b_in, iprog_b) begin
   if (init_rst = '1') then
       init_b_out <= '0';
   else
     if ((rst_en = '1' and prog_b_in  =  '0') or iprog_b = '0' ) then
         init_b_out <= '0';
     elsif ((rst_en = '1' and prog_b_in  =  '1') or iprog_b = '1') then
         init_b_out <= '1' after cfg_Tpl;
     end if;
   end if;
   end process;

  process  begin
    if (rst_en = '0') then
       prog_b_a <= '1';
    elsif (rising_edge(rst_en)) then
       if (prog_b_in = '1' and prog_pulse_low=cfg_Tprog) then
           prog_b_a <= '0';
           wait for 500 ps;
           prog_b_a <= '1';
       elsif (prog_b_in = '0') then
          prog_b_a <= '0';
          wait until (rising_edge(prog_b_in));
          prog_b_a <= '1';
       end if;
    end if;
   wait on rst_en, prog_b_in;
  end process;



  process
  begin
    por_b <= '0';
    por_b <=  '1' after 301 ns;
  wait;
  end process;

  prog_b_t <= prog_b_a  and iprog_b  and  por_b;

  rst_intl <=  '0' when (prog_b_t='0') else '1';

  process (init_b_t, prog_b_t)
    variable Message : line;
  begin
   if  (prog_b_t = '0') then
      mode_sample_flag <= '0';
   elsif ( init_b_t = '1' and mode_sample_flag = '0') then
        if(prog_b_t = '1') then
           mode_pin_in <= m_in;
           if (m_in /= "10") then
             mode_sample_flag <= '0';
             if (icap_on = '0') then
              Write ( Message, string'(" Error: input M is "));
              Write ( Message, string'(SLV_TO_STR(m_in)));
              Write ( Message, string'(" . Only Slave SelectMAP mode M=10 supported on SIM_CONFIG_S6."));
              assert false report Message.all severity error;
              DEALLOCATE (Message);
              end if;
             else
               mode_sample_flag <= '1' after 1 ps;
           end if;
         end if;
     end if;

     if ( rising_edge(init_b_t)) then
        if (prog_b_t /= '1' and NOW > 0 ps) then
            assert false report "Error: PROGB is not high when INITB goes high on SIM_CONFIG_S6." severity error;
       end if;
    end if;
  end process;

  process (m_in) begin
    if (mode_sample_flag = '1' and persist_en = '1' and icap_on = '0') then
       assert false report "Error : Mode pine M[1:0] changed after rising edge of INITB on SIM_CONFIG_S6." severity error;
    end if;
  end process;

  prog_pulse_P : process (prog_b_in)
     variable prog_pulse_low : time;
     variable Message : line;
  begin
    if (falling_edge (prog_b_in)) then
       prog_pulse_low_edge <= NOW;
    else
      if (NOW > 0 ps ) then
         prog_pulse_low := NOW - prog_pulse_low_edge;
         if (prog_pulse_low < cfg_Tprog  and icap_on = '0') then
             Write ( Message, string'(" Error: Low time of PROGB is less than required minimum Tprogram time "));
             Write ( Message, prog_pulse_low);
             Write ( Message, string'(" ."));
             assert false report Message.all severity error;
         end if;
      end if;
    end if;
  end process;


     rw_en <= '1' when ((mode_sample_flag = '1') and  (csi_b_in = '0')) else  '0';
     desync_flag <= (not rst_intl) or desynch_set or crc_err_flag or id_error_flag or icap_desynch;

     buswidth(1 downto 0) <= icap_bw(1 downto 0)  when (icap_on  =  '1'  and  icap_init_done  =  '1') else buswidth_tmp(1 downto 0);


    process  begin
     if (rising_edge(eos_startup )) then
      if (icap_on  =  '1') then
        file_close(f_fd);
        icap_init_done <= '1';
--        icap_clr <= '1';
        wait until (rising_edge(cclk_in));
        icap_desynch <= '1';
        wait until (rising_edge(cclk_in));
        wait until (rising_edge(cclk_in));
        icap_desynch <= '0';
        wait until (rising_edge(cclk_in));
        icap_clr <= '0';
      else  
        icap_clr <= '0';
        icap_init_done <= '0';
      end if;
    end if;
      wait on eos_startup, cclk_in;
    end process;

   process (cclk_in) begin
--   if (rising_edge(cclk_in)) then
   if (falling_edge(cclk_in)) then
       csi_sync <= csi_b_in;
     end if;
   end process;

   process (cclk_in, rdwr_b_in) begin
      if (rdwr_b_in = '0') then
           rd_sw_en <= '0';
      elsif (rising_edge(cclk_in)) then
           if (csi_sync = '1' and rdwr_b_in = '1') then
              rd_sw_en <= '1';
           end if;
      end if;
   end process;

    bus_sync_p : process (cclk_in, desync_flag, csi_b_in)
      variable tmp_byte  : std_logic_vector (7 downto 0);
      variable tmp_byte1  : std_logic_vector (7 downto 0);
      variable tmp_byte2  : std_logic_vector (7 downto 0);
      variable tmp_byte3  : std_logic_vector (7 downto 0);
      variable tmp_byte4  : std_logic_vector (7 downto 0);
      variable tmp_byte5  : std_logic_vector (7 downto 0);
      variable tmp_byte6  : std_logic_vector (7 downto 0);
      variable tmp_byte7  : std_logic_vector (7 downto 0);
      variable tmp_word  : std_logic_vector (15 downto 0);
      variable ctl_reg_tmp  : std_logic_vector (15 downto 0);
    begin
      if (desync_flag = '1') then
          pack_in_reg <= "0000000000000000";
          new_data_in_flag <= '0';
          bus_sync_flag <= '0';
          buswidth_tmp <= "00";
          wr_cnt <= 0;
          wr_flag <= '0';
          rd_flag <= '0';
      elsif (icap_init_done = '1' and  csi_b_in = '1' and rdwr_b_in = '0') then
          pack_in_reg <= X"0000";
          new_data_in_flag <= '0';
          wr_cnt <= 0;
      elsif (rising_edge(cclk_in)) then
       if (icap_clr  =  '1') then
          pack_in_reg <= "0000000000000000";
          new_data_in_flag <= '0';
          wr_cnt <= 0;
          wr_flag <= '0';
          rd_flag <= '0';
       elsif (rw_en  =  '1' ) then
         if (rdwr_b_in  =  '0') then
           wr_flag <= '1';
           rd_flag <= '0';
           if (bus_sync_flag  =  '0') then
              tmp_byte := bit_revers8(d_in(7 downto 0));
              tmp_byte1 := bit_revers8(d_in(15 downto 8));
              if (tmp_byte3  =  X"AA"  and  tmp_byte2  =  X"99"  and  
                      tmp_byte1 = X"55"  and  tmp_byte = X"66") then
                          bus_sync_flag <= '1';
                          new_data_in_flag <= '0';
                          buswidth_tmp <= "10";
                          wr_cnt <= 0;
              elsif (tmp_byte6  =  X"AA"  and  tmp_byte4  =  X"99"  and 
                      tmp_byte2  = X"55" and  tmp_byte = X"66") then 
                          bus_sync_flag <= '1';
                          new_data_in_flag <= '0';
                          buswidth_tmp <= "01";
                          wr_cnt <= 0;
              else 
                      tmp_byte7 := tmp_byte5;
                      tmp_byte6 := tmp_byte4;
                      tmp_byte5 := tmp_byte3;
                      tmp_byte4 := tmp_byte2;
                      tmp_byte3 := tmp_byte1;
                      tmp_byte2 := tmp_byte;
              end if;
           else 
             if (buswidth  =  "01") then
               tmp_byte := bit_revers8(d_in(7 downto 0));
               if (wr_cnt  =  0) then
                    pack_in_reg(15 downto 8) <= tmp_byte;
                     new_data_in_flag <= '0';
                     wr_cnt <=  1;
               elsif (wr_cnt  =  1) then
                     pack_in_reg(7 downto 0) <= tmp_byte;
                     new_data_in_flag <= '1';
                     wr_cnt <= 0;
               end if;
             elsif (buswidth  =  "10") then
                 tmp_word := (bit_revers8(d_in(15 downto 8)) & bit_revers8(d_in(7 downto 0)));
                 pack_in_reg(15 downto 0) <= tmp_word;
                 new_data_in_flag <= '1';
             end if;
         end if;
       else       
            wr_flag <= '0';
            new_data_in_flag <= '0';
            if (rd_sw_en  = '1') then
               rd_flag <= '1';
            end if;
       end if;
     else 
            wr_flag <= '0';
            rd_flag <= '0';
            new_data_in_flag <= '0';
     end if;
   end if;
   end process;
           
   pack_decode_p :  process (cclk_in, rst_intl)
      variable tmp_v : std_logic_vector(5 downto 0);
      variable tmp_v28 : std_logic_vector(27 downto 0);
      variable idcode_tmp : std_logic_vector(31 downto 0);
      variable message_line : line;
      variable csbo_cnt : integer := 0;
      variable crc_new : std_logic_vector(21 downto 0) := "0000000000000000000000";
      variable crc_input : std_logic_vector(21 downto 0) := "0000000000000000000000";
      variable ctl_reg_tmp : std_logic_vector(15 downto 0);
   begin
      if (rst_intl  =  '0') then
         conti_data_flag <= '0';
         conti_data_cnt <= 0;
         cmd_wr_flag <= '0';
         cmd_rd_flag <= '0';
         id_error_flag <= '0';
         far_maj_min_flag <= '0';
         cmd_reg_new_flag <= '0';
         crc_curr <= "0000000000000000000000";
         crc_ck <= '0';
         csbo_cnt := 0;
         csbo_flag <= '0';
         downcont <= "0000000000000000000000000000";
         downcont_int <= 0;
         rd_data_cnt <= 0;
      elsif (falling_edge(cclk_in)) then
        if (icap_clr  =  '1') then
         conti_data_flag <= '0';
         conti_data_cnt <= 0;
         cmd_wr_flag <= '0';
         cmd_rd_flag <= '0';
         id_error_flag <= '0';
         far_maj_min_flag <= '0';
         cmd_reg_new_flag <= '0';
         crc_ck <= '0';
         csbo_cnt := 0;
         csbo_flag <= '0';
         downcont <= "0000000000000000000000000000";
         downcont_int <= 0;
         rd_data_cnt <= 0;
        end if;

        if (crc_reset  =  '1' ) then
            crc_reg(31 downto 0) <= X"00000000";
            exp_sign_reg(31 downto 0) <= X"00000000";
            crc_ck <= '0';
            crc_curr(21 downto 0) <= "0000000000000000000000";
        end if;
        if (desynch_set = '1' or icap_desynch = '1' or  crc_err_flag = '1') then
           conti_data_flag <= '0';
           conti_data_cnt <= 0;
           cmd_wr_flag <= '0';
           cmd_rd_flag <= '0';
           far_maj_min_flag <= '0';
           cmd_reg_new_flag <= '0';
           crc_ck <= '0';
           csbo_cnt := 0;
           csbo_flag <= '0';
           downcont <= "0000000000000000000000000000";
           downcont_int <= 0;
           rd_data_cnt <= 0;
        end if;

        if (new_data_in_flag = '1'  and  wr_flag = '1') then
           if (conti_data_flag  =  '1' ) then
             if (type2_flag  =  '0') then
               case (reg_addr) is
               when "000000" =>  if (conti_data_cnt = 1) then
                             crc_reg(15 downto 0) <= pack_in_reg;
                             crc_ck <= '1';
                          elsif (conti_data_cnt = 2) then
                             crc_reg(31 downto 16) <= pack_in_reg;
                             crc_ck <= '0';
                          end if;
               when "000001" => if (conti_data_cnt = 2) then
                              far_maj_reg <= pack_in_reg;
                              far_maj_min_flag <= '1';
                           elsif (conti_data_cnt = 1) then
                               if (far_maj_min_flag  = '1') then
                                  far_min_reg <= pack_in_reg;
                                  far_maj_min_flag <= '0';
                               else
                                  far_maj_reg <= pack_in_reg;
                               end if;
                           end if;
               when "000010" => far_min_reg <= pack_in_reg;
               when "000011" => fdri_reg <= pack_in_reg;
               when "000101" => cmd_reg <= pack_in_reg(4 downto 0);
               when "000110" => 
                             ctl_reg_tmp := (pack_in_reg and (not mask_reg)) or (ctl_reg and mask_reg);
                             ctl_reg <= ("00000000" & ctl_reg_tmp(7 downto 0));
               when "000111" => mask_reg <= pack_in_reg;
               when "001001" => lout_reg <= pack_in_reg;
               when "001010" => cor1_reg <= pack_in_reg;
               when "001011" => cor2_reg <= pack_in_reg;
               when "001100" => pwrdn_reg <= pack_in_reg;
               when "001101" => flr_reg <= pack_in_reg;
               when "001110" => 
                          if (conti_data_cnt = 1) then
                             idcode_reg(15 downto 0) <= pack_in_reg;
                             idcode_tmp := (idcode_reg(31 downto 16) & pack_in_reg);
                             if (idcode_tmp(27 downto 0)  /=  device_id_reg(27 downto 0)) then
                                id_error_flag <= '1';
                                write(message_line, string'("Error : written value to IDCODE register "));
                                if (icap_on  =  '0') then
                                write(message_line, string'("of SIM_CONFIG_S6 is "));
                                else
                                write(message_line, string'("of X_ICAP_SPARTAN6 is "));
                                end if;
                                write(message_line, string'(SLV_TO_STR(idcode_tmp)));
                                write(message_line, string'(" which does not match DEVICE ID "));
                                write(message_line, string'(SLV_TO_STR(device_id_reg)));
                                write(message_line, string'("."));
                                assert false report message_line.all  severity error;
                                DEALLOCATE(message_line);
                             else
                                id_error_flag <= '0';
                             end if;
                          elsif (conti_data_cnt = 2) then
                             idcode_reg(31 downto 16) <= pack_in_reg;
                          end if;
                          
               when "001111" => cwdt_reg <= pack_in_reg;
               when "010000" => hc_opt_reg(6 downto 0) <= pack_in_reg(6 downto 0);
               when "010010" => csbo_reg <= pack_in_reg;
               when "010011" => general1_reg <= pack_in_reg;
               when "010100" => general2_reg <= pack_in_reg;
               when "010101" => general3_reg <= pack_in_reg;
               when "010110" => general4_reg <= pack_in_reg;
               when "010111" => general5_reg <= pack_in_reg;
               when "011000" => mode_reg <= pack_in_reg;
               when "011001" => pu_gwe_reg <= pack_in_reg;
               when "011010" => pu_gts_reg <= pack_in_reg;
               when "011011" => mfwr_reg <= pack_in_reg;
               when "011100" => cclk_freq_reg <= pack_in_reg;
               when "011101" => seu_opt_reg <= pack_in_reg;
               when "011110" => if (conti_data_cnt = 1) then
                            exp_sign_reg(15 downto 0) <= pack_in_reg;
                          elsif (conti_data_cnt = 2) then
                            exp_sign_reg(31 downto 16) <= pack_in_reg;
                          end if;
               when "011111" => if (conti_data_cnt = 1) then
                            rdbk_sign_reg(15 downto 0) <= pack_in_reg;
                          elsif (conti_data_cnt = 2) then
                            rdbk_sign_reg(31 downto 16) <= pack_in_reg;
                          end if;
               when "100001" => eye_mask_reg <= pack_in_reg;
               when "100010" => cbc_reg <= pack_in_reg;
               when others => NULL;
               end case;

             if (reg_addr  =  "000101") then
                 cmd_reg_new_flag <= '1';
             else
                 cmd_reg_new_flag <= '0';
             end if;

             if (crc_en  =  '1')  then
               if ((reg_addr  =  "000101") and  (pack_in_reg(4 downto 0)  =  "00111")) then

                   crc_curr(21 downto 0) <= "0000000000000000000000";
               else
                  if ((reg_addr /= "000100") and (reg_addr /= "001000") and (reg_addr /= "001001") and
                  (reg_addr /= "010010") and (reg_addr /= "011111") and
      (reg_addr  /= "100000") and (reg_addr /= "000000")) then
                     crc_input(21 downto 0) := (reg_addr(5 downto 0) & pack_in_reg);
                     crc_new(21 downto 0) := crc_next(crc_curr, crc_input);
                     crc_curr(21 downto 0) <= crc_new;
                     crc_curr(21 downto 0) <= crc_new;
                   end if;
               end if;
              end if;
             else    
                if (conti_data_cnt  = 2) then
                   downcont(27 downto 16) <= pack_in_reg(11 downto 0);
                elsif (conti_data_cnt  = 1) then
                   downcont(15 downto 0) <= pack_in_reg;
                   tmp_v28 := (downcont(27 downto 16) & pack_in_reg );
                   downcont_int <= SLV_TO_INT(tmp_v28);
                end if;
             end if;

             if (conti_data_cnt <= 1) then
                conti_data_cnt <= 0;
                type2_flag <= '0';
             else
                conti_data_cnt <= conti_data_cnt - 1;
             end if;
           else   
             if ( downcont_int >= 1) then
                   if (crc_en  =  '1') then
                     crc_input(21 downto 0) := ("000011" & pack_in_reg);  
                     crc_new(21 downto 0) := crc_next(crc_curr, crc_input);
                     crc_curr(21 downto 0) <= crc_new;
                   end if;

                   if (frame_data_wen  =  '1' and icap_init_done = '0' ) then
                     write(f_fd, ( SLV_TO_STR(pack_in_reg) &  LF));
                   end if;
             end if;

             if ((pack_in_reg(15 downto 13) = "010") and  (downcont_int  =  0)) then
                cmd_wr_flag <= '0';
                type2_flag <= '1';
                conti_data_flag <= '1';
                conti_data_cnt <= 2;
             elsif (pack_in_reg(15 downto 13) = "001")  then
                if ((pack_in_reg(12 downto 11) = "01") and  (downcont_int = 0))
then
                    if (pack_in_reg(4 downto 0) /= "00000") then
                       cmd_rd_flag <= '1';
                       cmd_wr_flag <= '0';
                       tmp_v := (pack_in_reg(4 downto 0) & '0');
                       rd_data_cnt <= 2;
                       conti_data_cnt <= 0;
                       conti_data_flag <= '0';
                       rd_reg_addr <= pack_in_reg(10 downto 5);
                    end if;
                elsif ((pack_in_reg(12 downto 11) = "10") and (downcont_int = 0)) then
                    if (pack_in_reg(15 downto 5)  =  "00110010010") then
                           csbo_reg <= pack_in_reg;
                           csbo_cnt := SLV_TO_INT(SLV=>pack_in_reg(4 downto 0));                           csbo_flag <= '1';
                           conti_data_flag <= '0';
                           reg_addr <= pack_in_reg(10 downto 5);
                           cmd_wr_flag <= '1';
                           conti_data_cnt <= 0;
                    else 
                      if (pack_in_reg(4 downto 0)  /=  "00000") then
                       cmd_wr_flag <= '1';
                       conti_data_flag <= '1';
                       conti_data_cnt <= SLV_TO_INT(SLV=>pack_in_reg(4 downto 0));
                       reg_addr <= pack_in_reg(10 downto 5);
                      else
                       cmd_wr_flag <= '1';
                       conti_data_flag <= '0';
                       conti_data_cnt <= 0;
                       reg_addr <= pack_in_reg(10 downto 5);
                      end if;
                    end if;
                else
                    cmd_wr_flag <= '0';
                    conti_data_flag <= '0';
                    conti_data_cnt <= 0;
                end if;
             end if;
             cmd_reg_new_flag <= '0';
             crc_ck <= '0';
          end if;   -- if (conti_data_flag  =  '0' )

         if (csbo_cnt /= 0 ) then
             if (csbo_flag = '1') then
              csbo_cnt := csbo_cnt - 1;
              end if;
          else
              csbo_flag <= '0';
         end if;


         if (conti_data_cnt  =  1) then
                conti_data_flag <= '0';
         end if;
      end if;

      if (crc_ck = '1' or  icap_init_done = '0') then
         crc_ck <= '0';
      end if;

      if (rw_en  = '1') then
         if (rd_data_cnt  =  1) then
            rd_data_cnt <= 0;
         elsif (rd_data_cnt = 0 and  rd_flag = '1') then
               cmd_rd_flag <= '0';
         elsif ((cmd_rd_flag = '1')  and  (rd_flag = '1')) then
             rd_data_cnt <= rd_data_cnt - 1;
         end if;

         if ((downcont_int >= 1) and (conti_data_flag  =  '0') and (new_data_in_flag = '1') and (wr_flag = '1')) then
              downcont_int <= downcont_int - 1;
         end if;
      end if;
    end if;
   end process;



   rd_back_p : process ( cclk_in, rst_intl) begin
    if (rst_intl  = '0') then
         outbus <= "0000000000000000";
    elsif (rising_edge(cclk_in)) then
        if (cmd_rd_flag  =  '1'  and  rdwr_b_in  =  '1' and  csi_b_in  =  '0') then
               case (rd_reg_addr) is
               when "000101" =>  if (buswidth  =  "01") then
                              outbus(15 downto 8) <= "00000000";
                              if (rd_data_cnt = 1) then
                                 outbus(7 downto 0) <= ("000" & cmd_reg(4 downto 0));
                              end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= ("00000000000" & cmd_reg(4 downto 0));
                              end if;
                           end if;
               when "000110" =>  if (buswidth  =  "01") then
                              outbus(15 downto 8) <= "00000000";
                              if (rd_data_cnt = 1) then
                                 outbus(7 downto 0) <= ctl_reg(7 downto 0);
                              end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= ("00000000" & ctl_reg(7 downto 0));
                              end if;
                           end if;
               when "000111" => if (buswidth  =  "01") then
                              outbus(15 downto 8) <= "00000000";
                              if (rd_data_cnt = 1) then
                                 outbus(7 downto 0) <= mask_reg(7 downto 0);
                              end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= ("00000000" & mask_reg(7 downto 0));
                              end if;
                           end if;
               when "001000" =>  if (buswidth  =  "01") then
                              outbus(15 downto 8) <= "00000000";
                              if (rd_data_cnt = 1)  then
                                outbus(7 downto 0) <= stat_reg(7 downto 0);
                             elsif (rd_data_cnt = 2) then
                                outbus(7 downto 0) <= stat_reg(15 downto 8);
                             elsif (rd_data_cnt = 3) then
                                outbus(7 downto 0) <= stat_reg(7 downto 0);
                             elsif (rd_data_cnt = 4) then
                                outbus(7 downto 0) <= stat_reg(15 downto 8);
                             end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= stat_reg(15 downto 0);
                              end if;
                           end if;
               when "001010" =>  if (buswidth  =  "01") then
                              outbus(15 downto 8) <= "00000000";
                              if (rd_data_cnt = 1) then
                                outbus(7 downto 0) <= cor1_reg(7 downto 0);
                             elsif (rd_data_cnt = 2) then
                                outbus(7 downto 0) <= cor1_reg(15 downto 8);
                             end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= cor1_reg(15 downto 0);
                              end if;
                           end if;
               when "001011" =>  if (buswidth  =  "01") then
                              outbus(15 downto 8) <= "00000000";
                              if (rd_data_cnt = 1) then
                                outbus(7 downto 0) <= cor2_reg(7 downto 0);
                             elsif (rd_data_cnt = 2) then
                                outbus(7 downto 0) <= cor2_reg(15 downto 8);
                             end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= cor2_reg(15 downto 0);
                              end if;
                           end if;
               when "001100" =>  if (buswidth  =  "01") then
                              outbus(15 downto 8) <= "00000000";
                              if (rd_data_cnt = 1) then
                                outbus(7 downto 0) <= pwrdn_reg(7 downto 0);
                             elsif (rd_data_cnt = 2) then
                                outbus(7 downto 0) <= pwrdn_reg(15 downto 8);
                             end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= pwrdn_reg(15 downto 0);
                              end if;
                           end if;
               when "001110" =>  if (buswidth  =  "01") then
                              outbus(15 downto 8) <= "00000000";
                              if (rd_data_cnt = 1) then
                                 outbus(7 downto 0) <= idcode_reg1(7 downto 0);
                              elsif (rd_data_cnt = 2) then
                                 outbus(7 downto 0) <= idcode_reg1(15 downto 8);
                              elsif (rd_data_cnt = 3) then
                                 outbus(7 downto 0) <= idcode_reg1(23 downto 16);
                              elsif (rd_data_cnt = 4) then
                                 outbus(7 downto 0) <= idcode_reg1(31 downto 24);
                              end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= idcode_reg1(15 downto 0);
                              elsif (rd_data_cnt = 2) then
                                 outbus <= idcode_reg1(31 downto 16);
                              end if;
                           end if;
               when "001111" =>  if (buswidth  =  "01") then
                              outbus(15 downto 8) <= "00000000";
                              if (rd_data_cnt = 1) then
                                 outbus(7 downto 0) <= cwdt_reg(7 downto 0);
                              elsif (rd_data_cnt = 2) then
                                 outbus(7 downto 0) <= cwdt_reg(15 downto 8);
                              end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= cwdt_reg(15 downto 0);
                              end if;
                           end if;
               when "010000" =>  if (buswidth  =  "01") then
                              outbus(15 downto 8) <= "00000000";
                              if (rd_data_cnt = 1) then
                                 outbus(7 downto 0) <= ("00" & hc_opt_reg(5 downto 0));
                              end if;
                            elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= ("0000000000" & hc_opt_reg(5 downto 0));
                              end if;
                           end if;
               when "010011" =>  if (buswidth  =  "01") then
                              outbus(15 downto 8) <= "00000000";
                              if (rd_data_cnt = 1) then
                                 outbus(7 downto 0) <= general1_reg(7 downto 0);
                              elsif (rd_data_cnt = 2) then
                                 outbus(7 downto 0) <= general1_reg(15 downto 8);
                              end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= general1_reg;
                              end if;
                           end if;
               when "010100" =>  if (buswidth  =  "01") then
                              outbus(15 downto 8) <= "00000000";
                              if (rd_data_cnt = 1) then
                                 outbus(7 downto 0) <= general2_reg(7 downto 0);
                              elsif (rd_data_cnt = 2) then
                                 outbus(7 downto 0) <= general2_reg(15 downto 8);
                              end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= general2_reg;
                              end if;
                           end if;
               when "010101" =>  if (buswidth  =  "01") then
                              outbus(15 downto 8) <= "00000000";
                              if (rd_data_cnt = 1) then
                                 outbus(7 downto 0) <= general3_reg(7 downto 0);
                              elsif (rd_data_cnt = 2) then
                                 outbus(7 downto 0) <= general3_reg(15 downto 8);
                              end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= general3_reg;
                              end if;
                           end if;
               when "010110" => if (buswidth  =  "01") then
                              outbus(15 downto 8) <= "00000000";
                              if (rd_data_cnt = 1) then
                                 outbus(7 downto 0) <= general4_reg(7 downto 0);
                              elsif (rd_data_cnt = 2) then
                                 outbus(7 downto 0) <= general4_reg(15 downto 8);
                              end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= general4_reg;
                              end if;
                           end if;
               when "010111"=>  if (buswidth  =  "01") then
                              outbus(15 downto 8) <= "00000000";
                              if (rd_data_cnt = 1) then
                                 outbus(7 downto 0) <= general5_reg(7 downto 0);
                              elsif (rd_data_cnt = 2) then
                                 outbus(7 downto 0) <= general5_reg(15 downto 8);
                              end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= general5_reg;
                              end if;
                           end if;
               when "011000" =>  if (buswidth  =  "01") then
                              outbus(15 downto 8) <= "00000000";
                              if (rd_data_cnt = 1) then
                                 outbus(7 downto 0) <= mode_reg(7 downto 0);
                              elsif (rd_data_cnt = 2) then
                                 outbus(7 downto 0) <= mode_reg(15 downto 8);
                              end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= mode_reg;
                              end if;
                           end if;
               when "011101" =>  if (buswidth  =  "01") then
                              outbus(15 downto 8) <= "00000000";
                              if (rd_data_cnt = 1) then
                                 outbus(7 downto 0) <= seu_reg(7 downto 0);
                              elsif (rd_data_cnt = 2) then
                                 outbus(7 downto 0) <= seu_reg(15 downto 8);
                              end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= seu_reg;
                              end if;
                           end if;
               when "011110" =>  if (buswidth  =  "01") then
                             outbus(15 downto 8) <= "00000000";
                             if (rd_data_cnt = 1) then
                                outbus(7 downto 0) <= exp_sign_reg(7 downto 0);
                             elsif (rd_data_cnt = 2) then
                                outbus(7 downto 0) <= exp_sign_reg(15 downto 8);
                             elsif (rd_data_cnt = 3) then
                                outbus(7 downto 0) <= exp_sign_reg(23 downto 16);
                             elsif (rd_data_cnt = 4) then
                                outbus(7 downto 0) <= exp_sign_reg(31 downto 24);
                            end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= exp_sign_reg(15 downto 0);
                              elsif (rd_data_cnt = 2) then
                                 outbus <= exp_sign_reg(31 downto 16);
                              end if;
                           end if;
               when "011111" =>  if (buswidth  =  "01") then
                             outbus(15 downto 8) <= "00000000";
                             if (rd_data_cnt = 1) then
                                outbus(7 downto 0) <= rdbk_sign_reg(7 downto 0);
                             elsif (rd_data_cnt = 2) then
                                outbus(7 downto 0) <= rdbk_sign_reg(15 downto 8);
                             elsif (rd_data_cnt = 3) then
                                outbus(7 downto 0) <= rdbk_sign_reg(23 downto 16);
                             elsif (rd_data_cnt = 4) then
                                outbus(7 downto 0) <= rdbk_sign_reg(31 downto 24);
                            end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= rdbk_sign_reg(15 downto 0);
                              elsif (rd_data_cnt = 2) then
                                 outbus <= rdbk_sign_reg(31 downto 16);
                              end if;
                           end if;
                when "100000" =>  if (buswidth  =  "01") then
                             outbus(15 downto 8) <= "00000000";
                             if (rd_data_cnt = 1) then
                                outbus(7 downto 0) <= bootsts_reg(7 downto 0);
                             elsif (rd_data_cnt = 2) then
                                outbus(7 downto 0) <= bootsts_reg(15 downto 8);
                             end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= bootsts_reg;
                              end if;
                           end if;
                when "100001" =>  if (buswidth  =  "01") then
                             outbus(15 downto 8) <= "00000000";
                             if (rd_data_cnt = 1) then
                                outbus(7 downto 0) <= eye_mask_reg(7 downto 0);
                              end if;
                           elsif (buswidth  =  "10") then
                              if (rd_data_cnt = 1) then
                                 outbus <= ("00000000" & eye_mask_reg(7 downto 0));
                              end if;
                           end if;
                 when others => NULL;
               end case;
       else
             outbus <= "0000000000000000";
       end if;
   end if;
   end process;

        

     crc_rst <= crc_reset  or   (not rst_intl);

    process ( cclk_in,  crc_rst ) begin
     if (crc_rst = '1') then
         crc_err_flag <= '0';
     elsif (rising_edge(cclk_in)) then
        if (crc_ck = '1') then
          if (crc_bypass = '1') then
             if (crc_reg(31 downto 0)  /=  X"9876defc") then
                 crc_err_flag <= '1';
             else
                 crc_err_flag <= '0';
             end if;
          else 
            if (crc_curr(21 downto 0)  /=  crc_reg(21 downto 0))  then
                crc_err_flag <= '1';
            else
                 crc_err_flag <= '0';
            end if;
         end if;
       else
           crc_err_flag <= '0';
       end if;
     end if;
    end process;

    process ( crc_err_flag,  rst_intl,  bus_sync_flag) begin
     if (rst_intl  =  '0') then
         crc_err_flag_reg <= '0';
     elsif (rising_edge(crc_err_flag)) then
         crc_err_flag_reg <= '1';
     elsif (rising_edge(bus_sync_flag)) then
         crc_err_flag_reg <= '0';
     end if;
    end process;

    process ( cclk_in,  rst_intl) begin
    if (rst_intl  = '0') then
         startup_set <= '0';
         crc_reset  <= '0';
         gsr_set <= '0';
         shutdown_set <= '0';
         desynch_set <= '0';
         reboot_set <= '0';
         ghigh_b <= '0';
    elsif (rising_edge(cclk_in)) then
      if (cmd_reg_new_flag  = '1') then
         if (cmd_reg  =  "00011") then
             ghigh_b <= '1';
         elsif (cmd_reg  =  "01000") then
             ghigh_b <= '0';
         end if;
         if (cmd_reg  =  "00101") then
             startup_set <= '1';
         end if;
         if (cmd_reg  =  "00111") then
              crc_reset <= '1';
         end if;
         if (cmd_reg  =  "01010") then
              gsr_set <= '1';
         end if;
         if (cmd_reg  =  "01011") then
              shutdown_set <= '1';
         end if;
         if (cmd_reg  =  "01101") then
              desynch_set <= '1';
         end if;
         if (cmd_reg  =  "01110") then
             reboot_set <= '1';
         end if;
      else
             startup_set <= '0';
              crc_reset <= '0';
              gsr_set <= '0';
              shutdown_set <= '0';
              desynch_set <= '0';
             reboot_set <= '0';
      end if;
    end if;
    end process;


   startup_set_pulse_p : process  begin
    if (rw_en  =  '1') then
    if (rising_edge(startup_set)) then
      if (startup_set_pulse  =  "00") then
         if (icap_on = '0') then
            startup_set_pulse <= "01";
         else
            startup_set_pulse <= "11";
            wait until (rising_edge(cclk_in ));
            startup_set_pulse <= "00";
         end if;
      end if;
    elsif (rising_edge(desynch_set)) then
      if (startup_set_pulse  =  "01") then
          startup_set_pulse <= "11";
          wait until (rising_edge(cclk_in ));
          startup_set_pulse <= "00";
      end if;
     end if;
    end if;
      wait on startup_set, desynch_set, rw_en;
    end process;

    process (ctl_reg) begin
      if (ctl_reg(3)  =  '1') then
         persist_en <= '1';
      else
         persist_en <= '0';
      end if;

      if (ctl_reg(0)  =  '1') then
         gts_usr_b <= '1';
      else
         gts_usr_b <= '0';
      end if;
    end process;

    process (cor1_reg) begin
      if (cor1_reg(2)  = '1') then
         done_pin_drv <= '1';
      else
         done_pin_drv <= '0';
      end if;

      if (cor1_reg(4)  =  '1') then
         crc_bypass <= '1';
      else
         crc_bypass <= '0';
      end if;
    end process;

    process (cor2_reg) begin
      if (cor2_reg(15)  = '1') then
        reset_on_err <= '1';
      else
        reset_on_err <= '0';
      end if;

      done_cycle_reg <= cor2_reg(11 downto 9);
      lock_cycle_reg <= cor2_reg(8 downto 6);
      gts_cycle_reg <= cor2_reg(5 downto 3);
      gwe_cycle_reg <= cor2_reg(2 downto 0);
    end process;

     stat_reg(15) <= sync_timeout;
     stat_reg(14) <= '0';
     stat_reg(13) <= DONE;
     stat_reg(12) <= INITB;
     stat_reg(11 downto 9) <= ('0' & mode_pin_in);
     stat_reg(5) <= ghigh_b;
     stat_reg(4) <= gwe_out;
     stat_reg(3) <= gts_out;
     stat_reg(2) <= 'X';
     stat_reg(1) <= id_error_flag;
     stat_reg(0) <= crc_err_flag_reg;

    st_state_p : process ( cclk_in, rst_intl) begin
      if (rst_intl  =  '0') then
        st_state <= STARTUP_PH0;
        startup_begin_flag <= '0';
        startup_end_flag <= '0';
      elsif (rising_edge(cclk_in)) then
           if (nx_st_state  =  STARTUP_PH1) then
              startup_begin_flag <= '1';
              startup_end_flag <= '0';
           elsif (st_state  =  STARTUP_PH7) then
              startup_end_flag <= '1';
              startup_begin_flag <= '0';
           end if;
           if  ((lock_cycle_reg = "111") or (pll_locked  =  '1') or (st_state /= lock_cycle_reg and pll_locked  =  '0')) then
                st_state <= nx_st_state;
           else
              st_state <= st_state;
           end if;
      end if;
    end process;

    nx_st_state_p : process (st_state, startup_set_pulse, done_in ) begin
    if ((( st_state  =  done_cycle_reg) and (done_in /= '0')) or ( st_state /= done_cycle_reg)) then
      case (st_state) is
      when STARTUP_PH0  =>      if (startup_set_pulse  =  "11" ) then
                                     nx_st_state <= STARTUP_PH1;
                                else
                                     nx_st_state <= STARTUP_PH0;
                                end if;
      when STARTUP_PH1  =>      nx_st_state <= STARTUP_PH2;

      when STARTUP_PH2  =>      nx_st_state <= STARTUP_PH3;

      when STARTUP_PH3  =>      nx_st_state <= STARTUP_PH4;

      when STARTUP_PH4  =>      nx_st_state <= STARTUP_PH5;

      when STARTUP_PH5  =>      nx_st_state <= STARTUP_PH6;

      when STARTUP_PH6  =>      nx_st_state <= STARTUP_PH7;

      when STARTUP_PH7  =>      nx_st_state <= STARTUP_PH0;

      when others => NULL;
      end case;
   end if;
   end process;

    start_out_p : process ( cclk_in, rst_intl ) begin
      if (rst_intl  =  '0') then
          gwe_out <= '0';
          gts_out <= '1';
          eos_startup <= '0';
          gsr_st_out <= '1';
          done_o <= '0';
      elsif (rising_edge(cclk_in)) then
         if (nx_st_state  =  done_cycle_reg) then
            if (done_in  /=  '0' or done_pin_drv = '1') then
               done_o <= '1';
            else
               done_o <= 'H';
            end if;
         end if;

         if (nx_st_state  =  gwe_cycle_reg ) then
             gwe_out <= '1';
         end if;

         if (nx_st_state  =  gts_cycle_reg ) then
             gts_out <= '0';
         end if;


         if (nx_st_state  =  STARTUP_PH6 ) then
             gsr_st_out <= '0';
         end if;

         if (nx_st_state  =  STARTUP_PH7 ) then
            eos_startup <= '1';
         end if;

      end if;
    end process;


    gsr_out <= gsr_st_out or gsr_cmd_out;


    process (rdwr_b_in, rst_intl, abort_flag_rst, csi_b_in)
    begin
      if (rst_intl = '0'  or  abort_flag_rst = '1'  or  csi_b_in  =  '1') then
        abort_flag_wr <= '0';
      elsif (rising_edge(rdwr_b_in)) then
        if (abort_dis  =  '0'  and  csi_b_in  =  '0') then
          if (NOW  /=  0 ps) then
            abort_flag_wr <= '1';
            if (icap_on = '0') then
              assert false report " Warning : RDWRB changes when CS_B low, which causes Configuration abort on SIM_CONFIG_S6."
                severity warning;
            end if; 
          end if;
        else
          abort_flag_wr <= '0';
        end if;
      end if;
    end process;


    process (rdwr_b_in, rst_intl, abort_flag_rst, csi_b_in)
    begin
      if (rst_intl = '0' or csi_b_in = '1' or abort_flag_rst = '1') then
        abort_flag_rd <= '0';
      elsif (falling_edge(rdwr_b_in)) then
        if (abort_dis = '0' and csi_b_in = '0') then
         if (NOW  /=  0 ps) then
          abort_flag_rd <= '1';
          if (icap_on = '0') then
          assert false report " Warning :  RDWRB changes when CS_B low, which causes Configuration abort on SIM_CONFIG_S6."
          severity warning;
          end if;
         end if;
       else
         abort_flag_rd <= '0';
       end if;
     end if;
    end process;

     abort_flag <= abort_flag_wr or abort_flag_rd;

    process ( cclk_in,  rst_intl) begin
      if (rst_intl  =  '0') then
         abort_cnt <= 0;
         abort_out_en <= '0';
      elsif (rising_edge(cclk_in)) then
         if ( abort_flag  = '1' ) then
             if (abort_cnt < 4) then
                 abort_cnt <= abort_cnt + 1;
                 abort_out_en <= '1';
             else
                abort_flag_rst <= '1';
             end if;
         else
                abort_cnt <=  0;
                abort_out_en <= '0';
                abort_flag_rst <= '0';
         end if;


         if (abort_cnt =  0) then
            abort_status <= ("11111111111110" & bus_sync_flag & cfgerr_b_flag);
         elsif (abort_cnt =  1) then
            abort_status <= ("111111111111001" & cfgerr_b_flag);
         elsif (abort_cnt =  2) then
            abort_status <= ("111111111111000" & cfgerr_b_flag);
         elsif (abort_cnt =  3) then
            abort_status <= ("111111111111100" & cfgerr_b_flag);
         end if;
      end if;
    end process;

end SIM_CONFIG_S6_V;

