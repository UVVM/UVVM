-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/blanc/VITAL/FRAME_ECC_VIRTEX6.vhd,v 1.10 2012/03/30 23:58:21 wloo Exp $
---------------------------------------------------------------------------
--  Copyright (c) 2012 Xilinx Inc.
--  All Right Reserved.
---------------------------------------------------------------------------
--
--   ____  ____
--  /   /\/   / 
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version : 11.1
--  \   \          Description : 
--  /   /                      
-- /___/   /\      Filename    : FRAME_ECC_VIRTEX6.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
-- Revision: 1.0
--  07/22/10 - Change Error to Message for input rbt file check (CR568991)
--             Initial tmpb_i, tmpb_i1, tmpb_v7 (CR569147)
--  08/04/11 - Change FRAME_RBT_IN_FILENAME ot NONE (CR618399)
--  03/30/12 - Fixed out of bound error and ECC error (CR 647366).
-- End Revision

----- CELL FRAME_ECC_VIRTEX6 -----

library IEEE;
--use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library STD;
use STD.TEXTIO.all;


library unisim;
use unisim.VCOMPONENTS.all;
use unisim.VPKG.all;

  entity FRAME_ECC_VIRTEX6 is
    generic (
      FARSRC : string:= "EFAR";
      FRAME_RBT_IN_FILENAME : string := "NONE"
    );

    port (
      CRCERROR             : out std_ulogic;
      ECCERROR             : out std_ulogic;
      ECCERRORSINGLE       : out std_ulogic;
      FAR                  : out std_logic_vector(23 downto 0);
      SYNBIT               : out std_logic_vector(4 downto 0);
      SYNDROME             : out std_logic_vector(12 downto 0);
      SYNDROMEVALID        : out std_ulogic;
      SYNWORD              : out std_logic_vector(6 downto 0)
    );

  end FRAME_ECC_VIRTEX6;

  architecture FRAME_ECC_VIRTEX6_V of FRAME_ECC_VIRTEX6 is
    
 function u_xor (
    in_v : in std_logic_vector ) return std_logic is
    variable u_xor_v : std_logic;
    variable u_xor_v1 : std_logic;
 begin
    u_xor_v := in_v(in_v'high);
    for i in in_v'high - 1 downto in_v'low loop
       u_xor_v1 := u_xor_v xor in_v(i);
       u_xor_v := u_xor_v1;
    end loop;
     return u_xor_v;
 end;

 function u_or (
    in_v : in std_logic_vector ) return std_logic is
    variable u_or_v : std_logic;
    variable u_or_v1 : std_logic;
 begin
    u_or_v := in_v(in_v'high);
    for i in in_v'high - 1 downto in_v'low loop
       u_or_v1 := u_or_v or in_v(i);
       u_or_v := u_or_v1;
    end loop;
     return u_or_v;
 end;

 function u_and (
    in_v : in std_logic_vector ) return std_logic is
    variable u_ad_v : std_logic;
    variable u_ad_v1 : std_logic;
 begin
    u_ad_v := in_v(in_v'high);
    for i in in_v'high - 1 downto in_v'low loop
       u_ad_v1 := u_ad_v and in_v(i);
       u_ad_v := u_ad_v1;
    end loop;
     return u_ad_v;
 end;

 function  crc_next (
   bcc : in std_logic_vector(31 downto 0);
   bcc_in : in std_logic_vector(36 downto 0)
   ) return  std_logic_vector
   is
      variable x : std_logic_vector(31 downto 0);
      variable m : std_logic_vector(36 downto 0);
      variable bcc_next : std_logic_vector(31 downto 0);
  begin

    m := bcc_in;
    x := bcc_in(31 downto 0) xor bcc;

    bcc_next(31) := m(32) xor m(36) xor x(31) xor x(30) xor x(29) xor x(28) xor x(27) xor x(24) xor x(20) xor x(19) xor x(18) xor x(15) xor x(13) xor x(11) xor x(10) xor x(9) xor x(8) xor x(6) xor x(5) xor x(1) xor x(0);
    bcc_next(30) := m(35) xor x(31) xor x(30) xor x(29) xor x(28) xor x(27) xor x(26) xor x(23) xor x(19) xor x(18) xor x(17) xor x(14) xor x(12) xor x(10) xor x(9) xor x(8) xor x(7) xor x(5) xor x(4) xor x(0);
    bcc_next(29) := m(34) xor x(30) xor x(29) xor x(28) xor x(27) xor x(26) xor x(25) xor x(22) xor x(18) xor x(17) xor x(16) xor x(13) xor x(11) xor x(9) xor x(8) xor x(7) xor x(6) xor x(4) xor x(3);
    bcc_next(28) := m(33) xor x(29) xor x(28) xor x(27) xor x(26) xor x(25) xor x(24) xor x(21) xor x(17) xor x(16) xor x(15) xor x(12) xor x(10) xor x(8) xor x(7) xor x(6) xor x(5) xor x(3) xor x(2);
    bcc_next(27) := m(32) xor x(28) xor x(27) xor x(26) xor x(25) xor x(24) xor x(23) xor x(20) xor x(16) xor x(15) xor x(14) xor x(11) xor x(9) xor x(7) xor x(6) xor x(5) xor x(4) xor x(2) xor x(1);
    bcc_next(26) := x(31) xor x(27) xor x(26) xor x(25) xor x(24) xor x(23) xor x(22) xor x(19) xor x(15) xor x(14) xor x(13) xor x(10) xor x(8) xor x(6) xor x(5) xor x(4) xor x(3) xor x(1) xor x(0);
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
    bcc_next(13) := m(36) xor x(30) xor x(28) xor x(26) xor x(25) xor x(23) xor x(22) xor x(20) xor x(18) xor x(17) xor x(16) xor x(15) xor x(9) xor x(8) xor x(7) xor x(6) xor x(5) xor x(3) xor x(2) xor x(1);
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

  constant FRAME_ECC_OUT_RBT_FILENAME : string := "frame_rbt_out_v6.txt";
  constant FRAME_ECC_OUT_ECC_FILENAME : string := "frame_ecc_out_v6.txt";

  signal clk_osc  : std_ulogic :=  '0';
  signal rb_data  : std_logic_vector (31 downto 0) := X"00000000" ; 
  type  frame_data_bak_a is array (255 downto 174)  of std_logic_vector (31 downto 0) ; 
  signal frame_data : frame_data_bak_a; 
  signal frame_addr  : std_logic_vector (31 downto 0) ; 
  signal rb_crc_rbt  : std_logic_vector (31 downto 0) ; 
  signal crc_curr : std_logic_vector (31 downto 0) :=  X"00000000"; 
  signal crc_new : std_logic_vector (31 downto 0) :=  X"00000000";
  signal crc_input : std_logic_vector (36 downto 0) :=  "0000000000000000000000000000000000000";
  signal rbcrc_err  : std_ulogic :=  '0';
  signal rd_rbt_hold  : std_ulogic :=  '0';
  signal rd_rbt_hold1  : std_ulogic :=  '0';
  signal rd_rbt_hold2  : std_ulogic :=  '0';
  signal ecc_wadr  : std_logic_vector (6 downto 0) ; 
  signal ecc_badr  : std_logic_vector (4 downto 0) ; 
  signal corr_wd  : std_logic_vector (31 downto 0) ; 
  signal corr_wd1  : std_logic_vector (31 downto 0) ; 
  signal rb_data_en  : std_ulogic :=  '0';
  signal end_rbt  : std_ulogic :=  '0';
  signal hamming_rst  : std_ulogic :=  '0';
  signal i  : integer :=  0;
  signal bi  : integer :=  174;
  signal nbi  : integer :=  174;
  signal n  : integer :=  174;
  
  signal ecc_run  : std_ulogic :=  '0';
  signal calc_syndrome  : std_ulogic :=  '0';
  signal new_s0_tmp : std_ulogic;
  signal new_s1_tmp : std_ulogic;
  signal new_s2_tmp : std_ulogic;
  signal new_s3_tmp : std_ulogic;
  signal new_S  : std_logic_vector (12 downto 0) ; 
  signal next_S  : std_logic_vector (12 downto 0) ; 
  signal S : std_logic_vector (12 downto 0) :=  "0000000000000";
  signal           S_valid  : std_ulogic :=  '0';
  signal           S_valid_ungated  : std_ulogic :=  '0';
  signal ecc_corr_mask : std_logic_vector (31 downto 0) :=  X"00000000";
  signal           ecc_error  : std_ulogic :=  '0';
  signal           ecc_error_single  : std_ulogic :=  '0';
  signal           ecc_error_ungated  : std_ulogic :=  '0';
 signal ecc_synbit : std_logic_vector (4 downto 0) :=  "00000"; 
 signal ecc_synword : std_logic_vector (6 downto 0) :=  "0000000"; 
 signal ecc_synbit_next : std_logic_vector (4 downto 0) :=  "00000"; 
 signal ecc_synword_next : std_logic_vector (6 downto 0) :=  "0000000"; 
 signal           efar_save  : std_ulogic :=  '0';
 signal hiaddr : std_logic_vector (11 downto 5) :=  "0101110"; 
 signal hiaddr_t : std_logic_vector (6 downto 0) :=  "0101110"; 
 signal hiaddrp1_t  : std_logic_vector (6 downto 0) := "0101111"; 
 signal hiaddrp1  : std_logic_vector (11 downto 5) := "0101111" ; 
 signal hiaddrp1_i : integer := 47;
 signal          hiaddr63 : std_logic;
 signal          hiaddr127 : std_logic;
 signal          hclk : std_ulogic;
 signal          xorall : std_ulogic;
 signal          overall : std_ulogic;
 signal          S_valid_next : std_ulogic;
 signal          S_valid_ungated_next : std_ulogic;
 signal          next_error : std_ulogic;
 signal new_S_xor_S  : std_logic_vector (12 downto 0) ; 
 signal ecc_synword_next_not_par  : std_logic_vector (6 downto 0) := "0000000"; 
 signal tmp_63v6 : std_logic_vector (5 downto 0) ;
 signal tmp_127v7 : std_logic_vector (6 downto 0) ;
 signal tmp_v7 : std_logic_vector (6 downto 0) ;
 signal tmp1_v7 : std_logic_vector (6 downto 0) ;
 signal tmp2_v7 : std_logic_vector (6 downto 0) ;
 signal tmp_v1  : std_ulogic;
 signal tmpa_v1  : std_ulogic;
 signal tmpb_v7 : std_logic_vector (6 downto 0) := "0111111";
 signal tmpb_i : integer := 1;
 signal tmpb_i1 : integer := 0;
 signal rd_rbt_en : std_ulogic := '0';
   file  ecc_ecc_out_fd : text;
   file  ecc_rbt_out_fd : text;

 begin

   
   INIPROC : process
   begin
     if((FARSRC /= "EFAR") and (FARSRC /= "efar") and
           (FARSRC /= "FAR") and  (FARSRC /= "far")) then
       assert FALSE report "Error : FARSRC = is not EFAR, FAR." severity error;
     end if;
   wait;
   end process INIPROC;

  CRCERROR <= rbcrc_err;
  ECCERROR <= ecc_error;
  ECCERRORSINGLE <= ecc_error_single;
  SYNDROMEVALID <= S_valid;
  SYNDROME <= S;
  FAR <= frame_addr(23 downto 0);
  SYNBIT <= ecc_synbit;
  SYNWORD <= ecc_synword;


 process  begin
   wait for 2 ns;
   clk_osc <=  '1';
   wait for 2 ns;
   clk_osc <=  '0';
--    wait on clk_osc;
 end process;


   
  file_read_p : process 
   file rbt_fd : text;
   variable open_status : file_open_status;
   variable in_buf    : line;
   variable read_ok : boolean;
   variable first_time : boolean := true;
   variable sim_file_flag : std_ulogic := '0';
   variable data_rbt  : std_logic_vector (31 downto 0) ; 
   variable frame_addr_tmp  : integer ; 
   variable frame_addr_i : UNSIGNED( 31 downto 0) :=  X"00000000";
   variable data_rbt_tmp  : bit_vector (31 downto 0) ; 
   variable rb_crc_rbt_tmp : bit_vector (31 downto 0) ;
   variable crc_new : std_logic_vector (31 downto 0) :=  X"00000000";
   variable crc_input : std_logic_vector (36 downto 0) :=  "0000000000000000000000000000000000000";

  begin
  if (first_time = true) then
   if (FRAME_RBT_IN_FILENAME  =  "NONE")  then
      assert false report " Message: The configuration frame data file for FRAME_ECC_VIRTEX6  was not found. Use ICAP_VIRTEX6 to generate frame data file and then use the FRAME_RBT_IN_FILENAME generic to pass the file name." severity warning;
      sim_file_flag := '0';
   else 
     file_open(open_status, rbt_fd, FRAME_RBT_IN_FILENAME, read_mode);
     if (open_status /= open_ok) then
      assert false report " Message : The configuration frame data file for FRAME_ECC_VIRTEX6  was not found. Use ICAP_VIRTEX6 to generate frame data file and then use the FRAME_RBT_IN_FILENAME generic to pass the file name." severity warning;
      sim_file_flag := '0';
     else
      readline(rbt_fd, in_buf);
      if (in_buf'LENGTH > 0 ) then
          rd_rbt_en <= '1' after 1 ps;
          sim_file_flag := '1';
       end if;
     end if;
    end if;

     file_open(open_status, ecc_ecc_out_fd, FRAME_ECC_OUT_ECC_FILENAME, write_mode);
     if (open_status /= open_ok) then
      assert false report " Error: The ecc frame data out file frame_ecc_out_v6.txt for FRAME_ECC_VIRTEX6 can not created." severity error;
      sim_file_flag := '0';
     end if;
     file_open(open_status, ecc_rbt_out_fd, FRAME_ECC_OUT_RBT_FILENAME, write_mode);
     if (open_status /= open_ok) then
      assert false report " Error: The rbt frame data out file frame_rbt_out_v6.txt for FRAME_ECC_VIRTEX6 can not created." severity error;
      sim_file_flag := '0';
     end if;
     first_time := false;
   end if;

   if (falling_edge(clk_osc)) then

   if ( sim_file_flag =  '1'  and  rd_rbt_en  =  '1'  and  rd_rbt_hold1  =  '0') then
    if (not endfile(rbt_fd)) then
       readline(rbt_fd, in_buf);
       read(in_buf, frame_addr_tmp, read_ok);
       if not read_ok then
      assert false report " Error: The format of the configuration frame data file for FRAME_ECC_VIRTEX6  is wrong. Use ICAP_VIRTEX6 to generate frame data file and then use the FRAME_RBT_IN_FILENAME generic to pass the file name." severity error;
       end if;
       read(in_buf, data_rbt_tmp, read_ok);
       read(in_buf, rb_crc_rbt_tmp, read_ok);
       data_rbt := TO_STDLOGICVECTOR(data_rbt_tmp);
       frame_addr_i := TO_UNSIGNED(frame_addr_tmp, 32);
       frame_addr <= STD_LOGIC_VECTOR(frame_addr_i);
       rb_crc_rbt <= TO_STDLOGICVECTOR(rb_crc_rbt_tmp);
       rb_data_en <= '1';
       rb_data <= data_rbt;
       crc_input(36 downto 0) :=  ("00011" & data_rbt);
       crc_new(31 downto 0) := crc_next(crc_curr, crc_input);
       crc_curr(31 downto 0) <= crc_new;
       if (n <= 255) then
         frame_data(n) <= data_rbt(31 downto 0);
         if (n  =  255)  then
           n <= 174;
         elsif (n = 191) then
           n <= 193;
         else
           n <= n + 1;
         end if;
       end if;
   else
       rb_data_en <= '0';
       end_rbt <= '1';
       n <= 173;
       if ( crc_new  /=  rb_crc_rbt) then
          rbcrc_err <= '1';
       else
          rbcrc_err <= '0';
       end if;
       file_close(rbt_fd);
     end if;
    end if;
    end if;
    wait on clk_osc, rd_rbt_hold1;
   end process;

   ecc_p1 : process ( clk_osc) 
     variable ecc_wadr : std_logic_vector(6 downto 0);
     variable ecc_wadr_i : integer;
     variable ecc_badr : std_logic_vector(4 downto 0);
     variable corr_wd : std_logic_vector(31 downto 0);
     variable corr_wd1 : std_logic_vector(31 downto 0);
     variable tmpwd1 : std_logic_vector(31 downto 0);
     variable tmpwd2 : std_logic_vector(31 downto 0);
     variable frame_data_bak : frame_data_bak_a;
   begin
     if (falling_edge(clk_osc)) then
     if (rb_data_en  =  '1') then
        if ( rd_rbt_hold1  =  '1'  and  rd_rbt_hold  =  '1'  and  rd_rbt_hold2  =  '0') then
          for bi in 174 to 255 loop
          frame_data_bak(bi) := frame_data(bi);
          end loop;
          if (ecc_error_single  =  '1') then
            ecc_wadr(6 downto 0) := S(11 downto 5);
            ecc_badr(4 downto 0) := S(4 downto 0);
            ecc_wadr_i := SLV_TO_INT(ecc_wadr) + 174;
            corr_wd := frame_data(ecc_wadr_i);
            corr_wd1 := frame_data(ecc_wadr_i);
            corr_wd(SLV_TO_INT(ecc_badr)) :=  not corr_wd1(SLV_TO_INT(ecc_badr));
            frame_data_bak(ecc_wadr_i) := corr_wd;
          end if;
          for nbi in 174 to 255 loop
            if (nbi  /=  192) then
              tmpwd1 := frame_data(nbi);
              tmpwd2 := frame_data_bak(nbi);
              write(ecc_rbt_out_fd,  (SLV_TO_STR(tmpwd1) & LF)); 
              write(ecc_ecc_out_fd, (SLV_TO_STR(tmpwd2) & LF)); 
            end if;
          end loop;
        end if;
     elsif (end_rbt  = '1') then
           file_close(ecc_ecc_out_fd);
           file_close(ecc_rbt_out_fd);
     end  if;
    end if;
    end process;
  
    process (clk_osc) begin
     if (rising_edge(clk_osc)) then
      if (rb_data_en  =  '1') then
        if (n  =  255)  then
           rd_rbt_hold <= '1';
        end if;
        rd_rbt_hold2 <= rd_rbt_hold1;
        rd_rbt_hold1 <= rd_rbt_hold;
        if (rd_rbt_hold2  = '1') then
           rd_rbt_hold <= '0';
           rd_rbt_hold1 <= '0';
           rd_rbt_hold2 <= '0';
        end if;
      elsif ( end_rbt  =  '1')  then
         rd_rbt_hold <= '1';
         rd_rbt_hold1 <=  '1';
         rd_rbt_hold2 <=  '1';
      end if;
    end if;
   end process;

    process (clk_osc) begin
      if (falling_edge(clk_osc)) then
       if (rd_rbt_hold2  =  '1'  and  hamming_rst  =  '0') then
          hamming_rst <= '1';
       else
          hamming_rst <= '0';
       end if;
      end if;
     end process;

     S_valid_next <= rb_data_en  and  hiaddr127  and  (not ecc_run);
     S_valid_ungated_next <= rb_data_en  and  hiaddr127;
     next_error <=  u_or(next_S);
     hiaddrp1_i <= SLV_TO_INT(hiaddr_t) + 1;
     hiaddr_t(6 downto 0)  <= hiaddr(11 downto 5);
     hiaddrp1(11 downto 5 ) <= hiaddrp1_t(6 downto 0);
     tmp_63v6 <= hiaddr(10 downto 5);
     tmp_127v7 <= hiaddr(11 downto 5);
     hiaddr63 <=  u_and(tmp_63v6);    
     hiaddr127 <=  u_and(tmp_127v7); 
     hclk <= '1' when( hiaddr  =  "1010111" ) else '0';

   hiaddrp1_i_p : process (hiaddrp1_i) 
     variable  hiaddrp1_i_t : UNSIGNED(7 downto 0);
     variable  hiaddrp1_i_t1 : STD_LOGIC_VECTOR(7 downto 0);
   begin
    if (NOW > 0 ps) then
      hiaddrp1_i_t := TO_UNSIGNED(hiaddrp1_i, 8);
      hiaddrp1_i_t1 := STD_LOGIC_VECTOR(hiaddrp1_i_t);
      hiaddrp1_t(6 downto 0) <= hiaddrp1_i_t1(6 downto 0);
    end if;
   end process;


   process (clk_osc, hamming_rst) begin
     if (rising_edge(hamming_rst)) then
           hiaddr <=  "0101110";
     elsif (rising_edge(clk_osc)) then
       if ( rb_data_en  =  '1' ) then
           if ( hiaddr127  = '1')     then
               hiaddr <=  "0101110";
           else 
               hiaddr <=  ( hiaddrp1(11 downto 6) & ( hiaddr63  or  hiaddrp1(5) ) );
           end if;
        end if;
     end if;
   end process;
           
    xorall  <= u_xor(rb_data(31 downto 13)) xor ((not hclk) and u_xor(rb_data(12 downto 0)));
    overall <= u_xor(rb_data(31 downto 13)) xor ((not hclk) and calc_syndrome and u_xor(rb_data(12 downto 0)));

    new_S(12) <=  overall;

    new_S(4) <= rb_data(31) xor rb_data(30) xor rb_data(29) xor rb_data(28) xor
                rb_data(27) xor rb_data(26) xor rb_data(25) xor rb_data(24) xor 
                rb_data(23) xor rb_data(22) xor rb_data(21) xor rb_data(20) xor 
                rb_data(19) xor rb_data(18) xor rb_data(17) xor rb_data(16) xor 
                  ( hclk  and   (not calc_syndrome)  and  rb_data(4)  );
    new_S(3) <= rb_data(31) xor rb_data(30) xor rb_data(29) xor rb_data(28) xor 
                rb_data(27) xor rb_data(26) xor rb_data(25) xor rb_data(24) xor 
                rb_data(15) xor rb_data(14) xor rb_data(13)  xor new_s3_tmp;
    new_s3_tmp <=  (not calc_syndrome  and  rb_data(3)) when hclk = '1' else  
                (rb_data(12) xor rb_data(11) xor rb_data(10) xor rb_data(9) xor rb_data(8));
    new_S(2) <= rb_data(31) xor rb_data(30) xor rb_data(29) xor rb_data(28) xor 
                rb_data(23) xor rb_data(22) xor rb_data(21) xor rb_data(20) xor 
                rb_data(15) xor rb_data(14) xor rb_data(13)  xor new_s2_tmp;
    new_s2_tmp <=  (not calc_syndrome  and  rb_data(2)) when hclk = '1' else 
                (rb_data(12) xor rb_data(7) xor rb_data(6) xor rb_data(5) xor rb_data(4));
    new_S(1) <= rb_data(31) xor rb_data(30) xor rb_data(27) xor rb_data(26) xor 
                rb_data(23) xor rb_data(22) xor rb_data(19) xor rb_data(18) xor 
                rb_data(15) xor rb_data(14)  xor new_s1_tmp;
    new_s1_tmp <= (not calc_syndrome  and  rb_data(1)) when hclk = '1' else 
                ( rb_data(11) xor rb_data(10) xor rb_data(7) xor rb_data(6) xor rb_data(3) xor rb_data(2) );
    new_S(0) <= rb_data(31) xor rb_data(29) xor rb_data(27) xor rb_data(25) xor 
                rb_data(23) xor rb_data(21) xor rb_data(19) xor rb_data(17) xor 
                rb_data(15) xor rb_data(13)  xor new_s0_tmp;
    new_s0_tmp <= (not calc_syndrome  and  rb_data(0)) when hclk = '1' else  
                (rb_data(11) xor rb_data(9) xor rb_data(7) xor rb_data(5) xor rb_data(3) xor rb_data(1));

    tmp_v7 <= (xorall & xorall & xorall & xorall & xorall & xorall & xorall);
    tmp_v1 <=  hclk  and   not calc_syndrome;
    tmp1_v7 <= (tmp_v1 & tmp_v1 & tmp_v1 & tmp_v1 & tmp_v1 & tmp_v1 & tmp_v1);
    tmp2_v7 <=  rb_data(11 downto 5);
    new_S(11 downto 5) <= (hiaddr and tmp_v7) xor (tmp1_v7 and tmp2_v7);

    new_S_xor_S <= S xor new_S;

    tmpa_v1 <=  u_xor(new_S_xor_S);

    next_S <= (tmpa_v1 & new_S_xor_S(11 downto 0)) when 
              (hiaddr127 and calc_syndrome) = '1' else 
              new_S when hiaddr  = "0101110" else  new_S_xor_S;

    tmpb_v7 <= new_S_xor_S(11 downto 5);
    tmpb_i <= SLV_TO_INT(tmpb_v7) - 46;
    tmpb_i1 <= tmpb_i when new_S_xor_S(11) = '0' else (tmpb_i - 1);    

   process (tmpb_i1) begin
    if (tmpb_i1 >= 0 and NOW > 0 ps) then
    ecc_synword_next_not_par <= STD_LOGIC_VECTOR(TO_UNSIGNED(tmpb_i1, 7));
   end if;
   end process; 

   process (ecc_synword_next_not_par, new_S_xor_S) begin
      if (new_S_xor_S(12) <= '0') then
            ecc_synword_next <= "0000000";
            ecc_synbit_next  <= "00000";
      else
         case (new_S_xor_S(11 downto 0)) is
            when X"000" =>
              ecc_synword_next <= "0101000";
              ecc_synbit_next  <= "01100";
            when X"001" =>
              ecc_synword_next <= "0101000";
              ecc_synbit_next  <= "00000";
            when X"002" =>
              ecc_synword_next <= "0101000";
              ecc_synbit_next  <= "00001";
            when X"004" =>
              ecc_synword_next <= "0101000";
              ecc_synbit_next  <= "00010";
            when X"008" =>
              ecc_synword_next <= "0101000";
              ecc_synbit_next  <= "00011";
            when X"010" =>
              ecc_synword_next <= "0101000";
              ecc_synbit_next  <= "00100";
            when X"020" =>
              ecc_synword_next <= "0101000";
              ecc_synbit_next  <= "00101";
            when X"040" =>
              ecc_synword_next <= "0101000";
              ecc_synbit_next  <= "00110";
            when X"080" =>
              ecc_synword_next <= "0101000";
              ecc_synbit_next  <= "00111";
            when X"100" =>
              ecc_synword_next <= "0101000";
              ecc_synbit_next  <= "01000";
            when X"200" =>
              ecc_synword_next <= "0101000";
              ecc_synbit_next  <= "01001";
            when X"400" =>
              ecc_synword_next <= "0101000";
              ecc_synbit_next  <= "01010";
            when X"800" =>
              ecc_synword_next <= "0101000";
              ecc_synbit_next  <= "10001";
           when others =>
              ecc_synword_next <= ecc_synword_next_not_par;
              ecc_synbit_next  <= new_S_xor_S(4 downto 0);
         end case; 
      end if;
   end process;

   process ( clk_osc, hamming_rst) begin
     if (rising_edge(hamming_rst)) then
           S_valid         <= '0';
           S_valid_ungated <= '0';
           S               <=  "0000000000000";
           ecc_synword    <= "0000000";
           ecc_synbit     <= "00000";
           ecc_error <= '0';
           ecc_error_single <= '0';
           ecc_error_ungated <= '0';
           efar_save  <= '0';
     elsif (rising_edge(clk_osc)) then
        if ( rb_data_en  =  '1' ) then
           S_valid_ungated <=  S_valid_ungated_next;
           S_valid         <=  S_valid_next;
           S               <=  next_S;
        else       
           S_valid_ungated <= '0';
           S_valid         <= '0';
       end if;
 
        if ( S_valid_next = '1'  and (not efar_save)  = '1') then
           ecc_synword    <=  ecc_synword_next;
           ecc_synbit     <=  ecc_synbit_next;
        end if;

        if (S_valid_next  =  '1') then
          ecc_error <=  next_error;
          ecc_error_single <= next_S(12);
        end if;

        if (S_valid_ungated_next  =  '1')  then
          ecc_error_ungated <= next_error;
        end if;

        if (ecc_error  =  '1'  or  ((S_valid_ungated_next  and  next_error)  =  '1')) then
           efar_save  <= '1';
        end if;
      end if;
   end process;

end FRAME_ECC_VIRTEX6_V;

