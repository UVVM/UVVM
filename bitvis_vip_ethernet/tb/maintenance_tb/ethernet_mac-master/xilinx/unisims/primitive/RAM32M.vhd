-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/rainier/VITAL/RAM32M.vhd,v 1.1 2008/06/19 16:59:22 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Function Simulation Library Component
--  /   /                  Static Synchronous RAM 32-Deep by 8-Wide
-- /___/   /\     Filename : RAM32M.vhd
-- \   \  /  \    Timestamp : 
--  \___\/\___\
--
-- Revision:
--    03/23/06 - Initial version.
--    02/12/07 - Change MEM_a in QB_P process to MEM_b (CR 434008)
-- End Revision

----- CELL RAM32M -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity RAM32M is
  generic (
      INIT_A : bit_vector(63 downto 0) := X"0000000000000000";
      INIT_B : bit_vector(63 downto 0) := X"0000000000000000";
      INIT_C : bit_vector(63 downto 0) := X"0000000000000000";
      INIT_D : bit_vector(63 downto 0) := X"0000000000000000"
    );

  port (
    DOA    : out std_logic_vector (1 downto 0);
    DOB    : out std_logic_vector (1 downto 0);
    DOC    : out std_logic_vector (1 downto 0);
    DOD    : out std_logic_vector (1 downto 0);

    ADDRA : in  std_logic_vector(4 downto 0);
    ADDRB : in  std_logic_vector(4 downto 0);
    ADDRC : in  std_logic_vector(4 downto 0);
    ADDRD : in  std_logic_vector(4 downto 0);
    DIA   : in  std_logic_vector (1 downto 0);
    DIB   : in  std_logic_vector (1 downto 0);
    DIC   : in  std_logic_vector (1 downto 0);
    DID   : in  std_logic_vector (1 downto 0);
    WCLK  : in  std_ulogic;
    WE   : in  std_ulogic
    );
end RAM32M;

architecture RAM32M_V of RAM32M is

  signal MEM_a : std_logic_vector( 65 downto 0 ) := ("XX" & To_StdLogicVector(INIT_A) );
  signal MEM_b : std_logic_vector( 65 downto 0 ) := ("XX" & To_StdLogicVector(INIT_B) );
  signal MEM_c : std_logic_vector( 65 downto 0 ) := ("XX" & To_StdLogicVector(INIT_C) );
  signal MEM_d : std_logic_vector( 65 downto 0 ) := ("XX" & To_StdLogicVector(INIT_D) );
begin

  QA_P : process ( ADDRA, MEM_a) 
    variable Index_a : integer := 32;
  begin
    Index_a := 2 * SLV_TO_INT(SLV => ADDRA);
    DOA(0) <= MEM_a(Index_a);
    DOA(1) <= MEM_a(Index_a + 1);
  end process QA_P;

  QB_P : process ( ADDRB, MEM_b) 
    variable Index_b : integer := 32;
  begin
    Index_b := 2 * SLV_TO_INT(SLV => ADDRB);
    DOB(0) <= MEM_b(Index_b);
    DOB(1) <= MEM_b(Index_b + 1);
  end process QB_P;

  QC_P : process ( ADDRC, MEM_c) 
    variable Index_c : integer := 32;
  begin
    Index_c := 2 * SLV_TO_INT(SLV => ADDRC);
    DOC(0) <= MEM_c(Index_c);
    DOC(1) <= MEM_c(Index_c + 1);
  end process QC_P;

  QD_P : process ( ADDRD, MEM_d) 
    variable Index_d : integer := 32;
  begin
    Index_d := 2 * SLV_TO_INT(SLV => ADDRD);
    DOD(0) <= MEM_d(Index_d);
    DOD(1) <= MEM_d(Index_d + 1);
  end process QD_P;

  VITALWriteBehavior : process(WCLK)
    variable Index   : integer := 32 ;
  begin
    if (rising_edge(WCLK)) then
      if (WE = '1') then
        Index                  := 2 * SLV_TO_INT(SLV => ADDRD);
        MEM_a(Index) <= DIA(0)  after 100 ps;
        MEM_a(Index+1) <= DIA(1) after 100 ps;
        MEM_b(Index) <= DIB(0)  after 100 ps;
        MEM_b(Index+1) <= DIB(1) after 100 ps;
        MEM_c(Index) <= DIC(0)  after 100 ps;
        MEM_c(Index+1) <= DIC(1) after 100 ps;
        MEM_d(Index) <= DID(0)  after 100 ps;
        MEM_d(Index+1) <= DID(1)  after 100 ps;
      end if;
    end if;
  end process VITALWriteBehavior;

end RAM32M_V;

