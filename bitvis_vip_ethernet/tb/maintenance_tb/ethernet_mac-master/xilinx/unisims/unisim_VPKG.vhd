-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisim_VPKG.vhd,v 1.19 2010/12/08 18:25:32 fphillip Exp $
----------------------------------------------------------------
-- 
-- Created by the Synopsys Library Compiler v3.4b
-- FILENAME     :    unisim_VPKG.vhd
-- FILE CONTENTS:    VITAL Table, hex-to-std_logic_vector conversion function,
--                   and adderess decoder function Package
-- DATE CREATED :    Thu Sep 12 14:45:01 1996
-- 
-- LIBRARY      :    UNISIM (UNIfied SIMulation)
-- DATE ENTERED :    Fri Jun  21 11:34:03 1996
-- REVISION     :    1.0.2
-- TECHNOLOGY   :    FPGA
-- TIME SCALE   :    1 NS
-- LOGIC SYSTEM :    IEEE-1164
-- NOTES        :    
-- HISTORY      :    1.  First created by runnning Synopsys LC V3.4b. DP, 09/12/96.
--                   2.  Changed package name from VTABLES to VPKG. DP, 09/13/96.
--                   3.  Added RAM_O_tab and RAMS_O_tab state tables. DP, 09/13/96.
--                   4.  Added HEX_TO_SLV16, HEX_TO_SLV32, DECODE_ADDR4, and
--                       DECODE_ADDR5 function, and XilinxIDENT procedure declarations.
--                       DP, 09/13/96.
--                   5.  Added package body with above functions and procedure.
--                       DP, 09/13/96.
--                   6.  Changed file name from XUP_VPKG.vhd to unisim_VPKG.vhd.
--                       DP, 09/25/97.
--                   7.  Added FD_Q_tab and FDE_Q_tab. DP, 09/25/97.
--                   8.  Removed XilinxIDENT. DP, 09/26/97.
--                   9.  Added VITAL state tables for Virtex flip flops and
--                       latches. DP, 10/28/97.
--                   10. Added ADDR_IS_VALID and SLV_TO_STR functions and SET_MEM_TO_X,
--                       ADDR_OVERLAP and COLLISION procedures for Virtex block
--                       RAMs. DP, 10/28/97.
--                   11. Fixed bug in ADDR_OVERLAP procedure. DP, 04/04/98.
--		     12. Added SLV_TO_INT function. SG, 09/15/98
--		     13. Added "IN" in SLV_TO_INT function decl.SG, 12/09/98.
--		     14. Fixed a bug in SLV_TO_STR function. SG, 01/06/99.
--                   15. Added type_std_logic_vector1,2,3,4 -- CR 225004 -- FP, 02/08/06
--                   16. Changed type_std_logic_vector1,2,3,4 to integer range instead of natural -- CR 520723 -- FP, 05/08/09
--                   17. Removed "synopsys translate_off/on" -- CR 585467 -- 12/08/10
----------------------------------------------------------------
LIBRARY STD;
USE STD.TEXTIO.ALL;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.VITAL_Timing.all;
use IEEE.VITAL_Primitives.all;

