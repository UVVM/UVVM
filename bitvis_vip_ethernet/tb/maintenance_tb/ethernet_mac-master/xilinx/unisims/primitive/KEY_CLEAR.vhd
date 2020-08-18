-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  
-- /___/   /\     Filename : KEY_CLEAR.vhd
-- \   \  /  \    Timestamp : Wed Aug 17 17:14:41 PDT 2005
--  \___\/\___\
--
-- Revision:
--    08/17/05 - Initial version.
--    01/31/11 - Add pulse width check (CR591410)
-- End Revision:

----- CELL KEY_CLEAR -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity KEY_CLEAR is
  port(
      KEYCLEARB            : in std_ulogic
    );

end KEY_CLEAR;

architecture KEY_CLEAR_V of KEY_CLEAR is

begin
    KEYCLEARB_PW_P : process (KEYCLEARB)
      variable r_edge : time := 0 ps;
      variable r_ht : time := 0 ps;
    begin
      if (rising_edge(KEYCLEARB)) then
         r_edge := NOW;
      elsif ((falling_edge(KEYCLEARB)) and r_edge > 1 ps)  then
         r_ht := NOW - r_edge;
         if (r_ht < 200 ps  and r_ht > 0 ps) then
            assert false report
               "Input Error : KEYCLEARB pulse width less than 200 ps."
            severity warning;
         end if;
      end if;
    end process;

end KEY_CLEAR_V;
