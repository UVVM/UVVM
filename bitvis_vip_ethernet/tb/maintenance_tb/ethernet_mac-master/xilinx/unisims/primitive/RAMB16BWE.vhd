-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/trilogy/VITAL/RAMB16BWE.vhd,v 1.4 2012/10/04 03:01:33 wloo Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2009 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component 16K-Bit Data
--  /   /                       and 2K-Bit Parity Dual Port Block RAM
-- /___/   /\     Filename : RAMB16BWE.vhd
-- \   \  /  \    Timestamp : Wed Sep 30 14:33:07 PDT 2009
--  \___\/\___\
--
-- Revision:
--    09/30/09 - Initial version.
--    07/13/10 - Initialized memory to zero for INIT_FILE (CR 560672).
--    10/02/12 - Fixed read problem of init_file (CR 679413).
-- End Revision

----- CELL RAMB16BWE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_TEXTIO.all;

library STD;
use STD.TEXTIO.all;

library unisim;
use unisim.vpkg.all;
use unisim.vcomponents.all;

entity RAMB16BWE is

  generic (

    DATA_WIDTH_A : integer := 0;
    DATA_WIDTH_B : integer := 0;

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
    INIT_20 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_21 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_22 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_23 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_24 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_25 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_26 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_27 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_28 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_29 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_30 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_31 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_32 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_33 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_34 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_35 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_36 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_37 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_38 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_39 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";

    INIT_A : bit_vector := X"000000000";
    INIT_B : bit_vector := X"000000000";

    INITP_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";

    INIT_FILE : string := "NONE";
    
    SIM_COLLISION_CHECK : string := "ALL";

    SRVAL_A : bit_vector := X"000000000";
    SRVAL_B : bit_vector := X"000000000";

    WRITE_MODE_A : string := "WRITE_FIRST";
    WRITE_MODE_B : string := "WRITE_FIRST"
    );

  port(
    DOA          : out std_logic_vector (31 downto 0);
    DOB          : out std_logic_vector (31 downto 0);
    DOPA         : out std_logic_vector (3 downto 0);
    DOPB         : out std_logic_vector (3 downto 0);

    ADDRA        : in  std_logic_vector (13 downto 0);
    ADDRB        : in  std_logic_vector (13 downto 0);
    CLKA         : in  std_ulogic;
    CLKB         : in  std_ulogic;
    DIA          : in  std_logic_vector (31 downto 0);
    DIB          : in  std_logic_vector (31 downto 0);
    DIPA         : in  std_logic_vector (3 downto 0);
    DIPB         : in  std_logic_vector (3 downto 0);
    ENA          : in  std_ulogic;
    ENB          : in  std_ulogic;
    SSRA         : in  std_ulogic;
    SSRB         : in  std_ulogic;
    WEA          : in  std_logic_vector (3 downto 0);
    WEB          : in  std_logic_vector (3 downto 0)
    );
  
end RAMB16BWE;

-- Architecture body --

