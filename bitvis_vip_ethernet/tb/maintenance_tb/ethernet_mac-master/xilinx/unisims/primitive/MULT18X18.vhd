-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/MULT18X18.vhd,v 1.1 2008/06/19 16:59:24 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  18X18 Signed Multiplier
-- /___/   /\     Filename : MULT18X18.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:03 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL MULT18X18 -----

library IEEE;
use IEEE.std_logic_1164.all;

library unisim;
use unisim.Vpkg.all;

entity MULT18X18 is
    port (
	  P	: out std_logic_vector (35 downto 0);
          
          A	: in std_logic_vector (17 downto 0);
          B	: in std_logic_vector (17 downto 0)
          );
    
end MULT18X18;

architecture MULT18X18_V of MULT18X18 is

function INT_TO_SLV(ARG: integer; SIZE: integer) return std_logic_vector is

	variable result : std_logic_vector (SIZE-1 downto 0);
        variable temp : integer := ARG;
begin
	temp := ARG;
	for i in 0 to SIZE-1 loop
		if (temp mod 2) = 1 then
			result(i) := '1';
		else
			result(i) := '0';
		end if;
		if temp > 0 then
			temp := temp /2 ;
		elsif (temp > integer'low) then
			temp := (temp-1) / 2;
		else
			temp := temp / 2;
		end if;
	end loop;
	return result;
end;

function COMPLEMENT(ARG: std_logic_vector ) return std_logic_vector is

	variable 	RESULT : std_logic_vector (ARG'left downto 0);
	variable	found1 : std_ulogic := '0';
begin
		for i in  0 to ARG'left  loop
			if (found1 = '0') then
				RESULT(i) := ARG(i);
				if (ARG(i) = '1' ) then
					found1 := '1';
				end if;
			else
				RESULT(i) := not ARG(i);
			end if;
                end loop;
		return result;
end;

function VECPLUS(A, B: std_logic_vector ) return std_logic_vector is

	variable carry: std_ulogic;
        variable BV, sum: std_logic_vector(A'left downto 0);

begin

	if (A(A'left) = 'X' or B(B'left) = 'X') then
            sum := (others => 'X');
            return(sum);
        end if;
        carry := '0';
        BV := B;

        for i in 0 to A'left loop
            sum(i) := A(i) xor BV(i) xor carry;
            carry := (A(i) and BV(i)) or
                    (A(i) and carry) or
                    (carry and BV(i));
        end loop;
        return sum;
end;
 
begin

  VITALBehaviour : process (A, B)
    variable O_zd,O1_zd, O2_zd : std_logic_vector( A'length+B'length-1 downto 0);
    variable IA, IB1,IB2  : integer ;
    variable sign : std_ulogic := '0';
    variable A_i : std_logic_vector(A'left downto 0);
    variable B_i : std_logic_vector(B'left downto 0);

  begin

    if (Is_X(A) or Is_X(B) ) then
            O_zd := (others => 'X');
    else
       if (A(A'left) = '1' ) then
         A_i :=  complement(A);
       else 
         A_i := A;
       end if;

       if (B(B'left)  = '1') then
         B_i := complement(B);
       else
         B_i := B;
       end if;

        IA := SLV_TO_INT(A_i);
        IB1 := SLV_TO_INT(B_i (17 downto 9));
        IB2 := SLV_TO_INT(B_i (8 downto 0));


       O1_zd := INT_TO_SLV((IA * IB1), A'length+B'length);
	-- shift I1_zd 9 to the left
           for j in 0 to 8 loop
            O1_zd(A'length+B'length-1 downto 0) := O1_zd(A'length+B'length-2 downto 0) & '0';
           end loop;
       O2_zd := INT_TO_SLV((IA * IB2), A'length+B'length);
       O_zd  := VECPLUS(O1_zd, O2_zd);

       sign := A(A'left) xor B(B'left);
       if (sign = '1' ) then
              O_zd := complement(O_zd);
       end if;
    end if;
    P <= O_zd;
  end process VITALBehaviour;

end MULT18X18_V ;


