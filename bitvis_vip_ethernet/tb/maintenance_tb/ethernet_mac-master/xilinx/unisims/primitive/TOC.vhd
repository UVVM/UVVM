-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/TOC.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Three-State on Configuration
-- /___/   /\     Filename : TOC.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:57:00 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL TOC -----

library IEEE;
use IEEE.std_logic_1164.all;

entity TOC is
  generic (
    InstancePath : string := "*";
    WIDTH        : time   := 100 ns
    );

  port(
    O : out std_ulogic := '0'
    );
end TOC;

architecture TOC_V of TOC is
begin
  ONE_SHOT : process
  begin
    O         <= '1';
    if (WIDTH <= 0 ns) then
      O       <= '0';
    else
      wait for WIDTH;
      O       <= '0';
    end if;
    wait;
  end process ONE_SHOT;
end TOC_V;