architecture RAMB16BWE_V of RAMB16BWE is
  
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
      when 1 => func_mem_depth := 16384;
      when 2 => func_mem_depth := 8192;
      when 4 => func_mem_depth := 4096;
      when 9 => func_mem_depth := 2048;
      when 18 => func_mem_depth := 1024;
      when 36 => func_mem_depth := 512;
      when others => func_mem_depth := 16384;
    end case;
    return func_mem_depth;
  end;

  
  function GetMemoryDepthP (
    rdwr_width : in integer
    ) return integer is
    variable func_memp_depth : integer;
  begin
    case rdwr_width is
      when 9 => func_memp_depth := 2048;
      when 18 => func_memp_depth := 1024;
      when 36 => func_memp_depth := 512;
      when others => func_memp_depth := 2048;
    end case;
    return func_memp_depth;
  end;

  
  function GetAddrbitLSB (
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

    
  function GetAddrbit124 (
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

  
  function GetAddrbit8 (
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

  
  function GetAddrbit16 (
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

  
  function GetAddrbit32 (
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

  constant SYNC_PATH_DELAY : time  := 100 ps;
  constant SETUP_ALL       : time  := 1000 ps;
  constant SETUP_READ_FIRST : time := 3000 ps;

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
  constant addra_lbit_124 : integer := GetAddrbitLSB(DATA_WIDTH_A);
  constant addrb_lbit_124 : integer := GetAddrbitLSB(DATA_WIDTH_B);
  constant addra_bit_124 : integer := GetAddrbit124(DATA_WIDTH_A, widest_width);
  constant addrb_bit_124 : integer := GetAddrbit124(DATA_WIDTH_B, widest_width);
  constant addra_bit_8 : integer := GetAddrbit8(DATA_WIDTH_A, widest_width);
  constant addrb_bit_8 : integer := GetAddrbit8(DATA_WIDTH_B, widest_width);
  constant addra_bit_16 : integer := GetAddrbit16(DATA_WIDTH_A, widest_width);
  constant addrb_bit_16 : integer := GetAddrbit16(DATA_WIDTH_B, widest_width);
  constant col_addr_lsb : integer := GetAddrbitLSB(widest_width);
  constant tmp_widthp : integer := GetWidthpTmpWidthp(widest_width);

  type Two_D_array_type_tmp_mem is array ((mem_depth -  1) downto 0) of std_logic_vector((widest_width - 1) downto 0);
    
  type Two_D_array_type is array ((mem_depth -  1) downto 0) of std_logic_vector((width - 1) downto 0);
  type Two_D_parity_array_type is array ((memp_depth - 1) downto 0) of std_logic_vector((widthp -1) downto 0);

  type Two_D_array_type_initf is array ((mem_depth -  1) downto 0) of std_logic_vector((width_initf - 1) downto 0);
  type Two_D_parity_array_type_initf is array ((memp_depth - 1) downto 0) of std_logic_vector((widthp_initf -1) downto 0);


  signal ADDRA_dly    : std_logic_vector(15 downto 0) := (others => 'X');
  signal CLKA_dly     : std_ulogic                    := 'X';
  signal DIA_dly      : std_logic_vector(63 downto 0) := (others => 'X');
  signal DIPA_dly     : std_logic_vector(7 downto 0)  := (others => 'X');
  signal ENA_dly      : std_ulogic                    := 'X';
  signal SSRA_dly     : std_ulogic                    := 'X';
  signal WEA_dly      : std_logic_vector(7 downto 0)  := (others => 'X');
  signal ADDRB_dly    : std_logic_vector(15 downto 0) := (others => 'X');
  signal CLKB_dly     : std_ulogic                    := 'X';
  signal DIB_dly      : std_logic_vector(63 downto 0) := (others => 'X');
  signal DIPB_dly     : std_logic_vector(7 downto 0)  := (others => 'X');
  signal ENB_dly      : std_ulogic                    := 'X';
  signal SSRB_dly     : std_ulogic                    := 'X';
  signal WEB_dly      : std_logic_vector(7 downto 0)  := (others => 'X');
  
  signal doado_out : std_logic_vector(63 downto 0) := (others => 'X');
  signal dopadop_out : std_logic_vector(7 downto 0) := (others => 'X');
  signal dobdo_out : std_logic_vector(63 downto 0) := (others => 'X');
  signal dopbdop_out : std_logic_vector(7 downto 0) := (others => 'X');

  signal GSR_dly : std_ulogic := '0';
  signal di_x : std_logic_vector(63 downto 0) := (others => 'X');

  signal SRVAL_A_STD : std_logic_vector(35 downto 0) := To_StdLogicVector(SRVAL_A);
  signal INIT_A_STD : std_logic_vector(35 downto 0) := To_StdLogicVector(INIT_A);
  signal SRVAL_B_STD : std_logic_vector(35 downto 0) := To_StdLogicVector(SRVAL_B);
  signal INIT_B_STD : std_logic_vector(35 downto 0) := To_StdLogicVector(INIT_B);

  
  function slv_to_two_D_array(
    slv_length : integer;
    slv_width : integer;
    SLV : in std_logic_vector
    )
    return two_D_array_type is
    variable two_D_array : two_D_array_type;
    variable intermediate : std_logic_vector((slv_width - 1) downto 0);
  begin
    for i in 0 to (slv_length - 1) loop
      intermediate := SLV(((i*slv_width) + (slv_width - 1)) downto (i* slv_width));
      two_D_array(i) := intermediate; 
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
    variable intermediate : std_logic_vector((slv_width - 1) downto 0);
  begin
    for i in 0 to (slv_length - 1)loop
      intermediate := SLV(((i*slv_width) + (slv_width - 1)) downto (i* slv_width));
      two_D_parity_array(i) := intermediate; 
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
    constant wea_tmp : in std_ulogic;
    constant web_tmp : in std_ulogic;
    constant addra_tmp : in std_logic_vector (15 downto 0);
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    variable col_wr_wr_msg : inout std_ulogic;
    variable col_wra_rdb_msg : inout std_ulogic;
    variable col_wrb_rda_msg : inout std_ulogic
    ) is
    
    variable string_length_1 : integer;
    variable string_length_2 : integer;
    variable message : LINE;
    constant MsgSeverity : severity_level := Error;

  begin
    
    if ((SIM_COLLISION_CHECK = "ALL" or SIM_COLLISION_CHECK = "WARNING_ONLY")
        and (not(((WRITE_MODE_B = "READ_FIRST" and web_tmp = '1' and wea_tmp = '0') and (not(rising_edge(clka_dly) and (not(rising_edge(clkb_dly))))))
              or ((WRITE_MODE_A = "READ_FIRST" and wea_tmp = '1' and web_tmp = '0') and (not(rising_edge(clkb_dly) and (not(rising_edge(clka_dly))))))))) then

      if ((addra_tmp'length mod 4) = 0) then
        string_length_1 := addra_tmp'length/4;
      elsif ((addra_tmp'length mod 4) > 0) then
        string_length_1 := addra_tmp'length/4 + 1;      
      end if;
      if ((addrb_tmp'length mod 4) = 0) then
        string_length_2 := addrb_tmp'length/4;
      elsif ((addrb_tmp'length mod 4) > 0) then
        string_length_2 := addrb_tmp'length/4 + 1;      
      end if;

      if (wea_tmp = '1' and web_tmp = '1' and col_wr_wr_msg = '1') then
        Write ( message, STRING'(" Memory Collision Error on RAMB16BWE :"));
        Write ( message, STRING'(RAMB16BWE'path_name));
        Write ( message, STRING'(" at simulation time "));
        Write ( message, now);
        Write ( message, STRING'("."));
        Write ( message, LF );
        Write ( message, STRING'(" A write was requested to the same address simultaneously at both Port A and Port B of the RAM."));
        Write ( message, STRING'(" The contents written to the RAM at address location "));      
        Write ( message, SLV_X_TO_HEX(addra_tmp, string_length_1));
        Write ( message, STRING'(" (hex) "));            
        Write ( message, STRING'("of Port A and address location "));
        Write ( message, SLV_X_TO_HEX(addrb_tmp, string_length_2));
        Write ( message, STRING'(" (hex) "));            
        Write ( message, STRING'("of Port B are unknown. "));
        ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
        DEALLOCATE (message);
        col_wr_wr_msg := '0';
        
      elsif (wea_tmp = '1' and web_tmp = '0' and col_wra_rdb_msg = '1') then
        Write ( message, STRING'(" Memory Collision Error on RAMB16BWE :"));
        Write ( message, STRING'(RAMB16BWE'path_name));
        Write ( message, STRING'(" at simulation time "));
        Write ( message, now);
        Write ( message, STRING'("."));
        Write ( message, LF );            
        Write ( message, STRING'(" A read was performed on address "));
        Write ( message, SLV_X_TO_HEX(addrb_tmp, string_length_2));
        Write ( message, STRING'(" (hex) "));            
        Write ( message, STRING'("of port B while a write was requested to the same address on Port A. "));
        Write ( message, STRING'(" The write will be successful however the read value on port B is unknown until the next CLKB cycle. "));
        ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
        DEALLOCATE (message);
        col_wra_rdb_msg := '0';
        
      elsif (wea_tmp = '0' and web_tmp = '1' and col_wrb_rda_msg = '1') then
        Write ( message, STRING'(" Memory Collision Error on RAMB16BWE :"));
        Write ( message, STRING'(RAMB16BWE'path_name));
        Write ( message, STRING'(" at simulation time "));
        Write ( message, now);
        Write ( message, STRING'("."));
        Write ( message, LF );            
        Write ( message, STRING'(" A read was performed on address "));
        Write ( message, SLV_X_TO_HEX(addra_tmp, string_length_1));
        Write ( message, STRING'(" (hex) "));            
        Write ( message, STRING'("of port A while a write was requested to the same address on Port B. "));
        Write ( message, STRING'(" The write will be successful however the read value on port A is unknown until the next CLKA cycle. "));
        ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
        DEALLOCATE (message);
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
    constant addra_tmp : in std_logic_vector (15 downto 0);
    variable doado_tmp : inout std_logic_vector (63 downto 0);
    variable dopadop_tmp : inout std_logic_vector (7 downto 0);
    constant mem : in Two_D_array_type;
    constant memp : in Two_D_parity_array_type     
    ) is
    variable prcd_tmp_addra_dly_depth : integer;
    variable prcd_tmp_addra_dly_width : integer;

  begin
    
    case a_width is

      when 1 | 2 | 4 => if (a_width >= width) then
                          prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto addra_lbit_124));
                          doado_tmp(a_width-1 downto 0) := mem(prcd_tmp_addra_dly_depth);
                        else
                          prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto addra_bit_124 + 1));
                          prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(addra_bit_124 downto addra_lbit_124));
                          doado_tmp(a_width-1 downto 0) := mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * a_width) + a_width - 1 downto prcd_tmp_addra_dly_width * a_width);
                        end if;

      when 8 => if (a_width >= width) then
                  prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 3));
                  doado_tmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth);
                  dopadop_tmp(0 downto 0) := memp(prcd_tmp_addra_dly_depth);
                else
                  prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto addra_bit_8 + 1));
                  prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(addra_bit_8 downto 3));
                  doado_tmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 8) + 7 downto prcd_tmp_addra_dly_width * 8);
                  dopadop_tmp(0 downto 0) := memp(prcd_tmp_addra_dly_depth)(prcd_tmp_addra_dly_width downto prcd_tmp_addra_dly_width);
                end if;

      when 16 => if (a_width >= width) then
                  prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                  doado_tmp(15 downto 0) := mem(prcd_tmp_addra_dly_depth);
                  dopadop_tmp(1 downto 0) := memp(prcd_tmp_addra_dly_depth);
                 else
                  prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto addra_bit_16 + 1));
                  prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(addra_bit_16 downto 4));
                  doado_tmp(15 downto 0) := mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 16) + 15 downto prcd_tmp_addra_dly_width * 16);
                  dopadop_tmp(1 downto 0) := memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2) + 1 downto prcd_tmp_addra_dly_width * 2);
                 end if;

      when 32 => if (a_width >= width) then
                  prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 5));
                  doado_tmp(31 downto 0) := mem(prcd_tmp_addra_dly_depth);
                  dopadop_tmp(3 downto 0) := memp(prcd_tmp_addra_dly_depth);
                end if;

      when others => null;

    end case;

  end prcd_rd_ram_a;

  
  procedure prcd_rd_ram_b (
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    variable dobdo_tmp : inout std_logic_vector (63 downto 0);
    variable dopbdop_tmp : inout std_logic_vector (7 downto 0);
    constant mem : in Two_D_array_type;
    constant memp : in Two_D_parity_array_type     
    ) is
    variable prcd_tmp_addrb_dly_depth : integer;
    variable prcd_tmp_addrb_dly_width : integer;

  begin
    
    case b_width is

      when 1 | 2 | 4 => if (b_width >= width) then
                          prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto addrb_lbit_124));
                          dobdo_tmp(b_width-1 downto 0) := mem(prcd_tmp_addrb_dly_depth);
                        else
                          prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto addrb_bit_124 + 1));
                          prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(addrb_bit_124 downto addrb_lbit_124));
                          dobdo_tmp(b_width-1 downto 0) := mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * b_width) + b_width - 1 downto prcd_tmp_addrb_dly_width * b_width);
                        end if;

      when 8 => if (b_width >= width) then
                  prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 3));
                  dobdo_tmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth);
                  dopbdop_tmp(0 downto 0) := memp(prcd_tmp_addrb_dly_depth);
                else
                  prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto addrb_bit_8 + 1));
                  prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(addrb_bit_8 downto 3));
                  dobdo_tmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 8) + 7 downto prcd_tmp_addrb_dly_width * 8);
                  dopbdop_tmp(0 downto 0) := memp(prcd_tmp_addrb_dly_depth)(prcd_tmp_addrb_dly_width downto prcd_tmp_addrb_dly_width);
                end if;

      when 16 => if (b_width >= width) then
                  prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                  dobdo_tmp(15 downto 0) := mem(prcd_tmp_addrb_dly_depth);
                  dopbdop_tmp(1 downto 0) := memp(prcd_tmp_addrb_dly_depth);
                 else
                  prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto addrb_bit_16 + 1));
                  prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(addrb_bit_16 downto 4));
                  dobdo_tmp(15 downto 0) := mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 16) + 15 downto prcd_tmp_addrb_dly_width * 16);
                  dopbdop_tmp(1 downto 0) := memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2) + 1 downto prcd_tmp_addrb_dly_width * 2);
                 end if;

      when 32 => if (b_width >= width) then
                  prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                  dobdo_tmp(31 downto 0) := mem(prcd_tmp_addrb_dly_depth);
                  dopbdop_tmp(3 downto 0) := memp(prcd_tmp_addrb_dly_depth);
                end if;

      when others => null;

    end case;

  end prcd_rd_ram_b;


  procedure prcd_col_wr_ram_a (
    constant seq : in std_logic_vector (1 downto 0);
    constant web_tmp : in std_logic_vector (7 downto 0);
    constant wea_tmp : in std_logic_vector (7 downto 0);
    constant dia_tmp : in std_logic_vector (63 downto 0);
    constant dipa_tmp : in std_logic_vector (7 downto 0);
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    constant addra_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type;
    variable col_wr_wr_msg : inout std_ulogic;
    variable col_wra_rdb_msg : inout std_ulogic;
    variable col_wrb_rda_msg : inout std_ulogic
    ) is
    variable prcd_tmp_addra_dly_depth : integer;
    variable prcd_tmp_addra_dly_width : integer;
    variable junk : std_ulogic;

  begin
    
    case a_width is

      when 1 | 2 | 4 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and a_width > b_width) or seq = "10") then
                          if (a_width >= width) then
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto addra_lbit_124));
                            prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(a_width-1 downto 0), '0', mem(prcd_tmp_addra_dly_depth), junk);
                          else
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto addra_bit_124 + 1));
                            prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(addra_bit_124 downto addra_lbit_124));
                            prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(a_width-1 downto 0), '0', mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * a_width) + a_width - 1 downto (prcd_tmp_addra_dly_width * a_width)), junk);
                          end if;

                          if (seq = "00") then
                            prcd_chk_for_col_msg (wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                          end if;
                        end if;
      
      when 8 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and a_width > b_width) or seq = "10") then
                  if (a_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 3));
                    prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth), memp(prcd_tmp_addra_dly_depth)(0));
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto addra_bit_8 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(addra_bit_8 downto 3));
                    prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 8) + 7 downto (prcd_tmp_addra_dly_width * 8)), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width)));
                  end if;
  
                  if (seq = "00") then
                    prcd_chk_for_col_msg (wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                  end if;
                end if;

      when 16 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and a_width > b_width) or seq = "10") then
                  if (a_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                    prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)(7 downto 0), memp(prcd_tmp_addra_dly_depth)(0));
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto addra_bit_16 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(addra_bit_16 downto 4));
                    prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 16) + 7 downto (prcd_tmp_addra_dly_width * 16)), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2)));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                  end if;
                 
                  if (a_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                    prcd_write_ram_col (web_tmp(1), wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)(15 downto 8), memp(prcd_tmp_addra_dly_depth)(1));
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto addra_bit_16 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(addra_bit_16 downto 4));
                    prcd_write_ram_col (web_tmp(1), wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 16) + 15 downto (prcd_tmp_addra_dly_width * 16) + 8), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2) + 1));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                  end if;
                 
                end if;

      when 32 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and a_width > b_width) or seq = "10") then

                   prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 5));
                   prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)(7 downto 0), memp(prcd_tmp_addra_dly_depth)(0));

                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                   prcd_write_ram_col (web_tmp(1), wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)(15 downto 8), memp(prcd_tmp_addra_dly_depth)(1));

                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;
                   
                   prcd_write_ram_col (web_tmp(2), wea_tmp(2), dia_tmp(23 downto 16), dipa_tmp(2), mem(prcd_tmp_addra_dly_depth)(23 downto 16), memp(prcd_tmp_addra_dly_depth)(2));

                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(2), web_tmp(2), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                   prcd_write_ram_col (web_tmp(3), wea_tmp(3), dia_tmp(31 downto 24), dipa_tmp(3), mem(prcd_tmp_addra_dly_depth)(31 downto 24), memp(prcd_tmp_addra_dly_depth)(3));

                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(3), web_tmp(3), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                 end if;

      when others => null;

    end case;

  end prcd_col_wr_ram_a;

  
  procedure prcd_col_wr_ram_b (
    constant seq : in std_logic_vector (1 downto 0);
    constant wea_tmp : in std_logic_vector (7 downto 0);
    constant web_tmp : in std_logic_vector (7 downto 0);
    constant dib_tmp : in std_logic_vector (63 downto 0);
    constant dipb_tmp : in std_logic_vector (7 downto 0);
    constant addra_tmp : in std_logic_vector (15 downto 0);
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type;
    variable col_wr_wr_msg : inout std_ulogic;
    variable col_wra_rdb_msg : inout std_ulogic;
    variable col_wrb_rda_msg : inout std_ulogic
    ) is
    variable prcd_tmp_addrb_dly_depth : integer;
    variable prcd_tmp_addrb_dly_width : integer;
    variable junk : std_ulogic;

  begin
    
    case b_width is

      when 1 | 2 | 4 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and b_width > a_width) or seq = "10") then
                          if (b_width >= width) then
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto addrb_lbit_124));
                            prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(b_width-1 downto 0), '0', mem(prcd_tmp_addrb_dly_depth), junk);
                          else
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto addrb_bit_124 + 1));
                            prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(addrb_bit_124 downto addrb_lbit_124));
                            prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(b_width-1 downto 0), '0', mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * b_width) + b_width - 1 downto (prcd_tmp_addrb_dly_width * b_width)), junk);
                          end if;

                          if (seq = "00") then
                            prcd_chk_for_col_msg (wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                          end if;
                        end if;

      when 8 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and b_width > a_width) or seq = "10") then
                  if (b_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 3));
                    prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth), memp(prcd_tmp_addrb_dly_depth)(0));
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto addrb_bit_8 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(addrb_bit_8 downto 3));
                    prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 8) + 7 downto (prcd_tmp_addrb_dly_width * 8)), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width)));
                  end if;
    
                  if (seq = "00") then
                    prcd_chk_for_col_msg (wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                  end if; 
                end if;

      when 16 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and b_width > a_width) or seq = "10") then
                  if (b_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                    prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)(7 downto 0), memp(prcd_tmp_addrb_dly_depth)(0));
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto addrb_bit_16 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(addrb_bit_16 downto 4));
                    prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 16) + 7 downto (prcd_tmp_addrb_dly_width * 16)), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2)));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                  end if;

                  if (b_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                    prcd_write_ram_col (wea_tmp(1), web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)(15 downto 8), memp(prcd_tmp_addrb_dly_depth)(1));
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto addrb_bit_16 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(addrb_bit_16 downto 4));
                    prcd_write_ram_col (wea_tmp(1), web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 16) + 15 downto (prcd_tmp_addrb_dly_width * 16) + 8), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2) + 1));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                  end if;

                end if;
      when 32 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and b_width > a_width) or seq = "10") then

                   prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                   prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)(7 downto 0), memp(prcd_tmp_addrb_dly_depth)(0));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                   prcd_write_ram_col (wea_tmp(1), web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)(15 downto 8), memp(prcd_tmp_addrb_dly_depth)(1));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;
                   
                   prcd_write_ram_col (wea_tmp(2), web_tmp(2), dib_tmp(23 downto 16), dipb_tmp(2), mem(prcd_tmp_addrb_dly_depth)(23 downto 16), memp(prcd_tmp_addrb_dly_depth)(2));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(2), web_tmp(2), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                   prcd_write_ram_col (wea_tmp(3), web_tmp(3), dib_tmp(31 downto 24), dipb_tmp(3), mem(prcd_tmp_addrb_dly_depth)(31 downto 24), memp(prcd_tmp_addrb_dly_depth)(3));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(3), web_tmp(3), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                 end if;

      when others => null;

    end case;

  end prcd_col_wr_ram_b;


  procedure prcd_col_rd_ram_a (
    constant viol_type_tmp : in std_logic_vector (1 downto 0);
    constant seq : in std_logic_vector (1 downto 0);
    constant web_tmp : in std_logic_vector (7 downto 0);
    constant wea_tmp : in std_logic_vector (7 downto 0);
    constant addra_tmp : in std_logic_vector (15 downto 0);
    variable doado_tmp : inout std_logic_vector (63 downto 0);
    variable dopadop_tmp : inout std_logic_vector (7 downto 0);
    constant mem : in Two_D_array_type;
    constant memp : in Two_D_parity_array_type;
    constant wr_mode_a_tmp : in std_logic_vector (1 downto 0)

    ) is
    variable prcd_tmp_addra_dly_depth : integer;
    variable prcd_tmp_addra_dly_width : integer;
    variable junk : std_ulogic;
    variable doado_ltmp : std_logic_vector (63 downto 0);
    variable dopadop_ltmp : std_logic_vector (7 downto 0);
    
  begin

    doado_ltmp := (others => '0');
    dopadop_ltmp := (others => '0');
    
    case a_width is
      
      when 1 | 2 | 4 => if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and web_tmp(0) = '1' and wea_tmp(0) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(0) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(0) /= '1')) then

                          if (a_width >= width) then
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto addra_lbit_124));
                            doado_ltmp(a_width-1 downto 0) := mem(prcd_tmp_addra_dly_depth);
                          else
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto addra_bit_124 + 1));
                            prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(addra_bit_124 downto addra_lbit_124));
                            doado_ltmp(a_width-1 downto 0) := mem(prcd_tmp_addra_dly_depth)(((prcd_tmp_addra_dly_width * a_width) + a_width - 1) downto (prcd_tmp_addra_dly_width * a_width));

                          end if;
                          prcd_x_buf (wr_mode_a_tmp, 3, 0, 0, doado_ltmp, doado_tmp, dopadop_ltmp, dopadop_tmp);
                        end if;

      when 8 => if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and web_tmp(0) = '1' and wea_tmp(0) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(0) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(0) /= '1')) then

                  if (a_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 3));
                    doado_ltmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth);
                    dopadop_ltmp(0) := memp(prcd_tmp_addra_dly_depth)(0);
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto addra_bit_8 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(addra_bit_8 downto 3));
                    doado_ltmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth)(((prcd_tmp_addra_dly_width * 8) + 7) downto (prcd_tmp_addra_dly_width * 8));
                    dopadop_ltmp(0) := memp(prcd_tmp_addra_dly_depth)(prcd_tmp_addra_dly_width);
                  end if;
                  prcd_x_buf (wr_mode_a_tmp, 7, 0, 0, doado_ltmp, doado_tmp, dopadop_ltmp, dopadop_tmp);

                end if;

      when 16 => if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and web_tmp(0) = '1' and wea_tmp(0) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(0) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(0) /= '1')) then

                  if (a_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                    doado_ltmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth)(7 downto 0);
                    dopadop_ltmp(0) := memp(prcd_tmp_addra_dly_depth)(0);
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto addra_bit_16 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(addra_bit_16 downto 4));

                    doado_ltmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth)(((prcd_tmp_addra_dly_width * 16) + 7) downto (prcd_tmp_addra_dly_width * 16));                    
                    dopadop_ltmp(0) := memp(prcd_tmp_addra_dly_depth)(prcd_tmp_addra_dly_width * 2);
                  end if;
                  prcd_x_buf (wr_mode_a_tmp, 7, 0, 0, doado_ltmp, doado_tmp, dopadop_ltmp, dopadop_tmp);

                end if;

                if ((web_tmp(1) = '1' and wea_tmp(1) = '1') or (seq = "01" and web_tmp(1) = '1' and wea_tmp(1) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(1) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(1) /= '1')) then

                  if (a_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                    doado_ltmp(15 downto 8) := mem(prcd_tmp_addra_dly_depth)(15 downto 8);
                    dopadop_ltmp(1) := memp(prcd_tmp_addra_dly_depth)(1);
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto addra_bit_16 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(addra_bit_16 downto 4));

                    doado_ltmp(15 downto 8) := mem(prcd_tmp_addra_dly_depth)(((prcd_tmp_addra_dly_width * 16) + 15) downto ((prcd_tmp_addra_dly_width * 16) + 8));
                    dopadop_ltmp(1) := memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2) + 1);
                  end if;
                  prcd_x_buf (wr_mode_a_tmp, 15, 8, 1, doado_ltmp, doado_tmp, dopadop_ltmp, dopadop_tmp);
                  
                end if;

      when 32 => if (a_width >= width) then

                   prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 5));

                   if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and web_tmp(0) = '1' and wea_tmp(0) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(0) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(0) /= '1')) then

                     doado_ltmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth)(7 downto 0);
                     dopadop_ltmp(0) := memp(prcd_tmp_addra_dly_depth)(0);
                     prcd_x_buf (wr_mode_a_tmp, 7, 0, 0, doado_ltmp, doado_tmp, dopadop_ltmp, dopadop_tmp);

                   end if;

                   if ((web_tmp(1) = '1' and wea_tmp(1) = '1') or (seq = "01" and web_tmp(1) = '1' and wea_tmp(1) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(1) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(1) /= '1')) then

                     doado_ltmp(15 downto 8) := mem(prcd_tmp_addra_dly_depth)(15 downto 8);
                     dopadop_ltmp(1) := memp(prcd_tmp_addra_dly_depth)(1);
                     prcd_x_buf (wr_mode_a_tmp, 15, 8, 1, doado_ltmp, doado_tmp, dopadop_ltmp, dopadop_tmp);

                   end if;

                   if ((web_tmp(2) = '1' and wea_tmp(2) = '1') or (seq = "01" and web_tmp(2) = '1' and wea_tmp(2) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(2) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(2) /= '1')) then

                     doado_ltmp(23 downto 16) := mem(prcd_tmp_addra_dly_depth)(23 downto 16);
                     dopadop_ltmp(2) := memp(prcd_tmp_addra_dly_depth)(2);
                     prcd_x_buf (wr_mode_a_tmp, 23, 16, 2, doado_ltmp, doado_tmp, dopadop_ltmp, dopadop_tmp);

                   end if;

                   if ((web_tmp(3) = '1' and wea_tmp(3) = '1') or (seq = "01" and web_tmp(3) = '1' and wea_tmp(3) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(3) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(3) /= '1')) then

                     doado_ltmp(31 downto 24) := mem(prcd_tmp_addra_dly_depth)(31 downto 24);
                     dopadop_ltmp(3) := memp(prcd_tmp_addra_dly_depth)(3);
                     prcd_x_buf (wr_mode_a_tmp, 31, 24, 3, doado_ltmp, doado_tmp, dopadop_ltmp, dopadop_tmp);

                   end if;
  
                end if;
  
      when others => null;

    end case;

  end prcd_col_rd_ram_a;


  procedure prcd_col_rd_ram_b (
    constant viol_type_tmp : in std_logic_vector (1 downto 0);
    constant seq : in std_logic_vector (1 downto 0);
    constant wea_tmp : in std_logic_vector (7 downto 0);
    constant web_tmp : in std_logic_vector (7 downto 0);
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    variable dobdo_tmp : inout std_logic_vector (63 downto 0);
    variable dopbdop_tmp : inout std_logic_vector (7 downto 0);
    constant mem : in Two_D_array_type;
    constant memp : in Two_D_parity_array_type;
    constant wr_mode_b_tmp : in std_logic_vector (1 downto 0)

    ) is
    variable prcd_tmp_addrb_dly_depth : integer;
    variable prcd_tmp_addrb_dly_width : integer;
    variable junk : std_ulogic;
    variable dobdo_ltmp : std_logic_vector (63 downto 0);
    variable dopbdop_ltmp : std_logic_vector (7 downto 0);
    
  begin

    dobdo_ltmp := (others => '0');
    dopbdop_ltmp := (others => '0');
    
    case b_width is
      
      when 1 | 2 | 4 => if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and wea_tmp(0) = '1' and web_tmp(0) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(0) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(0) /= '1')) then

                          if (b_width >= width) then
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto addrb_lbit_124));
                            dobdo_ltmp(b_width-1 downto 0) := mem(prcd_tmp_addrb_dly_depth);
                          else
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto addrb_bit_124 + 1));
                            prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(addrb_bit_124 downto addrb_lbit_124));
                            dobdo_ltmp(b_width-1 downto 0) := mem(prcd_tmp_addrb_dly_depth)(((prcd_tmp_addrb_dly_width * b_width) + b_width - 1) downto (prcd_tmp_addrb_dly_width * b_width));
                          end if;
                          prcd_x_buf (wr_mode_b_tmp, 3, 0, 0, dobdo_ltmp, dobdo_tmp, dopbdop_ltmp, dopbdop_tmp);

                        end if;

      when 8 => if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and wea_tmp(0) = '1' and web_tmp(0) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(0) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(0) /= '1')) then

                  if (b_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 3));
                    dobdo_ltmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth);
                    dopbdop_ltmp(0) := memp(prcd_tmp_addrb_dly_depth)(0);
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto addrb_bit_8 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(addrb_bit_8 downto 3));
                    dobdo_ltmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth)(((prcd_tmp_addrb_dly_width * 8) + 7) downto (prcd_tmp_addrb_dly_width * 8));
                    dopbdop_ltmp(0) := memp(prcd_tmp_addrb_dly_depth)(prcd_tmp_addrb_dly_width);
                  end if;
                  prcd_x_buf (wr_mode_b_tmp, 7, 0, 0, dobdo_ltmp, dobdo_tmp, dopbdop_ltmp, dopbdop_tmp);

                end if;

      when 16 => if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and wea_tmp(0) = '1' and web_tmp(0) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(0) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(0) /= '1')) then

                  if (b_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                    dobdo_ltmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth)(7 downto 0);
                    dopbdop_ltmp(0) := memp(prcd_tmp_addrb_dly_depth)(0);
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto addrb_bit_16 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(addrb_bit_16 downto 4));

                    dobdo_ltmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth)(((prcd_tmp_addrb_dly_width * 16) + 7) downto (prcd_tmp_addrb_dly_width * 16));
                    dopbdop_ltmp(0) := memp(prcd_tmp_addrb_dly_depth)(prcd_tmp_addrb_dly_width * 2);
                  end if;
                  prcd_x_buf (wr_mode_b_tmp, 7, 0, 0, dobdo_ltmp, dobdo_tmp, dopbdop_ltmp, dopbdop_tmp);

                end if;


                if ((web_tmp(1) = '1' and wea_tmp(1) = '1') or (seq = "01" and wea_tmp(1) = '1' and web_tmp(1) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(1) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(1) /= '1')) then

                  if (b_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                    dobdo_ltmp(15 downto 8) := mem(prcd_tmp_addrb_dly_depth)(15 downto 8);
                    dopbdop_ltmp(1) := memp(prcd_tmp_addrb_dly_depth)(1);
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto addrb_bit_16 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(addrb_bit_16 downto 4));

                    dobdo_ltmp(15 downto 8) := mem(prcd_tmp_addrb_dly_depth)(((prcd_tmp_addrb_dly_width * 16) + 15) downto ((prcd_tmp_addrb_dly_width * 16) + 8));
                    dopbdop_ltmp(1) := memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2) + 1);
                  end if;
                  prcd_x_buf (wr_mode_b_tmp, 15, 8, 1, dobdo_ltmp, dobdo_tmp, dopbdop_ltmp, dopbdop_tmp);

                end if;

      when 32 => if (b_width >= width) then

                   prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));

                   if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and wea_tmp(0) = '1' and web_tmp(0) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(0) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(0) /= '1')) then

                     dobdo_ltmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth)(7 downto 0);
                     dopbdop_ltmp(0) := memp(prcd_tmp_addrb_dly_depth)(0);
                     prcd_x_buf (wr_mode_b_tmp, 7, 0, 0, dobdo_ltmp, dobdo_tmp, dopbdop_ltmp, dopbdop_tmp);

                   end if;

                   if ((web_tmp(1) = '1' and wea_tmp(1) = '1') or (seq = "01" and wea_tmp(1) = '1' and web_tmp(1) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(1) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(1) /= '1')) then

                     dobdo_ltmp(15 downto 8) := mem(prcd_tmp_addrb_dly_depth)(15 downto 8);
                     dopbdop_ltmp(1) := memp(prcd_tmp_addrb_dly_depth)(1);
                     prcd_x_buf (wr_mode_b_tmp, 15, 8, 1, dobdo_ltmp, dobdo_tmp, dopbdop_ltmp, dopbdop_tmp);

                   end if;

                   if ((web_tmp(2) = '1' and wea_tmp(2) = '1') or (seq = "01" and wea_tmp(2) = '1' and web_tmp(2) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(2) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(2) /= '1')) then

                     dobdo_ltmp(23 downto 16) := mem(prcd_tmp_addrb_dly_depth)(23 downto 16);
                     dopbdop_ltmp(2) := memp(prcd_tmp_addrb_dly_depth)(2);
                     prcd_x_buf (wr_mode_b_tmp, 23, 16, 2, dobdo_ltmp, dobdo_tmp, dopbdop_ltmp, dopbdop_tmp);

                   end if;
  
                   if ((web_tmp(3) = '1' and wea_tmp(3) = '1') or (seq = "01" and wea_tmp(3) = '1' and web_tmp(3) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(3) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(3) /= '1')) then

                     dobdo_ltmp(31 downto 24) := mem(prcd_tmp_addrb_dly_depth)(31 downto 24);
                     dopbdop_ltmp(3) := memp(prcd_tmp_addrb_dly_depth)(3);
                     prcd_x_buf (wr_mode_b_tmp, 31, 24, 3, dobdo_ltmp, dobdo_tmp, dopbdop_ltmp, dopbdop_tmp);

                   end if;
  
                end if;
  
      when others => null;

    end case;

  end prcd_col_rd_ram_b;


  procedure prcd_wr_ram_a (
    constant wea_tmp : in std_logic_vector (7 downto 0);
    constant dia_tmp : in std_logic_vector (63 downto 0);
    constant dipa_tmp : in std_logic_vector (7 downto 0);
    constant addra_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type
    ) is
    variable prcd_tmp_addra_dly_depth : integer;
    variable prcd_tmp_addra_dly_width : integer;
    variable junk : std_ulogic;

  begin
    
    case a_width is

      when 1 | 2 | 4 =>
                          if (a_width >= width) then
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto addra_lbit_124));
                            prcd_write_ram (wea_tmp(0), dia_tmp(a_width-1 downto 0), '0', mem(prcd_tmp_addra_dly_depth), junk);
                          else
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto addra_bit_124 + 1));
                            prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(addra_bit_124 downto addra_lbit_124));
                            prcd_write_ram (wea_tmp(0), dia_tmp(a_width-1 downto 0), '0', mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * a_width) + a_width - 1 downto (prcd_tmp_addra_dly_width * a_width)), junk);
                          end if;

      when 8 =>
                  if (a_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 3));
                    prcd_write_ram (wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth), memp(prcd_tmp_addra_dly_depth)(0));
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto addra_bit_8 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(addra_bit_8 downto 3));
                    prcd_write_ram (wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 8) + 7 downto (prcd_tmp_addra_dly_width * 8)), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width)));
                  end if;
  
      when 16 =>
                  if (a_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                    prcd_write_ram (wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)(7 downto 0), memp(prcd_tmp_addra_dly_depth)(0));
                    prcd_write_ram (wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)(15 downto 8), memp(prcd_tmp_addra_dly_depth)(1));
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto addra_bit_16 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(addra_bit_16 downto 4));
                    prcd_write_ram (wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 16) + 7 downto (prcd_tmp_addra_dly_width * 16)), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2)));
                    prcd_write_ram (wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 16) + 15 downto (prcd_tmp_addra_dly_width * 16) + 8), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2) + 1));
                  end if;

      when 32 =>
                   prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 5));

                   prcd_write_ram (wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)(7 downto 0), memp(prcd_tmp_addra_dly_depth)(0));
                   prcd_write_ram (wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)(15 downto 8), memp(prcd_tmp_addra_dly_depth)(1));
                   prcd_write_ram (wea_tmp(2), dia_tmp(23 downto 16), dipa_tmp(2), mem(prcd_tmp_addra_dly_depth)(23 downto 16), memp(prcd_tmp_addra_dly_depth)(2));
                   prcd_write_ram (wea_tmp(3), dia_tmp(31 downto 24), dipa_tmp(3), mem(prcd_tmp_addra_dly_depth)(31 downto 24), memp(prcd_tmp_addra_dly_depth)(3));

      when others => null;

    end case;

  end prcd_wr_ram_a;


  procedure prcd_wr_ram_b (
    constant web_tmp : in std_logic_vector (7 downto 0);
    constant dib_tmp : in std_logic_vector (63 downto 0);
    constant dipb_tmp : in std_logic_vector (7 downto 0);
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type     
    ) is
    variable prcd_tmp_addrb_dly_depth : integer;
    variable prcd_tmp_addrb_dly_width : integer;
    variable junk : std_ulogic;

  begin
    
    case b_width is

      when 1 | 2 | 4 =>
                          if (b_width >= width) then
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto addrb_lbit_124));
                            prcd_write_ram (web_tmp(0), dib_tmp(b_width-1 downto 0), '0', mem(prcd_tmp_addrb_dly_depth), junk);
                          else
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto addrb_bit_124 + 1));
                            prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(addrb_bit_124 downto addrb_lbit_124));
                            prcd_write_ram (web_tmp(0), dib_tmp(b_width-1 downto 0), '0', mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * b_width) + b_width - 1 downto (prcd_tmp_addrb_dly_width * b_width)), junk);
                          end if;

      when 8 => 
                  if (b_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 3));
                    prcd_write_ram (web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth), memp(prcd_tmp_addrb_dly_depth)(0));
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto addrb_bit_8 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(addrb_bit_8 downto 3));
                    prcd_write_ram (web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 8) + 7 downto (prcd_tmp_addrb_dly_width * 8)), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width)));
                  end if;
  
      when 16 =>
                  if (b_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                    prcd_write_ram (web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)(7 downto 0), memp(prcd_tmp_addrb_dly_depth)(0));
                    prcd_write_ram (web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)(15 downto 8), memp(prcd_tmp_addrb_dly_depth)(1));
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto addrb_bit_16 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(addrb_bit_16 downto 4));
                    prcd_write_ram (web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 16) + 7 downto (prcd_tmp_addrb_dly_width * 16)), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2)));
                    prcd_write_ram (web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 16) + 15 downto (prcd_tmp_addrb_dly_width * 16) + 8), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2) + 1));
                  end if;

      when 32 =>
                   prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                   prcd_write_ram (web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)(7 downto 0), memp(prcd_tmp_addrb_dly_depth)(0));
                   prcd_write_ram (web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)(15 downto 8), memp(prcd_tmp_addrb_dly_depth)(1));
                   prcd_write_ram (web_tmp(2), dib_tmp(23 downto 16), dipb_tmp(2), mem(prcd_tmp_addrb_dly_depth)(23 downto 16), memp(prcd_tmp_addrb_dly_depth)(2));
                   prcd_write_ram (web_tmp(3), dib_tmp(31 downto 24), dipb_tmp(3), mem(prcd_tmp_addrb_dly_depth)(31 downto 24), memp(prcd_tmp_addrb_dly_depth)(3));

      when others => null;

    end case;

  end prcd_wr_ram_b;


  procedure prcd_warn_msg (
    constant addr_str : in string;
    constant clk_str : in string
    ) is

    variable message : LINE;
    constant MsgSeverity : severity_level := Warning;

  begin
        Write ( message, STRING'(" Setup/Hold Violation on "));
        Write ( message, STRING'(addr_str));
        Write ( message, STRING'(" with respect to "));
        Write ( message, STRING'(clk_str));
        Write ( message, STRING'(" when memory has been enabled. The memory contents at "));
        Write ( message, STRING'(addr_str));
        Write ( message, STRING'(" of the RAM can be corrupted. "));
        Write ( message, STRING'("This corruption is not modeled in this simulation model. Please take the necessary steps to recover from this data corruption in hardware."));
        ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
        DEALLOCATE (message);

  end prcd_warn_msg;

  
  
  begin

    clka_dly <= CLKA;
    clkb_dly <= CLKB;
    ena_dly <= ENA;
    enb_dly <= ENB;
    ssra_dly <= SSRA;
    ssrb_dly <= SSRB;
    
    gsr_dly <= GSR;
    dia_dly <= X"00000000" & DIA;
    dib_dly <= X"00000000" & DIB;
    dipa_dly <= "0000" & DIPA;
    dipb_dly <= "0000" & DIPB;
    wea_dly <= "0000" & WEA;
    web_dly <= "0000" & WEB;
    addra_dly <= "00" & ADDRA;
    addrb_dly <= "00" & ADDRB;

    
  --------------------
  --  BEHAVIOR SECTION
  --------------------

    prcs_clk: process (clka_dly, clkb_dly, gsr_dly, ssra_dly, ssrb_dly, ena_dly, enb_dly)

      variable mem_slv : std_logic_vector(16383 downto 0) := To_StdLogicVector(INIT_3F) &
                                                       To_StdLogicVector(INIT_3E) &
                                                       To_StdLogicVector(INIT_3D) &
                                                       To_StdLogicVector(INIT_3C) &
                                                       To_StdLogicVector(INIT_3B) &
                                                       To_StdLogicVector(INIT_3A) &
                                                       To_StdLogicVector(INIT_39) &
                                                       To_StdLogicVector(INIT_38) &
                                                       To_StdLogicVector(INIT_37) &
                                                       To_StdLogicVector(INIT_36) &
                                                       To_StdLogicVector(INIT_35) &
                                                       To_StdLogicVector(INIT_34) &
                                                       To_StdLogicVector(INIT_33) &
                                                       To_StdLogicVector(INIT_32) &
                                                       To_StdLogicVector(INIT_31) &
                                                       To_StdLogicVector(INIT_30) &
                                                       To_StdLogicVector(INIT_2F) &
                                                       To_StdLogicVector(INIT_2E) &
                                                       To_StdLogicVector(INIT_2D) &
                                                       To_StdLogicVector(INIT_2C) &
                                                       To_StdLogicVector(INIT_2B) &
                                                       To_StdLogicVector(INIT_2A) &
                                                       To_StdLogicVector(INIT_29) &
                                                       To_StdLogicVector(INIT_28) &
                                                       To_StdLogicVector(INIT_27) &
                                                       To_StdLogicVector(INIT_26) &
                                                       To_StdLogicVector(INIT_25) &
                                                       To_StdLogicVector(INIT_24) &
                                                       To_StdLogicVector(INIT_23) &
                                                       To_StdLogicVector(INIT_22) &
                                                       To_StdLogicVector(INIT_21) &
                                                       To_StdLogicVector(INIT_20) &
                                                       To_StdLogicVector(INIT_1F) &
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

    variable memp_slv : std_logic_vector(2047 downto 0) := To_StdLogicVector(INITP_07) &
                                                       To_StdLogicVector(INITP_06) &
                                                       To_StdLogicVector(INITP_05) &
                                                       To_StdLogicVector(INITP_04) &
                                                       To_StdLogicVector(INITP_03) &
                                                       To_StdLogicVector(INITP_02) &
                                                       To_StdLogicVector(INITP_01) &
                                                       To_StdLogicVector(INITP_00);

    variable tmp_mem : Two_D_array_type_tmp_mem := two_D_mem_initf(widest_width);
    variable mem : Two_D_array_type := two_D_mem_init(mem_depth, width, mem_slv, tmp_mem);
    variable memp : Two_D_parity_array_type := two_D_mem_initp(memp_depth, widthp, memp_slv, tmp_mem, width);
    variable tmp_addra_dly_depth : integer;
    variable tmp_addra_dly_width : integer;
    variable tmp_addrb_dly_depth : integer;
    variable tmp_addrb_dly_width : integer;
    variable junk1 : std_logic;
    variable wr_mode_a : std_logic_vector(1 downto 0) := "00";
    variable wr_mode_b : std_logic_vector(1 downto 0) := "00";
    variable tmp_syndrome_int : integer;    
    variable doado_buf : std_logic_vector(63 downto 0) := (others => '0');
    variable dobdo_buf : std_logic_vector(63 downto 0) := (others => '0');
    variable dopadop_buf : std_logic_vector(7 downto 0) := (others => '0');
    variable dopbdop_buf : std_logic_vector(7 downto 0) := (others => '0');    
    variable syndrome : std_logic_vector(7 downto 0) := (others => '0');
    variable addra_dly_15_reg_var : std_logic := '0';
    variable addrb_dly_15_reg_var : std_logic := '0';
    variable addra_dly_15_reg_bram_var : std_logic := '0';
    variable addrb_dly_15_reg_bram_var : std_logic := '0';
    variable FIRST_TIME : boolean := true;

    variable curr_time : time := 0 ps;
    variable prev_time : time := 0 ps;
    variable viol_time : integer := 0;
    variable viol_type : std_logic_vector(1 downto 0) := (others => '0');
    variable message : line;

    variable dia_reg_dly : std_logic_vector(63 downto 0) := (others => '0');
    variable dipa_reg_dly : std_logic_vector(7 downto 0) := (others => '0');
    variable wea_reg_dly : std_logic_vector(7 downto 0) := (others => '0');
    variable addra_reg_dly : std_logic_vector(15 downto 0) := (others => '0');
    variable dib_reg_dly : std_logic_vector(63 downto 0) := (others => '0');
    variable dipb_reg_dly : std_logic_vector(7 downto 0) := (others => '0');
    variable web_reg_dly : std_logic_vector(7 downto 0) := (others => '0');
    variable addrb_reg_dly : std_logic_vector(15 downto 0) := (others => '0');
    variable col_wr_wr_msg : std_ulogic := '1';
    variable col_wra_rdb_msg : std_ulogic := '1';
    variable col_wrb_rda_msg : std_ulogic := '1';
    variable addr_col : std_logic := '0';
    
  begin  -- process prcs_clka    

    if (FIRST_TIME) then

      case DATA_WIDTH_A is
        when 0 | 1 | 2 | 4 | 9 | 18 | 36 => null;

        when others => GenericValueCheckMessage
                         (  HeaderMsg            => " Attribute Syntax Error : ",
                            GenericName          => " DATA_WIDTH_A ",
                            EntityName           => "RAMB16BWE",
                            GenericValue         => DATA_WIDTH_A,
                            Unit                 => "",
                            ExpectedValueMsg     => " The Legal values for this attribute are ",
                            ExpectedGenericValue => " 0, 1, 2, 4, 9, 18 or 36.",
                            TailMsg              => "",
                            MsgSeverity          => failure
                            );
      end case;


      case DATA_WIDTH_B is
        when 0 | 1 | 2 | 4 | 9 | 18 | 36 => null;

        when others => GenericValueCheckMessage
                         (  HeaderMsg            => " Attribute Syntax Error : ",
                            GenericName          => " DATA_WIDTH_B ",
                            EntityName           => "RAMB16BWE",
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
        report "Attribute Syntax Error : Attributes DATA_WIDTH_A and DATA_WIDTH_B on RAMB16BWE instance, both can not be 0."
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
            EntityName           => "RAMB16BWE",
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
            EntityName           => "RAMB16BWE",
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
           EntityName => "RAMB16BWE",
           GenericValue => SIM_COLLISION_CHECK,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are ALL, NONE, WARNING_ONLY or GENERATE_X_ONLY",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
      end if;

      
    end if;
    -- end of FIRST_TIME
    

    if (rising_edge(clka_dly)) then

      if (ena_dly = '1') then      
        prev_time := curr_time;
        curr_time := now;
        addra_reg_dly := addra_dly;
        wea_reg_dly := wea_dly;
        dia_reg_dly := dia_dly;
        dipa_reg_dly := dipa_dly;
      end if;
      
    end if;
    
    if (rising_edge(clkb_dly)) then

      if (enb_dly = '1') then
        prev_time := curr_time;
        curr_time := now;
        addrb_reg_dly := addrb_dly;
        web_reg_dly := web_dly;
        dib_reg_dly := dib_dly;
        dipb_reg_dly := dipb_dly;
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

     if (rising_edge(clka_dly) or rising_edge(clkb_dly)) then

-------------------------------------------------------------------------------
-- Collision starts
-------------------------------------------------------------------------------

       if (SIM_COLLISION_CHECK /= "NONE") then

        
        if (curr_time - prev_time = 0 ps) then
          viol_time := 1;
        elsif (curr_time - prev_time <= SETUP_READ_FIRST) then
          viol_time := 2;
        end if;

        
        if (ena_dly = '0' or enb_dly = '0') then
          viol_time := 0;
        end if;

        
        if ((DATA_WIDTH_A <= 9 and wea_dly(0) = '0') or (DATA_WIDTH_A = 18 and wea_dly(1 downto 0) = "00") or (DATA_WIDTH_A = 36 and wea_dly(3 downto 0) = "0000")) then
          if ((DATA_WIDTH_B <= 9 and web_dly(0) = '0') or (DATA_WIDTH_B = 18 and web_dly(1 downto 0) = "00") or (DATA_WIDTH_B = 36 and web_dly(3 downto 0) = "0000")) then
            viol_time := 0;
          end if;
        end if;

        
        if (viol_time /= 0) then
          
          if (rising_edge(clka_dly) and rising_edge(clkb_dly)) then
            if (addra_dly(13 downto col_addr_lsb) = addrb_dly(13 downto col_addr_lsb)) then
              
              viol_type := "01";

              prcd_rd_ram_a (addra_dly, doado_buf, dopadop_buf, mem, memp);
              prcd_rd_ram_b (addrb_dly, dobdo_buf, dopbdop_buf, mem, memp);
              
              prcd_col_wr_ram_a ("00", web_dly, wea_dly, di_x, di_x(7 downto 0), addrb_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
              prcd_col_wr_ram_b ("00", wea_dly, web_dly, di_x, di_x(7 downto 0), addra_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

              prcd_col_rd_ram_a (viol_type, "01", web_dly, wea_dly, addra_dly, doado_buf, dopadop_buf, mem, memp, wr_mode_a);
              prcd_col_rd_ram_b (viol_type, "01", wea_dly, web_dly, addrb_dly, dobdo_buf, dopbdop_buf, mem, memp, wr_mode_b);

              prcd_col_wr_ram_a ("10", web_dly, wea_dly, dia_dly, dipa_dly, addrb_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

              prcd_col_wr_ram_b ("10", wea_dly, web_dly, dib_dly, dipb_dly, addra_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

              
              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", web_dly, wea_dly, addra_dly, doado_buf, dopadop_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", wea_dly, web_dly, addrb_dly, dobdo_buf, dopbdop_buf, mem, memp, wr_mode_b);
              end if;

            else
              viol_time := 0;
              
            end if;

          elsif (rising_edge(clka_dly) and  (not(rising_edge(clkb_dly)))) then
            if (addra_dly(13 downto col_addr_lsb) = addrb_reg_dly(13 downto col_addr_lsb)) then
              
              viol_type := "10";

              prcd_rd_ram_a (addra_dly, doado_buf, dopadop_buf, mem, memp);

              prcd_col_wr_ram_a ("00", web_reg_dly, wea_dly, di_x, di_x(7 downto 0), addrb_reg_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
              prcd_col_wr_ram_b ("00", wea_dly, web_reg_dly, di_x, di_x(7 downto 0), addra_dly, addrb_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

              prcd_col_rd_ram_a (viol_type, "01", web_reg_dly, wea_dly, addra_dly, doado_buf, dopadop_buf, mem, memp, wr_mode_a);
              prcd_col_rd_ram_b (viol_type, "01", wea_dly, web_reg_dly, addrb_reg_dly, dobdo_buf, dopbdop_buf, mem, memp, wr_mode_b);

              prcd_col_wr_ram_a ("10", web_reg_dly, wea_dly, dia_dly, dipa_dly, addrb_reg_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

              prcd_col_wr_ram_b ("10", wea_dly, web_reg_dly, dib_reg_dly, dipb_reg_dly, addra_dly, addrb_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

			    
              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", web_reg_dly, wea_dly, addra_dly, doado_buf, dopadop_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", wea_dly, web_reg_dly, addrb_reg_dly, dobdo_buf, dopbdop_buf, mem, memp, wr_mode_b);
              end if;

            else
              viol_time := 0;
              
            end if;

          elsif ((not(rising_edge(clka_dly))) and rising_edge(clkb_dly)) then
            if (addra_reg_dly(13 downto col_addr_lsb) = addrb_dly(13 downto col_addr_lsb)) then
                              
              viol_type := "11";

              prcd_rd_ram_b (addrb_dly, dobdo_buf, dopbdop_buf, mem, memp);

              prcd_col_wr_ram_a ("00", web_dly, wea_reg_dly, di_x, di_x(7 downto 0), addrb_dly, addra_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
              prcd_col_wr_ram_b ("00", wea_reg_dly, web_dly, di_x, di_x(7 downto 0), addra_reg_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

              prcd_col_rd_ram_a (viol_type, "01", web_dly, wea_reg_dly, addra_reg_dly, doado_buf, dopadop_buf, mem, memp, wr_mode_a);
              prcd_col_rd_ram_b (viol_type, "01", wea_reg_dly, web_dly, addrb_dly, dobdo_buf, dopbdop_buf, mem, memp, wr_mode_b);

              prcd_col_wr_ram_a ("10", web_dly, wea_reg_dly, dia_reg_dly, dipa_reg_dly, addrb_dly, addra_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

              prcd_col_wr_ram_b ("10", wea_reg_dly, web_dly, dib_dly, dipb_dly, addra_reg_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

			    
              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", web_dly, wea_reg_dly, addra_reg_dly, doado_buf, dopadop_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", wea_reg_dly, web_dly, addrb_dly, dobdo_buf, dopbdop_buf, mem, memp, wr_mode_b);
              end if;

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
    if (rising_edge(clka_dly)) then
      
      if (gsr_dly = '0' and ena_dly = '1') then

        if (ssra_dly = '1') then

          doado_buf(a_width-1 downto 0) := SRVAL_A_STD(a_width-1 downto 0);
          doado_out(a_width-1 downto 0) <= SRVAL_A_STD(a_width-1 downto 0);          

          if (a_width >= 8) then
            dopadop_buf(a_widthp-1 downto 0) := SRVAL_A_STD((a_width+a_widthp)-1 downto a_width);
            dopadop_out(a_widthp-1 downto 0) <= SRVAL_A_STD((a_width+a_widthp)-1 downto a_width);            
          end if;

        end if;

        
        if (viol_time = 0) then
          -- read for rf
          if (wr_mode_a = "01" and ssra_dly = '0') then
            prcd_rd_ram_a (addra_dly, doado_buf, dopadop_buf, mem, memp);
          end if;

          if (ena_dly = '1') then
            prcd_wr_ram_a (wea_dly, dia_dly, dipa_dly, addra_dly, mem, memp);    
          end if;
          
          if (wr_mode_a /= "01" and ssra_dly = '0') then
            prcd_rd_ram_a (addra_dly, doado_buf, dopadop_buf, mem, memp);
          end if;

        
        end if;
      end if;
    end if;
    
-------------------------------------------------------------------------------
-- Port B
-------------------------------------------------------------------------------

    if (rising_edge(clkb_dly)) then

      if (gsr_dly = '0' and enb_dly = '1') then

        if (ssrb_dly = '1') then

          dobdo_buf(b_width-1 downto 0) := SRVAL_B_STD(b_width-1 downto 0);
          dobdo_out(b_width-1 downto 0) <= SRVAL_B_STD(b_width-1 downto 0);          

          if (b_width >= 8) then
            dopbdop_buf(b_widthp-1 downto 0) := SRVAL_B_STD((b_width+b_widthp)-1 downto b_width);
            dopbdop_out(b_widthp-1 downto 0) <= SRVAL_B_STD((b_width+b_widthp)-1 downto b_width);            
          end if;

        end if;


        if (viol_time = 0) then
          
          if (wr_mode_b = "01" and ssrb_dly = '0') then
            prcd_rd_ram_b (addrb_dly, dobdo_buf, dopbdop_buf, mem, memp);            
          end if;

          if (enb_dly = '1') then
            prcd_wr_ram_b (web_dly, dib_dly, dipb_dly, addrb_dly, mem, memp);
          end if;
          
          if (wr_mode_b /= "01" and ssrb_dly = '0') then
            prcd_rd_ram_b (addrb_dly, dobdo_buf, dopbdop_buf, mem, memp);
          end if;
          
        end if;
      end if;
    end if;
    

    if (ena_dly = '1' and (rising_edge(clka_dly) or viol_time /= 0)) then
      if (ssra_dly = '0' and (wr_mode_a /= "10" or (DATA_WIDTH_A <= 9 and wea_dly(0) = '0') or (DATA_WIDTH_A = 18 and wea_dly(1 downto 0) = "00") or (DATA_WIDTH_A = 36 and wea_dly(3 downto 0) = "0000"))) then

        doado_out <= doado_buf;
        dopadop_out <= dopadop_buf;

      end if;
    end if;

    
    if (enb_dly = '1' and (rising_edge(clkb_dly) or viol_time /= 0)) then

      if (ssrb_dly = '0' and (wr_mode_b /= "10" or (DATA_WIDTH_B <= 9 and web_dly(0) = '0') or (DATA_WIDTH_B = 18 and web_dly(1 downto 0) = "00") or (DATA_WIDTH_B = 36 and web_dly(3 downto 0) = "0000"))) then

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


-------------------------------------------------------------------------------
   prcs_output:process (doado_out, dopadop_out, dobdo_out, dopbdop_out)
   begin
       
     DOA    <= doado_out(31 downto 0) after SYNC_PATH_DELAY;
     DOPA   <= dopadop_out(3 downto 0) after SYNC_PATH_DELAY;
     DOB    <= dobdo_out(31 downto 0) after SYNC_PATH_DELAY;
     DOPB   <= dopbdop_out(3 downto 0) after SYNC_PATH_DELAY;

   end process prcs_output;

end RAMB16BWE_V;