package VPKG is
  type OtherGenericsType is record    
                              BooleanVal : BOOLEAN;
                              IntegerVal : INTEGER;
                            end record;
  type memory_collision_type is (Read_A_Write_B,
                                 Read_B_Write_A,
                                 Write_A_Write_B);

  type std_logic_vector1 is array (integer range <>) of std_logic;
  type std_logic_vector2 is array (integer range <>, integer range <>) of std_logic;
  type std_logic_vector3 is array (integer range <>, integer range <>, integer range <>) of std_logic;
  type std_logic_vector4 is array (integer range <>, integer range <>, integer range <>, integer range <>) of std_logic;
 
  
  CONSTANT L : VitalTableSymbolType := '0';
  CONSTANT H : VitalTableSymbolType := '1';
  CONSTANT x : VitalTableSymbolType := '-';
  CONSTANT S : VitalTableSymbolType := 'S';
  CONSTANT R : VitalTableSymbolType := '/';
  CONSTANT U : VitalTableSymbolType := 'X';
  CONSTANT V : VitalTableSymbolType := 'B'; -- valid clock signal (non-rising)

  CONSTANT FD_Q_tab : VitalStateTableType := (
    ( L,  L,  H,  x,  L ),
    ( L,  H,  H,  x,  H ),
    ( H,  x,  x,  x,  S ),
    ( x,  x,  L,  x,  S ));

  CONSTANT FDC_Q_tab : VitalStateTableType := (
    ( L,  L,  H,  x,  x,  L ),
    ( L,  H,  H,  L,  x,  H ),
    ( H,  x,  x,  L,  x,  S ),
    ( x,  x,  L,  L,  x,  S ),
    ( x,  x,  x,  H,  x,  L ));

  CONSTANT FDCE_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  x,  H,  x,  x,  L ),
    ( L,  L,  x,  L,  H,  x,  x,  L ),
    ( L,  H,  H,  x,  H,  L,  x,  H ),
    ( L,  H,  x,  L,  H,  L,  x,  H ),
    ( L,  x,  L,  H,  H,  x,  x,  L ),
    ( L,  x,  H,  H,  H,  L,  x,  H ),
    ( H,  x,  x,  x,  x,  L,  x,  S ),
    ( x,  x,  x,  x,  L,  L,  x,  S ),
    ( x,  x,  x,  x,  x,  H,  x,  L ));

  CONSTANT FDCP_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  H,  x,  x,  L ),
    ( L,  H,  x,  H,  L,  x,  H ),
    ( H,  x,  L,  x,  L,  x,  S ),
    ( x,  x,  L,  L,  L,  x,  S ),
    ( x,  x,  H,  x,  L,  x,  H ),
    ( x,  x,  x,  x,  H,  x,  L ));

  CONSTANT FDCPE_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  L,  x,  H,  x,  x,  L ),
    ( L,  L,  L,  x,  L,  H,  x,  x,  L ),
    ( L,  L,  x,  L,  H,  H,  x,  x,  L ),
    ( L,  x,  H,  H,  x,  H,  L,  x,  H ),
    ( L,  x,  H,  x,  L,  H,  L,  x,  H ),
    ( L,  x,  x,  H,  H,  H,  L,  x,  H ),
    ( H,  L,  x,  x,  x,  x,  L,  x,  S ),
    ( x,  L,  x,  x,  x,  L,  L,  x,  S ),
    ( x,  H,  x,  x,  x,  x,  L,  x,  H ),
    ( x,  x,  x,  x,  x,  x,  H,  x,  L ));

  CONSTANT FDE_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  x,  H,  x,  L ),
    ( L,  L,  x,  L,  H,  x,  L ),
    ( L,  H,  H,  x,  H,  x,  H ),
    ( L,  H,  x,  L,  H,  x,  H ),
    ( L,  x,  L,  H,  H,  x,  L ),
    ( L,  x,  H,  H,  H,  x,  H ),
    ( H,  x,  x,  x,  x,  x,  S ),
    ( x,  x,  x,  x,  L,  x,  S ));

  CONSTANT FDP_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  H,  x,  L ),
    ( L,  H,  x,  H,  x,  H ),
    ( H,  x,  L,  x,  x,  S ),
    ( x,  x,  L,  L,  x,  S ),
    ( x,  x,  H,  x,  x,  H ));

  CONSTANT FDPE_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  L,  x,  H,  x,  L ),
    ( L,  L,  L,  x,  L,  H,  x,  L ),
    ( L,  L,  x,  L,  H,  H,  x,  L ),
    ( L,  x,  H,  H,  x,  H,  x,  H ),
    ( L,  x,  H,  x,  L,  H,  x,  H ),
    ( L,  x,  x,  H,  H,  H,  x,  H ),
    ( H,  L,  x,  x,  x,  x,  x,  S ),
    ( x,  L,  x,  x,  x,  L,  x,  S ),
    ( x,  H,  x,  x,  x,  x,  x,  H ));

  CONSTANT FDR_Q_tab : VitalStateTableType := (
    ( L,  L,  x,  H,  x,  L ),
    ( L,  H,  L,  H,  x,  H ),
    ( L,  x,  H,  H,  x,  L ),
    ( H,  x,  x,  x,  x,  S ),
    ( x,  x,  x,  L,  x,  S ));

  CONSTANT FDRE_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  x,  x,  H,  x,  L ),
    ( L,  L,  x,  L,  x,  H,  x,  L ),
    ( L,  H,  H,  x,  L,  H,  x,  H ),
    ( L,  H,  x,  L,  L,  H,  x,  H ),
    ( L,  x,  L,  H,  x,  H,  x,  L ),
    ( L,  x,  H,  H,  L,  H,  x,  H ),
    ( L,  x,  x,  x,  H,  H,  x,  L ),
    ( H,  x,  x,  x,  x,  x,  x,  S ),
    ( x,  x,  x,  x,  x,  L,  x,  S ));

  CONSTANT FDRS_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  x,  H,  x,  L ),
    ( L,  H,  x,  L,  H,  x,  H ),
    ( L,  x,  H,  L,  H,  x,  H ),
    ( L,  x,  x,  H,  H,  x,  L ),
    ( H,  x,  x,  x,  x,  x,  S ),
    ( x,  x,  x,  x,  L,  x,  S ));

  CONSTANT FDRSE_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  L,  x,  x,  H,  x,  L ),
    ( L,  L,  L,  x,  L,  x,  H,  x,  L ),
    ( L,  L,  x,  L,  H,  x,  H,  x,  L ),
    ( L,  H,  x,  x,  x,  L,  H,  x,  H ),
    ( L,  x,  H,  H,  x,  L,  H,  x,  H ),
    ( L,  x,  H,  x,  L,  L,  H,  x,  H ),
    ( L,  x,  x,  H,  H,  L,  H,  x,  H ),
    ( L,  x,  x,  x,  x,  H,  H,  x,  L ),
    ( H,  x,  x,  x,  x,  x,  x,  x,  S ),
    ( x,  x,  x,  x,  x,  x,  L,  x,  S ));

  CONSTANT FDS_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  H,  x,  L ),
    ( L,  H,  x,  H,  x,  H ),
    ( L,  x,  H,  H,  x,  H ),
    ( H,  x,  x,  x,  x,  S ),
    ( x,  x,  x,  L,  x,  S ));

  CONSTANT FDSE_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  L,  x,  H,  x,  L ),
    ( L,  L,  L,  x,  L,  H,  x,  L ),
    ( L,  L,  x,  L,  H,  H,  x,  L ),
    ( L,  H,  x,  x,  x,  H,  x,  H ),
    ( L,  x,  H,  H,  x,  H,  x,  H ),
    ( L,  x,  H,  x,  L,  H,  x,  H ),
    ( L,  x,  x,  H,  H,  H,  x,  H ),
    ( H,  x,  x,  x,  x,  x,  x,  S ),
    ( x,  x,  x,  x,  x,  L,  x,  S ));

  CONSTANT FDPC_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  H,  x,  x,  L ),
    ( L,  H,  x,  x,  L,  x,  S ),
    ( L,  x,  x,  L,  L,  x,  S ),
    ( L,  x,  x,  x,  H,  x,  L ),
    ( H,  x,  x,  x,  x,  x,  H ),
    ( x,  L,  H,  H,  L,  x,  H ));

  CONSTANT FTC_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  H,  x,  x,  L ),
    ( L,  L,  H,  H,  L,  x,  H ),
    ( L,  H,  L,  H,  L,  x,  H ),
    ( L,  H,  H,  H,  x,  x,  L ),
    ( H,  x,  x,  x,  L,  x,  S ),
    ( x,  x,  x,  L,  L,  x,  S ),
    ( x,  x,  x,  x,  H,  x,  L ));

  CONSTANT FTP_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  L,  H,  x,  L ),
    ( L,  L,  H,  H,  H,  x,  L ),
    ( L,  x,  L,  H,  H,  x,  H ),
    ( L,  x,  H,  L,  H,  x,  H ),
    ( H,  L,  x,  x,  x,  x,  S ),
    ( x,  L,  x,  x,  L,  x,  S ),
    ( x,  H,  x,  x,  x,  x,  H ));

  CONSTANT FTCP_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  L,  H,  x,  x,  L ),
    ( L,  L,  H,  H,  H,  x,  x,  L ),
    ( L,  x,  L,  H,  H,  L,  x,  H ),
    ( L,  x,  H,  L,  H,  L,  x,  H ),
    ( H,  L,  x,  x,  x,  L,  x,  S ),
    ( x,  L,  x,  x,  L,  L,  x,  S ),
    ( x,  H,  x,  x,  x,  L,  x,  H ),
    ( x,  x,  x,  x,  x,  H,  x,  L ));
  
  CONSTANT IFD_Q_tab : VitalStateTableType := (
    ( L,  L,  H,  x,  L ),
    ( L,  H,  H,  x,  H ),
    ( H,  x,  x,  x,  S ),
    ( x,  x,  L,  x,  S ));

  CONSTANT IFDX_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  x,  H,  x,  L ),
    ( L,  L,  x,  L,  H,  x,  L ),
    ( L,  H,  H,  x,  H,  x,  H ),
    ( L,  H,  x,  L,  H,  x,  H ),
    ( L,  x,  L,  H,  H,  x,  L ),
    ( L,  x,  H,  H,  H,  x,  H ),
    ( H,  x,  x,  x,  x,  x,  S ),
    ( x,  x,  x,  x,  L,  x,  S ));

  CONSTANT ILD_Q_tab : VitalStateTableType := (
    ( L,  H,  x,  L ),
    ( H,  H,  x,  H ),
    ( x,  L,  x,  S ));

  CONSTANT ILDI_1_Q_tab : VitalStateTableType := (
    ( L,  L,  x,  L ),
    ( L,  H,  x,  H ),
    ( H,  x,  x,  S ));

  CONSTANT ILFFX_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  x,  H,  H,  x,  L ),
    ( L,  L,  x,  H,  H,  H,  x,  L ),
    ( L,  H,  H,  x,  H,  H,  x,  H ),
    ( L,  H,  x,  H,  H,  H,  x,  H ),
    ( L,  x,  L,  L,  H,  H,  x,  L ),
    ( L,  x,  H,  L,  H,  H,  x,  H ),
    ( H,  x,  x,  x,  x,  x,  x,  S ),
    ( x,  x,  x,  x,  L,  x,  x,  S ),
    ( x,  x,  x,  x,  x,  L,  x,  S ));

  CONSTANT ILFLX_Q_tab : VitalStateTableType := (
    ( L,  L,  x,  H,  H,  x,  L ),
    ( L,  x,  H,  H,  H,  x,  L ),
    ( H,  H,  x,  H,  H,  x,  H ),
    ( H,  x,  H,  H,  H,  x,  H ),
    ( x,  L,  L,  H,  H,  x,  L ),
    ( x,  H,  L,  H,  H,  x,  H ),
    ( x,  x,  x,  L,  x,  x,  S ),
    ( x,  x,  x,  x,  L,  x,  S ));

  CONSTANT ILFLXI_1_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  x,  H,  x,  L ),
    ( L,  L,  x,  H,  H,  x,  L ),
    ( L,  H,  H,  x,  H,  x,  H ),
    ( L,  H,  x,  H,  H,  x,  H ),
    ( L,  x,  L,  L,  H,  x,  L ),
    ( L,  x,  H,  L,  H,  x,  H ),
    ( H,  x,  x,  x,  x,  x,  S ),
    ( x,  x,  x,  x,  L,  x,  S ));

  CONSTANT ILFFXI_F_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  x,  H,  H,  x,  L ),
    ( L,  L,  x,  H,  H,  H,  x,  L ),
    ( L,  H,  H,  x,  H,  H,  x,  H ),
    ( L,  H,  x,  H,  H,  H,  x,  H ),
    ( L,  x,  L,  L,  H,  H,  x,  L ),
    ( L,  x,  H,  L,  H,  H,  x,  H ),
    ( H,  x,  x,  x,  x,  x,  x,  S ),
    ( x,  x,  x,  x,  L,  x,  x,  S ),
    ( x,  x,  x,  x,  x,  L,  x,  S ));

  CONSTANT ILFFXI_F_INT_tab : VitalStateTableType := (
    ( L,  L,  x,  L ),
    ( L,  H,  x,  H ),
    ( H,  x,  x,  S ));

  CONSTANT ILFLXI_1F_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  x,  H,  x,  L ),
    ( L,  L,  x,  H,  H,  x,  L ),
    ( L,  H,  H,  x,  H,  x,  H ),
    ( L,  H,  x,  H,  H,  x,  H ),
    ( L,  x,  L,  L,  H,  x,  L ),
    ( L,  x,  H,  L,  H,  x,  H ),
    ( H,  x,  x,  x,  x,  x,  S ),
    ( x,  x,  x,  x,  L,  x,  S ));

  CONSTANT ILFLX_F_Q_tab : VitalStateTableType := (
    ( L,  L,  x,  H,  H,  x,  L ),
    ( L,  x,  H,  H,  H,  x,  L ),
    ( H,  H,  x,  H,  H,  x,  H ),
    ( H,  x,  H,  H,  H,  x,  H ),
    ( x,  L,  L,  H,  H,  x,  L ),
    ( x,  H,  L,  H,  H,  x,  H ),
    ( x,  x,  x,  L,  x,  x,  S ),
    ( x,  x,  x,  x,  L,  x,  S ));

  CONSTANT LDC_Q_tab : VitalStateTableType := (
    ( L,  H,  x,  x,  L ),
    ( H,  H,  L,  x,  H ),
    ( x,  L,  L,  x,  S ),
    ( x,  x,  H,  x,  L ));

  CONSTANT LDCE_Q_tab : VitalStateTableType := (
    ( L,  H,  H,  x,  x,  L ),
    ( H,  H,  H,  L,  x,  H ),
    ( x,  L,  x,  L,  x,  S ),
    ( x,  x,  L,  L,  x,  S ),
    ( x,  x,  x,  H,  x,  L ));

  CONSTANT LDCP_Q_tab : VitalStateTableType := (
    ( L,  L,  H,  x,  x,  L ),
    ( H,  x,  H,  L,  x,  H ),
    ( x,  L,  L,  L,  x,  S ),
    ( x,  H,  x,  L,  x,  H ),
    ( x,  x,  x,  H,  x,  L ));

  CONSTANT LDCPE_Q_tab : VitalStateTableType := (
    ( L,  L,  H,  H,  x,  x,  L ),
    ( H,  x,  H,  H,  L,  x,  H ),
    ( x,  L,  L,  x,  L,  x,  S ),
    ( x,  L,  x,  L,  L,  x,  S ),
    ( x,  H,  x,  x,  L,  x,  H ),
    ( x,  x,  x,  x,  H,  x,  L ));

  CONSTANT LDCP_1_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  x,  x,  L ),
    ( L,  H,  x,  L,  x,  H ),
    ( H,  x,  L,  L,  x,  S ),
    ( x,  x,  H,  L,  x,  H ),
    ( x,  x,  x,  H,  x,  L ));

  CONSTANT LDC_1_Q_tab : VitalStateTableType := (
    ( L,  L,  x,  x,  L ),
    ( L,  H,  L,  x,  H ),
    ( H,  x,  L,  x,  S ),
    ( x,  x,  H,  x,  L ));

  CONSTANT LDE_Q_tab : VitalStateTableType := (
    ( L,  H,  H,  x,  L ),
    ( H,  H,  H,  x,  H ),
    ( x,  L,  x,  x,  S ),
    ( x,  x,  L,  x,  S ));

  CONSTANT LDP_Q_tab : VitalStateTableType := (
    ( L,  L,  H,  x,  L ),
    ( H,  x,  H,  x,  H ),
    ( x,  L,  L,  x,  S ),
    ( x,  H,  x,  x,  H ));

  CONSTANT LDPE_Q_tab : VitalStateTableType := (
    ( L,  L,  H,  H,  x,  L ),
    ( H,  x,  H,  H,  x,  H ),
    ( x,  L,  L,  x,  x,  S ),
    ( x,  L,  x,  L,  x,  S ),
    ( x,  H,  x,  x,  x,  H ));

  CONSTANT LDP_1_Q_tab : VitalStateTableType := (
    ( L,  L,  L,  x,  L ),
    ( L,  H,  x,  x,  H ),
    ( H,  x,  L,  x,  S ),
    ( x,  x,  H,  x,  H ));

  CONSTANT RAM_O_tab : VitalStateTableType := (
    ( L,  H,  x,  L ),
    ( H,  H,  x,  H ),
    ( x,  L,  x,  S ));
  
  CONSTANT RAMS_O_tab : VitalStateTableType := (
    ( L,  L,  L,  x,  H,  x,  L ),
    ( L,  L,  x,  L,  H,  x,  L ),
    ( L,  H,  H,  x,  H,  x,  H ),
    ( L,  H,  x,  L,  H,  x,  H ),
    ( L,  x,  L,  H,  H,  x,  L ),
    ( L,  x,  H,  H,  H,  x,  H ),
    ( H,  x,  x,  x,  x,  x,  S ),
    ( x,  x,  x,  x,  L,  x,  S ));

  CONSTANT RAMS_O_tab_1 : VitalStateTableType := (
    ( H,  L,  L,  x,  L,  x,  L ),
    ( H,  L,  x,  L,  L,  x,  L ),
    ( H,  H,  H,  x,  L,  x,  H ),
    ( H,  H,  x,  L,  L,  x,  H ),
    ( H,  x,  L,  H,  L,  x,  L ),
    ( H,  x,  H,  H,  L,  x,  H ),
    ( L,  x,  x,  x,  x,  x,  S ),
    ( x,  x,  x,  x,  H,  x,  S ));
  


