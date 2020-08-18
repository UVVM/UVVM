-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/rainier/VITAL/SRLC32E.vhd,v 1.1 2008/06/19 16:59:22 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  32-Bit Shift Register Look-Up-Table with Carry and Clock Enable
-- /___/   /\     Filename : SRLC32E.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:58 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/15/04 - Initial version.
--    04/22/05 - Change input A type from ulogic vector to logic vector.
-- End Revision

----- CELL SRLC32E -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity SRLC32E is

  generic (
       INIT : bit_vector := X"00000000"
  );

  port (
        Q   : out STD_ULOGIC;
        Q31 : out STD_ULOGIC;

        A   : in STD_LOGIC_VECTOR (4 downto 0);
        CE  : in STD_ULOGIC;
        CLK : in STD_ULOGIC;        
        D   : in STD_ULOGIC
       ); 
end SRLC32E;

architecture SRLC32E_V of SRLC32E is
  signal SHIFT_REG : std_logic_vector (31 downto 0) :=  To_StdLogicVector(INIT);
begin

    Q <= SHIFT_REG(TO_INTEGER(UNSIGNED(A)));
    Q31 <= SHIFT_REG(31);


   WriteBehavior : process

    variable FIRST_TIME : boolean := TRUE;

  begin

    if (FIRST_TIME) then
        wait until ((CE = '1' or CE = '0') and
                   (CLK'last_value = '0' or CLK'last_value = '1') and
                   (CLK = '0' or CLK = '1'));
        FIRST_TIME := FALSE;
    end if;

    if (CLK'event AND CLK = '1') then
        if (CE = '1') then
           SHIFT_REG(31 downto 0) <= (SHIFT_REG(30 downto 0) & D) after 100 ps;
        end if ;
    end if;

    wait on CLK;

  end process WriteBehavior;
end SRLC32E_V;


