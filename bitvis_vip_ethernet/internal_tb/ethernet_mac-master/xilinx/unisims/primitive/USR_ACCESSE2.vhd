-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/fuji/VITAL/USR_ACCESSE2.vhd,v 1.3 2012/09/22 00:04:49 wloo Exp $
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
-- /___/   /\      Filename    : USR_ACCESSE2.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Revision: 1.0
-------------------------------------------------------

----- CELL USR_ACCESSE2 -----

library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

  entity USR_ACCESSE2 is
    port (
      CFGCLK               : out std_ulogic;
      DATA                 : out std_logic_vector(31 downto 0);
      DATAVALID            : out std_ulogic
    );
  end USR_ACCESSE2;

  architecture USR_ACCESSE2_V of USR_ACCESSE2 is
    
    signal CFGCLK_out : std_ulogic;
    signal DATAVALID_out : std_ulogic;
    signal DATA_out : std_logic_vector(31 downto 0);
    
    begin

    CFGCLK <= CFGCLK_out;
    DATA <= DATA_out;
    DATAVALID <= DATAVALID_out;

   end USR_ACCESSE2_V;
