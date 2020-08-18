-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/RAM64X2S.vhd,v 1.1 2008/06/19 16:59:25 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Static Synchronous RAM 64-Deep by 2-Wide
-- /___/   /\     Filename : RAM64X2S.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:49 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL RAM64X2S -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity RAM64X2S is
  generic (
       INIT_00 : bit_vector(63 downto 0) := X"0000000000000000";
       INIT_01 : bit_vector(63 downto 0) := X"0000000000000000"
  );

  port (
        O0   : out std_ulogic;
        O1   : out std_ulogic;
        
        A0   : in std_ulogic;
        A1   : in std_ulogic;
        A2   : in std_ulogic;
        A3   : in std_ulogic;
        A4   : in std_ulogic;
        A5   : in std_ulogic;        
        D0   : in std_ulogic;
	D1   : in std_ulogic;
        WCLK : in std_ulogic;        
        WE   : in std_ulogic
       );
end RAM64X2S;

architecture RAM64X2S_V of RAM64X2S is
  signal MEM0       : std_logic_vector( 64 downto 0 ) := ('X' & To_StdLogicVector(INIT_00) );
  signal MEM1       : std_logic_vector( 64 downto 0 ) := ('X' & To_StdLogicVector(INIT_01) );

begin
  VITALReadBehavior : process(A0, A1, A2, A3, A4, A5, MEM0, MEM1)
    variable Index   : integer := 32;
    variable Address : std_logic_vector (5 downto 0);    
  begin
        Address := (A5, A4, A3, A2 , A1 , A0);
        Index      := SLV_TO_INT(SLV => Address);
        O0 <= MEM0(Index);      
        O1 <= MEM1(Index);      
  end process VITALReadBehavior;

  VITALWriteBehavior : process(WCLK)
    variable Index   : integer := 32;
    variable Address : std_logic_vector (5 downto 0);    
  begin
    if (rising_edge(WCLK)) then
      if (WE = '1') then
        Address := (A5, A4, A3, A2, A1, A0);
        Index   := SLV_TO_INT(SLV => Address);
        MEM0(Index) <= D0 after 100 ps;
        MEM1(Index) <= D1 after 100 ps;
      end if;
    end if;    
end process VITALWriteBehavior;
end RAM64X2S_V;


