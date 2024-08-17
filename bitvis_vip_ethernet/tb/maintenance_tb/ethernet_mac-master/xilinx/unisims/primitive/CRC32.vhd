-------------------------------------------------------------------------------
-- Copyright (c) 1995/2006 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Cyclic Redundancy Check 32-bit Input Simulation Model
-- /___/   /\     Filename : CRC32.vhd
-- \   \  /  \    Timestamp : Fri Jun 18 10:57:01 PDT 2004
--  \___\/\___\
--
-- Revision:
--  12/20/05 - Initial version.
--  12/20/05 - Added functionality
--  01/09/06  - Added Timing
--  08/02/06 - CR#233833 - Remove GSR declaration
--  08/18/06 - CR#421781 - CRCOUT initialized to 0 when GSR is high
--  07/24/07 - CR#442758 - Use CRCCLK instead of crcclk_int in always block
--  08/16/07 - CR#446564 - Add data_width as part of process block sensitivity list
--  10/22/07 - CR#452418 - Add all to process sensitivity list
--  11/21/07 - CR#454853 - POLYNOMIAL is not a user attribute
-- End Revision
-------------------------------------------------------------------------------

----- CELL CRC32 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;

library STD;
use STD.TEXTIO.all;


library unisim;
use unisim.vcomponents.all;
use unisim.vpkg.all;

entity CRC32 is
  generic (
    CRC_INIT   : bit_vector := X"FFFFFFFF"
     );    
  port (
    CRCOUT : out std_logic_vector(31 downto 0);
  
    CRCCLK : in std_ulogic;
    CRCDATAVALID : in std_ulogic;
    CRCDATAWIDTH : in std_logic_vector(2 downto 0);
    CRCIN : in std_logic_vector(31 downto 0);
    CRCRESET : in std_ulogic
  );
end CRC32;
  
  architecture CRC32_V of CRC32 is
    
    signal   data_in_32 :  std_logic_vector(7 downto 0);
    signal   data_in_24 :  std_logic_vector(7 downto 0);
    signal   data_in_16 :  std_logic_vector(7 downto 0);
    signal   data_in_8  :  std_logic_vector(7 downto 0);
    signal   data_width :  std_logic_vector(2 downto 0);
    signal   data_valid :  std_logic;
    signal   crcd       :  std_logic_vector(31 downto 0);
    signal   crcreg     :  std_logic_vector(31 downto 0);
    
    signal   crcgen_out_32 :  std_logic_vector(31 downto 0);
    signal   crcgen_out_24 :  std_logic_vector(31 downto 0);
    signal   crcgen_out_16 :  std_logic_vector(31 downto 0);
    signal   crcgen_out_8  :  std_logic_vector(31 downto 0);
    
--    signal   crcclk_int    :  std_logic;
    signal   crcreset_int  :  std_logic;

    signal   crc_initial : std_logic_vector(31 downto 0);
    signal   poly_val    : std_logic_vector(31 downto 0);

    signal   zero_24     : std_logic_vector(23 downto 0);
    signal   zero_16     : std_logic_vector(15 downto 0);
    signal   zero_8     : std_logic_vector(7 downto 0);

    signal   GSR_dly     : std_logic;
    signal   CRCOUT_zd : std_logic_vector(31 downto 0) := ( others => '0');

    constant POLYNOMIAL : bit_vector := X"04C11DB7";

  begin

  GSR_dly  <= GSR  after 0 ps;
    
  crcreset_int <= CRCRESET;
