-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/RAMB16_S36.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  16K-Bit Data and 2K-Bit Parity Single Port Block RAM
-- /___/   /\     Filename : RAMB16_S36.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:52 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    09/26/05 - Fixed CR# 216846. INIT and SRVAL attributes length check and adjustment.
-- END Revision

----- CELL RAMB16_S36 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity RAMB16_S36 is

  generic (
    INIT : bit_vector := X"000000000";
    SRVAL : bit_vector := X"000000000";
    WRITE_MODE : string := "WRITE_FIRST";
    INITP_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
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
    INIT_3F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000"
    );

  port (
    DO : out STD_LOGIC_VECTOR (31 downto 0);
    DOP : out STD_LOGIC_VECTOR (3 downto 0);
    
    ADDR : in STD_LOGIC_VECTOR (8 downto 0);
    CLK : in STD_ULOGIC;
    DI : in STD_LOGIC_VECTOR (31 downto 0);
    DIP : in STD_LOGIC_VECTOR (3 downto 0);
    EN : in STD_ULOGIC;
    SSR : in STD_ULOGIC;
    WE : in STD_ULOGIC
    );
end RAMB16_S36;

architecture RAMB16_S36_V of RAMB16_S36 is
  constant length : integer := 512;
  constant width : integer := 32;

  constant parity_width : integer := 4;
  
  type Two_D_array_type is array ((length -  1) downto 0) of std_logic_vector((width - 1) downto 0);
  type Two_D_parity_array_type is array ((length -  1) downto 0) of std_logic_vector((parity_width - 1) downto 0);    

  function slv_to_two_D_array(
    slv_length : integer;
    slv_width : integer;
    SLV : in std_logic_vector
    )
    return two_D_array_type is
    variable two_D_array : two_D_array_type;
    variable intermediate : std_logic_vector((slv_width - 1) downto 0);
  begin
    for i in 0 to (slv_length - 1)loop
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
begin
  VITALBehavior : process  
    variable address : integer;
    variable valid_addr : boolean := FALSE;
    variable mem_slv : std_logic_vector(16383 downto 0) := To_StdLogicVector(INIT_3F & INIT_3E & INIT_3D & INIT_3C &
                                                                             INIT_3B & INIT_3A & INIT_39 & INIT_38 &
                                                                             INIT_37 & INIT_36 & INIT_35 & INIT_34 &
                                                                             INIT_33 & INIT_32 & INIT_31 & INIT_30 &
                                                                             INIT_2F & INIT_2E & INIT_2D & INIT_2C &
                                                                             INIT_2B & INIT_2A & INIT_29 & INIT_28 &
                                                                             INIT_27 & INIT_26 & INIT_25 & INIT_24 &
                                                                             INIT_23 & INIT_22 & INIT_21 & INIT_20 &
                                                                             INIT_1F & INIT_1E & INIT_1D & INIT_1C &
                                                                             INIT_1B & INIT_1A & INIT_19 & INIT_18 &
                                                                             INIT_17 & INIT_16 & INIT_15 & INIT_14 &
                                                                             INIT_13 & INIT_12 & INIT_11 & INIT_10 &
                                                                             INIT_0F & INIT_0E & INIT_0D & INIT_0C &
                                                                             INIT_0B & INIT_0A & INIT_09 & INIT_08 &
                                                                             INIT_07 & INIT_06 & INIT_05 & INIT_04 &
                                                                             INIT_03 & INIT_02 & INIT_01 & INIT_00);

    variable memp_slv : std_logic_vector(2047 downto 0) := To_StdLogicVector(INITP_07 & INITP_06 & INITP_05 & INITP_04 &
                                                                              INITP_03 & INITP_02 & INITP_01 & INITP_00);    
    variable mem : Two_D_array_type := slv_to_two_D_array(length, width, mem_slv);
    variable memp : Two_D_parity_array_type := slv_to_two_D_parity_array(length, parity_width, memp_slv);    

    variable wr_mode : integer := 0;    
    variable first_time : boolean := true;

    variable INIT_reg         : std_logic_vector (35 downto 0) := "000000000000000000000000000000000000";
    variable SRVAL_reg         : std_logic_vector (35 downto 0) := "000000000000000000000000000000000000";
    
  begin
    if (first_time) then
      if ((WRITE_MODE = "write_first") or (WRITE_MODE = "WRITE_FIRST")) then
        wr_mode := 0;
      elsif ((WRITE_MODE = "read_first") or (WRITE_MODE = "READ_FIRST")) then
        wr_mode := 1;
      elsif ((WRITE_MODE = "no_change") or (WRITE_MODE = "NO_CHANGE")) then
        wr_mode := 2;
      else
        GenericValueCheckMessage
          (HeaderMsg            => " Attribute Syntax Error ",
           GenericName          => " WRITE_MODE ",
           EntityName           => "/RAMB16_S36",
           GenericValue         => WRITE_MODE,
           Unit                 => "",
           ExpectedValueMsg     => " The Legal values for this attribute are ",
           ExpectedGenericValue => " WRITE_FIRST, READ_FIRST or NO_CHANGE ",
           TailMsg              => "",
           MsgSeverity          => error
           );
      end if;
      if (INIT'length > 36) then
        INIT_reg(35 downto 0) := To_StdLogicVector(INIT)(35 downto 0);
      else
        INIT_reg(INIT'length-1 downto 0) := To_StdLogicVector(INIT);
      end if;
      
      DO <= INIT_reg(31 downto 0);
      DOP <= INIT_reg(35 downto 32);

      if (SRVAL'length > 36) then
        SRVAL_reg(35 downto 0) := To_StdLogicVector(SRVAL)(35 downto 0);
      else
        SRVAL_reg(SRVAL'length-1 downto 0) := To_StdLogicVector(SRVAL);
      end if;
      
      first_time := false;
    end if;
      
    valid_addr := addr_is_valid(addr);
    
    if (valid_addr) then
      address := slv_to_int(addr);
    end if;
    
    if (rising_edge(CLK)) then
      if (EN = '1') then
        if (SSR = '1') then
          DO <= SRVAL_reg(31 downto 0) after 100 ps;
          DOP <= SRVAL_reg(35 downto 32) after 100 ps;          
        else    
          if (WE = '1') then
            if (wr_mode = 0) then
              DO <= DI after 100 ps;
              DOP <= DIP after 100 ps;              
            elsif (wr_mode = 1) then
              DO <= mem(address) after 100 ps;
              DOP <= memp(address) after 100 ps;                
            end if;
          else 
            if (valid_addr) then
              DO <= mem(address) after 100 ps;
              DOP <= memp(address) after 100 ps;              
            end if;
          end if;
        end if;
        if (WE = '1') then
          if (valid_addr) then
            mem(address) := DI;
            memp(address) := DIP;            
          end if;
        end if;  
      end if;
    end if;
    wait on CLK;    
  end process VITALBehavior;

end RAMB16_S36_V;


