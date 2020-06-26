------------------------------------------------------------------------------
-- Copyright (c) 1995/2005 Xilinx, Inc.
-- All Right Reserved.
------------------------------------------------------------------------------/
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Function Simulation Library Component
--  /   /                  Configuration Simulation Model
-- /___/   /\     Filename : SIM_CONFIGE2.vhd
-- \   \  /  \    Timestamp : 
--  \___\/\___\
--
-- Revision:
--    04/30/10 - Initial version.
--    10/27/10 - Add PROGB_GLBL global signal. (CR573665)
--    03/04/11 - Remove extra line in rdbk_2wd (CR595750)
--    03/14/11 - Make crc_ck 1 cycle long (CR599232)
--    03/17/11 - Handle CSB toggle (CR601925)
--    03/24/11 - Add cbi_b_ins to sync to negedge clock(CR603092)
--    05/03/11 - delay outbus 1 cycle (CR605404)
--    05/20/11 - initial done_cycle_reg (CR611383)
--    07/01/11 - Generate startup_set_pulse when rw_en=1 (595934)
--    02/21/13 - Updated output latency to 3 clock cycles (CR 701426).
-- End Revision
--------------------------------------------------------------------------------

----- CELL SIM_CONFIGE2  -----
library IEEE;
use IEEE.std_logic_1164.all;


library STD;
use STD.TEXTIO.all;
library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity SIM_CONFIGE2 is
  generic (
    DEVICE_ID : bit_vector := X"00000000";
    ICAP_SUPPORT : boolean := false;
    ICAP_WIDTH : string := "X8"
    );
  port (
    CSOB : out std_ulogic := '1';
    DONE : inout std_ulogic := '0';
    CCLK : in  std_ulogic := '0';
    CSB : in  std_ulogic := '0';
    D : inout std_logic_vector(31 downto 0);
    INITB : inout std_ulogic := 'H';
    M : in  std_logic_vector(2 downto 0) := "000";
    PROGB : in  std_ulogic := '0';
    RDWRB : in  std_ulogic := '0'
    );


end SIM_CONFIGE2;

architecture SIM_CONFIGE2_V of SIM_CONFIGE2 is

function  crc_next (
   crc_currf : in std_logic_vector(31 downto 0);
   crc_inputf : in std_logic_vector(36 downto 0)
 ) return  std_logic_vector
   is
      variable x : std_logic_vector(31 downto 0);
      variable m : std_logic_vector(36 downto 0);
      variable bcc_next : std_logic_vector(31 downto 0);
  begin
 m := crc_inputf;
 x := crc_inputf(31 downto 0)  xor  crc_currf(31 downto 0);
 bcc_next(31) := m(32) xor m(36) xor x(31) xor x(30) xor x(29) xor x(28) xor x(27) xor x(24) xor x(20) xor x(19) xor x(18) xor x(15) xor x(13) xor x(11) xor x(10) xor x(9) xor x(8) xor x(6) xor x(5) xor x(1) xor x(0);

 bcc_next(30) := m(35) xor x(31) xor x(30) xor x(29) xor x(28) xor x(27) xor x(26) xor x(23) xor x(19) xor x(18) xor x(17) xor x(14) xor x(12) xor x(10) xor x(9) xor x(8) xor x(7) xor x(5) xor x(4) xor x(0);

 bcc_next(29) := m(34) xor x(30) xor x(29) xor x(28) xor x(27) xor x(26) xor x(25) xor x(22) xor x(18) xor x(17) xor x(16) xor x(13) xor x(11) xor x(9) xor x(8) xor x(7) xor x(6) xor x(4) xor x(3);

 bcc_next(28) := m(33) xor x(29) xor x(28) xor x(27) xor x(26) xor x(25) xor x(24) xor x(21) xor x(17) xor x(16) xor x(15) xor x(12) xor x(10) xor x(8) xor x(7) xor x(6) xor x(5) xor x(3) xor x(2);

 bcc_next(27) := m(32) xor x(28) xor x(27) xor x(26) xor x(25) xor x(24) xor x(23) xor x(20) xor x(16) xor x(15) xor x(14) xor x(11) xor x(9) xor x(7) xor x(6)
xor x(5) xor x(4) xor x(2) xor x(1);

 bcc_next(26) := x(31) xor x(27) xor x(26) xor x(25) xor x(24) xor x(23) xor x(22) xor x(19) xor x(15) xor x(14) xor x(13) xor x(10) xor x(8) xor x(6) xor x(5)
xor x(4) xor x(3) xor x(1) xor x(0);

 bcc_next(25) := m(32) xor m(36) xor x(31) xor x(29) xor x(28) xor x(27) xor x(26) xor x(25) xor x(23) xor x(22) xor x(21) xor x(20) xor x(19) xor x(15) xor x(14) xor x(12) xor x(11) xor x(10) xor x(8) xor x(7) xor x(6) xor x(4) xor x(3) xor x(2) xor x(1);

 bcc_next(24) := m(35) xor x(31) xor x(30) xor x(28) xor x(27) xor x(26) xor x(25) xor x(24) xor x(22) xor x(21) xor x(20) xor x(19) xor x(18) xor x(14) xor x(13) xor x(11) xor x(10) xor x(9) xor x(7) xor x(6) xor x(5) xor x(3) xor x(2) xor x(1) xor x(0);

 bcc_next(23) := m(32) xor m(34) xor m(36) xor x(31) xor x(28) xor x(26) xor x(25) xor x(23) xor x(21) xor x(17) xor x(15) xor x(12) xor x(11) xor x(4) xor x(2);

 bcc_next(22) := m(32) xor m(33) xor m(35) xor m(36) xor x(29) xor x(28) xor x(25) xor x(22) xor x(19) xor x(18) xor x(16) xor x(15) xor x(14) xor x(13) xor x(9) xor x(8) xor x(6) xor x(5) xor x(3) xor x(0);

 bcc_next(21) := m(34) xor m(35) xor m(36) xor x(30) xor x(29) xor x(21) xor x(20) xor x(19) xor x(17) xor x(14) xor x(12) xor x(11) xor x(10) xor x(9) xor x(7) xor x(6) xor x(4) xor x(2) xor x(1) xor x(0);

 bcc_next(20) := m(32) xor m(33) xor m(34) xor m(35) xor m(36) xor x(31) xor x(30) xor x(27) xor x(24) xor x(16) xor x(15) xor x(3);

 bcc_next(19) := m(32) xor m(33) xor m(34) xor m(35) xor x(31) xor x(30) xor x(29) xor x(26) xor x(23) xor x(15) xor x(14) xor x(2);

 bcc_next(18) := m(33) xor m(34) xor m(36) xor x(27) xor x(25) xor x(24) xor x(22) xor x(20) xor x(19) xor x(18) xor x(15) xor x(14) xor x(11) xor x(10) xor x(9) xor x(8) xor x(6) xor x(5) xor x(0);

 bcc_next(17) := m(33) xor m(35) xor m(36) xor x(31) xor x(30) xor x(29) xor x(28) xor x(27) xor x(26) xor x(23) xor x(21) xor x(20) xor x(17) xor x(15) xor x(14) xor x(11) xor x(7) xor x(6) xor x(4) xor x(1) xor x(0);

 bcc_next(16) := m(32) xor m(34) xor m(35) xor x(30) xor x(29) xor x(28) xor x(27) xor x(26) xor x(25) xor x(22) xor x(20) xor x(19) xor x(16) xor x(14) xor x(13) xor x(10) xor x(6) xor x(5) xor x(3) xor x(0);

 bcc_next(15) := m(33) xor m(34) xor x(31) xor x(29) xor x(28) xor x(27) xor x(26) xor x(25) xor x(24) xor x(21) xor x(19) xor x(18) xor x(15) xor x(13) xor x(12) xor x(9) xor x(5) xor x(4) xor x(2);

 bcc_next(14) := m(32) xor m(33) xor x(30) xor x(28) xor x(27) xor x(26) xor x(25) xor x(24) xor x(23) xor x(20) xor x(18) xor x(17) xor x(14) xor x(12) xor x(11) xor x(8) xor x(4) xor x(3) xor x(1);

 bcc_next(13) := m(36) xor x(30) xor x(28) xor x(26) xor x(25) xor x(23) xor x(22) xor x(20) xor x(18) xor x(17) xor x(16) xor x(15) xor x(9) xor x(8) xor x(7)
xor x(6) xor x(5) xor x(3) xor x(2) xor x(1);

 bcc_next(12) := m(32) xor m(35) xor m(36) xor x(31) xor x(30) xor x(28) xor x(25) xor x(22) xor x(21) xor x(20) xor x(18) xor x(17) xor x(16) xor x(14) xor x(13) xor x(11) xor x(10) xor x(9) xor x(7) xor x(4) xor x(2);

 bcc_next(11) := m(32) xor m(34) xor m(35) xor m(36) xor x(28) xor x(21) xor x(18) xor x(17) xor x(16) xor x(12) xor x(11) xor x(5) xor x(3) xor x(0);

 bcc_next(10) := m(33) xor m(34) xor m(35) xor x(31) xor x(27) xor x(20) xor x(17) xor x(16) xor x(15) xor x(11) xor x(10) xor x(4) xor x(2);

 bcc_next(9) := m(33) xor m(34) xor m(36) xor x(31) xor x(29) xor x(28) xor x(27) xor x(26) xor x(24) xor x(20) xor x(18) xor x(16) xor x(14) xor x(13) xor x(11) xor x(8) xor x(6) xor x(5) xor x(3) xor x(0);

 bcc_next(8) := m(33) xor m(35) xor m(36) xor x(31) xor x(29) xor x(26) xor x(25) xor x(24) xor x(23) xor x(20) xor x(18) xor x(17) xor x(12) xor x(11) xor x(9) xor x(8) xor x(7) xor x(6) xor x(4) xor x(2) xor x(1) xor x(0);

 bcc_next(7) := m(32) xor m(34) xor m(35) xor x(30) xor x(28) xor x(25) xor x(24) xor x(23) xor x(22) xor x(19) xor x(17) xor x(16) xor x(11) xor x(10) xor x(8) xor x(7) xor x(6) xor x(5) xor x(3) xor x(1) xor x(0);

 bcc_next(6) := m(32) xor m(33) xor m(34) xor m(36) xor x(30) xor x(28) xor x(23) xor x(22) xor x(21) xor x(20) xor x(19) xor x(16) xor x(13) xor x(11) xor x(8) xor x(7) xor x(4) xor x(2) xor x(1);

 bcc_next(5) := m(33) xor m(35) xor m(36) xor x(30) xor x(28) xor x(24) xor x(22) xor x(21) xor x(13) xor x(12) xor x(11) xor x(9) xor x(8) xor x(7) xor x(5) xor x(3);

 bcc_next(4) := m(34) xor m(35) xor m(36) xor x(31) xor x(30) xor x(28) xor x(24) xor x(23) xor x(21) xor x(19) xor x(18) xor x(15) xor x(13) xor x(12) xor x(9) xor x(7) xor x(5) xor x(4) xor x(2) xor x(1) xor x(0);

 bcc_next(3) := m(32) xor m(33) xor m(34) xor m(35) xor m(36) xor x(31) xor x(28) xor x(24) xor x(23) xor x(22) xor x(19) xor x(17) xor x(15) xor x(14) xor x(13) xor x(12) xor x(10) xor x(9) xor x(5) xor x(4) xor x(3);

 bcc_next(2) := m(32) xor m(33) xor m(34) xor m(35) xor x(31) xor x(30) xor x(27) xor x(23) xor x(22) xor x(21) xor x(18) xor x(16) xor x(14) xor x(13) xor x(12) xor x(11) xor x(9) xor x(8) xor x(4) xor x(3) xor x(2);

 bcc_next(1) := m(32) xor m(33) xor m(34) xor x(31) xor x(30) xor x(29) xor x(26) xor x(22) xor x(21) xor x(20) xor x(17) xor x(15) xor x(13) xor x(12) xor x(11) xor x(10) xor x(8) xor x(7) xor x(3) xor x(2) xor x(1);

 bcc_next(0) := m(32) xor m(33) xor x(31) xor x(30) xor x(29) xor x(28) xor x(25) xor x(21) xor x(20) xor x(19) xor x(16) xor x(14) xor x(12) xor x(11) xor x(10) xor x(9) xor x(7) xor x(6) xor x(2) xor x(1) xor x(0);

 return bcc_next;

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

  procedure  rdbk_byte (rdbk_reg : in std_logic_vector(31 downto 0);
                        rd_data_cnt : in integer;
                        outbus : out std_logic_vector(31 downto 0))
  is
  begin
    outbus(31 downto 8) := X"000000";
   if (rd_data_cnt = 1) then
      outbus(7 downto 0) := bit_revers8(rdbk_reg(7 downto 0));
   elsif (rd_data_cnt = 2) then
      outbus(7 downto 0) := bit_revers8(rdbk_reg(15 downto 8));
   elsif (rd_data_cnt = 3) then
      outbus(7 downto 0) := bit_revers8(rdbk_reg(23 downto 16));
   elsif (rd_data_cnt = 4) then
      outbus(7 downto 0) := bit_revers8(rdbk_reg(31 downto 24));
   end if;
  end procedure rdbk_byte;

  procedure  rdbk_wd (rdbk_reg : in std_logic_vector(31 downto 0);
                      rd_data_cnt : in integer;
                      outbus : out std_logic_vector(31 downto 0))

  is
  begin
     outbus(31 downto 16) := X"0000";
     if (rd_data_cnt = 1) then
         outbus(15 downto 0) := X"0000";
     elsif (rd_data_cnt = 2) then
         outbus(15 downto 0) := X"0000";
     elsif (rd_data_cnt = 3) then
         outbus(7 downto 0) := bit_revers8(rdbk_reg(7 downto 0));
         outbus(15 downto 8) := bit_revers8(rdbk_reg(15 downto 8));
     elsif (rd_data_cnt = 4) then
         outbus(7 downto 0) := bit_revers8(rdbk_reg(23 downto 16));
         outbus(15 downto 8) := bit_revers8(rdbk_reg(31 downto 24));
     end if;
  end procedure rdbk_wd;
    
  procedure  rdbk_2wd (rdbk_reg : in std_logic_vector(31 downto 0);
                      rd_data_cnt : in integer;
                      outbus : out std_logic_vector(31 downto 0))

  is
  begin
     if (rd_data_cnt = 1) then
         outbus := X"00000000";
     elsif (rd_data_cnt = 2) then
         outbus := X"00000000";
     elsif (rd_data_cnt = 3) then
         outbus := X"00000000";
     elsif (rd_data_cnt = 4) then
         outbus(7 downto 0) := bit_revers8(rdbk_reg(7 downto 0));
         outbus(15 downto 8) := bit_revers8(rdbk_reg(15 downto 8));
         outbus(23 downto 16) := bit_revers8(rdbk_reg(23 downto 16));
         outbus(31 downto 24) := bit_revers8(rdbk_reg(31 downto 24));
     end if;
  end procedure rdbk_2wd;

  constant cfg_Tprog : time := 250000 ps;   -- min PROG must be low
  constant cfg_Tpl : time :=   100000 ps;  -- max program latency us.
  constant STARTUP_PH0 : std_logic_vector(2 downto 0) := "000";
  constant STARTUP_PH1 : std_logic_vector(2 downto 0) := "001";
  constant STARTUP_PH2 : std_logic_vector(2 downto 0) := "010";
  constant STARTUP_PH3 : std_logic_vector(2 downto 0) := "011";
  constant STARTUP_PH4 : std_logic_vector(2 downto 0) := "100";
  constant STARTUP_PH5 : std_logic_vector(2 downto 0) := "101";
  constant STARTUP_PH6 : std_logic_vector(2 downto 0) := "110";
  constant STARTUP_PH7 : std_logic_vector(2 downto 0) := "111";
  constant FRAME_RBT_OUT_FILENAME : string := "frame_data_e2_rbt_out.txt";
  signal GSR : std_ulogic := '1';
  signal GTS : std_ulogic := '1';
  signal GWE : std_ulogic := '0';
  signal cclk_in : std_ulogic;
  signal init_b_in : std_ulogic;
  signal prog_b_in : std_ulogic;
  signal rdwr_b_in : std_ulogic;
  signal rdwr_b_in1 : std_ulogic;
  signal checka_en : std_ulogic := '0';
  signal init_b_out  : std_ulogic :=  '1';
  signal done_o  : std_logic_vector(3 downto 0) := "0000";
  signal por_b : std_ulogic := '0';
  signal m_in  : std_logic_vector (2 downto 0) ;
  signal frame_data_fd : integer;
  signal farn  : integer :=  0;
  signal frame_data_wen  : std_ulogic :=  '0';
  signal d_in  : std_logic_vector (31 downto 0) ; 
  signal d_out  : std_logic_vector (31 downto 0) ; 
  signal busy_out : std_ulogic;
  signal cso_b_out : std_ulogic;
  signal csi_b_in : std_ulogic;
  signal csi_b_ins : std_ulogic := '1';
  signal d_out_en : std_ulogic;
  signal pll_locked : std_ulogic;
  signal init_b_t : std_ulogic;
  signal prog_b_t : std_ulogic;
  signal bus_en : std_ulogic;
  signal ib : integer := 0;
  signal ib_skp : integer := 0;
  signal rd_desynch : std_ulogic :=  '0';
  signal rd_desynch_tmp : std_ulogic :=  '0';
  signal desync_flag : std_logic_vector(3 downto 0) := "0000";
  signal crc_rst : std_logic_vector(3 downto 0) := "0000";
  signal  crc_bypass  : std_logic_vector(3 downto 0) := "0000";
  signal icap_on  : std_ulogic :=  '0';
  signal icap_clr  : std_ulogic :=  '0';
  signal icap_sync  : std_ulogic :=  '0';
  signal icap_desynch  : std_ulogic :=  '0';
  signal icap_init_done  : std_ulogic :=  '0';
  signal icap_init_done_dly  : std_ulogic :=  '0';
  signal desynch_set_tmp : std_ulogic;
  signal desynch_set1 : std_logic_vector(3 downto 0) := "0000";
  signal icap_bw : std_logic_vector (1 downto 0) :=  "01"; 
  signal  prog_pulse_low_edge  : time :=  0 ps;
  signal  prog_pulse_low  : time :=  0 ps;
  signal  mode_sample_flag  : std_ulogic :=  '0';
  signal  buswid_flag_init  : std_logic_vector(3 downto 0) := "0000";
  signal  buswid_flag_init_bi  : std_ulogic :=  '0';
  signal  buswid_flag_init_tmp_bi  : std_ulogic :=  '0';
  signal  buswid_flag  : std_logic_vector(3 downto 0) := "0000";
  signal  buswid_flag_bi : std_ulogic :=  '0';
  type    v2_a is  array (integer range <>) of
                            std_logic_vector(1 downto 0);
  type    v4_a is  array (integer range <>) of
                            std_logic_vector(3 downto 0);
  type    v5_a is  array (integer range <>) of
                            std_logic_vector(4 downto 0);
  type    v16_a is  array (integer range <>) of
                            std_logic_vector(15 downto 0); 
  type    v32_a is  array (integer range <>) of
                            std_logic_vector(31 downto 0);
  type    i4_a is  array (integer range <>) of
                            integer;
  signal buswidth  : v2_a (3 downto 0) ; 
  signal buswidth_tmp : v2_a (3 downto 0) :=  (others => "00"); 
