-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/fuji/VITAL/BUFMR.vhd,v 1.1 2009/12/21 22:37:58 yanx Exp $
-------------------------------------------------------
--  Copyright (c) 2009 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   / 
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version : 11.1
--  \   \          Description : 
--  /   /                      
-- /___/   /\      Filename    : BUFMR.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Revision: 1.0
-------------------------------------------------------

----- CELL BUFMR -----

library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

  entity BUFMR is
    port (
      O                    : out std_ulogic;
      I                    : in std_ulogic      
    );
  end BUFMR;

  architecture BUFMR_V of BUFMR is
    
    begin

    O <= TO_X01(I);

  end BUFMR_V;
