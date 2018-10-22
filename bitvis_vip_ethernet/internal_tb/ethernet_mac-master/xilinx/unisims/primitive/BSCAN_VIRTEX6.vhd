-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Boundary Scan Logic Control Circuit for VIRTEX6
-- /___/   /\     Filename : BSCAN_VIRTEX6.v
-- \   \  /  \    Timestamp : Thu Jan 29 15:11:19 PST 2009
--  \___\/\___\
--
-- Revision:
--    01/29/09 - Initial version.
-- End Revision


----- CELL BSCAN_VIRTEX6 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.vcomponents.all;
entity BSCAN_VIRTEX6 is
  generic(
        DISABLE_JTAG : boolean := FALSE;
        JTAG_CHAIN : integer := 1
        );

  port(
    CAPTURE : out std_ulogic := 'H';
    DRCK    : out std_ulogic := 'H';
    RESET   : out std_ulogic := 'H';
    RUNTEST : out std_ulogic := 'L';
    SEL     : out std_ulogic := 'L';
    SHIFT   : out std_ulogic := 'L';
    TCK     : out std_ulogic := 'L';
    TDI     : out std_ulogic := 'L';
    TMS     : out std_ulogic := 'L';
    UPDATE  : out std_ulogic := 'L';

    TDO     : in std_ulogic := 'X'
    );

end BSCAN_VIRTEX6;

architecture BSCAN_VIRTEX6_V of BSCAN_VIRTEX6 is

signal SEL_zd : std_ulogic := '0';
signal UPDATE_zd : std_ulogic := '0';

begin

--####################################################################
--#####                        Initialization                      ###
--####################################################################
  prcs_init:process
  begin
     if((JTAG_CHAIN /= 1) and (JTAG_CHAIN /= 2)  and (JTAG_CHAIN /= 3)
                                           and (JTAG_CHAIN /= 4)) then
        assert false
        report "Attribute Syntax Error: The allowed values for JTAG_CHAIN are 1, 2, 3 or 4"
        severity Failure;
     end if;

     if((DISABLE_JTAG /= TRUE) and (DISABLE_JTAG /= FALSE)) then
        assert false
        report "Attribute Syntax Error: The allowed values for DISABLE_JTAG are TRUE or FALSE"
        severity Failure;
     end if;
     wait;
  end process prcs_init;

-- synopsys translate_off

--####################################################################
--#####                        jtag_select                         ###
--####################################################################
  prcs_jtag_select:process (JTAG_SEL1_GLBL, JTAG_SEL2_GLBL, JTAG_SEL3_GLBL, JTAG_SEL4_GLBL)
  begin
      if(JTAG_CHAIN = 1) then
        SEL_zd <= JTAG_SEL1_GLBL;
      elsif(JTAG_CHAIN = 2) then
        SEL_zd <= JTAG_SEL2_GLBL;
      elsif(JTAG_CHAIN = 3) then
        SEL_zd <= JTAG_SEL3_GLBL;
      elsif(JTAG_CHAIN = 4) then
        SEL_zd <= JTAG_SEL4_GLBL;
     end if;

  end process prcs_jtag_select;

--####################################################################
--#####                        USER_TDO                            ###
--####################################################################
  prcs_jtag_UserTDO:process (TDO)
  begin
      if(JTAG_CHAIN = 1) then
        JTAG_USER_TDO1_GLBL <= TDO;
      elsif(JTAG_CHAIN = 2) then
        JTAG_USER_TDO2_GLBL <= TDO;
      elsif(JTAG_CHAIN = 3) then
        JTAG_USER_TDO3_GLBL <= TDO;
      elsif(JTAG_CHAIN = 4) then
        JTAG_USER_TDO4_GLBL <= TDO;
     end if;

  end process prcs_jtag_UserTDO;
--####################################################################

  CAPTURE <= JTAG_CAPTURE_GLBL;
  DRCK  <= ((SEL_zd and not JTAG_SHIFT_GLBL and not JTAG_CAPTURE_GLBL) or
            (SEL_zd and JTAG_SHIFT_GLBL and JTAG_TCK_GLBL) or
            (SEL_zd and JTAG_CAPTURE_GLBL and JTAG_TCK_GLBL));

  RESET   <= JTAG_RESET_GLBL;
  RUNTEST <= JTAG_RUNTEST_GLBL;
  SEL     <= SEL_zd;
  SHIFT   <= JTAG_SHIFT_GLBL;
  TDI     <= JTAG_TDI_GLBL;
  TCK     <= JTAG_TCK_GLBL;
  TMS     <= JTAG_TMS_GLBL;
  UPDATE  <= JTAG_UPDATE_GLBL;

-- synopsys translate_on

end BSCAN_VIRTEX6_V;
