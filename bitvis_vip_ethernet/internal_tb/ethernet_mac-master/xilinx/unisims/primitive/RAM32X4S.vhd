-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/RAM32X4S.vhd,v 1.1 2008/06/19 16:59:25 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Static Synchronous RAM 32-Deep by 4-Wide
-- /___/   /\     Filename : RAM32X4S.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:49 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL RAM32X4S -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity RAM32X4S is

  generic (
    INIT_00 : bit_vector(31 downto 0) := X"00000000";
    INIT_01 : bit_vector(31 downto 0) := X"00000000";
    INIT_02 : bit_vector(31 downto 0) := X"00000000";
    INIT_03 : bit_vector(31 downto 0) := X"00000000"
    );

  port (
    O0 : out std_ulogic;
    O1 : out std_ulogic;
    O2 : out std_ulogic;
    O3 : out std_ulogic;

    A0   : in std_ulogic;
    A1   : in std_ulogic;
    A2   : in std_ulogic;
    A3   : in std_ulogic;
    A4   : in std_ulogic;
    D0   : in std_ulogic;
    D1   : in std_ulogic;
    D2   : in std_ulogic;
    D3   : in std_ulogic;
    WCLK : in std_ulogic;
    WE   : in std_ulogic
    );
end RAM32X4S;

architecture RAM32X4S_V of RAM32X4S is
  signal MEM0 : std_logic_vector( 32 downto 0 ) := ('X' & To_StdLogicVector(INIT_00) );
  signal MEM1 : std_logic_vector( 32 downto 0 ) := ('X' & To_StdLogicVector(INIT_01) );
  signal MEM2 : std_logic_vector( 32 downto 0 ) := ('X' & To_StdLogicVector(INIT_02) );
  signal MEM3 : std_logic_vector( 32 downto 0 ) := ('X' & To_StdLogicVector(INIT_03) );

begin
  VITALReadBehavior  : process(A0, A1, A2, A3, A4, MEM0, MEM1, MEM2, MEM3)
    variable Index   : integer := 32;
    variable Address : std_logic_vector (4 downto 0);

  begin
    Address := (A4, A3, A2, A1, A0);
    Index   := SLV_TO_INT(SLV => Address);
    O0 <= MEM0(Index);      
    O1 <= MEM1(Index);      
    O2 <= MEM2(Index);      
    O3 <= MEM3(Index);      
  end process VITALReadBehavior;

  VITALWriteBehavior : process(WCLK)
    variable Index   : integer := 32;
    variable Address : std_logic_vector (4 downto 0);

  begin
    if (rising_edge(WCLK)) then
      if (WE = '1') then
        Address := (A4, A3, A2, A1, A0);
        Index   := SLV_TO_INT(SLV => Address);
        MEM0(Index) <= D0 after 100 ps;
        MEM1(Index) <= D1 after 100 ps;
        MEM2(Index) <= D2 after 100 ps;
        MEM3(Index) <= D3 after 100 ps;
      end if;
    end if;
  end process VITALWriteBehavior;
end RAM32X4S_V;


