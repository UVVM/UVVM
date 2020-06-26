-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/rainier/VITAL/CARRY4.vhd,v 1.3 2012/04/25 22:21:49 robh Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Fast Carry Logic with Look Ahead
-- /___/   /\     Filename : CARRY4.vhd
-- \   \  /  \    
--  \___\/\___\
-- Revision:
--    04/11/05 - Initial version.
--    05/06/05 - Unused CYINT or CI pin need grounded instead of open (CR207752)
--    05/31/05 - Change pin order, remove connection check for CYINT and CI.
--    10/04/11 - Add X to CO_out to handle S=X (CR627723)
--    04/13/12 - CR655410 - add pulldown (:= 'L'), CI, CYINIT
-- End Revision

----- CELL CARRY4 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity CARRY4 is

  port(
      CO          : out std_logic_vector(3 downto 0);
      O           : out std_logic_vector(3 downto 0);
   
      CI          : in  std_ulogic := 'L';
      CYINIT      : in  std_ulogic := 'L';
      DI          : in std_logic_vector(3 downto 0);
      S           : in std_logic_vector(3 downto 0)
      );

end CARRY4;

architecture CARRY4_V OF CARRY4 is

  signal ci_or_cyinit : std_ulogic;
  signal CO_out : std_logic_vector(3 downto 0);

begin

  O <= S xor ( CO_out(2 downto 0) & ci_or_cyinit );
  CO <= CO_out;

  CO_out(0) <= ci_or_cyinit when S(0) = '1' else DI(0) when S(0) = '0' else 'X'; 
  CO_out(1) <= CO_out(0) when S(1) = '1' else DI(1) when S(1) = '0' else 'X'; 
  CO_out(2) <= CO_out(1) when S(2) = '1' else DI(2) when S(2) = '0' else 'X'; 
  CO_out(3) <= CO_out(2) when S(3) = '1' else DI(3) when S(3) = '0' else 'X'; 
  ci_or_cyinit <= CI or CYINIT;


end CARRY4_V;

