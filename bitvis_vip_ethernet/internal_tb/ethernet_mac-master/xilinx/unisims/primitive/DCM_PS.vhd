-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/virtex4/VITAL/DCM_PS.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Digital Clock Manager with Basic and Phase Shift Features
-- /___/   /\     Filename : DCM_PS.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:57:03 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    08/08/05 - Add parameter DCM_AUTOCALIBRATION (CR 214040).
--    05/10/07 - Remove Vital timing.
-- End Revision
----- CELL DCM_PS -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;
library unisim;
use unisim.VCOMPONENTS.all;
use unisim.VPKG.all;
library STD;
use STD.TEXTIO.all;

entity DCM_PS is
generic (
		CLKDV_DIVIDE : real := 2.0;
		CLKFX_DIVIDE : integer := 1;
		CLKFX_MULTIPLY : integer := 4;
		CLKIN_DIVIDE_BY_2 : boolean := FALSE;
		CLKIN_PERIOD : real := 10.0;
		CLKOUT_PHASE_SHIFT : string := "NONE";
		CLK_FEEDBACK : string := "1X";                
                DCM_AUTOCALIBRATION : boolean := TRUE;  
		DCM_PERFORMANCE_MODE : string := "MAX_SPEED";
		DESKEW_ADJUST : string := "SYSTEM_SYNCHRONOUS";
		DFS_FREQUENCY_MODE : string := "LOW";
		DLL_FREQUENCY_MODE : string := "LOW";
		DUTY_CYCLE_CORRECTION : boolean := TRUE;
                FACTORY_JF : bit_vector := X"F0F0";                 --non-simulatable                
		PHASE_SHIFT : integer := 0;
		STARTUP_WAIT : boolean := FALSE
  );

port (
		CLK0 : out std_ulogic;
		CLK180 : out std_ulogic;
		CLK270 : out std_ulogic;
		CLK2X : out std_ulogic;
		CLK2X180 : out std_ulogic;
		CLK90 : out std_ulogic;
		CLKDV : out std_ulogic;
		CLKFX : out std_ulogic;
		CLKFX180 : out std_ulogic;
		DO : out std_logic_vector(15 downto 0);
		LOCKED : out std_ulogic;
		PSDONE : out std_ulogic;

		CLKFB : in std_ulogic;
		CLKIN : in std_ulogic;
		PSCLK : in std_ulogic;
		PSEN : in std_ulogic;
		PSINCDEC : in std_ulogic;
		RST : in std_ulogic
     );
end DCM_PS;

-- Architecture body --

architecture DCM_PS_V of DCM_PS is

signal  OPEN_DRDY : std_ulogic;

begin

  INITPROC : process
    variable Message : line;    
  begin


    if ((CLK_FEEDBACK = "none") or (CLK_FEEDBACK = "NONE")) then
      Write ( Message, string'(" Attribute CLK_FEEDBACK is set to value NONE."));
      Write ( Message, string'(" In this mode, the output ports CLK0, CLK180, CLK270, CLK2X, CLK2X180, CLK90 and  CLKDV can have any random phase relation w.r.t. input port CLKIN"));
      Write ( Message, '.' & LF );
      assert false report Message.all severity note;
      DEALLOCATE (Message);            
    elsif ((CLK_FEEDBACK = "1x") or (CLK_FEEDBACK = "1X")) then
--    elsif ((CLK_FEEDBACK = "2x") or (CLK_FEEDBACK = "2X")) then
--      clkfb_type <= 2;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLK_FEEDBACK",
         EntityName => "DCM_PS",
--         InstanceName => InstancePath,
         GenericValue => CLK_FEEDBACK,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are NONE or 1X",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;    
    wait;
  end process INITPROC;
  
-- DCM_ADV Instatiation (port map, generic map)
DCM_ADV_inst : DCM_ADV
	generic map (
		CLKDV_DIVIDE => CLKDV_DIVIDE,
		CLKFX_DIVIDE => CLKFX_DIVIDE,
		CLKFX_MULTIPLY => CLKFX_MULTIPLY,
		CLKIN_DIVIDE_BY_2 => CLKIN_DIVIDE_BY_2,
		CLKIN_PERIOD => CLKIN_PERIOD,
		CLKOUT_PHASE_SHIFT => CLKOUT_PHASE_SHIFT,
		CLK_FEEDBACK => CLK_FEEDBACK,
                DCM_AUTOCALIBRATION => DCM_AUTOCALIBRATION,
		DCM_PERFORMANCE_MODE => DCM_PERFORMANCE_MODE,
		DESKEW_ADJUST => DESKEW_ADJUST,
		DFS_FREQUENCY_MODE => DFS_FREQUENCY_MODE,
		DLL_FREQUENCY_MODE => DLL_FREQUENCY_MODE,
		DUTY_CYCLE_CORRECTION => DUTY_CYCLE_CORRECTION,
                FACTORY_JF => FACTORY_JF,
		PHASE_SHIFT => PHASE_SHIFT,
		STARTUP_WAIT => STARTUP_WAIT
)
port map (
  		DRDY => OPEN_DRDY,
		CLKIN => CLKIN,
		CLKFB => CLKFB,
		RST => RST,
		PSINCDEC => PSINCDEC,
		PSEN => PSEN,
		PSCLK => PSCLK,                

		CLK0 => CLK0,
		CLK90 => CLK90,
		CLK180 => CLK180,
		CLK270 => CLK270,
		CLK2X => CLK2X,
		CLK2X180 => CLK2X180,
		CLKDV => CLKDV,
		CLKFX => CLKFX,
		CLKFX180 => CLKFX180,
		LOCKED => LOCKED,
		PSDONE => PSDONE,
		DO => DO
);

end DCM_PS_V;
