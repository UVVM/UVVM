-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/stan/VITAL/RAMB8BWER.vhd,v 1.18 2012/10/04 03:01:33 wloo Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2005 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component 8K-Bit Data
--  /   /                       and 1K-Bit Parity Dual Port Block RAM
-- /___/   /\     Filename : RAMB8BWER.vhd
-- \   \  /  \    Timestamp : Thu May  1 16:42:27 PDT 2008
--  \___\/\___\
--
-- Revision:
--    05/01/08 - Initial version.
--    09/15/08 - Updated File open function to impure. (CR 478698)
--    11/03/08 - Fixed Async reset. (IR 494418)
--    11/19/08 - Fixed EN_RSTRAM_A/B = FALSE. (IR 497199)
--    12/10/08 - Fixed REGCE in output register (IR 499078). Fixed problem caused by IR 497199.
--    12/18/08 - Fixed write when async reset is asserted (IR 494418).
--    01/26/09 - Update reset behavior (IR 500935).
--    02/10/09 - Fixed regce behavior (IR 507042).
--    03/10/09 - X's the unused bits of outputs (CR 511363).
--    08/20/09 - Fixed address checking for collision (CR 529759).
--    02/25/10 - Added DRC of DATA_WIDTH_A/B = 36 is required for SDP mode (CR 550329).
--    03/15/10 - Updated address collision for asynchronous clocks and read first mode (CR 547447).
--             - Fixed DRC for SDP mode (CR 552920).
--    03/18/10 - Removed INIT_FILE support (CR 553511).
--    06/17/10 - Added WRITE_FIRST support in SDP mode.
--    07/13/10 - Initialized memory to zero for INIT_FILE (CR 560672).
--    09/30/10 - Updated address overlap for read first mode (CR 566026).
--    08/04/11 - Change RST_PRIORITY default to CE (CR 618583).
--    10/02/12 - Fixed read problem of init_file (CR 679413).
-- End Revision

----- CELL RAMB8BWER -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_TEXTIO.all;

library STD;
use STD.TEXTIO.all;

library unisim;
use unisim.vcomponents.all;
use unisim.vpkg.all;

entity RAMB8BWER is

  generic (
    
    DATA_WIDTH_A : integer := 0;
    DATA_WIDTH_B : integer := 0;
    DOA_REG : integer := 0;
    DOB_REG : integer := 0;
    EN_RSTRAM_A : boolean := TRUE;
    EN_RSTRAM_B : boolean := TRUE;
    INITP_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_08 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_09 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_10 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_11 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_12 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_13 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_14 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_15 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_16 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_17 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_18 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_19 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_A : bit_vector := X"00000";
    INIT_B : bit_vector := X"00000";
    INIT_FILE : string := "NONE";
    RAM_MODE : string := "TDP";
    RSTTYPE  : string := "SYNC";
    RST_PRIORITY_A : string := "CE";
    RST_PRIORITY_B : string := "CE";
    SETUP_ALL : time := 1000 ps;
    SETUP_READ_FIRST : time := 3000 ps;
    SIM_COLLISION_CHECK : string := "ALL";
    SRVAL_A : bit_vector := X"00000";
    SRVAL_B : bit_vector := X"00000";
    WRITE_MODE_A : string := "WRITE_FIRST";
    WRITE_MODE_B : string := "WRITE_FIRST"
    );

  port (

    DOADO : out std_logic_vector(15 downto 0);
    DOBDO : out std_logic_vector(15 downto 0);
    DOPADOP : out std_logic_vector(1 downto 0);
    DOPBDOP : out std_logic_vector(1 downto 0);

    ADDRAWRADDR : in std_logic_vector(12 downto 0);
    ADDRBRDADDR : in std_logic_vector(12 downto 0);
    CLKAWRCLK : in std_ulogic;
    CLKBRDCLK : in std_ulogic;
    DIADI : in std_logic_vector(15 downto 0);
    DIBDI : in std_logic_vector(15 downto 0);
    DIPADIP : in std_logic_vector(1 downto 0);
    DIPBDIP : in std_logic_vector(1 downto 0);
    ENAWREN : in std_ulogic;
    ENBRDEN : in std_ulogic;
    REGCEA : in std_ulogic;
    REGCEBREGCE : in std_ulogic;
    RSTA : in std_ulogic;
    RSTBRST : in std_ulogic;
    WEAWEL : in std_logic_vector(1 downto 0);
    WEBWEU : in std_logic_vector(1 downto 0)

    ); 
end RAMB8BWER;

-- Architecture body --

