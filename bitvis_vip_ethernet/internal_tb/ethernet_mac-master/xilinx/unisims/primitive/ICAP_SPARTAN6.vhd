-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/stan/VITAL/ICAP_SPARTAN6.vhd,v 1.14.156.1 2013/05/02 21:44:21 wloo Exp $
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
-- /___/   /\      Filename    : ICAP_SPARTAN6.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Revision: 
--  10/09/09 - Add initialzion message and check (CR525847)
--  12/08/09 - Support no rbt file case readback (CR537437)
--  03/02/10 - Support desync when icap initial done (CR551856)
--  03/17/10 - Create internal clock for icap initializtion to
--             reduce initializtion time (CR554252)
--  01/31/11 - Fix for init_tri (CR590958)
--  11/10/11 - Update DEVICE_ID (CR611789)
--  05/02/13 - Update initial data loading time (CR 710332). 
--  End Revision
-------------------------------------------------------

----- CELL ICAP_SPARTAN6 -----

library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library STD;
use STD.TEXTIO.all;



library unisim;
use unisim.VCOMPONENTS.all;

use unisim.VPKG.all;

  entity ICAP_SPARTAN6 is
    generic (
      DEVICE_ID : bit_vector := X"04000093";
      SIM_CFG_FILE_NAME : string := "NONE"
    );

    port (
      BUSY                 : out std_ulogic := '1';
      O                    : out std_logic_vector(15 downto 0);
      CE                   : in std_ulogic;
      CLK                  : in std_ulogic;
      I                    : in std_logic_vector(15 downto 0);
      WRITE                : in std_ulogic      
    );

  end ICAP_SPARTAN6;

  architecture ICAP_SPARTAN6_V of ICAP_SPARTAN6 is

component SIM_CONFIG_S6
  generic (
     DEVICE_ID : bit_vector := X"00000000";
     ICAP_SUPPORT : boolean := false
  );
  port (
     BUSY : out std_ulogic := '0';
     CSOB : out std_ulogic := '1';
     D : inout std_logic_vector(15 downto 0);
     DONE : inout std_logic;
     INITB : inout std_logic := 'H';
     CCLK : in std_ulogic := '0';
     CSIB : in std_ulogic := '0';
     M : in std_logic_vector(1 downto 0) := "10";
     PROGB : in std_ulogic := 'H';
     RDWRB : in std_ulogic := '0'
  );
end component;

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


    
  signal BUSY_out : std_ulogic := '1';
  signal O_out : std_logic_vector(15 downto 0);
    
  signal CE_ipd : std_ulogic;
  signal CLK_ipd : std_ulogic;
  signal I_ipd : std_logic_vector(15 downto 0);
  signal WRITE_ipd : std_ulogic;
  signal WRITE_CLK_dly : std_ulogic;
  signal I_CLK_dly : std_logic_vector(15 downto 0);
  signal CE_CLK_dly : std_ulogic;
  signal CLK_dly : std_ulogic;

  signal cso_b : std_ulogic;
  signal  prog_b : std_ulogic := '1';
  signal  init_b : std_logic := '0';
  signal  init_tri : std_logic := 'H';
  signal  cs_bi : std_ulogic := '0';
  signal  rdwr_bi : std_ulogic := '0';
  signal cs_b_t : std_ulogic;
  signal clk_in : std_ulogic;
  signal rdwr_b_t : std_ulogic;
  signal dix  : std_logic_vector (15 downto 0) ; 
  signal di  : std_logic_vector (15 downto 0) ; 
  signal icap_idone : std_ulogic := '0';
  signal csi_b_in : std_ulogic;
  signal done_o : std_logic;
  signal busy_o : std_ulogic;
  signal di_t : std_logic_vector (15 downto 0) ;
  signal clk_osc : std_ulogic := '0';
    begin

    I_CLK_dly <= I;
    CE_CLK_dly <= CE;
    CLK_dly <= CLK;
    WRITE_CLK_dly <= WRITE;
    BUSY  <= BUSY_out;
     O <= O_out;

   init_tri <=  init_b;
   done_o <= 'H';
   di_t <= "ZZZZZZZZZZZZZZZZ" when (icap_idone = '1' and WRITE_CLK_dly = '1') else dix;
   csi_b_in <= CE_CLK_dly;
   dix <= I_CLK_DLY when (icap_idone  =  '1') else di;
   BUSY_out <= busy_o when (icap_idone   =  '1') else '1';
   cs_b_t <= csi_b_in when (icap_idone  =  '1') else cs_bi;
   clk_in <= CLK_dly when (icap_idone  =  '1') else clk_osc;
   rdwr_b_t <= WRITE_CLK_dly when (icap_idone   =  '1') else rdwr_bi;
   O_out <= di_t when (icap_idone = '1' and WRITE_CLK_dly = '1') else "0000000000000000";

   process (CE_CLK_dly, WRITE_CLK_dly)
   begin
     if (NOW > 1 ps and icap_idone = '0') then
      assert FALSE report " Warning :  ICAP_SPARTAN6 has not finished initialization. A message will be printed after the initialization. User need start read/write operation after that." severity warning;
     end if;
   end process;

 process  begin
   wait for 1 ns;
   clk_osc <=  '1';
   wait for 1 ns;
   clk_osc <=  '0';
 end process;



  SIM_CONFIG_S6_INST : SIM_CONFIG_S6
  generic map (
      DEVICE_ID => DEVICE_ID,
      ICAP_SUPPORT => TRUE
    )
  port map (
      BUSY => busy_o, 
      CSOB => cso_b,
      DONE => done_o,
      CCLK => clk_in,
      CSIB => cs_b_t,
      D => di_t,
      INITB => init_tri,
      M => "10",
      PROGB => prog_b,
      RDWRB => rdwr_b_t
  );

  process 
    file icap_fd : text;
    variable open_status : file_open_status;
    variable in_buf    : line;
    variable data_rbt_tmp : bit_vector(15 downto 0);
    variable data_rbt : std_logic_vector(15 downto 0);
    variable read_ok : boolean := false;
    variable tmp_byte0  : std_logic_vector (7 downto 0) ; 
    variable tmp_byte1  : std_logic_vector (7 downto 0) ; 
    variable tmp_byte  : std_logic_vector (7 downto 0) ; 
    variable sim_file_flag : std_ulogic := '0';
  begin
    if (SIM_CFG_FILE_NAME  =  "NONE") then