--  signal buswidth_tmp : std_logic_vector (1 downto 0) :=  "00"; 
  signal pack_in_reg : v32_a (3 downto 0) := (others => X"00000000"); 
--  signal pack_in_reg_tmp : std_logic_vector (31 downto 0) := X"00000000"; 
--  signal pack_in_reg_tmp0 : std_logic_vector (31 downto 0) := X"00000000"; 
--  signal pack_in_reg_tmpv : std_logic_vector (31 downto 0) := X"00000000"; 
  signal pack_in_reg_tmps0 : std_logic_vector (31 downto 0) := X"00000000"; 
  signal reg_addr  : v5_a (3 downto 0) ; 
  signal  new_data_in_flag   : std_logic_vector (3 downto 0) := "0000";
  signal  wr_flag   : std_logic_vector (3 downto 0) := "0000";
  signal  rd_flag   : std_logic_vector (3 downto 0) := "0000";
  signal  rd_flag_tmpi : std_ulogic;
  signal  cmd_wr_flag   : std_logic_vector (3 downto 0) := "0000";
  signal  cmd_reg_new_flag  : std_logic_vector (3 downto 0) := "0000";
  signal  cmd_rd_flag   : std_logic_vector (3 downto 0) := "0000";
  signal  bus_sync_flag  : std_logic_vector (3 downto 0) := "0000";
  signal  conti_data_flag  : std_logic_vector (3 downto 0) := "0000";
  signal  wr_cnt   : i4_a (3 downto 0) := (others=>0);
  signal  conti_data_cnt  : i4_a (3 downto 0) := (others=>0);
  signal  rd_data_cnt  : i4_a (3 downto 0) := (others=>0);
  signal  abort_cnt  : integer :=  0;
  signal st_state0 : std_logic_vector (2 downto 0) :=  STARTUP_PH0; 
  signal st_state1 : std_logic_vector (2 downto 0) :=  STARTUP_PH0; 
  signal st_state2 : std_logic_vector (2 downto 0) :=  STARTUP_PH0; 
  signal st_state3 : std_logic_vector (2 downto 0) :=  STARTUP_PH0; 
  signal  startup_begin_flag0  : std_ulogic :=  '0';
  signal  startup_begin_flag1  : std_ulogic :=  '0';
  signal  startup_begin_flag2  : std_ulogic :=  '0';
  signal  startup_begin_flag3  : std_ulogic :=  '0';
  signal  startup_end_flag0  : std_ulogic :=  '0';
  signal  startup_end_flag1  : std_ulogic :=  '0';
  signal  startup_end_flag2  : std_ulogic :=  '0';
  signal  startup_end_flag3  : std_ulogic :=  '0';
  signal  crc_ck  : std_logic_vector (3 downto 0) := "0000";
  signal  crc_ck_en  : std_logic_vector (3 downto 0) := "1111";
  signal crc_err_flag  : std_logic_vector (3 downto 0) := "0000";
  signal crc_err_flag_tot : std_logic_vector (3 downto 0) := "0000";
  signal crc_err_flag_reg  : std_logic_vector (3 downto 0) := "0000";
  signal  crc_en : std_logic_vector (3 downto 0) := "0000";
  signal crc_curr : v32_a (3 downto 0) :=  (others => X"00000000");
  signal crc_new : std_logic_vector (31 downto 0) :=  X"00000000";
  signal crc_input : std_logic_vector (36 downto 0) := "0000000000000000000000000000000000000";
  signal rbcrc_curr : v32_a (3 downto 0) :=  (others => X"00000000");
  signal rbcrc_new : std_logic_vector (31 downto 0) :=  X"00000000";
  signal rbcrc_input : std_logic_vector (36 downto 0) :=  "0000000000000000000000000000000000000";
  signal  gwe_out  : std_logic_vector (3 downto 0) := "0000";
  signal  gts_out  : std_logic_vector (3 downto 0) := "1111";
  signal d_o : std_logic_vector (31 downto 0) :=  X"00000000";
  signal outbus : std_logic_vector (31 downto 0) :=  X"00000000";
  signal outbus_dly : std_logic_vector (31 downto 0) :=  X"00000000";
  signal  busy_o  : std_ulogic :=  '0';
  signal tmp_val1  : std_logic_vector (31 downto 0) ; 
  signal tmp_val2  : std_logic_vector (31 downto 0) ; 
  signal crc_reg  : v32_a (3 downto 0) ; 
  signal far_reg  : v32_a (3 downto 0) ;
  signal far_addr  : integer := 0 ; 
  signal fdri_reg  : v32_a (3 downto 0); 
  signal fdro_reg  : v32_a (3 downto 0); 
  signal cmd_reg  : v5_a (3 downto 0) ; 
  signal ctl0_reg : v32_a (3 downto 0)  := (others => "000XXXXXXXXXXXXXX000000100000XX1"); 
  signal ctl0_reg_tmp0 : std_logic_vector (31 downto 0);
  signal ctl0_reg_tmp1 : std_logic_vector (31 downto 0);
  signal ctl0_reg_tmp2 : std_logic_vector (31 downto 0);
  signal ctl0_reg_tmp3 : std_logic_vector (31 downto 0);
  signal mask_reg  : v32_a (3 downto 0) ; 
  signal stat_reg : v32_a (3 downto 0); 
  signal stat_reg_tmp0 : std_logic_vector (31 downto 0);
  signal stat_reg_tmp1 : std_logic_vector (31 downto 0);
  signal stat_reg_tmp2 : std_logic_vector (31 downto 0);
  signal stat_reg_tmp3 : std_logic_vector (31 downto 0);
  signal lout_reg  : v32_a (3 downto 0) ; 
  signal cor0_reg : v32_a (3 downto 0) :=  (others => "00000000000000000011111111101100"); 
  signal cor0_reg_tmp0 : std_logic_vector (31 downto 0) :=  "00000000000000000011111111101100";
  signal cor0_reg_tmp1 : std_logic_vector (31 downto 0) :=  "00000000000000000011111111101100";
  signal cor0_reg_tmp2 : std_logic_vector (31 downto 0) :=  "00000000000000000011111111101100";
  signal cor0_reg_tmp3 : std_logic_vector (31 downto 0) :=  "00000000000000000011111111101100";
  signal mfwr_reg  : v32_a (3 downto 0) ; 
  signal cbc_reg  : v32_a (3 downto 0) ; 
  signal idcode_reg  : v32_a (3 downto 0) ; 
  signal idcode_reg1  : v32_a (3 downto 0) := (others => TO_STDLOGICVECTOR(DEVICE_ID)); 
  signal axss_reg  : v32_a (3 downto 0) ; 
  signal cor1_reg : v32_a (3 downto 0) :=  (others => X"00000000"); 
  signal cor1_reg_tmp0 : std_logic_vector  (31 downto 0) :=   X"00000000"; 
  signal cor1_reg_tmp1 : std_logic_vector  (31 downto 0) :=   X"00000000"; 
  signal cor1_reg_tmp2 : std_logic_vector  (31 downto 0) :=   X"00000000"; 
  signal cor1_reg_tmp3 : std_logic_vector  (31 downto 0) :=   X"00000000"; 
  signal csob_reg  : v32_a (3 downto 0) ; 
  signal wbstar_reg : v32_a (3 downto 0) := (others =>  X"00000000");
  signal timer_reg : v32_a (3 downto 0) := (others =>  X"00000000");
  signal rbcrc_hw_reg  : v32_a (3 downto 0) ; 
  signal rbcrc_sw_reg  : v32_a (3 downto 0) ; 
  signal rbcrc_live_reg  : v32_a (3 downto 0) ; 
  signal efar_reg  : v32_a (3 downto 0) ; 
  signal bootsts_reg : v32_a (3 downto 0) := (others =>  X"00000000");
  signal ctl1_reg : v32_a (3 downto 0) := (others =>  X"00000000");
  signal testmode_reg : v32_a (3 downto 0) := (others =>  X"00000000");
  signal memrd_param_reg : v32_a (3 downto 0) := (others =>  X"00000000");
  signal dwc_reg : v32_a (3 downto 0) := (others =>  X"00000000");
  signal trim_reg : v32_a (3 downto 0) := (others =>  X"00000000");
  signal bout_reg : v32_a (3 downto 0) := (others =>  X"00000000");
  signal bspi_reg : v32_a (3 downto 0) := (others =>  X"00000000");
  signal mode_pin_in : std_logic_vector(2 downto 0) :=  "000"; 