architecture RAMB8BWER_V of RAMB8BWER is

  
  function GetWidestWidth (
    wr_width_a : in integer;
    wr_width_b : in integer
    ) return integer is
    variable func_widest_width : integer;
  begin
    if (wr_width_a >= wr_width_b) then
      func_widest_width := wr_width_a;
    else
      func_widest_width := wr_width_b;
    end if;
    return func_widest_width;
  end;

    
  function GetWidth (
    rdwr_width : in integer
    ) return integer is
    variable func_width : integer;
  begin
    case rdwr_width is
      when 1 => func_width := 1;
      when 2 => func_width := 2;
      when 4 => func_width := 4;
      when 9 => func_width := 8;
      when 18 => func_width := 16;
      when 36 => func_width := 32;
      when others => func_width := 1;
    end case;
    return func_width;
  end;

    
  function GetWidthINITF (
    rdwr_width_initf : in integer
    ) return integer is
    variable func_width_initf : integer;
  begin
    case rdwr_width_initf is
      when 1 => func_width_initf := 4;
      when 2 => func_width_initf := 4;
      when 4 => func_width_initf := 4;
      when 9 => func_width_initf := 12;
      when 18 => func_width_initf := 20;
      when 36 => func_width_initf := 36;
      when 72 => func_width_initf := 72;
      when others => func_width_initf := 1;
    end case;
    return func_width_initf;
  end;

    
  function GetWidthp (
    rdwr_widthp : in integer
    ) return integer is
    variable func_widthp : integer;
  begin
    case rdwr_widthp is
      when 9 => func_widthp := 1;
      when 18 => func_widthp := 2;
      when 36 => func_widthp := 4;
      when others => func_widthp := 0;
    end case;
    return func_widthp;
  end;

    
  function GetWidthpINITF (
    rdwr_widthp_initf : in integer
    ) return integer is
    variable func_widthp_initf : integer;
  begin
    case rdwr_widthp_initf is
      when 9 => func_widthp_initf := 4;
      when 18 => func_widthp_initf := 4;
      when 36 => func_widthp_initf := 4;
      when 72 => func_widthp_initf := 8;
      when others => func_widthp_initf := 1;
    end case;
    return func_widthp_initf;
  end;


  function GetWidthpTmpWidthp (
    rdwr_tmp_widthp : in integer
    ) return integer is
    variable func_widthp_tmp : integer;
  begin
    case rdwr_tmp_widthp is
      when 1 | 2 | 4 => func_widthp_tmp := 0;
      when 9 => func_widthp_tmp := 1;
      when 18 => func_widthp_tmp := 2;
      when 36 => func_widthp_tmp := 4;
      when 72 => func_widthp_tmp := 8;
      when others => func_widthp_tmp := 8;
    end case;
    return func_widthp_tmp;
  end;

    
  function GetMemoryDepth (
    rdwr_width : in integer
    ) return integer is
    variable func_mem_depth : integer;
  begin
    case rdwr_width is
      when 1 => func_mem_depth := 8192;
      when 2 => func_mem_depth := 4096;
      when 4 => func_mem_depth := 2048;
      when 9 => func_mem_depth := 1024;
      when 18 => func_mem_depth := 512;
      when 36 => func_mem_depth := 256;
      when others => func_mem_depth := 8192;
    end case;
    return func_mem_depth;
  end;

  
  function GetMemoryDepthP (
    rdwr_width : in integer
    ) return integer is
    variable func_memp_depth : integer;
  begin
    case rdwr_width is
      when 9 => func_memp_depth := 1024;
      when 18 => func_memp_depth := 512;
      when 36 => func_memp_depth := 256;
      when others => func_memp_depth := 1024;
    end case;
    return func_memp_depth;
  end;

  
  function GetAddrbrdaddritLSB (
    rdwr_width : in integer
    ) return integer is
    variable func_lsb : integer;
  begin
    case rdwr_width is
      when 1 => func_lsb := 0;
      when 2 => func_lsb := 1;
      when 4 => func_lsb := 2;
      when 9 => func_lsb := 3;
      when 18 => func_lsb := 4;
      when 36 => func_lsb := 5;
      when others => func_lsb := 10;
    end case;
    return func_lsb;
  end;

    
  function GetAddrbrdaddrit124 (
    rdwr_width : in integer;
    w_width : in integer
    ) return integer is
    variable func_widest_width : integer;
  begin
    case rdwr_width is
      when 1 => case w_width is
                  when 2 => func_widest_width := 0;
                  when 4 => func_widest_width := 1;
                  when 9 => func_widest_width := 2;
                  when 18 => func_widest_width := 3;
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when 2 => case w_width is
                  when 4 => func_widest_width := 1;
                  when 9 => func_widest_width := 2;
                  when 18 => func_widest_width := 3;
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when 4 => case w_width is
                  when 9 => func_widest_width := 2;
                  when 18 => func_widest_width := 3;
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when others => func_widest_width := 10;
    end case;
    return func_widest_width;
  end;

  
  function GetAddrbrdaddrit8 (
    rdwr_width : in integer;
    w_width : in integer
    ) return integer is
    variable func_widest_width : integer;
  begin
    case rdwr_width is
      when 9 => case w_width is
                  when 18 => func_widest_width := 3;
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when others => func_widest_width := 10;
    end case;
    return func_widest_width;
  end;

  
  function GetAddrbrdaddrit16 (
    rdwr_width : in integer;
    w_width : in integer
    ) return integer is
    variable func_widest_width : integer;
  begin
    case rdwr_width is
      when 18 => case w_width is
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when others => func_widest_width := 10;
    end case;
    return func_widest_width;
  end;

  
  function GetAddrbrdaddrit32 (
    rdwr_width : in integer;
    w_width : in integer
    ) return integer is
    variable func_widest_width : integer;
  begin
    case rdwr_width is
      when 36 => case w_width is
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when others => func_widest_width := 10;
    end case;
    return func_widest_width;
  end;

  ---------------------------------------------------------------------------
  -- Function SLV_X_TO_HEX returns a hex string version of the std_logic_vector
  -- argument.
  ---------------------------------------------------------------------------
  function SLV_X_TO_HEX (
    SLV : in std_logic_vector;
    string_length : in integer
    ) return string is

    variable i : integer := 1;
    variable j : integer := 1;
    variable STR : string(string_length downto 1);
    variable nibble : std_logic_vector(3 downto 0) := "0000";
    variable full_nibble_count : integer := 0;
    variable remaining_bits : integer := 0;

  begin
    full_nibble_count := SLV'length/4;
    remaining_bits := SLV'length mod 4;
    for i in 1 to full_nibble_count loop
      nibble := SLV(((4*i) - 1) downto ((4*i) - 4));
      if (((nibble(0) xor nibble(1) xor nibble (2) xor nibble(3)) /= '1') and
          (nibble(0) xor nibble(1) xor nibble (2) xor nibble(3)) /= '0')  then
        STR(j) := 'x';
      elsif (nibble = "0000")  then
        STR(j) := '0';
      elsif (nibble = "0001")  then
        STR(j) := '1';
      elsif (nibble = "0010")  then
        STR(j) := '2';
      elsif (nibble = "0011")  then
        STR(j) := '3';
      elsif (nibble = "0100")  then
        STR(j) := '4';
      elsif (nibble = "0101")  then
        STR(j) := '5';
      elsif (nibble = "0110")  then
        STR(j) := '6';
      elsif (nibble = "0111")  then
        STR(j) := '7';
      elsif (nibble = "1000")  then
        STR(j) := '8';
      elsif (nibble = "1001")  then
        STR(j) := '9';
      elsif (nibble = "1010")  then
        STR(j) := 'a';
      elsif (nibble = "1011")  then
        STR(j) := 'b';
      elsif (nibble = "1100")  then
        STR(j) := 'c';
      elsif (nibble = "1101")  then
        STR(j) := 'd';
      elsif (nibble = "1110")  then
        STR(j) := 'e';
      elsif (nibble = "1111")  then
        STR(j) := 'f';
      end if;
      j := j + 1;
    end loop;
    
    if (remaining_bits /= 0) then
      nibble := "0000";
      nibble((remaining_bits -1) downto 0) := SLV((SLV'length -1) downto (SLV'length - remaining_bits));
      if (((nibble(0) xor nibble(1) xor nibble (2) xor nibble(3)) /= '1') and
          (nibble(0) xor nibble(1) xor nibble (2) xor nibble(3)) /= '0')  then
        STR(j) := 'x';
      elsif (nibble = "0000")  then
        STR(j) := '0';
      elsif (nibble = "0001")  then
        STR(j) := '1';
      elsif (nibble = "0010")  then
        STR(j) := '2';
      elsif (nibble = "0011")  then
        STR(j) := '3';
      elsif (nibble = "0100")  then
        STR(j) := '4';
      elsif (nibble = "0101")  then
        STR(j) := '5';
      elsif (nibble = "0110")  then
        STR(j) := '6';
      elsif (nibble = "0111")  then
        STR(j) := '7';
      elsif (nibble = "1000")  then
        STR(j) := '8';
      elsif (nibble = "1001")  then
        STR(j) := '9';
      elsif (nibble = "1010")  then
        STR(j) := 'a';
      elsif (nibble = "1011")  then
        STR(j) := 'b';
      elsif (nibble = "1100")  then
        STR(j) := 'c';
      elsif (nibble = "1101")  then
        STR(j) := 'd';
      elsif (nibble = "1110")  then
        STR(j) := 'e';
      elsif (nibble = "1111")  then
        STR(j) := 'f';
      end if;
    end if;    
    return STR;
  end SLV_X_TO_HEX;


  function INIT_SRVAL_SDP (
    int_port : integer;
    data_width : integer;
    input_b : bit_vector(19 downto 0);
    input_a : bit_vector(19 downto 0))
    return std_logic_vector is variable out_init_srval_std : std_logic_vector(35 downto 0);
    variable out_init_srval : bit_vector(35 downto 0);
  begin

    if (RAM_MODE = "SDP" and data_width = 36) then
      out_init_srval := input_b(17 downto 16) & input_a(17 downto 16) & input_b(15 downto 0) & input_a(15 downto 0);
    else

      if (int_port = 0) then            -- 0 = port A, 1 = port B
        out_init_srval := "000000000000000000" & input_a(17 downto 0);
      else
        out_init_srval := "000000000000000000" & input_b(17 downto 0);
      end if;
        
    end if;

    out_init_srval_std := To_StdLogicVector(out_init_srval);
    
    return out_init_srval_std;  
                         
  end;

                               
  constant widest_width : integer := GetWidestWidth(DATA_WIDTH_A, DATA_WIDTH_B);
  constant mem_depth : integer := GetMemoryDepth(widest_width);
  constant memp_depth : integer := GetMemoryDepthP(widest_width);
  constant width : integer := GetWidth(widest_width);
  constant widthp : integer := GetWidthp(widest_width);
  constant width_initf : integer := GetWidthINITF(widest_width);
  constant widthp_initf : integer := GetWidthpINITF(widest_width);  
  constant a_width : integer := GetWidth(DATA_WIDTH_A);
  constant b_width : integer := GetWidth(DATA_WIDTH_B);
  constant a_widthp : integer := GetWidthp(DATA_WIDTH_A);
  constant b_widthp : integer := GetWidthp(DATA_WIDTH_B);
  constant addrawraddr_lbit_124 : integer := GetAddrbrdaddritLSB(DATA_WIDTH_A);
  constant addrbrdaddr_lbit_124 : integer := GetAddrbrdaddritLSB(DATA_WIDTH_B);
  constant addrawraddr_bit_124 : integer := GetAddrbrdaddrit124(DATA_WIDTH_A, widest_width);
  constant addrbrdaddr_bit_124 : integer := GetAddrbrdaddrit124(DATA_WIDTH_B, widest_width);
  constant addrawraddr_bit_8 : integer := GetAddrbrdaddrit8(DATA_WIDTH_A, widest_width);
  constant addrbrdaddr_bit_8 : integer := GetAddrbrdaddrit8(DATA_WIDTH_B, widest_width);
  constant addrawraddr_bit_16 : integer := GetAddrbrdaddrit16(DATA_WIDTH_A, widest_width);
  constant addrbrdaddr_bit_16 : integer := GetAddrbrdaddrit16(DATA_WIDTH_B, widest_width);
  constant col_addr_lsb : integer := GetAddrbrdaddritLSB(widest_width);
  constant tmp_widthp : integer := GetWidthpTmpWidthp(widest_width);

  constant SYNC_PATH_DELAY : time  := 100 ps;
  
  type Two_D_array_type_tmp_mem is array ((mem_depth -  1) downto 0) of std_logic_vector((widest_width - 1) downto 0);
    
  type Two_D_array_type is array ((mem_depth -  1) downto 0) of std_logic_vector((width - 1) downto 0);
  type Two_D_parity_array_type is array ((memp_depth - 1) downto 0) of std_logic_vector((widthp -1) downto 0);

  type Two_D_array_type_initf is array ((mem_depth -  1) downto 0) of std_logic_vector((width_initf - 1) downto 0);
  type Two_D_parity_array_type_initf is array ((memp_depth - 1) downto 0) of std_logic_vector((widthp_initf -1) downto 0);


  signal ADDRAWRADDR_dly    : std_logic_vector(15 downto 0) := (others => 'X');
  signal CLKAWRCLK_dly     : std_ulogic                    := 'X';
  signal DIADI_dly      : std_logic_vector(63 downto 0) := (others => 'X');
  signal DIPADIP_dly     : std_logic_vector(7 downto 0)  := (others => 'X');
  signal ENAWREN_dly      : std_ulogic                    := 'X';
  signal REGCEA_dly   : std_ulogic                    := 'X';
  signal RSTA_dly     : std_ulogic                    := 'X';
  signal WEAWEL_dly      : std_logic_vector(7 downto 0)  := (others => 'X');
  signal ADDRBRDADDR_dly    : std_logic_vector(15 downto 0) := (others => 'X');
  signal CLKBRDCLK_dly     : std_ulogic                    := 'X';
  signal DIBDI_dly      : std_logic_vector(63 downto 0) := (others => 'X');
  signal DIPBDIP_dly     : std_logic_vector(7 downto 0)  := (others => 'X');
  signal ENBRDEN_dly      : std_ulogic                    := 'X';
  signal REGCEBREGCE_dly   : std_ulogic                    := 'X';
  signal RSTBRST_dly     : std_ulogic                    := 'X';
  signal WEBWEU_dly      : std_logic_vector(7 downto 0)  := (others => 'X');
  signal ox_addra_reconstruct : std_logic_vector(12 downto 0) := (others => 'X');
  signal ox_addrb_reconstruct : std_logic_vector(12 downto 0) := (others => 'X');
  
  signal doado_out : std_logic_vector(63 downto 0) := (others => 'X');
  signal dopadop_out : std_logic_vector(7 downto 0) := (others => 'X');
  signal doado_outreg : std_logic_vector(63 downto 0) := (others => 'X');
  signal dopadop_outreg : std_logic_vector(7 downto 0) := (others => 'X');
  signal dobdo_outreg : std_logic_vector(63 downto 0) := (others => 'X');
  signal dopbdop_outreg : std_logic_vector(7 downto 0) := (others => 'X');
  signal dobdo_out : std_logic_vector(63 downto 0) := (others => 'X');
  signal dopbdop_out : std_logic_vector(7 downto 0) := (others => 'X');

  signal doado_out_out : std_logic_vector(63 downto 0) := (others => 'X');
  signal dopadop_out_out : std_logic_vector(7 downto 0) := (others => 'X');
  signal dobdo_out_out : std_logic_vector(63 downto 0) := (others => 'X');
  signal dopbdop_out_out : std_logic_vector(7 downto 0) := (others => 'X');    
  signal GSR_dly : std_ulogic := '0';
  signal di_x : std_logic_vector(63 downto 0) := (others => 'X');

  signal SRVAL_A_STD : std_logic_vector(35 downto 0) := INIT_SRVAL_SDP(0, DATA_WIDTH_A, SRVAL_B, SRVAL_A);
  signal INIT_A_STD : std_logic_vector(35 downto 0) := INIT_SRVAL_SDP(0, DATA_WIDTH_A ,INIT_B, INIT_A);
  signal SRVAL_B_STD : std_logic_vector(35 downto 0) := INIT_SRVAL_SDP(1, DATA_WIDTH_B, SRVAL_B, SRVAL_A);
  signal INIT_B_STD : std_logic_vector(35 downto 0) := INIT_SRVAL_SDP(1, DATA_WIDTH_B ,INIT_B, INIT_A);

  
  function slv_to_two_D_array(
    slv_length : integer;
    slv_width : integer;
    SLV : in std_logic_vector
    )
    return two_D_array_type is
    variable two_D_array : two_D_array_type;
    variable intermediadite : std_logic_vector((slv_width - 1) downto 0);
  begin
    for i in 0 to (slv_length - 1) loop
      intermediadite := SLV(((i*slv_width) + (slv_width - 1)) downto (i* slv_width));
      two_D_array(i) := intermediadite; 
    end loop;
    return two_D_array;
  end;


  function slv_to_two_D_parity_array(
    slv_length : integer;
    slv_width : integer;
    SLV : in std_logic_vector
    )
    return two_D_parity_array_type is
    variable two_D_parity_array : two_D_parity_array_type;
    variable intermediadite : std_logic_vector((slv_width - 1) downto 0);
  begin
    for i in 0 to (slv_length - 1)loop
      intermediadite := SLV(((i*slv_width) + (slv_width - 1)) downto (i* slv_width));
      two_D_parity_array(i) := intermediadite; 
    end loop;
    return two_D_parity_array;
  end;


  impure function two_D_mem_initf(
    slv_width : integer
    )
    return two_D_array_type_tmp_mem is

    variable input_initf_tmp : Two_D_array_type_initf;
    variable input_initf : Two_D_array_type_tmp_mem := (others => (others => '0'));
    file int_infile : text;
    variable data_line, data_line_tmp, out_data_line : line;
    variable i : integer := 0;
    variable good_data : boolean := false;
    variable ignore_line : boolean := false;
    variable char_tmp : character;
    variable init_addr_slv : std_logic_vector(31 downto 0) := (others => '0');
    variable open_status : file_open_status;
    
  begin

    if (INIT_FILE /= "NONE") then
      
      file_open(open_status, int_infile, INIT_FILE, read_mode);

      while not endfile(int_infile) loop
          
        readline(int_infile, data_line);

        while (data_line /= null and data_line'length > 0) loop
          
          if (data_line(data_line'low to data_line'low + 1) = "//") then
            deallocate(data_line);

          elsif ((data_line(data_line'low to data_line'low + 1) = "/*") and (data_line(data_line'high-1 to data_line'high) = "*/")) then
            deallocate(data_line);

          elsif (data_line(data_line'low to data_line'low + 1) = "/*") then
            deallocate(data_line);
            ignore_line := true;

          elsif (ignore_line = true and data_line(data_line'high-1 to data_line'high) = "*/") then
            deallocate(data_line);
            ignore_line := false;


          elsif (ignore_line = false and data_line(data_line'low) = '@') then
            read(data_line, char_tmp);
            hread(data_line, init_addr_slv, good_data);

            i := SLV_TO_INT(init_addr_slv);

          elsif (ignore_line = false) then

            hread(data_line, input_initf_tmp(i), good_data);
            input_initf(i)(slv_width - 1 downto 0) := input_initf_tmp(i)(slv_width - 1 downto 0);
          
            if (good_data = true) then
              i := i + 1;             
            end if;
          else
            deallocate(data_line);
                     
          end if;
        
        end loop;
        
      end loop;

    end if;
        
    return input_initf;

  end;


  function two_D_mem_init(  
    slv_length : integer;
    slv_width : integer;
    SLV : in std_logic_vector;
    temp_mem : two_D_array_type_tmp_mem
    )
    return two_D_array_type is
    variable two_D_array_mem_init : two_D_array_type;
  begin
     if (INIT_FILE = "NONE") then
       two_D_array_mem_init := slv_to_two_D_array(slv_length, slv_width, SLV);
     else

       for i in 0 to (slv_length - 1) loop
         two_D_array_mem_init(i)(slv_width-1 downto 0) := temp_mem(i)(slv_width-1 downto 0);
       end loop;
                           
     end if;
     return two_D_array_mem_init;
  end;


  function two_D_mem_initp(  
    slv_length : integer;
    slv_width : integer;
    SLV : in std_logic_vector;
    temp_mem : two_D_array_type_tmp_mem;
    mem_width : integer
    )
    return two_D_parity_array_type is
    variable two_D_array_mem_initp : two_D_parity_array_type;
  begin
     if (INIT_FILE = "NONE") then
       two_D_array_mem_initp := slv_to_two_D_parity_array(slv_length, slv_width, SLV);
     else

       if (slv_width > 0) then
         
         for i in 0 to (slv_length - 1) loop
           two_D_array_mem_initp(i)(slv_width-1 downto 0) := temp_mem(i)(mem_width + slv_width - 1 downto mem_width);
         end loop;

       end if;
     end if;
     return two_D_array_mem_initp;
  end;


  procedure prcd_chk_for_col_msg (
    constant viol_time_tmp : in integer;
    constant weawel_tmp : in std_ulogic;
    constant webweu_tmp : in std_ulogic;
    constant addrawraddr_tmp : in std_logic_vector (15 downto 0);
    constant addrbrdaddr_tmp : in std_logic_vector (15 downto 0);
    variable col_wr_wr_msg : inout std_ulogic;
    variable col_wra_rdb_msg : inout std_ulogic;
    variable col_wrb_rda_msg : inout std_ulogic;
    variable chk_col_same_clk_tmp : inout integer;
    variable chk_ox_same_clk_tmp : inout integer;
    variable chk_ox_msg_tmp : inout integer
    ) is
    
    variable string_length_1 : integer;
    variable string_length_2 : integer;
    variable message : LINE;
    constant MsgSeverity : severity_level := Error;

  begin
    
    if (SIM_COLLISION_CHECK = "ALL" or SIM_COLLISION_CHECK = "WARNING_ONLY") then
    
      if ((addrawraddr_tmp'length mod 4) = 0) then
        string_length_1 := addrawraddr_tmp'length/4;
      elsif ((addrawraddr_tmp'length mod 4) > 0) then
        string_length_1 := addrawraddr_tmp'length/4 + 1;      
      end if;
      if ((addrbrdaddr_tmp'length mod 4) = 0) then
        string_length_2 := addrbrdaddr_tmp'length/4;
      elsif ((addrbrdaddr_tmp'length mod 4) > 0) then
        string_length_2 := addrbrdaddr_tmp'length/4 + 1;      
      end if;

      if (weawel_tmp = '1' and webweu_tmp = '1' and col_wr_wr_msg = '1') then

        if (chk_ox_msg_tmp = 1) then
          
          if (not(chk_ox_same_clk_tmp = 1)) then

            Write ( message, STRING'(" Address Overlap Error on RAMB8BWER :"));
            Write ( message, STRING'(RAMB8BWER'path_name));
            Write ( message, STRING'(" at simulation time "));
            Write ( message, now);
            Write ( message, STRING'("."));
            Write ( message, LF );
            Write ( message, STRING'(" A write was requested to the overlapped address simultaneously at both Port A and Port B of the RAM."));
            Write ( message, STRING'(" The contents written to the RAM at address location "));      
            Write ( message, SLV_X_TO_HEX(addrawraddr_tmp, string_length_1));
            Write ( message, STRING'(" (hex) "));            
            Write ( message, STRING'("of Port A and address location "));
            Write ( message, SLV_X_TO_HEX(addrbrdaddr_tmp, string_length_2));
            Write ( message, STRING'(" (hex) "));            
            Write ( message, STRING'("of Port B are unknown. "));
            ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
            DEALLOCATE (message);

          end if;

        else
          
          Write ( message, STRING'(" Memory Collision Error on RAMB8BWER :"));
          Write ( message, STRING'(RAMB8BWER'path_name));
          Write ( message, STRING'(" at simulation time "));
          Write ( message, now);
          Write ( message, STRING'("."));
          Write ( message, LF );
          Write ( message, STRING'(" A write was requested to the same address simultaneously at both Port A and Port B of the RAM."));
          Write ( message, STRING'(" The contents written to the RAM at address location "));      
          Write ( message, SLV_X_TO_HEX(addrawraddr_tmp, string_length_1));
          Write ( message, STRING'(" (hex) "));            
          Write ( message, STRING'("of Port A and address location "));
          Write ( message, SLV_X_TO_HEX(addrbrdaddr_tmp, string_length_2));
          Write ( message, STRING'(" (hex) "));            
          Write ( message, STRING'("of Port B are unknown. "));
          ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
          DEALLOCATE (message);

        end if;
        
        col_wr_wr_msg := '0';
        
      elsif (weawel_tmp = '1' and webweu_tmp = '0' and col_wra_rdb_msg = '1') then

        if (chk_ox_msg_tmp = 1) then

          if (not(chk_ox_same_clk_tmp = 1)) then

            Write ( message, STRING'(" Address Overlap Error on RAMB8BWER :"));
            Write ( message, STRING'(RAMB8BWER'path_name));
            Write ( message, STRING'(" at simulation time "));
            Write ( message, now);
            Write ( message, STRING'("."));
            Write ( message, LF );            
            Write ( message, STRING'(" A read was performed on address "));
            Write ( message, SLV_X_TO_HEX(addrbrdaddr_tmp, string_length_2));
            Write ( message, STRING'(" (hex) "));            
            Write ( message, STRING'("of port B while a write was requested to the overlapped address "));
            Write ( message, SLV_X_TO_HEX(addrawraddr_tmp, string_length_1));
            Write ( message, STRING'(" (hex) "));
            Write ( message, STRING'("of Port A. "));
            Write ( message, STRING'(" The write will be unsuccessful and the contents of the RAM at both address locations of port A and B became unknown. "));
            ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
            DEALLOCATE (message);

          end if;

        else

          if ((WRITE_MODE_A = "READ_FIRST" or WRITE_MODE_B = "READ_FIRST")
              and (not(chk_col_same_clk_tmp = 1))) then

            Write ( message, STRING'(" Memory Collision Error on RAMB8BWER :"));
            Write ( message, STRING'(RAMB8BWER'path_name));
            Write ( message, STRING'(" at simulation time "));
            Write ( message, now);
            Write ( message, STRING'("."));
            Write ( message, LF );            
            Write ( message, STRING'(" A read was performed on address "));
            Write ( message, SLV_X_TO_HEX(addrbrdaddr_tmp, string_length_2));
            Write ( message, STRING'(" (hex) "));            
            Write ( message, STRING'("of port B while a write was requested to the same address on Port A. "));
            Write ( message, STRING'(" The write will be unsuccessful and the contents of the RAM at both address locations of port A and B became unknown. "));
            ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
            DEALLOCATE (message);

          elsif (WRITE_MODE_A /= "READ_FIRST") then
            
            Write ( message, STRING'(" Memory Collision Error on RAMB8BWER :"));
            Write ( message, STRING'(RAMB8BWER'path_name));
            Write ( message, STRING'(" at simulation time "));
            Write ( message, now);
            Write ( message, STRING'("."));
            Write ( message, LF );            
            Write ( message, STRING'(" A read was performed on address "));
            Write ( message, SLV_X_TO_HEX(addrbrdaddr_tmp, string_length_2));
            Write ( message, STRING'(" (hex) "));            
            Write ( message, STRING'("of port B while a write was requested to the same address on Port A. "));
            Write ( message, STRING'(" The write will be successful however the read value on port B is unknown until the next CLKB cycle. "));
            ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
            DEALLOCATE (message);

          end if;

        end if;

        col_wra_rdb_msg := '0';
        
      elsif (weawel_tmp = '0' and webweu_tmp = '1' and col_wrb_rda_msg = '1') then

        if (chk_ox_msg_tmp = 1) then

          if (not(chk_ox_same_clk_tmp = 1)) then

            Write ( message, STRING'(" Address Overlap Error on RAMB8BWER :"));
            Write ( message, STRING'(RAMB8BWER'path_name));
            Write ( message, STRING'(" at simulation time "));
            Write ( message, now);
            Write ( message, STRING'("."));
            Write ( message, LF );            
            Write ( message, STRING'(" A read was performed on address "));
            Write ( message, SLV_X_TO_HEX(addrawraddr_tmp, string_length_1));
            Write ( message, STRING'(" (hex) "));            
            Write ( message, STRING'("of port A while a write was requested to the overlapped address "));
            Write ( message, SLV_X_TO_HEX(addrbrdaddr_tmp, string_length_2));
            Write ( message, STRING'(" (hex) "));
            Write ( message, STRING'("of Port B. "));
            Write ( message, STRING'(" The write will be unsuccessful and the contents of the RAM at both address locations of port A and B became unknown. "));
            ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
            DEALLOCATE (message);

          end if;

        else

          if ((WRITE_MODE_A = "READ_FIRST" or WRITE_MODE_B = "READ_FIRST")
              and (not(chk_col_same_clk_tmp = 1))) then

            Write ( message, STRING'(" Memory Collision Error on RAMB8BWER :"));
            Write ( message, STRING'(RAMB8BWER'path_name));
            Write ( message, STRING'(" at simulation time "));
            Write ( message, now);
            Write ( message, STRING'("."));
            Write ( message, LF );            
            Write ( message, STRING'(" A read was performed on address "));
            Write ( message, SLV_X_TO_HEX(addrawraddr_tmp, string_length_1));
            Write ( message, STRING'(" (hex) "));            
            Write ( message, STRING'("of port A while a write was requested to the same address on Port B. "));
            Write ( message, STRING'(" The write will be unsuccessful and the contents of the RAM at both address locations of port A and B became unknown. "));
            ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
            DEALLOCATE (message);

          elsif (WRITE_MODE_B /= "READ_FIRST") then
            
            Write ( message, STRING'(" Memory Collision Error on RAMB8BWER :"));
            Write ( message, STRING'(RAMB8BWER'path_name));
            Write ( message, STRING'(" at simulation time "));
            Write ( message, now);
            Write ( message, STRING'("."));
            Write ( message, LF );            
            Write ( message, STRING'(" A read was performed on address "));
            Write ( message, SLV_X_TO_HEX(addrawraddr_tmp, string_length_1));
            Write ( message, STRING'(" (hex) "));            
            Write ( message, STRING'("of port A while a write was requested to the same address on Port B. "));
            Write ( message, STRING'(" The write will be successful however the read value on port A is unknown until the next CLKB cycle. "));
            ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
            DEALLOCATE (message);

          end if;

        end if;

        col_wrb_rda_msg := '0';
        
      end if;      

    end if;
    
  end prcd_chk_for_col_msg;


  procedure prcd_write_ram (
    constant we : in std_logic;
    constant di : in std_logic_vector;
    constant dip : in std_logic;
    variable mem_proc : inout std_logic_vector;
    variable memp_proc : inout std_logic
    ) is
    
    alias di_tmp : std_logic_vector (di'length-1 downto 0) is di;
    alias mem_proc_tmp : std_logic_vector (mem_proc'length-1 downto 0) is mem_proc;

    begin
      if (we = '1') then
        mem_proc_tmp := di_tmp;

        if (width >= 8) then
          memp_proc := dip;
        end if;
      end if;
  end prcd_write_ram;

    
  procedure prcd_write_ram_col (
    constant we_o : in std_logic;
    constant we : in std_logic;
    constant di : in std_logic_vector;
    constant dip : in std_logic;
    variable mem_proc : inout std_logic_vector;
    variable memp_proc : inout std_logic
    ) is
    
    alias di_tmp : std_logic_vector (di'length-1 downto 0) is di;
    alias mem_proc_tmp : std_logic_vector (mem_proc'length-1 downto 0) is mem_proc;
    variable i : integer := 0;
    
    begin
      if (we = '1') then

        for i in 0 to di'length-1 loop
          if ((mem_proc_tmp(i) /= 'X') or (not(we = we_o and we = '1'))) then
            mem_proc_tmp(i) := di_tmp(i);
          end if;
        end loop;

        if (width >= 8 and ((memp_proc /= 'X') or (not(we = we_o and we = '1')))) then
          memp_proc := dip;
        end if;

      end if;
  end prcd_write_ram_col;


  procedure prcd_write_ram_ox (
    constant we_o : in std_logic;
    constant we : in std_logic;
    constant di : in std_logic_vector;
    constant dip : in std_logic;
    variable mem_proc : inout std_logic_vector;
    variable memp_proc : inout std_logic
    ) is
    
    alias di_tmp : std_logic_vector (di'length-1 downto 0) is di;
    alias mem_proc_tmp : std_logic_vector (mem_proc'length-1 downto 0) is mem_proc;
    variable i : integer := 0;
    
    begin
      if (we = '1') then

        for i in 0 to di'length-1 loop
          mem_proc_tmp(i) := di_tmp(i);
        end loop;

        if (width >= 8) then
          memp_proc := dip;
        end if;

      end if;
  end prcd_write_ram_ox;

  
  procedure prcd_x_buf (
    constant wr_rd_mode : in std_logic_vector (1 downto 0);
    constant do_uindex : in integer;
    constant do_lindex : in integer;
    constant dop_index : in integer;
    constant do_ltmp : in std_logic_vector (63 downto 0);
    variable do_tmp : inout std_logic_vector (63 downto 0);
    constant dop_ltmp : in std_logic_vector (7 downto 0);
    variable dop_tmp : inout std_logic_vector (7 downto 0)
    ) is
    
    variable i : integer;

    begin
      if (wr_rd_mode = "01") then
        for i in do_lindex to do_uindex loop
          if (do_ltmp(i) = 'X') then
            do_tmp(i) := 'X';
          end if;
        end loop;
        
        if (dop_ltmp(dop_index) = 'X') then
          dop_tmp(dop_index) := 'X';
        end if;
          
      else
        do_tmp(do_lindex + 7 downto do_lindex) := do_ltmp(do_lindex + 7 downto do_lindex);
        dop_tmp(dop_index) := dop_ltmp(dop_index);
      end if;

  end prcd_x_buf;

    
  procedure prcd_rd_ram_a (
    constant addrawraddr_tmp : in std_logic_vector (15 downto 0);
    variable doado_tmp : inout std_logic_vector (63 downto 0);
    variable dopadop_tmp : inout std_logic_vector (7 downto 0);
    constant mem : in Two_D_array_type;
    constant memp : in Two_D_parity_array_type     
    ) is
    variable prcd_tmp_addrawraddr_dly_depth : integer;
    variable prcd_tmp_addrawraddr_dly_width : integer;

  begin
    
    case a_width is

      when 1 | 2 | 4 => if (a_width >= width) then
                          prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_lbit_124));
                          doado_tmp(a_width-1 downto 0) := mem(prcd_tmp_addrawraddr_dly_depth);
                        else
                          prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_bit_124 + 1));
                          prcd_tmp_addrawraddr_dly_width := SLV_TO_INT(addrawraddr_tmp(addrawraddr_bit_124 downto addrawraddr_lbit_124));
                          doado_tmp(a_width-1 downto 0) := mem(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * a_width) + a_width - 1 downto prcd_tmp_addrawraddr_dly_width * a_width);
                        end if;

      when 8 => if (a_width >= width) then
                  prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto 3));
                  doado_tmp(7 downto 0) := mem(prcd_tmp_addrawraddr_dly_depth);
                  dopadop_tmp(0 downto 0) := memp(prcd_tmp_addrawraddr_dly_depth);
                else
                  prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_bit_8 + 1));
                  prcd_tmp_addrawraddr_dly_width := SLV_TO_INT(addrawraddr_tmp(addrawraddr_bit_8 downto 3));
                  doado_tmp(7 downto 0) := mem(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * 8) + 7 downto prcd_tmp_addrawraddr_dly_width * 8);
                  dopadop_tmp(0 downto 0) := memp(prcd_tmp_addrawraddr_dly_depth)(prcd_tmp_addrawraddr_dly_width downto prcd_tmp_addrawraddr_dly_width);
                end if;

      when 16 => if (a_width >= width) then
                  prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto 4));
                  doado_tmp(15 downto 0) := mem(prcd_tmp_addrawraddr_dly_depth);
                  dopadop_tmp(1 downto 0) := memp(prcd_tmp_addrawraddr_dly_depth);
                 else
                  prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_bit_16 + 1));
                  prcd_tmp_addrawraddr_dly_width := SLV_TO_INT(addrawraddr_tmp(addrawraddr_bit_16 downto 4));
                  doado_tmp(15 downto 0) := mem(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * 16) + 15 downto prcd_tmp_addrawraddr_dly_width * 16);
                  dopadop_tmp(1 downto 0) := memp(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * 2) + 1 downto prcd_tmp_addrawraddr_dly_width * 2);
                 end if;

      when 32 => if (a_width >= width) then
                  prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto 5));
                  doado_tmp(31 downto 0) := mem(prcd_tmp_addrawraddr_dly_depth);
                  dopadop_tmp(3 downto 0) := memp(prcd_tmp_addrawraddr_dly_depth);
                end if;

      when others => null;

    end case;

  end prcd_rd_ram_a;

  
  procedure prcd_rd_ram_b (
    constant addrbrdaddr_tmp : in std_logic_vector (15 downto 0);
    variable dobdo_tmp : inout std_logic_vector (63 downto 0);
    variable dopbdop_tmp : inout std_logic_vector (7 downto 0);
    constant mem : in Two_D_array_type;
    constant memp : in Two_D_parity_array_type     
    ) is
    variable prcd_tmp_addrbrdaddr_dly_depth : integer;
    variable prcd_tmp_addrbrdaddr_dly_width : integer;

  begin
    
    case b_width is

      when 1 | 2 | 4 => if (b_width >= width) then
                          prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_lbit_124));
                          dobdo_tmp(b_width-1 downto 0) := mem(prcd_tmp_addrbrdaddr_dly_depth);
                        else
                          prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_bit_124 + 1));
                          prcd_tmp_addrbrdaddr_dly_width := SLV_TO_INT(addrbrdaddr_tmp(addrbrdaddr_bit_124 downto addrbrdaddr_lbit_124));
                          dobdo_tmp(b_width-1 downto 0) := mem(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * b_width) + b_width - 1 downto prcd_tmp_addrbrdaddr_dly_width * b_width);
                        end if;

      when 8 => if (b_width >= width) then
                  prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto 3));
                  dobdo_tmp(7 downto 0) := mem(prcd_tmp_addrbrdaddr_dly_depth);
                  dopbdop_tmp(0 downto 0) := memp(prcd_tmp_addrbrdaddr_dly_depth);
                else
                  prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_bit_8 + 1));
                  prcd_tmp_addrbrdaddr_dly_width := SLV_TO_INT(addrbrdaddr_tmp(addrbrdaddr_bit_8 downto 3));
                  dobdo_tmp(7 downto 0) := mem(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * 8) + 7 downto prcd_tmp_addrbrdaddr_dly_width * 8);
                  dopbdop_tmp(0 downto 0) := memp(prcd_tmp_addrbrdaddr_dly_depth)(prcd_tmp_addrbrdaddr_dly_width downto prcd_tmp_addrbrdaddr_dly_width);
                end if;

      when 16 => if (b_width >= width) then
                  prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto 4));
                  dobdo_tmp(15 downto 0) := mem(prcd_tmp_addrbrdaddr_dly_depth);
                  dopbdop_tmp(1 downto 0) := memp(prcd_tmp_addrbrdaddr_dly_depth);
                 else
                  prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_bit_16 + 1));
                  prcd_tmp_addrbrdaddr_dly_width := SLV_TO_INT(addrbrdaddr_tmp(addrbrdaddr_bit_16 downto 4));
                  dobdo_tmp(15 downto 0) := mem(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * 16) + 15 downto prcd_tmp_addrbrdaddr_dly_width * 16);
                  dopbdop_tmp(1 downto 0) := memp(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * 2) + 1 downto prcd_tmp_addrbrdaddr_dly_width * 2);
                 end if;

      when 32 => if (b_width >= width) then
                  prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto 5));
                  dobdo_tmp(31 downto 0) := mem(prcd_tmp_addrbrdaddr_dly_depth);
                  dopbdop_tmp(3 downto 0) := memp(prcd_tmp_addrbrdaddr_dly_depth);
                end if;

      when others => null;

    end case;

  end prcd_rd_ram_b;


  procedure prcd_col_wr_ram_a (
    constant viol_time_tmp : in integer;
    constant seq : in std_logic_vector (1 downto 0);
    constant webweu_tmp : in std_logic_vector (7 downto 0);
    constant weawel_tmp : in std_logic_vector (7 downto 0);
    constant diadi_tmp : in std_logic_vector (63 downto 0);
    constant dipadip_tmp : in std_logic_vector (7 downto 0);
    constant addrbrdaddr_tmp : in std_logic_vector (15 downto 0);
    constant addrawraddr_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type;
    variable col_wr_wr_msg : inout std_ulogic;
    variable col_wra_rdb_msg : inout std_ulogic;
    variable col_wrb_rda_msg : inout std_ulogic;
    variable chk_col_same_clk_tmp : inout integer;
    variable chk_ox_same_clk_tmp : inout integer;
    variable chk_ox_msg_tmp : inout integer
    ) is
    variable prcd_tmp_addrawraddr_dly_depth : integer;
    variable prcd_tmp_addrawraddr_dly_width : integer;
    variable junk : std_ulogic;

  begin
    
    case a_width is

      when 1 | 2 | 4 => if (not(weawel_tmp(0) = '1' and webweu_tmp(0) = '1' and a_width > b_width) or seq = "10") then
                          if (a_width >= width) then
                            prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_lbit_124));
                            prcd_write_ram_col (webweu_tmp(0), weawel_tmp(0), diadi_tmp(a_width-1 downto 0), '0', mem(prcd_tmp_addrawraddr_dly_depth), junk);
                          else
                            prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_bit_124 + 1));
                            prcd_tmp_addrawraddr_dly_width := SLV_TO_INT(addrawraddr_tmp(addrawraddr_bit_124 downto addrawraddr_lbit_124));
                            prcd_write_ram_col (webweu_tmp(0), weawel_tmp(0), diadi_tmp(a_width-1 downto 0), '0', mem(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * a_width) + a_width - 1 downto (prcd_tmp_addrawraddr_dly_width * a_width)), junk);
                          end if;

                          if (seq = "00") then
                            prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(0), webweu_tmp(0), addrawraddr_tmp, addrbrdaddr_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                          end if;
                        end if;
      
      when 8 => if (not(weawel_tmp(0) = '1' and webweu_tmp(0) = '1' and a_width > b_width) or seq = "10") then
                  if (a_width >= width) then
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto 3));
                    prcd_write_ram_col (webweu_tmp(0), weawel_tmp(0), diadi_tmp(7 downto 0), dipadip_tmp(0), mem(prcd_tmp_addrawraddr_dly_depth), memp(prcd_tmp_addrawraddr_dly_depth)(0));
                  else
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_bit_8 + 1));
                    prcd_tmp_addrawraddr_dly_width := SLV_TO_INT(addrawraddr_tmp(addrawraddr_bit_8 downto 3));
                    prcd_write_ram_col (webweu_tmp(0), weawel_tmp(0), diadi_tmp(7 downto 0), dipadip_tmp(0), mem(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * 8) + 7 downto (prcd_tmp_addrawraddr_dly_width * 8)), memp(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width)));
                  end if;
  
                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(0), webweu_tmp(0), addrawraddr_tmp, addrbrdaddr_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;
                end if;

      when 16 => if (not(weawel_tmp(0) = '1' and webweu_tmp(0) = '1' and a_width > b_width) or seq = "10") then
                  if (a_width >= width) then
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto 4));
                    prcd_write_ram_col (webweu_tmp(0), weawel_tmp(0), diadi_tmp(7 downto 0), dipadip_tmp(0), mem(prcd_tmp_addrawraddr_dly_depth)(7 downto 0), memp(prcd_tmp_addrawraddr_dly_depth)(0));
                  else
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_bit_16 + 1));
                    prcd_tmp_addrawraddr_dly_width := SLV_TO_INT(addrawraddr_tmp(addrawraddr_bit_16 downto 4));
                    prcd_write_ram_col (webweu_tmp(0), weawel_tmp(0), diadi_tmp(7 downto 0), dipadip_tmp(0), mem(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * 16) + 7 downto (prcd_tmp_addrawraddr_dly_width * 16)), memp(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * 2)));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(0), webweu_tmp(0), addrawraddr_tmp, addrbrdaddr_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;
                 
                  if (a_width >= width) then
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto 4));
                    prcd_write_ram_col (webweu_tmp(1), weawel_tmp(1), diadi_tmp(15 downto 8), dipadip_tmp(1), mem(prcd_tmp_addrawraddr_dly_depth)(15 downto 8), memp(prcd_tmp_addrawraddr_dly_depth)(1));
                  else
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_bit_16 + 1));
                    prcd_tmp_addrawraddr_dly_width := SLV_TO_INT(addrawraddr_tmp(addrawraddr_bit_16 downto 4));
                    prcd_write_ram_col (webweu_tmp(1), weawel_tmp(1), diadi_tmp(15 downto 8), dipadip_tmp(1), mem(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * 16) + 15 downto (prcd_tmp_addrawraddr_dly_width * 16) + 8), memp(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * 2) + 1));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(1), webweu_tmp(1), addrawraddr_tmp, addrbrdaddr_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;
                 
                end if;

      when 32 => if (not(weawel_tmp(0) = '1' and webweu_tmp(0) = '1' and a_width > b_width) or seq = "10") then

                   prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto 5));
                   prcd_write_ram_col (webweu_tmp(0), weawel_tmp(0), diadi_tmp(7 downto 0), dipadip_tmp(0), mem(prcd_tmp_addrawraddr_dly_depth)(7 downto 0), memp(prcd_tmp_addrawraddr_dly_depth)(0));

                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(0), webweu_tmp(0), addrawraddr_tmp, addrbrdaddr_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_col (webweu_tmp(1), weawel_tmp(1), diadi_tmp(15 downto 8), dipadip_tmp(1), mem(prcd_tmp_addrawraddr_dly_depth)(15 downto 8), memp(prcd_tmp_addrawraddr_dly_depth)(1));

                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(1), webweu_tmp(1), addrawraddr_tmp, addrbrdaddr_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
                   
                   prcd_write_ram_col (webweu_tmp(2), weawel_tmp(2), diadi_tmp(23 downto 16), dipadip_tmp(2), mem(prcd_tmp_addrawraddr_dly_depth)(23 downto 16), memp(prcd_tmp_addrawraddr_dly_depth)(2));

                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(2), webweu_tmp(2), addrawraddr_tmp, addrbrdaddr_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_col (webweu_tmp(3), weawel_tmp(3), diadi_tmp(31 downto 24), dipadip_tmp(3), mem(prcd_tmp_addrawraddr_dly_depth)(31 downto 24), memp(prcd_tmp_addrawraddr_dly_depth)(3));

                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(3), webweu_tmp(3), addrawraddr_tmp, addrbrdaddr_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                 end if;

      when others => null;

    end case;

  end prcd_col_wr_ram_a;


  procedure prcd_ox_wr_ram_a (
    constant viol_time_tmp : in integer;
    constant seq : in std_logic_vector (1 downto 0);
    constant webweu_tmp : in std_logic_vector (7 downto 0);
    constant weawel_tmp : in std_logic_vector (7 downto 0);
    constant diadi_tmp : in std_logic_vector (63 downto 0);
    constant dipadip_tmp : in std_logic_vector (7 downto 0);
    constant addrbrdaddr_tmp : in std_logic_vector (15 downto 0);
    constant addrawraddr_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type;
    variable ox_wr_wr_msg : inout std_ulogic;
    variable ox_wra_rdb_msg : inout std_ulogic;
    variable ox_wrb_rda_msg : inout std_ulogic;
    variable chk_col_same_clk_tmp : inout integer;
    variable chk_ox_same_clk_tmp : inout integer;
    variable chk_ox_msg_tmp : inout integer
    ) is
    variable prcd_tmp_addrawraddr_dly_depth : integer;
    variable prcd_tmp_addrawraddr_dly_width : integer;
    variable junk : std_ulogic;

  begin
    
    case a_width is

      when 1 | 2 | 4 => if (not(weawel_tmp(0) = '1' and webweu_tmp(0) = '1' and a_width > b_width) or seq = "10") then
                          if (a_width >= width) then
                            prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_lbit_124));
                            prcd_write_ram_ox (webweu_tmp(0), weawel_tmp(0), diadi_tmp(a_width-1 downto 0), '0', mem(prcd_tmp_addrawraddr_dly_depth), junk);
                          else
                            prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_bit_124 + 1));
                            prcd_tmp_addrawraddr_dly_width := SLV_TO_INT(addrawraddr_tmp(addrawraddr_bit_124 downto addrawraddr_lbit_124));
                            prcd_write_ram_ox (webweu_tmp(0), weawel_tmp(0), diadi_tmp(a_width-1 downto 0), '0', mem(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * a_width) + a_width - 1 downto (prcd_tmp_addrawraddr_dly_width * a_width)), junk);
                          end if;

                          if (seq = "00") then
                            prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(0), webweu_tmp(0), addrawraddr_tmp, addrbrdaddr_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                          end if;
                        end if;
      
      when 8 => if (not(weawel_tmp(0) = '1' and webweu_tmp(0) = '1' and a_width > b_width) or seq = "10") then
                  if (a_width >= width) then
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto 3));
                    prcd_write_ram_ox (webweu_tmp(0), weawel_tmp(0), diadi_tmp(7 downto 0), dipadip_tmp(0), mem(prcd_tmp_addrawraddr_dly_depth), memp(prcd_tmp_addrawraddr_dly_depth)(0));
                  else
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_bit_8 + 1));
                    prcd_tmp_addrawraddr_dly_width := SLV_TO_INT(addrawraddr_tmp(addrawraddr_bit_8 downto 3));
                    prcd_write_ram_ox (webweu_tmp(0), weawel_tmp(0), diadi_tmp(7 downto 0), dipadip_tmp(0), mem(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * 8) + 7 downto (prcd_tmp_addrawraddr_dly_width * 8)), memp(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width)));
                  end if;
  
                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(0), webweu_tmp(0), addrawraddr_tmp, addrbrdaddr_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;
                end if;

      when 16 => if (not(weawel_tmp(0) = '1' and webweu_tmp(0) = '1' and a_width > b_width) or seq = "10") then
                  if (a_width >= width) then
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto 4));
                    prcd_write_ram_ox (webweu_tmp(0), weawel_tmp(0), diadi_tmp(7 downto 0), dipadip_tmp(0), mem(prcd_tmp_addrawraddr_dly_depth)(7 downto 0), memp(prcd_tmp_addrawraddr_dly_depth)(0));
                  else
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_bit_16 + 1));
                    prcd_tmp_addrawraddr_dly_width := SLV_TO_INT(addrawraddr_tmp(addrawraddr_bit_16 downto 4));
                    prcd_write_ram_ox (webweu_tmp(0), weawel_tmp(0), diadi_tmp(7 downto 0), dipadip_tmp(0), mem(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * 16) + 7 downto (prcd_tmp_addrawraddr_dly_width * 16)), memp(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * 2)));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(0), webweu_tmp(0), addrawraddr_tmp, addrbrdaddr_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;
                 
                  if (a_width >= width) then
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto 4));
                    prcd_write_ram_ox (webweu_tmp(1), weawel_tmp(1), diadi_tmp(15 downto 8), dipadip_tmp(1), mem(prcd_tmp_addrawraddr_dly_depth)(15 downto 8), memp(prcd_tmp_addrawraddr_dly_depth)(1));
                  else
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_bit_16 + 1));
                    prcd_tmp_addrawraddr_dly_width := SLV_TO_INT(addrawraddr_tmp(addrawraddr_bit_16 downto 4));
                    prcd_write_ram_ox (webweu_tmp(1), weawel_tmp(1), diadi_tmp(15 downto 8), dipadip_tmp(1), mem(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * 16) + 15 downto (prcd_tmp_addrawraddr_dly_width * 16) + 8), memp(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * 2) + 1));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(1), webweu_tmp(1), addrawraddr_tmp, addrbrdaddr_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;
                 
                end if;

      when 32 => if (not(weawel_tmp(0) = '1' and webweu_tmp(0) = '1' and a_width > b_width) or seq = "10") then

                   prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto 5));
                   prcd_write_ram_ox (webweu_tmp(0), weawel_tmp(0), diadi_tmp(7 downto 0), dipadip_tmp(0), mem(prcd_tmp_addrawraddr_dly_depth)(7 downto 0), memp(prcd_tmp_addrawraddr_dly_depth)(0));

                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(0), webweu_tmp(0), addrawraddr_tmp, addrbrdaddr_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_ox (webweu_tmp(1), weawel_tmp(1), diadi_tmp(15 downto 8), dipadip_tmp(1), mem(prcd_tmp_addrawraddr_dly_depth)(15 downto 8), memp(prcd_tmp_addrawraddr_dly_depth)(1));

                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(1), webweu_tmp(1), addrawraddr_tmp, addrbrdaddr_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
                   
                   prcd_write_ram_ox (webweu_tmp(2), weawel_tmp(2), diadi_tmp(23 downto 16), dipadip_tmp(2), mem(prcd_tmp_addrawraddr_dly_depth)(23 downto 16), memp(prcd_tmp_addrawraddr_dly_depth)(2));

                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(2), webweu_tmp(2), addrawraddr_tmp, addrbrdaddr_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_ox (webweu_tmp(3), weawel_tmp(3), diadi_tmp(31 downto 24), dipadip_tmp(3), mem(prcd_tmp_addrawraddr_dly_depth)(31 downto 24), memp(prcd_tmp_addrawraddr_dly_depth)(3));

                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(3), webweu_tmp(3), addrawraddr_tmp, addrbrdaddr_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                 end if;

      when others => null;

    end case;

  end prcd_ox_wr_ram_a;

  
  procedure prcd_col_wr_ram_b (
    constant viol_time_tmp : in integer;
    constant seq : in std_logic_vector (1 downto 0);
    constant weawel_tmp : in std_logic_vector (7 downto 0);
    constant webweu_tmp : in std_logic_vector (7 downto 0);
    constant dibdi_tmp : in std_logic_vector (63 downto 0);
    constant dipbdip_tmp : in std_logic_vector (7 downto 0);
    constant addrawraddr_tmp : in std_logic_vector (15 downto 0);
    constant addrbrdaddr_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type;
    variable col_wr_wr_msg : inout std_ulogic;
    variable col_wra_rdb_msg : inout std_ulogic;
    variable col_wrb_rda_msg : inout std_ulogic;
    variable chk_col_same_clk_tmp : inout integer;
    variable chk_ox_same_clk_tmp : inout integer;
    variable chk_ox_msg_tmp : inout integer
    ) is
    variable prcd_tmp_addrbrdaddr_dly_depth : integer;
    variable prcd_tmp_addrbrdaddr_dly_width : integer;
    variable junk : std_ulogic;

  begin
    
    case b_width is

      when 1 | 2 | 4 => if (not(weawel_tmp(0) = '1' and webweu_tmp(0) = '1' and b_width > a_width) or seq = "10") then
                          if (b_width >= width) then
                            prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_lbit_124));
                            prcd_write_ram_col (weawel_tmp(0), webweu_tmp(0), dibdi_tmp(b_width-1 downto 0), '0', mem(prcd_tmp_addrbrdaddr_dly_depth), junk);
                          else
                            prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_bit_124 + 1));
                            prcd_tmp_addrbrdaddr_dly_width := SLV_TO_INT(addrbrdaddr_tmp(addrbrdaddr_bit_124 downto addrbrdaddr_lbit_124));
                            prcd_write_ram_col (weawel_tmp(0), webweu_tmp(0), dibdi_tmp(b_width-1 downto 0), '0', mem(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * b_width) + b_width - 1 downto (prcd_tmp_addrbrdaddr_dly_width * b_width)), junk);
                          end if;

                          if (seq = "00") then
                            prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(0), webweu_tmp(0), addrawraddr_tmp, addrbrdaddr_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                          end if;
                        end if;

      when 8 => if (not(weawel_tmp(0) = '1' and webweu_tmp(0) = '1' and b_width > a_width) or seq = "10") then
                  if (b_width >= width) then
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto 3));
                    prcd_write_ram_col (weawel_tmp(0), webweu_tmp(0), dibdi_tmp(7 downto 0), dipbdip_tmp(0), mem(prcd_tmp_addrbrdaddr_dly_depth), memp(prcd_tmp_addrbrdaddr_dly_depth)(0));
                  else
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_bit_8 + 1));
                    prcd_tmp_addrbrdaddr_dly_width := SLV_TO_INT(addrbrdaddr_tmp(addrbrdaddr_bit_8 downto 3));
                    prcd_write_ram_col (weawel_tmp(0), webweu_tmp(0), dibdi_tmp(7 downto 0), dipbdip_tmp(0), mem(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * 8) + 7 downto (prcd_tmp_addrbrdaddr_dly_width * 8)), memp(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width)));
                  end if;
    
                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(0), webweu_tmp(0), addrawraddr_tmp, addrbrdaddr_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if; 
                end if;

      when 16 => if (not(weawel_tmp(0) = '1' and webweu_tmp(0) = '1' and b_width > a_width) or seq = "10") then
                  if (b_width >= width) then
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto 4));
                    prcd_write_ram_col (weawel_tmp(0), webweu_tmp(0), dibdi_tmp(7 downto 0), dipbdip_tmp(0), mem(prcd_tmp_addrbrdaddr_dly_depth)(7 downto 0), memp(prcd_tmp_addrbrdaddr_dly_depth)(0));
                  else
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_bit_16 + 1));
                    prcd_tmp_addrbrdaddr_dly_width := SLV_TO_INT(addrbrdaddr_tmp(addrbrdaddr_bit_16 downto 4));
                    prcd_write_ram_col (weawel_tmp(0), webweu_tmp(0), dibdi_tmp(7 downto 0), dipbdip_tmp(0), mem(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * 16) + 7 downto (prcd_tmp_addrbrdaddr_dly_width * 16)), memp(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * 2)));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(0), webweu_tmp(0), addrawraddr_tmp, addrbrdaddr_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;

                  if (b_width >= width) then
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto 4));
                    prcd_write_ram_col (weawel_tmp(1), webweu_tmp(1), dibdi_tmp(15 downto 8), dipbdip_tmp(1), mem(prcd_tmp_addrbrdaddr_dly_depth)(15 downto 8), memp(prcd_tmp_addrbrdaddr_dly_depth)(1));
                  else
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_bit_16 + 1));
                    prcd_tmp_addrbrdaddr_dly_width := SLV_TO_INT(addrbrdaddr_tmp(addrbrdaddr_bit_16 downto 4));
                    prcd_write_ram_col (weawel_tmp(1), webweu_tmp(1), dibdi_tmp(15 downto 8), dipbdip_tmp(1), mem(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * 16) + 15 downto (prcd_tmp_addrbrdaddr_dly_width * 16) + 8), memp(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * 2) + 1));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(1), webweu_tmp(1), addrawraddr_tmp, addrbrdaddr_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;

                end if;
      when 32 => if (not(weawel_tmp(0) = '1' and webweu_tmp(0) = '1' and b_width > a_width) or seq = "10") then

                   prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto 5));
                   prcd_write_ram_col (weawel_tmp(0), webweu_tmp(0), dibdi_tmp(7 downto 0), dipbdip_tmp(0), mem(prcd_tmp_addrbrdaddr_dly_depth)(7 downto 0), memp(prcd_tmp_addrbrdaddr_dly_depth)(0));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(0), webweu_tmp(0), addrawraddr_tmp, addrbrdaddr_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_col (weawel_tmp(1), webweu_tmp(1), dibdi_tmp(15 downto 8), dipbdip_tmp(1), mem(prcd_tmp_addrbrdaddr_dly_depth)(15 downto 8), memp(prcd_tmp_addrbrdaddr_dly_depth)(1));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(1), webweu_tmp(1), addrawraddr_tmp, addrbrdaddr_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
                   
                   prcd_write_ram_col (weawel_tmp(2), webweu_tmp(2), dibdi_tmp(23 downto 16), dipbdip_tmp(2), mem(prcd_tmp_addrbrdaddr_dly_depth)(23 downto 16), memp(prcd_tmp_addrbrdaddr_dly_depth)(2));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(2), webweu_tmp(2), addrawraddr_tmp, addrbrdaddr_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_col (weawel_tmp(3), webweu_tmp(3), dibdi_tmp(31 downto 24), dipbdip_tmp(3), mem(prcd_tmp_addrbrdaddr_dly_depth)(31 downto 24), memp(prcd_tmp_addrbrdaddr_dly_depth)(3));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(3), webweu_tmp(3), addrawraddr_tmp, addrbrdaddr_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                 end if;

      when others => null;

    end case;

  end prcd_col_wr_ram_b;


  procedure prcd_ox_wr_ram_b (
    constant viol_time_tmp : in integer;
    constant seq : in std_logic_vector (1 downto 0);
    constant weawel_tmp : in std_logic_vector (7 downto 0);
    constant webweu_tmp : in std_logic_vector (7 downto 0);
    constant dibdi_tmp : in std_logic_vector (63 downto 0);
    constant dipbdip_tmp : in std_logic_vector (7 downto 0);
    constant addrawraddr_tmp : in std_logic_vector (15 downto 0);
    constant addrbrdaddr_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type;
    variable ox_wr_wr_msg : inout std_ulogic;
    variable ox_wra_rdb_msg : inout std_ulogic;
    variable ox_wrb_rda_msg : inout std_ulogic;
    variable chk_col_same_clk_tmp : inout integer;
    variable chk_ox_same_clk_tmp : inout integer;
    variable chk_ox_msg_tmp : inout integer
    ) is
    variable prcd_tmp_addrbrdaddr_dly_depth : integer;
    variable prcd_tmp_addrbrdaddr_dly_width : integer;
    variable junk : std_ulogic;

  begin
    
    case b_width is

      when 1 | 2 | 4 => if (not(weawel_tmp(0) = '1' and webweu_tmp(0) = '1' and b_width > a_width) or seq = "10") then
                          if (b_width >= width) then
                            prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_lbit_124));
                            prcd_write_ram_ox (weawel_tmp(0), webweu_tmp(0), dibdi_tmp(b_width-1 downto 0), '0', mem(prcd_tmp_addrbrdaddr_dly_depth), junk);
                          else
                            prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_bit_124 + 1));
                            prcd_tmp_addrbrdaddr_dly_width := SLV_TO_INT(addrbrdaddr_tmp(addrbrdaddr_bit_124 downto addrbrdaddr_lbit_124));
                            prcd_write_ram_ox (weawel_tmp(0), webweu_tmp(0), dibdi_tmp(b_width-1 downto 0), '0', mem(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * b_width) + b_width - 1 downto (prcd_tmp_addrbrdaddr_dly_width * b_width)), junk);
                          end if;

                          if (seq = "00") then
                            prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(0), webweu_tmp(0), addrawraddr_tmp, addrbrdaddr_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                          end if;
                        end if;

      when 8 => if (not(weawel_tmp(0) = '1' and webweu_tmp(0) = '1' and b_width > a_width) or seq = "10") then
                  if (b_width >= width) then
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto 3));
                    prcd_write_ram_ox (weawel_tmp(0), webweu_tmp(0), dibdi_tmp(7 downto 0), dipbdip_tmp(0), mem(prcd_tmp_addrbrdaddr_dly_depth), memp(prcd_tmp_addrbrdaddr_dly_depth)(0));
                  else
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_bit_8 + 1));
                    prcd_tmp_addrbrdaddr_dly_width := SLV_TO_INT(addrbrdaddr_tmp(addrbrdaddr_bit_8 downto 3));
                    prcd_write_ram_ox (weawel_tmp(0), webweu_tmp(0), dibdi_tmp(7 downto 0), dipbdip_tmp(0), mem(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * 8) + 7 downto (prcd_tmp_addrbrdaddr_dly_width * 8)), memp(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width)));
                  end if;
    
                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(0), webweu_tmp(0), addrawraddr_tmp, addrbrdaddr_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if; 
                end if;

      when 16 => if (not(weawel_tmp(0) = '1' and webweu_tmp(0) = '1' and b_width > a_width) or seq = "10") then
                  if (b_width >= width) then
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto 4));
                    prcd_write_ram_ox (weawel_tmp(0), webweu_tmp(0), dibdi_tmp(7 downto 0), dipbdip_tmp(0), mem(prcd_tmp_addrbrdaddr_dly_depth)(7 downto 0), memp(prcd_tmp_addrbrdaddr_dly_depth)(0));
                  else
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_bit_16 + 1));
                    prcd_tmp_addrbrdaddr_dly_width := SLV_TO_INT(addrbrdaddr_tmp(addrbrdaddr_bit_16 downto 4));
                    prcd_write_ram_ox (weawel_tmp(0), webweu_tmp(0), dibdi_tmp(7 downto 0), dipbdip_tmp(0), mem(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * 16) + 7 downto (prcd_tmp_addrbrdaddr_dly_width * 16)), memp(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * 2)));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(0), webweu_tmp(0), addrawraddr_tmp, addrbrdaddr_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;

                  if (b_width >= width) then
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto 4));
                    prcd_write_ram_ox (weawel_tmp(1), webweu_tmp(1), dibdi_tmp(15 downto 8), dipbdip_tmp(1), mem(prcd_tmp_addrbrdaddr_dly_depth)(15 downto 8), memp(prcd_tmp_addrbrdaddr_dly_depth)(1));
                  else
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_bit_16 + 1));
                    prcd_tmp_addrbrdaddr_dly_width := SLV_TO_INT(addrbrdaddr_tmp(addrbrdaddr_bit_16 downto 4));
                    prcd_write_ram_ox (weawel_tmp(1), webweu_tmp(1), dibdi_tmp(15 downto 8), dipbdip_tmp(1), mem(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * 16) + 15 downto (prcd_tmp_addrbrdaddr_dly_width * 16) + 8), memp(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * 2) + 1));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(1), webweu_tmp(1), addrawraddr_tmp, addrbrdaddr_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;

                end if;
      when 32 => if (not(weawel_tmp(0) = '1' and webweu_tmp(0) = '1' and b_width > a_width) or seq = "10") then

                   prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto 5));
                   prcd_write_ram_ox (weawel_tmp(0), webweu_tmp(0), dibdi_tmp(7 downto 0), dipbdip_tmp(0), mem(prcd_tmp_addrbrdaddr_dly_depth)(7 downto 0), memp(prcd_tmp_addrbrdaddr_dly_depth)(0));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(0), webweu_tmp(0), addrawraddr_tmp, addrbrdaddr_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_ox (weawel_tmp(1), webweu_tmp(1), dibdi_tmp(15 downto 8), dipbdip_tmp(1), mem(prcd_tmp_addrbrdaddr_dly_depth)(15 downto 8), memp(prcd_tmp_addrbrdaddr_dly_depth)(1));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(1), webweu_tmp(1), addrawraddr_tmp, addrbrdaddr_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
                   
                   prcd_write_ram_ox (weawel_tmp(2), webweu_tmp(2), dibdi_tmp(23 downto 16), dipbdip_tmp(2), mem(prcd_tmp_addrbrdaddr_dly_depth)(23 downto 16), memp(prcd_tmp_addrbrdaddr_dly_depth)(2));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(2), webweu_tmp(2), addrawraddr_tmp, addrbrdaddr_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_ox (weawel_tmp(3), webweu_tmp(3), dibdi_tmp(31 downto 24), dipbdip_tmp(3), mem(prcd_tmp_addrbrdaddr_dly_depth)(31 downto 24), memp(prcd_tmp_addrbrdaddr_dly_depth)(3));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_time_tmp, weawel_tmp(3), webweu_tmp(3), addrawraddr_tmp, addrbrdaddr_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                 end if;

      when others => null;

    end case;

  end prcd_ox_wr_ram_b;

  
  procedure prcd_col_rd_ram_a (
    constant viol_type_tmp : in std_logic_vector (1 downto 0);
    constant seq : in std_logic_vector (1 downto 0);
    constant webweu_tmp : in std_logic_vector (7 downto 0);
    constant weawel_tmp : in std_logic_vector (7 downto 0);
    constant addrawraddr_tmp : in std_logic_vector (15 downto 0);
    variable doado_tmp : inout std_logic_vector (63 downto 0);
    variable dopadop_tmp : inout std_logic_vector (7 downto 0);
    constant mem : in Two_D_array_type;
    constant memp : in Two_D_parity_array_type;
    constant wr_mode_a_tmp : in std_logic_vector (1 downto 0)

    ) is
    variable prcd_tmp_addrawraddr_dly_depth : integer;
    variable prcd_tmp_addrawraddr_dly_width : integer;
    variable junk : std_ulogic;
    variable doado_ltmp : std_logic_vector (63 downto 0);
    variable dopadop_ltmp : std_logic_vector (7 downto 0);
    
  begin

    doado_ltmp := (others => '0');
    dopadop_ltmp := (others => '0');
    
    case a_width is
      
      when 1 | 2 | 4 => if ((webweu_tmp(0) = '1' and weawel_tmp(0) = '1') or (seq = "01" and webweu_tmp(0) = '1' and weawel_tmp(0) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and webweu_tmp(0) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and webweu_tmp(0) /= '1')) then

                          if (a_width >= width) then
                            prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_lbit_124));
                            doado_ltmp(a_width-1 downto 0) := mem(prcd_tmp_addrawraddr_dly_depth);
                          else
                            prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_bit_124 + 1));
                            prcd_tmp_addrawraddr_dly_width := SLV_TO_INT(addrawraddr_tmp(addrawraddr_bit_124 downto addrawraddr_lbit_124));
                            doado_ltmp(a_width-1 downto 0) := mem(prcd_tmp_addrawraddr_dly_depth)(((prcd_tmp_addrawraddr_dly_width * a_width) + a_width - 1) downto (prcd_tmp_addrawraddr_dly_width * a_width));

                          end if;
                          prcd_x_buf (wr_mode_a_tmp, 3, 0, 0, doado_ltmp, doado_tmp, dopadop_ltmp, dopadop_tmp);
                        end if;

      when 8 => if ((webweu_tmp(0) = '1' and weawel_tmp(0) = '1') or (seq = "01" and webweu_tmp(0) = '1' and weawel_tmp(0) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and webweu_tmp(0) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and webweu_tmp(0) /= '1')) then

                  if (a_width >= width) then
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto 3));
                    doado_ltmp(7 downto 0) := mem(prcd_tmp_addrawraddr_dly_depth);
                    dopadop_ltmp(0) := memp(prcd_tmp_addrawraddr_dly_depth)(0);
                  else
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_bit_8 + 1));
                    prcd_tmp_addrawraddr_dly_width := SLV_TO_INT(addrawraddr_tmp(addrawraddr_bit_8 downto 3));
                    doado_ltmp(7 downto 0) := mem(prcd_tmp_addrawraddr_dly_depth)(((prcd_tmp_addrawraddr_dly_width * 8) + 7) downto (prcd_tmp_addrawraddr_dly_width * 8));
                    dopadop_ltmp(0) := memp(prcd_tmp_addrawraddr_dly_depth)(prcd_tmp_addrawraddr_dly_width);
                  end if;
                  prcd_x_buf (wr_mode_a_tmp, 7, 0, 0, doado_ltmp, doado_tmp, dopadop_ltmp, dopadop_tmp);

                end if;

      when 16 => if ((webweu_tmp(0) = '1' and weawel_tmp(0) = '1') or (seq = "01" and webweu_tmp(0) = '1' and weawel_tmp(0) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and webweu_tmp(0) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and webweu_tmp(0) /= '1')) then

                  if (a_width >= width) then
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto 4));
                    doado_ltmp(7 downto 0) := mem(prcd_tmp_addrawraddr_dly_depth)(7 downto 0);
                    dopadop_ltmp(0) := memp(prcd_tmp_addrawraddr_dly_depth)(0);
                  else
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_bit_16 + 1));
                    prcd_tmp_addrawraddr_dly_width := SLV_TO_INT(addrawraddr_tmp(addrawraddr_bit_16 downto 4));

                    doado_ltmp(7 downto 0) := mem(prcd_tmp_addrawraddr_dly_depth)(((prcd_tmp_addrawraddr_dly_width * 16) + 7) downto (prcd_tmp_addrawraddr_dly_width * 16));                    
                    dopadop_ltmp(0) := memp(prcd_tmp_addrawraddr_dly_depth)(prcd_tmp_addrawraddr_dly_width * 2);
                  end if;
                  prcd_x_buf (wr_mode_a_tmp, 7, 0, 0, doado_ltmp, doado_tmp, dopadop_ltmp, dopadop_tmp);

                end if;

                if ((webweu_tmp(1) = '1' and weawel_tmp(1) = '1') or (seq = "01" and webweu_tmp(1) = '1' and weawel_tmp(1) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and webweu_tmp(1) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and webweu_tmp(1) /= '1')) then

                  if (a_width >= width) then
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto 4));
                    doado_ltmp(15 downto 8) := mem(prcd_tmp_addrawraddr_dly_depth)(15 downto 8);
                    dopadop_ltmp(1) := memp(prcd_tmp_addrawraddr_dly_depth)(1);
                  else
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_bit_16 + 1));
                    prcd_tmp_addrawraddr_dly_width := SLV_TO_INT(addrawraddr_tmp(addrawraddr_bit_16 downto 4));

                    doado_ltmp(15 downto 8) := mem(prcd_tmp_addrawraddr_dly_depth)(((prcd_tmp_addrawraddr_dly_width * 16) + 15) downto ((prcd_tmp_addrawraddr_dly_width * 16) + 8));
                    dopadop_ltmp(1) := memp(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * 2) + 1);
                  end if;
                  prcd_x_buf (wr_mode_a_tmp, 15, 8, 1, doado_ltmp, doado_tmp, dopadop_ltmp, dopadop_tmp);
                  
                end if;

      when 32 => if (a_width >= width) then

                   prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto 5));

                   if ((webweu_tmp(0) = '1' and weawel_tmp(0) = '1') or (seq = "01" and webweu_tmp(0) = '1' and weawel_tmp(0) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and webweu_tmp(0) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and webweu_tmp(0) /= '1')) then

                     doado_ltmp(7 downto 0) := mem(prcd_tmp_addrawraddr_dly_depth)(7 downto 0);
                     dopadop_ltmp(0) := memp(prcd_tmp_addrawraddr_dly_depth)(0);
                     prcd_x_buf (wr_mode_a_tmp, 7, 0, 0, doado_ltmp, doado_tmp, dopadop_ltmp, dopadop_tmp);

                   end if;

                   if ((webweu_tmp(1) = '1' and weawel_tmp(1) = '1') or (seq = "01" and webweu_tmp(1) = '1' and weawel_tmp(1) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and webweu_tmp(1) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and webweu_tmp(1) /= '1')) then

                     doado_ltmp(15 downto 8) := mem(prcd_tmp_addrawraddr_dly_depth)(15 downto 8);
                     dopadop_ltmp(1) := memp(prcd_tmp_addrawraddr_dly_depth)(1);
                     prcd_x_buf (wr_mode_a_tmp, 15, 8, 1, doado_ltmp, doado_tmp, dopadop_ltmp, dopadop_tmp);

                   end if;

                   if ((webweu_tmp(2) = '1' and weawel_tmp(2) = '1') or (seq = "01" and webweu_tmp(2) = '1' and weawel_tmp(2) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and webweu_tmp(2) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and webweu_tmp(2) /= '1')) then

                     doado_ltmp(23 downto 16) := mem(prcd_tmp_addrawraddr_dly_depth)(23 downto 16);
                     dopadop_ltmp(2) := memp(prcd_tmp_addrawraddr_dly_depth)(2);
                     prcd_x_buf (wr_mode_a_tmp, 23, 16, 2, doado_ltmp, doado_tmp, dopadop_ltmp, dopadop_tmp);

                   end if;

                   if ((webweu_tmp(3) = '1' and weawel_tmp(3) = '1') or (seq = "01" and webweu_tmp(3) = '1' and weawel_tmp(3) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and webweu_tmp(3) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and webweu_tmp(3) /= '1')) then

                     doado_ltmp(31 downto 24) := mem(prcd_tmp_addrawraddr_dly_depth)(31 downto 24);
                     dopadop_ltmp(3) := memp(prcd_tmp_addrawraddr_dly_depth)(3);
                     prcd_x_buf (wr_mode_a_tmp, 31, 24, 3, doado_ltmp, doado_tmp, dopadop_ltmp, dopadop_tmp);

                   end if;
  
                end if;
  
      when others => null;

    end case;

  end prcd_col_rd_ram_a;


  procedure prcd_col_rd_ram_b (
    constant viol_type_tmp : in std_logic_vector (1 downto 0);
    constant seq : in std_logic_vector (1 downto 0);
    constant weawel_tmp : in std_logic_vector (7 downto 0);
    constant webweu_tmp : in std_logic_vector (7 downto 0);
    constant addrbrdaddr_tmp : in std_logic_vector (15 downto 0);
    variable dobdo_tmp : inout std_logic_vector (63 downto 0);
    variable dopbdop_tmp : inout std_logic_vector (7 downto 0);
    constant mem : in Two_D_array_type;
    constant memp : in Two_D_parity_array_type;
    constant wr_mode_b_tmp : in std_logic_vector (1 downto 0)

    ) is
    variable prcd_tmp_addrbrdaddr_dly_depth : integer;
    variable prcd_tmp_addrbrdaddr_dly_width : integer;
    variable junk : std_ulogic;
    variable dobdo_ltmp : std_logic_vector (63 downto 0);
    variable dopbdop_ltmp : std_logic_vector (7 downto 0);
    
  begin

    dobdo_ltmp := (others => '0');
    dopbdop_ltmp := (others => '0');
    
    case b_width is
      
      when 1 | 2 | 4 => if ((webweu_tmp(0) = '1' and weawel_tmp(0) = '1') or (seq = "01" and weawel_tmp(0) = '1' and webweu_tmp(0) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and weawel_tmp(0) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and weawel_tmp(0) /= '1')) then

                          if (b_width >= width) then
                            prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_lbit_124));
                            dobdo_ltmp(b_width-1 downto 0) := mem(prcd_tmp_addrbrdaddr_dly_depth);
                          else
                            prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_bit_124 + 1));
                            prcd_tmp_addrbrdaddr_dly_width := SLV_TO_INT(addrbrdaddr_tmp(addrbrdaddr_bit_124 downto addrbrdaddr_lbit_124));
                            dobdo_ltmp(b_width-1 downto 0) := mem(prcd_tmp_addrbrdaddr_dly_depth)(((prcd_tmp_addrbrdaddr_dly_width * b_width) + b_width - 1) downto (prcd_tmp_addrbrdaddr_dly_width * b_width));
                          end if;
                          prcd_x_buf (wr_mode_b_tmp, 3, 0, 0, dobdo_ltmp, dobdo_tmp, dopbdop_ltmp, dopbdop_tmp);

                        end if;

      when 8 => if ((webweu_tmp(0) = '1' and weawel_tmp(0) = '1') or (seq = "01" and weawel_tmp(0) = '1' and webweu_tmp(0) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and weawel_tmp(0) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and weawel_tmp(0) /= '1')) then

                  if (b_width >= width) then
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto 3));
                    dobdo_ltmp(7 downto 0) := mem(prcd_tmp_addrbrdaddr_dly_depth);
                    dopbdop_ltmp(0) := memp(prcd_tmp_addrbrdaddr_dly_depth)(0);
                  else
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_bit_8 + 1));
                    prcd_tmp_addrbrdaddr_dly_width := SLV_TO_INT(addrbrdaddr_tmp(addrbrdaddr_bit_8 downto 3));
                    dobdo_ltmp(7 downto 0) := mem(prcd_tmp_addrbrdaddr_dly_depth)(((prcd_tmp_addrbrdaddr_dly_width * 8) + 7) downto (prcd_tmp_addrbrdaddr_dly_width * 8));
                    dopbdop_ltmp(0) := memp(prcd_tmp_addrbrdaddr_dly_depth)(prcd_tmp_addrbrdaddr_dly_width);
                  end if;
                  prcd_x_buf (wr_mode_b_tmp, 7, 0, 0, dobdo_ltmp, dobdo_tmp, dopbdop_ltmp, dopbdop_tmp);

                end if;

      when 16 => if ((webweu_tmp(0) = '1' and weawel_tmp(0) = '1') or (seq = "01" and weawel_tmp(0) = '1' and webweu_tmp(0) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and weawel_tmp(0) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and weawel_tmp(0) /= '1')) then

                  if (b_width >= width) then
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto 4));
                    dobdo_ltmp(7 downto 0) := mem(prcd_tmp_addrbrdaddr_dly_depth)(7 downto 0);
                    dopbdop_ltmp(0) := memp(prcd_tmp_addrbrdaddr_dly_depth)(0);
                  else
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_bit_16 + 1));
                    prcd_tmp_addrbrdaddr_dly_width := SLV_TO_INT(addrbrdaddr_tmp(addrbrdaddr_bit_16 downto 4));

                    dobdo_ltmp(7 downto 0) := mem(prcd_tmp_addrbrdaddr_dly_depth)(((prcd_tmp_addrbrdaddr_dly_width * 16) + 7) downto (prcd_tmp_addrbrdaddr_dly_width * 16));
                    dopbdop_ltmp(0) := memp(prcd_tmp_addrbrdaddr_dly_depth)(prcd_tmp_addrbrdaddr_dly_width * 2);
                  end if;
                  prcd_x_buf (wr_mode_b_tmp, 7, 0, 0, dobdo_ltmp, dobdo_tmp, dopbdop_ltmp, dopbdop_tmp);

                end if;


                if ((webweu_tmp(1) = '1' and weawel_tmp(1) = '1') or (seq = "01" and weawel_tmp(1) = '1' and webweu_tmp(1) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and weawel_tmp(1) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and weawel_tmp(1) /= '1')) then

                  if (b_width >= width) then
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto 4));
                    dobdo_ltmp(15 downto 8) := mem(prcd_tmp_addrbrdaddr_dly_depth)(15 downto 8);
                    dopbdop_ltmp(1) := memp(prcd_tmp_addrbrdaddr_dly_depth)(1);
                  else
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_bit_16 + 1));
                    prcd_tmp_addrbrdaddr_dly_width := SLV_TO_INT(addrbrdaddr_tmp(addrbrdaddr_bit_16 downto 4));

                    dobdo_ltmp(15 downto 8) := mem(prcd_tmp_addrbrdaddr_dly_depth)(((prcd_tmp_addrbrdaddr_dly_width * 16) + 15) downto ((prcd_tmp_addrbrdaddr_dly_width * 16) + 8));
                    dopbdop_ltmp(1) := memp(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * 2) + 1);
                  end if;
                  prcd_x_buf (wr_mode_b_tmp, 15, 8, 1, dobdo_ltmp, dobdo_tmp, dopbdop_ltmp, dopbdop_tmp);

                end if;

      when 32 => if (b_width >= width) then

                   prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto 5));

                   if ((webweu_tmp(0) = '1' and weawel_tmp(0) = '1') or (seq = "01" and weawel_tmp(0) = '1' and webweu_tmp(0) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and weawel_tmp(0) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and weawel_tmp(0) /= '1')) then

                     dobdo_ltmp(7 downto 0) := mem(prcd_tmp_addrbrdaddr_dly_depth)(7 downto 0);
                     dopbdop_ltmp(0) := memp(prcd_tmp_addrbrdaddr_dly_depth)(0);
                     prcd_x_buf (wr_mode_b_tmp, 7, 0, 0, dobdo_ltmp, dobdo_tmp, dopbdop_ltmp, dopbdop_tmp);

                   end if;

                   if ((webweu_tmp(1) = '1' and weawel_tmp(1) = '1') or (seq = "01" and weawel_tmp(1) = '1' and webweu_tmp(1) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and weawel_tmp(1) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and weawel_tmp(1) /= '1')) then

                     dobdo_ltmp(15 downto 8) := mem(prcd_tmp_addrbrdaddr_dly_depth)(15 downto 8);
                     dopbdop_ltmp(1) := memp(prcd_tmp_addrbrdaddr_dly_depth)(1);
                     prcd_x_buf (wr_mode_b_tmp, 15, 8, 1, dobdo_ltmp, dobdo_tmp, dopbdop_ltmp, dopbdop_tmp);

                   end if;

                   if ((webweu_tmp(2) = '1' and weawel_tmp(2) = '1') or (seq = "01" and weawel_tmp(2) = '1' and webweu_tmp(2) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and weawel_tmp(2) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and weawel_tmp(2) /= '1')) then

                     dobdo_ltmp(23 downto 16) := mem(prcd_tmp_addrbrdaddr_dly_depth)(23 downto 16);
                     dopbdop_ltmp(2) := memp(prcd_tmp_addrbrdaddr_dly_depth)(2);
                     prcd_x_buf (wr_mode_b_tmp, 23, 16, 2, dobdo_ltmp, dobdo_tmp, dopbdop_ltmp, dopbdop_tmp);

                   end if;
  
                   if ((webweu_tmp(3) = '1' and weawel_tmp(3) = '1') or (seq = "01" and weawel_tmp(3) = '1' and webweu_tmp(3) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and weawel_tmp(3) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and weawel_tmp(3) /= '1')) then

                     dobdo_ltmp(31 downto 24) := mem(prcd_tmp_addrbrdaddr_dly_depth)(31 downto 24);
                     dopbdop_ltmp(3) := memp(prcd_tmp_addrbrdaddr_dly_depth)(3);
                     prcd_x_buf (wr_mode_b_tmp, 31, 24, 3, dobdo_ltmp, dobdo_tmp, dopbdop_ltmp, dopbdop_tmp);

                   end if;
  
                end if;
  
      when others => null;

    end case;

  end prcd_col_rd_ram_b;


  procedure prcd_wr_ram_a (
    constant weawel_tmp : in std_logic_vector (7 downto 0);
    constant diadi_tmp : in std_logic_vector (63 downto 0);
    constant dipadip_tmp : in std_logic_vector (7 downto 0);
    constant addrawraddr_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type
    ) is
    variable prcd_tmp_addrawraddr_dly_depth : integer;
    variable prcd_tmp_addrawraddr_dly_width : integer;
    variable junk : std_ulogic;

  begin
    
    case a_width is

      when 1 | 2 | 4 =>
                          if (a_width >= width) then
                            prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_lbit_124));
                            prcd_write_ram (weawel_tmp(0), diadi_tmp(a_width-1 downto 0), '0', mem(prcd_tmp_addrawraddr_dly_depth), junk);
                          else
                            prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_bit_124 + 1));
                            prcd_tmp_addrawraddr_dly_width := SLV_TO_INT(addrawraddr_tmp(addrawraddr_bit_124 downto addrawraddr_lbit_124));
                            prcd_write_ram (weawel_tmp(0), diadi_tmp(a_width-1 downto 0), '0', mem(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * a_width) + a_width - 1 downto (prcd_tmp_addrawraddr_dly_width * a_width)), junk);
                          end if;

      when 8 =>
                  if (a_width >= width) then
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto 3));
                    prcd_write_ram (weawel_tmp(0), diadi_tmp(7 downto 0), dipadip_tmp(0), mem(prcd_tmp_addrawraddr_dly_depth), memp(prcd_tmp_addrawraddr_dly_depth)(0));
                  else
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_bit_8 + 1));
                    prcd_tmp_addrawraddr_dly_width := SLV_TO_INT(addrawraddr_tmp(addrawraddr_bit_8 downto 3));
                    prcd_write_ram (weawel_tmp(0), diadi_tmp(7 downto 0), dipadip_tmp(0), mem(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * 8) + 7 downto (prcd_tmp_addrawraddr_dly_width * 8)), memp(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width)));
                  end if;
  
      when 16 =>
                  if (a_width >= width) then
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto 4));
                    prcd_write_ram (weawel_tmp(0), diadi_tmp(7 downto 0), dipadip_tmp(0), mem(prcd_tmp_addrawraddr_dly_depth)(7 downto 0), memp(prcd_tmp_addrawraddr_dly_depth)(0));
                    prcd_write_ram (weawel_tmp(1), diadi_tmp(15 downto 8), dipadip_tmp(1), mem(prcd_tmp_addrawraddr_dly_depth)(15 downto 8), memp(prcd_tmp_addrawraddr_dly_depth)(1));
                  else
                    prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto addrawraddr_bit_16 + 1));
                    prcd_tmp_addrawraddr_dly_width := SLV_TO_INT(addrawraddr_tmp(addrawraddr_bit_16 downto 4));
                    prcd_write_ram (weawel_tmp(0), diadi_tmp(7 downto 0), dipadip_tmp(0), mem(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * 16) + 7 downto (prcd_tmp_addrawraddr_dly_width * 16)), memp(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * 2)));
                    prcd_write_ram (weawel_tmp(1), diadi_tmp(15 downto 8), dipadip_tmp(1), mem(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * 16) + 15 downto (prcd_tmp_addrawraddr_dly_width * 16) + 8), memp(prcd_tmp_addrawraddr_dly_depth)((prcd_tmp_addrawraddr_dly_width * 2) + 1));
                  end if;

      when 32 =>
                   prcd_tmp_addrawraddr_dly_depth := SLV_TO_INT(addrawraddr_tmp(14 downto 5));

                   prcd_write_ram (weawel_tmp(0), diadi_tmp(7 downto 0), dipadip_tmp(0), mem(prcd_tmp_addrawraddr_dly_depth)(7 downto 0), memp(prcd_tmp_addrawraddr_dly_depth)(0));
                   prcd_write_ram (weawel_tmp(1), diadi_tmp(15 downto 8), dipadip_tmp(1), mem(prcd_tmp_addrawraddr_dly_depth)(15 downto 8), memp(prcd_tmp_addrawraddr_dly_depth)(1));
                   prcd_write_ram (weawel_tmp(2), diadi_tmp(23 downto 16), dipadip_tmp(2), mem(prcd_tmp_addrawraddr_dly_depth)(23 downto 16), memp(prcd_tmp_addrawraddr_dly_depth)(2));
                   prcd_write_ram (weawel_tmp(3), diadi_tmp(31 downto 24), dipadip_tmp(3), mem(prcd_tmp_addrawraddr_dly_depth)(31 downto 24), memp(prcd_tmp_addrawraddr_dly_depth)(3));

      when others => null;

    end case;

  end prcd_wr_ram_a;


  procedure prcd_wr_ram_b (
    constant webweu_tmp : in std_logic_vector (7 downto 0);
    constant dibdi_tmp : in std_logic_vector (63 downto 0);
    constant dipbdip_tmp : in std_logic_vector (7 downto 0);
    constant addrbrdaddr_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type     
    ) is
    variable prcd_tmp_addrbrdaddr_dly_depth : integer;
    variable prcd_tmp_addrbrdaddr_dly_width : integer;
    variable junk : std_ulogic;

  begin
    
    case b_width is

      when 1 | 2 | 4 =>
                          if (b_width >= width) then
                            prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_lbit_124));
                            prcd_write_ram (webweu_tmp(0), dibdi_tmp(b_width-1 downto 0), '0', mem(prcd_tmp_addrbrdaddr_dly_depth), junk);
                          else
                            prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_bit_124 + 1));
                            prcd_tmp_addrbrdaddr_dly_width := SLV_TO_INT(addrbrdaddr_tmp(addrbrdaddr_bit_124 downto addrbrdaddr_lbit_124));
                            prcd_write_ram (webweu_tmp(0), dibdi_tmp(b_width-1 downto 0), '0', mem(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * b_width) + b_width - 1 downto (prcd_tmp_addrbrdaddr_dly_width * b_width)), junk);
                          end if;

      when 8 => 
                  if (b_width >= width) then
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto 3));
                    prcd_write_ram (webweu_tmp(0), dibdi_tmp(7 downto 0), dipbdip_tmp(0), mem(prcd_tmp_addrbrdaddr_dly_depth), memp(prcd_tmp_addrbrdaddr_dly_depth)(0));
                  else
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_bit_8 + 1));
                    prcd_tmp_addrbrdaddr_dly_width := SLV_TO_INT(addrbrdaddr_tmp(addrbrdaddr_bit_8 downto 3));
                    prcd_write_ram (webweu_tmp(0), dibdi_tmp(7 downto 0), dipbdip_tmp(0), mem(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * 8) + 7 downto (prcd_tmp_addrbrdaddr_dly_width * 8)), memp(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width)));
                  end if;
  
      when 16 =>
                  if (b_width >= width) then
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto 4));
                    prcd_write_ram (webweu_tmp(0), dibdi_tmp(7 downto 0), dipbdip_tmp(0), mem(prcd_tmp_addrbrdaddr_dly_depth)(7 downto 0), memp(prcd_tmp_addrbrdaddr_dly_depth)(0));
                    prcd_write_ram (webweu_tmp(1), dibdi_tmp(15 downto 8), dipbdip_tmp(1), mem(prcd_tmp_addrbrdaddr_dly_depth)(15 downto 8), memp(prcd_tmp_addrbrdaddr_dly_depth)(1));
                  else
                    prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto addrbrdaddr_bit_16 + 1));
                    prcd_tmp_addrbrdaddr_dly_width := SLV_TO_INT(addrbrdaddr_tmp(addrbrdaddr_bit_16 downto 4));
                    prcd_write_ram (webweu_tmp(0), dibdi_tmp(7 downto 0), dipbdip_tmp(0), mem(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * 16) + 7 downto (prcd_tmp_addrbrdaddr_dly_width * 16)), memp(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * 2)));
                    prcd_write_ram (webweu_tmp(1), dibdi_tmp(15 downto 8), dipbdip_tmp(1), mem(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * 16) + 15 downto (prcd_tmp_addrbrdaddr_dly_width * 16) + 8), memp(prcd_tmp_addrbrdaddr_dly_depth)((prcd_tmp_addrbrdaddr_dly_width * 2) + 1));
                  end if;

      when 32 =>
                   prcd_tmp_addrbrdaddr_dly_depth := SLV_TO_INT(addrbrdaddr_tmp(14 downto 5));
                   prcd_write_ram (webweu_tmp(0), dibdi_tmp(7 downto 0), dipbdip_tmp(0), mem(prcd_tmp_addrbrdaddr_dly_depth)(7 downto 0), memp(prcd_tmp_addrbrdaddr_dly_depth)(0));
                   prcd_write_ram (webweu_tmp(1), dibdi_tmp(15 downto 8), dipbdip_tmp(1), mem(prcd_tmp_addrbrdaddr_dly_depth)(15 downto 8), memp(prcd_tmp_addrbrdaddr_dly_depth)(1));
                   prcd_write_ram (webweu_tmp(2), dibdi_tmp(23 downto 16), dipbdip_tmp(2), mem(prcd_tmp_addrbrdaddr_dly_depth)(23 downto 16), memp(prcd_tmp_addrbrdaddr_dly_depth)(2));
                   prcd_write_ram (webweu_tmp(3), dibdi_tmp(31 downto 24), dipbdip_tmp(3), mem(prcd_tmp_addrbrdaddr_dly_depth)(31 downto 24), memp(prcd_tmp_addrbrdaddr_dly_depth)(3));

      when others => null;

    end case;

  end prcd_wr_ram_b;

  
  begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

    addrawraddr_dly      <= "000" & ADDRAWRADDR        	after 0 ps;
    addrbrdaddr_dly      <= "000" & ADDRBRDADDR        	after 0 ps;
    clkawrclk_dly        <= CLKAWRCLK           	after 0 ps;
    clkbrdclk_dly        <= CLKBRDCLK           	after 0 ps;
    enawren_dly        	 <= ENAWREN            	after 0 ps;
    enbrden_dly        	 <= ENBRDEN            	after 0 ps;
    regcea_dly     	 <= REGCEA         	after 0 ps;
    regcebregce_dly      <= REGCEBREGCE        	after 0 ps;
    rsta_dly       	 <= RSTA           	after 0 ps;
    rstbrst_dly       	 <= RSTBRST           	after 0 ps;
    gsr_dly        	 <= GSR            	after 0 ps;


    TDP: if (RAM_MODE = "TDP") generate

      diadi_dly        	 <= X"000000000000" & DIADI            	after 0 ps;
      dibdi_dly        	 <= X"000000000000" &DIBDI            	after 0 ps;
      dipadip_dly      	 <= "000000" &DIPADIP           	after 0 ps;
      dipbdip_dly      	 <= "000000" &DIPBDIP           	after 0 ps;
      weawel_dly       	 <= "000000" & WEAWEL            	after 0 ps;
      webweu_dly       	 <= "000000" & WEBWEU            	after 0 ps;

    end generate TDP;


    SDP: if (RAM_MODE = "SDP") generate

      diadi_dly        	 <= X"00000000" & DIBDI & DIADI     	after 0 ps;
      dibdi_dly        	 <= (others => '0')	after 0 ps;
      dipadip_dly      	 <= "0000" & DIPBDIP & DIPADIP  	after 0 ps;
      dipbdip_dly      	 <= (others => '0') 	after 0 ps;
      weawel_dly       	 <= "0000" & WEBWEU & WEAWEL    	after 0 ps;
      webweu_dly       	 <= (others => '0') 	after 0 ps;

    end generate SDP;


    ox_addra_reconstruct(12 downto 0) <= (addrawraddr_dly(12 downto 6) & '0' & addrawraddr_dly(4) & "0000") when
                                          (WRITE_MODE_A = "READ_FIRST" or WRITE_MODE_B = "READ_FIRST")
                                          else
                                          addrawraddr_dly(12 downto 0);


    ox_addrb_reconstruct(12 downto 0) <= (addrbrdaddr_dly(12 downto 6) & '0' & addrbrdaddr_dly(4) & "0000") when
                                          (WRITE_MODE_A = "READ_FIRST" or WRITE_MODE_B = "READ_FIRST")
                                          else
                                          addrbrdaddr_dly(12 downto 0);

    
  --------------------
  --  BEHAVIOR SECTION
  --------------------

    prcs_clk: process (clkawrclk_dly, clkbrdclk_dly, gsr_dly, rsta_dly, rstbrst_dly, enawren_dly, enbrden_dly)

      variable mem_slv : std_logic_vector(8191 downto 0) := To_StdLogicVector(INIT_1F) &
                                                       To_StdLogicVector(INIT_1E) &
                                                       To_StdLogicVector(INIT_1D) &
                                                       To_StdLogicVector(INIT_1C) &
                                                       To_StdLogicVector(INIT_1B) &
                                                       To_StdLogicVector(INIT_1A) &
                                                       To_StdLogicVector(INIT_19) &
                                                       To_StdLogicVector(INIT_18) &
                                                       To_StdLogicVector(INIT_17) &
                                                       To_StdLogicVector(INIT_16) &
                                                       To_StdLogicVector(INIT_15) &
                                                       To_StdLogicVector(INIT_14) &
                                                       To_StdLogicVector(INIT_13) &
                                                       To_StdLogicVector(INIT_12) &
                                                       To_StdLogicVector(INIT_11) &
                                                       To_StdLogicVector(INIT_10) &
                                                       To_StdLogicVector(INIT_0F) &
                                                       To_StdLogicVector(INIT_0E) &
                                                       To_StdLogicVector(INIT_0D) &
                                                       To_StdLogicVector(INIT_0C) &
                                                       To_StdLogicVector(INIT_0B) &
                                                       To_StdLogicVector(INIT_0A) &
                                                       To_StdLogicVector(INIT_09) &
                                                       To_StdLogicVector(INIT_08) &
                                                       To_StdLogicVector(INIT_07) &
                                                       To_StdLogicVector(INIT_06) &
                                                       To_StdLogicVector(INIT_05) &
                                                       To_StdLogicVector(INIT_04) &
                                                       To_StdLogicVector(INIT_03) &
                                                       To_StdLogicVector(INIT_02) &
                                                       To_StdLogicVector(INIT_01) &
                                                       To_StdLogicVector(INIT_00);

    variable memp_slv : std_logic_vector(1023 downto 0) := To_StdLogicVector(INITP_03) &
                                                       To_StdLogicVector(INITP_02) &
                                                       To_StdLogicVector(INITP_01) &
                                                       To_StdLogicVector(INITP_00);

    variable tmp_mem : Two_D_array_type_tmp_mem := two_D_mem_initf(widest_width);
    variable mem : Two_D_array_type := two_D_mem_init(mem_depth, width, mem_slv, tmp_mem);
    variable memp : Two_D_parity_array_type := two_D_mem_initp(memp_depth, widthp, memp_slv, tmp_mem, width);
    variable tmp_addrawraddr_dly_depth : integer;
    variable tmp_addrawraddr_dly_width : integer;
    variable tmp_addrbrdaddr_dly_depth : integer;
    variable tmp_addrbrdaddr_dly_width : integer;
    variable junk1 : std_logic;
    variable wr_mode_a : std_logic_vector(1 downto 0) := "00";
    variable wr_mode_b : std_logic_vector(1 downto 0) := "00";
    variable tmp_syndrome_int : integer;    
    variable doado_buf : std_logic_vector(63 downto 0) := (others => '0');
    variable dobdo_buf : std_logic_vector(63 downto 0) := (others => '0');
    variable dopadop_buf : std_logic_vector(7 downto 0) := (others => '0');
    variable dopbdop_buf : std_logic_vector(7 downto 0) := (others => '0');    
    variable syndrome : std_logic_vector(7 downto 0) := (others => '0');
    variable addrawraddr_dly_15_reg_var : std_logic := '0';
    variable addrbrdaddr_dly_15_reg_var : std_logic := '0';
    variable addrawraddr_dly_15_reg_bram_var : std_logic := '0';
    variable addrbrdaddr_dly_15_reg_bram_var : std_logic := '0';
    variable FIRST_TIME : boolean := true;

    variable time_port_a : time := 0 ps;
    variable time_port_b : time := 0 ps;
    variable viol_time : integer := 0;
    variable viol_type : std_logic_vector(1 downto 0) := (others => '0');
    variable message : line;

    variable diadi_reg_dly : std_logic_vector(63 downto 0) := (others => '0');
    variable dipadip_reg_dly : std_logic_vector(7 downto 0) := (others => '0');
    variable weawel_reg_dly : std_logic_vector(7 downto 0) := (others => '0');
    variable addrawraddr_reg_dly : std_logic_vector(15 downto 0) := (others => '0');
    variable dibdi_reg_dly : std_logic_vector(63 downto 0) := (others => '0');
    variable dipbdip_reg_dly : std_logic_vector(7 downto 0) := (others => '0');
    variable webweu_reg_dly : std_logic_vector(7 downto 0) := (others => '0');
    variable addrbrdaddr_reg_dly : std_logic_vector(15 downto 0) := (others => '0');
    variable col_wr_wr_msg : std_ulogic := '1';
    variable col_wra_rdb_msg : std_ulogic := '1';
    variable col_wrb_rda_msg : std_ulogic := '1';
    variable addr_col : std_logic := '0';
    variable ox_addra_reconstruct_reg : std_logic_vector(12 downto 0) := (others => '0');
    variable ox_addrb_reconstruct_reg : std_logic_vector(12 downto 0) := (others => '0');
    variable chk_ox_msg : integer := 0;
    variable chk_ox_same_clk : integer := 0;
    variable chk_col_same_clk : integer := 0;
      
  begin  -- process prcs_clkawrclk    

    if (FIRST_TIME) then


      if (INIT_FILE /= "NONE") then
       assert false
         report "DRC Error : The INIT_FILE attribute on RAMB8BWER instance must be set to NONE.  Currently, initializing memory contents of this component via an external file is not supported.  Please set this attribute to the default value of NONE and specify any initialization of this component via the INIT_xx attributes."
            severity failure;
     end if;

  
      case DATA_WIDTH_A is
        when 0 | 1 | 2 | 4 | 9 | 18 => null;
                                       
        when 36 => if (RAM_MODE /= "SDP") then
                     assert false
                       report "DRC error : The attribute DATA_WIDTH_A = 36 requires RAM_MODE set to SDP on RAMB8BWER."
                       severity failure;
                   end if;
  
        when others => GenericValueCheckMessage
                         (  HeaderMsg            => " Attribute Syntax Error : ",
                            GenericName          => " DATA_WIDTH_A ",
                            EntityName           => "RAMB8BWER",
                            GenericValue         => DATA_WIDTH_A,
                            Unit                 => "",
                            ExpectedValueMsg     => " The Legal values for this attribute are ",
                            ExpectedGenericValue => " 0, 1, 2, 4, 9, 18 or 36.",
                            TailMsg              => "",
                            MsgSeverity          => failure
                            );
      end case;


      case DATA_WIDTH_B is
        when 0 | 1 | 2 | 4 | 9 | 18 => null;
                                       
        when 36 => if (RAM_MODE /= "SDP") then
                     assert false
                       report "DRC error : The attribute DATA_WIDTH_B = 36 requires RAM_MODE set to SDP on RAMB8BWER."
                       severity failure;
                   end if;
                   
        when others => GenericValueCheckMessage
                         (  HeaderMsg            => " Attribute Syntax Error : ",
                            GenericName          => " DATA_WIDTH_B ",
                            EntityName           => "RAMB8BWER",
                            GenericValue         => DATA_WIDTH_B,
                            Unit                 => "",
                            ExpectedValueMsg     => " The Legal values for this attribute are ",
                            ExpectedGenericValue => " 0, 1, 2, 4, 9, 18 or 36.",
                            TailMsg              => "",
                            MsgSeverity          => failure
                            );
      end case;

      
      if (DATA_WIDTH_A = 0 and DATA_WIDTH_B = 0) then
        assert false
        report "Attribute Syntax Error : Attributes DATA_WIDTH_A and DATA_WIDTH_B on RAMB8BWER instance, both can not be 0."
        severity failure;
      end if;

      
      if (WRITE_MODE_A = "WRITE_FIRST") then
        wr_mode_a := "00";
      elsif (WRITE_MODE_A = "READ_FIRST") then
        wr_mode_a := "01";
      elsif (WRITE_MODE_A = "NO_CHANGE") then
        wr_mode_a := "10";
      else
        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " WRITE_MODE_A ",
            EntityName           => "RAMB8BWER",
            GenericValue         => WRITE_MODE_A,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " WRITE_FIRST, READ_FIRST or NO_CHANGE ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
      end if;
    
      if (WRITE_MODE_B = "WRITE_FIRST") then
        wr_mode_b := "00";
      elsif (WRITE_MODE_B = "READ_FIRST") then
        wr_mode_b := "01";
      elsif (WRITE_MODE_B = "NO_CHANGE") then
        wr_mode_b := "10";
      else
        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " WRITE_MODE_B ",
            EntityName           => "RAMB8BWER",
            GenericValue         => WRITE_MODE_B,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " WRITE_FIRST, READ_FIRST or NO_CHANGE ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
      end if;

    
      if (not ((SIM_COLLISION_CHECK = "NONE") or (SIM_COLLISION_CHECK = "WARNING_ONLY") or (SIM_COLLISION_CHECK = "GENERATE_X_ONLY") or (SIM_COLLISION_CHECK = "ALL"))) then
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "SIM_COLLISION_CHECK",
           EntityName => "RAMB8BWER",
           GenericValue => SIM_COLLISION_CHECK,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are ALL, NONE, WARNING_ONLY or GENERATE_X_ONLY",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
      end if;


      if (RAM_MODE = "SDP") then
        
        if ((WRITE_MODE_A /= WRITE_MODE_B) or WRITE_MODE_A = "NO_CHANGE" or WRITE_MODE_A = "NO_CHANGE") then
          assert false
            report "DRC Error : Both attributes WRITE_MODE_A and WRITE_MODE_B must be set to READ_FIRST or both attributes must be set to WRITE_FIRST when RAM_MODE = SDP on RAMB8BWER instance."
            severity failure;
        end if;

        
        if (DATA_WIDTH_A /= 36 or DATA_WIDTH_B /= 36) then
          assert false
            report "DRC Error : DATA_WIDTH_A and DATA_WIDTH_B are required to be set to 36 in simple dual port (SDP) mode on RAMB8BWER instance."
            severity failure;
        end if;

      end if;
      
      
      if (RAM_MODE /= "TDP" and RAM_MODE /= "SDP") then 
        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " RAM_MODE ",
            EntityName           => "RAMB8BWER",
            GenericValue         => RAM_MODE,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " TDP or SDP ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
      end if;


    end if;
    -- end of FIRST_TIME
    

    if (rising_edge(clkawrclk_dly)) then

      if (enawren_dly = '1') then      
        time_port_a := now;
        addrawraddr_reg_dly := addrawraddr_dly;
        weawel_reg_dly := weawel_dly;
        diadi_reg_dly := diadi_dly;
        dipadip_reg_dly := dipadip_dly;
        ox_addra_reconstruct_reg := ox_addra_reconstruct;
      end if;
      
    end if;
    
    if (rising_edge(clkbrdclk_dly)) then

      if (enbrden_dly = '1') then
        time_port_b := now;
        addrbrdaddr_reg_dly := addrbrdaddr_dly;
        webweu_reg_dly := webweu_dly;
        dibdi_reg_dly := dibdi_dly;
        dipbdip_reg_dly := dipbdip_dly;
        ox_addrb_reconstruct_reg := ox_addrb_reconstruct;
      end if;
      
    end if;
    
    if (gsr_dly = '1' or FIRST_TIME) then

      doado_out(a_width-1 downto 0) <= INIT_A_STD(a_width-1 downto 0);

      if (a_width >= 8) then
        dopadop_out(a_widthp-1 downto 0) <= INIT_A_STD((a_width+a_widthp)-1 downto a_width);            
      end if;

      dobdo_out(b_width-1 downto 0) <= INIT_B_STD(b_width-1 downto 0);          

      if (b_width >= 8) then
        dopbdop_out(b_widthp-1 downto 0) <= INIT_B_STD((b_width+b_widthp)-1 downto b_width);            
      end if;

      FIRST_TIME := false;
      
    elsif (gsr_dly = '0') then

     if (rising_edge(clkawrclk_dly) or rising_edge(clkbrdclk_dly)) then

