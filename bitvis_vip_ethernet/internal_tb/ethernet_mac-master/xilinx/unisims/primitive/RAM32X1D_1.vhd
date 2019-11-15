-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/RAM32X1D_1.vhd,v 1.1 2008/06/19 16:59:25 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Static Dual Port Synchronous RAM 32-Deep by 1-Wide
-- /___/   /\     Filename : RAM32X1D_1.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:48 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL RAM32X1D_1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity RAM32X1D_1 is

  generic (
    INIT : bit_vector(31 downto 0) := X"00000000"
    );

  port (
    DPO : out std_ulogic;
    SPO : out std_ulogic;

    A0    : in std_ulogic;
    A1    : in std_ulogic;
    A2    : in std_ulogic;
    A3    : in std_ulogic;
    A4    : in std_ulogic;
    D     : in std_ulogic;
    DPRA0 : in std_ulogic;
    DPRA1 : in std_ulogic;
    DPRA2 : in std_ulogic;
    DPRA3 : in std_ulogic;
    DPRA4 : in std_ulogic;
    WCLK  : in std_ulogic;
    WE    : in std_ulogic
    );
end RAM32X1D_1;

architecture RAM32X1D_1_V of RAM32X1D_1 is
  signal MEM : std_logic_vector( 32 downto 0 ) := ('X' & To_StdLogicVector(INIT) );

begin
  VITALReadBehavior   : process(A0, A1, A2, A3, A4, DPRA4, DPRA3, DPRA2, DPRA1, DPRA0, MEM)
    variable Index_SP : integer := 32;
    variable Index_DP : integer := 32;
    variable Raddress : std_logic_vector (4 downto 0);
    variable Waddress : std_logic_vector (4 downto 0);

  begin
    Raddress := (A4, A3, A2, A1, A0);
    Waddress := (DPRA4, DPRA3, DPRA2, DPRA1, DPRA0);
    Index_SP := SLV_TO_INT(SLV => Raddress);
    Index_DP := SLV_TO_INT(SLV => Waddress);
    SPO <= MEM(Index_SP);
    DPO <= MEM(Index_DP);
  end process VITALReadBehavior;

  VITALWriteBehavior  : process(WCLK)
    variable Index_SP : integer := 32;
    variable Index_DP : integer := 32;
    variable Address  : std_logic_vector( 4 downto 0);

  begin
    Address  := (A4, A3, A2, A1, A0);
    Index_SP := SLV_TO_INT(SLV => Address );
    if ((WE = '1') and (wclk'event) and (wclk'last_value = '1') and (wclk = '0')) then
      MEM(Index_SP) <= D after 100 ps;      
    end if;
  end process VITALWriteBehavior;
end RAM32X1D_1_V;


