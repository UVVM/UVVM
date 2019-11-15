-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/rainier/VITAL/RAM256X1S.vhd,v 1.1 2008/06/19 16:59:22 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Static Synchronous RAM 256-Deep by 1-Wide
-- /___/   /\     Filename : RAM256X1S.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:49 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/15/05 - Initial version.
--    09/21/05 - Use SLV_TO_INT to decode the address. (CR 217651)
-- End Revision

----- CELL RAM256X1S -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity RAM256X1S is
  generic (
    INIT : bit_vector(255 downto 0) := X"0000000000000000000000000000000000000000000000000000000000000000"
    );

  port (
    O : out std_ulogic;

    A     : in std_logic_vector(7 downto 0);
    D     : in std_ulogic;
    WCLK  : in std_ulogic;
    WE    : in std_ulogic
    );
end RAM256X1S;

architecture RAM256X1S_V of RAM256X1S is
  signal MEM : std_ulogic_vector( 256 downto 0 ) :=  ('X' & TO_STDULOGICVECTOR(INIT));

begin

  ReadBehavior  : process(A, MEM)
    variable Index   : integer := 256;

  begin
    Index   := SLV_TO_INT(SLV => A);
    O <= MEM(Index);      
  end process ReadBehavior;

  WriteBehavior : process(WCLK)
    variable Index   : integer := 256;
  begin
    Index                  := SLV_TO_INT(SLV => A);
    if ((WE = '1') and (wclk'event) and (wclk'last_value = '0') and (wclk = '1')) then
        MEM(Index) <= D after 100 ps;
    end if;
  end process WriteBehavior;

end RAM256X1S_V;


