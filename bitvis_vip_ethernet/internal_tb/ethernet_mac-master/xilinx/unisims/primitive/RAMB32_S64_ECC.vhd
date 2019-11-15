-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/virtex4/VITAL/RAMB32_S64_ECC.vhd,v 1.1 2008/06/19 16:59:27 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                    Ramb32_s64_ecc 
-- /___/   /\     Filename : ramb32_s64_ecc.vhd
-- \   \  /  \    Timestamp : Tue Mar  1 14:57:54 PST 2005
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    03/04/05 - Add generic DO_REG and SIM_COLLISION_CHECK to pass to RAMB16.
--                    Add register to output for the latency. (CR 204569)
--    03/16/05 - Change parameter WRITE_MODE_A and WRITE_MODE_B to READ_FIRST.
-- End Revision

----- CELL RAMB32_S64_ECC -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.vpkg.all;
use unisim.VCOMPONENTS.all;

entity RAMB32_S64_ECC is

generic(
               DO_REG : integer := 0 ; 
               SIM_COLLISION_CHECK : string := "ALL" 
       );

port (
		DO : out std_logic_vector(63 downto 0);
		STATUS : out std_logic_vector(1 downto 0);

		DI : in std_logic_vector(63 downto 0);
		RDADDR : in std_logic_vector(8 downto 0);
		RDCLK : in std_ulogic;
		RDEN : in std_ulogic;
		SSR : in std_ulogic;
		WRADDR : in std_logic_vector(8 downto 0);
		WRCLK : in std_ulogic;
		WREN : in std_ulogic
     );
end RAMB32_S64_ECC;

-- Architecture body --

architecture RAMB32_S64_ECC_V of RAMB32_S64_ECC is


-- Input/Output Pin signals

        signal   do_ram16low  :  std_logic_vector(31 downto 0);
        signal   do_ram16up   :  std_logic_vector(31 downto 0);
        signal   dopa_ram16low  :  std_logic_vector(3 downto 0);
        signal   dopa_ram16up  :  std_logic_vector(3 downto 0);
        signal   STATUS_out  :  std_logic_vector(1 downto 0);
        signal   tmp41      :  std_logic_vector(3 downto 0) :="1111";
        signal   tmp640      :  std_logic_vector(63 downto 0) := (others=>'0');
        signal   tmp40      :  std_logic_vector(3 downto 0) :="0000";
        signal   tmp0       :  std_logic :='0';
        signal   tmp1       :  std_logic :='1';
        signal   ADDRA_tmp  :  std_logic_vector(14 downto 0) := "1XXXXXXXXX00000";
        signal   ADDRB_tmp  :  std_logic_vector(14 downto 0) := "1XXXXXXXXX00000";
        signal   DIB_up     :  std_logic_vector(31 downto 0);
        signal   DIB_low    :  std_logic_vector(31 downto 0);
        signal   DIPB_up     :  std_logic_vector(3 downto 0);
        signal   DIPB_low    :  std_logic_vector(3 downto 0);
        signal   DIA_tmp    :  std_logic_vector(31 downto 0) := (others=>'0');
        signal   DO_tmp    :  std_logic_vector(63 downto 0) := (others=>'0');


