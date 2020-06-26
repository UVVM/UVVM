-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/rainier/VITAL/RAM128X1D.vhd,v 1.1 2008/06/19 16:59:22 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Static Dual Port Synchronous RAM 128-Deep by 1-Wide
-- /___/   /\     Filename : RAM128X1D.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:49 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/15/05 - Initial version.
--    09/21/05 - Use SLV_TO_INT to decode the address. (CR 217651)
-- End Revision

----- CELL RAM128X1D -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity RAM128X1D is
  generic (
    INIT : bit_vector(127 downto 0) := X"00000000000000000000000000000000"
    );

  port (
    DPO : out std_ulogic;
    SPO : out std_ulogic;

    A     : in std_logic_vector(6 downto 0);
    D     : in std_ulogic;
    DPRA  : in std_logic_vector(6 downto 0);
    WCLK  : in std_ulogic;
    WE    : in std_ulogic
    );
end RAM128X1D;

architecture RAM128X1D_V of RAM128X1D is
  signal MEM : std_ulogic_vector( 128 downto 0 ) :=  ('X' & TO_STDULOGICVECTOR(INIT));

begin

  ReadBehavior   : process(A, DPRA, MEM)
    variable Index_SP : integer := 128;
    variable Index_DP : integer := 128;
  begin
    Index_SP := SLV_TO_INT(SLV => A);
    Index_DP := SLV_TO_INT(SLV => DPRA);
    SPO <= MEM(Index_SP);
    DPO <= MEM(Index_DP);      
  end process ReadBehavior;

 WriteBehavior  : process(WCLK)
    variable Index_SP : integer := 128;
  begin
    Index_SP := SLV_TO_INT(SLV => A );
    if ((WE = '1') and (wclk'event) and (wclk'last_value = '0') and (wclk = '1')) then
      MEM(Index_SP) <= D after 100 ps;      
    end if;
  end process WriteBehavior;

end RAM128X1D_V;


