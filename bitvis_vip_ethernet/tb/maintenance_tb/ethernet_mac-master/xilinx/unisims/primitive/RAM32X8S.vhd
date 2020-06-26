-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/RAM32X8S.vhd,v 1.1 2008/06/19 16:59:25 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Static Synchronous RAM 32-Deep by 8-Wide
-- /___/   /\     Filename : RAM32X8S.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:49 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL RAM32X8S -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity RAM32X8S is

  generic (
    INIT_00 : bit_vector(31 downto 0) := X"00000000";
    INIT_01 : bit_vector(31 downto 0) := X"00000000";
    INIT_02 : bit_vector(31 downto 0) := X"00000000";
    INIT_03 : bit_vector(31 downto 0) := X"00000000";
    INIT_04 : bit_vector(31 downto 0) := X"00000000";
    INIT_05 : bit_vector(31 downto 0) := X"00000000";
    INIT_06 : bit_vector(31 downto 0) := X"00000000";
    INIT_07 : bit_vector(31 downto 0) := X"00000000"
    );

  port (
    O : out std_logic_vector ( 7 downto 0);

    A0   : in std_ulogic;
    A1   : in std_ulogic;
    A2   : in std_ulogic;
    A3   : in std_ulogic;
    A4   : in std_ulogic;
    D    : in std_logic_vector ( 7 downto 0);
    WCLK : in std_ulogic;
    WE   : in std_ulogic
    );
end RAM32X8S;

architecture RAM32X8S_V of RAM32X8S is
  signal MEM0 : std_logic_vector(32 downto 0) := ('X' & To_StdLogicVector(INIT_00));
  signal MEM1 : std_logic_vector(32 downto 0) := ('X' & To_StdLogicVector(INIT_01));
  signal MEM2 : std_logic_vector(32 downto 0) := ('X' & To_StdLogicVector(INIT_02));
  signal MEM3 : std_logic_vector(32 downto 0) := ('X' & To_StdLogicVector(INIT_03));
  signal MEM4 : std_logic_vector(32 downto 0) := ('X' & To_StdLogicVector(INIT_04));
  signal MEM5 : std_logic_vector(32 downto 0) := ('X' & To_StdLogicVector(INIT_05));
  signal MEM6 : std_logic_vector(32 downto 0) := ('X' & To_StdLogicVector(INIT_06));
  signal MEM7 : std_logic_vector(32 downto 0) := ('X' & To_StdLogicVector(INIT_07));

begin
  VITALReadBehavior : process(A0, A1, A2, A3, A4, MEM0, MEM1, MEM2, MEM3, MEM4, MEM5, MEM6, MEM7)

    variable Index   : integer := 32;
    variable Address : std_logic_vector (4 downto 0);

  begin
    Address := (A4, A3, A2, A1, A0);
    Index   := SLV_TO_INT(SLV => Address);

      O(0) <= MEM0(Index);      
      O(1) <= MEM1(Index);      
      O(2) <= MEM2(Index);      
      O(3) <= MEM3(Index);      
      O(4) <= MEM4(Index);      
      O(5) <= MEM5(Index);      
      O(6) <= MEM6(Index);      
      O(7) <= MEM7(Index);      
  end process VITALReadBehavior;

  VITALWriteBehavior : process(WCLK)
    variable Index   : integer := 32;
    variable Address : std_logic_vector (4 downto 0);
  begin
    if (rising_edge(WCLK)) then
      if (WE = '1') then
        Address                := (A4, A3, A2, A1, A0);
        Index                  := SLV_TO_INT(SLV => Address);
        MEM0(Index) <= D(0) after 100 ps;
        MEM1(Index) <= D(1) after 100 ps;
        MEM2(Index) <= D(2) after 100 ps;
        MEM3(Index) <= D(3) after 100 ps;
        MEM4(Index) <= D(4) after 100 ps;
        MEM5(Index) <= D(5) after 100 ps;
        MEM6(Index) <= D(6) after 100 ps;
        MEM7(Index) <= D(7) after 100 ps;
      end if;
    end if;
  end process VITALWriteBehavior;
end RAM32X8S_V;


