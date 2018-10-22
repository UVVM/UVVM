-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/RAM32X1S.vhd,v 1.1 2008/06/19 16:59:25 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Static Synchronous RAM 32-Deep by 1-Wide
-- /___/   /\     Filename : RAM32X1S.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:48 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL RAM32X1S -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity RAM32X1S is
  generic (
    INIT : bit_vector(31 downto 0) := X"00000000"
    );

  port (
    O : out std_ulogic;

    A0   : in std_ulogic;
    A1   : in std_ulogic;
    A2   : in std_ulogic;
    A3   : in std_ulogic;
    A4   : in std_ulogic;
    D    : in std_ulogic;
    WCLK : in std_ulogic;
    WE   : in std_ulogic
    );
end RAM32X1S;

architecture RAM32X1S_V of RAM32X1S is
  signal MEM : std_logic_vector(32 downto 0) := ('X' & To_StdLogicVector(INIT));

begin
  VITALReadBehavior  : process(A0, A1, A2, A3, A4, MEM)
    variable Index   : integer := 32;
    variable Address : std_logic_vector (4 downto 0);

  begin
    Address := (A4, A3, A2, A1, A0);
    Index   := SLV_TO_INT(SLV => Address);
    O <= MEM(Index);      
  end process VITALReadBehavior;

  VITALWriteBehavior : process(WCLK)
    variable Index   : integer := 32;
    variable Address : std_logic_vector (4 downto 0);

  begin
    if (rising_edge(WCLK)) then
      if (WE = '1') then
        Address := (A4, A3, A2, A1, A0);
        Index   := SLV_TO_INT(SLV => Address);
        MEM(Index) <= D after 100 ps;
      end if;
    end if;
  end process VITALWriteBehavior;
end RAM32X1S_V;


