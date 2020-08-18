-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/blanc/VITAL/AUTOBUF.vhd,v 1.3 2009/08/22 00:26:00 harikr Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Clock Buffer
-- /___/   /\     Filename : AUTOBUF.vhd
-- \   \  /  \    Timestamp : 
--  \___\/\___\
--
-- Revision:
--    04/08/08 - Initial version.
--    09/04/08 - Add attribute value check.
--    07/23/09 - Add more attrute values (CR521811)
-- End Revision

----- CELL AUTOBUF -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity AUTOBUF is
  generic(
    BUFFER_TYPE : string := "AUTO"
    );
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );
end AUTOBUF;

architecture AUTOBUF_V of AUTOBUF is
begin
  INIPROC : process
  begin
    if (BUFFER_TYPE /= "AUTO" and BUFFER_TYPE /= "auto" and
        BUFFER_TYPE /= "BUF" and BUFFER_TYPE /= "buf" and
        BUFFER_TYPE /= "BUFG" and BUFFER_TYPE /= "bufg" and
        BUFFER_TYPE /= "BUFGP" and BUFFER_TYPE /= "bufgp" and
        BUFFER_TYPE /= "BUFH" and BUFFER_TYPE /= "bufh" and
        BUFFER_TYPE /= "BUFIO" and BUFFER_TYPE /= "bufio" and
        BUFFER_TYPE /= "BUFIO2" and BUFFER_TYPE /= "bufioi2" and
        BUFFER_TYPE /= "BUFIO2FB" and BUFFER_TYPE /= "bufioi2fb" and
        BUFFER_TYPE /= "BUFR" and BUFFER_TYPE /= "bufr" and
        BUFFER_TYPE /= "IBUF" and BUFFER_TYPE /= "ibuf" and
        BUFFER_TYPE /= "IBUFG" and BUFFER_TYPE /= "ibufg" and
        BUFFER_TYPE /= "NONE" and BUFFER_TYPE /= "none" and
        BUFFER_TYPE /= "OBUF" and BUFFER_TYPE /= "obuf" ) then

      assert FALSE report "Attribute Syntax Error : BUFFER_TYPE is not AUTO, BUF, BUFG, BUFGP, BUFH, BUFIO, BUFIO2, BUFIO2FB, BUFR, IBUF, IBUFG, NONE, and OBUF." severity error;
       end if;
   wait;
  end process;

  O <= TO_X01(I);

end AUTOBUF_V;