--  crcclk_int <= CRCCLK;

  crc_initial <= To_StdLogicVector(CRC_INIT); 
  poly_val <= To_StdLogicVector(POLYNOMIAL);

  zero_24 <= "000000000000000000000000";
  zero_16 <= "0000000000000000";
  zero_8 <= "00000000";

  
  OUTPUT_CALC: process(GSR_dly,crcreg)
    begin
      if(GSR_dly = '1') then
         CRCOUT_zd <=  (others => '0');
      elsif(GSR_dly = '0') then
         CRCOUT_zd <= (not(crcreg(24)) & not(crcreg(25)) & not(crcreg(26)) & not(crcreg(27)) & not(crcreg(28)) & not(crcreg(29)) & not(crcreg(30)) & not(crcreg(31)) & not(crcreg(16)) & not(crcreg(17)) & not(crcreg(18)) & not(crcreg(19)) & not(crcreg(20)) & not(crcreg(21)) & not(crcreg(22)) & not(crcreg(23)) & not(crcreg(8)) & not(crcreg(9)) & not(crcreg(10)) & not(crcreg(11)) & not(crcreg(12)) & not(crcreg(13)) & not(crcreg(14)) & not(crcreg(15)) & not(crcreg(0)) & not(crcreg(1)) & not(crcreg(2)) & not(crcreg(3)) & not(crcreg(4)) & not(crcreg(5)) & not(crcreg(6)) & not(crcreg(7)));
      end if;
  end process;

  LOCK_DATA_IN: process(CRCCLK)
    begin
      if (rising_edge(CRCCLK)) then
        data_in_8  <= CRCIN(31 downto 24);	
        data_in_16 <= CRCIN(23 downto 16);	
        data_in_24 <= CRCIN(15 downto 8);
        data_in_32 <= CRCIN(7 downto 0);
        data_valid <= CRCDATAVALID;
        data_width <= CRCDATAWIDTH;
      end if;
  end process;
  
   
   -- Select between CRC8, CRC16, CRC24, CRC32 based on CRCDATAWIDTH
      
      SELECT_DATA_IN: process(crcgen_out_8,crcgen_out_16,crcgen_out_24,crcgen_out_32,crcd,data_width)
	 begin
	  case data_width is
 	   when  "000" => crcd <= crcgen_out_8;
	   when  "001" => crcd <= crcgen_out_16;
	   when  "010" => crcd <= crcgen_out_24;
	   when  "011" => crcd <= crcgen_out_32;
	   when others => crcd <= crcgen_out_8;
	end case;
     end process;
   
   -- 32-bit CRC internal register
   
   INT_REG: process(CRCCLK)
    begin
      if (rising_edge(CRCCLK)) then
        if (crcreset_int = '1') then
          crcreg <= crc_initial;
        elsif (data_valid /= '1') then 
          crcreg <= crcreg;
        else
          crcreg <= crcd;
        end if;
      end if;
   end process;   

   --CRC Generator Logic
   
  CRC_GEN: process(crcreg, CRCIN, data_width,data_in_8,data_in_16, data_in_24,data_in_32)
    variable   msg        :  std_logic_vector(40 downto 0);

    variable   concat_data_8 :  std_logic_vector(31 downto 0);
    variable   concat_data_16 :  std_logic_vector(31 downto 0);
    variable   concat_data_24 :  std_logic_vector(31 downto 0);
    variable   concat_data_32 :  std_logic_vector(31 downto 0);
    

    begin

      --CRC-8
        
      if (data_width = "000") then
        
        concat_data_8 := data_in_8(0) & data_in_8(1) & data_in_8(2) & data_in_8(3) & data_in_8(4) & data_in_8(5) & data_in_8(6) & data_in_8(7) & zero_24;
      
        msg(31 downto 0) := crcreg xor concat_data_8;
        msg(40 downto 0) := To_StdLogicVector((To_bitvector(msg)) sll 8);
      
        for i in 0 to 7 loop
          msg(40 downto 0) := To_StdLogicVector((To_bitvector(msg)) sll 1);
          if (msg(40) = '1') then
            msg(39 downto 8) := msg(39 downto 8) xor poly_val;
          end if;
        end loop;
        crcgen_out_8 <= msg(39 downto 8);
       
        --CRC-16
    
      elsif (data_width = "001") then

        concat_data_16 := data_in_8(0) & data_in_8(1) & data_in_8(2) & data_in_8(3) & data_in_8(4) & data_in_8(5) & data_in_8(6) & data_in_8(7) & data_in_16(0)& data_in_16(1) & data_in_16(2) & data_in_16(3) & data_in_16(4) & data_in_16(5) & data_in_16(6) & data_in_16(7) & zero_16;

        msg(31 downto 0) := crcreg xor concat_data_16;
        msg(40 downto 0) := To_StdLogicVector((To_bitvector(msg)) sll 8);
	   
        for i in 0 to 15 loop
          msg(40 downto 0) := To_StdLogicVector((To_bitvector(msg)) sll 1);
          if (msg(40) = '1') then
            msg(39 downto 8) := msg(39 downto 8) xor poly_val;
          end if;
        end loop;
        crcgen_out_16 <= msg(39 downto 8);

    --CRC-24
	
      elsif (data_width = "010") then 

        concat_data_24 := data_in_8(0) & data_in_8(1) & data_in_8(2) & data_in_8(3) & data_in_8(4) & data_in_8(5) & data_in_8(6) & data_in_8(7) & data_in_16(0) & data_in_16(1) & data_in_16(2) & data_in_16(3) & data_in_16(4) & data_in_16(5) & data_in_16(6) & data_in_16(7) & data_in_24(0) & data_in_24(1) & data_in_24(2) & data_in_24(3) & data_in_24(4) & data_in_24(5) & data_in_24(6) & data_in_24(7) & zero_8;

        msg(31 downto 0) := crcreg xor concat_data_24;
        msg(40 downto 0) := To_StdLogicVector((To_bitvector(msg)) sll 8);
	   
        for i in 0 to 23 loop
          msg(40 downto 0) := To_StdLogicVector((To_bitvector(msg)) sll 1);
          if (msg(40) = '1') then
            msg(39 downto 8) := msg(39 downto 8) xor poly_val;
          end if;
        end loop;
        crcgen_out_24 <= msg(39 downto 8);


    --CRC-32
	
      elsif (data_width = "011") then
        concat_data_32 := data_in_8(0) & data_in_8(1) & data_in_8(2) & data_in_8(3) & data_in_8(4) & data_in_8(5) & data_in_8(6) & data_in_8(7) & data_in_16(0) & data_in_16(1) & data_in_16(2) & data_in_16(3) & data_in_16(4) & data_in_16(5) & data_in_16(6) & data_in_16(7) & data_in_24(0) & data_in_24(1) & data_in_24(2) & data_in_24(3) & data_in_24(4) & data_in_24(5) & data_in_24(6) & data_in_24(7) & data_in_32(0) & data_in_32(1) & data_in_32(2) & data_in_32(3) & data_in_32(4) & data_in_32(5) & data_in_32(6) & data_in_32(7);
     
        msg(31 downto 0) := crcreg xor concat_data_32;
        msg(40 downto 0) := To_StdLogicVector((To_bitvector(msg)) sll 8);

        for i in 0 to 31 loop
          msg(40 downto 0) := To_StdLogicVector((To_bitvector(msg)) sll 1);
          if (msg(40) = '1') then
            msg(39 downto 8) := msg(39 downto 8) xor poly_val;
          end if;
        end loop;
        crcgen_out_32 <= msg(39 downto 8);
     
      end if;
    end process;
         
    UNISIM_OUT: process (CRCOUT_zd)
    begin 
      CRCOUT <= CRCOUT_zd after 100 ps;
    end process;
  
end CRC32_V;
