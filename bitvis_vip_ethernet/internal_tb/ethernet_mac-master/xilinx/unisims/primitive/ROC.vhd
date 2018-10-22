-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/ROC.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Reset On Configuration
-- /___/   /\     Filename : ROC.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:56 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL ROC -----

library IEEE;
use IEEE.std_logic_1164.all;

entity ROC is
  generic (
    InstancePath : string := "*";
    WIDTH : time := 100 ns
    );
  port(
    O : out std_ulogic := '1'
    );
end ROC;

architecture ROC_V of ROC is
begin
  ONE_SHOT : process
  begin
    if (WIDTH <= 0 ns) then
      assert false report
        "*** Error : a positive value of WIDTH must be specified ***"
        severity failure;
    else
      wait for WIDTH;
      O <= '0';
    end if;
    wait;
  end process ONE_SHOT;
end ROC_V;