-------------------------------------------------------------------------------
-- COOLRUNNER STUFF
-------------------------------------------------------------------------------

  CONSTANT FDD_Q_tab : VitalStateTableType := (
    ( L,  L,  H,  x,  L ),
    ( L,  H,  H,  x,  H ),
    ( H,  L,  L,  x,  L ),
    ( H,  H,  L,  x,  H ),
    ( H,  x,  x,  x,  S ),
    ( x,  x,  L,  x,  S ));
  
  CONSTANT FDDC_Q_tab : VitalStateTableType := (
    ( L,  L,  H,  x,  x,  L ),
    ( L,  H,  H,  L,  x,  H ),
    ( H,  L,  L,  x,  x,  L ),
    ( H,  H,  L,  L,  x,  H ),
    ( H,  x,  x,  L,  x,  S ),
    ( x,  x,  L,  L,  x,  S ),
    ( x,  x,  x,  H,  x,  L ));

  CONSTANT FDDCE_Q_tab : VitalStateTableType := (
-- C_del  Q_   D  CE C_ipd CLR state Q
    ( L,  L,  L,  x,  H,  x,  x,  L ),
    ( L,  L,  x,  L,  H,  x,  x,  L ),
    ( L,  H,  H,  x,  H,  L,  x,  H ),
    ( L,  H,  x,  L,  H,  L,  x,  H ),
    ( L,  x,  L,  H,  H,  x,  x,  L ),
    ( L,  x,  H,  H,  H,  L,  x,  H ),
-- Duplicate of 2 lines above for falling edge
    ( H,  x,  L,  H,  L,  x,  x,  L ),
    ( H,  x,  H,  H,  L,  L,  x,  H ),
    ( H,  x,  x,  x,  x,  L,  x,  S ),
    ( x,  x,  x,  x,  L,  L,  x,  S ),
    ( x,  x,  x,  x,  x,  H,  x,  L ));

  CONSTANT FDDCP_Q_tab : VitalStateTableType := (
--   C_d  D  PRE C_i CLR  S   Q
    ( L,  L,  L,  H,  x,  x,  L ),
    ( L,  H,  x,  H,  L,  x,  H ),
-- 2 lines below are duplicates from 2 above for falling edge
    ( H,  L,  L,  L,  x,  x,  L ),
    ( H,  H,  x,  L,  L,  x,  H ),
    ( H,  x,  L,  x,  L,  x,  S ),
    ( x,  x,  L,  L,  L,  x,  S ),
    ( x,  x,  H,  x,  L,  x,  H ),
    ( x,  x,  x,  x,  H,  x,  L ));

  CONSTANT FDDCPE_Q_tab : VitalStateTableType := (
--   C_d PRE Qz   D  CE  C_i CLR  S   Q
    ( L,  L,  L,  L,  x,  H,  x,  x,  L ),
    ( L,  L,  L,  x,  L,  H,  x,  x,  L ),
    ( L,  L,  x,  L,  H,  H,  x,  x,  L ),
    -- Line below is dup of line above for falling edge
    ( H,  L,  x,  L,  H,  L,  x,  x,  L ),
    ( L,  x,  H,  H,  x,  H,  L,  x,  H ),
    ( L,  x,  H,  x,  L,  H,  L,  x,  H ),
    ( L,  x,  x,  H,  H,  H,  L,  x,  H ),
    -- Line below is dup of line above for falling edge
    ( H,  x,  x,  H,  H,  L,  L,  x,  H ),
    ( H,  L,  x,  x,  x,  x,  L,  x,  S ),
    ( x,  L,  x,  x,  x,  L,  L,  x,  S ),
    ( x,  H,  x,  x,  x,  x,  L,  x,  H ),
    ( x,  x,  x,  x,  x,  x,  H,  x,  L ));


  CONSTANT FDDP_Q_tab : VitalStateTableType := (
--   C_d  D  PRE  C_i State Q    
    ( L,  L,  L,  H,  x,  L ),
    ( L,  H,  x,  H,  x,  H ),
-- Duplicate 2 lines above for falling edge
    ( H,  L,  L,  L,  x,  L ),
    ( H,  H,  x,  L,  x,  H ),
    ( H,  x,  L,  x,  x,  S ),
    ( x,  x,  L,  L,  x,  S ),
    ( x,  x,  H,  x,  x,  H ));

  CONSTANT FDDPE_Q_tab : VitalStateTableType := (
--  C_d  PRE Qz   D  CE  C_i  S   Q
    ( L,  L,  L,  L,  x,  H,  x,  L ),
    ( L,  L,  L,  x,  L,  H,  x,  L ),
    ( L,  L,  x,  L,  H,  H,  x,  L ),
-- Line below is duplicate from above for falling edge
    ( H,  L,  x,  L,  H,  L,  x,  L ),
    ( L,  x,  H,  H,  x,  H,  x,  H ),
    ( L,  x,  H,  x,  L,  H,  x,  H ),
    ( L,  x,  x,  H,  H,  H,  x,  H ),
-- Line below is duplicate from above for falling edge
    ( H,  x,  x,  H,  H,  L,  x,  H ),
    ( H,  L,  x,  x,  x,  x,  x,  S ),
    ( x,  L,  x,  x,  x,  L,  x,  S ),
    ( x,  H,  x,  x,  x,  x,  x,  H ));


  ---------------------------------------------------------------------------
  -- Function HEX_TO_SLV16 converts a hexadecimal string to std_logic_vector
  -- of size 15 downto 0.
  ---------------------------------------------------------------------------
  function HEX_TO_SLV16 (
    INIT : in string(4 downto 1)
    ) return std_logic_vector;
  
  ---------------------------------------------------------------------------
  -- Function HEX_TO_SLV32 converts a hexadecimal string to std_logic_vector
  -- of size 31 downto 0.
  ---------------------------------------------------------------------------
  function HEX_TO_SLV32 (
    INIT : in string(8 downto 1)
    ) return std_logic_vector;
  
  ---------------------------------------------------------------------------
  -- Function DECODE_ADDR4 decodes a 4 bit address into an integer ranging
  -- from 0 to 16.
  ---------------------------------------------------------------------------
  function DECODE_ADDR4 (
    ADDRESS : in std_logic_vector(3 downto 0)
    ) return integer;
  
  ---------------------------------------------------------------------------
  -- Function DECODE_ADDR5 decodes a 5 bit address into an integer ranging
  -- from 0 to 32.
  ---------------------------------------------------------------------------
  function DECODE_ADDR5 (
    ADDRESS : in std_logic_vector(4 downto 0)
    ) return integer;
  
  ---------------------------------------------------------------------------
  -- Function SLV_TO_INT converts standard logic vector into an integer
  ---------------------------------------------------------------------------
  function SLV_TO_INT (
    SLV : in std_logic_vector
    ) return integer;

  ---------------------------------------------------------------------------
  -- Function ADDR_IS_VALID checks for the validity of the argument. A FALSE
  -- is returned if any argument bit is other than a '0' or '1'.
  ---------------------------------------------------------------------------
  function ADDR_IS_VALID (
    SLV : in std_logic_vector
    ) return boolean;

  ---------------------------------------------------------------------------
  -- Function SLV_TO_STR returns a string version of the std_logic_vector
  -- argument.
  ---------------------------------------------------------------------------
  function SLV_TO_STR (
    SLV : in std_logic_vector
    ) return string;

  ---------------------------------------------------------------------------
  -- Function SLV_TO_HEX returns a string version of the std_logic_vector
  -- argument.
  ---------------------------------------------------------------------------
  function SLV_TO_HEX (
    SLV : in std_logic_vector;
    string_length : in integer    
    ) return string;  

  ---------------------------------------------------------------------------
  -- Procedure SET_MEM_TO_X issues an "invalid address" warning and sets the
  -- contents of the argument MEM to 'X'.
  ---------------------------------------------------------------------------
  procedure SET_MEM_TO_X (
    ADDRESS : in std_logic_vector;
    MEM : inout std_logic_vector
    );

  ---------------------------------------------------------------------------
  -- Procedure ADDR_OVERLAP determines if there is overlap between the data
  -- addressed by ports A and B of a dual port RAM. If there is overlap, the
  -- argument OVERLAP is set to TRUE, and the lower and upper indices of the 
  -- overlap bits in the array used to model the RAM, as well as in the RAM
  -- A and B output ports are determined.
  ---------------------------------------------------------------------------
  procedure ADDR_OVERLAP (
    ADDRESS_A, ADDRESS_B, DAW, DBW : in integer;
    OVERLAP : out boolean;
    OVRLAP_LSB, OVRLAP_MSB, DOA_OV_LSB, 
    DOA_OV_MSB, DOB_OV_LSB, DOB_OV_MSB : out integer
    );

  ---------------------------------------------------------------------------
  -- Procedure COLLISION issues either a "WRITE COLLISION detected" error or
  -- a warning that an attempt was made to read some or all of the bits
  -- addressed by one port of a dual port RAM while writing to some or all
  -- of the bits from the other port. In case of write collision, some or all
  -- of the bits addressed by the port at which the collision is detected are
  -- set to 'X'.
  ---------------------------------------------------------------------------
  procedure COLLISION (
    ADDRESS : in std_logic_vector; 
    LSB, MSB : in integer;
    MODE, PORT1, PORT2, InstancePath : in string;
    MEM : inout std_logic_vector
    );

  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";        
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN STRING := "";
    Constant Unit : IN STRING := "";
    Constant ExpectedValueMsg : IN STRING := "";
    Constant ExpectedGenericValue : IN STRING := "";
    CONSTANT TailMsg      : IN STRING;                    

    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING
    
    );

  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";        
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN INTEGER;
    Constant Unit : IN STRING := "";
    Constant ExpectedValueMsg : IN STRING := "";
    Constant ExpectedGenericValue : IN INTEGER;
    CONSTANT TailMsg      : IN STRING;                    

    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING
    
    );

  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";        
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN BOOLEAN;
    Constant Unit : IN STRING := "";
    Constant ExpectedValueMsg : IN STRING := "";
    Constant ExpectedGenericValue : IN STRING := "";
    CONSTANT TailMsg      : IN STRING;                    

    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING
    
    );   

  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";        
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN INTEGER;
    CONSTANT Unit : IN STRING := "";
    CONSTANT ExpectedValueMsg : IN STRING := "";
    CONSTANT ExpectedGenericValue : IN STRING := "";
    CONSTANT TailMsg      : IN STRING;                    
    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING
    );

  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";        
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN REAL;
    CONSTANT Unit : IN STRING := "";
    CONSTANT ExpectedValueMsg : IN STRING := "";
    CONSTANT ExpectedGenericValue : IN STRING := "";
    CONSTANT TailMsg      : IN STRING;                    

    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING
    
    );

  PROCEDURE Memory_Collision_Msg (
    CONSTANT HeaderMsg      : IN STRING := " Memory Collision Error on ";        
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    constant collision_type : in memory_collision_type;
    constant address_a : in std_logic_vector; 
    constant address_b : in std_logic_vector; 
    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := ERROR
    
    
    );

  
  procedure detect_resolution (
    constant model_name : in string
    );    
  