--       assert FALSE report "Error : The configure rbt data file for ICAP_SPARTAN6 was not found. Use the SIM_CFG_FILE_NAME generic to pass the file name." severity error;
       sim_file_flag := '1';
    else 
      file_open(open_status, icap_fd, SIM_CFG_FILE_NAME, read_mode);
      if (open_status /= open_ok) then
         assert false report " Error: The configure rbt data file %s for ICAP_SPARTAN6 was not found. Use the SIM_CFG_FILE_NAME generic to pass the file name." severity error;
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
      wait for 5000000 ps;
      wait until falling_edge(clk_in);
      init_b <= '1';
      cs_bi <= '0';
    if (sim_file_flag  =  '0') then
      while (not endfile(icap_fd)) loop
         readline(icap_fd, in_buf);
         read(in_buf, data_rbt_tmp, read_ok);
         data_rbt := TO_STDLOGICVECTOR(data_rbt_tmp);
         if (done_o  =  '0') then
          tmp_byte(7 downto 0) := data_rbt(15 downto 8);
          tmp_byte1(7 downto 0) := bit_revers8(tmp_byte);
          tmp_byte(7 downto 0) := data_rbt(7 downto 0);
          tmp_byte0(7 downto 0) := bit_revers8(tmp_byte);
          wait until falling_edge(clk_in);
          di <= (tmp_byte1 & tmp_byte0);
         else 
          if (icap_idone = '0') then
          wait until falling_edge(clk_in);
          di <= X"FFFF";
          wait until falling_edge(clk_in);
          wait until falling_edge(clk_in);
          wait until falling_edge(clk_in);
          wait until falling_edge(clk_in);
          wait until falling_edge(clk_in);
          wait until falling_edge(clk_in);
          icap_idone <= '1';
      assert FALSE report " Message :  ICAP_SPARTAN6 has finished initialization. User can start read/write operation." severity note;
         end if;
        end if;
      end loop;
      file_close(icap_fd);
    else
      wait until falling_edge(clk_in);
          di <= X"FFFF";
      wait until falling_edge(clk_in);
          di <= X"FFFF";
      wait until falling_edge(clk_in);
          di <= X"FFFF";
      wait until falling_edge(clk_in);
          di <= X"FFFF";
      wait until falling_edge(clk_in);
          di <= X"FFFF";
      wait until falling_edge(clk_in);
          di <= X"5599"; -- AA99
      wait until falling_edge(clk_in);
          di <= X"AA66"; -- 5566
      wait until falling_edge(clk_in);
          di <= X"FFFF";
      wait until falling_edge(clk_in);
          di <= X"FFFF";
      wait until falling_edge(clk_in);
          di <= X"0C85";
      wait until falling_edge(clk_in);
          di <= X"00A0";
      wait until falling_edge(clk_in);
      wait until falling_edge(clk_in);
      wait until falling_edge(clk_in);
      wait until falling_edge(clk_in);
      wait until falling_edge(clk_in);
      wait until falling_edge(clk_in);
      if (icap_idone = '0') then
          icap_idone <= '1';
      assert FALSE report " Message :  ICAP_SPARTAN6 has finished initialization. User can start read/write operation." severity note;
      end if;
    end if;
      wait; 
  
  end process;

end ICAP_SPARTAN6_V;