--  signal mode_reg  : (2 downto 0) ; 
  signal  crc_reset  : std_logic_vector (3 downto 0) := "0000";
  signal  gsr_set  : std_logic_vector (3 downto 0) := "0000";
  signal  gts_usr_b  : std_logic_vector (3 downto 0) := "1111";
  signal  done_pin_drv  : std_logic_vector (3 downto 0) := "0000";
  
  signal  shutdown_set  : std_logic_vector (3 downto 0) := "0000";
  signal  desynch_set  : std_logic_vector (3 downto 0) := "0000";
  signal done_cycle_reg0  : std_logic_vector (2 downto 0) := "011"; 
  signal done_cycle_reg1  : std_logic_vector (2 downto 0) := "011"; 
  signal done_cycle_reg2  : std_logic_vector (2 downto 0) := "011"; 
  signal done_cycle_reg3  : std_logic_vector (2 downto 0) := "011"; 
  signal gts_cycle_reg0  : std_logic_vector (2 downto 0) := "101"; 
  signal gts_cycle_reg1  : std_logic_vector (2 downto 0) := "101"; 
  signal gts_cycle_reg2  : std_logic_vector (2 downto 0) := "101"; 
  signal gts_cycle_reg3  : std_logic_vector (2 downto 0) := "101"; 
  signal gwe_cycle_reg0  : std_logic_vector (2 downto 0) := "100"; 
  signal gwe_cycle_reg1  : std_logic_vector (2 downto 0) := "100"; 
  signal gwe_cycle_reg2  : std_logic_vector (2 downto 0) := "100"; 
  signal gwe_cycle_reg3  : std_logic_vector (2 downto 0) := "100"; 
  signal  init_pin : std_ulogic;
  signal  init_rst  : std_ulogic :=  '0';
  signal  init_complete : std_ulogic; 
  signal nx_st_state0 : std_logic_vector (2 downto 0) :=  "000"; 
  signal nx_st_state1 : std_logic_vector (2 downto 0) :=  "000"; 
  signal nx_st_state2 : std_logic_vector (2 downto 0) :=  "000"; 
  signal nx_st_state3 : std_logic_vector (2 downto 0) :=  "000"; 
  signal  ghigh_b  : std_logic_vector (3 downto 0) :=  "0000";
  signal  gts_cfg_b  : std_logic_vector (3 downto 0) :=  "0000";
  signal  eos_startup  : std_logic_vector (3 downto 0) :=  "0000";
  signal startup_set  : std_logic_vector (3 downto 0) :=  "0000";
  signal startup_set_pulse0 : std_logic_vector (1 downto 0) :=  "00"; 
  signal startup_set_pulse1 : std_logic_vector (1 downto 0) :=  "00"; 
  signal startup_set_pulse2 : std_logic_vector (1 downto 0) :=  "00"; 
  signal startup_set_pulse3 : std_logic_vector (1 downto 0) :=  "00"; 
  signal abort_out_en  : std_ulogic :=  '0';
  signal tmp_dword  : std_logic_vector (31 downto 0) ; 
  signal tmp_word  : std_logic_vector (15 downto 0) ; 
  signal tmp_byte  : std_logic_vector (7 downto 0) ; 
  signal id_error_flag  : std_logic_vector (3 downto 0) :=  "0000";
  signal id_error_flag_tmpi : std_ulogic :=  '0';
  signal iprog_b  : std_logic_vector (3 downto 0) :=  "1111";
  signal iprog_b_t : std_ulogic :=  '1';
  signal i_init_b_cmd  : std_logic_vector (3 downto 0) :=  "1111";
  signal i_init_b_cmd_t : std_ulogic :=  '1';
  signal i_init_b  : std_ulogic :=  '0';
  signal abort_status : std_logic_vector (7 downto 0) :=  "00000000"; 
  signal persist_en  : std_logic_vector (3 downto 0) :=  "0000";
  signal rst_sync  : std_logic_vector (3 downto 0) :=  "0000";
  signal abort_dis  : std_logic_vector (3 downto 0) :=  "0000";
  signal abort_dis_bi  : std_ulogic :=  '0';
  signal lock_cycle_reg0 : std_logic_vector (2 downto 0) :=  "100"; 
  signal lock_cycle_reg1 : std_logic_vector (2 downto 0) :=  "100"; 
  signal lock_cycle_reg2 : std_logic_vector (2 downto 0) :=  "100"; 
  signal lock_cycle_reg3 : std_logic_vector (2 downto 0) :=  "100"; 
  signal rbcrc_no_pin  : std_logic_vector (3 downto 0) :=  "0000";
  signal abort_flag_rst  : std_ulogic :=  '0';
  signal gsr_st_out  : std_logic_vector (3 downto 0) :=  "1111";
  signal gsr_cmd_out  : std_logic_vector (3 downto 0) :=  "0000";
  signal gsr_cmd_out_pulse  : std_logic_vector (3 downto 0) :=  "0000";
  signal d_o_en  : std_ulogic :=  '0';
  signal rst_intl : std_ulogic;
  signal rw_en : std_logic_vector (3 downto 0);
  signal rw_en_tmp : std_ulogic;
  signal rw_en_tmp1 : std_ulogic;
  signal gsr_out : std_logic_vector (3 downto 0);
  signal cfgerr_b_flag : std_logic_vector (3 downto 0);
  signal abort_flag : std_logic_vector (3 downto 0) :=  "0000";
  signal abort_flag_bi  : std_ulogic :=  '0';
  signal abort_flag_tmpi : std_ulogic :=  '0';
  signal downcont_cnt  : integer :=  0;
  signal rst_en  : std_ulogic :=  '0';
  signal prog_b_a  : std_ulogic :=  '1';
  signal csbo_flag  : std_logic_vector (3 downto 0) :=  "0000";
  signal bout_flag  : std_logic_vector (3 downto 0) :=  "0000";
  signal bout_flags  : std_logic_vector (3 downto 0) :=  "0000";
  signal bout_bf  : std_logic_vector (3 downto 0) :=  "0000";
  signal bout_en  : std_logic_vector (3 downto 0) :=  "0001";
  signal csi_sync  : std_ulogic :=  '0';
  signal rd_sw_en  : std_ulogic :=  '0';
  signal csbo_cnt  : i4_a (3 downto 0) := (others => 0);
  signal bout_cnt  : i4_a (3 downto 0) := (others => 0);
  signal bout_cnt_tmp : integer :=  0;
  signal rd_reg_addr : v5_a  (3 downto 0) := (others => "00000"); 
  signal  done_in  : std_ulogic; 
  signal done_o_t : std_ulogic;
  signal done_o_t1 : std_ulogic;
  signal done_o_t2 : std_ulogic;
  signal done_o_t3 : std_ulogic;
  file f_fd : text;
  
  begin
   INITB <=  not crc_err_flag_tot(ib) when mode_sample_flag = '1' else init_b_out