end VPKG;

-----------------------------------------------------------------------------



package body VPKG is
  
  ---------------------------------------------------------------------------
  -- Function SLV_TO_INT converts a std_logic_vector TO INTEGER
  ---------------------------------------------------------------------------
  function SLV_TO_INT(SLV: in std_logic_vector
                      ) return integer is

    variable int : integer;
  begin
    int := 0;
    for i in SLV'high downto SLV'low loop
      int := int * 2;
      if SLV(i) = '1' then
        int := int + 1;
      end if;
    end loop;
    return int;
  end;

  ---------------------------------------------------------------------------
  -- Function HEX_TO_SLV16 converts a hexadecimal string to std_logic_vector
  -- of size 15 downto 0.
  ---------------------------------------------------------------------------
  function HEX_TO_SLV16 (
    INIT : in string(4 downto 1)
    ) return std_logic_vector is
    
    variable SLV_16 : std_logic_vector(15 downto 0);
    
  begin
    for I in 0 to 3 loop
      case INIT(I+1) is
        when '0' =>
          SLV_16(I*4+3 downto I*4) := "0000";
        when '1' =>
          SLV_16(I*4+3 downto I*4) := "0001";
        when '2' =>
          SLV_16(I*4+3 downto I*4) := "0010";
        when '3' =>
          SLV_16(I*4+3 downto I*4) := "0011";
        when '4' =>
          SLV_16(I*4+3 downto I*4) := "0100";
        when '5' =>
          SLV_16(I*4+3 downto I*4) := "0101";
        when '6' =>
          SLV_16(I*4+3 downto I*4) := "0110";
        when '7' =>
          SLV_16(I*4+3 downto I*4) := "0111";
        when '8' =>
          SLV_16(I*4+3 downto I*4) := "1000";
        when '9' =>
          SLV_16(I*4+3 downto I*4) := "1001";
        when 'a' | 'A' =>
          SLV_16(I*4+3 downto I*4) := "1010";
        when 'b' | 'B' =>
          SLV_16(I*4+3 downto I*4) := "1011";
        when 'c' | 'C' =>
          SLV_16(I*4+3 downto I*4) := "1100";
        when 'd' | 'D' =>
          SLV_16(I*4+3 downto I*4) := "1101";
        when 'e' | 'E' =>
          SLV_16(I*4+3 downto I*4) := "1110";
        when 'f' | 'F' =>
          SLV_16(I*4+3 downto I*4) := "1111";
        when others =>
          assert false
            report "WARNING: Unknown Hex digit in INIT: "&INIT(I+1)
            severity warning;
          SLV_16(I*4+3 downto I*4)   := "XXXX";
      end case;
    end loop;
    return SLV_16;
  end HEX_TO_SLV16;

  ---------------------------------------------------------------------------
  -- Function HEX_TO_SLV32 converts a hexadecimal string to std_logic_vector
  -- of size 31 downto 0.
  ---------------------------------------------------------------------------
  function HEX_TO_SLV32 (
    INIT : in string(8 downto 1)
    ) return std_logic_vector is
    
    variable SLV_32 : std_logic_vector(31 downto 0);
    
  begin
    for I in 0 to 7 loop
      case INIT(I+1) is
        when '0' =>
          SLV_32(I*4+3 downto I*4) := "0000";
        when '1' =>
          SLV_32(I*4+3 downto I*4) := "0001";
        when '2' =>
          SLV_32(I*4+3 downto I*4) := "0010";
        when '3' =>
          SLV_32(I*4+3 downto I*4) := "0011";
        when '4' =>
          SLV_32(I*4+3 downto I*4) := "0100";
        when '5' =>
          SLV_32(I*4+3 downto I*4) := "0101";
        when '6' =>
          SLV_32(I*4+3 downto I*4) := "0110";
        when '7' =>
          SLV_32(I*4+3 downto I*4) := "0111";
        when '8' =>
          SLV_32(I*4+3 downto I*4) := "1000";
        when '9' =>
          SLV_32(I*4+3 downto I*4) := "1001";
        when 'a' | 'A' =>
          SLV_32(I*4+3 downto I*4) := "1010";
        when 'b' | 'B' =>
          SLV_32(I*4+3 downto I*4) := "1011";
        when 'c' | 'C' =>
          SLV_32(I*4+3 downto I*4) := "1100";
        when 'd' | 'D' =>
          SLV_32(I*4+3 downto I*4) := "1101";
        when 'e' | 'E' =>
          SLV_32(I*4+3 downto I*4) := "1110";
        when 'f' | 'F' =>
          SLV_32(I*4+3 downto I*4) := "1111";
        when others =>
          assert false
            report "WARNING: Unknown Hex digit in INIT: "&INIT(I+1)
            severity warning;
          SLV_32(I*4+3 downto I*4)   := "XXXX";
      end case;
    end loop;
    return SLV_32;
  end HEX_TO_SLV32;

  ---------------------------------------------------------------------------
  -- Function DECODE_ADDR4 decodes a 4 bit address into an integer ranging
  -- from 0 to 16.
  ---------------------------------------------------------------------------
  function DECODE_ADDR4 (
    ADDRESS : in std_logic_vector(3 downto 0)
    ) return integer is
    
    variable I : integer;
    
  begin
    case ADDRESS is
      when "0000"  =>  I := 0;
      when "0001"  =>  I := 1;
      when "0010"  =>  I := 2;
      when "0011"  =>  I := 3;
      when "0100"  =>  I := 4;
      when "0101"  =>  I := 5;
      when "0110"  =>  I := 6;
      when "0111"  =>  I := 7;
      when "1000"  =>  I := 8;
      when "1001"  =>  I := 9;
      when "1010"  =>  I := 10;
      when "1011"  =>  I := 11;
      when "1100"  =>  I := 12;
      when "1101"  =>  I := 13;
      when "1110"  =>  I := 14;
      when "1111"  =>  I := 15;
      when others  =>  I := 16;
    end case;
    return I;
  end DECODE_ADDR4;

  ---------------------------------------------------------------------------
  -- Function DECODE_ADDR5 decodes a 5 bit address into an integer ranging
  -- from 0 to 32.
  ---------------------------------------------------------------------------
  function DECODE_ADDR5 (
    ADDRESS : in std_logic_vector(4 downto 0)
    ) return integer is
    
    variable I : integer;
    
  begin
    case ADDRESS is
      when "00000"  =>  I := 0;
      when "00001"  =>  I := 1;
      when "00010"  =>  I := 2;
      when "00011"  =>  I := 3;
      when "00100"  =>  I := 4;
      when "00101"  =>  I := 5;
      when "00110"  =>  I := 6;
      when "00111"  =>  I := 7;
      when "01000"  =>  I := 8;
      when "01001"  =>  I := 9;
      when "01010"  =>  I := 10;
      when "01011"  =>  I := 11;
      when "01100"  =>  I := 12;
      when "01101"  =>  I := 13;
      when "01110"  =>  I := 14;
      when "01111"  =>  I := 15;
      when "10000"  =>  I := 16;
      when "10001"  =>  I := 17;
      when "10010"  =>  I := 18;
      when "10011"  =>  I := 19;
      when "10100"  =>  I := 20;
      when "10101"  =>  I := 21;
      when "10110"  =>  I := 22;
      when "10111"  =>  I := 23;
      when "11000"  =>  I := 24;
      when "11001"  =>  I := 25;
      when "11010"  =>  I := 26;
      when "11011"  =>  I := 27;
      when "11100"  =>  I := 28;
      when "11101"  =>  I := 29;
      when "11110"  =>  I := 30;
      when "11111"  =>  I := 31;
      when others   =>  I := 32;
    end case;
    return I;
  end DECODE_ADDR5;

  ---------------------------------------------------------------------------
  -- Function ADDR_IS_VALID checks for the validity of the argument. A FALSE
  -- is returned if any argument bit is other than a '0' or '1'.
  ---------------------------------------------------------------------------
  function ADDR_IS_VALID (
    SLV : in std_logic_vector
    ) return boolean is

    variable IS_VALID : boolean := TRUE;

  begin
    for I in SLV'high downto SLV'low loop
      if (SLV(I) /= '0' AND SLV(I) /= '1') then
        IS_VALID := FALSE;
      end if;
    end loop;
    return IS_VALID;
  end ADDR_IS_VALID;

  ---------------------------------------------------------------------------
  -- Function SLV_TO_STR returns a string version of the std_logic_vector
  -- argument.
  ---------------------------------------------------------------------------
  function SLV_TO_STR (
    SLV : in std_logic_vector
    ) return string is

    variable j : integer := SLV'length;
    variable STR : string (SLV'length downto 1);
    

  begin
    for I in SLV'high downto SLV'low loop
      case SLV(I) is
        when '0' => STR(J) := '0';
        when '1' => STR(J) := '1';
        when 'X' => STR(J) := 'X';
        when 'U' => STR(J) := 'U';
        when others => STR(J) := 'X';
      end case;
      J := J - 1;
    end loop;
    return STR;
  end SLV_TO_STR;

  ---------------------------------------------------------------------------
  -- Function SLV_TO_HEX returns a hex string version of the std_logic_vector
  -- argument.
  ---------------------------------------------------------------------------
  function SLV_TO_HEX (
    SLV : in std_logic_vector;
    string_length : in integer
    ) return string is

    variable i : integer := 1;
    variable j : integer := 1;
    variable STR : string(string_length downto 1);
    variable nibble : std_logic_vector(3 downto 0) := "0000";
    variable full_nibble_count : integer := 0;
    variable remaining_bits : integer := 0;


  begin
    full_nibble_count := SLV'length/4;
    remaining_bits := SLV'length mod 4;
    for i in 1 to full_nibble_count loop
      nibble := SLV(((4*i) - 1) downto ((4*i) - 4));
      if (nibble = "0000")  then
        STR(j) := '0';
      elsif (nibble = "0001")  then
        STR(j) := '1';
      elsif (nibble = "0010")  then
        STR(j) := '2';
      elsif (nibble = "0011")  then
        STR(j) := '3';
      elsif (nibble = "0100")  then
        STR(j) := '4';
      elsif (nibble = "0101")  then
        STR(j) := '5';
      elsif (nibble = "0110")  then
        STR(j) := '6';
      elsif (nibble = "0111")  then
        STR(j) := '7';
      elsif (nibble = "1000")  then
        STR(j) := '8';
      elsif (nibble = "1001")  then
        STR(j) := '9';
      elsif (nibble = "1010")  then
        STR(j) := 'a';
      elsif (nibble = "1011")  then
        STR(j) := 'b';
      elsif (nibble = "1100")  then
        STR(j) := 'c';
      elsif (nibble = "1101")  then
        STR(j) := 'd';
      elsif (nibble = "1110")  then
        STR(j) := 'e';
      elsif (nibble = "1111")  then
        STR(j) := 'f';          
      end if;
      j := j + 1;
    end loop;
    
    if (remaining_bits /= 0) then
      nibble := "0000";
      nibble((remaining_bits -1) downto 0) := SLV((SLV'length -1) downto (SLV'length - remaining_bits));
      if (nibble = "0000")  then
        STR(j) := '0';
      elsif (nibble = "0001")  then
        STR(j) := '1';
      elsif (nibble = "0010")  then
        STR(j) := '2';
      elsif (nibble = "0011")  then
        STR(j) := '3';
      elsif (nibble = "0100")  then
        STR(j) := '4';
      elsif (nibble = "0101")  then
        STR(j) := '5';
      elsif (nibble = "0110")  then
        STR(j) := '6';
      elsif (nibble = "0111")  then
        STR(j) := '7';
      elsif (nibble = "1000")  then
        STR(j) := '8';
      elsif (nibble = "1001")  then
        STR(j) := '9';
      elsif (nibble = "1010")  then
        STR(j) := 'a';
      elsif (nibble = "1011")  then
        STR(j) := 'b';
      elsif (nibble = "1100")  then
        STR(j) := 'c';
      elsif (nibble = "1101")  then
        STR(j) := 'd';
      elsif (nibble = "1110")  then
        STR(j) := 'e';
      elsif (nibble = "1111")  then
        STR(j) := 'f';          
      end if;
    end if;    
    return STR;
  end SLV_TO_HEX;  
  

  ---------------------------------------------------------------------------
  -- Procedure SET_MEM_TO_X issues an "invalid address" warning and sets the
  -- contents of the argument MEM to 'X'.
  ---------------------------------------------------------------------------
  procedure SET_MEM_TO_X (ADDRESS : in std_logic_vector;
                          MEM : inout std_logic_vector
                          ) is

  begin
    assert false report
      "Invalid ADDRESS: "& SLV_TO_STR(ADDRESS) & ". Memory contents will be set to 'X'."
      severity warning;
    for I in MEM'high downto MEM'low loop
      MEM(I) := 'X';
    end loop;
  end SET_MEM_TO_X;


  ---------------------------------------------------------------------------
  -- Procedure ADDR_OVERLAP determines if there is overlap between the data
  -- addressed by ports A and B of a dual port RAM. If there is overlap, the
  -- argument OVERLAP is set to TRUE, and the lower and upper indices of the 
  -- overlap bits in the array used to model the RAM, as well as in the RAM
  -- A and B output ports are determined.
  ---------------------------------------------------------------------------
  procedure ADDR_OVERLAP (
    ADDRESS_A, ADDRESS_B, DAW, DBW : in integer;
    OVERLAP : out boolean;
    OVRLAP_LSB, OVRLAP_MSB, DOA_OV_LSB, 
    DOA_OV_MSB, DOB_OV_LSB, DOB_OV_MSB : out integer
    ) is

    variable A_LSB, A_MSB, B_LSB, B_MSB : integer;

  begin
    A_LSB := ADDRESS_A * DAW;
    A_MSB := A_LSB + DAW - 1;
    B_LSB := ADDRESS_B * DBW;
    B_MSB := B_LSB + DBW - 1;

    if (A_MSB < B_LSB OR B_MSB < A_LSB) then
      OVERLAP := FALSE;
    else
      OVERLAP := TRUE;
      if (A_LSB >= B_LSB) then
        OVRLAP_LSB := A_LSB;
        DOA_OV_LSB := 0;
        DOB_OV_LSB := A_LSB - B_LSB;
      else
        OVRLAP_LSB := B_LSB;
        DOA_OV_LSB := B_LSB - A_LSB;
        DOB_OV_LSB := 0;
      end if;
      if (A_MSB >= B_MSB) then
        OVRLAP_MSB := B_MSB;
        DOA_OV_MSB := DAW - (A_MSB - B_MSB) - 1;
        DOB_OV_MSB := DBW - 1;
      else
        OVRLAP_MSB := A_MSB;
        DOA_OV_MSB := DAW - 1;
        DOB_OV_MSB := DBW - (B_MSB - A_MSB) - 1;
      end if;
    end if;
  end ADDR_OVERLAP;

  ---------------------------------------------------------------------------
  -- Procedure COLLISION issues either a "WRITE COLLISION detected" error or
  -- a warning that an attempt was made to read some or all of the bits
  -- addressed by one port of a dual port RAM while writing to some or all
  -- of the bits from the other port. In case of write collision, some or all
  -- of the bits addressed by the port at which the collision is detected are
  -- set to 'X'.
  ---------------------------------------------------------------------------
  procedure COLLISION (
    ADDRESS : in std_logic_vector; 
    LSB, MSB : in integer;
    MODE, PORT1, PORT2, InstancePath : in string;
    MEM : inout std_logic_vector
    ) is

  begin
    if (MODE = "write") then
      assert false report
        "WRITE COLLISION detected at " & PORT1 & " in instance " & InstancePath &
        ". Contents of address "& SLV_TO_STR(ADDRESS) &
        " will be wholly or partially set to 'X'."
        severity WARNING;
      for I in MSB downto LSB loop
        MEM(I) := 'X';
      end loop;
    elsif (MODE = "read") then
      assert false report
        "Attempting to read some or all of contents of address "& SLV_TO_STR(ADDRESS) &
        " from " & PORT2 & " while writing from " & PORT1 &
        " in instance " & InstancePath
        severity WARNING;
    end if;
  end COLLISION;

  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";        
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN STRING := "";
    Constant Unit : IN STRING := "";
    Constant ExpectedValueMsg : IN STRING := "";
    Constant ExpectedGenericValue : IN STRING := "";
    CONSTANT TailMsg      : IN STRING;                    

    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING
    
    ) IS
    VARIABLE Message : LINE;
  BEGIN

    Write ( Message, HeaderMsg );
    Write ( Message, STRING'(" The attribute ") );                
    Write ( Message, GenericName );
    Write ( Message, STRING'(" on ") );
    Write ( Message, EntityName );
    Write ( Message, STRING'(" instance ") );
    Write ( Message, InstanceName );
    Write ( Message, STRING'(" is set to  ") );        
    Write ( Message, GenericValue );
    Write ( Message, Unit );        
    Write ( Message, '.' & LF );
    Write ( Message, ExpectedValueMsg );
    Write ( Message, ExpectedGenericValue );        
    Write ( Message, Unit );
    Write ( Message, TailMsg );

    ASSERT FALSE REPORT Message.ALL SEVERITY MsgSeverity;

    DEALLOCATE (Message);
  END GenericValueCheckMessage;

  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";        
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN INTEGER;
    CONSTANT Unit : IN STRING := "";
    CONSTANT ExpectedValueMsg : IN STRING := "";
    CONSTANT ExpectedGenericValue : IN INTEGER;
    CONSTANT TailMsg      : IN STRING;                    

    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING
    
    ) IS
    VARIABLE Message : LINE;
  BEGIN

    Write ( Message, HeaderMsg );
    Write ( Message, STRING'(" The attribute ") );                
    Write ( Message, GenericName );
    Write ( Message, STRING'(" on ") );
    Write ( Message, EntityName );
    Write ( Message, STRING'(" instance ") );
    Write ( Message, InstanceName );
    Write ( Message, STRING'(" is set to  ") );        
    Write ( Message, GenericValue );
    Write ( Message, Unit );        
    Write ( Message, '.' & LF );
    Write ( Message, ExpectedValueMsg );
    Write ( Message, ExpectedGenericValue );        
    Write ( Message, Unit );
    Write ( Message, TailMsg );        

    ASSERT FALSE REPORT Message.ALL SEVERITY MsgSeverity;

    DEALLOCATE (Message);
  END GenericValueCheckMessage;

  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";        
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN BOOLEAN;
    Constant Unit : IN STRING := "";
    CONSTANT ExpectedValueMsg : IN STRING := "";
    CONSTANT ExpectedGenericValue : IN STRING := "";
    CONSTANT TailMsg      : IN STRING;                    

    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING
    
    ) IS
    VARIABLE Message : LINE;
  BEGIN

    Write ( Message, HeaderMsg );
    Write ( Message, STRING'(" The attribute ") );                
    Write ( Message, GenericName );
    Write ( Message, STRING'(" on ") );
    Write ( Message, EntityName );
    Write ( Message, STRING'(" instance ") );
    Write ( Message, InstanceName );
    Write ( Message, STRING'(" is set to  ") );        
    Write ( Message, GenericValue );
    Write ( Message, Unit );        
    Write ( Message, '.' & LF );
    Write ( Message, ExpectedValueMsg );
    Write ( Message, ExpectedGenericValue );        
    Write ( Message, Unit );
    Write ( Message, TailMsg );        

    ASSERT FALSE REPORT Message.ALL SEVERITY MsgSeverity;

    DEALLOCATE (Message);
  END GenericValueCheckMessage;

  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";        
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN INTEGER;
    CONSTANT Unit : IN STRING := "";
    CONSTANT ExpectedValueMsg : IN STRING := "";
    CONSTANT ExpectedGenericValue : IN STRING := "";
    CONSTANT TailMsg      : IN STRING;                    

    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING
    
    ) IS
    VARIABLE Message : LINE;
  BEGIN

    Write ( Message, HeaderMsg );
    Write ( Message, STRING'(" The attribute ") );                
    Write ( Message, GenericName );
    Write ( Message, STRING'(" on ") );
    Write ( Message, EntityName );
    Write ( Message, STRING'(" instance ") );
    Write ( Message, InstanceName );
    Write ( Message, STRING'(" is set to  ") );        
    Write ( Message, GenericValue );
    Write ( Message, Unit );        
    Write ( Message, '.' & LF );
    Write ( Message, ExpectedValueMsg );
    Write ( Message, ExpectedGenericValue );        
    Write ( Message, Unit );
    Write ( Message, TailMsg );        

    ASSERT FALSE REPORT Message.ALL SEVERITY MsgSeverity;

    DEALLOCATE (Message);
  END GenericValueCheckMessage;
  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";        
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN REAL;
    CONSTANT Unit : IN STRING := "";
    CONSTANT ExpectedValueMsg : IN STRING := "";
    CONSTANT ExpectedGenericValue : IN STRING := "";
    CONSTANT TailMsg      : IN STRING;                    

    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING
    
    ) IS
    VARIABLE Message : LINE;
  BEGIN

    Write ( Message, HeaderMsg );
    Write ( Message, STRING'(" The attribute ") );                
    Write ( Message, GenericName );
    Write ( Message, STRING'(" on ") );
    Write ( Message, EntityName );
    Write ( Message, STRING'(" instance ") );
    Write ( Message, InstanceName );
    Write ( Message, STRING'(" is set to  ") );        
    Write ( Message, GenericValue );
    Write ( Message, Unit );        
    Write ( Message, '.' & LF );
    Write ( Message, ExpectedValueMsg );
    Write ( Message, ExpectedGenericValue );        
    Write ( Message, Unit );
    Write ( Message, TailMsg );        

    ASSERT FALSE REPORT Message.ALL SEVERITY MsgSeverity;

    DEALLOCATE (Message);
  END GenericValueCheckMessage;

--
  PROCEDURE Memory_Collision_Msg (
    CONSTANT HeaderMsg      : IN STRING := " Memory Collision Error on ";        
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    constant collision_type : in memory_collision_type;
    constant address_a : in std_logic_vector; 
    constant address_b : in std_logic_vector; 
    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := ERROR
    
    
    ) IS
    variable current_time : time := NOW;
    variable string_length_a : integer;
    variable string_length_b : integer;    

    VARIABLE Message : LINE;
  BEGIN
    if ((address_a'length mod 4) = 0) then
      string_length_a := address_a'length/4;
    elsif ((address_a'length mod 4) > 0) then
      string_length_a := address_a'length/4 + 1;      
    end if;
    if ((address_b'length mod 4) = 0) then
      string_length_b := address_b'length/4;
    elsif ((address_b'length mod 4) > 0) then
      string_length_b := address_b'length/4 + 1;      
    end if;    
    if (collision_type = Read_A_Write_B) then
      Write ( Message, HeaderMsg);
      Write ( Message, EntityName);    
      Write ( Message, STRING'(": "));
      Write ( Message, InstanceName);
      Write ( Message, STRING'(" at simulation time "));
      Write ( Message, current_time);
      Write ( Message, STRING'("."));
      Write ( Message, LF );            
      Write ( Message, STRING'(" A read was performed on address "));
      Write ( Message, SLV_TO_HEX(address_a, string_length_a));
      Write ( Message, STRING'(" (hex) "));      
      Write ( Message, STRING'("of port A while a write was requested to the same address on Port B "));
      Write ( Message, STRING'(" The write will be successful however the read value is unknown until the next CLKA cycle  "));

    elsif (collision_type = Read_B_Write_A) then
      Write ( Message, HeaderMsg);
      Write ( Message, EntityName);    
      Write ( Message, STRING'(": "));
      Write ( Message, InstanceName);
      Write ( Message, STRING'(" at simulation time "));
      Write ( Message, current_time);
      Write ( Message, STRING'("."));
      Write ( Message, LF );            
      Write ( Message, STRING'(" A read was performed on address "));
      Write ( Message, SLV_TO_HEX(address_b, string_length_b));
      Write ( Message, STRING'(" (hex) "));            
      Write ( Message, STRING'("of port B while a write was requested to the same address on Port A "));
      Write ( Message, STRING'(" The write will be successful however the read value is unknown until the next CLKB cycle  "));
      
    elsif (collision_type = Write_A_Write_B) then
      Write ( Message, HeaderMsg);
      Write ( Message, EntityName);    
      Write ( Message, STRING'(": "));
      Write ( Message, InstanceName);
      Write ( Message, STRING'(" at simulation time "));
      Write ( Message, current_time);
      Write ( Message, STRING'("."));
      Write ( Message, LF );      
      Write ( Message, STRING'(" A write was requested to the same address simultaneously at both Port A and Port B of the RAM."));
      Write ( Message, STRING'(" The contents written to the RAM at address location "));      
      Write ( Message, SLV_TO_HEX(address_a, string_length_a));
      Write ( Message, STRING'(" (hex) "));            
      Write ( Message, STRING'("of Port A and address location "));
      Write ( Message, SLV_TO_HEX(address_b, string_length_b));
      Write ( Message, STRING'(" (hex) "));            
      Write ( Message, STRING'("of Port B are unknown. "));
      
    end if;      
    ASSERT FALSE REPORT Message.ALL SEVERITY MsgSeverity;

    DEALLOCATE (Message);
  END Memory_Collision_Msg;

  procedure detect_resolution (
    constant model_name : in string
    ) IS
    
    variable test_value : time;
    variable Message : LINE;
  BEGIN
    test_value := 1 ps;
    if (test_value = 0 ps) then
      Write (Message, STRING'(" Simulator Resolution Error : "));
      Write (Message, STRING'(" Simulator resolution is set to a value greater than 1 ps. "));
      Write (Message, STRING'(" In order to simulate the "));
      Write (Message, model_name);
      Write (Message, STRING'(", the simulator resolution must be set to 1ps or smaller "));
      ASSERT FALSE REPORT Message.ALL SEVERITY ERROR;
      DEALLOCATE (Message);      
    end if;
  END detect_resolution;      
  

end VPKG;
