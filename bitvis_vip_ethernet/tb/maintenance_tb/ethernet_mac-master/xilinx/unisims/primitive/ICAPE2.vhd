-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/fuji/VITAL/ICAPE2.vhd,v 1.3 2011/02/18 21:01:45 yanx Exp $
-------------------------------------------------------
--  Copyright (c) 2009 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   / 
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version : 11.1
--  \   \          Description : 
--  /   /                      
-- /___/   /\      Filename    : ICAPE2.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Revision: 1.0
--  05/01/10 - Initial version.
--  02/18/11 - Change DEVICE_ID default (CR593951)
-------------------------------------------------------

----- CELL ICAPE2 -----

library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library STD;
use STD.TEXTIO.all;




library unisim;
use unisim.VCOMPONENTS.all;

use unisim.VPKG.all;

  entity ICAPE2 is
    generic (
      DEVICE_ID : bit_vector := X"03651093";
      ICAP_WIDTH : string := "X32";
      SIM_CFG_FILE_NAME : string := "NONE"
    );

    port (
      O                    : out std_logic_vector(31 downto 0);
      CLK                  : in std_ulogic;
      CSIB                  : in std_ulogic;
      I                    : in std_logic_vector(31 downto 0);
      RDWRB                : in std_ulogic      
    );

  end ICAPE2;

  architecture ICAPE2_V of ICAPE2 is

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

component SIM_CONFIGE2
  generic (
     DEVICE_ID : bit_vector := X"00000000";
     ICAP_SUPPORT : boolean := false;
     ICAP_WIDTH : string := "X8"
  );
  port (
     CSOB : out std_ulogic := '1';
     D : inout std_logic_vector(31 downto 0);
     DONE : inout std_logic;
     INITB : inout std_logic := 'H';
     CCLK : in std_ulogic := '0';
     CSB : in std_ulogic := '0';
     M : in std_logic_vector(2 downto 0) := "110";
     PROGB : in std_ulogic := '0';
     RDWRB : in std_ulogic := '0'
  );

