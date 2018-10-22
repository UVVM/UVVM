-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Boundary Scan Logic Control Circuit for SPARTAN3A
-- /___/   /\     Filename : BSCAN_SPARTAN3A.vhd
-- \   \  /  \    Timestamp : Tue Jul  5 16:58:04 PDT 2005
--  \___\/\___\
--
-- Revision:
--    07/05/05 - Initial version.
--    01/24/06 - CR 224623, added TCK and TMS ports
-- End Revision

----- CELL BSCAN_SPARTAN3A -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.vcomponents.all;

entity BSCAN_SPARTAN3A is

  port(
      CAPTURE : out std_ulogic := 'H';
      DRCK1   : out std_ulogic := 'L';
      DRCK2   : out std_ulogic := 'L';
      RESET   : out std_ulogic := 'L';
      SEL1    : out std_ulogic := 'L';
      SEL2    : out std_ulogic := 'L';
      SHIFT   : out std_ulogic := 'L';
      TCK     : out std_ulogic := 'L';
      TDI     : out std_ulogic := 'L';
      TMS     : out std_ulogic := 'L';
      UPDATE  : out std_ulogic := 'L';

      TDO1 : in std_ulogic := 'X';
      TDO2 : in std_ulogic := 'X'
      );
end BSCAN_SPARTAN3A;


-- architecture body  

architecture BSCAN_SPARTAN3A_V of BSCAN_SPARTAN3A is



  signal        TDO1_dly         : std_ulogic := '0';
  signal        TDO2_dly         : std_ulogic := '0';

begin

  TDO1_dly       	 <= TDO1           	after 0 ps;
  TDO2_dly       	 <= TDO2           	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------


-- synopsys translate_off

      CAPTURE <= JTAG_CAPTURE_GLBL ;

--####################################################################
--#####                        jtag_select                         ###
--####################################################################
      DRCK1  <= ((JTAG_SEL1_GLBL and not JTAG_SHIFT_GLBL and not JTAG_CAPTURE_GLBL)
                                     or
                 (JTAG_SEL1_GLBL and JTAG_SHIFT_GLBL and JTAG_TCK_GLBL)
                                     or
                 (JTAG_SEL1_GLBL and JTAG_CAPTURE_GLBL and JTAG_TCK_GLBL));
      DRCK2  <= ((JTAG_SEL2_GLBL and not JTAG_SHIFT_GLBL and not JTAG_CAPTURE_GLBL)
                                     or
                 (JTAG_SEL2_GLBL and JTAG_SHIFT_GLBL and JTAG_TCK_GLBL)
                                     or
                 (JTAG_SEL2_GLBL and JTAG_CAPTURE_GLBL and JTAG_TCK_GLBL));
      RESET  <= JTAG_RESET_GLBL ;
      SEL1   <= JTAG_SEL1_GLBL;
      SEL2   <= JTAG_SEL2_GLBL;
      SHIFT  <= JTAG_SHIFT_GLBL;
      TCK    <= JTAG_TCK_GLBL;
      TDI    <= JTAG_TDI_GLBL;
      TMS    <= JTAG_TMS_GLBL;
      UPDATE <= JTAG_UPDATE_GLBL;

      JTAG_USER_TDO1_GLBL <=  TDO1;
      JTAG_USER_TDO2_GLBL <=  TDO2;

-- synopsys translate_on


end BSCAN_SPARTAN3A_V;

