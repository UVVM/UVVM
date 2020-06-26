-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/LUT4_D.vhd,v 1.1 2008/06/19 16:59:24 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  4-input Look-Up-Table with Dual Output
-- /___/   /\     Filename : LUT4_D.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:02 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    03/15/05 - Modified to handle the address unknown case.
--    03/10/06 - replace TO_INTEGER to SLV_TO_INT. (CR 226842)
-- End Revision

----- CELL LUT4_D -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity LUT4_D is
  generic(
    INIT : bit_vector := X"0000"
    );

  port(
    LO : out std_ulogic;
    O  : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    I2 : in std_ulogic;
    I3 : in std_ulogic
    );
end LUT4_D;

architecture LUT4_D_V of LUT4_D is

function lut4_mux4 (d :  std_logic_vector(3 downto 0); s : std_logic_vector(1 downto 0) )
                    return std_logic is

       variable lut4_mux4_o : std_logic;
  begin
       
       if (((s(1) xor s(0)) = '1')  or  ((s(1) xor s(0)) = '0')) then
           lut4_mux4_o := d(SLV_TO_INT(s));
       elsif ((d(0) xor d(1)) = '0' and (d(2) xor d(3)) = '0'
                    and (d(0) xor d(2)) = '0') then
           lut4_mux4_o := d(0);
       elsif ((s(1) = '0') and (d(0) = d(1))) then
           lut4_mux4_o := d(0);
       elsif ((s(1) = '1') and (d(2) = d(3))) then
           lut4_mux4_o := d(2);
       elsif ((s(0) = '0') and (d(0) = d(2))) then
           lut4_mux4_o := d(0);
       elsif ((s(0) = '1') and (d(1) = d(3))) then
           lut4_mux4_o := d(1);
       else
           lut4_mux4_o := 'X';
      end if;

      return (lut4_mux4_o);
     
  end function lut4_mux4;

    constant INIT_reg : std_logic_vector(15 downto 0) := To_StdLogicVector(INIT);    
begin

  lut_p   : process (I0, I1, I2, I3)
    variable I_reg    : std_logic_vector(3 downto 0);
    variable tmp_o    : std_ulogic;
  begin

    I_reg := TO_STDLOGICVECTOR(I3 &  I2 & I1 & I0);

    if ((I3 xor I2 xor I1 xor I0) = '1' or (I3 xor I2 xor I1 xor I0) = '0') then
       tmp_o := INIT_reg(SLV_TO_INT(I_reg));
    else 
       tmp_o := lut4_mux4 ( 
            (lut4_mux4 ( INIT_reg(15 downto 12), I_reg(1 downto 0)) &
            lut4_mux4 ( INIT_reg(11 downto 8), I_reg(1 downto 0)) &
            lut4_mux4 ( INIT_reg(7 downto 4), I_reg(1 downto 0)) &
            lut4_mux4 ( INIT_reg(3 downto 0), I_reg(1 downto 0))), I_reg(3 downto 2));
    end if;
    O <= tmp_o;
    LO <= tmp_o;

  end process;
end LUT4_D_V;
