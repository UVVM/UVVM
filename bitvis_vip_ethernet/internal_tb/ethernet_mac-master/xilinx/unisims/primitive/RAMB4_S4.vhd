-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/RAMB4_S4.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  4K-Bit Data Single Port Block RAM
-- /___/   /\     Filename : RAMB4_S4.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:55 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL RAMB4_S4 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity RAMB4_S4 is

  generic (
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
    INIT_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000"
    );

  port (
    DO     : out STD_LOGIC_VECTOR (3 downto 0);
        
    ADDR   : in STD_LOGIC_VECTOR (9 downto 0);
    CLK    : in STD_ULOGIC;        
    DI     : in STD_LOGIC_VECTOR (3 downto 0);
    EN     : in STD_ULOGIC;
    RST    : in STD_ULOGIC;        
    WE     : in STD_ULOGIC
    );
end RAMB4_S4;

architecture RAMB4_S4_V of RAMB4_S4 is
  constant length : integer := 1024;
  constant width : integer := 4;
  type Two_D_array_type is array ((length -  1) downto 0) of std_logic_vector((width - 1) downto 0);

  function slv_to_two_D_array(
    SLV : in std_logic_vector)
    return two_D_array_type is
    variable two_D_array : two_D_array_type;
    variable intermediate : std_logic_vector((width - 1) downto 0);
  begin
    for i in two_D_array'low to two_D_array'high loop
      intermediate := SLV(((i*width) + (width - 1)) downto (i* width));
      two_D_array(i) := intermediate; 
    end loop;
    return two_D_array;
  end;  
begin

  VITALBehavior : process

    variable address : integer;
    variable valid_addr : boolean := FALSE;
    variable mem_slv : std_logic_vector(4095 downto 0) := To_StdLogicVector(INIT_0F & INIT_0E & INIT_0D & INIT_0C &
                                                                            INIT_0B & INIT_0A & INIT_09 & INIT_08 &
                                                                            INIT_07 & INIT_06 & INIT_05 & INIT_04 &
                                                                            INIT_03 & INIT_02 & INIT_01 & INIT_00);     
    variable mem : Two_D_array_type := slv_to_two_D_array(mem_slv);

  begin 
    valid_addr := addr_is_valid(addr);
    
    if (valid_addr) then
      address := slv_to_int(addr);
    end if;
    
    if (rising_edge(CLK)) then
      if (EN = '1') then
        if (RST = '1') then
          DO <= (others => '0') after 100 ps;
        else    
          if (WE = '1') then
            DO <= DI after 100 ps;
          else 
            if (valid_addr) then
              DO <= mem(address) after 100 ps;
            end if;
          end if;
        end if;
        if (WE = '1') then
          if (valid_addr) then
            mem(address) := DI;
          end if;
        end if;  
      end if;
    end if;
    wait on CLK;
  end process VITALBehavior;
end RAMB4_S4_V;


