-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/ROM16X1.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  16-Deep by 1-Wide ROM
-- /___/   /\     Filename : ROM16X1.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:57 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL ROM16X1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity ROM16X1 is
  generic (
       INIT : bit_vector := X"0000"
  );

  port (
        O : out std_ulogic;
        
        A0 : in std_ulogic;
        A1 : in std_ulogic;
        A2 : in std_ulogic;
        A3 : in std_ulogic
       );
end ROM16X1;

architecture ROM16X1_V of ROM16X1 is
begin
  VITALBehavior : process (A3, A2, A1, A0)
    variable INIT_BITS  : std_logic_vector(15 downto 0) := To_StdLogicVector(INIT);
    variable MEM : std_logic_vector( 16 downto 0 ) ;
    variable Index : integer := 16;
    variable FIRST_TIME : boolean := TRUE;    
  begin
     if (FIRST_TIME = TRUE) then
       MEM := ('X' & INIT_BITS(15 downto 0));
      FIRST_TIME := FALSE;
    end if;
    Index := DECODE_ADDR4(ADDRESS => (A3, A2, A1, A0));
    O <= MEM(Index); 
  end process VITALBehavior;
end ROM16X1_V;


