-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/RAM16X1D.vhd,v 1.1 2008/06/19 16:59:25 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Static Dual Port Synchronous RAM 16-Deep by 1-Wide
-- /___/   /\     Filename : RAM16X1D.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:47 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL RAM16X1D -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity RAM16X1D is

  generic (
       INIT : bit_vector(15 downto 0) := X"0000"
  );

  port (
        DPO   : out std_ulogic;        
        SPO   : out std_ulogic;
        
        A0    : in std_ulogic;
        A1    : in std_ulogic;
        A2    : in std_ulogic;
        A3    : in std_ulogic;
        D     : in std_ulogic;        
        DPRA0 : in std_ulogic;
        DPRA1 : in std_ulogic;
        DPRA2 : in std_ulogic;
        DPRA3 : in std_ulogic;        
        WCLK  : in std_ulogic;
        WE    : in std_ulogic
       );
end RAM16X1D;

architecture RAM16X1D_V of RAM16X1D is
  signal MEM       : std_logic_vector( 16 downto 0 ) := ('X' & To_StdLogicVector(INIT) );

begin
 VITALReadBehavior : process(A0, A1, A2, A3, DPRA3, DPRA2, DPRA1, DPRA0, MEM)
       Variable Index_SP   : integer  := 16 ;
       Variable Index_DP   : integer  := 16 ;

  begin 
    Index_SP := DECODE_ADDR4(ADDRESS => (A3, A2, A1, A0));
    Index_DP := DECODE_ADDR4(ADDRESS => (DPRA3, DPRA2, DPRA1, DPRA0));
    SPO <= MEM(Index_SP);
    DPO <= MEM(Index_DP);

  end process VITALReadBehavior;

 VITALWriteBehavior : process(WCLK)
    variable Index_SP  : integer := 16;
    variable Index_DP  : integer := 16;
  begin
    Index_SP := DECODE_ADDR4(ADDRESS => (A3, A2, A1, A0));
    if ((WE = '1') and (wclk'event) and (wclk'last_value = '0') and (wclk = '1')) then
      MEM(Index_SP) <= D after 100 ps;      
    end if;
  end process VITALWriteBehavior;
end RAM16X1D_V;
 