end component;


  signal O_out : std_logic_vector(31 downto 0);
    
  signal CLK_ipd : std_ulogic;
  signal CSIB_ipd : std_ulogic;
  signal I_ipd : std_logic_vector(31 downto 0);
  signal RDWRB_ipd : std_ulogic;
    
  signal CLK_dly : std_ulogic;
  signal CSIB_CLK_dly : std_ulogic;
  signal I_CLK_dly : std_logic_vector(31 downto 0);
  signal RDWRB_CLK_dly : std_ulogic;

  signal bw : std_logic_vector (3 downto 0) := "0000";
  signal cso_b : std_ulogic;
  signal  prog_b : std_ulogic := '1';
  signal  init_b : std_logic := '0';
  signal  init_tri : std_logic := 'H';
  signal  cs_bi : std_ulogic := '0';
  signal  rdwr_bi : std_ulogic := '0';
  signal cs_b_t : std_ulogic;
  signal clk_in : std_ulogic;
  signal rdwr_b_t : std_ulogic;
  signal dix  : std_logic_vector (31 downto 0) ;
  signal tmp_byte0  : std_logic_vector (7 downto 0) ;
  signal tmp_byte1  : std_logic_vector (7 downto 0) ;
  signal tmp_byte2  : std_logic_vector (7 downto 0) ;
  signal tmp_byte3  : std_logic_vector (7 downto 0) ;
  signal tmp_byte  : std_logic_vector (7 downto 0) ;
  signal di  : std_logic_vector (31 downto 0) ;
  signal icap_idone : std_ulogic := '0';
  signal csi_b_in : std_ulogic;
  signal done_o : std_logic;
  signal busy_o : std_ulogic;
  signal di_t : std_logic_vector (31 downto 0) ;
  signal clk_osc : std_ulogic := '0';
    
    begin
    I_CLK_dly <= I;
    CSIB_CLK_dly <= CSIB;
    CLK_dly <= CLK;
    RDWRB_CLK_dly <= RDWRB;
     O <= O_out;

   init_tri <=  init_b;
   done_o <= 'H';
   di_t <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" when (icap_idone = '1' and RDWRB_CLK_dly = '1') else dix;
   csi_b_in <= CSIB_CLK_dly;
   dix <= I_CLK_DLY when (icap_idone  =  '1') else di;
   cs_b_t <= csi_b_in when (icap_idone  =  '1') else cs_bi;
   clk_in <= CLK_dly when (icap_idone  =  '1') else clk_osc;
   rdwr_b_t <= RDWRB_CLK_dly when (icap_idone   =  '1') else rdwr_bi;
   O_out <= di_t when (icap_idone = '1' and RDWRB_CLK_dly = '1') else "00000000000000000000000000000000";

   process (CSIB_CLK_dly, RDWRB_CLK_dly)
   begin
     if (NOW > 1 ps and icap_idone = '0') then
      assert FALSE report " Warning :  ICAPE2 has not finished initialization. A message will be printed after the initialization. User need start read/write operation after that." severity warning;
     end if;
   end process;
       
 process  begin
   wait for 1 ns;
   clk_osc <=  '1';
   wait for 1 ns;
   clk_osc <=  '0';
 end process;


  SIM_CONFIGE2_INST : SIM_CONFIGE2
  generic map (
      DEVICE_ID => DEVICE_ID,
      ICAP_SUPPORT => TRUE,
      ICAP_WIDTH => ICAP_WIDTH
    )
  port map (
      CSOB => cso_b,
      DONE => done_o,
      CCLK => clk_in,
      CSB => cs_b_t,
      D => di_t,
      INITB => init_tri,
      M => "110",
      PROGB => prog_b,
      RDWRB => rdwr_b_t
  );

  process
    file icap_fd : text;
    variable open_status : file_open_status;
    variable in_buf    : line;
    variable data_rbt_tmp : bit_vector(31 downto 0);
    variable data_rbt : std_logic_vector(31 downto 0);
    variable read_ok : boolean := false;
    variable tmp_byte0  : std_logic_vector (7 downto 0) ;
    variable tmp_byte1  : std_logic_vector (7 downto 0) ;
    variable tmp_byte2  : std_logic_vector (7 downto 0) ;
    variable tmp_byte3  : std_logic_vector (7 downto 0) ;
    variable tmp_byte  : std_logic_vector (7 downto 0) ;
    variable sim_file_flag : std_ulogic := '0';
  begin

   if((ICAP_WIDTH = "X8") or (ICAP_WIDTH = "x8")) then
      bw <= "0000";
    elsif((ICAP_WIDTH = "X16") or (ICAP_WIDTH= "x16")) then
      bw <= "0010";
    elsif((ICAP_WIDTH = "X32") or (ICAP_WIDTH= "x32")) then
      bw <= "0011";
    else
      assert FALSE report "Attribute Syntax Error : The Attribute ICAP_WIDTH is not X8, X16, X32." severity error;
      sim_file_flag := '1';
    end if;

    if (SIM_CFG_FILE_NAME  =  "NONE") then
       sim_file_flag := '1';
    else
      file_open(open_status, icap_fd, SIM_CFG_FILE_NAME, read_mode);
      if (open_status /= open_ok) then
         assert false report " Error: The configure rbt data file %s for ICAPE2 was not found. Use the SIM_CFG_FILE_NAME generic to pass the file name." severity error;
         sim_file_flag := '1';
      end if;
    end if;
      init_b <= '1';
      prog_b <= '1';
      rdwr_bi <= '0';
      cs_bi <= '1';
      wait for 600000 ps;
      wait until rising_edge(clk_in);
      prog_b <= '0';
      wait until falling_edge(clk_in);
      init_b <= '0';
      wait for 600000 ps;
      wait until rising_edge(clk_in);
      prog_b <= '1';
      wait until falling_edge(clk_in);
      init_b <= '1';
      cs_bi <= '0';
    if (sim_file_flag  =  '0') then
      while (not endfile(icap_fd)) loop
         readline(icap_fd, in_buf);
         read(in_buf, data_rbt_tmp, read_ok);
         data_rbt := TO_STDLOGICVECTOR(data_rbt_tmp);
         if (done_o  =  '0') then
          tmp_byte(7 downto 0) := data_rbt(31 downto 24);
          tmp_byte3(7 downto 0) := bit_revers8(tmp_byte);
          tmp_byte(7 downto 0) := data_rbt(23 downto 16);
          tmp_byte2(7 downto 0) := bit_revers8(tmp_byte);
          tmp_byte(7 downto 0) := data_rbt(15 downto 8);
          tmp_byte1(7 downto 0) := bit_revers8(tmp_byte);
          tmp_byte(7 downto 0) := data_rbt(7 downto 0);
          tmp_byte0(7 downto 0) := bit_revers8(tmp_byte);
          if (bw = "0000") then
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte3);
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte2);
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte1);
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte0);
           elsif (bw = "0010") then
              wait until falling_edge(clk_in);
              di <= ("0000000000000000" & tmp_byte3 & tmp_byte2);
              wait until falling_edge(clk_in);
              di <= ("0000000000000000" & tmp_byte1 & tmp_byte0);
           elsif (bw = "0011") then
              wait until falling_edge(clk_in);
              di <= (tmp_byte3 & tmp_byte2 &tmp_byte1 & tmp_byte0);
           end if;
         else
          if (icap_idone = '0') then
             wait until falling_edge(clk_in);
             di <= X"FFFFFFFF";
             wait until falling_edge(clk_in);
             wait until falling_edge(clk_in);
             wait until falling_edge(clk_in);
             wait until falling_edge(clk_in);
             wait until falling_edge(clk_in);
             icap_idone <= '1';
         assert FALSE report " Message :  ICAPE2 has finished initialization. User can start read/write operation." severity Note;
          end if;
        end if;
      end loop;
      file_close(icap_fd);
    else
              wait until falling_edge(clk_in);
              di <= X"FFFFFFFF";
              wait until falling_edge(clk_in);
              di <= X"FFFFFFFF";
              wait until falling_edge(clk_in);
              di <= X"FFFFFFFF";
              wait until falling_edge(clk_in);
              di <= X"FFFFFFFF";
              wait until falling_edge(clk_in);
              di <= X"FFFFFFFF";
              wait until falling_edge(clk_in);
              di <= X"FFFFFFFF";
              wait until falling_edge(clk_in);
              di <= X"FFFFFFFF";
              wait until falling_edge(clk_in);
              di <= X"FFFFFFFF";
              wait until falling_edge(clk_in);
              di <= X"FFFFFFFF";
          tmp_byte3(7 downto 0) := "00000000";
          tmp_byte2(7 downto 0) := "00000000";
          tmp_byte1(7 downto 0) := "00000000";
          tmp_byte0(7 downto 0) := bit_revers8("10111011");
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte3);
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte2);
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte1);
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte0);
          if (bw = "0000") then
             wait until falling_edge(clk_in);
             di <= X"00000088";
           elsif (bw = "0010") then
              wait until falling_edge(clk_in);
              di <= X"00000044";
           elsif (bw = "0011") then
              wait until falling_edge(clk_in);
              di <= X"00000022";
           end if;
             wait until falling_edge(clk_in);
             di <= X"FFFFFFFF";
             wait until falling_edge(clk_in);
             di <= X"FFFFFFFF";
             wait until falling_edge(clk_in);
             di <= X"FFFFFFFF";
             wait until falling_edge(clk_in);
             di <= X"FFFFFFFF";
             wait until falling_edge(clk_in);
             di <= X"FFFFFFFF";
             wait until falling_edge(clk_in);
             di <= X"FFFFFFFF";
             wait until falling_edge(clk_in);
             di <= X"FFFFFFFF";
             wait until falling_edge(clk_in);
             di <= X"FFFFFFFF";
          tmp_byte3(7 downto 0) := bit_revers8("10101010");
          tmp_byte2(7 downto 0) := bit_revers8("10011001");
          tmp_byte1(7 downto 0) := bit_revers8("01010101");
          tmp_byte0(7 downto 0) := bit_revers8("01100110");
          if (bw = "0000") then
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte3);
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte2);
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte1);
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte0);
           elsif (bw = "0010") then
              wait until falling_edge(clk_in);
              di <= ("0000000000000000" & tmp_byte3 & tmp_byte2);
              wait until falling_edge(clk_in);
              di <= ("0000000000000000" & tmp_byte1 & tmp_byte0);
           elsif (bw = "0011") then
              wait until falling_edge(clk_in);
              di <= (tmp_byte3 & tmp_byte2 &tmp_byte1 & tmp_byte0);
           end if;
          tmp_byte3(7 downto 0) := bit_revers8("00110000");
          tmp_byte2(7 downto 0) := bit_revers8("00000000");
          tmp_byte1(7 downto 0) := bit_revers8("10000000");
          tmp_byte0(7 downto 0) := bit_revers8("00000001");
          if (bw = "0000") then
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte3);
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte2);
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte1);
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte0);
           elsif (bw = "0010") then
              wait until falling_edge(clk_in);
              di <= ("0000000000000000" & tmp_byte3 & tmp_byte2);
              wait until falling_edge(clk_in);
              di <= ("0000000000000000" & tmp_byte1 & tmp_byte0);
           elsif (bw = "0011") then
              wait until falling_edge(clk_in);
              di <= (tmp_byte3 & tmp_byte2 &tmp_byte1 & tmp_byte0);
           end if;
          tmp_byte3(7 downto 0) := "00000000";
          tmp_byte2(7 downto 0) := "00000000";
          tmp_byte1(7 downto 0) := "00000000";
          tmp_byte0(7 downto 0) := bit_revers8("00000101");
          if (bw = "0000") then
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte3);
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte2);
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte1);
             wait until falling_edge(clk_in);
             di <= ("000000000000000000000000" & tmp_byte0);
           elsif (bw = "0010") then
              wait until falling_edge(clk_in);
              di <= ("0000000000000000" & tmp_byte3 & tmp_byte2);
              wait until falling_edge(clk_in);
              di <= ("0000000000000000" & tmp_byte1 & tmp_byte0);
           elsif (bw = "0011") then
              wait until falling_edge(clk_in);
              di <= (tmp_byte3 & tmp_byte2 &tmp_byte1 & tmp_byte0);
           end if;
      wait until falling_edge(clk_in);
      wait until falling_edge(clk_in);
      wait until falling_edge(clk_in);
      wait until falling_edge(clk_in);
      wait until falling_edge(clk_in);
      wait until falling_edge(clk_in);
       if (icap_idone = '0') then
          icap_idone <= '1';
      assert FALSE report " Message :  ICAPE2 has finished initialization. User can start read/write operation." severity warning;
       end if;
    end if;
      wait;
  end process;

end ICAPE2_V;
