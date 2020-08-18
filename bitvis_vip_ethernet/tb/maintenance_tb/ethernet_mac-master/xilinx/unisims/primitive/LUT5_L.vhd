-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/rainier/VITAL/LUT5_L.vhd,v 1.1 2008/06/19 16:59:22 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  5-input Look-Up-Table with General Output
-- /___/   /\     Filename : lut5_l.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:02 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    03/15/05 - Modified to handle the address unknown case.
--    03/10/06 - Change d to df in function lut4_mux4f and replace TO_INTEGER to
--               SLV_TO_INT. (CR 226842)
-- End Revision

----- CELL LUT5_L -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity LUT5_L is
  generic(
    INIT : bit_vector := X"00000000"
    );

  port(
    LO : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    I2 : in std_ulogic;
    I3 : in std_ulogic;
    I4 : in std_ulogic
    );
end LUT5_L;

architecture LUT5_L_V of LUT5_L is

function lut6_mux8 (d :  std_logic_vector(7 downto 0); s : std_logic_vector(2 downto 0)) 
                    return std_logic is

       variable lut6_mux8_o : std_logic;
       function lut4_mux4f (df :  std_logic_vector(3 downto 0); sf : std_logic_vector(1 downto 0) )
                    return std_logic is

            variable lut4_mux4_f : std_logic;
       begin

            if (((sf(1) xor sf(0)) = '1')  or  ((sf(1) xor sf(0)) = '0')) then
                lut4_mux4_f := df(SLV_TO_INT(sf));          
            elsif ((df(0) xor df(1)) = '0' and (df(2) xor df(3)) = '0'
                    and (df(0) xor df(2)) = '0') then
                lut4_mux4_f := df(0);
            elsif ((sf(1) = '0') and (df(0) = df(1))) then
                lut4_mux4_f := df(0);
            elsif ((sf(1) = '1') and (df(2) = df(3))) then
                lut4_mux4_f := df(2);
            elsif ((sf(0) = '0') and (df(0) = df(2))) then
                lut4_mux4_f := df(0);
            elsif ((sf(0) = '1') and (df(1) = df(3))) then
                lut4_mux4_f := df(1);
            else
                lut4_mux4_f := 'X';
           end if;

           return (lut4_mux4_f);
    
       end function lut4_mux4f;
  begin
       
    if ((s(2) xor s(1) xor s(0)) = '1' or (s(2) xor s(1) xor s(0)) = '0') then
       lut6_mux8_o := d(SLV_TO_INT(s));
    else
       lut6_mux8_o := lut4_mux4f(('0' & '0' & lut4_mux4f(d(7 downto 4), s(1 downto 0)) &
            lut4_mux4f(d(3 downto 0), s(1 downto 0))), ('0' & s(2)));
    end if;

      return (lut6_mux8_o);
     
  end function lut6_mux8;

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

    constant INIT_reg : std_logic_vector(31 downto 0) := To_StdLogicVector(INIT);    
begin

  lut_p   : process (I0, I1, I2, I3, I4)
    variable INIT_reg : std_logic_vector(31 downto 0) := To_StdLogicVector(INIT);    
    variable I_reg : std_logic_vector(4 downto 0);
  begin

    I_reg := TO_STDLOGICVECTOR(I4 & I3 &  I2 & I1 & I0);

    if ((I4 xor I3 xor I2 xor I1 xor I0) = '1' or (I4 xor I3 xor I2 xor I1 xor I0) = '0') then
       LO <= INIT_reg(SLV_TO_INT(I_reg));
    else 

       LO <=  lut4_mux4 ( 
           (lut6_mux8 ( INIT_reg(31 downto 24), I_reg(2 downto 0)) &
            lut6_mux8 ( INIT_reg(23 downto 16), I_reg(2 downto 0)) &
            lut6_mux8 ( INIT_reg(15 downto 8), I_reg(2 downto 0)) &
            lut6_mux8 ( INIT_reg(7 downto 0), I_reg(2 downto 0))),
                        I_reg(4 downto 3));
 
    end if;
  end process;
end LUT5_L_V;