when init_b_out ='0' else 'H';

    done_o_t1 <= done_o(1) when bout_en(1) = '1' else 'H';
    done_o_t2 <= done_o(2) when bout_en(2) = '1' else 'H';
    done_o_t3 <= done_o(3) when bout_en(3) = '1' else 'H';
    done_o_t <= done_o(0) and done_o_t1 and done_o_t2 and done_o_t3; 
    DONE <= done_o_t ;
    
    done_in <= DONE;

   CSOB <= cso_b_out;
   cclk_in <= CCLK;
   csi_b_in <= CSB;

   d_in <= D;
   D <=  d_out when d_out_en = '1' else "HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH";
   pll_locked <= '0' when PLL_LOCKG = '0' else '1';
   PROGB_GLBL <= PROGB;

   init_b_in <= INITB;
   m_in <= M;
   prog_b_in <= PROGB;
   rdwr_b_in <= RDWRB;



   INIPROC : process
    variable open_status : file_open_status;
    variable read_ok : boolean := false;
   begin

    if (DEVICE_ID  =  X"036A2093"  or  DEVICE_ID  =  X"03702093") then
       bout_en <= "0011";
    elsif (DEVICE_ID  =  X"036A4093"  or  DEVICE_ID  =  X"03704093") then
       bout_en <= "0111";
    elsif (DEVICE_ID  =  X"036A6093") then
       bout_en <= "1111";
    end if;

     if (DEVICE_ID = X"00000000" and  ICAP_SUPPORT = FALSE) then
             assert FALSE report "Attribute Syntax Error : The attribute DEVICE_ID on  SIM_CONFIGE2 is not set." severity error;
     end if;

    case (ICAP_SUPPORT) is
      when  FALSE => icap_on <= '0';
      when  TRUE => icap_on <= '1';
      when  others => icap_on <= '0';
    end case;

     if (ICAP_SUPPORT  =  true) then 
       if  (ICAP_WIDTH =  "X8") then
           icap_bw <= "01";
       elsif (ICAP_WIDTH =  "X16") then
           icap_bw <= "10";
       elsif (ICAP_WIDTH =  "X32") then
           icap_bw <= "11";
       end if;

       file_open(open_status, f_fd, FRAME_RBT_OUT_FILENAME, write_mode);
       if (open_status = open_ok) then
            frame_data_wen <= '1';
            write(f_fd, "frame_address     frame_data      readback_crc_value" & LF);
       end if;
     else 
        icap_bw <= "10";
        frame_data_wen <= '0';
     end if;

      icap_sync <= '0';
      
     wait;
   end process;


    GSR <= gsr_out(0);
    GTS <= gts_out(0);
    GWE <= gwe_out(0);
    busy_out <= busy_o;
    cfgerr_b_flag(0) <= rw_en(0)  and  (not crc_err_flag_tot(0));
    cfgerr_b_flag(1) <= rw_en(1)  and  (not crc_err_flag_tot(1));
    cfgerr_b_flag(2) <= rw_en(2)  and  (not crc_err_flag_tot(2));
    cfgerr_b_flag(3) <= rw_en(3)  and  (not crc_err_flag_tot(3));
    crc_err_flag_tot(0) <= id_error_flag(0)  or  crc_err_flag_reg(0);
    crc_err_flag_tot(1) <= id_error_flag(1)  or  crc_err_flag_reg(1);
    crc_err_flag_tot(2) <= id_error_flag(2)  or  crc_err_flag_reg(2);
    crc_err_flag_tot(3) <= id_error_flag(3)  or  crc_err_flag_reg(3);

    d_out(7 downto 0) <=  abort_status when (abort_out_en = '1') else outbus_dly(7 downto 0);
    d_out(31 downto 8) <=  X"000000" when (abort_out_en = '1') else outbus_dly(31 downto 8);

    d_out_en <= d_o_en;
    cso_b_out <=  '0' when (csbo_flag(0) =  '1') else '1';
    crc_en <=    "0000" when (icap_init_done =  '1') else "1111";

    outbus_dly_p : process (cclk_in)
      variable tmp1 : std_logic_vector(31 downto 0) := X"00000000";
      variable tmp2 : std_logic_vector(31 downto 0) := X"00000000";
    begin
      if (rising_edge(cclk_in)) then
        outbus_dly <= tmp2;
        tmp2 := tmp1;
        tmp1 := outbus;
      end if;
    end process; 

   abort_flag_tmpi <= abort_flag(ib);

   process  begin
        if (csi_b_in  =  '1')  then
           csi_b_ins <= csi_b_in;
        else
          if (cclk_in  /=  '1') then
            csi_b_ins <= csi_b_in;
          else 
            wait until falling_edge(cclk_in);
            csi_b_ins <= csi_b_in;
          end if;
        end if;
        wait on csi_b_in, cclk_in;
   end process;

   rd_flag_tmpi <= rd_flag(ib);

   process (abort_out_en, csi_b_in, rdwr_b_in, rd_flag_tmpi)  begin
    if (abort_out_en  =  '1') then
       d_o_en <= '1';
    else
       d_o_en <= rdwr_b_in  and   (not csi_b_in)  and  rd_flag_tmpi;
    end if;
   end process;


   i_init_b_cmd_t <= i_init_b_cmd(0) and i_init_b_cmd(1) and 
                    i_init_b_cmd(2) and i_init_b_cmd(3);

   iprog_b_t <= iprog_b(0) and iprog_b(1) and iprog_b(2) and iprog_b(3);

   init_b_t <= init_b_in  and  i_init_b_cmd_t;

  process (rst_en, init_rst, prog_b_in, iprog_b_t)
  begin
  if (icap_on = '0') then
   if (init_rst = '1') then
       init_b_out <= '0';
   else
     if ((rst_en = '1' and prog_b_in  =  '0') or iprog_b_t = '0' ) then
         init_b_out <= '0';
     elsif ((rst_en = '1' and prog_b_in  =  '1') or iprog_b_t = '1') then
         init_b_out <= '1' after cfg_Tpl;
     end if;
    end if;
   end if;
   end process;

   id_error_flag_tmpi <= id_error_flag(ib);

  process  begin
     if  (rising_edge(id_error_flag_tmpi)) then
      init_rst <= '1';
      init_rst <= '0' after cfg_Tprog;
     end if;
   wait on id_error_flag_tmpi;
  end process;

    process
    variable rst_en_v : std_ulogic;
    begin
      if (prog_b_in'event and prog_b_in = '0') then
         rst_en_v := '0';
         rst_en <= '0';
         wait for cfg_Tprog;
         wait for 1 ps;
         rst_en_v := '1';
         rst_en <= '1';
      end if;
    if (rst_en_v = '1') then
       if (prog_pulse_low  =  cfg_Tprog) then
           prog_b_a <= '0';
           prog_b_a <= '1' after 500 ps;
       else
          prog_b_a <= prog_b_in;
       end if;
    else
          prog_b_a <= '1';
    end if;
     wait on prog_b_in, prog_pulse_low;
  end process;

  process begin
    por_b <= '0';
    por_b <= '1' after 400 ns;
    wait;
  end process;

   prog_b_t <= prog_b_a   and  iprog_b_t  and  por_b;

   rst_intl <= '0' when (prog_b_t  =  '0' ) else '1';

  process (init_b_t, prog_b_t)
    variable Message : line;
  begin
   if  (prog_b_t = '0') then
      mode_sample_flag <= '0';
   elsif ( init_b_t = '1' and mode_sample_flag = '0') then
        if(prog_b_t = '1') then
           mode_pin_in <= m_in;
           if (m_in /= "110") then
             mode_sample_flag <= '0';
             if (icap_on = '0') then
              Write ( Message, string'(" Error: input M is "));
              Write ( Message, string'(SLV_TO_STR(m_in)));
              Write ( Message, string'(" . Only Slave SelectMAP mode M=110 supported on SIM_CONFIGE2."));
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
            assert false report "Error: PROGB is not high when INITB goes high on SIM_CONFIGE2." severity error;
       end if;
    end if;
  end process;

  process (m_in) begin
    if (mode_sample_flag = '1' and persist_en(0) = '1' and icap_on = '0') then
       assert false report "Error : Mode pine M[2:0] changed after rising edge of INITB on SIM_CONFIGE2." severity error;
    end if;
  end process;

  prog_pulse_P : process (prog_b_in)
     variable prog_pulse_low_v : time;
--     variable prog_pulse_low : time;
     variable Message : line;
  begin
    if (falling_edge (prog_b_in)) then
       prog_pulse_low_edge <= NOW;
    else
      if (NOW > 0 ps ) then
         prog_pulse_low_v := NOW - prog_pulse_low_edge;
         prog_pulse_low <= NOW - prog_pulse_low_edge;
         if (prog_pulse_low_v < cfg_Tprog ) then
             Write ( Message, string'(" Error: Low time of PROGB is less than required minimum Tprogram time "));
             Write ( Message, prog_pulse_low_v);
             Write ( Message, string'(" ."));
             assert false report Message.all severity error;
             DEALLOCATE(Message);
         end if;
      end if;
    end if;
  end process;

     bus_en <= '1' when (mode_sample_flag  =  '1'  and   csi_b_in  = '0') else '0';

      buswid_flag_bi <= buswid_flag(ib);
      buswid_flag_init_bi <= buswid_flag_init(ib);

--    process (cclk_in,  rst_intl, desynch_set1)
    buswidth_chk_p : process (cclk_in,  rst_intl, buswid_flag_bi)
       variable tmp_byte : std_logic_vector (7 downto 0);
       variable tmp_byteb : std_logic_vector (7 downto 0);
    begin
      if (rst_intl  = '0') then
         buswid_flag_init <= "0000";
         buswid_flag <= "0000";
         buswidth_tmp(0) <= "00";
         buswidth_tmp(1) <= "00";
         buswidth_tmp(2) <= "00";
         buswidth_tmp(3) <= "00";
      elsif (rising_edge(cclk_in)) then
                 tmp_byteb := bit_revers8(d_in(7 downto 0));
        if (buswid_flag_bi  =  '0') then
           if (bus_en = '1'  and  rdwr_b_in  =  '0')  then
                 tmp_byte := bit_revers8(d_in(7 downto 0));
                 if (buswid_flag_init_bi  =  '0') then
                     if (tmp_byte  =  X"BB") then
                         buswid_flag_init(ib) <= '1';
                         buswid_flag_init_tmp_bi <= '1';
                     end if;
                  else
                     if (tmp_byte  =  X"11") then
                         buswid_flag(ib) <= '1';
                         buswidth_tmp(ib) <= "01";
                     elsif (tmp_byte  =  X"22") then
                         buswid_flag(ib) <= '1';
                         buswidth_tmp(ib) <= "10";
                     elsif (tmp_byte  =  X"44") then
                         buswid_flag(ib) <= '1';
                         buswidth_tmp(ib) <= "11";
                     else
                         buswid_flag(ib) <= '0';
                         buswidth_tmp(ib) <= "00";
                         buswid_flag_init(ib) <= '0';
                         if (icap_on = '0') then
                         assert false report
                         "Error : BUS Width Auto Dection did not find 0x11 or 0x22 or 0x44 on D(7:0) followed 0xBB on SIM_CONFIGE2."
                         severity error;
                         else
                         assert false report
                         "Error : BUS Width Auto Dection did not find 0x11 or 0x22 or 0x44 on D(7:0) followed 0xBB on X_ICAPE2."
                         severity error;
                         end if;
                     end if;
                 end if;
            end if;
      end if;
     end if;
     end process;

     buswidth(ib) <= icap_bw(1 downto 0) when (icap_on  =  '1'  and  icap_init_done  =  '1')  else  buswidth_tmp(ib);
     rw_en_tmp <= '1' when (bus_en  =  '1' ) else '0';
     rw_en(0) <= rw_en_tmp when (buswid_flag(0)  =  '1')  else '0';
     rw_en(1) <= rw_en_tmp when (buswid_flag(1)  =  '1')  else '0';
     rw_en(2) <= rw_en_tmp when (buswid_flag(2)  =  '1')  else '0';
     rw_en(3) <= rw_en_tmp when (buswid_flag(3)  =  '1')  else '0';
     desynch_set1(0) <= desynch_set(0)  or  icap_desynch or  rd_desynch;
     desynch_set1(1) <= desynch_set(1)  or  icap_desynch or  rd_desynch;
     desynch_set1(2) <= desynch_set(2)  or  icap_desynch or  rd_desynch;
     desynch_set1(3) <= desynch_set(3)  or  icap_desynch or  rd_desynch;
     desync_flag(0) <=  (not rst_intl)  or  desynch_set1(0)  or  crc_err_flag(0)  or  id_error_flag(0);
     desync_flag(1) <=  (not rst_intl)  or  desynch_set1(1)  or  crc_err_flag(1)  or  id_error_flag(1);
     desync_flag(2) <=  (not rst_intl)  or  desynch_set1(2)  or  crc_err_flag(2)  or  id_error_flag(2);
     desync_flag(3) <=  (not rst_intl)  or  desynch_set1(3)  or  crc_err_flag(3)  or  id_error_flag(3);
    
    process  begin
      if (rising_edge(eos_startup(0))) then
        if (icap_on  =  '1') then
          file_close(f_fd);
          icap_init_done <= '1';
          wait until rising_edge(cclk_in);
          wait until rising_edge(cclk_in);
          if (icap_init_done_dly = '0') then
              icap_desynch <= '1';
          end if;
          wait until rising_edge(cclk_in);
          wait until rising_edge(cclk_in);
          icap_init_done_dly <= '1';
          icap_desynch <= '0';
           wait until rising_edge(cclk_in);
           wait until rising_edge(cclk_in);
        else
          icap_desynch <= '0';
        end if;
      end if;
      wait on eos_startup, cclk_in;
    end process;

   process (cclk_in, rdwr_b_in) begin
      if (rdwr_b_in = '0') then
           rd_sw_en <= '0';
      elsif (rising_edge(cclk_in)) then
           if (csi_b_in = '1' and rdwr_b_in = '1') then
              rd_sw_en <= '1';
           end if;
      end if;
   end process;

    bus_sync_p : process (cclk_in, desync_flag, csi_b_in)
      variable tmp_byte  : std_logic_vector (7 downto 0);
      variable tmp_word  : std_logic_vector (15 downto 0);
      variable tmp_dword  : std_logic_vector (31 downto 0);
      variable pack_in_reg_tmp0 : std_logic_vector (31 downto 0);
    begin
      if (desync_flag(ib) = '1') then
         pack_in_reg_tmp0 := X"00000000";
          pack_in_reg_tmps0 <= X"00000000";
      end if;
      if (desync_flag(0) = '1') then
          pack_in_reg(0) <= X"00000000";
          new_data_in_flag(0) <= '0';
          bus_sync_flag(0) <= '0';
          wr_cnt(0) <= 0;
          wr_flag(0) <= '0';
          rd_flag(0) <= '0';
      end if;
      if (desync_flag(1) = '1') then
          pack_in_reg(1) <= X"00000000";
          new_data_in_flag(1) <= '0';
          bus_sync_flag(1) <= '0';
          wr_cnt(1) <= 0;
          wr_flag(1) <= '0';
          rd_flag(1) <= '0';
      end if;
      if (desync_flag(2) = '1') then
          pack_in_reg(2) <= X"00000000";
          new_data_in_flag(2) <= '0';
          bus_sync_flag(2) <= '0';
          wr_cnt(2) <= 0;
          wr_flag(2) <= '0';
          rd_flag(2) <= '0';
      end if;
      if (desync_flag(3) = '1') then
          pack_in_reg(3) <= X"00000000";
          new_data_in_flag(3) <= '0';
          bus_sync_flag(3) <= '0';
          wr_cnt(3) <= 0;
          wr_flag(3) <= '0';
          rd_flag(3) <= '0';
      end if;

      if (icap_init_done = '1' and  csi_b_in = '1' and rdwr_b_in = '0') then
          pack_in_reg(0) <= X"00000000";
          pack_in_reg(1) <= X"00000000";
          pack_in_reg(2) <= X"00000000";
          pack_in_reg(3) <= X"00000000";
          new_data_in_flag <= "0000";
          wr_cnt(0) <= 0;
          wr_cnt(1) <= 0;
          wr_cnt(2) <= 0;
          wr_cnt(3) <= 0;
          pack_in_reg_tmp0 := X"00000000";
          pack_in_reg_tmps0 <= X"00000000";
      elsif (rising_edge(cclk_in)) then
       if (icap_clr = '1') then
          pack_in_reg(0) <= X"00000000";
          pack_in_reg(1) <= X"00000000";
          pack_in_reg(2) <= X"00000000";
          pack_in_reg(3) <= X"00000000";
          new_data_in_flag <= "0000";
          wr_cnt(0) <= 0;
          wr_cnt(1) <= 0;
          wr_cnt(2) <= 0;
          wr_cnt(3) <= 0;
          pack_in_reg_tmp0 := X"00000000";
          pack_in_reg_tmps0 <= X"00000000";
          wr_flag <= "0000";
          rd_flag <= "0000";
       elsif (rw_en(ib)  =  '1' and desync_flag(ib) = '0' ) then
         if (rdwr_b_in  =  '0') then
           wr_flag(ib) <= '1';
           rd_flag(ib) <= '0';
           if (buswidth(ib)  =  "01" or (icap_sync = '1' and bus_sync_flag(ib) = '0')) then
               tmp_byte := bit_revers8(d_in(7 downto 0));
               if (bus_sync_flag(ib)  =  '0') then
                  pack_in_reg_tmp0 := pack_in_reg(ib);
                  if (pack_in_reg_tmp0(23 downto 16) = X"AA" and pack_in_reg_tmp0(15 downto 8) = X"99"
                       and  pack_in_reg_tmp0(7 downto 0)  =  X"55"  and  tmp_byte = X"66") then
                          bus_sync_flag(ib) <= '1';
                          new_data_in_flag(ib) <= '0';
                          wr_cnt(ib) <= 0;
                   else
                      pack_in_reg_tmp0(31 downto 24) := pack_in_reg_tmp0(23 downto 16);
                      pack_in_reg_tmp0(23 downto 16) := pack_in_reg_tmp0(15 downto 8);
                      pack_in_reg_tmp0(15 downto 8) := pack_in_reg_tmp0(7 downto 0);
                      pack_in_reg_tmp0(7 downto 0) := tmp_byte;
                      pack_in_reg(ib) <= pack_in_reg_tmp0;
                   end if;
               else
                 if (wr_cnt(ib)  =  0) then
                    pack_in_reg_tmp0 := pack_in_reg(ib);
                    pack_in_reg_tmp0(31 downto 24) := tmp_byte;
                    pack_in_reg(ib) <= pack_in_reg_tmp0;
                     new_data_in_flag(ib) <= '0';
                     wr_cnt(ib) <=  1;
                 elsif (wr_cnt(ib)  =  1) then
                    pack_in_reg_tmp0 := pack_in_reg(ib);
                    pack_in_reg_tmp0(23 downto 16) := tmp_byte;
                    pack_in_reg(ib) <= pack_in_reg_tmp0;
                    new_data_in_flag(ib) <= '0';
                    wr_cnt(ib) <= 2;
                 elsif (wr_cnt(ib)  =  2) then
                    pack_in_reg_tmp0 := pack_in_reg(ib);
                    pack_in_reg_tmp0(15 downto 8) := tmp_byte;
                    pack_in_reg(ib) <= pack_in_reg_tmp0;
                     new_data_in_flag(ib) <= '0';
                     wr_cnt(ib) <= 3;
                 elsif (wr_cnt(ib)  =  3) then
                    pack_in_reg_tmp0 := pack_in_reg(ib);
                    pack_in_reg_tmp0(7 downto 0) := tmp_byte;
                    pack_in_reg(ib) <= pack_in_reg_tmp0;
                     new_data_in_flag(ib) <= '1';
                     wr_cnt(ib) <= 0;
                 end if;
             end if;
           elsif (buswidth(ib)  =  "10") then
             tmp_word := bit_revers8(d_in(15 downto 8)) & bit_revers8(d_in(7 downto 0));
             if (bus_sync_flag(ib)  =  '0') then
                pack_in_reg_tmp0 := pack_in_reg(ib);
                if (pack_in_reg_tmp0(15 downto 0)  =  X"AA99"  and  tmp_word  = X"5566") then
                     wr_cnt(ib) <= 0;
                     bus_sync_flag(ib) <= '1';
                     new_data_in_flag(ib) <= '0';
                else
                   pack_in_reg_tmp0(31 downto 16) := pack_in_reg_tmp0(15 downto 0);
                   pack_in_reg_tmp0(15 downto 0) := tmp_word;
                   pack_in_reg(ib) <= pack_in_reg_tmp0;
                   new_data_in_flag(ib) <= '0';
                   wr_cnt(ib) <= 0;
                end if;
             else
               pack_in_reg_tmp0 := pack_in_reg(ib);
               if (wr_cnt(ib)  =  0) then
                   pack_in_reg_tmp0(31 downto 16) := tmp_word;
                   pack_in_reg(ib) <= pack_in_reg_tmp0;
                   new_data_in_flag(ib) <= '0';
                   wr_cnt(ib) <= 1;
               elsif (wr_cnt(ib)  =  1) then
                   pack_in_reg_tmp0(15 downto 0) := tmp_word;
                   pack_in_reg(ib) <= pack_in_reg_tmp0;
                   new_data_in_flag(ib) <= '1';
                   wr_cnt(ib) <= 0;
               end if;
             end if;
           elsif (buswidth(ib)  =  "11" ) then
             tmp_dword := bit_revers8(d_in(31 downto 24)) & bit_revers8(d_in(23
downto 16)) &
                          bit_revers8(d_in(15 downto 8)) &  bit_revers8(d_in(7 downto 0));
             pack_in_reg_tmp0(31 downto 0) := tmp_dword;
             if (bus_sync_flag(ib)  =  '0') then
                if (tmp_dword  =  X"AA995566") then
                     bus_sync_flag(ib) <= '1';
                     new_data_in_flag(ib) <= '0';
                end if;
             else
                pack_in_reg(ib) <= tmp_dword;
                new_data_in_flag(ib) <= '1';
             end if;
           end if;  -- end buswidth check
       else
            wr_flag(ib) <= '0';
            new_data_in_flag(ib) <= '0';
            if (rd_sw_en  = '1') then
               rd_flag(ib) <= '1';
            end if;
       end if; -- end rdwr check
     else
            wr_flag(ib) <= '0';
            rd_flag(ib) <= '0';
            new_data_in_flag(ib) <= '0';
     end if;
   end if;
   end process;
           
   pack_decode_p :  process (cclk_in, rst_intl)
      variable tmp_v : std_logic_vector(5 downto 0);
      variable reg_addr_tmp : std_logic_vector(4 downto 0);
      variable tmp_v27 : std_logic_vector(26 downto 0);
      variable tmp_v11 : std_logic_vector(10 downto 0);
      variable tmp_v1 : std_logic_vector(27 downto 0);
      variable tmp_v2 : std_logic_vector(31 downto 0);
      variable tmp_v3 : std_logic_vector(27 downto 0);
      variable pack_in_reg_tmp : std_logic_vector(31 downto 0);
      variable mask_reg_tmp : std_logic_vector(31 downto 0);
      variable ctl0_reg_tmp : std_logic_vector(31 downto 0);
      variable ctl1_reg_tmp : std_logic_vector(31 downto 0);
      variable message_line : line;
      variable outbuf : line;
      variable tmp_str3 : string (1 TO 7);
      variable crc_new : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
      variable crc_input : std_logic_vector(36 downto 0) := "0000000000000000000000000000000000000";
      variable rbcrc_new : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
      variable rbcrc_input : std_logic_vector(36 downto 0) := "0000000000000000000000000000000000000";
   begin
      if (rst_intl  = '0') then
         conti_data_flag <= "0000";
         conti_data_cnt(0) <= 0;
         conti_data_cnt(1) <= 0;
         conti_data_cnt(2) <= 0;
         conti_data_cnt(3) <= 0;
         cmd_wr_flag <= "0000";
         cmd_rd_flag <= "0000";
         id_error_flag <= "0000";
         crc_curr(0) <= X"00000000";
         crc_curr(1) <= X"00000000";
         crc_curr(2) <= X"00000000";
         crc_curr(3) <= X"00000000";
         crc_ck <= "0000";
         csbo_cnt(0) <= 0;
         csbo_cnt(1) <= 0;
         csbo_cnt(2) <= 0;
         csbo_cnt(3) <= 0;
         csbo_flag <= "0000";
         downcont_cnt <= 0;
         rd_data_cnt(0) <= 0;
         rd_data_cnt(1) <= 0;
         rd_data_cnt(2) <= 0;
         rd_data_cnt(3) <= 0;
         bout_flag <= "0000";
         bout_cnt(0) <= 0;
         bout_cnt(1) <= 0;
         bout_cnt(2) <= 0;
         bout_cnt(3) <= 0;
      elsif (falling_edge(cclk_in)) then
        if (icap_clr  =  '1') then
         conti_data_flag <= "0000";
         conti_data_cnt(0) <= 0;
         conti_data_cnt(1) <= 0;
         conti_data_cnt(2) <= 0;
         conti_data_cnt(3) <= 0;
         cmd_wr_flag <= "0000";
         cmd_rd_flag <= "0000";
         id_error_flag <= "0000";
         crc_curr(0) <= X"00000000";
         crc_curr(1) <= X"00000000";
         crc_curr(2) <= X"00000000";
         crc_curr(3) <= X"00000000";
         crc_ck <= "0000";
         csbo_cnt(0) <= 0;
         csbo_cnt(1) <= 0;
         csbo_cnt(2) <= 0;
         csbo_cnt(3) <= 0;
         csbo_flag <= "0000";
         downcont_cnt <= 0;
         rd_data_cnt(0) <= 0;
         rd_data_cnt(1) <= 0;
         rd_data_cnt(2) <= 0;
         rd_data_cnt(3) <= 0;
         bout_flag <= "0000";
         bout_cnt(0) <= 0;
         bout_cnt(1) <= 0;
         bout_cnt(2) <= 0;
         bout_cnt(3) <= 0;
        end if;
        if (crc_reset(ib)  =  '1' ) then
            crc_reg(ib) <= X"00000000";
            crc_ck(ib) <= '0';
            crc_curr(ib) <= X"00000000";
        end if;
        if (crc_ck(ib)  =  '1') then
             crc_curr(ib) <= X"00000000";
             crc_ck(ib) <= '0';
        end if;

        if (desynch_set1(0)  =  '1'  or  crc_err_flag(0)  =  '1') then
         conti_data_flag(0) <= '0';
         conti_data_cnt(0) <= 0;
         cmd_wr_flag(0) <= '0';
         cmd_rd_flag(0) <= '0';
         id_error_flag(0) <= '0';
         crc_curr(0) <= X"00000000";
         crc_ck(0) <= '0';
         csbo_cnt(0) <= 0;
         csbo_flag(0) <= '0';
         downcont_cnt <= 0;
         rd_data_cnt(0) <= 0;
         bout_flag(0) <= '0';
         bout_cnt(0) <= 0;
        end if;

        if (desynch_set1(1)  =  '1'  or  crc_err_flag(1)  =  '1') then
         conti_data_flag(1) <= '0';
         conti_data_cnt(1) <= 0;
         cmd_wr_flag(1) <= '0';
         cmd_rd_flag(1) <= '0';
         id_error_flag(1) <= '0';
         crc_curr(1) <= X"00000000";
         crc_ck(1) <= '0';
         csbo_cnt(1) <= 0;
         csbo_flag(1) <= '0';
         downcont_cnt <= 0;
         rd_data_cnt(1) <= 0;
         bout_flag(1) <= '0';
         bout_cnt(1) <= 0;
        end if;

        if (desynch_set1(2)  =  '1'  or  crc_err_flag(2)  =  '1') then
         conti_data_flag(2) <= '0';
         conti_data_cnt(2) <= 0;
         cmd_wr_flag(2) <= '0';
         cmd_rd_flag(2) <= '0';
         id_error_flag(2) <= '0';
         crc_curr(2) <= X"00000000";
         crc_ck(2) <= '0';
         csbo_cnt(2) <= 0;
         csbo_flag(2) <= '0';
         downcont_cnt <= 0;
         rd_data_cnt(2) <= 0;
         bout_flag(2) <= '0';
         bout_cnt(2) <= 0;
        end if;

        if (desynch_set1(3)  =  '1'  or  crc_err_flag(3)  =  '1') then
         conti_data_flag(3) <= '0';
         conti_data_cnt(3) <= 0;
         cmd_wr_flag(3) <= '0';
         cmd_rd_flag(3) <= '0';
         id_error_flag(3) <= '0';
         crc_curr(3) <= X"00000000";
         crc_ck(3) <= '0';
         csbo_cnt(3) <= 0;
         csbo_flag(3) <= '0';
         downcont_cnt <= 0;
         rd_data_cnt(3) <= 0;
         bout_flag(3) <= '0';
         bout_cnt(3) <= 0;
        end if;

        if (new_data_in_flag(ib)  =  '1'  and  wr_flag(ib)  =  '1' and csi_b_ins = '0' and
          desynch_set1(ib) = '0' and crc_err_flag(ib) = '0' and icap_clr = '0') then
           pack_in_reg_tmp := pack_in_reg(ib);
           mask_reg_tmp := mask_reg(ib);
           ctl0_reg_tmp := ctl0_reg(ib);
           ctl1_reg_tmp := ctl1_reg(ib);
           reg_addr_tmp := reg_addr(ib);
           if (conti_data_flag(ib)  =  '1' ) then
               case (reg_addr_tmp) is
               when "00000" =>  
                             crc_reg(ib) <= pack_in_reg(ib);
                             crc_ck(ib) <= '1';
               when "00001" => far_reg(ib) <= ( "000000" & pack_in_reg_tmp(25 downto 0));
               when "00010" => fdri_reg(ib) <= pack_in_reg(ib);
               when "00100"  =>  cmd_reg(ib) <= pack_in_reg_tmp(4 downto 0);
               when "00101" => ctl0_reg(ib) <= (pack_in_reg_tmp  and  mask_reg_tmp)  or  (ctl0_reg_tmp  and   not mask_reg_tmp);
               when "00110" => mask_reg(ib) <= pack_in_reg(ib);
               when "01000" => lout_reg(ib) <= pack_in_reg(ib);
               when "01001" => cor0_reg(ib) <= pack_in_reg(ib);
               when "01010" => mfwr_reg(ib) <= pack_in_reg(ib);
               when "01011" => cbc_reg(ib) <= pack_in_reg(ib);
               when "01100" => 
                          tmp_v1 := pack_in_reg_tmp(27 downto 0);
                          tmp_v2 := TO_STDLOGICVECTOR(DEVICE_ID);
                          tmp_v3 := tmp_v2(27 downto 0);
                          if (tmp_v1  /=  tmp_v3) then
                             id_error_flag(ib) <= '1';
                                write(message_line, string'("Error : written value to IDCODE register is "));
                                write(message_line, string'(SLV_TO_STR(tmp_v1)));
                                write(message_line, string'(" which does not match DEVICE ID "));
                                write(message_line, string'(SLV_TO_STR(tmp_v2)));
                                if (icap_on = '0') then
                                  write(message_line, string'("on SIM_CONFIGE2."));
                                else
                                  write(message_line, string'("on X_ICAPE2."));
                                end if;

                                assert false report message_line.all  severity error;
                                DEALLOCATE(message_line);
                          else
                             id_error_flag(ib) <= '0';
                          end if;
               when "01101" => axss_reg(ib) <= pack_in_reg(ib);
               when "01110" => cor1_reg(ib) <= pack_in_reg(ib);
               when "01111" => csob_reg(ib) <= pack_in_reg(ib);
               when "10000" => wbstar_reg(ib) <= pack_in_reg(ib);
               when "10001" => timer_reg(ib) <= pack_in_reg(ib);
               when "10011" => rbcrc_sw_reg(ib) <= pack_in_reg(ib);
               when "10111" => testmode_reg(ib) <= pack_in_reg(ib);
               when "11000" => ctl1_reg(ib) <= (pack_in_reg_tmp  and  mask_reg_tmp)  or  (ctl1_reg_tmp  and   not mask_reg_tmp);
               when "11001" => memrd_param_reg(ib) <= ("0000" & pack_in_reg_tmp(27 downto 0));
               when "11010" => dwc_reg(ib) <= ("0000" & pack_in_reg_tmp(27 downto 0));
               when "11011" => trim_reg(ib) <= pack_in_reg(ib);
--               when "11110" => bout_reg(ib) <= pack_in_reg(ib);
               when "11110" => bout_reg(ib) <= pack_in_reg_tmp;
               when "11111" => bspi_reg(ib) <= pack_in_reg(ib);
           
               when others => NULL;
               end case;
   
             if (reg_addr(ib)  /=  "00000") then
                crc_ck(ib) <= '0';
             end if;

             if (reg_addr(ib)  =  "00100") then
                  cmd_reg_new_flag(ib) <= '1';
             else
                 cmd_reg_new_flag(ib) <= '0';
             end if;

             if (crc_en(ib)  =  '1')  then
               if (reg_addr(ib)  = "00100"  and  pack_in_reg_tmp(4 downto 0)  =  "00111") then
                   crc_curr(ib) <= X"00000000";
               else
                  if ( reg_addr(ib) /= "01111" and reg_addr(ib) /= "10010" and
                    reg_addr(ib) /= "10100" and reg_addr(ib) /= "10101" and
                    reg_addr(ib) /= "10110" and reg_addr(ib) /= "00000") then
                     crc_input(36 downto 0) := reg_addr(ib) & pack_in_reg_tmp(31 downto 0);
                     crc_new(31 downto 0) := crc_next(crc_curr(ib), crc_input);
                     crc_curr(ib) <= crc_new;
                   end if;
               end if;
             end if;

             if (conti_data_cnt(ib) = 1) then
                  conti_data_cnt(ib) <= 0;
             else
                conti_data_cnt(ib) <= conti_data_cnt(ib) - 1;
             end if;
        elsif (conti_data_flag(ib)  =  '0' ) then
            if ( downcont_cnt >= 1) then
                   if (crc_en(ib)  =  '1') then
                     crc_input(36 downto 0) :=  "00010" & pack_in_reg(ib);
                     crc_new(31 downto 0) := crc_next(crc_curr(ib), crc_input);
                     crc_curr(ib) <= crc_new;
                   end if;
                  if (ib = 0) then
                   if (farn <= 80) then
                      farn <= farn + 1;
                   else 
                      far_addr <= far_addr + 1;
                      farn <= 0;
                   end if;

                   if (frame_data_wen  =  '1' and icap_init_done = '0') then
                     rbcrc_input(36 downto 0) :=  ("00011" & pack_in_reg(ib)); 
                     rbcrc_new(31 downto 0) := crc_next(rbcrc_curr(ib), rbcrc_input);
                     rbcrc_curr(ib) <= rbcrc_new;
                     if (far_addr < 10 ) then
                        write(outbuf, far_addr);
                        write(outbuf, string'("      "));
                     elsif (far_addr >= 10 and far_addr < 100 ) then
                        write(outbuf, far_addr);
                        write(outbuf, string'("     "));
                     elsif (far_addr >= 100 and far_addr < 1000 ) then
                        write(outbuf, far_addr);
                        write(outbuf, string'("    "));
                     elsif (far_addr >= 1000 and far_addr < 10000 ) then
                        write(outbuf, far_addr);
                        write(outbuf, string'("   "));
                     elsif (far_addr >= 10000 and far_addr < 100000 ) then
                        write(outbuf, far_addr);
                        write(outbuf, string'("  "));
                     end if;
                     read(outbuf, tmp_str3);
                     DEALLOCATE (outbuf);
                     write(f_fd, ( tmp_str3  & "  " &  SLV_TO_STR(pack_in_reg(ib)) & "  " & SLV_TO_STR(rbcrc_new) & LF));
                   end if;
                 end if;
             end if;


             if (pack_in_reg_tmp(31 downto 29)  =  "010") then
               if (reg_addr(ib) = "00010"  and  downcont_cnt  =  0  ) then
                cmd_rd_flag(ib) <= '0';
                cmd_wr_flag(ib) <= '0';
                conti_data_flag(ib) <= '0';
                conti_data_cnt(ib) <= 0;
                tmp_v27 := pack_in_reg_tmp(26 downto 0);
                downcont_cnt <= SLV_TO_INT(SLV=>tmp_v27);
                far_addr <= SLV_TO_INT(far_reg(ib));
               elsif (reg_addr(ib) = "11110"  and  bout_cnt(ib)  =  0  ) then
                cmd_rd_flag(ib) <= '0';
                cmd_wr_flag(ib) <= '0';
                conti_data_flag(ib) <= '0';
                conti_data_cnt(ib) <= 0;
                bout_flag(ib) <= '1';
                tmp_v27 := pack_in_reg_tmp(26 downto 0);
                bout_cnt(ib) <= SLV_TO_INT(SLV=>tmp_v27);
               elsif (reg_addr(ib) = "01000"  and  csbo_cnt(ib)  =  0  ) then
                cmd_rd_flag(ib) <= '0';
                cmd_wr_flag(ib) <= '0';
                conti_data_flag(ib) <= '0';
                conti_data_cnt(ib) <= 0;
                tmp_v27 := pack_in_reg_tmp(26 downto 0);
                csbo_cnt(ib) <= SLV_TO_INT(SLV=>tmp_v27);
               end if;
             elsif (pack_in_reg_tmp(31 downto 29)  =  "001") then
                if (pack_in_reg_tmp(28 downto 27)  =  "01"  and  downcont_cnt  =  0) then
                    if (pack_in_reg_tmp(10 downto 0)  /=  "00000000000") then
                       cmd_rd_flag(ib) <= '1';
                       cmd_wr_flag(ib) <= '0';
                       rd_data_cnt(ib) <= 4;
                       conti_data_cnt(ib) <= 0;
                       conti_data_flag(ib) <= '0';
                       rd_reg_addr(ib) <= pack_in_reg_tmp(17 downto 13);
                    end if;
                elsif (pack_in_reg_tmp(28 downto 27)  =  "10"  and  downcont_cnt  =
 0) then
                   if (pack_in_reg_tmp(17 downto 13)  =  "01111")   then
                           csob_reg(ib) <= pack_in_reg(ib);
                           csbo_cnt(ib) <= SLV_TO_INT(SLV=>pack_in_reg_tmp(10 downto 0));
                           csbo_flag(ib) <= '1';
                           conti_data_flag(ib) <= '0';
                           reg_addr(ib) <= pack_in_reg_tmp(17 downto 13);
                           cmd_wr_flag(ib) <= '1';
                           conti_data_cnt(ib) <= 0;
                    else 
                      if (pack_in_reg_tmp(10 downto 0)  /=  "00000000000") then
                       cmd_rd_flag(ib) <= '0';
                       cmd_wr_flag(ib) <= '1';
                       conti_data_flag(ib) <= '1';
                       tmp_v11 := pack_in_reg_tmp(10 downto 0);
                       conti_data_cnt(ib) <= SLV_TO_INT(SLV=>tmp_v11);
                       reg_addr(ib) <= pack_in_reg_tmp(17 downto 13);
                      else
                       cmd_rd_flag(ib) <= '0';
                       cmd_wr_flag(ib) <= '1';
                       conti_data_flag(ib) <= '0';
                       conti_data_cnt(ib) <= 0;
                       reg_addr(ib) <= pack_in_reg_tmp(17 downto 13);
                      end if;
                    end if;
                else
                    cmd_wr_flag(ib) <= '0';
                    conti_data_flag(ib) <= '0';
                    conti_data_cnt(ib) <= 0;
                end if;
             end if;
--             cmd_reg_new_flag(ib) <= '0';
--             crc_ck(ib) <= '0';
          end  if;  -- if (conti_data_flag  =  '0' )
          if (csbo_cnt(ib)  /=  0 ) then
             if (csbo_flag(ib)  =  '1') then
              csbo_cnt(ib) <= csbo_cnt(ib) - 1;
             end if;
          else
              csbo_flag(ib) <= '0';
          end if;

          if (bout_cnt(0)  /=  0   and  bout_flag(0)  =  '1') then
             if (bout_cnt(0)   =  1) then
                bout_cnt(0) <= 0;
                bout_flag(0) <= '0';
             else
                bout_cnt(0) <= bout_cnt(0) - 1;
             end if;
          end if;

          if (bout_cnt(1)  /=  0   and  bout_flag(1)  =  '1') then
             if (bout_cnt(1)   =  1) then
                bout_cnt(1) <= 0;
                bout_flag(1) <= '0';
             else
                bout_cnt(1) <= bout_cnt(1) - 1;
             end if;
          end if;

          if (bout_cnt(2)  /=  0   and  bout_flag(2)  =  '1') then
             if (bout_cnt(2)   =  1) then
                bout_cnt(2) <= 0;
                bout_flag(2) <= '0';
             else
                bout_cnt(2) <= bout_cnt(2) - 1;
             end if;
          end if;

          if (bout_cnt(3)  /=  0   and  bout_flag(3)  =  '1') then
             if (bout_cnt(3)   =  1) then
                bout_cnt(3) <= 0;
                bout_flag(3) <= '0';
             else
                bout_cnt(3) <= bout_cnt(3) - 1;
             end if;
          end if;

          if (conti_data_cnt(ib)  =  1 )  then
                conti_data_flag(ib) <= '0';
          end if;

          if (crc_ck(ib) = '1' or icap_init_done = '1') then
              crc_ck(ib) <= '0';
          end if;

      end if;
      if (rw_en(ib)  = '1' and csi_b_ins = '0') then
         if (rd_data_cnt(ib)  =  1 and  rd_flag(ib)  =  '1')  then
            rd_data_cnt(ib) <= 0;
         elsif (rd_data_cnt(ib)  =  0  and  rd_flag(ib)  =  '1') then
               cmd_rd_flag(ib) <= '0';
         elsif (cmd_rd_flag(ib)  = '1'   and  rd_flag(ib)  =  '1') then
             rd_data_cnt(ib) <= rd_data_cnt(ib) - 1;
         end if;

          if (downcont_cnt >= 1 and conti_data_flag(ib) = '0' and new_data_in_flag(ib) = '1' and wr_flag(ib) = '1') then
              downcont_cnt <= downcont_cnt - 1;
          end if;
      end if;

     if (crc_ck(ib) = '1' or icap_init_done = '1') then
         crc_ck(ib) <= '0';
     end if;

      if (cmd_reg_new_flag(ib)  =  '1') then
          cmd_reg_new_flag(ib) <= '0';
      end if;
    end if;
    end  process;


   ib_proc : process (bout_flag) begin
     if (bout_flag(3)  =  '1') then
       ib <= 3;
       ib_skp <= 1;
     elsif (bout_flag(2)  =  '1') then
       ib <= 3;
       ib_skp <= 0;
     elsif (bout_flag(1)  =  '1') then
       ib <= 2;
       ib_skp <= 0;
     elsif (bout_flag(0)  =  '1') then
       ib <= 1;
       ib_skp <= 0;
     else 
       ib <= 0;
       ib_skp <= 0;
     end if;
   end process;

   rd_back_p : process ( cclk_in, rst_intl)
     variable outbus1 : std_logic_vector(31 downto 0);
     variable tmp_reg : std_logic_vector(31 downto 0);
   begin
    if (rst_intl  = '0') then
         outbus <= X"00000000";
    elsif (rising_edge(cclk_in)) then
        if (cmd_rd_flag(ib)  =  '1'  and  rdwr_b_in  =  '1')
then
               case (rd_reg_addr(ib)) is
               when "00000" => if (buswidth(ib)  =  "01") then
                             rdbk_byte(crc_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(crc_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11")  then
                             rdbk_2wd(crc_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "00001" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(far_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(far_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(far_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "00011" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(fdro_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(fdro_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(fdro_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "00100" => tmp_reg := ("000000000000000000000000000" & cmd_reg(ib));
                          if (buswidth(ib)  =  "01") then
                             rdbk_byte(tmp_reg, rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(tmp_reg, rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(tmp_reg, rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "00101" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(ctl0_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(ctl0_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(ctl0_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "00110" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(mask_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(mask_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(mask_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "00111" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(stat_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(stat_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(stat_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "01001" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(cor0_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(cor0_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(cor0_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "01100" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(idcode_reg1(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(idcode_reg1(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(idcode_reg1(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "01101" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(axss_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(axss_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(axss_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "01110" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(cor1_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(cor1_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(cor1_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "10000" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(wbstar_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(wbstar_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(wbstar_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "10001" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(timer_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(timer_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(timer_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "10010" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(rbcrc_hw_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(rbcrc_hw_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(rbcrc_hw_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "10011" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(rbcrc_sw_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(rbcrc_sw_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(rbcrc_sw_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "10100" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(rbcrc_live_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(rbcrc_live_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(rbcrc_live_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "10101" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(efar_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(efar_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(efar_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "10110" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(bootsts_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(bootsts_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(bootsts_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "11000" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(ctl1_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(ctl1_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(ctl1_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "11001" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(memrd_param_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(memrd_param_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(memrd_param_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "11010" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(dwc_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(dwc_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(dwc_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "11011" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(trim_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(trim_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(trim_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;
               when "11111" =>  if (buswidth(ib)  =  "01") then
                             rdbk_byte(bspi_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "10") then
                             rdbk_wd(bspi_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          elsif (buswidth(ib)  =  "11") then
                             rdbk_2wd(bspi_reg(ib), rd_data_cnt(ib), outbus1);
                             outbus <= outbus1;
                          end if;

               when others => NULL;
               end case;
               if (ib /= 0) then
                  if (rd_data_cnt(ib) = 1) then
                     rd_desynch_tmp <= '1';
                  end if;
               end if;
       else
             outbus <= X"00000000";
             rd_desynch <= rd_desynch_tmp;
             rd_desynch_tmp <= '0';
       end if;
    end if;
   end process;

        
     crc_rst(0) <= crc_reset(0)  or   not rst_intl;
     crc_rst(1) <= crc_reset(1)  or   not rst_intl;
     crc_rst(2) <= crc_reset(2)  or   not rst_intl;
     crc_rst(3) <= crc_reset(3)  or   not rst_intl;

    process ( cclk_in,  crc_rst(0) ) begin
     if (crc_rst(0) = '1') then
         crc_err_flag(0) <= '0';
         crc_ck_en(0) <= '1';
     elsif (rising_edge(cclk_in)) then
        if (crc_ck(0) = '1' and crc_ck_en(0) = '1') then
            if (crc_curr(0)  /=  crc_reg(0))  then
                crc_err_flag(0) <= '1';
            else
                 crc_err_flag(0) <= '0';
            end if;
            crc_ck_en(0) <= '0';
       else
           crc_err_flag(0) <= '0';
           crc_ck_en(0) <= '1';
       end if;
    end if;
    end process;

    process ( cclk_in,  crc_rst(1) ) begin
     if (crc_rst(1) = '1') then
         crc_err_flag(1) <= '0';
         crc_ck_en(1) <= '1';
     elsif (rising_edge(cclk_in)) then
        if (crc_ck(1) = '1' and crc_ck_en(1) = '1') then
            if (crc_curr(1)  /=  crc_reg(1))  then
                crc_err_flag(1) <= '1';
            else
                 crc_err_flag(1) <= '0';
            end if;
            crc_ck_en(1) <= '0';
       else
           crc_err_flag(1) <= '0';
           crc_ck_en(1) <= '1';
       end if;
    end if;
    end process;

    process ( cclk_in,  crc_rst(2) ) begin
     if (crc_rst(2) = '1') then
         crc_err_flag(2) <= '0';
         crc_ck_en(2) <= '1';
     elsif (rising_edge(cclk_in)) then
        if (crc_ck(2) = '1' and crc_ck_en(2) = '1') then
            if (crc_curr(2)  /=  crc_reg(2))  then
                crc_err_flag(2) <= '1';
            else
                 crc_err_flag(2) <= '0';
            end if;
            crc_ck_en(2) <= '0';
       else
           crc_err_flag(2) <= '0';
           crc_ck_en(2) <= '1';
       end if;
    end if;
    end process;

    process ( cclk_in,  crc_rst(3) ) begin
     if (crc_rst(3) = '1') then
         crc_err_flag(3) <= '0';
         crc_ck_en(3) <= '1';
     elsif (rising_edge(cclk_in)) then
        if (crc_ck(3) = '1' and crc_ck_en(3) = '1') then
            if (crc_curr(3)  /=  crc_reg(3))  then
                crc_err_flag(3) <= '1';
            else
                 crc_err_flag(3) <= '0';
            end if;
            crc_ck_en(3) <= '0';
       else
           crc_err_flag(3) <= '0';
           crc_ck_en(3) <= '1';
       end if;
    end if;
    end process;


    process ( crc_err_flag(0),  rst_intl,  bus_sync_flag(0)) begin
     if (rst_intl  =  '0') then
         crc_err_flag_reg(0) <= '0';
     elsif (rising_edge(crc_err_flag(0))) then
         crc_err_flag_reg(0) <= '1';
     elsif (rising_edge(bus_sync_flag(0))) then
         crc_err_flag_reg(0) <= '0';
     end if;
    end process;

    process ( crc_err_flag(1),  rst_intl,  bus_sync_flag(1)) begin
     if (rst_intl  =  '0') then
         crc_err_flag_reg(1) <= '0';
     elsif (rising_edge(crc_err_flag(1))) then
         crc_err_flag_reg(1) <= '1';
     elsif (rising_edge(bus_sync_flag(1))) then
         crc_err_flag_reg(1) <= '0';
     end if;
    end process;

    process ( crc_err_flag(2),  rst_intl,  bus_sync_flag(2)) begin
     if (rst_intl  =  '0') then
         crc_err_flag_reg(2) <= '0';
     elsif (rising_edge(crc_err_flag(2))) then
         crc_err_flag_reg(2) <= '1';
     elsif (rising_edge(bus_sync_flag(2))) then
         crc_err_flag_reg(2) <= '0';
     end if;
    end process;

    process ( crc_err_flag(3),  rst_intl,  bus_sync_flag(3)) begin
     if (rst_intl  =  '0') then
         crc_err_flag_reg(3) <= '0';
     elsif (rising_edge(crc_err_flag(3))) then
         crc_err_flag_reg(3) <= '1';
     elsif (rising_edge(bus_sync_flag(3))) then
         crc_err_flag_reg(3) <= '0';
     end if;
    end process;


    process (cclk_in, rst_intl) begin
    if (rst_intl  = '0') then
         startup_set <= "0000";
         crc_reset  <= "0000";
         gsr_cmd_out <= "0000";
         shutdown_set <= "0000";
         desynch_set <= "0000";
         ghigh_b <= "0000";
    elsif (rising_edge(cclk_in)) then
    for dsi in 3 downto 0 loop
     if (cmd_reg_new_flag(dsi)  = '1') then
      if (cmd_reg(dsi)  =  "00011")  then
          ghigh_b(dsi) <= '1';
      elsif (cmd_reg(dsi)  =  "01000") then
           ghigh_b(dsi) <= '0';
      end if;

      if (cmd_reg(dsi)  =  "00101") then
           startup_set(dsi) <= '1';
      end if;

     if (cmd_reg(dsi)  =  "00111")  then
           crc_reset(dsi) <= '1';
      end if;

      if (cmd_reg(dsi)  =  "01010")  then
           gsr_cmd_out(dsi) <= '1';
      end if;

      if (cmd_reg(dsi)  =  "01011") then
           shutdown_set(dsi) <= '1';
      end if;

      if (cmd_reg(dsi)  =  "01101")  then
           desynch_set(dsi) <= '1';
      end if;


      if (cmd_reg(dsi)  =  "01111") then
          iprog_b(dsi) <= '0';
          i_init_b_cmd(dsi) <= '0';
          iprog_b(dsi) <= '1' after cfg_Tprog;
          i_init_b_cmd(dsi) <= '1' after (cfg_Tprog + cfg_Tpl);
      end if;
    else
             startup_set(dsi) <= '0';
              crc_reset(dsi) <= '0';
              gsr_cmd_out(dsi) <= '0';
              shutdown_set(dsi) <= '0';
              desynch_set(dsi) <= '0';
    end if;
    end loop;
   end if;
   end process;

   startup_set_pulse_p0 : process  begin
    if (rw_en(0)  =  '1') then
    if (rising_edge(startup_set(0))) then
      if (startup_set_pulse0  =  "00") then
         if (icap_on = '0') then
            startup_set_pulse0 <= "01";
         else
            startup_set_pulse0 <= "11";
            wait until (rising_edge(cclk_in ));
            startup_set_pulse0 <= "00";
         end if;
      end if;
    elsif (rising_edge(desynch_set(0)) ) then
      if (startup_set_pulse0  =  "01") then
          startup_set_pulse0 <= "11";
          wait until (rising_edge(cclk_in ));
          startup_set_pulse0 <= "00";
       end if;
    end if;
    end if;
      wait on startup_set(0), desynch_set(0), rw_en(0);
    end process;

   startup_set_pulse_p1 : process  begin
    if (rw_en(1)  =  '1') then
    if (rising_edge(startup_set(1))) then
      if (startup_set_pulse1  =  "00") then
         if (icap_on = '0') then
            startup_set_pulse1 <= "01";
         else
            startup_set_pulse1 <= "11";
            wait until (rising_edge(cclk_in ));
            startup_set_pulse1 <= "00";
         end if;
      end if;
    elsif (rising_edge(desynch_set(1)) ) then
      if (startup_set_pulse1  =  "01") then
          startup_set_pulse1 <= "11";
          wait until (rising_edge(cclk_in ));
          startup_set_pulse1 <= "00";
       end if;
    end if;
    end if;
      wait on startup_set(1), desynch_set(1), rw_en(1);
    end process;

   startup_set_pulse_p2 : process  begin
    if (rw_en(2)  =  '1') then
    if (rising_edge(startup_set(2))) then
      if (startup_set_pulse2  =  "00") then
         if (icap_on = '0') then
            startup_set_pulse2 <= "01";
         else
            startup_set_pulse2 <= "11";
            wait until (rising_edge(cclk_in ));
            startup_set_pulse2 <= "00";
         end if;
      end if;
    elsif (rising_edge(desynch_set(2)) ) then
      if (startup_set_pulse2  =  "01") then
          startup_set_pulse2 <= "11";
          wait until (rising_edge(cclk_in ));
          startup_set_pulse2 <= "00";
       end if;
    end if;
    end if;
      wait on startup_set(2), desynch_set(2), rw_en(2);
    end process;

   startup_set_pulse_p3 : process  begin
    if (rw_en(3)  =  '1') then
    if (rising_edge(startup_set(3))) then
      if (startup_set_pulse3  =  "00") then
         if (icap_on = '0') then
            startup_set_pulse3 <= "01";
         else
            startup_set_pulse3 <= "11";
            wait until (rising_edge(cclk_in ));
            startup_set_pulse3 <= "00";
         end if;
      end if;
    elsif (rising_edge(desynch_set(3)) ) then
      if (startup_set_pulse3  =  "01") then
          startup_set_pulse3 <= "11";
          wait until (rising_edge(cclk_in ));
          startup_set_pulse3 <= "00";
       end if;
    end if;
    end if;
      wait on startup_set(3), desynch_set(3), rw_en(3) ;
    end process;

   gsr_cmd_out_pulse_p0 :  process  begin
    if (rw_en(0)  =  '0') then
       gsr_cmd_out_pulse(0) <= '0';
    elsif (rising_edge(gsr_cmd_out(0))) then
       gsr_cmd_out_pulse(0) <= '1';
       wait until (rising_edge(cclk_in ));
       wait until (rising_edge(cclk_in ));
       gsr_cmd_out_pulse(0) <=  '0';
   end if;
      wait on gsr_cmd_out(0), rw_en(0);
   end process;

   gsr_cmd_out_pulse_p1 :  process  begin
    if (rw_en(1)  =  '0') then
       gsr_cmd_out_pulse(1) <= '0';
    elsif (rising_edge(gsr_cmd_out(1))) then
       gsr_cmd_out_pulse(1) <= '1';
       wait until (rising_edge(cclk_in ));
       wait until (rising_edge(cclk_in ));
       gsr_cmd_out_pulse(1) <=  '0';
   end if;
      wait on gsr_cmd_out(1), rw_en(1);
   end process;

   gsr_cmd_out_pulse_p2 :  process  begin
    if (rw_en(2)  =  '0') then
       gsr_cmd_out_pulse(2) <= '0';
    elsif (rising_edge(gsr_cmd_out(2))) then
       gsr_cmd_out_pulse(2) <= '1';
       wait until (rising_edge(cclk_in ));
       wait until (rising_edge(cclk_in ));
       gsr_cmd_out_pulse(2) <=  '0';
   end if;
      wait on gsr_cmd_out(2), rw_en(2);
   end process;

   gsr_cmd_out_pulse_p3 :  process  begin
    if (rw_en(3)  =  '0') then
       gsr_cmd_out_pulse(3) <= '0';
    elsif (rising_edge(gsr_cmd_out(3))) then
       gsr_cmd_out_pulse(3) <= '1';
       wait until (rising_edge(cclk_in ));
       wait until (rising_edge(cclk_in ));
       gsr_cmd_out_pulse(3) <=  '0';
   end if;
      wait on gsr_cmd_out(3), rw_en(3);
   end process;


   ctl0_reg_tmp0 <= ctl0_reg(0);
   ctl0_reg_tmp1 <= ctl0_reg(1);
   ctl0_reg_tmp2 <= ctl0_reg(2);
   ctl0_reg_tmp3 <= ctl0_reg(3);

    process (ctl0_reg_tmp0) begin
      if (ctl0_reg_tmp0(9)  =  '1') then
         abort_dis(0) <= '1';
      else
         abort_dis(0) <= '0';
      end if;
      if (ctl0_reg_tmp0(3)  =  '1') then
         persist_en(0) <= '1';
      else
         persist_en(0) <= '0';
      end if;
      if (ctl0_reg_tmp0(0)  =  '1') then
         gts_usr_b(0) <= '1';
      else
         gts_usr_b(0) <= '0';
      end if;
    end process;

    process (ctl0_reg_tmp1) begin
      if (ctl0_reg_tmp1(9)  =  '1') then
         abort_dis(1) <= '1';
      else
         abort_dis(1) <= '0';
      end if;
      if (ctl0_reg_tmp1(3)  =  '1') then
         persist_en(1) <= '1';
      else
         persist_en(1) <= '0';
      end if;
      if (ctl0_reg_tmp1(0)  =  '1') then
         gts_usr_b(1) <= '1';
      else
         gts_usr_b(1) <= '0';
      end if;
    end process;

    process (ctl0_reg_tmp2) begin
      if (ctl0_reg_tmp2(9)  =  '1') then
         abort_dis(2) <= '1';
      else
         abort_dis(2) <= '0';
      end if;
      if (ctl0_reg_tmp2(3)  =  '1') then
         persist_en(2) <= '1';
      else
         persist_en(2) <= '0';
      end if;
      if (ctl0_reg_tmp2(0)  =  '1') then
         gts_usr_b(2) <= '1';
      else
         gts_usr_b(2) <= '0';
      end if;
    end process;

    process (ctl0_reg_tmp3) begin
      if (ctl0_reg_tmp3(9)  =  '1') then
         abort_dis(3) <= '1';
      else
         abort_dis(3) <= '0';
      end if;
      if (ctl0_reg_tmp3(3)  =  '1') then
         persist_en(3) <= '1';
      else
         persist_en(3) <= '0';
      end if;
      if (ctl0_reg_tmp3(0)  =  '1') then
         gts_usr_b(3) <= '1';
      else
         gts_usr_b(3) <= '0';
      end if;
    end process;

    cor0_reg_tmp0 <= cor0_reg(0);
    cor0_reg_tmp1 <= cor0_reg(1);
    cor0_reg_tmp2 <= cor0_reg(2);
    cor0_reg_tmp3 <= cor0_reg(3);

    process (cor0_reg_tmp0)
    begin
      done_cycle_reg0 <= cor0_reg_tmp0(14 downto 12);
      lock_cycle_reg0 <= cor0_reg_tmp0(8 downto 6);
      gts_cycle_reg0 <= cor0_reg_tmp0(5 downto 3);
      gwe_cycle_reg0 <= cor0_reg_tmp0(2 downto 0);

     if (cor0_reg_tmp0(24)  =  '1') then
         done_pin_drv(0) <= '1';
      else
         done_pin_drv(0) <= '0';
      end if;
      if (cor0_reg_tmp0(28)  =  '1') then
         crc_bypass(0) <= '1';
      else
         crc_bypass(0) <= '0';
      end if;
    end process;

    process (cor0_reg_tmp1)
    begin
      done_cycle_reg1 <= cor0_reg_tmp1(14 downto 12);
      lock_cycle_reg1 <= cor0_reg_tmp1(8 downto 6);
      gts_cycle_reg1 <= cor0_reg_tmp1(5 downto 3);
      gwe_cycle_reg1 <= cor0_reg_tmp1(2 downto 0);

     if (cor0_reg_tmp1(24)  =  '1') then
         done_pin_drv(1) <= '1';
      else
         done_pin_drv(1) <= '0';
      end if;
      if (cor0_reg_tmp1(28)  =  '1') then
         crc_bypass(1) <= '1';
      else
         crc_bypass(1) <= '0';
      end if;
    end process;

    process (cor0_reg_tmp2)
    begin
      done_cycle_reg2 <= cor0_reg_tmp2(14 downto 12);
      lock_cycle_reg2 <= cor0_reg_tmp2(8 downto 6);
      gts_cycle_reg2 <= cor0_reg_tmp2(5 downto 3);
      gwe_cycle_reg2 <= cor0_reg_tmp2(2 downto 0);

     if (cor0_reg_tmp2(24)  =  '1') then
         done_pin_drv(2) <= '1';
      else
         done_pin_drv(2) <= '0';
      end if;
      if (cor0_reg_tmp2(28)  =  '1') then
         crc_bypass(2) <= '1';
      else
         crc_bypass(2) <= '0';
      end if;
    end process;

    process (cor0_reg_tmp3)
    begin
      done_cycle_reg3 <= cor0_reg_tmp3(14 downto 12);
      lock_cycle_reg3 <= cor0_reg_tmp3(8 downto 6);
      gts_cycle_reg3 <= cor0_reg_tmp3(5 downto 3);
      gwe_cycle_reg3 <= cor0_reg_tmp3(2 downto 0);

     if (cor0_reg_tmp3(24)  =  '1') then
         done_pin_drv(3) <= '1';
      else
         done_pin_drv(3) <= '0';
      end if;
      if (cor0_reg_tmp3(28)  =  '1') then
         crc_bypass(3) <= '1';
      else
         crc_bypass(3) <= '0';
      end if;
    end process;

    cor1_reg_tmp0 <= cor1_reg(0);
    cor1_reg_tmp1 <= cor1_reg(1);
    cor1_reg_tmp2 <= cor1_reg(2);
    cor1_reg_tmp3 <= cor1_reg(3);

    process (cor1_reg_tmp0) begin
       rbcrc_no_pin(0) <= cor1_reg_tmp0(8);
    end process;

    process (cor1_reg_tmp1) begin
       rbcrc_no_pin(1) <= cor1_reg_tmp1(8);
    end process;

    process (cor1_reg_tmp2) begin
       rbcrc_no_pin(2) <= cor1_reg_tmp2(8);
    end process;

    process (cor1_reg_tmp3) begin
       rbcrc_no_pin(3) <= cor1_reg_tmp3(8);
    end process;



     stat_reg_tmp0(31 downto 27) <= "00000";
     stat_reg_tmp1(31 downto 27) <= "00000";
     stat_reg_tmp2(31 downto 27) <= "00000";
     stat_reg_tmp3(31 downto 27) <= "00000";
     stat_reg_tmp0(26 downto 25) <= buswidth(0);
     stat_reg_tmp1(26 downto 25) <= buswidth(0);
     stat_reg_tmp2(26 downto 25) <= buswidth(0);
     stat_reg_tmp3(26 downto 25) <= buswidth(0);
     stat_reg_tmp0(24 downto 21) <= "XXX0";
     stat_reg_tmp1(24 downto 21) <= "XXX0";
     stat_reg_tmp2(24 downto 21) <= "XXX0";
     stat_reg_tmp3(24 downto 21) <= "XXX0";
     stat_reg_tmp0(20 downto 18) <= st_state0;
     stat_reg_tmp1(20 downto 18) <= st_state1;
     stat_reg_tmp2(20 downto 18) <= st_state2;
     stat_reg_tmp3(20 downto 18) <= st_state3;
     stat_reg_tmp0(17 downto 16) <= "00";
     stat_reg_tmp1(17 downto 16) <= "00";
     stat_reg_tmp2(17 downto 16) <= "00";
     stat_reg_tmp3(17 downto 16) <= "00";
     stat_reg_tmp0(15) <= id_error_flag(0);
     stat_reg_tmp1(15) <= id_error_flag(1);
     stat_reg_tmp2(15) <= id_error_flag(2);
     stat_reg_tmp3(15) <= id_error_flag(3);
     stat_reg_tmp0(14) <= DONE;
     stat_reg_tmp1(14) <= DONE;
     stat_reg_tmp2(14) <= DONE;
     stat_reg_tmp3(14) <= DONE;
     stat_reg_tmp0(13) <= '1' when (done_o(0) /=  '0') else '0';
     stat_reg_tmp1(13) <= '1' when (done_o(1) /=  '0') else '0';
     stat_reg_tmp2(13) <= '1' when (done_o(2) /=  '0') else '0';
     stat_reg_tmp3(13) <= '1' when (done_o(3) /=  '0') else '0';
     stat_reg_tmp0(12) <= INITB;
     stat_reg_tmp1(12) <= INITB;
     stat_reg_tmp2(12) <= INITB;
     stat_reg_tmp3(12) <= INITB;
     stat_reg_tmp0(11) <= mode_sample_flag;
     stat_reg_tmp1(11) <= mode_sample_flag;
     stat_reg_tmp2(11) <= mode_sample_flag;
     stat_reg_tmp3(11) <= mode_sample_flag;
     stat_reg_tmp0(10 downto 8) <= mode_pin_in;
     stat_reg_tmp1(10 downto 8) <= mode_pin_in;
     stat_reg_tmp2(10 downto 8) <= mode_pin_in;
     stat_reg_tmp3(10 downto 8) <= mode_pin_in;
     stat_reg_tmp0(7) <= ghigh_b(0);
     stat_reg_tmp1(7) <= ghigh_b(1);
     stat_reg_tmp2(7) <= ghigh_b(2);
     stat_reg_tmp3(7) <= ghigh_b(3);
     stat_reg_tmp0(6) <= gwe_out(0);
     stat_reg_tmp1(6) <= gwe_out(1);
     stat_reg_tmp2(6) <= gwe_out(2);
     stat_reg_tmp3(6) <= gwe_out(3);
     stat_reg_tmp0(5) <= gts_cfg_b(0);
     stat_reg_tmp1(5) <= gts_cfg_b(1);
     stat_reg_tmp2(5) <= gts_cfg_b(2);
     stat_reg_tmp3(5) <= gts_cfg_b(3);
     stat_reg_tmp0(4) <= eos_startup(0);
     stat_reg_tmp1(4) <= eos_startup(1);
     stat_reg_tmp2(4) <= eos_startup(2);
     stat_reg_tmp3(4) <= eos_startup(3);
     stat_reg_tmp0(3) <= '1';
     stat_reg_tmp1(3) <= '1';
     stat_reg_tmp2(3) <= '1';
     stat_reg_tmp3(3) <= '1';
     stat_reg_tmp0(2) <= pll_locked;
     stat_reg_tmp1(2) <= pll_locked;
     stat_reg_tmp2(2) <= pll_locked;
     stat_reg_tmp3(2) <= pll_locked;
     stat_reg_tmp0(1) <= '0';
     stat_reg_tmp1(1) <= '0';
     stat_reg_tmp2(1) <= '0';
     stat_reg_tmp3(1) <= '0';
     stat_reg_tmp0(0) <= crc_err_flag_reg(0);
     stat_reg_tmp1(0) <= crc_err_flag_reg(1);
     stat_reg_tmp2(0) <= crc_err_flag_reg(2);
     stat_reg_tmp3(0) <= crc_err_flag_reg(3);


     stat_reg(0) <= stat_reg_tmp0;
     stat_reg(1) <= stat_reg_tmp0;
     stat_reg(2) <= stat_reg_tmp0;
     stat_reg(3) <= stat_reg_tmp0;

    st_state_p : process ( cclk_in, rst_intl) begin
      if (rst_intl  =  '0') then
        st_state0 <= STARTUP_PH0;
        st_state1 <= STARTUP_PH0;
        st_state2 <= STARTUP_PH0;
        st_state3 <= STARTUP_PH0;
        startup_begin_flag0 <= '0';
        startup_begin_flag1 <= '0';
        startup_begin_flag2 <= '0';
        startup_begin_flag3 <= '0';
        startup_end_flag0 <= '0';
        startup_end_flag1 <= '0';
        startup_end_flag2 <= '0';
        startup_end_flag3 <= '0';
      elsif (rising_edge(cclk_in)) then
           if (nx_st_state0  =  STARTUP_PH1) then
              startup_begin_flag0 <= '1';
              startup_end_flag0 <= '0';
           elsif (st_state0  =  STARTUP_PH7) then
              startup_end_flag0 <= '1';
              startup_begin_flag0 <= '0';
           end if;
           if  ((lock_cycle_reg0 = "111") or (pll_locked  =  '1') or (st_state0 /= lock_cycle_reg0 and pll_locked  =  '0')) then
                st_state0 <= nx_st_state0;
           else
              st_state0 <= st_state0;
           end if;

           if (nx_st_state1  =  STARTUP_PH1) then
              startup_begin_flag1 <= '1';
              startup_end_flag1 <= '0';
           elsif (st_state1  =  STARTUP_PH7) then
              startup_end_flag1 <= '1';
              startup_begin_flag1 <= '0';
           end if;
           if  ((lock_cycle_reg1 = "111") or (pll_locked  =  '1') or (st_state1 /= lock_cycle_reg1 and pll_locked  =  '0')) then
                st_state1 <= nx_st_state1;
           else
              st_state1 <= st_state1;
           end if;

           if (nx_st_state2  =  STARTUP_PH1) then
              startup_begin_flag2 <= '1';
              startup_end_flag2 <= '0';
           elsif (st_state2  =  STARTUP_PH7) then
              startup_end_flag2 <= '1';
              startup_begin_flag2 <= '0';
           end if;
           if  ((lock_cycle_reg2 = "111") or (pll_locked  =  '1') or (st_state2 /= lock_cycle_reg2 and pll_locked  =  '0')) then
                st_state2 <= nx_st_state2;
           else
              st_state2 <= st_state2;
           end if;

           if (nx_st_state3  =  STARTUP_PH1) then
              startup_begin_flag3 <= '1';
              startup_end_flag3 <= '0';
           elsif (st_state3  =  STARTUP_PH7) then
              startup_end_flag3 <= '1';
              startup_begin_flag3 <= '0';
           end if;
           if  ((lock_cycle_reg3 = "111") or (pll_locked  =  '1') or (st_state3 /= lock_cycle_reg3 and pll_locked  =  '0')) then
                st_state3 <= nx_st_state3;
           else
              st_state3 <= st_state3;
           end if;

      end if;
     end process;

    nx_st_state_p0 : process (st_state0, startup_set_pulse0, done_in ) begin
    if ((( st_state0 =  done_cycle_reg0) and (done_in /= '0')) or ( st_state0 /= done_cycle_reg0)) then
      case (st_state0) is
      when STARTUP_PH0  =>      if (startup_set_pulse0  =  "11" ) then
                                     nx_st_state0 <= STARTUP_PH1;
                                else
                                     nx_st_state0 <= STARTUP_PH0;
                                end if;
      when STARTUP_PH1  =>      nx_st_state0 <= STARTUP_PH2;
      when STARTUP_PH2  =>      nx_st_state0 <= STARTUP_PH3;
      when STARTUP_PH3  =>      nx_st_state0 <= STARTUP_PH4;
      when STARTUP_PH4  =>      nx_st_state0 <= STARTUP_PH5;
      when STARTUP_PH5  =>      nx_st_state0 <= STARTUP_PH6;
      when STARTUP_PH6  =>      nx_st_state0 <= STARTUP_PH7;
      when STARTUP_PH7  =>      nx_st_state0 <= STARTUP_PH0;
      when others => NULL;
      end case;
   end if;
   end process;

    nx_st_state_p1 : process (st_state1, startup_set_pulse1, done_in ) begin
    if ((( st_state1 =  done_cycle_reg1) and (done_in /= '0')) or ( st_state1 /= done_cycle_reg1)) then
      case (st_state1) is
      when STARTUP_PH0  =>      if (startup_set_pulse1  =  "11" ) then
                                     nx_st_state1 <= STARTUP_PH1;
                                else
                                     nx_st_state1 <= STARTUP_PH0;
                                end if;
      when STARTUP_PH1  =>      nx_st_state1 <= STARTUP_PH2;
      when STARTUP_PH2  =>      nx_st_state1 <= STARTUP_PH3;
      when STARTUP_PH3  =>      nx_st_state1 <= STARTUP_PH4;
      when STARTUP_PH4  =>      nx_st_state1 <= STARTUP_PH5;
      when STARTUP_PH5  =>      nx_st_state1 <= STARTUP_PH6;
      when STARTUP_PH6  =>      nx_st_state1 <= STARTUP_PH7;
      when STARTUP_PH7  =>      nx_st_state1 <= STARTUP_PH0;
      when others => NULL;
      end case;
   end if;
   end process;

    nx_st_state_p2 : process (st_state2, startup_set_pulse2, done_in ) begin
    if ((( st_state2 =  done_cycle_reg2) and (done_in /= '0')) or ( st_state2 /= done_cycle_reg2)) then
      case (st_state2) is
      when STARTUP_PH0  =>      if (startup_set_pulse2  =  "11" ) then
                                     nx_st_state2 <= STARTUP_PH1;
                                else
                                     nx_st_state2 <= STARTUP_PH0;
                                end if;
      when STARTUP_PH1  =>      nx_st_state2 <= STARTUP_PH2;
      when STARTUP_PH2  =>      nx_st_state2 <= STARTUP_PH3;
      when STARTUP_PH3  =>      nx_st_state2 <= STARTUP_PH4;
      when STARTUP_PH4  =>      nx_st_state2 <= STARTUP_PH5;
      when STARTUP_PH5  =>      nx_st_state2 <= STARTUP_PH6;
      when STARTUP_PH6  =>      nx_st_state2 <= STARTUP_PH7;
      when STARTUP_PH7  =>      nx_st_state2 <= STARTUP_PH0;
      when others => NULL;
      end case;
   end if;
   end process;

    nx_st_state_p3 : process (st_state3, startup_set_pulse3, done_in ) begin
    if ((( st_state3 =  done_cycle_reg3) and (done_in /= '0')) or ( st_state3 /= done_cycle_reg3)) then
      case (st_state3) is
      when STARTUP_PH0  =>      if (startup_set_pulse3  =  "11" ) then
                                     nx_st_state3 <= STARTUP_PH1;
                                else
                                     nx_st_state3 <= STARTUP_PH0;
                                end if;
      when STARTUP_PH1  =>      nx_st_state3 <= STARTUP_PH2;
      when STARTUP_PH2  =>      nx_st_state3 <= STARTUP_PH3;
      when STARTUP_PH3  =>      nx_st_state3 <= STARTUP_PH4;
      when STARTUP_PH4  =>      nx_st_state3 <= STARTUP_PH5;
      when STARTUP_PH5  =>      nx_st_state3 <= STARTUP_PH6;
      when STARTUP_PH6  =>      nx_st_state3 <= STARTUP_PH7;
      when STARTUP_PH7  =>      nx_st_state3 <= STARTUP_PH0;
      when others => NULL;
      end case;
   end if;
   end process;


    start_out_p : process ( cclk_in, rst_intl ) begin
      if (rst_intl  =  '0') then
          gwe_out <= "0000";
          gts_out <= "1111";
          eos_startup <= "0000";
          gsr_st_out <= "1111";
          done_o <= "0000";
      elsif (rising_edge(cclk_in)) then
        if (nx_st_state0 = done_cycle_reg0 or st_state0 = done_cycle_reg0) then
            if (done_in  /=  '0' or done_pin_drv(0) = '1') then
               done_o(0) <= '1';
            else
               done_o(0) <= 'H';
            end if;
         end if;
        if (nx_st_state1 = done_cycle_reg1 or st_state1 = done_cycle_reg1) then
            if (done_in  /=  '0' or done_pin_drv(1) = '1') then
               done_o(1) <= '1';
            else
               done_o(1) <= 'H';
            end if;
         end if;
        if (nx_st_state2 = done_cycle_reg2 or st_state2 = done_cycle_reg2) then
            if (done_in  /=  '0' or done_pin_drv(2) = '1') then
               done_o(2) <= '1';
            else
               done_o(2) <= 'H';
            end if;
         end if;
        if (nx_st_state3 = done_cycle_reg3 or st_state3 = done_cycle_reg3) then
            if (done_in  /=  '0' or done_pin_drv(3) = '1') then
               done_o(3) <= '1';
            else
               done_o(3) <= 'H';
            end if;
         end if;

         if (st_state0  =  gwe_cycle_reg0  and  DONE  /=  '0')   then
             gwe_out(0) <= '1';
         end if;
         if (st_state1  =  gwe_cycle_reg1  and  DONE  /=  '0')   then
             gwe_out(1) <= '1';
         end if;
         if (st_state2  =  gwe_cycle_reg2  and  DONE  /=  '0')   then
             gwe_out(2) <= '1';
         end if;
         if (st_state3  =  gwe_cycle_reg3  and  DONE  /=  '0')   then
             gwe_out(3) <= '1';
         end if;
         if (st_state0  =  gts_cycle_reg0  and  DONE  /=  '0')   then
             gts_out(0) <= '0';
         end if;
         if (st_state1  =  gts_cycle_reg1  and  DONE  /=  '0')   then
             gts_out(1) <= '0';
         end if;
         if (st_state2  =  gts_cycle_reg2  and  DONE  /=  '0')   then
             gts_out(2) <= '0';
         end if;
         if (st_state3  =  gts_cycle_reg3  and  DONE  /=  '0')   then
             gts_out(3) <= '0';
         end if;
         if (st_state0  =  STARTUP_PH6  and  DONE  /=  '0') then
             gsr_st_out(0) <= '0';
         end if;
         if (st_state1  =  STARTUP_PH6  and  DONE  /=  '0') then
             gsr_st_out(1) <= '0';
         end if;
         if (st_state2  =  STARTUP_PH6  and  DONE  /=  '0') then
             gsr_st_out(2) <= '0';
         end if;
         if (st_state3  =  STARTUP_PH6  and  DONE  /=  '0') then
             gsr_st_out(3) <= '0';
         end if;
         if (st_state0  =  STARTUP_PH7  and  DONE  /=  '0')  then
            eos_startup(0) <= '1';
         end if;
         if (st_state1  =  STARTUP_PH7  and  DONE  /=  '0')  then
            eos_startup(1) <= '1';
         end if;
         if (st_state2  =  STARTUP_PH7  and  DONE  /=  '0')  then
            eos_startup(2) <= '1';
         end if;
         if (st_state3  =  STARTUP_PH7  and  DONE  /=  '0')  then
            eos_startup(3) <= '1';
         end if;
      end if;
    end process;

      gsr_out(0) <= gsr_st_out(0)  or  gsr_cmd_out(0);
      gsr_out(1) <= gsr_st_out(1)  or  gsr_cmd_out(1);
      gsr_out(2) <= gsr_st_out(2)  or  gsr_cmd_out(2);
      gsr_out(3) <= gsr_st_out(3)  or  gsr_cmd_out(3);


    abort_dis_bi <= abort_dis(ib);

    process (cclk_in,  rst_intl, abort_flag_rst , csi_b_in)
    begin
      if (rst_intl = '0'  or  abort_flag_rst = '1'  or  csi_b_in  =  '1') then
          abort_flag(ib) <= '0';
          checka_en <= '0';
          rdwr_b_in1 <= rdwr_b_in;
      elsif (rising_edge(cclk_in)) then
        if (abort_dis_bi  =  '0'  and  csi_b_in  =  '0') then
          if ((rdwr_b_in1 /= rdwr_b_in) and checka_en /= '0') then
             if (NOW  /=  0 ps) then
               abort_flag(ib) <= '1';
               if (icap_on = '0') then
               assert false report " Warning : RDWRB changes when CS_B low, which causes Configuration abort on SIM_CONFIGE2."
               severity warning;
               end if;
             end if;
           end if;
        else
           abort_flag(ib) <= '0';
        end if;
        rdwr_b_in1 <= rdwr_b_in;
        checka_en <= '1';
     end if;
    end process;


    abort_flag_bi <= abort_flag(ib);

    abort_data_p : process
    begin
      if (rising_edge(abort_flag_bi)) then
         abort_out_en <= '1';
         abort_status <= (cfgerr_b_flag(ib) & bus_sync_flag(ib) &  "011111");
         wait until (rising_edge(cclk_in));
         abort_status <= (cfgerr_b_flag(ib) & "1001111");
         wait until (rising_edge(cclk_in));
         abort_status <= (cfgerr_b_flag(ib) & "0001111");
         wait until (rising_edge(cclk_in));
         abort_status <= (cfgerr_b_flag(ib) & "0011111");
         wait until (rising_edge(cclk_in));
         abort_out_en <= '0';
         abort_flag_rst <= '1';
         wait until (rising_edge(cclk_in));
         abort_flag_rst <= '0';
    end if;
    wait on abort_flag_bi, cclk_in;
    end process;

end SIM_CONFIGE2_V;

