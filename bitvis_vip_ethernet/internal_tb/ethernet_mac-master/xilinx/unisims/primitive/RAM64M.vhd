-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/rainier/VITAL/RAM64M.vhd,v 1.1 2008/06/19 16:59:22 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Function Simulation Library Component
--  /   /                  Static Synchronous RAM 64-Deep by 4-Wide
-- /___/   /\     Filename : RAM64M.vhd
-- \   \  /  \    Timestamp : 
--  \___\/\___\
--
-- Revision:
--    03/23/06 - Initial version.
-- End Revision

----- CELL RAM64M -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity RAM64M is
  generic (
      INIT_A : bit_vector(63 downto 0) := X"0000000000000000";
      INIT_B : bit_vector(63 downto 0) := X"0000000000000000";
      INIT_C : bit_vector(63 downto 0) := X"0000000000000000";
      INIT_D : bit_vector(63 downto 0) := X"0000000000000000"
    );

  port (
    DOA    : out std_ulogic;
    DOB    : out std_ulogic;
    DOC    : out std_ulogic;
    DOD    : out std_ulogic;

    ADDRA : in  std_logic_vector(5 downto 0);
    ADDRB : in  std_logic_vector(5 downto 0);
    ADDRC : in  std_logic_vector(5 downto 0);
    ADDRD : in  std_logic_vector(5 downto 0);
    DIA   : in  std_ulogic;
    DIB   : in  std_ulogic;
    DIC   : in  std_ulogic;
    DID   : in  std_ulogic;
    WCLK  : in  std_ulogic;
    WE   : in  std_ulogic
    );
end RAM64M;

architecture RAM64M_V of RAM64M is

  signal MEM_a : std_logic_vector( 64 downto 0 ) := ('X' & To_StdLogicVector(INIT_A) );
  signal MEM_b : std_logic_vector( 64 downto 0 ) := ('X' & To_StdLogicVector(INIT_B) );
  signal MEM_c : std_logic_vector( 64 downto 0 ) := ('X' & To_StdLogicVector(INIT_C) );
  signal MEM_d : std_logic_vector( 64 downto 0 ) := ('X' & To_StdLogicVector(INIT_D) );
begin

   DOA   <= MEM_a(SLV_TO_INT(SLV => ADDRA));
   DOB   <= MEM_b(SLV_TO_INT(SLV => ADDRB));
   DOC   <= MEM_c(SLV_TO_INT(SLV => ADDRC));
   DOD   <= MEM_d(SLV_TO_INT(SLV => ADDRD));

  VITALWriteBehavior : process(WCLK)
    variable Index   : integer := 64 ;
  begin
    if (rising_edge(WCLK)) then
      if (WE = '1') then
        Index                  := SLV_TO_INT(SLV => ADDRD);
        MEM_a(Index) <= DIA  after 100 ps;
        MEM_b(Index) <= DIB  after 100 ps;
        MEM_c(Index) <= DIC  after 100 ps;
        MEM_d(Index) <= DID  after 100 ps;
      end if;
    end if;
  end process VITALWriteBehavior;

end RAM64M_V;