begin
 
  DO(63 downto 0) <= DO_tmp(63 downto 0);

  DO_OUT_P : process (RDCLK)
  begin
   if (RDCLK'event and RDCLK='1') then
     DO_tmp(13 downto 0) <= do_ram16low(13 downto 0);
     DO_tmp(14) <= dopa_ram16low(1);
     DO_tmp(15) <= dopa_ram16low(3);
     DO_tmp(29 downto 16) <= do_ram16low(29 downto 16);
     DO_tmp(30) <= dopa_ram16low(0);
     DO_tmp(31) <= dopa_ram16low(2);

     DO_tmp(32) <= dopa_ram16up(0);
     DO_tmp(33) <= dopa_ram16up(2);
     DO_tmp(47 downto 34) <= do_ram16up(15 downto 2);
     DO_tmp(48) <= dopa_ram16up(1);
     DO_tmp(49) <= dopa_ram16up(3);
     DO_tmp(63 downto 50) <= do_ram16up(31 downto 18);
   end if;
  end process DO_OUT_P;

  ADDR_IN_P : process (RDADDR, WRADDR)
  begin
    ADDRA_tmp(4 downto 0)       <=  "00000";
    ADDRA_tmp(13 downto 5)       <=  RDADDR(8 downto 0);
    ADDRA_tmp(14)              <= '1';
    ADDRB_tmp(4 downto 0)       <=  "00000";
    ADDRB_tmp(13 downto 5)       <=  WRADDR(8 downto 0);
    ADDRB_tmp(14)              <= '1';
  end process ADDR_IN_P;

  DATA_IN_P : process(DI)
  begin
     DIB_low(13 downto 0)         <=  DI(13 downto 0);
     DIB_low(15 downto 14)         <=  "00";
     DIPB_low(1)                  <=  DI(14);
     DIPB_low(3)                  <=  DI(15);
     DIB_low(29 downto 16)         <= DI(29 downto 16);
     DIB_low(31 downto 30)         <= "00";
     DIPB_low(0)                  <=  DI(30);
     DIPB_low(2)                  <=  DI(31);

     DIPB_up(0)                  <=  DI(32);
     DIPB_up(2)                  <=  DI(33);
     DIB_up(1 downto 0)          <=  "00";
     DIB_up(15 downto 2)         <=  DI(47 downto 34);
     DIPB_up(1)                  <=  DI(48);
     DIPB_up(3)                  <=  DI(49);
     DIB_up(17 downto 16)        <=  "00";
     DIB_up(31 downto 18)         <= DI(63 downto 50);
  end process DATA_IN_P;

  
  STATUS <= "00";


  RAMB16_LOWER : RAMB16
  generic map (
    READ_WIDTH_A  => 36,
    WRITE_WIDTH_A => 36,
    READ_WIDTH_B  => 36,
    WRITE_WIDTH_B => 36,
    WRITE_MODE_A  => "READ_FIRST",
    WRITE_MODE_B  => "READ_FIRST",
    INIT_A  => "000000000000000000000000000000000000",
    SRVAL_A => "000000000000000000000000000000000000",
    INIT_B  => "000000000000000000000000000000000000",
    SRVAL_B => "000000000000000000000000000000000000",
    DOA_REG => DO_REG,
    DOB_REG => 0,
    INVERT_CLK_DOA_REG => FALSE,
    INVERT_CLK_DOB_REG => FALSE,
    RAM_EXTENSION_A => "NONE",
    RAM_EXTENSION_B => "NONE",
    SIM_COLLISION_CHECK => SIM_COLLISION_CHECK
  )                                                         
  port map (
    ADDRA       => ADDRA_tmp,
    ADDRB       => ADDRB_tmp,
    DIA         => DIA_tmp,
    DIB         => DIB_low,
    DIPA        => tmp40,
    DIPB        => DIPB_low,
    ENA         => RDEN,
    ENB         => WREN,
    WEA         => tmp40,
    WEB         => tmp41,
    SSRA        => SSR,
    SSRB        => tmp0,
    CLKA        => RDCLK,
    CLKB        => WRCLK,
    REGCEA      => tmp1,
    REGCEB      => tmp0,
    CASCADEINA  => tmp0,
    CASCADEINB  => tmp0,
    DOA         => do_ram16low(31 downto 0),
    DOB         => open,
    DOPA        => dopa_ram16low(3 downto 0),
    DOPB        => open,
    CASCADEOUTA => open,
    CASCADEOUTB => open 

      );


  RAMB16_UPPER : RAMB16
  generic map (
    READ_WIDTH_A  => 36,
    WRITE_WIDTH_A => 36,
    READ_WIDTH_B  => 36,
    WRITE_WIDTH_B => 36,
    WRITE_MODE_A  => "READ_FIRST",
    WRITE_MODE_B  => "READ_FIRST",
    INIT_A  => "000000000000000000000000000000000000",
    SRVAL_A => "000000000000000000000000000000000000",
    INIT_B  => "000000000000000000000000000000000000",
    SRVAL_B => "000000000000000000000000000000000000",
    DOA_REG => DO_REG,
    DOB_REG => 0,
    INVERT_CLK_DOA_REG => FALSE,
    INVERT_CLK_DOB_REG => FALSE,
    RAM_EXTENSION_A => "NONE",
    RAM_EXTENSION_B => "NONE",
    SIM_COLLISION_CHECK => SIM_COLLISION_CHECK
  )                                                         
  port map (
    ADDRA       => ADDRA_tmp,
    ADDRB       => ADDRB_tmp,
    DIA         => DIA_tmp,
    DIB         => DIB_up,
    DIPA        => tmp40,
    DIPB        => DIPB_up,
    ENA         => RDEN,
    ENB         => WREN,
    WEA         => tmp40,
    WEB         => tmp41,
    SSRA        => SSR,
    SSRB        => tmp0,
    CLKA        => RDCLK,
    CLKB        => WRCLK,
    REGCEA      => tmp1,
    REGCEB      => tmp0,
    CASCADEINA  => tmp0,
    CASCADEINB  => tmp0,
    DOA         => do_ram16up(31 downto 0),
    DOB         => open,
    DOPA        => dopa_ram16up(3 downto 0),
    DOPB        => open,
    CASCADEOUTA => open,
    CASCADEOUTB => open 
      );

end RAMB32_S64_ECC_V;
