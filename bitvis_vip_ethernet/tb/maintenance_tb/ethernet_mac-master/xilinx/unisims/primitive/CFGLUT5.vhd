-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/rainier/VITAL/CFGLUT5.vhd,v 1.1 2008/06/19 16:59:21 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                 5-input Dynamically Reconfigurable Look-Up-Table with Carry and Clock Enable 
-- /___/   /\     Filename : CFGLUT5.vhd
-- \   \  /  \    Timestamp : 
--  \___\/\___\
--
-- Revision:
--    12/28/05 - Initial version.
--    04/13/06 - Add address declaration. (CR229735)
-- End Revision

----- CELL CFGLUT5 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity CFGLUT5 is

  generic (
       INIT : bit_vector := X"00000000"
  );

  port (
        CDO : out STD_ULOGIC;
        O5  : out STD_ULOGIC;
        O6  : out STD_ULOGIC;

        CDI : in STD_ULOGIC;
        CE  : in STD_ULOGIC;
        CLK : in STD_ULOGIC;        
        I0  : in STD_ULOGIC;
        I1  : in STD_ULOGIC;
        I2  : in STD_ULOGIC;
        I3  : in STD_ULOGIC;
        I4  : in STD_ULOGIC
       ); 
end CFGLUT5;

architecture CFGLUT5_V of CFGLUT5 is
  signal SHIFT_REG : std_logic_vector (31 downto 0) :=  To_StdLogicVector(INIT);
  signal o6_slv : std_logic_vector (4 downto 0) ;
  signal o5_slv : std_logic_vector (3 downto 0) ;
  signal o6_addr : integer := 0;
  signal o5_addr : integer := 0;
begin

    o6_slv <= I4 & I3 & I2 & I1 & I0;
    o5_slv <= I3 & I2 & I1 & I0;
    o6_addr <= SLV_TO_INT(o6_slv(4 downto 0));
    o5_addr <= SLV_TO_INT(o5_slv(3 downto 0));
    O6 <= SHIFT_REG(o6_addr);
    O5 <= SHIFT_REG(o5_addr);
    CDO <= SHIFT_REG(31);

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
           SHIFT_REG(31 downto 0) <= (SHIFT_REG(30 downto 0) & CDI) after 100 ps;
        end if ;
    end if;

    wait on CLK;

  end process WriteBehavior;

end CFGLUT5_V;


