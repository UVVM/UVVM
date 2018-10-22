-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/SRL16E.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  16-Bit Shift Register Look-Up-Table with Clock Enable
-- /___/   /\     Filename : SRL16E.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:57 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL SRL16E -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity SRL16E is

  generic (
       INIT : bit_vector := X"0000"
  );

  port (
        Q   : out STD_ULOGIC;
        
        A0  : in STD_ULOGIC;
        A1  : in STD_ULOGIC;
        A2  : in STD_ULOGIC;
        A3  : in STD_ULOGIC;
        CE  : in STD_ULOGIC;        
        CLK : in STD_ULOGIC;
        D   : in STD_ULOGIC
       ); 
end SRL16E;

architecture SRL16E_V of SRL16E is
    signal SHIFT_REG : std_logic_vector (16 downto 0) := ('X' & To_StdLogicVector(INIT));
begin
  VITALReadBehavior : process(A0, A1, A2, A3, SHIFT_REG)

    variable VALID_ADDR : boolean := FALSE;
    variable LENGTH : integer;
    variable ADDR : std_logic_vector(3 downto 0);

  begin

    ADDR := (A3, A2, A1, A0);
    VALID_ADDR := ADDR_IS_VALID(SLV => ADDR);

    if (VALID_ADDR) then
        LENGTH := SLV_TO_INT(SLV => ADDR);
    else
        LENGTH := 16;
    end if;
    Q <= SHIFT_REG(LENGTH);

  end process VITALReadBehavior;

  VITALWriteBehavior : process
    variable FIRST_TIME : boolean := TRUE;
  begin

    if (FIRST_TIME) then
        wait until ((CE = '1' or CE = '0') and
                   (CLK'last_value = '0' or CLK'last_value = '1') and
                   (CLK = '0' or CLK = '1'));
        FIRST_TIME := FALSE;
    end if;

    if (CLK'event AND CLK'last_value = '0') then
      if (CLK = '1') then
        if (CE = '1') then
          for I in 15 downto 1 loop
            SHIFT_REG(I) <= SHIFT_REG(I-1) after 100 ps;
          end loop;
          SHIFT_REG(0) <= D after 100 ps;
        elsif (CE = 'X') then
          SHIFT_REG <= (others => 'X') after 100 ps;
        end if;
      elsif (CLK = 'X') then
        if (CE /= '0') then
          SHIFT_REG <= (others => 'X') after 100 ps;
        end if;
      end if;
    elsif (CLK'event AND CLK'last_value = 'X') then
      if (CLK = '1') then
        if (CE /= '0') then
          SHIFT_REG <= (others => 'X') after 100 ps;
        end if;
      end if;
    end if;
    wait on CLK;
  end process VITALWriteBehavior;
end SRL16E_V;