-------------------------------------------------------------------------------
-- Collision starts
-------------------------------------------------------------------------------

       if (SIM_COLLISION_CHECK /= "NONE") then

         if (time_port_a > time_port_b) then
           
           if (time_port_a - time_port_b <= 100 ps) then
             viol_time := 1;
           elsif (time_port_a - time_port_b <= SETUP_READ_FIRST) then
             viol_time := 2;
           end if;

         else
  
           if (time_port_b - time_port_a <= 100 ps) then
             viol_time := 1;
           elsif (time_port_b - time_port_a <= SETUP_READ_FIRST) then
             viol_time := 2;
           end if;

         end if;

           
        if (enawren_dly = '0' or enbrden_dly = '0') then
          viol_time := 0;
        end if;

        
        if ((DATA_WIDTH_A <= 9 and weawel_dly(0) = '0') or (DATA_WIDTH_A = 18 and weawel_dly(1 downto 0) = "00") or (DATA_WIDTH_A = 36 and weawel_dly(3 downto 0) = "0000")) then
          if ((DATA_WIDTH_B <= 9 and webweu_dly(0) = '0') or (DATA_WIDTH_B = 18 and webweu_dly(1 downto 0) = "00") or (DATA_WIDTH_B = 36 and webweu_dly(3 downto 0) = "0000")) then
            viol_time := 0;
          end if;
        end if;

        
        if (viol_time /= 0) then
          
          if ((rising_edge(clkawrclk_dly) and rising_edge(clkbrdclk_dly)) or  viol_time = 1) then
            
            if (addrawraddr_dly(12 downto col_addr_lsb) = addrbrdaddr_dly(12 downto col_addr_lsb)) then
              
              viol_type := "01";
              chk_col_same_clk := 1;
              
              prcd_rd_ram_a (addrawraddr_dly, doado_buf, dopadop_buf, mem, memp);
              prcd_rd_ram_b (addrbrdaddr_dly, dobdo_buf, dopbdop_buf, mem, memp);
              
              prcd_col_wr_ram_a (viol_time, "00", webweu_dly, weawel_dly, di_x, di_x(7 downto 0), addrbrdaddr_dly, addrawraddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              prcd_col_wr_ram_b (viol_time, "00", weawel_dly, webweu_dly, di_x, di_x(7 downto 0), addrawraddr_dly, addrbrdaddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              chk_col_same_clk := 0;
              
              prcd_col_rd_ram_a (viol_type, "01", webweu_dly, weawel_dly, addrawraddr_dly, doado_buf, dopadop_buf, mem, memp, wr_mode_a);
              prcd_col_rd_ram_b (viol_type, "01", weawel_dly, webweu_dly, addrbrdaddr_dly, dobdo_buf, dopbdop_buf, mem, memp, wr_mode_b);

              prcd_col_wr_ram_a (viol_time, "10", webweu_dly, weawel_dly, diadi_dly, dipadip_dly, addrbrdaddr_dly, addrawraddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              prcd_col_wr_ram_b (viol_time, "10", weawel_dly, webweu_dly, dibdi_dly, dipbdip_dly, addrawraddr_dly, addrbrdaddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", webweu_dly, weawel_dly, addrawraddr_dly, doado_buf, dopadop_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", weawel_dly, webweu_dly, addrbrdaddr_dly, dobdo_buf, dopbdop_buf, mem, memp, wr_mode_b);
              end if;

            elsif ((wr_mode_a = "01" or wr_mode_b = "01") and (ox_addra_reconstruct(12 downto col_addr_lsb) = ox_addrb_reconstruct(12 downto col_addr_lsb))) then
              
              viol_type := "01";
              chk_ox_msg := 1;
              chk_ox_same_clk := 1;
              
              prcd_rd_ram_a (addrawraddr_dly, doado_buf, dopadop_buf, mem, memp);
              prcd_rd_ram_b (addrbrdaddr_dly, dobdo_buf, dopbdop_buf, mem, memp);
              
              prcd_col_wr_ram_a (viol_time, "00", webweu_dly, weawel_dly, di_x, di_x(7 downto 0), addrbrdaddr_dly, addrawraddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              prcd_col_wr_ram_b (viol_time, "00", weawel_dly, webweu_dly, di_x, di_x(7 downto 0), addrawraddr_dly, addrbrdaddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              chk_ox_msg := 0;
              chk_ox_same_clk := 0;
              
              prcd_ox_wr_ram_a (viol_time, "10", webweu_dly, weawel_dly, diadi_dly, dipadip_dly, addrbrdaddr_dly, addrawraddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              prcd_ox_wr_ram_b (viol_time, "10", weawel_dly, webweu_dly, dibdi_dly, dipbdip_dly, addrawraddr_dly, addrbrdaddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              
              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", webweu_dly, weawel_dly, addrawraddr_dly, doado_buf, dopadop_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", weawel_dly, webweu_dly, addrbrdaddr_dly, dobdo_buf, dopbdop_buf, mem, memp, wr_mode_b);
              end if;

            else
              viol_time := 0;
              
            end if;


          elsif (rising_edge(clkawrclk_dly) and  (not(rising_edge(clkbrdclk_dly)))) then
            
            if (addrawraddr_dly(12 downto col_addr_lsb) = addrbrdaddr_reg_dly(12 downto col_addr_lsb)) then
              
              viol_type := "10";

              prcd_rd_ram_a (addrawraddr_dly, doado_buf, dopadop_buf, mem, memp);

              prcd_col_wr_ram_a (viol_time, "00", webweu_reg_dly, weawel_dly, di_x, di_x(7 downto 0), addrbrdaddr_reg_dly, addrawraddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              prcd_col_wr_ram_b (viol_time, "00", weawel_dly, webweu_reg_dly, di_x, di_x(7 downto 0), addrawraddr_dly, addrbrdaddr_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              prcd_col_rd_ram_a (viol_type, "01", webweu_reg_dly, weawel_dly, addrawraddr_dly, doado_buf, dopadop_buf, mem, memp, wr_mode_a);
              prcd_col_rd_ram_b (viol_type, "01", weawel_dly, webweu_reg_dly, addrbrdaddr_reg_dly, dobdo_buf, dopbdop_buf, mem, memp, wr_mode_b);

              prcd_col_wr_ram_a (viol_time, "10", webweu_reg_dly, weawel_dly, diadi_dly, dipadip_dly, addrbrdaddr_reg_dly, addrawraddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              prcd_col_wr_ram_b (viol_time, "10", weawel_dly, webweu_reg_dly, dibdi_reg_dly, dipbdip_reg_dly, addrawraddr_dly, addrbrdaddr_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

			    
              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", webweu_reg_dly, weawel_dly, addrawraddr_dly, doado_buf, dopadop_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", weawel_dly, webweu_reg_dly, addrbrdaddr_reg_dly, dobdo_buf, dopbdop_buf, mem, memp, wr_mode_b);
              end if;
              
              if (wr_mode_a = "01" or wr_mode_b = "01") then 
                prcd_col_wr_ram_a (viol_time, "10", webweu_reg_dly, weawel_dly, di_x, di_x(7 downto 0), addrbrdaddr_reg_dly, addrawraddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
                prcd_col_wr_ram_b (viol_time, "10", weawel_dly, webweu_reg_dly, di_x, di_x(7 downto 0), addrawraddr_dly, addrbrdaddr_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              end if;

              
            elsif ((wr_mode_a = "01" or wr_mode_b = "01") and (ox_addra_reconstruct(12 downto col_addr_lsb) = ox_addrb_reconstruct_reg(12 downto col_addr_lsb))) then

              viol_type := "10";
              chk_ox_msg := 1;
              
              prcd_rd_ram_a (addrawraddr_dly, doado_buf, dopadop_buf, mem, memp);

              prcd_col_wr_ram_a (viol_time, "00", webweu_reg_dly, weawel_dly, di_x, di_x(7 downto 0), addrbrdaddr_reg_dly, addrawraddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              prcd_col_wr_ram_b (viol_time, "00", weawel_dly, webweu_reg_dly, di_x, di_x(7 downto 0), addrawraddr_dly, addrbrdaddr_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              
              chk_ox_msg := 0;

              prcd_ox_wr_ram_a (viol_time, "10", webweu_reg_dly, weawel_dly, diadi_dly, dipadip_dly, addrbrdaddr_reg_dly, addrawraddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              prcd_ox_wr_ram_b (viol_time, "10", weawel_dly, webweu_reg_dly, dibdi_reg_dly, dipbdip_reg_dly, addrawraddr_dly, addrbrdaddr_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

			    
              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", webweu_reg_dly, weawel_dly, addrawraddr_dly, doado_buf, dopadop_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", weawel_dly, webweu_reg_dly, addrbrdaddr_reg_dly, dobdo_buf, dopbdop_buf, mem, memp, wr_mode_b);
              end if;
              

              prcd_col_wr_ram_a (viol_time, "10", webweu_reg_dly, "11111111", di_x, di_x(7 downto 0), addrbrdaddr_reg_dly, addrawraddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              prcd_col_wr_ram_b (viol_time, "10", weawel_dly, "11111111", di_x, di_x(7 downto 0), addrawraddr_dly, addrbrdaddr_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              
            else
              viol_time := 0;
              
            end if;

          elsif ((not(rising_edge(clkawrclk_dly))) and rising_edge(clkbrdclk_dly)) then

            if (addrawraddr_reg_dly(12 downto col_addr_lsb) = addrbrdaddr_dly(12 downto col_addr_lsb)) then
                              
              viol_type := "11";

              prcd_rd_ram_b (addrbrdaddr_dly, dobdo_buf, dopbdop_buf, mem, memp);

              prcd_col_wr_ram_a (viol_time, "00", webweu_dly, weawel_reg_dly, di_x, di_x(7 downto 0), addrbrdaddr_dly, addrawraddr_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              prcd_col_wr_ram_b (viol_time, "00", weawel_reg_dly, webweu_dly, di_x, di_x(7 downto 0), addrawraddr_reg_dly, addrbrdaddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              prcd_col_rd_ram_a (viol_type, "01", webweu_dly, weawel_reg_dly, addrawraddr_reg_dly, doado_buf, dopadop_buf, mem, memp, wr_mode_a);
              prcd_col_rd_ram_b (viol_type, "01", weawel_reg_dly, webweu_dly, addrbrdaddr_dly, dobdo_buf, dopbdop_buf, mem, memp, wr_mode_b);

              prcd_col_wr_ram_a (viol_time, "10", webweu_dly, weawel_reg_dly, diadi_reg_dly, dipadip_reg_dly, addrbrdaddr_dly, addrawraddr_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              prcd_col_wr_ram_b (viol_time, "10", weawel_reg_dly, webweu_dly, dibdi_dly, dipbdip_dly, addrawraddr_reg_dly, addrbrdaddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

			    
              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", webweu_dly, weawel_reg_dly, addrawraddr_reg_dly, doado_buf, dopadop_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", weawel_reg_dly, webweu_dly, addrbrdaddr_dly, dobdo_buf, dopbdop_buf, mem, memp, wr_mode_b);
              end if;

              if (wr_mode_a = "01" or wr_mode_b = "01") then
                prcd_col_wr_ram_a (viol_time, "10", webweu_dly, weawel_reg_dly, di_x, di_x(7 downto 0), addrbrdaddr_dly, addrawraddr_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
                prcd_col_wr_ram_b (viol_time, "10", weawel_reg_dly, webweu_dly, di_x, di_x(7 downto 0), addrawraddr_reg_dly, addrbrdaddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              end if;

            elsif ((wr_mode_a = "01" or wr_mode_b = "01") and (ox_addra_reconstruct_reg(12 downto col_addr_lsb) = ox_addrb_reconstruct(12 downto col_addr_lsb))) then

              viol_type := "11";
              chk_ox_msg := 1;
              
              prcd_rd_ram_b (addrbrdaddr_dly, dobdo_buf, dopbdop_buf, mem, memp);

              prcd_col_wr_ram_a (viol_time, "00", webweu_dly, weawel_reg_dly, di_x, di_x(7 downto 0), addrbrdaddr_dly, addrawraddr_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              prcd_col_wr_ram_b (viol_time, "00", weawel_reg_dly, webweu_dly, di_x, di_x(7 downto 0), addrawraddr_reg_dly, addrbrdaddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              chk_ox_msg := 0;

              prcd_ox_wr_ram_a (viol_time, "10", webweu_dly, weawel_reg_dly, diadi_reg_dly, dipadip_reg_dly, addrbrdaddr_dly, addrawraddr_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              prcd_ox_wr_ram_b (viol_time, "10", weawel_reg_dly, webweu_dly, dibdi_dly, dipbdip_dly, addrawraddr_reg_dly, addrbrdaddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

			    
              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", webweu_dly, weawel_reg_dly, addrawraddr_reg_dly, doado_buf, dopadop_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", weawel_reg_dly, webweu_dly, addrbrdaddr_dly, dobdo_buf, dopbdop_buf, mem, memp, wr_mode_b);
              end if;

              prcd_col_wr_ram_a (viol_time, "10", webweu_dly, "11111111", di_x, di_x(7 downto 0), addrbrdaddr_dly, addrawraddr_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              prcd_col_wr_ram_b (viol_time, "10", weawel_reg_dly, "11111111", di_x, di_x(7 downto 0), addrawraddr_reg_dly, addrbrdaddr_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);


            else
              viol_time := 0;
              
            end if;
          end if;

          if (SIM_COLLISION_CHECK = "WARNING_ONLY") then
            viol_time := 0;
          end if;
          
        end if;
      end if;
-------------------------------------------------------------------------------
-- end collision
-------------------------------------------------------------------------------

    end if;
       
-------------------------------------------------------------------------------
-- Port A
-------------------------------------------------------------------------------        
    if (rising_edge(clkawrclk_dly) or ((rising_edge(rsta_dly) or rising_edge(enawren_dly)) and RSTTYPE = "ASYNC")) then

      if (gsr_dly = '0' and ((enawren_dly = '1' and RST_PRIORITY_A = "CE") or RST_PRIORITY_A = "SR")) then

        if (rsta_dly = '1' and EN_RSTRAM_A = TRUE) then

          doado_buf(a_width-1 downto 0) := SRVAL_A_STD(a_width-1 downto 0);
          doado_out(a_width-1 downto 0) <= SRVAL_A_STD(a_width-1 downto 0);          

          if (a_width >= 8) then
            dopadop_buf(a_widthp-1 downto 0) := SRVAL_A_STD((a_width+a_widthp)-1 downto a_width);
            dopadop_out(a_widthp-1 downto 0) <= SRVAL_A_STD((a_width+a_widthp)-1 downto a_width);            
          end if;

        end if;

        if (viol_time = 0 and rising_edge(clkawrclk_dly)) then
          -- read for rf
          if (wr_mode_a = "01" and (rsta_dly = '0' or EN_RSTRAM_A = FALSE)) then
            prcd_rd_ram_a (addrawraddr_dly, doado_buf, dopadop_buf, mem, memp);
          end if;

          if (enawren_dly = '1') then
            prcd_wr_ram_a (weawel_dly, diadi_dly, dipadip_dly, addrawraddr_dly, mem, memp);    
          end if;
          
          if (wr_mode_a /= "01" and (rsta_dly = '0' or EN_RSTRAM_A = FALSE)) then
            prcd_rd_ram_a (addrawraddr_dly, doado_buf, dopadop_buf, mem, memp);
          end if;

        
        end if;
        
      end if;
    end if;
    
-------------------------------------------------------------------------------
-- Port B
-------------------------------------------------------------------------------

    if (rising_edge(clkbrdclk_dly) or ((rising_edge(rstbrst_dly) or rising_edge(enbrden_dly)) and RSTTYPE = "ASYNC")) then


      if (gsr_dly = '0' and ((enbrden_dly = '1' and RST_PRIORITY_B = "CE") or RST_PRIORITY_B = "SR")) then

        if (rstbrst_dly = '1' and EN_RSTRAM_B = TRUE) then

          dobdo_buf(b_width-1 downto 0) := SRVAL_B_STD(b_width-1 downto 0);
          dobdo_out(b_width-1 downto 0) <= SRVAL_B_STD(b_width-1 downto 0);          

          if (b_width >= 8) then
            dopbdop_buf(b_widthp-1 downto 0) := SRVAL_B_STD((b_width+b_widthp)-1 downto b_width);
            dopbdop_out(b_widthp-1 downto 0) <= SRVAL_B_STD((b_width+b_widthp)-1 downto b_width);            
          end if;

        end if;


        if (viol_time = 0 and rising_edge(clkbrdclk_dly)) then
          
          if (wr_mode_b = "01" and (rstbrst_dly = '0' or EN_RSTRAM_B = FALSE)) then
            prcd_rd_ram_b (addrbrdaddr_dly, dobdo_buf, dopbdop_buf, mem, memp);            
          end if;

          if (enbrden_dly = '1') then
            prcd_wr_ram_b (webweu_dly, dibdi_dly, dipbdip_dly, addrbrdaddr_dly, mem, memp);
          end if;
          
          if (wr_mode_b /= "01" and (rstbrst_dly = '0' or EN_RSTRAM_B = FALSE)) then
            prcd_rd_ram_b (addrbrdaddr_dly, dobdo_buf, dopbdop_buf, mem, memp);
          end if;
          
        end if;
      end if;
    end if;
    

    if (enawren_dly = '1' and (rising_edge(clkawrclk_dly) or viol_time /= 0)) then

      if ((rsta_dly = '0' or EN_RSTRAM_A = FALSE) and (wr_mode_a /= "10" or (DATA_WIDTH_A <= 9 and weawel_dly(0) = '0') or (DATA_WIDTH_A = 18 and weawel_dly(1 downto 0) = "00") or (DATA_WIDTH_A = 36 and weawel_dly(3 downto 0) = "0000"))) then

        doado_out <= doado_buf;
        dopadop_out <= dopadop_buf;

      end if;
    end if;

    
    if (enbrden_dly = '1' and (rising_edge(clkbrdclk_dly) or viol_time /= 0)) then

      if ((rstbrst_dly = '0' or EN_RSTRAM_B = FALSE) and (wr_mode_b /= "10" or (DATA_WIDTH_B <= 9 and webweu_dly(0) = '0') or (DATA_WIDTH_B = 18 and webweu_dly(1 downto 0) = "00") or (DATA_WIDTH_B = 36 and webweu_dly(3 downto 0) = "0000"))) then

        dobdo_out <= dobdo_buf;
        dopbdop_out <= dopbdop_buf;

      end if;
    end if;

    
    viol_time := 0;
    viol_type := "00";
    col_wr_wr_msg := '1';
    col_wra_rdb_msg := '1';
    col_wrb_rda_msg := '1';


  end if;


  end process prcs_clk;


  outreg_clkawrclk: process (clkawrclk_dly, gsr_dly, rsta_dly, regcea_dly)
    variable FIRST_TIME : boolean := true;
    
  begin  -- process outreg_clkawrclk

    if (rising_edge(clkawrclk_dly) or rising_edge(gsr_dly) or FIRST_TIME or ((rising_edge(rsta_dly) or (rsta_dly = '1' and rising_edge(regcea_dly))) and RSTTYPE = "ASYNC")) then

      if (DOA_REG = 1) then
        
        if (gsr_dly = '1' or FIRST_TIME) then

          doado_outreg(a_width-1 downto 0) <= INIT_A_STD(a_width-1 downto 0);

          if (a_width >= 8) then
            dopadop_outreg(a_widthp-1 downto 0) <= INIT_A_STD((a_width+a_widthp)-1 downto a_width);
          end if;

          FIRST_TIME := false;
          
        elsif (gsr_dly = '0') then

          if (RST_PRIORITY_A = "CE") then

            if (regcea_dly = '1') then
              if (rsta_dly = '1') then

                doado_outreg(a_width-1 downto 0) <= SRVAL_A_STD(a_width-1 downto 0);

                if (a_width >= 8) then
                  dopadop_outreg(a_widthp-1 downto 0) <= SRVAL_A_STD((a_width+a_widthp)-1 downto a_width);
                end if;

              elsif (rsta_dly = '0') then
                doado_outreg <= doado_out;
                dopadop_outreg <= dopadop_out;

              end if;     
            end if;

          else
          
            if (rsta_dly = '1') then

              doado_outreg(a_width-1 downto 0) <= SRVAL_A_STD(a_width-1 downto 0);

              if (a_width >= 8) then
                dopadop_outreg(a_widthp-1 downto 0) <= SRVAL_A_STD((a_width+a_widthp)-1 downto a_width);
              end if;

            elsif (rsta_dly = '0') then
              
              if (regcea_dly = '1') then

                doado_outreg <= doado_out;
                dopadop_outreg <= dopadop_out;

              end if;     
            end if;
          end if;
        end if;
      end if;

    end if;
  end process outreg_clkawrclk;
  

  outmux_clkawrclk: process (doado_out, dopadop_out, doado_outreg, dopadop_outreg)
  begin  -- process outmux_clkawrclk

      case DOA_REG is
        when 0 =>
                  doado_out_out(a_width-1 downto 0) <= doado_out(a_width-1 downto 0);
                  dopadop_out_out(a_widthp-1 downto 0) <= dopadop_out(a_widthp-1 downto 0);
        when 1 =>
                  doado_out_out(a_width-1 downto 0) <= doado_outreg(a_width-1 downto 0);
                  dopadop_out_out(a_widthp-1 downto 0) <= dopadop_outreg(a_widthp-1 downto 0);
        
        when others => assert false
                       report "Attribute Syntax Error: The allowed integer values for DOA_REG are 0 or 1."
                       severity Failure;
      end case;

  end process outmux_clkawrclk;
  

  outreg_clkbrdclk: process (clkbrdclk_dly, gsr_dly, rstbrst_dly, regcebregce_dly)
    variable FIRST_TIME : boolean := true;

  begin  -- process outreg_clkbrdclk

    if (rising_edge(clkbrdclk_dly) or rising_edge(gsr_dly) or FIRST_TIME or ((rising_edge(rstbrst_dly) or (rstbrst_dly = '1' and rising_edge(regcebregce_dly))) and RSTTYPE = "ASYNC")) then

      if (DOB_REG = 1) then
        
        if (gsr_dly = '1' or FIRST_TIME) then
          dobdo_outreg(b_width-1 downto 0) <= INIT_B_STD(b_width-1 downto 0);

          if (b_width >= 8) then
            dopbdop_outreg(b_widthp-1 downto 0) <= INIT_B_STD((b_width+b_widthp)-1 downto b_width);
          end if;

          FIRST_TIME := false;
          
        elsif (gsr_dly = '0') then

          if (RST_PRIORITY_B = "CE") then

            if (regcebregce_dly = '1') then
              if (rstbrst_dly = '1') then

                dobdo_outreg(b_width-1 downto 0) <= SRVAL_B_STD(b_width-1 downto 0);

                if (b_width >= 8) then
                  dopbdop_outreg(b_widthp-1 downto 0) <= SRVAL_B_STD((b_width+b_widthp)-1 downto b_width);
                end if;

              elsif (rstbrst_dly = '0') then

                dobdo_outreg <= dobdo_out;
                dopbdop_outreg <= dopbdop_out;

              end if;     
            end if;

          else
          
            if (rstbrst_dly = '1') then

              dobdo_outreg(b_width-1 downto 0) <= SRVAL_B_STD(b_width-1 downto 0);

              if (b_width >= 8) then
                dopbdop_outreg(b_widthp-1 downto 0) <= SRVAL_B_STD((b_width+b_widthp)-1 downto b_width);
              end if;

            elsif (rstbrst_dly = '0') then

              if (regcebregce_dly = '1') then

                dobdo_outreg <= dobdo_out;
                dopbdop_outreg <= dopbdop_out;

              end if;
            end if;
          end if;
        end if;
      end if;
      
    end if;
  end process outreg_clkbrdclk;

  
  outmux_clkbrdclk: process (dobdo_out, dopbdop_out, dobdo_outreg, dopbdop_outreg)
  begin  -- process outmux_clkbrdclk

      case DOB_REG is

        when 0 =>
                  dobdo_out_out(b_width-1 downto 0) <= dobdo_out(b_width-1 downto 0);
                  dopbdop_out_out(b_widthp-1 downto 0) <= dopbdop_out(b_widthp-1 downto 0);
        when 1 =>
                  dobdo_out_out(b_width-1 downto 0) <= dobdo_outreg(b_width-1 downto 0);
                  dopbdop_out_out(b_widthp-1 downto 0) <= dopbdop_outreg(b_widthp-1 downto 0);
                  
        when others => assert false
                       report "Attribute Syntax Error: The allowed integer values for DOB_REG are 0 or 1."
                       severity Failure;
      end case;

  end process outmux_clkbrdclk;


-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------
    
  prcs_output: process (doado_out_out, dopadop_out_out, dobdo_out_out, dopbdop_out_out)
  begin  -- process prcs_output

    if (RAM_MODE = "TDP") then

      DOADO <= doado_out_out(15 downto 0) after SYNC_PATH_DELAY;
      DOPADOP <= dopadop_out_out(1 downto 0) after SYNC_PATH_DELAY;
      DOBDO <= dobdo_out_out(15 downto 0) after SYNC_PATH_DELAY;
      DOPBDOP <= dopbdop_out_out(1 downto 0) after SYNC_PATH_DELAY;

    elsif (RAM_MODE = "SDP") then
        
      DOADO <= dobdo_out_out(15 downto 0) after SYNC_PATH_DELAY;
      DOBDO <= dobdo_out_out(31 downto 16) after SYNC_PATH_DELAY;
      DOPADOP <= dopbdop_out_out(1 downto 0) after SYNC_PATH_DELAY;
      DOPBDOP <= dopbdop_out_out(3 downto 2) after SYNC_PATH_DELAY;

    end if;
    
  end process prcs_output;
  

end RAMB8BWER_V;
