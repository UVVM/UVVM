-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/ROM256X1.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  256-Deep by 1-Wide ROM
-- /___/   /\     Filename : ROM256X1.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:57 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL ROM256X1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity ROM256X1 is
  generic (
    INIT : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000"
    );

  port (
    O : out std_ulogic;

    A0 : in std_ulogic;
    A1 : in std_ulogic;
    A2 : in std_ulogic;
    A3 : in std_ulogic;
    A4 : in std_ulogic;
    A5 : in std_ulogic;
    A6 : in std_ulogic;
    A7 : in std_ulogic
    );
end ROM256X1;

architecture ROM256X1_V of ROM256X1 is
begin
  VITALBehavior         : process (A7, A6, A5, A4, A3, A2, A1, A0)
    variable INIT_BITS  : std_logic_vector(255 downto 0) := "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
    variable MEM        : std_logic_vector( 256 downto 0 );
    variable Index      : integer                        := 256;
    variable Raddress   : std_logic_vector (7 downto 0);
    variable FIRST_TIME : boolean                        := true;

  begin
    if (FIRST_TIME = true) then
      INIT_BITS(INIT'length-1 downto 0) := To_StdLogicVector(INIT );
      MEM        := ('X' & INIT_BITS(255 downto 0));
      FIRST_TIME := false;
    end if;
    Raddress     := (A7, A6, A5, A4, A3, A2, A1, A0);
    Index        := SLV_TO_INT(SLV => Raddress );
    O <= MEM(Index);
  end process VITALBehavior;
end ROM256X1_V;


