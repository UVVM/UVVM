-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/LUT2_L.vhd,v 1.1 2008/06/19 16:59:24 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  2-input Look-Up-Table with Local Output
-- /___/   /\     Filename : LUT2_L.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:02 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    03/15/05 - Modified to handle the address unknown case.
--    03/10/06 - replace TO_INTEGER to SLV_TO_INT. (CR 226842)
--    04/13/06 - Add address declaration. (CR229735)
-- End Revision

----- CELL LUT2_L -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity LUT2_L is
  generic(
    INIT : bit_vector := X"0"
    );

  port(
    LO : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic
    );
end LUT2_L;

architecture LUT2_L_V of LUT2_L is
begin
  VITALBehavior    : process (I0, I1)
    variable INIT_reg : std_logic_vector((INIT'length - 1) downto 0) := To_StdLogicVector(INIT);
    variable address : std_logic_vector(1 downto 0);
    variable address_int : integer := 0;
  begin
     address := I1 & I0;
     address_int := SLV_TO_INT(address(1 downto 0));

     if ((I1 xor I0) = '1' or (I1 xor I0) = '0') then
       LO <= INIT_reg(address_int);
    else 
        if ((INIT_reg(0) = INIT_reg(1)) and (INIT_reg(2) = INIT_reg(3)) and 
                              (INIT_reg(0) = INIT_reg(2)))  then
        LO <= INIT_reg(0);
      elsif ((I1 = '0') and (INIT_reg(0) = INIT_reg(1)))  then
        LO <= INIT_reg(0);      
      elsif ((I1 = '1') and (INIT_reg(2) = INIT_reg(3)))  then
        LO <= INIT_reg(2);      
      elsif ((I0 = '0') and (INIT_reg(0) = INIT_reg(2)))  then
        LO <= INIT_reg(0);      
      elsif ((I0 = '1') and (INIT_reg(1)  = INIT_reg(3)))  then
        LO <= INIT_reg(1);      
      else
        LO <= 'X';
      end if;
    end if;
  end process;
end LUT2_L_V;
