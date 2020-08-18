-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/blanc/VITAL/RAMB36E1.vhd,v 1.36.14.1 2013/03/05 22:30:42 wloo Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2008 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                       32K-Bit Data and 4K-Bit Parity Dual Port Block RAM
-- /___/   /\     Filename : RAMB36E1.vhd
-- \   \  /  \    Timestamp : Wed Apr  2 17:20:44 PDT 2008
--  \___\/\___\
--
-- Revision:
--    04/02/08 - Initial version.
--    07/28/08 - Fixed ECC in register mode. (IR 477257) 
--    08/01/08 - Updated to support SDP mode with smaller port width <= 36. (IR 477258)
--    09/15/08 - Updated File open function to impure. (CR 478698)
--    11/11/08 - Added DRC for invalid input parity for ECC (CR 482976).
--    11/20/08 - Changed RDADDRECC from 13 bits to 9 bits (IR 496907).
--    01/05/09 - Fixed read width 36 bits when write width is 72 bits (IR 501176).
--    03/11/09 - X's the unused bits of outputs (CR 511363).
--    04/20/09 - Implemented X's in sbiterr and dbiterr outputs during collision in ECC mode (CR 508071).
--    08/04/09 - Updated collision behavior when both clocks are in phase/within 100 ps (CR 522327).
--    08/12/09 - Updated collision address check for none in phase clocks (CR 527010).
--    08/20/09 - Fixed address checking for collision (CR 529759).
--    11/16/09 - Implemented DRC for ADDR(15) in non-cascade mode (CR 535882).
--    11/24/09 - Undo CR 535882, bitgen or map is going to tie off ADDR[15] instead.
--    03/15/10 - Updated address collision for asynchronous clocks and read first mode (CR 527010).
--    04/01/10 - Fixed clocks detection for collision (CR 552123).
--    05/11/10 - Added attribute RDADDR_COLLISION_HWCONFIG (CR 557971).
--    05/25/10 - Added WRITE_FIRST support in SDP mode (CR 561807).
--    06/04/10 - Added functionality for attribute RDADDR_COLLISION_HWCONFIG (CR 557971).
--    07/08/10 - Added SIM_DEVICE attribute (CR 567633).
--    07/09/10 - Fixed INJECTSBITERR and INJECTDBITERR behaviors (CR 565234).
--    07/09/10 - Initialized memory to zero for INIT_FILE (CR 560672).
--    10/28/10 - Updated 7SERIES address overlap and address collision (CR 575953).
--    11/19/10 - Fixed bug in cascade mode (CR 574075).
--    03/16/11 - Changed synchronous clock skew to 50ps for 7 series(CR 588053).
--    08/04/11 - Fixed address overlap when clocks are within 100ps (CR 611004).
--    09/12/11 - Fixed ECC error when clocks are within 100ps with address collision/overlap (CR 621942).
--    09/28/11 - Fixed ECC error when clocks are within 100ps with address collision/overlap, part 2 (CR 621942).
--    10/18/11 - Fixed collision with clocks within 100ps in SDP mode (CR 620844).
--    10/31/11 - Removed all mention of internal block ram from messaging (CR 569190).
--    11/04/11 - Fixed collision with clock within 100ps in TDP mode (CR 627670).
--    02/05/12 - Fixed read width function when READ_WIDTH_A/B = 0 (CR 643482).
--    02/23/12 - Fixed SDP mode when write width is 32 and read width is 64 (CR 647335).
--    10/02/12 - Fixed read problem of init_file (CR 679413).
--    02/15/13 - Updated collision check to use clock period or 3ns (CR 694934).
-- End Revision


-- WARNING!!!: The following RB36_INTERNAL_VHDL entity is not an user primitive.
--             Please do not modify any part of it. RAMB36E1 may not work properly if do so.
--
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_TEXTIO.all;

library STD;
use STD.TEXTIO.all;

library unisim;
use unisim.vcomponents.all;
use unisim.vpkg.all;



entity RB36_INTERNAL_VHDL is

  generic (

    BRAM_SIZE : integer := 36;
    DOA_REG : integer := 0;
    DOB_REG : integer := 0;
    EN_ECC_READ : boolean := FALSE;
    EN_ECC_WRITE : boolean := FALSE; 
    INITP_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_08 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_09 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_0A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_0B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_0C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_0D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_0E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_08 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_09 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_10 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_11 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_12 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_13 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_14 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_15 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_16 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_17 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_18 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_19 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_20 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_21 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_22 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_23 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_24 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_25 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_26 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_27 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_28 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_29 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_30 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_31 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_32 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_33 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_34 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_35 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_36 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_37 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_38 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_39 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_40 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_41 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_42 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_43 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_44 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_45 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_46 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_47 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_48 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_49 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_4A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_4B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_4C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_4D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_4E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_4F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_50 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_51 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_52 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_53 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_54 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_55 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_56 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_57 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_58 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_59 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_5A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_5B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_5C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_5D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_5E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_5F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_60 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_61 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_62 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_63 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_64 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_65 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_66 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_67 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_68 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_69 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_6A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_6B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_6C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_6D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_6E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_6F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_70 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_71 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_72 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_73 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_74 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_75 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_76 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_77 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_78 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_79 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_7A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_7B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_7C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_7D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_7E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_7F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_A : bit_vector := X"000000000000000000";
    INIT_B : bit_vector := X"000000000000000000";
    INIT_FILE : string := "NONE";
    RAM_EXTENSION_A : string := "NONE";
    RAM_EXTENSION_B : string := "NONE";
    RAM_MODE : string := "TDP";
    RDADDR_COLLISION_HWCONFIG : string := "DELAYED_WRITE";
    READ_WIDTH_A : integer := 0;
    READ_WIDTH_B : integer := 0;
    RSTREG_PRIORITY_A : string := "RSTREG";
    RSTREG_PRIORITY_B : string := "RSTREG";
    SETUP_ALL : time := 1000 ps;
    SETUP_READ_FIRST : time := 3000 ps;
    SIM_COLLISION_CHECK : string := "ALL";
    SIM_DEVICE : string := "VIRTEX6";
    SRVAL_A : bit_vector := X"000000000000000000";
    SRVAL_B : bit_vector := X"000000000000000000";
    WRITE_MODE_A : string := "WRITE_FIRST";
    WRITE_MODE_B : string := "WRITE_FIRST";
    WRITE_WIDTH_A : integer := 0;
    WRITE_WIDTH_B : integer := 0

    );

  port (
    CASCADEOUTA : out std_ulogic;
    CASCADEOUTB : out std_ulogic;
    DBITERR : out std_ulogic;
    DOA : out std_logic_vector(63 downto 0);
    DOB : out std_logic_vector(63 downto 0);
    DOPA : out std_logic_vector(7 downto 0);
    DOPB : out std_logic_vector(7 downto 0);
    ECCPARITY : out std_logic_vector(7 downto 0);
    SBITERR : out std_ulogic;
    RDADDRECC : out std_logic_vector(8 downto 0);
        
    ADDRA : in std_logic_vector(15 downto 0);
    ADDRB : in std_logic_vector(15 downto 0);
    CASCADEINA : in std_ulogic;
    CASCADEINB : in std_ulogic;
    CLKA : in std_ulogic;
    CLKB : in std_ulogic;
    DIA : in std_logic_vector(63 downto 0);
    DIB : in std_logic_vector(63 downto 0);
    DIPA : in std_logic_vector(7 downto 0);
    DIPB : in std_logic_vector(7 downto 0);
    ENA : in std_ulogic;
    ENB : in std_ulogic;
    INJECTDBITERR : in std_ulogic;
    INJECTSBITERR : in std_ulogic;
    REGCEA : in std_ulogic;
    REGCEB : in std_ulogic;
    RSTRAMA : in std_ulogic;
    RSTRAMB : in std_ulogic;
    RSTREGA : in std_ulogic;
    RSTREGB : in std_ulogic;
    WEA : in std_logic_vector(7 downto 0);
    WEB : in std_logic_vector(7 downto 0)
    
  );

  
end RB36_INTERNAL_VHDL;

-- Architecture body --

architecture RB36_INTERNAL_VHDL_V of RB36_INTERNAL_VHDL is

  
    signal ADDRA_dly    : std_logic_vector(15 downto 0) := (others => 'X');
    signal CLKA_dly     : std_ulogic                    := 'X';
    signal DIA_dly      : std_logic_vector(63 downto 0) := (others => 'X');
    signal DIPA_dly     : std_logic_vector(7 downto 0)  := (others => 'X');
    signal ENA_dly      : std_ulogic                    := 'X';
    signal REGCEA_dly   : std_ulogic                    := 'X';
    signal RSTRAMA_dly     : std_ulogic                    := 'X';
    signal WEA_dly      : std_logic_vector(7 downto 0)  := (others => 'X');
    signal CASCADEINA_dly      : std_ulogic          := 'X';
    signal ADDRB_dly    : std_logic_vector(15 downto 0) := (others => 'X');
    signal CLKB_dly     : std_ulogic                    := 'X';
    signal DIB_dly      : std_logic_vector(63 downto 0) := (others => 'X');
    signal DIPB_dly     : std_logic_vector(7 downto 0)  := (others => 'X');
    signal ENB_dly      : std_ulogic                    := 'X';
    signal REGCEB_dly   : std_ulogic                    := 'X';
    signal RSTRAMB_dly     : std_ulogic                    := 'X';
    signal WEB_dly      : std_logic_vector(7 downto 0)  := (others => 'X');
    signal CASCADEINB_dly      : std_ulogic          := 'X';
    signal INJECTDBITERR_dly     : std_ulogic          := 'X';
    signal INJECTSBITERR_dly     : std_ulogic          := 'X';
    signal RSTREGA_dly :  std_ulogic := 'X';
    signal RSTREGB_dly :  std_ulogic := 'X';
    signal ox_addra_reconstruct : std_logic_vector(15 downto 0) := (others => 'X');
    signal ox_addrb_reconstruct : std_logic_vector(15 downto 0) := (others => 'X');
      
    signal rdaddrecc_out : std_logic_vector(8 downto 0) := (others => '0');
    signal rdaddrecc_outreg : std_logic_vector(8 downto 0) := (others => '0');
    signal rdaddrecc_out_out : std_logic_vector(8 downto 0) := (others => '0');
    signal sbiterr_out : std_logic := '0';
    signal dbiterr_out : std_logic := '0';
    signal sbiterr_outreg : std_logic := '0';
    signal dbiterr_outreg : std_logic := '0';
    signal sbiterr_out_out : std_logic := '0';
    signal dbiterr_out_out : std_logic := '0';
    signal doa_out : std_logic_vector(63 downto 0) := (others => 'X');
    signal dopa_out : std_logic_vector(7 downto 0) := (others => 'X');
    signal doa_outreg : std_logic_vector(63 downto 0) := (others => 'X');
    signal dopa_outreg : std_logic_vector(7 downto 0) := (others => 'X');
    signal dob_outreg : std_logic_vector(63 downto 0) := (others => 'X');
    signal dopb_outreg : std_logic_vector(7 downto 0) := (others => 'X');
    signal dob_out : std_logic_vector(63 downto 0) := (others => 'X');
    signal dopb_out : std_logic_vector(7 downto 0) := (others => 'X');

    signal doa_out_mux : std_logic_vector(63 downto 0) := (others => 'X');
    signal dopa_out_mux : std_logic_vector(7 downto 0) := (others => 'X');
    signal doa_outreg_mux : std_logic_vector(63 downto 0) := (others => 'X');
    signal dopa_outreg_mux : std_logic_vector(7 downto 0) := (others => 'X');
    signal dob_outreg_mux : std_logic_vector(63 downto 0) := (others => 'X');
    signal dopb_outreg_mux : std_logic_vector(7 downto 0) := (others => 'X');
    signal dob_out_mux : std_logic_vector(63 downto 0) := (others => 'X');
    signal dopb_out_mux : std_logic_vector(7 downto 0) := (others => 'X');
    
    signal doa_out_out : std_logic_vector(63 downto 0) := (others => 'X');
    signal dopa_out_out : std_logic_vector(7 downto 0) := (others => 'X');
    signal dob_out_out : std_logic_vector(63 downto 0) := (others => 'X');
    signal dopb_out_out : std_logic_vector(7 downto 0) := (others => 'X');    
    signal addra_dly_15_reg : std_logic := '0';
    signal addrb_dly_15_reg : std_logic := '0';
    signal addra_dly_15_reg1 : std_logic := '0';
    signal addrb_dly_15_reg1 : std_logic := '0';
    signal cascade_a : std_logic_vector(1 downto 0) := (others => '0');
    signal cascade_b : std_logic_vector(1 downto 0) := (others => '0');
    signal GSR_dly : std_ulogic := 'X';
    signal eccparity_out : std_logic_vector(7 downto 0) := (others => 'X');
    signal SRVAL_A_STD : std_logic_vector(SRVAL_A'length-1 downto 0) := To_StdLogicVector(SRVAL_A);
    signal SRVAL_B_STD : std_logic_vector(SRVAL_B'length-1 downto 0) := To_StdLogicVector(SRVAL_B);
    signal INIT_A_STD : std_logic_vector(INIT_A'length-1 downto 0) := To_StdLogicVector(INIT_A);
    signal INIT_B_STD : std_logic_vector(INIT_B'length-1 downto 0) := To_StdLogicVector(INIT_B);
    signal di_x : std_logic_vector(63 downto 0) := (others => 'X');
    
      
  function GetWidestWidth (
    wr_width_a : in integer;
    rd_width_a : in integer;
    wr_width_b : in integer;
    rd_width_b : in integer
    ) return integer is
    variable func_widest_width : integer;
  begin
    if ((wr_width_a >= wr_width_b) and (wr_width_a >= rd_width_a) and (wr_width_a >= rd_width_b)) then
      func_widest_width := wr_width_a;
    elsif ((wr_width_b >= wr_width_a) and (wr_width_b >= rd_width_a) and (wr_width_b >= rd_width_b)) then
      func_widest_width := wr_width_b;
    elsif ((rd_width_a >= wr_width_a) and (rd_width_a >= wr_width_b) and (rd_width_a >= rd_width_b)) then
      func_widest_width := rd_width_a;
    elsif ((rd_width_b >= wr_width_a) and (rd_width_b >= wr_width_b) and (rd_width_b >= rd_width_a)) then
      func_widest_width := rd_width_b;
    end if;
    return func_widest_width;
  end;

    
  function GetWidth (
    rdwr_width : in integer
    ) return integer is
    variable func_width : integer;
  begin
    case rdwr_width is
      when 1 => func_width := 1;
      when 2 => func_width := 2;
      when 4 => func_width := 4;
      when 9 => func_width := 8;
      when 18 => func_width := 16;
      when 36 => func_width := 32;
      when 72 => func_width := 64;
      when others => func_width := 1;
    end case;
    return func_width;
  end;


  function GetRdWidth (
    rdwr_width : in integer;
    rdwr_width_across : in integer
    ) return integer is
    variable func_width : integer;
  begin
    case rdwr_width is
      when 0 => case rdwr_width_across is
                  when 1 => func_width := 1;
                  when 2 => func_width := 2;
                  when 4 => func_width := 4;
                  when 9 => func_width := 8;
                  when 18 => func_width := 16;
                  when 36 => func_width := 32;
                  when 72 => func_width := 64;
                  when others => func_width := 1;
                end case;
      when 1 => func_width := 1;
      when 2 => func_width := 2;
      when 4 => func_width := 4;
      when 9 => func_width := 8;
      when 18 => func_width := 16;
      when 36 => func_width := 32;
      when 72 => func_width := 64;
      when others => func_width := 1;
    end case;
    return func_width;
  end;

    
  function GetWidthINITF (
    rdwr_width_initf : in integer
    ) return integer is
    variable func_width_initf : integer;
  begin
    case rdwr_width_initf is
      when 1 => func_width_initf := 4;
      when 2 => func_width_initf := 4;
      when 4 => func_width_initf := 4;
      when 9 => func_width_initf := 12;
      when 18 => func_width_initf := 20;
      when 36 => func_width_initf := 36;
      when 72 => func_width_initf := 72;
      when others => func_width_initf := 1;
    end case;
    return func_width_initf;
  end;

    
  function GetWidthp (
    rdwr_widthp : in integer
    ) return integer is
    variable func_widthp : integer;
  begin
    case rdwr_widthp is
      when 9 => func_widthp := 1;
      when 18 => func_widthp := 2;
      when 36 => func_widthp := 4;
      when 72 => func_widthp := 8;
--      when others => func_widthp := 1;
      when others => func_widthp := 0;
    end case;
    return func_widthp;
  end;

    
  function GetWidthpINITF (
    rdwr_widthp_initf : in integer
    ) return integer is
    variable func_widthp_initf : integer;
  begin
    case rdwr_widthp_initf is
      when 9 => func_widthp_initf := 4;
      when 18 => func_widthp_initf := 4;
      when 36 => func_widthp_initf := 4;
      when 72 => func_widthp_initf := 8;
      when others => func_widthp_initf := 1;
    end case;
    return func_widthp_initf;
  end;


  function GetWidthpTmpWidthp (
    rdwr_tmp_widthp : in integer
    ) return integer is
    variable func_widthp_tmp : integer;
  begin
    case rdwr_tmp_widthp is
      when 1 | 2 | 4 => func_widthp_tmp := 0;
      when 9 => func_widthp_tmp := 1;
      when 18 => func_widthp_tmp := 2;
      when 36 => func_widthp_tmp := 4;
      when 72 => func_widthp_tmp := 8;
      when others => func_widthp_tmp := 8;
    end case;
    return func_widthp_tmp;
  end;

    
  function GetMemoryDepth (
    rdwr_width : in integer;
    func_bram_size : in integer
    ) return integer is
    variable func_mem_depth : integer;
  begin
    case rdwr_width is
      when 1 => if (func_bram_size = 18) then
                  func_mem_depth := 16384;
                else
                  func_mem_depth := 32768;
                end if;
      when 2 => if (func_bram_size = 18) then
                  func_mem_depth := 8192;
                else
                  func_mem_depth := 16384;
                end if;
      when 4 => if (func_bram_size = 18) then
                  func_mem_depth := 4096;
                else
                  func_mem_depth := 8192;
                end if;
      when 9 => if (func_bram_size = 18) then
                  func_mem_depth := 2048;
                else
                  func_mem_depth := 4096;
                end if;
      when 18 => if (func_bram_size = 18) then
                   func_mem_depth := 1024;
                 else
                   func_mem_depth := 2048;
                 end if;
      when 36 => if (func_bram_size = 18) then
                   func_mem_depth := 512;
                 else
                   func_mem_depth := 1024;
                 end if;
      when 72 => if (func_bram_size = 18) then
                   func_mem_depth := 0;
                 else
                   func_mem_depth := 512;
                 end if;
      when others => func_mem_depth := 32768;
    end case;
    return func_mem_depth;
  end;

  
  function GetMemoryDepthP (
    rdwr_width : in integer;
    func_bram_size : in integer
    ) return integer is
    variable func_memp_depth : integer;
  begin
    case rdwr_width is
      when 9 => if (func_bram_size = 18) then
                  func_memp_depth := 2048;
                else
                  func_memp_depth := 4096;
                end if;
      when 18 => if (func_bram_size = 18) then
                   func_memp_depth := 1024;
                 else
                   func_memp_depth := 2048;
                 end if;
      when 36 => if (func_bram_size = 18) then
                   func_memp_depth := 512;
                 else
                   func_memp_depth := 1024;
                 end if;
      when 72 => if (func_bram_size = 18) then
                   func_memp_depth := 0;
                 else
                   func_memp_depth := 512;
                 end if;
      when others => func_memp_depth := 4096;
    end case;
    return func_memp_depth;
  end;

  
  function GetAddrBitLSB (
    rdwr_width : in integer
    ) return integer is
    variable func_lsb : integer;
  begin
    case rdwr_width is
      when 1 => func_lsb := 0;
      when 2 => func_lsb := 1;
      when 4 => func_lsb := 2;
      when 9 => func_lsb := 3;
      when 18 => func_lsb := 4;
      when 36 => func_lsb := 5;
      when 72 => func_lsb := 6;
      when others => func_lsb := 10;
    end case;
    return func_lsb;
  end;

  
  function GetRdAddrBitLSB (
    rdwr_width : in integer;
    rdwr_width_across : in integer
    ) return integer is
    variable func_lsb : integer;
  begin
    case rdwr_width is
      when 1 => func_lsb := 0;
      when 2 => func_lsb := 1;
      when 4 => func_lsb := 2;
      when 9 => func_lsb := 3;
      when 18 => func_lsb := 4;
      when 36 => func_lsb := 5;
      when 72 => func_lsb := 6;
      when 0 => case rdwr_width_across is
                  when 1 => func_lsb := 0;
                  when 2 => func_lsb := 1;
                  when 4 => func_lsb := 2;
                  when 9 => func_lsb := 3;
                  when 18 => func_lsb := 4;
                  when 36 => func_lsb := 5;
                  when 72 => func_lsb := 6;
                  when others => func_lsb := 10;
                end case;
      when others => func_lsb := 10;
    end case;
    return func_lsb;
  end;

  
  function GetAddrBit124 (
    rdwr_width : in integer;
    w_width : in integer
    ) return integer is
    variable func_widest_width : integer;
  begin
    case rdwr_width is
      when 1 => case w_width is
                  when 2 => func_widest_width := 0;
                  when 4 => func_widest_width := 1;
                  when 9 => func_widest_width := 2;
                  when 18 => func_widest_width := 3;
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when 2 => case w_width is
                  when 4 => func_widest_width := 1;
                  when 9 => func_widest_width := 2;
                  when 18 => func_widest_width := 3;
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when 4 => case w_width is
                  when 9 => func_widest_width := 2;
                  when 18 => func_widest_width := 3;
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when others => func_widest_width := 10;
    end case;
    return func_widest_width;
  end;


  function GetRdAddrBit124 (
    rdwr_width : in integer;
    rdwr_width_across : in integer;
    w_width : in integer
    ) return integer is
    variable func_widest_width : integer;
  begin
    case rdwr_width is
      when 1 => case w_width is
                  when 2 => func_widest_width := 0;
                  when 4 => func_widest_width := 1;
                  when 9 => func_widest_width := 2;
                  when 18 => func_widest_width := 3;
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when 2 => case w_width is
                  when 4 => func_widest_width := 1;
                  when 9 => func_widest_width := 2;
                  when 18 => func_widest_width := 3;
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when 4 => case w_width is
                  when 9 => func_widest_width := 2;
                  when 18 => func_widest_width := 3;
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when 0 => case rdwr_width_across is
                  when 1 => case w_width is
                              when 2 => func_widest_width := 0;
                              when 4 => func_widest_width := 1;
                              when 9 => func_widest_width := 2;
                              when 18 => func_widest_width := 3;
                              when 36 => func_widest_width := 4;
                              when 72 => func_widest_width := 5;
                              when others => func_widest_width := 10;
                            end case;
                  when 2 => case w_width is
                              when 4 => func_widest_width := 1;
                              when 9 => func_widest_width := 2;
                              when 18 => func_widest_width := 3;
                              when 36 => func_widest_width := 4;
                              when 72 => func_widest_width := 5;
                              when others => func_widest_width := 10;
                            end case;
                  when 4 => case w_width is
                              when 9 => func_widest_width := 2;
                              when 18 => func_widest_width := 3;
                              when 36 => func_widest_width := 4;
                              when 72 => func_widest_width := 5;
                              when others => func_widest_width := 10;
                            end case;
                  when others => func_widest_width := 10;
                end case;
      when others => func_widest_width := 10;
    end case;
    return func_widest_width;
  end;
  
  
  function GetAddrBit8 (
    rdwr_width : in integer;
    w_width : in integer
    ) return integer is
    variable func_widest_width : integer;
  begin
    case rdwr_width is
      when 9 => case w_width is
                  when 18 => func_widest_width := 3;
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when others => func_widest_width := 10;
    end case;
    return func_widest_width;
  end;


  function GetRdAddrBit8 (
    rdwr_width : in integer;
    rdwr_width_across : in integer;
    w_width : in integer
    ) return integer is
    variable func_widest_width : integer;
  begin
    case rdwr_width is
      when 9 => case w_width is
                  when 18 => func_widest_width := 3;
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when 0 => if (rdwr_width_across = 9) then
                  case w_width is
                    when 18 => func_widest_width := 3;
                    when 36 => func_widest_width := 4;
                    when 72 => func_widest_width := 5;
                    when others => func_widest_width := 10;
                  end case;
                end if;
      when others => func_widest_width := 10;
    end case;
    return func_widest_width;
  end;

  
  function GetAddrBit16 (
    rdwr_width : in integer;
    w_width : in integer
    ) return integer is
    variable func_widest_width : integer;
  begin
    case rdwr_width is
      when 18 => case w_width is
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when others => func_widest_width := 10;
    end case;
    return func_widest_width;
  end;


  function GetRdAddrBit16 (
    rdwr_width : in integer;
    rdwr_width_across : in integer;
    w_width : in integer
    ) return integer is
    variable func_widest_width : integer;
  begin
    case rdwr_width is
      when 18 => case w_width is
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when 0 => if (rdwr_width_across = 18) then
                  case w_width is
                    when 36 => func_widest_width := 4;
                    when 72 => func_widest_width := 5;
                    when others => func_widest_width := 10;
                  end case;
                end if;
      when others => func_widest_width := 10;
    end case;
    return func_widest_width;
  end;
  
  
  function GetAddrBit32 (
    rdwr_width : in integer;
    w_width : in integer
    ) return integer is
    variable func_widest_width : integer;
  begin
    case rdwr_width is
      when 36 => case w_width is
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when others => func_widest_width := 10;
    end case;
    return func_widest_width;
  end;


  function GetRdAddrBit32 (
    rdwr_width : in integer;
    rdwr_width_across : in integer;
    w_width : in integer
    ) return integer is
    variable func_widest_width : integer;
  begin
    case rdwr_width is
      when 36 => case w_width is
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when 0 => if (rdwr_width_across = 36) then
                  case w_width is
                    when 72 => func_widest_width := 5;
                    when others => func_widest_width := 10;
                  end case;
                end if;
      when others => func_widest_width := 10;
    end case;
    return func_widest_width;
  end;

  
  function GetAddrBitLSBNotSameClk (
    col_addr_lsb_temp : in integer
    ) return integer is
    variable func_col_addr_lsb : integer;
  begin

    if (WRITE_MODE_A = "READ_FIRST" or WRITE_MODE_B = "READ_FIRST") then
      case BRAM_SIZE is
        when 18 => func_col_addr_lsb := 7;
        when 36 => func_col_addr_lsb := 8;
        when others => func_col_addr_lsb := col_addr_lsb_temp;
      end case;
    else
      func_col_addr_lsb := col_addr_lsb_temp;
    end if;
    
    return func_col_addr_lsb;
  end;
    
    
  ---------------------------------------------------------------------------
  -- Function SLV_X_TO_HEX returns a hex string version of the std_logic_vector
  -- argument.
  ---------------------------------------------------------------------------
  function SLV_X_TO_HEX (
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
      if (((nibble(0) xor nibble(1) xor nibble (2) xor nibble(3)) /= '1') and
          (nibble(0) xor nibble(1) xor nibble (2) xor nibble(3)) /= '0')  then
        STR(j) := 'x';
      elsif (nibble = "0000")  then
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
      if (((nibble(0) xor nibble(1) xor nibble (2) xor nibble(3)) /= '1') and
          (nibble(0) xor nibble(1) xor nibble (2) xor nibble(3)) /= '0')  then
        STR(j) := 'x';
      elsif (nibble = "0000")  then
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
  end SLV_X_TO_HEX;

  constant widest_width : integer := GetWidestWidth(WRITE_WIDTH_A, READ_WIDTH_A, WRITE_WIDTH_B, READ_WIDTH_B);
  constant mem_depth : integer := GetMemoryDepth(widest_width, BRAM_SIZE);
  constant memp_depth : integer := GetMemoryDepthP(widest_width, BRAM_SIZE);
  constant width : integer := GetWidth(widest_width);
  constant widthp : integer := GetWidthp(widest_width);
  constant width_initf : integer := GetWidthINITF(widest_width);
  constant widthp_initf : integer := GetWidthpINITF(widest_width);  
  constant wa_width : integer := GetWidth(WRITE_WIDTH_A);
  constant wb_width : integer := GetWidth(WRITE_WIDTH_B);
  constant ra_width : integer := GetRdWidth(READ_WIDTH_A, READ_WIDTH_B);
  constant rb_width : integer := GetRdWidth(READ_WIDTH_B, READ_WIDTH_A);
  constant wa_widthp : integer := GetWidthp(WRITE_WIDTH_A);
  constant wb_widthp : integer := GetWidthp(WRITE_WIDTH_B);
  constant ra_widthp : integer := GetWidthp(READ_WIDTH_A);
  constant rb_widthp : integer := GetWidthp(READ_WIDTH_B);
  constant r_addra_lbit_124 : integer := GetRdAddrBitLSB(READ_WIDTH_A, READ_WIDTH_B);
  constant r_addrb_lbit_124 : integer := GetRdAddrBitLSB(READ_WIDTH_B, READ_WIDTH_A);
  constant w_addra_lbit_124 : integer := GetAddrBitLSB(WRITE_WIDTH_A);
  constant w_addrb_lbit_124 : integer := GetAddrBitLSB(WRITE_WIDTH_B);
  constant w_addra_bit_124 : integer := GetAddrBit124(WRITE_WIDTH_A, widest_width);
  constant r_addra_bit_124 : integer := GetRdAddrBit124(READ_WIDTH_A, READ_WIDTH_B, widest_width);
  constant w_addrb_bit_124 : integer := GetAddrBit124(WRITE_WIDTH_B, widest_width);
  constant r_addrb_bit_124 : integer := GetRdAddrBit124(READ_WIDTH_B, READ_WIDTH_A, widest_width);
  constant w_addra_bit_8 : integer := GetAddrBit8(WRITE_WIDTH_A, widest_width);
  constant r_addra_bit_8 : integer := GetRdAddrBit8(READ_WIDTH_A, READ_WIDTH_B, widest_width);
  constant w_addrb_bit_8 : integer := GetAddrBit8(WRITE_WIDTH_B, widest_width);
  constant r_addrb_bit_8 : integer := GetRdAddrBit8(READ_WIDTH_B, READ_WIDTH_A, widest_width);
  constant w_addra_bit_16 : integer := GetAddrBit16(WRITE_WIDTH_A, widest_width);
  constant r_addra_bit_16 : integer := GetRdAddrBit16(READ_WIDTH_A, READ_WIDTH_B, widest_width);
  constant w_addrb_bit_16 : integer := GetAddrBit16(WRITE_WIDTH_B, widest_width);
  constant r_addrb_bit_16 : integer := GetRdAddrBit16(READ_WIDTH_B, READ_WIDTH_A, widest_width);
  constant w_addra_bit_32 : integer := GetAddrBit32(WRITE_WIDTH_A, widest_width);
  constant r_addra_bit_32 : integer := GetRdAddrBit32(READ_WIDTH_A, READ_WIDTH_B, widest_width);
  constant w_addrb_bit_32 : integer := GetAddrBit32(WRITE_WIDTH_B, widest_width);
  constant r_addrb_bit_32 : integer := GetRdAddrBit32(READ_WIDTH_B, READ_WIDTH_A, widest_width);
  constant col_addr_lsb : integer := GetAddrBitLSB(widest_width);
  constant tmp_widthp : integer := GetWidthpTmpWidthp(widest_width);

  type Two_D_array_type_tmp_mem is array ((mem_depth -  1) downto 0) of std_logic_vector((widest_width - 1) downto 0);
    
  type Two_D_array_type is array ((mem_depth -  1) downto 0) of std_logic_vector((width - 1) downto 0);
  type Two_D_parity_array_type is array ((memp_depth - 1) downto 0) of std_logic_vector((widthp -1) downto 0);

  type Two_D_array_type_initf is array ((mem_depth -  1) downto 0) of std_logic_vector((width_initf - 1) downto 0);
  type Two_D_parity_array_type_initf is array ((memp_depth - 1) downto 0) of std_logic_vector((widthp_initf -1) downto 0);

    
  function slv_to_two_D_array(
    slv_length : integer;
    slv_width : integer;
    SLV : in std_logic_vector
    )
    return two_D_array_type is
    variable two_D_array : two_D_array_type;
    variable intermediate : std_logic_vector((slv_width - 1) downto 0);
  begin
    for i in 0 to (slv_length - 1) loop
      intermediate := SLV(((i*slv_width) + (slv_width - 1)) downto (i* slv_width));
      two_D_array(i) := intermediate; 
    end loop;
    return two_D_array;
  end;


  function slv_to_two_D_parity_array(
    slv_length : integer;
    slv_width : integer;
    SLV : in std_logic_vector
    )
    return two_D_parity_array_type is
    variable two_D_parity_array : two_D_parity_array_type;
    variable intermediate : std_logic_vector((slv_width - 1) downto 0);
  begin
    for i in 0 to (slv_length - 1)loop
      intermediate := SLV(((i*slv_width) + (slv_width - 1)) downto (i* slv_width));
      two_D_parity_array(i) := intermediate; 
    end loop;
    return two_D_parity_array;
  end;


  impure function two_D_mem_initf(
    slv_width : integer
    )
    return two_D_array_type_tmp_mem is

    variable input_initf_tmp : Two_D_array_type_initf;
    variable input_initf : Two_D_array_type_tmp_mem := (others => (others => '0'));
    file int_infile : text;
    variable data_line, data_line_tmp, out_data_line : line;
    variable i : integer := 0;
    variable good_data : boolean := false;
    variable ignore_line : boolean := false;
    variable char_tmp : character;
    variable init_addr_slv : std_logic_vector(31 downto 0) := (others => '0');
    variable open_status : file_open_status;
    
  begin

    if (INIT_FILE /= "NONE") then
      
      file_open(open_status, int_infile, INIT_FILE, read_mode);

      while not endfile(int_infile) loop
          
        readline(int_infile, data_line);

        while (data_line /= null and data_line'length > 0) loop
          
          if (data_line(data_line'low to data_line'low + 1) = "//") then
            deallocate(data_line);

          elsif ((data_line(data_line'low to data_line'low + 1) = "/*") and (data_line(data_line'high-1 to data_line'high) = "*/")) then
            deallocate(data_line);
            
          elsif (data_line(data_line'low to data_line'low + 1) = "/*") then
            deallocate(data_line);
            ignore_line := true;

          elsif (ignore_line = true and data_line(data_line'high-1 to data_line'high) = "*/") then
            deallocate(data_line);
            ignore_line := false;


          elsif (ignore_line = false and data_line(data_line'low) = '@') then
            read(data_line, char_tmp);
            hread(data_line, init_addr_slv, good_data);

            i := SLV_TO_INT(init_addr_slv);

          elsif (ignore_line = false) then

            hread(data_line, input_initf_tmp(i), good_data);
            input_initf(i)(slv_width - 1 downto 0) := input_initf_tmp(i)(slv_width - 1 downto 0);
          
            if (good_data = true) then
              i := i + 1;             
            end if;
          else
            deallocate(data_line);
                     
          end if;
        
        end loop;
        
      end loop;

    end if;
        
    return input_initf;

  end;


  function two_D_mem_init(  
    slv_length : integer;
    slv_width : integer;
    SLV : in std_logic_vector;
    temp_mem : two_D_array_type_tmp_mem
    )
    return two_D_array_type is
    variable two_D_array_mem_init : two_D_array_type;
  begin
     if (INIT_FILE = "NONE") then
       two_D_array_mem_init := slv_to_two_D_array(slv_length, slv_width, SLV);
     else

       for i in 0 to (slv_length - 1) loop
         two_D_array_mem_init(i)(slv_width-1 downto 0) := temp_mem(i)(slv_width-1 downto 0);
       end loop;
                           
     end if;
     return two_D_array_mem_init;
  end;


  function two_D_mem_initp(  
    slv_length : integer;
    slv_width : integer;
    SLV : in std_logic_vector;
    temp_mem : two_D_array_type_tmp_mem;
    mem_width : integer
    )
    return two_D_parity_array_type is
    variable two_D_array_mem_initp : two_D_parity_array_type;
  begin
     if (INIT_FILE = "NONE") then
       two_D_array_mem_initp := slv_to_two_D_parity_array(slv_length, slv_width, SLV);
     else

       if (slv_width > 0) then
         
         for i in 0 to (slv_length - 1) loop
           two_D_array_mem_initp(i)(slv_width-1 downto 0) := temp_mem(i)(mem_width + slv_width - 1 downto mem_width);
         end loop;

       end if;
     end if;
     return two_D_array_mem_initp;
  end;

    

  function fn_dip_ecc (
    encode : in std_logic;
    di_in : in std_logic_vector (63 downto 0);
    dip_in : in std_logic_vector (7 downto 0)
    ) return std_logic_vector is
    variable fn_dip_ecc : std_logic_vector (7 downto 0);
  begin

    fn_dip_ecc(0) := di_in(0) xor di_in(1) xor di_in(3) xor di_in(4) xor di_in(6) xor di_in(8)
                  xor di_in(10) xor di_in(11) xor di_in(13) xor di_in(15) xor di_in(17) xor di_in(19)
                  xor di_in(21) xor di_in(23) xor di_in(25) xor di_in(26) xor di_in(28)
                  xor di_in(30) xor di_in(32) xor di_in(34) xor di_in(36) xor di_in(38)
                  xor di_in(40) xor di_in(42) xor di_in(44) xor di_in(46) xor di_in(48)
                  xor di_in(50) xor di_in(52) xor di_in(54) xor di_in(56) xor di_in(57) xor di_in(59)
                  xor di_in(61) xor di_in(63);

    fn_dip_ecc(1) := di_in(0) xor di_in(2) xor di_in(3) xor di_in(5) xor di_in(6) xor di_in(9)
                     xor di_in(10) xor di_in(12) xor di_in(13) xor di_in(16) xor di_in(17)
                     xor di_in(20) xor di_in(21) xor di_in(24) xor di_in(25) xor di_in(27) xor di_in(28)
                     xor di_in(31) xor di_in(32) xor di_in(35) xor di_in(36) xor di_in(39)
                     xor di_in(40) xor di_in(43) xor di_in(44) xor di_in(47) xor di_in(48)
                     xor di_in(51) xor di_in(52) xor di_in(55) xor di_in(56) xor di_in(58) xor di_in(59)
                     xor di_in(62) xor di_in(63);

    fn_dip_ecc(2) := di_in(1) xor di_in(2) xor di_in(3) xor di_in(7) xor di_in(8) xor di_in(9)
                     xor di_in(10) xor di_in(14) xor di_in(15) xor di_in(16) xor di_in(17)
                     xor di_in(22) xor di_in(23) xor di_in(24) xor di_in(25) xor di_in(29)
                     xor di_in(30) xor di_in(31) xor di_in(32) xor di_in(37) xor di_in(38) xor di_in(39)
                     xor di_in(40) xor di_in(45) xor di_in(46) xor di_in(47) xor di_in(48)
                     xor di_in(53) xor di_in(54) xor di_in(55) xor di_in(56)
                     xor di_in(60) xor di_in(61) xor di_in(62) xor di_in(63);
	
    fn_dip_ecc(3) := di_in(4) xor di_in(5) xor di_in(6) xor di_in(7) xor di_in(8) xor di_in(9)
                     xor di_in(10) xor di_in(18) xor di_in(19)
                     xor di_in(20) xor di_in(21) xor di_in(22) xor di_in(23) xor di_in(24) xor di_in(25)
                     xor di_in(33) xor di_in(34) xor di_in(35) xor di_in(36) xor di_in(37) xor di_in(38) xor di_in(39)
                     xor di_in(40) xor di_in(49)
                     xor di_in(50) xor di_in(51) xor di_in(52) xor di_in(53) xor di_in(54) xor di_in(55) xor di_in(56);

    fn_dip_ecc(4) := di_in(11) xor di_in(12) xor di_in(13) xor di_in(14) xor di_in(15) xor di_in(16) xor di_in(17)
                     xor di_in(18) xor di_in(19) xor di_in(20) xor di_in(21) xor di_in(22) xor di_in(23) xor di_in(24)
                     xor di_in(25) xor di_in(41) xor di_in(42) xor di_in(43) xor di_in(44) xor di_in(45) xor di_in(46)
                     xor di_in(47) xor di_in(48) xor di_in(49) xor di_in(50) xor di_in(51) xor di_in(52) xor di_in(53)
                     xor di_in(54) xor di_in(55) xor di_in(56);


    fn_dip_ecc(5) := di_in(26) xor di_in(27) xor di_in(28) xor di_in(29)
                     xor di_in(30) xor di_in(31) xor di_in(32) xor di_in(33) xor di_in(34) xor di_in(35) xor di_in(36)
                     xor di_in(37) xor di_in(38) xor di_in(39) xor di_in(40) xor di_in(41) xor di_in(42) xor di_in(43)
                     xor di_in(44) xor di_in(45) xor di_in(46) xor di_in(47) xor di_in(48) xor di_in(49) xor di_in(50)
                     xor di_in(51) xor di_in(52) xor di_in(53) xor di_in(54) xor di_in(55) xor di_in(56);

    fn_dip_ecc(6) := di_in(57) xor di_in(58) xor di_in(59)
                     xor di_in(60) xor di_in(61) xor di_in(62) xor di_in(63);

    if (encode = '1') then

      fn_dip_ecc(7) := fn_dip_ecc(0) xor fn_dip_ecc(1) xor fn_dip_ecc(2) xor fn_dip_ecc(3) xor fn_dip_ecc(4) xor fn_dip_ecc(5)
                       xor fn_dip_ecc(6) xor di_in(0) xor di_in(1) xor di_in(2) xor di_in(3) xor di_in(4) xor di_in(5)
                       xor di_in(6) xor di_in(7) xor di_in(8) xor di_in(9) xor di_in(10) xor di_in(11) xor di_in(12)
                       xor di_in(13) xor di_in(14) xor di_in(15) xor di_in(16) xor di_in(17) xor di_in(18) xor di_in(19)
                       xor di_in(20) xor di_in(21) xor di_in(22) xor di_in(23) xor di_in(24) xor di_in(25) xor di_in(26)
                       xor di_in(27) xor di_in(28) xor di_in(29) xor di_in(30) xor di_in(31) xor di_in(32) xor di_in(33)
                       xor di_in(34) xor di_in(35) xor di_in(36) xor di_in(37) xor di_in(38) xor di_in(39) xor di_in(40)
                       xor di_in(41) xor di_in(42) xor di_in(43) xor di_in(44) xor di_in(45) xor di_in(46) xor di_in(47)
                       xor di_in(48) xor di_in(49) xor di_in(50) xor di_in(51) xor di_in(52) xor di_in(53) xor di_in(54)
                       xor di_in(55) xor di_in(56) xor di_in(57) xor di_in(58) xor di_in(59) xor di_in(60) xor di_in(61)
                       xor di_in(62) xor di_in(63);

    else

      fn_dip_ecc(7) := dip_in(0) xor dip_in(1) xor dip_in(2) xor dip_in(3) xor dip_in(4) xor dip_in(5)
                       xor dip_in(6) xor di_in(0) xor di_in(1) xor di_in(2) xor di_in(3) xor di_in(4) xor di_in(5)
                       xor di_in(6) xor di_in(7) xor di_in(8) xor di_in(9) xor di_in(10) xor di_in(11) xor di_in(12)
                       xor di_in(13) xor di_in(14) xor di_in(15) xor di_in(16) xor di_in(17) xor di_in(18) xor di_in(19)
                       xor di_in(20) xor di_in(21) xor di_in(22) xor di_in(23) xor di_in(24) xor di_in(25) xor di_in(26)
                       xor di_in(27) xor di_in(28) xor di_in(29) xor di_in(30) xor di_in(31) xor di_in(32) xor di_in(33)
                       xor di_in(34) xor di_in(35) xor di_in(36) xor di_in(37) xor di_in(38) xor di_in(39) xor di_in(40)
                       xor di_in(41) xor di_in(42) xor di_in(43) xor di_in(44) xor di_in(45) xor di_in(46) xor di_in(47)
                       xor di_in(48) xor di_in(49) xor di_in(50) xor di_in(51) xor di_in(52) xor di_in(53) xor di_in(54)
                       xor di_in(55) xor di_in(56) xor di_in(57) xor di_in(58) xor di_in(59) xor di_in(60) xor di_in(61)
                       xor di_in(62) xor di_in(63);
    end if;

    return fn_dip_ecc;
    
  end fn_dip_ecc;



  procedure prcd_disp_addr_ox_msg (
    constant addra_tmp : in std_logic_vector (15 downto 0);
    constant addrb_tmp : in std_logic_vector (15 downto 0)
    ) is
    
    variable string_length_1 : integer;
    variable string_length_2 : integer;
    variable message : LINE;
    constant MsgSeverity : severity_level := Failure;

  begin
    
    if ((addra_dly'length mod 4) = 0) then
      string_length_1 := addra_dly'length/4;
    elsif ((addra_dly'length mod 4) > 0) then
      string_length_1 := addra_dly'length/4 + 1;      
    end if;
    if ((addrb_dly'length mod 4) = 0) then
      string_length_2 := addrb_dly'length/4;
    elsif ((addrb_dly'length mod 4) > 0) then
      string_length_2 := addrb_dly'length/4 + 1;      
    end if;
              
    Write ( message, STRING'(" Address Overlap Error on RAMB36E1 :"));
    Write ( message, STRING'(RB36_INTERNAL_VHDL'path_name));
    Write ( message, STRING'(" at simulation time "));
    Write ( message, now);
    Write ( message, STRING'("."));
    Write ( message, LF );            
    Write ( message, STRING'(" A read/write/write was performed on address "));
    Write ( message, SLV_X_TO_HEX(addra_dly, string_length_1));
    Write ( message, STRING'(" (hex) "));            
    Write ( message, STRING'(" of port A while a write/read/write was requested to the overlapped address "));
    Write ( message, SLV_X_TO_HEX(addrb_dly, string_length_2));
    Write ( message, STRING'(" (hex) "));
    Write ( message, STRING'(" of port B with RDADDR_COLLISION_HWCONFIG set to "));
    Write ( message, RDADDR_COLLISION_HWCONFIG);
    Write ( message, STRING'(" and WRITE_MODE_A set "));
    Write ( message, WRITE_MODE_A);
    Write ( message, STRING'(" and WRITE_MODE_B set "));
    Write ( message, WRITE_MODE_B);
    Write ( message, STRING'(". The write will be unsuccessful and the contents of the RAM at both address locations of port A and B became unknown.  To correct this issue, either evaluate changing RDADDR_COLLISION_HWCONFIG to DELAYED_WRITE, change both WITRE_MODEs to something other than READ_FIRST or control addressing to not incur address overlap."));
    ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
    DEALLOCATE (message);

  end prcd_disp_addr_ox_msg;
    

    
  procedure prcd_chk_for_col_msg (
    constant viol_type_tmp : in std_logic_vector (1 downto 0);
    constant wea_tmp : in std_ulogic;
    constant web_tmp : in std_ulogic;
    constant addra_tmp : in std_logic_vector (15 downto 0);
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    variable col_wr_wr_msg : inout std_ulogic;
    variable col_wra_rdb_msg : inout std_ulogic;
    variable col_wrb_rda_msg : inout std_ulogic;
    variable chk_col_same_clk_tmp : inout integer;
    variable chk_ox_same_clk_tmp : inout integer;
    variable chk_ox_msg_tmp : inout integer
    ) is
    
    variable string_length_1 : integer;
    variable string_length_2 : integer;
    variable message : LINE;
    constant MsgSeverity : severity_level := Error;

  begin
    
    if (SIM_COLLISION_CHECK = "ALL" or SIM_COLLISION_CHECK = "WARNING_ONLY") then
    
      if ((addra_tmp'length mod 4) = 0) then
        string_length_1 := addra_tmp'length/4;
      elsif ((addra_tmp'length mod 4) > 0) then
        string_length_1 := addra_tmp'length/4 + 1;      
      end if;
      if ((addrb_tmp'length mod 4) = 0) then
        string_length_2 := addrb_tmp'length/4;
      elsif ((addrb_tmp'length mod 4) > 0) then
        string_length_2 := addrb_tmp'length/4 + 1;      
      end if;

      if (wea_tmp = '1' and web_tmp = '1' and col_wr_wr_msg = '1') then

        if (chk_ox_msg_tmp = 1) then
          
          if (not(RDADDR_COLLISION_HWCONFIG = "DELAYED_WRITE" and chk_ox_same_clk_tmp = 1)) then

            Write ( message, STRING'(" Address Overlap Error on RAMB36E1 :"));
            Write ( message, STRING'(RB36_INTERNAL_VHDL'path_name));
            Write ( message, STRING'(" at simulation time "));
            Write ( message, now);
            Write ( message, STRING'("."));
            Write ( message, LF );
            Write ( message, STRING'(" A write was requested to the overlapped address simultaneously at both port A and port B of the RAM."));
            Write ( message, STRING'(" The contents written to the RAM at address location "));      
            Write ( message, SLV_X_TO_HEX(addra_tmp, string_length_1));
            Write ( message, STRING'(" (hex) "));            
            Write ( message, STRING'("of port A and address location "));
            Write ( message, SLV_X_TO_HEX(addrb_tmp, string_length_2));
            Write ( message, STRING'(" (hex) "));            
            Write ( message, STRING'("of port B are unknown. "));
            ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
            DEALLOCATE (message);

          end if;

        else
          
          Write ( message, STRING'(" Memory Collision Error on RAMB36E1 :"));
          Write ( message, STRING'(RB36_INTERNAL_VHDL'path_name));
          Write ( message, STRING'(" at simulation time "));
          Write ( message, now);
          Write ( message, STRING'("."));
          Write ( message, LF );
          Write ( message, STRING'(" A write was requested to the same address simultaneously at both port A and port B of the RAM."));
          Write ( message, STRING'(" The contents written to the RAM at address location "));      
          Write ( message, SLV_X_TO_HEX(addra_tmp, string_length_1));
          Write ( message, STRING'(" (hex) "));            
          Write ( message, STRING'("of port A and address location "));
          Write ( message, SLV_X_TO_HEX(addrb_tmp, string_length_2));
          Write ( message, STRING'(" (hex) "));            
          Write ( message, STRING'("of port B are unknown. "));
          ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
          DEALLOCATE (message);

        end if;
        
        col_wr_wr_msg := '0';
        
      elsif (wea_tmp = '1' and web_tmp = '0' and col_wra_rdb_msg = '1') then

        if (chk_ox_msg_tmp = 1) then

          if (not(RDADDR_COLLISION_HWCONFIG = "DELAYED_WRITE" and chk_ox_same_clk_tmp = 1)) then

            Write ( message, STRING'(" Address Overlap Error on RAMB36E1 :"));
            Write ( message, STRING'(RB36_INTERNAL_VHDL'path_name));
            Write ( message, STRING'(" at simulation time "));
            Write ( message, now);
            Write ( message, STRING'("."));
            Write ( message, LF );            
            Write ( message, STRING'(" A read was performed on address "));
            Write ( message, SLV_X_TO_HEX(addrb_tmp, string_length_2));
            Write ( message, STRING'(" (hex) "));            
            Write ( message, STRING'("of port B while a write was requested to the overlapped address "));
            Write ( message, SLV_X_TO_HEX(addra_tmp, string_length_1));
            Write ( message, STRING'(" (hex) "));
            Write ( message, STRING'("of port A. "));
            Write ( message, STRING'(" The write will be unsuccessful and the contents of the RAM at both address locations of port A and B became unknown. "));
            ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
            DEALLOCATE (message);

          end if;

        else

          if ((WRITE_MODE_A = "READ_FIRST" or WRITE_MODE_B = "READ_FIRST")
              and (not(chk_col_same_clk_tmp = 1 and RDADDR_COLLISION_HWCONFIG = "DELAYED_WRITE") and SIM_DEVICE = "VIRTEX6")) then

            Write ( message, STRING'(" Memory Collision Error on RAMB36E1 :"));
            Write ( message, STRING'(RB36_INTERNAL_VHDL'path_name));
            Write ( message, STRING'(" at simulation time "));
            Write ( message, now);
            Write ( message, STRING'("."));
            Write ( message, LF );            
            Write ( message, STRING'(" A read was performed on address "));
            Write ( message, SLV_X_TO_HEX(addrb_tmp, string_length_2));
            Write ( message, STRING'(" (hex) "));            
            Write ( message, STRING'("of port B while a write was requested to the same address on port A. "));
            Write ( message, STRING'(" The write will be unsuccessful and the contents of the RAM at both address locations of port A and B became unknown. "));
            ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
            DEALLOCATE (message);

          elsif (WRITE_MODE_A /= "READ_FIRST" or (viol_type_tmp = "11" and WRITE_MODE_A = "READ_FIRST")) then
            
            Write ( message, STRING'(" Memory Collision Error on RAMB36E1 :"));
            Write ( message, STRING'(RB36_INTERNAL_VHDL'path_name));
            Write ( message, STRING'(" at simulation time "));
            Write ( message, now);
            Write ( message, STRING'("."));
            Write ( message, LF );            
            Write ( message, STRING'(" A read was performed on address "));
            Write ( message, SLV_X_TO_HEX(addrb_tmp, string_length_2));
            Write ( message, STRING'(" (hex) "));            
            Write ( message, STRING'("of port B while a write was requested to the same address on port A. "));
            Write ( message, STRING'(" The write will be successful however the read value on port B is unknown until the next CLKB cycle. "));
            ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
            DEALLOCATE (message);

          end if;

        end if;

        col_wra_rdb_msg := '0';
        
      elsif (wea_tmp = '0' and web_tmp = '1' and col_wrb_rda_msg = '1') then

        if (chk_ox_msg_tmp = 1) then

          if (not(RDADDR_COLLISION_HWCONFIG = "DELAYED_WRITE" and chk_ox_same_clk_tmp = 1)) then

            Write ( message, STRING'(" Address Overlap Error on RAMB36E1 :"));
            Write ( message, STRING'(RB36_INTERNAL_VHDL'path_name));
            Write ( message, STRING'(" at simulation time "));
            Write ( message, now);
            Write ( message, STRING'("."));
            Write ( message, LF );            
            Write ( message, STRING'(" A read was performed on address "));
            Write ( message, SLV_X_TO_HEX(addra_tmp, string_length_1));
            Write ( message, STRING'(" (hex) "));            
            Write ( message, STRING'("of port A while a write was requested to the overlapped address "));
            Write ( message, SLV_X_TO_HEX(addrb_tmp, string_length_2));
            Write ( message, STRING'(" (hex) "));
            Write ( message, STRING'("of port B. "));
            Write ( message, STRING'(" The write will be unsuccessful and the contents of the RAM at both address locations of port A and B became unknown. "));
            ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
            DEALLOCATE (message);

          end if;

        else

          if ((WRITE_MODE_A = "READ_FIRST" or WRITE_MODE_B = "READ_FIRST")
              and (not(chk_col_same_clk_tmp = 1 and RDADDR_COLLISION_HWCONFIG = "DELAYED_WRITE") and SIM_DEVICE = "VIRTEX6")) then

            Write ( message, STRING'(" Memory Collision Error on RAMB36E1 :"));
            Write ( message, STRING'(RB36_INTERNAL_VHDL'path_name));
            Write ( message, STRING'(" at simulation time "));
            Write ( message, now);
            Write ( message, STRING'("."));
            Write ( message, LF );            
            Write ( message, STRING'(" A read was performed on address "));
            Write ( message, SLV_X_TO_HEX(addra_tmp, string_length_1));
            Write ( message, STRING'(" (hex) "));            
            Write ( message, STRING'("of port A while a write was requested to the same address on port B. "));
            Write ( message, STRING'(" The write will be unsuccessful and the contents of the RAM at both address locations of port A and B became unknown. "));
            ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
            DEALLOCATE (message);

          elsif (WRITE_MODE_B /= "READ_FIRST" or (viol_type_tmp = "10" and WRITE_MODE_B = "READ_FIRST")) then
            
            Write ( message, STRING'(" Memory Collision Error on RAMB36E1 :"));
            Write ( message, STRING'(RB36_INTERNAL_VHDL'path_name));
            Write ( message, STRING'(" at simulation time "));
            Write ( message, now);
            Write ( message, STRING'("."));
            Write ( message, LF );            
            Write ( message, STRING'(" A read was performed on address "));
            Write ( message, SLV_X_TO_HEX(addra_tmp, string_length_1));
            Write ( message, STRING'(" (hex) "));            
            Write ( message, STRING'("of port A while a write was requested to the same address on port B. "));
            Write ( message, STRING'(" The write will be successful however the read value on port A is unknown until the next CLKA cycle. "));
            ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
            DEALLOCATE (message);

          end if;

        end if;

        col_wrb_rda_msg := '0';
        
      end if;      

    end if;
    
  end prcd_chk_for_col_msg;

    
  procedure prcd_write_ram (
    constant we : in std_logic;
    constant di : in std_logic_vector;
    constant dip : in std_logic;
    variable mem_proc : inout std_logic_vector;
    variable memp_proc : inout std_logic
    ) is
    
    alias di_tmp : std_logic_vector (di'length-1 downto 0) is di;
    alias mem_proc_tmp : std_logic_vector (mem_proc'length-1 downto 0) is mem_proc;

    begin
      if (we = '1') then
        mem_proc_tmp := di_tmp;

        if (width >= 8) then
          memp_proc := dip;
        end if;
      end if;
  end prcd_write_ram;

    
  procedure prcd_write_ram_col (
    constant we_o : in std_logic;
    constant we : in std_logic;
    constant di : in std_logic_vector;
    constant dip : in std_logic;
    variable mem_proc : inout std_logic_vector;
    variable memp_proc : inout std_logic
    ) is
    
    alias di_tmp : std_logic_vector (di'length-1 downto 0) is di;
    alias mem_proc_tmp : std_logic_vector (mem_proc'length-1 downto 0) is mem_proc;
    variable i : integer := 0;
    
    begin
      if (we = '1') then

        for i in 0 to di'length-1 loop
          if ((mem_proc_tmp(i) /= 'X') or (not(we = we_o and we = '1'))) then
            mem_proc_tmp(i) := di_tmp(i);
          end if;
        end loop;

        if (width >= 8 and ((memp_proc /= 'X') or (not(we = we_o and we = '1')))) then
          memp_proc := dip;
        end if;

      end if;
  end prcd_write_ram_col;


  procedure prcd_write_ram_ox (
    constant we_o : in std_logic;
    constant we : in std_logic;
    constant di : in std_logic_vector;
    constant dip : in std_logic;
    variable mem_proc : inout std_logic_vector;
    variable memp_proc : inout std_logic
    ) is
    
    alias di_tmp : std_logic_vector (di'length-1 downto 0) is di;
    alias mem_proc_tmp : std_logic_vector (mem_proc'length-1 downto 0) is mem_proc;
    variable i : integer := 0;
    
    begin
      if (we = '1') then

        for i in 0 to di'length-1 loop
          mem_proc_tmp(i) := di_tmp(i);
        end loop;

        if (width >= 8) then
          memp_proc := dip;
        end if;

      end if;
  end prcd_write_ram_ox;

    
  procedure prcd_x_buf (
    constant wr_rd_mode : in std_logic_vector (1 downto 0);
    constant do_uindex : in integer;
    constant do_lindex : in integer;
    constant dop_index : in integer;
    constant do_ltmp : in std_logic_vector (63 downto 0);
    variable do_tmp : inout std_logic_vector (63 downto 0);
    constant dop_ltmp : in std_logic_vector (7 downto 0);
    variable dop_tmp : inout std_logic_vector (7 downto 0)
    ) is
    
    variable i : integer;

    begin
      if (wr_rd_mode = "01") then
        for i in do_lindex to do_uindex loop
          if (do_ltmp(i) = 'X') then
            do_tmp(i) := 'X';
          end if;
        end loop;
        
        if (dop_ltmp(dop_index) = 'X') then
          dop_tmp(dop_index) := 'X';
        end if;
          
      else
        do_tmp(do_lindex + 7 downto do_lindex) := do_ltmp(do_lindex + 7 downto do_lindex);
        dop_tmp(dop_index) := dop_ltmp(dop_index);
      end if;

  end prcd_x_buf;

    
  procedure prcd_rd_ram_a (
    constant addra_tmp : in std_logic_vector (15 downto 0);
    variable doa_tmp : inout std_logic_vector (63 downto 0);
    variable dopa_tmp : inout std_logic_vector (7 downto 0);
    constant mem : in Two_D_array_type;
    constant memp : in Two_D_parity_array_type     
    ) is
    variable prcd_tmp_addra_dly_depth : integer;
    variable prcd_tmp_addra_dly_width : integer;

  begin
    
    case ra_width is

      when 1 | 2 | 4 => if (ra_width >= width) then
                          prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto r_addra_lbit_124));
                          doa_tmp(ra_width-1 downto 0) := mem(prcd_tmp_addra_dly_depth);
                        else
                          prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto r_addra_bit_124 + 1));
                          prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(r_addra_bit_124 downto r_addra_lbit_124));
                          doa_tmp(ra_width-1 downto 0) := mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * ra_width) + ra_width - 1 downto prcd_tmp_addra_dly_width * ra_width);
                        end if;

      when 8 => if (ra_width >= width) then
                  prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 3));
                  doa_tmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth);
                  dopa_tmp(0 downto 0) := memp(prcd_tmp_addra_dly_depth);
                else
                  prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto r_addra_bit_8 + 1));
                  prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(r_addra_bit_8 downto 3));
                  doa_tmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 8) + 7 downto prcd_tmp_addra_dly_width * 8);
                  dopa_tmp(0 downto 0) := memp(prcd_tmp_addra_dly_depth)(prcd_tmp_addra_dly_width downto prcd_tmp_addra_dly_width);
                end if;

      when 16 => if (ra_width >= width) then
                  prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                  doa_tmp(15 downto 0) := mem(prcd_tmp_addra_dly_depth);
                  dopa_tmp(1 downto 0) := memp(prcd_tmp_addra_dly_depth);
                 else
                  prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto r_addra_bit_16 + 1));
                  prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(r_addra_bit_16 downto 4));
                  doa_tmp(15 downto 0) := mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 16) + 15 downto prcd_tmp_addra_dly_width * 16);
                  dopa_tmp(1 downto 0) := memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2) + 1 downto prcd_tmp_addra_dly_width * 2);
                 end if;

      when 32 => if (ra_width >= width) then
                  prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 5));
                  doa_tmp(31 downto 0) := mem(prcd_tmp_addra_dly_depth);
                  dopa_tmp(3 downto 0) := memp(prcd_tmp_addra_dly_depth);
                 else
                  prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto r_addra_bit_32 + 1));
                  prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(r_addra_bit_32 downto 5));
                  doa_tmp(31 downto 0) := mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 32) + 31 downto prcd_tmp_addra_dly_width * 32);
                  dopa_tmp(3 downto 0) := memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 4) + 3 downto prcd_tmp_addra_dly_width * 4);
                end if;

      when 64 => if (ra_width >= width) then
                  prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 6));
                  doa_tmp(63 downto 0) := mem(prcd_tmp_addra_dly_depth);
                  dopa_tmp(7 downto 0) := memp(prcd_tmp_addra_dly_depth);
                end if;
                 
      when others => null;

    end case;

  end prcd_rd_ram_a;

  
  procedure prcd_rd_ram_b (
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    variable dob_tmp : inout std_logic_vector (63 downto 0);
    variable dopb_tmp : inout std_logic_vector (7 downto 0);
    constant mem : in Two_D_array_type;
    constant memp : in Two_D_parity_array_type     
    ) is
    variable prcd_tmp_addrb_dly_depth : integer;
    variable prcd_tmp_addrb_dly_width : integer;

  begin
    
    case rb_width is

      when 1 | 2 | 4 => if (rb_width >= width) then
                          prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_lbit_124));
                          dob_tmp(rb_width-1 downto 0) := mem(prcd_tmp_addrb_dly_depth);
                        else
                          prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_bit_124 + 1));
                          prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(r_addrb_bit_124 downto r_addrb_lbit_124));
                          dob_tmp(rb_width-1 downto 0) := mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * rb_width) + rb_width - 1 downto prcd_tmp_addrb_dly_width * rb_width);
                        end if;

      when 8 => if (rb_width >= width) then
                  prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 3));
                  dob_tmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth);
                  dopb_tmp(0 downto 0) := memp(prcd_tmp_addrb_dly_depth);
                else
                  prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_bit_8 + 1));
                  prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(r_addrb_bit_8 downto 3));
                  dob_tmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 8) + 7 downto prcd_tmp_addrb_dly_width * 8);
                  dopb_tmp(0 downto 0) := memp(prcd_tmp_addrb_dly_depth)(prcd_tmp_addrb_dly_width downto prcd_tmp_addrb_dly_width);
                end if;

      when 16 => if (rb_width >= width) then
                  prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                  dob_tmp(15 downto 0) := mem(prcd_tmp_addrb_dly_depth);
                  dopb_tmp(1 downto 0) := memp(prcd_tmp_addrb_dly_depth);
                 else
                  prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_bit_16 + 1));
                  prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(r_addrb_bit_16 downto 4));
                  dob_tmp(15 downto 0) := mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 16) + 15 downto prcd_tmp_addrb_dly_width * 16);
                  dopb_tmp(1 downto 0) := memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2) + 1 downto prcd_tmp_addrb_dly_width * 2);
                 end if;

      when 32 => if (rb_width >= width) then
                  prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                  dob_tmp(31 downto 0) := mem(prcd_tmp_addrb_dly_depth);
                  dopb_tmp(3 downto 0) := memp(prcd_tmp_addrb_dly_depth);
                end if;
      when 64 => if (rb_width >= width) then
                  prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 6));
                  dob_tmp(63 downto 0) := mem(prcd_tmp_addrb_dly_depth);
                  dopb_tmp(7 downto 0) := memp(prcd_tmp_addrb_dly_depth);
                end if;
      when others => null;

    end case;

  end prcd_rd_ram_b;


  procedure prcd_col_wr_ram_a (
    constant viol_type_tmp : in std_logic_vector (1 downto 0);
    constant seq : in std_logic_vector (1 downto 0);
    constant web_tmp : in std_logic_vector (7 downto 0);
    constant wea_tmp : in std_logic_vector (7 downto 0);
    constant dia_tmp : in std_logic_vector (63 downto 0);
    constant dipa_tmp : in std_logic_vector (7 downto 0);
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    constant addra_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type;
    variable col_wr_wr_msg : inout std_ulogic;
    variable col_wra_rdb_msg : inout std_ulogic;
    variable col_wrb_rda_msg : inout std_ulogic;
    variable chk_col_same_clk_tmp : inout integer;
    variable chk_ox_same_clk_tmp : inout integer;
    variable chk_ox_msg_tmp : inout integer
    ) is
    variable prcd_tmp_addra_dly_depth : integer;
    variable prcd_tmp_addra_dly_width : integer;
    variable junk : std_ulogic;

  begin
    
    case wa_width is

      when 1 | 2 | 4 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wa_width > wb_width) or seq = "10") then
                          if (wa_width >= width) then
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_lbit_124));
                            prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(wa_width-1 downto 0), '0', mem(prcd_tmp_addra_dly_depth), junk);
                          else
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_bit_124 + 1));
                            prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(w_addra_bit_124 downto w_addra_lbit_124));
                            prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(wa_width-1 downto 0), '0', mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * wa_width) + wa_width - 1 downto (prcd_tmp_addra_dly_width * wa_width)), junk);
                          end if;

                          if (seq = "00") then
                            prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                          end if;
                        end if;
      
      when 8 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wa_width > wb_width) or seq = "10") then
                  if (wa_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 3));
                    prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth), memp(prcd_tmp_addra_dly_depth)(0));
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_bit_8 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(w_addra_bit_8 downto 3));
                    prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 8) + 7 downto (prcd_tmp_addra_dly_width * 8)), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width)));
                  end if;
  
                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;
                end if;

      when 16 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wa_width > wb_width) or seq = "10") then
                  if (wa_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                    prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)(7 downto 0), memp(prcd_tmp_addra_dly_depth)(0));
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_bit_16 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(w_addra_bit_16 downto 4));
                    prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 16) + 7 downto (prcd_tmp_addra_dly_width * 16)), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2)));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;
                 
                  if (wa_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                    prcd_write_ram_col (web_tmp(1), wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)(15 downto 8), memp(prcd_tmp_addra_dly_depth)(1));
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_bit_16 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(w_addra_bit_16 downto 4));
                    prcd_write_ram_col (web_tmp(1), wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 16) + 15 downto (prcd_tmp_addra_dly_width * 16) + 8), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2) + 1));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;
                 
                end if;

      when 32 => if (RAM_MODE /= "SDP") then
                   if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wa_width > wb_width) or seq = "10") then

                     prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 5));
                     prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)(7 downto 0), memp(prcd_tmp_addra_dly_depth)(0));

                     if (seq = "00") then
                       prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                     end if;

                     prcd_write_ram_col (web_tmp(1), wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)(15 downto 8), memp(prcd_tmp_addra_dly_depth)(1));

                     if (seq = "00") then
                       prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                     end if;
                   
                     prcd_write_ram_col (web_tmp(2), wea_tmp(2), dia_tmp(23 downto 16), dipa_tmp(2), mem(prcd_tmp_addra_dly_depth)(23 downto 16), memp(prcd_tmp_addra_dly_depth)(2));

                     if (seq = "00") then
                       prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(2), web_tmp(2), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                     end if;

                     prcd_write_ram_col (web_tmp(3), wea_tmp(3), dia_tmp(31 downto 24), dipa_tmp(3), mem(prcd_tmp_addra_dly_depth)(31 downto 24), memp(prcd_tmp_addra_dly_depth)(3));

                     if (seq = "00") then
                       prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(3), web_tmp(3), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                     end if;

                   end if;

                 end if;

      when 64 =>
                   prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 6));
                   prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)(7 downto 0), memp(prcd_tmp_addra_dly_depth)(0));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_col (web_tmp(1), wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)(15 downto 8), memp(prcd_tmp_addra_dly_depth)(1));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
                   
                   prcd_write_ram_col (web_tmp(2), wea_tmp(2), dia_tmp(23 downto 16), dipa_tmp(2), mem(prcd_tmp_addra_dly_depth)(23 downto 16), memp(prcd_tmp_addra_dly_depth)(2));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(2), web_tmp(2), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_col (web_tmp(3), wea_tmp(3), dia_tmp(31 downto 24), dipa_tmp(3), mem(prcd_tmp_addra_dly_depth)(31 downto 24), memp(prcd_tmp_addra_dly_depth)(3));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(3), web_tmp(3), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
  
                   prcd_write_ram_col (web_tmp(4), wea_tmp(4), dia_tmp(39 downto 32), dipa_tmp(4), mem(prcd_tmp_addra_dly_depth)(39 downto 32), memp(prcd_tmp_addra_dly_depth)(4));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(4), web_tmp(4), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_col (web_tmp(5), wea_tmp(5), dia_tmp(47 downto 40), dipa_tmp(5), mem(prcd_tmp_addra_dly_depth)(47 downto 40), memp(prcd_tmp_addra_dly_depth)(5));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(5), web_tmp(5), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_col (web_tmp(6), wea_tmp(6), dia_tmp(55 downto 48), dipa_tmp(6), mem(prcd_tmp_addra_dly_depth)(55 downto 48), memp(prcd_tmp_addra_dly_depth)(6));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(6), web_tmp(6), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_col (web_tmp(7), wea_tmp(7), dia_tmp(63 downto 56), dipa_tmp(7), mem(prcd_tmp_addra_dly_depth)(63 downto 56), memp(prcd_tmp_addra_dly_depth)(7));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(7), web_tmp(7), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
    
      when others => null;

    end case;

  end prcd_col_wr_ram_a;


  procedure prcd_ox_wr_ram_a (
    constant viol_type_tmp : in std_logic_vector (1 downto 0);
    constant seq : in std_logic_vector (1 downto 0);
    constant web_tmp : in std_logic_vector (7 downto 0);
    constant wea_tmp : in std_logic_vector (7 downto 0);
    constant dia_tmp : in std_logic_vector (63 downto 0);
    constant dipa_tmp : in std_logic_vector (7 downto 0);
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    constant addra_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type;
    variable ox_wr_wr_msg : inout std_ulogic;
    variable ox_wra_rdb_msg : inout std_ulogic;
    variable ox_wrb_rda_msg : inout std_ulogic;
    variable chk_col_same_clk_tmp : inout integer;
    variable chk_ox_same_clk_tmp : inout integer;
    variable chk_ox_msg_tmp : inout integer
    ) is
    variable prcd_tmp_addra_dly_depth : integer;
    variable prcd_tmp_addra_dly_width : integer;
    variable junk : std_ulogic;

  begin
    
    case wa_width is

      when 1 | 2 | 4 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wa_width > wb_width) or seq = "10") then
                          if (wa_width >= width) then
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_lbit_124));
                            prcd_write_ram_ox (web_tmp(0), wea_tmp(0), dia_tmp(wa_width-1 downto 0), '0', mem(prcd_tmp_addra_dly_depth), junk);
                          else
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_bit_124 + 1));
                            prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(w_addra_bit_124 downto w_addra_lbit_124));
                            prcd_write_ram_ox (web_tmp(0), wea_tmp(0), dia_tmp(wa_width-1 downto 0), '0', mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * wa_width) + wa_width - 1 downto (prcd_tmp_addra_dly_width * wa_width)), junk);
                          end if;

                          if (seq = "00") then
                            prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                          end if;
                        end if;
      
      when 8 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wa_width > wb_width) or seq = "10") then
                  if (wa_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 3));
                    prcd_write_ram_ox (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth), memp(prcd_tmp_addra_dly_depth)(0));
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_bit_8 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(w_addra_bit_8 downto 3));
                    prcd_write_ram_ox (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 8) + 7 downto (prcd_tmp_addra_dly_width * 8)), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width)));
                  end if;
  
                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;
                end if;

      when 16 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wa_width > wb_width) or seq = "10") then
                  if (wa_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                    prcd_write_ram_ox (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)(7 downto 0), memp(prcd_tmp_addra_dly_depth)(0));
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_bit_16 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(w_addra_bit_16 downto 4));
                    prcd_write_ram_ox (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 16) + 7 downto (prcd_tmp_addra_dly_width * 16)), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2)));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;
                 
                  if (wa_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                    prcd_write_ram_ox (web_tmp(1), wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)(15 downto 8), memp(prcd_tmp_addra_dly_depth)(1));
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_bit_16 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(w_addra_bit_16 downto 4));
                    prcd_write_ram_ox (web_tmp(1), wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 16) + 15 downto (prcd_tmp_addra_dly_width * 16) + 8), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2) + 1));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;
                 
                end if;

      when 32 => if (RAM_MODE /= "SDP") then
                   if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wa_width > wb_width) or seq = "10") then

                     prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 5));
                     prcd_write_ram_ox (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)(7 downto 0), memp(prcd_tmp_addra_dly_depth)(0));

                     if (seq = "00") then
                       prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                     end if;

                     prcd_write_ram_ox (web_tmp(1), wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)(15 downto 8), memp(prcd_tmp_addra_dly_depth)(1));

                     if (seq = "00") then
                       prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                     end if;
                   
                     prcd_write_ram_ox (web_tmp(2), wea_tmp(2), dia_tmp(23 downto 16), dipa_tmp(2), mem(prcd_tmp_addra_dly_depth)(23 downto 16), memp(prcd_tmp_addra_dly_depth)(2));

                     if (seq = "00") then
                       prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(2), web_tmp(2), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                     end if;

                     prcd_write_ram_ox (web_tmp(3), wea_tmp(3), dia_tmp(31 downto 24), dipa_tmp(3), mem(prcd_tmp_addra_dly_depth)(31 downto 24), memp(prcd_tmp_addra_dly_depth)(3));

                     if (seq = "00") then
                       prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(3), web_tmp(3), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                     end if;

                   end if;

                 end if;

        when 64 =>
                   prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 6));
                   prcd_write_ram_ox (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)(7 downto 0), memp(prcd_tmp_addra_dly_depth)(0));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_ox (web_tmp(1), wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)(15 downto 8), memp(prcd_tmp_addra_dly_depth)(1));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
                   
                   prcd_write_ram_ox (web_tmp(2), wea_tmp(2), dia_tmp(23 downto 16), dipa_tmp(2), mem(prcd_tmp_addra_dly_depth)(23 downto 16), memp(prcd_tmp_addra_dly_depth)(2));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(2), web_tmp(2), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_ox (web_tmp(3), wea_tmp(3), dia_tmp(31 downto 24), dipa_tmp(3), mem(prcd_tmp_addra_dly_depth)(31 downto 24), memp(prcd_tmp_addra_dly_depth)(3));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(3), web_tmp(3), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
  
                   prcd_write_ram_ox (web_tmp(4), wea_tmp(4), dia_tmp(39 downto 32), dipa_tmp(4), mem(prcd_tmp_addra_dly_depth)(39 downto 32), memp(prcd_tmp_addra_dly_depth)(4));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(4), web_tmp(4), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_ox (web_tmp(5), wea_tmp(5), dia_tmp(47 downto 40), dipa_tmp(5), mem(prcd_tmp_addra_dly_depth)(47 downto 40), memp(prcd_tmp_addra_dly_depth)(5));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(5), web_tmp(5), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_ox (web_tmp(6), wea_tmp(6), dia_tmp(55 downto 48), dipa_tmp(6), mem(prcd_tmp_addra_dly_depth)(55 downto 48), memp(prcd_tmp_addra_dly_depth)(6));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(6), web_tmp(6), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_ox (web_tmp(7), wea_tmp(7), dia_tmp(63 downto 56), dipa_tmp(7), mem(prcd_tmp_addra_dly_depth)(63 downto 56), memp(prcd_tmp_addra_dly_depth)(7));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(7), web_tmp(7), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
    
      when others => null;

    end case;

  end prcd_ox_wr_ram_a;

    
  procedure prcd_col_wr_ram_b (
    constant viol_type_tmp : in std_logic_vector (1 downto 0);
    constant seq : in std_logic_vector (1 downto 0);
    constant wea_tmp : in std_logic_vector (7 downto 0);
    constant web_tmp : in std_logic_vector (7 downto 0);
    constant dib_tmp : in std_logic_vector (63 downto 0);
    constant dipb_tmp : in std_logic_vector (7 downto 0);
    constant addra_tmp : in std_logic_vector (15 downto 0);
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type;
    variable col_wr_wr_msg : inout std_ulogic;
    variable col_wra_rdb_msg : inout std_ulogic;
    variable col_wrb_rda_msg : inout std_ulogic;
    variable chk_col_same_clk_tmp : inout integer;
    variable chk_ox_same_clk_tmp : inout integer;
    variable chk_ox_msg_tmp : inout integer
    ) is
    variable prcd_tmp_addrb_dly_depth : integer;
    variable prcd_tmp_addrb_dly_width : integer;
    variable junk : std_ulogic;

  begin
    
    case wb_width is

      when 1 | 2 | 4 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wb_width > wa_width) or seq = "10") then
                          if (wb_width >= width) then
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_lbit_124));
                            prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(wb_width-1 downto 0), '0', mem(prcd_tmp_addrb_dly_depth), junk);
                          else
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_124 + 1));
                            prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_124 downto w_addrb_lbit_124));
                            prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(wb_width-1 downto 0), '0', mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * wb_width) + wb_width - 1 downto (prcd_tmp_addrb_dly_width * wb_width)), junk);
                          end if;

                          if (seq = "00") then
                            prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                          end if;
                        end if;

      when 8 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wb_width > wa_width) or seq = "10") then
                  if (wb_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 3));
                    prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth), memp(prcd_tmp_addrb_dly_depth)(0));
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_8 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_8 downto 3));
                    prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 8) + 7 downto (prcd_tmp_addrb_dly_width * 8)), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width)));
                  end if;
    
                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if; 
                end if;

      when 16 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wb_width > wa_width) or seq = "10") then
                  if (wb_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                    prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)(7 downto 0), memp(prcd_tmp_addrb_dly_depth)(0));
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_16 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_16 downto 4));
                    prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 16) + 7 downto (prcd_tmp_addrb_dly_width * 16)), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2)));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;

                  if (wb_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                    prcd_write_ram_col (wea_tmp(1), web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)(15 downto 8), memp(prcd_tmp_addrb_dly_depth)(1));
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_16 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_16 downto 4));
                    prcd_write_ram_col (wea_tmp(1), web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 16) + 15 downto (prcd_tmp_addrb_dly_width * 16) + 8), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2) + 1));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;

                end if;
      when 32 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wb_width > wa_width) or seq = "10") then
                   
                   if (wb_width >= width) then
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                     prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)(7 downto 0), memp(prcd_tmp_addrb_dly_depth)(0));
                   else
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_32 + 1));
                     prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_32 downto 5));
                     prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 32) + 7 downto (prcd_tmp_addrb_dly_width * 32)), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 4)));
                   end if;
  
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
  
                   if (wb_width >= width) then
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                     prcd_write_ram_col (wea_tmp(1), web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)(15 downto 8), memp(prcd_tmp_addrb_dly_depth)(1));
                   else
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_32 + 1));
                     prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_32 downto 5));
                     prcd_write_ram_col (wea_tmp(1), web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 32) + 15 downto (prcd_tmp_addrb_dly_width * 32) + 8), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 4) + 1));
                   end if;
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
  
                   if (wb_width >= width) then 
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                     prcd_write_ram_col (wea_tmp(2), web_tmp(2), dib_tmp(23 downto 16), dipb_tmp(2), mem(prcd_tmp_addrb_dly_depth)(23 downto 16), memp(prcd_tmp_addrb_dly_depth)(2));
                   else
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_32 + 1));
                     prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_32 downto 5));
                     prcd_write_ram_col (wea_tmp(2), web_tmp(2), dib_tmp(23 downto 16), dipb_tmp(2), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 32) + 23 downto (prcd_tmp_addrb_dly_width * 32) + 16), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 4) + 2));
                   end if;
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(2), web_tmp(2), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
  
                   if (wb_width >= width) then 
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                     prcd_write_ram_col (wea_tmp(3), web_tmp(3), dib_tmp(31 downto 24), dipb_tmp(3), mem(prcd_tmp_addrb_dly_depth)(31 downto 24), memp(prcd_tmp_addrb_dly_depth)(3));
                   else
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_32 + 1));
                     prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_32 downto 5));
                     prcd_write_ram_col (wea_tmp(3), web_tmp(3), dib_tmp(31 downto 24), dipb_tmp(3), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 32) + 31 downto (prcd_tmp_addrb_dly_width * 32) + 24), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 4) + 3));
                  end if;
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(3), web_tmp(3), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
  
                 end if;
      when 64 =>
                   prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 6));
                   prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)(7 downto 0), memp(prcd_tmp_addrb_dly_depth)(0));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_col (wea_tmp(1), web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)(15 downto 8), memp(prcd_tmp_addrb_dly_depth)(1));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
                   
                   prcd_write_ram_col (wea_tmp(2), web_tmp(2), dib_tmp(23 downto 16), dipb_tmp(2), mem(prcd_tmp_addrb_dly_depth)(23 downto 16), memp(prcd_tmp_addrb_dly_depth)(2));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(2), web_tmp(2), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_col (wea_tmp(3), web_tmp(3), dib_tmp(31 downto 24), dipb_tmp(3), mem(prcd_tmp_addrb_dly_depth)(31 downto 24), memp(prcd_tmp_addrb_dly_depth)(3));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(3), web_tmp(3), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
  
                   prcd_write_ram_col (wea_tmp(4), web_tmp(4), dib_tmp(39 downto 32), dipb_tmp(4), mem(prcd_tmp_addrb_dly_depth)(39 downto 32), memp(prcd_tmp_addrb_dly_depth)(4));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(4), web_tmp(4), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_col (wea_tmp(5), web_tmp(5), dib_tmp(47 downto 40), dipb_tmp(5), mem(prcd_tmp_addrb_dly_depth)(47 downto 40), memp(prcd_tmp_addrb_dly_depth)(5));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(5), web_tmp(5), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_col (wea_tmp(6), web_tmp(6), dib_tmp(55 downto 48), dipb_tmp(6), mem(prcd_tmp_addrb_dly_depth)(55 downto 48), memp(prcd_tmp_addrb_dly_depth)(6));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(6), web_tmp(6), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_col (wea_tmp(7), web_tmp(7), dib_tmp(63 downto 56), dipb_tmp(7), mem(prcd_tmp_addrb_dly_depth)(63 downto 56), memp(prcd_tmp_addrb_dly_depth)(7));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(7), web_tmp(7), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

      when others => null;

    end case;

  end prcd_col_wr_ram_b;


  procedure prcd_ox_wr_ram_b (
    constant viol_type_tmp : in std_logic_vector (1 downto 0);
    constant seq : in std_logic_vector (1 downto 0);
    constant wea_tmp : in std_logic_vector (7 downto 0);
    constant web_tmp : in std_logic_vector (7 downto 0);
    constant dib_tmp : in std_logic_vector (63 downto 0);
    constant dipb_tmp : in std_logic_vector (7 downto 0);
    constant addra_tmp : in std_logic_vector (15 downto 0);
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type;
    variable ox_wr_wr_msg : inout std_ulogic;
    variable ox_wra_rdb_msg : inout std_ulogic;
    variable ox_wrb_rda_msg : inout std_ulogic;
    variable chk_col_same_clk_tmp : inout integer;
    variable chk_ox_same_clk_tmp : inout integer;
    variable chk_ox_msg_tmp : inout integer
    ) is
    variable prcd_tmp_addrb_dly_depth : integer;
    variable prcd_tmp_addrb_dly_width : integer;
    variable junk : std_ulogic;

  begin
    
    case wb_width is

      when 1 | 2 | 4 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wb_width > wa_width) or seq = "10") then
                          if (wb_width >= width) then
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_lbit_124));
                            prcd_write_ram_ox (wea_tmp(0), web_tmp(0), dib_tmp(wb_width-1 downto 0), '0', mem(prcd_tmp_addrb_dly_depth), junk);
                          else
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_124 + 1));
                            prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_124 downto w_addrb_lbit_124));
                            prcd_write_ram_ox (wea_tmp(0), web_tmp(0), dib_tmp(wb_width-1 downto 0), '0', mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * wb_width) + wb_width - 1 downto (prcd_tmp_addrb_dly_width * wb_width)), junk);
                          end if;

                          if (seq = "00") then
                            prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                          end if;
                        end if;

      when 8 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wb_width > wa_width) or seq = "10") then
                  if (wb_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 3));
                    prcd_write_ram_ox (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth), memp(prcd_tmp_addrb_dly_depth)(0));
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_8 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_8 downto 3));
                    prcd_write_ram_ox (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 8) + 7 downto (prcd_tmp_addrb_dly_width * 8)), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width)));
                  end if;
    
                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if; 
                end if;

      when 16 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wb_width > wa_width) or seq = "10") then
                  if (wb_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                    prcd_write_ram_ox (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)(7 downto 0), memp(prcd_tmp_addrb_dly_depth)(0));
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_16 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_16 downto 4));
                    prcd_write_ram_ox (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 16) + 7 downto (prcd_tmp_addrb_dly_width * 16)), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2)));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;

                  if (wb_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                    prcd_write_ram_ox (wea_tmp(1), web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)(15 downto 8), memp(prcd_tmp_addrb_dly_depth)(1));
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_16 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_16 downto 4));
                    prcd_write_ram_ox (wea_tmp(1), web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 16) + 15 downto (prcd_tmp_addrb_dly_width * 16) + 8), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2) + 1));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                  end if;

                end if;

      when 32 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wb_width > wa_width) or seq = "10") then
                   
                   if (wb_width >= width) then
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                     prcd_write_ram_ox (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)(7 downto 0), memp(prcd_tmp_addrb_dly_depth)(0));
                   else
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_32 + 1));
                     prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_32 downto 5));
                     prcd_write_ram_ox (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 32) + 7 downto (prcd_tmp_addrb_dly_width * 32)), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 4)));
                   end if;
  
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
  
                   if (wb_width >= width) then
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                     prcd_write_ram_ox (wea_tmp(1), web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)(15 downto 8), memp(prcd_tmp_addrb_dly_depth)(1));
                   else
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_32 + 1));
                     prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_32 downto 5));
                     prcd_write_ram_ox (wea_tmp(1), web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 32) + 15 downto (prcd_tmp_addrb_dly_width * 32) + 8), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 4) + 1));
                   end if;
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
  
                   if (wb_width >= width) then 
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                     prcd_write_ram_ox (wea_tmp(2), web_tmp(2), dib_tmp(23 downto 16), dipb_tmp(2), mem(prcd_tmp_addrb_dly_depth)(23 downto 16), memp(prcd_tmp_addrb_dly_depth)(2));
                   else
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_32 + 1));
                     prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_32 downto 5));
                     prcd_write_ram_ox (wea_tmp(2), web_tmp(2), dib_tmp(23 downto 16), dipb_tmp(2), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 32) + 23 downto (prcd_tmp_addrb_dly_width * 32) + 16), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 4) + 2));
                   end if;
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(2), web_tmp(2), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
  
                   if (wb_width >= width) then 
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                     prcd_write_ram_ox (wea_tmp(3), web_tmp(3), dib_tmp(31 downto 24), dipb_tmp(3), mem(prcd_tmp_addrb_dly_depth)(31 downto 24), memp(prcd_tmp_addrb_dly_depth)(3));
                   else
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_32 + 1));
                     prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_32 downto 5));
                     prcd_write_ram_ox (wea_tmp(3), web_tmp(3), dib_tmp(31 downto 24), dipb_tmp(3), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 32) + 31 downto (prcd_tmp_addrb_dly_width * 32) + 24), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 4) + 3));
                  end if;
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(3), web_tmp(3), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
  
                 end if;

      when 64 =>
                   prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 6));
                   prcd_write_ram_ox (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)(7 downto 0), memp(prcd_tmp_addrb_dly_depth)(0));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_ox (wea_tmp(1), web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)(15 downto 8), memp(prcd_tmp_addrb_dly_depth)(1));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
                   
                   prcd_write_ram_ox (wea_tmp(2), web_tmp(2), dib_tmp(23 downto 16), dipb_tmp(2), mem(prcd_tmp_addrb_dly_depth)(23 downto 16), memp(prcd_tmp_addrb_dly_depth)(2));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(2), web_tmp(2), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_ox (wea_tmp(3), web_tmp(3), dib_tmp(31 downto 24), dipb_tmp(3), mem(prcd_tmp_addrb_dly_depth)(31 downto 24), memp(prcd_tmp_addrb_dly_depth)(3));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(3), web_tmp(3), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;
  
                   prcd_write_ram_ox (wea_tmp(4), web_tmp(4), dib_tmp(39 downto 32), dipb_tmp(4), mem(prcd_tmp_addrb_dly_depth)(39 downto 32), memp(prcd_tmp_addrb_dly_depth)(4));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(4), web_tmp(4), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_ox (wea_tmp(5), web_tmp(5), dib_tmp(47 downto 40), dipb_tmp(5), mem(prcd_tmp_addrb_dly_depth)(47 downto 40), memp(prcd_tmp_addrb_dly_depth)(5));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(5), web_tmp(5), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_ox (wea_tmp(6), web_tmp(6), dib_tmp(55 downto 48), dipb_tmp(6), mem(prcd_tmp_addrb_dly_depth)(55 downto 48), memp(prcd_tmp_addrb_dly_depth)(6));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(6), web_tmp(6), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

                   prcd_write_ram_ox (wea_tmp(7), web_tmp(7), dib_tmp(63 downto 56), dipb_tmp(7), mem(prcd_tmp_addrb_dly_depth)(63 downto 56), memp(prcd_tmp_addrb_dly_depth)(7));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (viol_type_tmp, wea_tmp(7), web_tmp(7), addra_tmp, addrb_tmp, ox_wr_wr_msg, ox_wra_rdb_msg, ox_wrb_rda_msg, chk_col_same_clk_tmp, chk_ox_same_clk_tmp, chk_ox_msg_tmp);
                   end if;

      when others => null;

    end case;

  end prcd_ox_wr_ram_b;

    
  procedure prcd_col_rd_ram_a (
    constant viol_type_tmp : in std_logic_vector (1 downto 0);
    constant seq : in std_logic_vector (1 downto 0);
    constant web_tmp : in std_logic_vector (7 downto 0);
    constant wea_tmp : in std_logic_vector (7 downto 0);
    constant addra_tmp : in std_logic_vector (15 downto 0);
    variable doa_tmp : inout std_logic_vector (63 downto 0);
    variable dopa_tmp : inout std_logic_vector (7 downto 0);
    constant mem : in Two_D_array_type;
    constant memp : in Two_D_parity_array_type;
    constant wr_mode_a_tmp : in std_logic_vector (1 downto 0)

    ) is
    variable prcd_tmp_addra_dly_depth : integer;
    variable prcd_tmp_addra_dly_width : integer;
    variable junk : std_ulogic;
    variable doa_ltmp : std_logic_vector (63 downto 0);
    variable dopa_ltmp : std_logic_vector (7 downto 0);
    
  begin

    doa_ltmp := (others => '0');
    dopa_ltmp := (others => '0');
    
    case ra_width is
      
      when 1 | 2 | 4 => if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and web_tmp(0) = '1' and wea_tmp(0) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(0) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(0) /= '1')) then

                          if (ra_width >= width) then
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto r_addra_lbit_124));
                            doa_ltmp(ra_width-1 downto 0) := mem(prcd_tmp_addra_dly_depth);
                          else
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto r_addra_bit_124 + 1));
                            prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(r_addra_bit_124 downto r_addra_lbit_124));
                            doa_ltmp(ra_width-1 downto 0) := mem(prcd_tmp_addra_dly_depth)(((prcd_tmp_addra_dly_width * ra_width) + ra_width - 1) downto (prcd_tmp_addra_dly_width * ra_width));

                          end if;
                          prcd_x_buf (wr_mode_a_tmp, 3, 0, 0, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);
                        end if;

      when 8 => if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and web_tmp(0) = '1' and wea_tmp(0) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(0) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(0) /= '1')) then

                  if (ra_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 3));
                    doa_ltmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth);
                    dopa_ltmp(0) := memp(prcd_tmp_addra_dly_depth)(0);
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto r_addra_bit_8 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(r_addra_bit_8 downto 3));
                    doa_ltmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth)(((prcd_tmp_addra_dly_width * 8) + 7) downto (prcd_tmp_addra_dly_width * 8));
                    dopa_ltmp(0) := memp(prcd_tmp_addra_dly_depth)(prcd_tmp_addra_dly_width);
                  end if;
                  prcd_x_buf (wr_mode_a_tmp, 7, 0, 0, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                end if;

      when 16 => if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and web_tmp(0) = '1' and wea_tmp(0) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(0) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(0) /= '1')) then

                  if (ra_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                    doa_ltmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth)(7 downto 0);
                    dopa_ltmp(0) := memp(prcd_tmp_addra_dly_depth)(0);
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto r_addra_bit_16 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(r_addra_bit_16 downto 4));

                    doa_ltmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth)(((prcd_tmp_addra_dly_width * 16) + 7) downto (prcd_tmp_addra_dly_width * 16));                    
                    dopa_ltmp(0) := memp(prcd_tmp_addra_dly_depth)(prcd_tmp_addra_dly_width * 2);
                  end if;
                  prcd_x_buf (wr_mode_a_tmp, 7, 0, 0, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                end if;

                if ((web_tmp(1) = '1' and wea_tmp(1) = '1') or (seq = "01" and web_tmp(1) = '1' and wea_tmp(1) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(1) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(1) /= '1')) then

                  if (ra_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                    doa_ltmp(15 downto 8) := mem(prcd_tmp_addra_dly_depth)(15 downto 8);
                    dopa_ltmp(1) := memp(prcd_tmp_addra_dly_depth)(1);
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto r_addra_bit_16 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(r_addra_bit_16 downto 4));

                    doa_ltmp(15 downto 8) := mem(prcd_tmp_addra_dly_depth)(((prcd_tmp_addra_dly_width * 16) + 15) downto ((prcd_tmp_addra_dly_width * 16) + 8));
                    dopa_ltmp(1) := memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2) + 1);
                  end if;
                  prcd_x_buf (wr_mode_a_tmp, 15, 8, 1, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);
                  
                end if;

      when 32 => if (ra_width >= width) then

                   prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 5));

                   if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and web_tmp(0) = '1' and wea_tmp(0) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(0) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(0) /= '1')) then

                     doa_ltmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth)(7 downto 0);
                     dopa_ltmp(0) := memp(prcd_tmp_addra_dly_depth)(0);
                     prcd_x_buf (wr_mode_a_tmp, 7, 0, 0, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(1) = '1' and wea_tmp(1) = '1') or (seq = "01" and web_tmp(1) = '1' and wea_tmp(1) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(1) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(1) /= '1')) then

                     doa_ltmp(15 downto 8) := mem(prcd_tmp_addra_dly_depth)(15 downto 8);
                     dopa_ltmp(1) := memp(prcd_tmp_addra_dly_depth)(1);
                     prcd_x_buf (wr_mode_a_tmp, 15, 8, 1, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(2) = '1' and wea_tmp(2) = '1') or (seq = "01" and web_tmp(2) = '1' and wea_tmp(2) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(2) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(2) /= '1')) then

                     doa_ltmp(23 downto 16) := mem(prcd_tmp_addra_dly_depth)(23 downto 16);
                     dopa_ltmp(2) := memp(prcd_tmp_addra_dly_depth)(2);
                     prcd_x_buf (wr_mode_a_tmp, 23, 16, 2, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(3) = '1' and wea_tmp(3) = '1') or (seq = "01" and web_tmp(3) = '1' and wea_tmp(3) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(3) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(3) /= '1')) then

                     doa_ltmp(31 downto 24) := mem(prcd_tmp_addra_dly_depth)(31 downto 24);
                     dopa_ltmp(3) := memp(prcd_tmp_addra_dly_depth)(3);
                     prcd_x_buf (wr_mode_a_tmp, 31, 24, 3, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;
  
                end if;
  
      when 64 =>
                   prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 6));

                   if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and web_tmp(0) = '1' and wea_tmp(0) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(0) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(0) /= '1')) then

                     doa_ltmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth)(7 downto 0);
                     dopa_ltmp(0) := memp(prcd_tmp_addra_dly_depth)(0);
                     prcd_x_buf (wr_mode_a_tmp, 7, 0, 0, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(1) = '1' and wea_tmp(1) = '1') or (seq = "01" and web_tmp(1) = '1' and wea_tmp(1) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(1) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(1) /= '1')) then

                     doa_ltmp(15 downto 8) := mem(prcd_tmp_addra_dly_depth)(15 downto 8);
                     dopa_ltmp(1) := memp(prcd_tmp_addra_dly_depth)(1);
                     prcd_x_buf (wr_mode_a_tmp, 15, 8, 1, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(2) = '1' and wea_tmp(2) = '1') or (seq = "01" and web_tmp(2) = '1' and wea_tmp(2) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(2) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(2) /= '1')) then

                     doa_ltmp(23 downto 16) := mem(prcd_tmp_addra_dly_depth)(23 downto 16);
                     dopa_ltmp(2) := memp(prcd_tmp_addra_dly_depth)(2);
                     prcd_x_buf (wr_mode_a_tmp, 23, 16, 2, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(3) = '1' and wea_tmp(3) = '1') or (seq = "01" and web_tmp(3) = '1' and wea_tmp(3) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(3) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(3) /= '1')) then

                     doa_ltmp(31 downto 24) := mem(prcd_tmp_addra_dly_depth)(31 downto 24);
                     dopa_ltmp(3) := memp(prcd_tmp_addra_dly_depth)(3);
                     prcd_x_buf (wr_mode_a_tmp, 31, 24, 3, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(4) = '1' and wea_tmp(4) = '1') or (seq = "01" and web_tmp(4) = '1' and wea_tmp(4) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(4) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(4) /= '1')) then

                     doa_ltmp(39 downto 32) := mem(prcd_tmp_addra_dly_depth)(39 downto 32);
                     dopa_ltmp(4) := memp(prcd_tmp_addra_dly_depth)(4);
                     prcd_x_buf (wr_mode_a_tmp, 39, 32, 4, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(5) = '1' and wea_tmp(5) = '1') or (seq = "01" and web_tmp(5) = '1' and wea_tmp(5) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(5) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(5) /= '1')) then

                     doa_ltmp(47 downto 40) := mem(prcd_tmp_addra_dly_depth)(47 downto 40);
                     dopa_ltmp(5) := memp(prcd_tmp_addra_dly_depth)(5);
                     prcd_x_buf (wr_mode_a_tmp, 47, 40, 5, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(6) = '1' and wea_tmp(6) = '1') or (seq = "01" and web_tmp(6) = '1' and wea_tmp(6) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(6) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(6) /= '1')) then

                     doa_ltmp(55 downto 48) := mem(prcd_tmp_addra_dly_depth)(55 downto 48);
                     dopa_ltmp(6) := memp(prcd_tmp_addra_dly_depth)(6);
                     prcd_x_buf (wr_mode_a_tmp, 55, 48, 6, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(7) = '1' and wea_tmp(7) = '1') or (seq = "01" and web_tmp(7) = '1' and wea_tmp(7) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(7) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(7) /= '1')) then

                     doa_ltmp(63 downto 56) := mem(prcd_tmp_addra_dly_depth)(63 downto 56);
                     dopa_ltmp(7) := memp(prcd_tmp_addra_dly_depth)(7);
                     prcd_x_buf (wr_mode_a_tmp, 63, 56, 7, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;
    
      when others => null;

    end case;

  end prcd_col_rd_ram_a;


  procedure prcd_col_rd_ram_b (
    constant viol_type_tmp : in std_logic_vector (1 downto 0);
    constant seq : in std_logic_vector (1 downto 0);
    constant wea_tmp : in std_logic_vector (7 downto 0);
    constant web_tmp : in std_logic_vector (7 downto 0);
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    variable dob_tmp : inout std_logic_vector (63 downto 0);
    variable dopb_tmp : inout std_logic_vector (7 downto 0);
    constant mem : in Two_D_array_type;
    constant memp : in Two_D_parity_array_type;
    constant wr_mode_b_tmp : in std_logic_vector (1 downto 0)

    ) is
    variable prcd_tmp_addrb_dly_depth : integer;
    variable prcd_tmp_addrb_dly_width : integer;
    variable junk : std_ulogic;
    variable dob_ltmp : std_logic_vector (63 downto 0);
    variable dopb_ltmp : std_logic_vector (7 downto 0);
    
  begin

    dob_ltmp := (others => '0');
    dopb_ltmp := (others => '0');
    
    case rb_width is
      
      when 1 | 2 | 4 => if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and wea_tmp(0) = '1' and web_tmp(0) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(0) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(0) /= '1')) then

                          if (rb_width >= width) then
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_lbit_124));
                            dob_ltmp(rb_width-1 downto 0) := mem(prcd_tmp_addrb_dly_depth);
                          else
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_bit_124 + 1));
                            prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(r_addrb_bit_124 downto r_addrb_lbit_124));
                            dob_ltmp(rb_width-1 downto 0) := mem(prcd_tmp_addrb_dly_depth)(((prcd_tmp_addrb_dly_width * rb_width) + rb_width - 1) downto (prcd_tmp_addrb_dly_width * rb_width));
                          end if;
                          prcd_x_buf (wr_mode_b_tmp, 3, 0, 0, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                        end if;

      when 8 => if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and wea_tmp(0) = '1' and web_tmp(0) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(0) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(0) /= '1')) then

                  if (rb_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 3));
                    dob_ltmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth);
                    dopb_ltmp(0) := memp(prcd_tmp_addrb_dly_depth)(0);
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_bit_8 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(r_addrb_bit_8 downto 3));
                    dob_ltmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth)(((prcd_tmp_addrb_dly_width * 8) + 7) downto (prcd_tmp_addrb_dly_width * 8));
                    dopb_ltmp(0) := memp(prcd_tmp_addrb_dly_depth)(prcd_tmp_addrb_dly_width);
                  end if;
                  prcd_x_buf (wr_mode_b_tmp, 7, 0, 0, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                end if;

      when 16 => if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and wea_tmp(0) = '1' and web_tmp(0) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(0) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(0) /= '1')) then

                  if (rb_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                    dob_ltmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth)(7 downto 0);
                    dopb_ltmp(0) := memp(prcd_tmp_addrb_dly_depth)(0);
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_bit_16 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(r_addrb_bit_16 downto 4));

                    dob_ltmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth)(((prcd_tmp_addrb_dly_width * 16) + 7) downto (prcd_tmp_addrb_dly_width * 16));
                    dopb_ltmp(0) := memp(prcd_tmp_addrb_dly_depth)(prcd_tmp_addrb_dly_width * 2);
                  end if;
                  prcd_x_buf (wr_mode_b_tmp, 7, 0, 0, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                end if;


                if ((web_tmp(1) = '1' and wea_tmp(1) = '1') or (seq = "01" and wea_tmp(1) = '1' and web_tmp(1) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(1) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(1) /= '1')) then

                  if (rb_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                    dob_ltmp(15 downto 8) := mem(prcd_tmp_addrb_dly_depth)(15 downto 8);
                    dopb_ltmp(1) := memp(prcd_tmp_addrb_dly_depth)(1);
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_bit_16 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(r_addrb_bit_16 downto 4));

                    dob_ltmp(15 downto 8) := mem(prcd_tmp_addrb_dly_depth)(((prcd_tmp_addrb_dly_width * 16) + 15) downto ((prcd_tmp_addrb_dly_width * 16) + 8));
                    dopb_ltmp(1) := memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2) + 1);
                  end if;
                  prcd_x_buf (wr_mode_b_tmp, 15, 8, 1, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                end if;

      when 32 => if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and wea_tmp(0) = '1' and web_tmp(0) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(0) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(0) /= '1')) then

                   if (rb_width >= width) then
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                     dob_ltmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth)(7 downto 0);
                     dopb_ltmp(0) := memp(prcd_tmp_addrb_dly_depth)(0);
                   else
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_bit_32 + 1));
                     prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(r_addrb_bit_32 downto 5));

                     dob_ltmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth)(((prcd_tmp_addrb_dly_width * 32) + 7) downto (prcd_tmp_addrb_dly_width * 32));
                     dopb_ltmp(0) := memp(prcd_tmp_addrb_dly_depth)(prcd_tmp_addrb_dly_width * 4);
                   end if;
                   prcd_x_buf (wr_mode_b_tmp, 7, 0, 0, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                 end if;


                 if ((web_tmp(1) = '1' and wea_tmp(1) = '1') or (seq = "01" and wea_tmp(1) = '1' and web_tmp(1) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(1) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(1) /= '1')) then

                   if (rb_width >= width) then
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                     dob_ltmp(15 downto 8) := mem(prcd_tmp_addrb_dly_depth)(15 downto 8);
                     dopb_ltmp(1) := memp(prcd_tmp_addrb_dly_depth)(1);
                   else
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_bit_32 + 1));
                     prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(r_addrb_bit_32 downto 5));

                     dob_ltmp(15 downto 8) := mem(prcd_tmp_addrb_dly_depth)(((prcd_tmp_addrb_dly_width * 32) + 15) downto (prcd_tmp_addrb_dly_width * 32) + 8);
                     dopb_ltmp(1) := memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 4) + 1);
                   end if;
                   prcd_x_buf (wr_mode_b_tmp, 15, 8, 1, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                 end if;


                 if ((web_tmp(2) = '1' and wea_tmp(2) = '1') or (seq = "01" and wea_tmp(2) = '1' and web_tmp(2) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(2) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(2) /= '1')) then

                   if (rb_width >= width) then
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                     dob_ltmp(23 downto 16) := mem(prcd_tmp_addrb_dly_depth)(23 downto 16);
                     dopb_ltmp(2) := memp(prcd_tmp_addrb_dly_depth)(2);
                   else
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_bit_32 + 1));
                     prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(r_addrb_bit_32 downto 5));

                     dob_ltmp(23 downto 16) := mem(prcd_tmp_addrb_dly_depth)(((prcd_tmp_addrb_dly_width * 32) + 23) downto (prcd_tmp_addrb_dly_width * 32) + 16);
                     dopb_ltmp(2) := memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 4) + 2);
                   end if;
                   prcd_x_buf (wr_mode_b_tmp, 23, 16, 2, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);    

                 end if;
    

                 if ((web_tmp(3) = '1' and wea_tmp(3) = '1') or (seq = "01" and wea_tmp(3) = '1' and web_tmp(3) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(3) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(3) /= '1')) then

                   if (rb_width >= width) then
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                     dob_ltmp(31 downto 24) := mem(prcd_tmp_addrb_dly_depth)(31 downto 24);
                     dopb_ltmp(3) := memp(prcd_tmp_addrb_dly_depth)(3);
                   else
                     prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_bit_32 + 1));
                     prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(r_addrb_bit_32 downto 5));

                     dob_ltmp(31 downto 24) := mem(prcd_tmp_addrb_dly_depth)(((prcd_tmp_addrb_dly_width * 32) + 31) downto (prcd_tmp_addrb_dly_width * 32) + 24);
                     dopb_ltmp(3) := memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 4) + 3);
                   end if;
                     prcd_x_buf (wr_mode_b_tmp, 31, 24, 3, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);
                 end if;

    
      when 64 =>
                   prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 6));

                   if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and wea_tmp(0) = '1' and web_tmp(0) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(0) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(0) /= '1')) then

                     dob_ltmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth)(7 downto 0);
                     dopb_ltmp(0) := memp(prcd_tmp_addrb_dly_depth)(0);
                     prcd_x_buf (wr_mode_b_tmp, 7, 0, 0, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;

                   if ((web_tmp(1) = '1' and wea_tmp(1) = '1') or (seq = "01" and wea_tmp(1) = '1' and web_tmp(1) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(1) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(1) /= '1')) then

                     dob_ltmp(15 downto 8) := mem(prcd_tmp_addrb_dly_depth)(15 downto 8);
                     dopb_ltmp(1) := memp(prcd_tmp_addrb_dly_depth)(1);
                     prcd_x_buf (wr_mode_b_tmp, 15, 8, 1, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;

                   if ((web_tmp(2) = '1' and wea_tmp(2) = '1') or (seq = "01" and wea_tmp(2) = '1' and web_tmp(2) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(2) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(2) /= '1')) then

                     dob_ltmp(23 downto 16) := mem(prcd_tmp_addrb_dly_depth)(23 downto 16);
                     dopb_ltmp(2) := memp(prcd_tmp_addrb_dly_depth)(2);
                     prcd_x_buf (wr_mode_b_tmp, 23, 16, 2, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;

                   if ((web_tmp(3) = '1' and wea_tmp(3) = '1') or (seq = "01" and wea_tmp(3) = '1' and web_tmp(3) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(3) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(3) /= '1')) then

                     dob_ltmp(31 downto 24) := mem(prcd_tmp_addrb_dly_depth)(31 downto 24);
                     dopb_ltmp(3) := memp(prcd_tmp_addrb_dly_depth)(3);
                     prcd_x_buf (wr_mode_b_tmp, 31, 24, 3, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;

                   if ((web_tmp(4) = '1' and wea_tmp(4) = '1') or (seq = "01" and wea_tmp(4) = '1' and web_tmp(4) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(4) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(4) /= '1')) then

                     dob_ltmp(39 downto 32) := mem(prcd_tmp_addrb_dly_depth)(39 downto 32);
                     dopb_ltmp(4) := memp(prcd_tmp_addrb_dly_depth)(4);
                     prcd_x_buf (wr_mode_b_tmp, 39, 32, 4, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;
  
                   if ((web_tmp(5) = '1' and wea_tmp(5) = '1') or (seq = "01" and wea_tmp(5) = '1' and web_tmp(5) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(5) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(5) /= '1')) then

                     dob_ltmp(47 downto 40) := mem(prcd_tmp_addrb_dly_depth)(47 downto 40);
                     dopb_ltmp(5) := memp(prcd_tmp_addrb_dly_depth)(5);
                     prcd_x_buf (wr_mode_b_tmp, 47, 40, 5, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;

                   if ((web_tmp(6) = '1' and wea_tmp(6) = '1') or (seq = "01" and wea_tmp(6) = '1' and web_tmp(6) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(6) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(6) /= '1')) then

                     dob_ltmp(55 downto 48) := mem(prcd_tmp_addrb_dly_depth)(55 downto 48);
                     dopb_ltmp(6) := memp(prcd_tmp_addrb_dly_depth)(6);
                     prcd_x_buf (wr_mode_b_tmp, 55, 48, 6, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;
  
                   if ((web_tmp(7) = '1' and wea_tmp(7) = '1') or (seq = "01" and wea_tmp(7) = '1' and web_tmp(7) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(7) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(7) /= '1')) then

                     dob_ltmp(63 downto 56) := mem(prcd_tmp_addrb_dly_depth)(63 downto 56);
                     dopb_ltmp(7) := memp(prcd_tmp_addrb_dly_depth)(7);
                     prcd_x_buf (wr_mode_b_tmp, 63, 56, 7, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;
    
      when others => null;

    end case;

  end prcd_col_rd_ram_b;


  procedure prcd_wr_ram_a (
    constant wea_tmp : in std_logic_vector (7 downto 0);
    constant dia_tmp : in std_logic_vector (63 downto 0);
    constant dipa_tmp : in std_logic_vector (7 downto 0);
    constant addra_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type;
    constant syndrome_tmp : in std_logic_vector (7 downto 0)
    ) is
    variable prcd_tmp_addra_dly_depth : integer;
    variable prcd_tmp_addra_dly_width : integer;
    variable junk : std_ulogic;

  begin
    
    case wa_width is

      when 1 | 2 | 4 =>
                          if (wa_width >= width) then
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_lbit_124));
                            prcd_write_ram (wea_tmp(0), dia_tmp(wa_width-1 downto 0), '0', mem(prcd_tmp_addra_dly_depth), junk);
                          else
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_bit_124 + 1));
                            prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(w_addra_bit_124 downto w_addra_lbit_124));
                            prcd_write_ram (wea_tmp(0), dia_tmp(wa_width-1 downto 0), '0', mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * wa_width) + wa_width - 1 downto (prcd_tmp_addra_dly_width * wa_width)), junk);
                          end if;

      when 8 =>
                  if (wa_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 3));
                    prcd_write_ram (wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth), memp(prcd_tmp_addra_dly_depth)(0));
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_bit_8 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(w_addra_bit_8 downto 3));
                    prcd_write_ram (wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 8) + 7 downto (prcd_tmp_addra_dly_width * 8)), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width)));
                  end if;
  
      when 16 =>
                  if (wa_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                    prcd_write_ram (wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)(7 downto 0), memp(prcd_tmp_addra_dly_depth)(0));
                    prcd_write_ram (wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)(15 downto 8), memp(prcd_tmp_addra_dly_depth)(1));
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_bit_16 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(w_addra_bit_16 downto 4));
                    prcd_write_ram (wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 16) + 7 downto (prcd_tmp_addra_dly_width * 16)), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2)));
                    prcd_write_ram (wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 16) + 15 downto (prcd_tmp_addra_dly_width * 16) + 8), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2) + 1));
                  end if;

      when 32 =>
                  if (RAM_MODE /= "SDP") then
                    
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 5));

                    prcd_write_ram (wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)(7 downto 0), memp(prcd_tmp_addra_dly_depth)(0));
                    prcd_write_ram (wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)(15 downto 8), memp(prcd_tmp_addra_dly_depth)(1));
                    prcd_write_ram (wea_tmp(2), dia_tmp(23 downto 16), dipa_tmp(2), mem(prcd_tmp_addra_dly_depth)(23 downto 16), memp(prcd_tmp_addra_dly_depth)(2));
                    prcd_write_ram (wea_tmp(3), dia_tmp(31 downto 24), dipa_tmp(3), mem(prcd_tmp_addra_dly_depth)(31 downto 24), memp(prcd_tmp_addra_dly_depth)(3));

                  end if;
                  
      when others => null;

    end case;

  end prcd_wr_ram_a;


  procedure prcd_wr_ram_b (
    constant web_tmp : in std_logic_vector (7 downto 0);
    constant dib_tmp : in std_logic_vector (63 downto 0);
    constant dipb_tmp : in std_logic_vector (7 downto 0);
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type     
    ) is
    variable prcd_tmp_addrb_dly_depth : integer;
    variable prcd_tmp_addrb_dly_width : integer;
    variable junk : std_ulogic;

  begin
    
    case wb_width is

      when 1 | 2 | 4 =>
                          if (wb_width >= width) then
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_lbit_124));
                            prcd_write_ram (web_tmp(0), dib_tmp(wb_width-1 downto 0), '0', mem(prcd_tmp_addrb_dly_depth), junk);
                          else
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_124 + 1));
                            prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_124 downto w_addrb_lbit_124));
                            prcd_write_ram (web_tmp(0), dib_tmp(wb_width-1 downto 0), '0', mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * wb_width) + wb_width - 1 downto (prcd_tmp_addrb_dly_width * wb_width)), junk);
                          end if;

      when 8 => 
                  if (wb_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 3));
                    prcd_write_ram (web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth), memp(prcd_tmp_addrb_dly_depth)(0));
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_8 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_8 downto 3));
                    prcd_write_ram (web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 8) + 7 downto (prcd_tmp_addrb_dly_width * 8)), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width)));
                  end if;
  
      when 16 =>
                  if (wb_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                    prcd_write_ram (web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)(7 downto 0), memp(prcd_tmp_addrb_dly_depth)(0));
                    prcd_write_ram (web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)(15 downto 8), memp(prcd_tmp_addrb_dly_depth)(1));
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_16 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_16 downto 4));
                    prcd_write_ram (web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 16) + 7 downto (prcd_tmp_addrb_dly_width * 16)), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2)));
                    prcd_write_ram (web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 16) + 15 downto (prcd_tmp_addrb_dly_width * 16) + 8), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2) + 1));
                  end if;

      when 32 =>
                 if (wb_width >= width) then
                   prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                   prcd_write_ram (web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)(7 downto 0), memp(prcd_tmp_addrb_dly_depth)(0));
                   prcd_write_ram (web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)(15 downto 8), memp(prcd_tmp_addrb_dly_depth)(1));
                   prcd_write_ram (web_tmp(2), dib_tmp(23 downto 16), dipb_tmp(2), mem(prcd_tmp_addrb_dly_depth)(23 downto 16), memp(prcd_tmp_addrb_dly_depth)(2));
                   prcd_write_ram (web_tmp(3), dib_tmp(31 downto 24), dipb_tmp(3), mem(prcd_tmp_addrb_dly_depth)(31 downto 24), memp(prcd_tmp_addrb_dly_depth)(3));

                 else
                   prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_32 + 1));
                   prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_32 downto 5));
                   prcd_write_ram (web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 32) + 7 downto (prcd_tmp_addrb_dly_width * 32)), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 4)));
                   prcd_write_ram (web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 32) + 15 downto (prcd_tmp_addrb_dly_width * 32) + 8), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 4) + 1));
                   prcd_write_ram (web_tmp(2), dib_tmp(23 downto 16), dipb_tmp(2), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 32) + 23 downto (prcd_tmp_addrb_dly_width * 32) + 16), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 4) + 2));
                   prcd_write_ram (web_tmp(3), dib_tmp(31 downto 24), dipb_tmp(3), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 32) + 31 downto (prcd_tmp_addrb_dly_width * 32) + 24), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 4) + 3));
                 end if;

                   
      when 64 =>
                   prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 6));
                   prcd_write_ram (web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)(7 downto 0), memp(prcd_tmp_addrb_dly_depth)(0));
                   prcd_write_ram (web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)(15 downto 8), memp(prcd_tmp_addrb_dly_depth)(1));
                   prcd_write_ram (web_tmp(2), dib_tmp(23 downto 16), dipb_tmp(2), mem(prcd_tmp_addrb_dly_depth)(23 downto 16), memp(prcd_tmp_addrb_dly_depth)(2));
                   prcd_write_ram (web_tmp(3), dib_tmp(31 downto 24), dipb_tmp(3), mem(prcd_tmp_addrb_dly_depth)(31 downto 24), memp(prcd_tmp_addrb_dly_depth)(3));
                   prcd_write_ram (web_tmp(4), dib_tmp(39 downto 32), dipb_tmp(4), mem(prcd_tmp_addrb_dly_depth)(39 downto 32), memp(prcd_tmp_addrb_dly_depth)(4));
                   prcd_write_ram (web_tmp(5), dib_tmp(47 downto 40), dipb_tmp(5), mem(prcd_tmp_addrb_dly_depth)(47 downto 40), memp(prcd_tmp_addrb_dly_depth)(5));
                   prcd_write_ram (web_tmp(6), dib_tmp(55 downto 48), dipb_tmp(6), mem(prcd_tmp_addrb_dly_depth)(55 downto 48), memp(prcd_tmp_addrb_dly_depth)(6));
                   prcd_write_ram (web_tmp(7), dib_tmp(63 downto 56), dipb_tmp(7), mem(prcd_tmp_addrb_dly_depth)(63 downto 56), memp(prcd_tmp_addrb_dly_depth)(7));

      when others => null;

    end case;

  end prcd_wr_ram_b;
    
    
  procedure prcd_col_ecc_read (

    variable do_tmp : inout std_logic_vector (63 downto 0);
    variable dop_tmp : inout std_logic_vector (7 downto 0);
    constant addr_tmp : in std_logic_vector (15 downto 0);
    variable dbiterr_tmp : inout std_logic;
    variable sbiterr_tmp : inout std_logic;
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type;
    variable prcd_syndrome : inout std_logic_vector (7 downto 0)
    ) is

    variable prcd_ecc_bit_position : std_logic_vector (71 downto 0);
    variable prcd_dopr_ecc : std_logic_vector (7 downto 0);
    variable prcd_di_dly_ecc_corrected : std_logic_vector (63 downto 0);
    variable prcd_dip_dly_ecc_corrected : std_logic_vector (7 downto 0);
    variable prcd_tmp_syndrome_int : integer := 0;
    variable x_break : integer := 0;
    
  begin

    
    for i in 0 to 63 loop
      if (do_tmp(i) = 'X') then
        x_break := 1;
      end if;
    end loop;

    
    if (x_break = 1) then

      dbiterr_tmp := 'X';
      sbiterr_tmp := 'X';

    else
  
      prcd_dopr_ecc := fn_dip_ecc('0', do_tmp, dop_tmp);

      prcd_syndrome := prcd_dopr_ecc xor dop_tmp;

      if (prcd_syndrome /= "00000000") then

        if (prcd_syndrome(7) = '1') then  -- dectect single bit error

          prcd_ecc_bit_position := do_tmp(63 downto 57) & dop_tmp(6) & do_tmp(56 downto 26) & dop_tmp(5) & do_tmp(25 downto 11) & dop_tmp(4) & do_tmp(10 downto 4) & dop_tmp(3) & do_tmp(3 downto 1) & dop_tmp(2) & do_tmp(0) & dop_tmp(1 downto 0) & dop_tmp(7);

          prcd_tmp_syndrome_int := SLV_TO_INT(prcd_syndrome(6 downto 0));

          if (prcd_tmp_syndrome_int > 71) then
            assert false
              report "DRC Error : Simulation halted due Corrupted DIP. To correct this problem, make sure that reliable data is fed to the DIP. The correct Parity must be generated by a Hamming code encoder or encoder in the Block RAM. The output from the model is unreliable if there are more than 2 bit errors. The model doesn't warn if there is sporadic input of more than 2 bit errors due to the limitation in Hamming code."
              severity failure;
          end if;
    
          prcd_ecc_bit_position(prcd_tmp_syndrome_int) := not prcd_ecc_bit_position(prcd_tmp_syndrome_int); -- correct single bit error in the output 

          prcd_di_dly_ecc_corrected := prcd_ecc_bit_position(71 downto 65) & prcd_ecc_bit_position(63 downto 33) & prcd_ecc_bit_position(31 downto 17) & prcd_ecc_bit_position(15 downto 9) & prcd_ecc_bit_position(7 downto 5) & prcd_ecc_bit_position(3); -- correct single bit error in the memory

          do_tmp := prcd_di_dly_ecc_corrected;
			
          prcd_dip_dly_ecc_corrected := prcd_ecc_bit_position(0) & prcd_ecc_bit_position(64) & prcd_ecc_bit_position(32) & prcd_ecc_bit_position(16) & prcd_ecc_bit_position(8) & prcd_ecc_bit_position(4) & prcd_ecc_bit_position(2 downto 1); -- correct single bit error in the parity memory
                
          dop_tmp := prcd_dip_dly_ecc_corrected;
                
          dbiterr_tmp := '0';
          sbiterr_tmp := '1';

        elsif (prcd_syndrome(7) = '0') then  -- double bit error
          sbiterr_tmp := '0';
          dbiterr_tmp := '1';
        end if;
      else
        dbiterr_tmp := '0';
        sbiterr_tmp := '0';
      end if;


    end if;
    
  end prcd_col_ecc_read;

  
  begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

    addra_dly      	 <= ADDRA          	after 0 ps;
    addrb_dly      	 <= ADDRB          	after 0 ps;
    cascadeina_dly 	 <= CASCADEINA     	after 0 ps;
    cascadeinb_dly 	 <= CASCADEINB     	after 0 ps;
    clka_dly       	 <= CLKA           	after 0 ps;
    clkb_dly       	 <= CLKB           	after 0 ps;
    dia_dly        	 <= DIA            	after 0 ps;
    dib_dly        	 <= DIB            	after 0 ps;
    dipa_dly       	 <= DIPA           	after 0 ps;
    dipb_dly       	 <= DIPB           	after 0 ps;
    ena_dly        	 <= ENA            	after 0 ps;
    enb_dly        	 <= ENB            	after 0 ps;
    regcea_dly     	 <= REGCEA         	after 0 ps;
    regceb_dly     	 <= REGCEB         	after 0 ps;
    rstrama_dly          <= RSTRAMA      	after 0 ps;
    rstramb_dly       	 <= RSTRAMB           	after 0 ps;
    wea_dly        	 <= WEA            	after 0 ps;
    web_dly        	 <= WEB            	after 0 ps;
    gsr_dly        	 <= GSR            	after 0 ps;
    injectdbiterr_dly  	 <= INJECTDBITERR      	after 0 ps;
    injectsbiterr_dly  	 <= INJECTSBITERR      	after 0 ps;
    rstrega_dly     	 <= RSTREGA         	after 0 ps;
    rstregb_dly     	 <= RSTREGB         	after 0 ps;
    
    
    ox_addra_reconstruct(15 downto 0) <= ('0' & addra_dly(14 downto 8) & "00000000") when
                                          ((WRITE_MODE_A = "READ_FIRST" or WRITE_MODE_B = "READ_FIRST") and BRAM_SIZE = 36)
                                          else
                                          ("00" & addra_dly(13 downto 7) & "0000000") when
                                          ((WRITE_MODE_A = "READ_FIRST" or WRITE_MODE_B = "READ_FIRST") and BRAM_SIZE = 18)
                                          else
                                          addra_dly;


    ox_addrb_reconstruct(15 downto 0) <= ('0' & addrb_dly(14 downto 8) & "00000000") when
                                          ((WRITE_MODE_A = "READ_FIRST" or WRITE_MODE_B = "READ_FIRST") and BRAM_SIZE = 36)
                                          else
                                          ("00" & addrb_dly(13 downto 7) & "0000000") when
                                          ((WRITE_MODE_A = "READ_FIRST" or WRITE_MODE_B = "READ_FIRST") and BRAM_SIZE = 18)
                                          else
                                          addrb_dly;
    
    
  --------------------
  --  BEHAVIOR SECTION
  --------------------

    prcs_clk: process (clka_dly, clkb_dly, gsr_dly)

      variable mem_slv : std_logic_vector(32767 downto 0) := To_StdLogicVector(INIT_7F) &
                                                       To_StdLogicVector(INIT_7E) &
                                                       To_StdLogicVector(INIT_7D) &
                                                       To_StdLogicVector(INIT_7C) &
                                                       To_StdLogicVector(INIT_7B) &
                                                       To_StdLogicVector(INIT_7A) &
                                                       To_StdLogicVector(INIT_79) &
                                                       To_StdLogicVector(INIT_78) &
                                                       To_StdLogicVector(INIT_77) &
                                                       To_StdLogicVector(INIT_76) &
                                                       To_StdLogicVector(INIT_75) &
                                                       To_StdLogicVector(INIT_74) &
                                                       To_StdLogicVector(INIT_73) &
                                                       To_StdLogicVector(INIT_72) &
                                                       To_StdLogicVector(INIT_71) &
                                                       To_StdLogicVector(INIT_70) &
                                                       To_StdLogicVector(INIT_6F) &
                                                       To_StdLogicVector(INIT_6E) &
                                                       To_StdLogicVector(INIT_6D) &
                                                       To_StdLogicVector(INIT_6C) &
                                                       To_StdLogicVector(INIT_6B) &
                                                       To_StdLogicVector(INIT_6A) &
                                                       To_StdLogicVector(INIT_69) &
                                                       To_StdLogicVector(INIT_68) &
                                                       To_StdLogicVector(INIT_67) &
                                                       To_StdLogicVector(INIT_66) &
                                                       To_StdLogicVector(INIT_65) &
                                                       To_StdLogicVector(INIT_64) &
                                                       To_StdLogicVector(INIT_63) &
                                                       To_StdLogicVector(INIT_62) &
                                                       To_StdLogicVector(INIT_61) &
                                                       To_StdLogicVector(INIT_60) &
                                                       To_StdLogicVector(INIT_5F) &
                                                       To_StdLogicVector(INIT_5E) &
                                                       To_StdLogicVector(INIT_5D) &
                                                       To_StdLogicVector(INIT_5C) &
                                                       To_StdLogicVector(INIT_5B) &
                                                       To_StdLogicVector(INIT_5A) &
                                                       To_StdLogicVector(INIT_59) &
                                                       To_StdLogicVector(INIT_58) &
                                                       To_StdLogicVector(INIT_57) &
                                                       To_StdLogicVector(INIT_56) &
                                                       To_StdLogicVector(INIT_55) &
                                                       To_StdLogicVector(INIT_54) &
                                                       To_StdLogicVector(INIT_53) &
                                                       To_StdLogicVector(INIT_52) &
                                                       To_StdLogicVector(INIT_51) &
                                                       To_StdLogicVector(INIT_50) &
                                                       To_StdLogicVector(INIT_4F) &
                                                       To_StdLogicVector(INIT_4E) &
                                                       To_StdLogicVector(INIT_4D) &
                                                       To_StdLogicVector(INIT_4C) &
                                                       To_StdLogicVector(INIT_4B) &
                                                       To_StdLogicVector(INIT_4A) &
                                                       To_StdLogicVector(INIT_49) &
                                                       To_StdLogicVector(INIT_48) &
                                                       To_StdLogicVector(INIT_47) &
                                                       To_StdLogicVector(INIT_46) &
                                                       To_StdLogicVector(INIT_45) &
                                                       To_StdLogicVector(INIT_44) &
                                                       To_StdLogicVector(INIT_43) &
                                                       To_StdLogicVector(INIT_42) &
                                                       To_StdLogicVector(INIT_41) &
                                                       To_StdLogicVector(INIT_40) &
                                                       To_StdLogicVector(INIT_3F) &
                                                       To_StdLogicVector(INIT_3E) &
                                                       To_StdLogicVector(INIT_3D) &
                                                       To_StdLogicVector(INIT_3C) &
                                                       To_StdLogicVector(INIT_3B) &
                                                       To_StdLogicVector(INIT_3A) &
                                                       To_StdLogicVector(INIT_39) &
                                                       To_StdLogicVector(INIT_38) &
                                                       To_StdLogicVector(INIT_37) &
                                                       To_StdLogicVector(INIT_36) &
                                                       To_StdLogicVector(INIT_35) &
                                                       To_StdLogicVector(INIT_34) &
                                                       To_StdLogicVector(INIT_33) &
                                                       To_StdLogicVector(INIT_32) &
                                                       To_StdLogicVector(INIT_31) &
                                                       To_StdLogicVector(INIT_30) &
                                                       To_StdLogicVector(INIT_2F) &
                                                       To_StdLogicVector(INIT_2E) &
                                                       To_StdLogicVector(INIT_2D) &
                                                       To_StdLogicVector(INIT_2C) &
                                                       To_StdLogicVector(INIT_2B) &
                                                       To_StdLogicVector(INIT_2A) &
                                                       To_StdLogicVector(INIT_29) &
                                                       To_StdLogicVector(INIT_28) &
                                                       To_StdLogicVector(INIT_27) &
                                                       To_StdLogicVector(INIT_26) &
                                                       To_StdLogicVector(INIT_25) &
                                                       To_StdLogicVector(INIT_24) &
                                                       To_StdLogicVector(INIT_23) &
                                                       To_StdLogicVector(INIT_22) &
                                                       To_StdLogicVector(INIT_21) &
                                                       To_StdLogicVector(INIT_20) &
                                                       To_StdLogicVector(INIT_1F) &
                                                       To_StdLogicVector(INIT_1E) &
                                                       To_StdLogicVector(INIT_1D) &
                                                       To_StdLogicVector(INIT_1C) &
                                                       To_StdLogicVector(INIT_1B) &
                                                       To_StdLogicVector(INIT_1A) &
                                                       To_StdLogicVector(INIT_19) &
                                                       To_StdLogicVector(INIT_18) &
                                                       To_StdLogicVector(INIT_17) &
                                                       To_StdLogicVector(INIT_16) &
                                                       To_StdLogicVector(INIT_15) &
                                                       To_StdLogicVector(INIT_14) &
                                                       To_StdLogicVector(INIT_13) &
                                                       To_StdLogicVector(INIT_12) &
                                                       To_StdLogicVector(INIT_11) &
                                                       To_StdLogicVector(INIT_10) &
                                                       To_StdLogicVector(INIT_0F) &
                                                       To_StdLogicVector(INIT_0E) &
                                                       To_StdLogicVector(INIT_0D) &
                                                       To_StdLogicVector(INIT_0C) &
                                                       To_StdLogicVector(INIT_0B) &
                                                       To_StdLogicVector(INIT_0A) &
                                                       To_StdLogicVector(INIT_09) &
                                                       To_StdLogicVector(INIT_08) &
                                                       To_StdLogicVector(INIT_07) &
                                                       To_StdLogicVector(INIT_06) &
                                                       To_StdLogicVector(INIT_05) &
                                                       To_StdLogicVector(INIT_04) &
                                                       To_StdLogicVector(INIT_03) &
                                                       To_StdLogicVector(INIT_02) &
                                                       To_StdLogicVector(INIT_01) &
                                                       To_StdLogicVector(INIT_00);

    variable memp_slv : std_logic_vector(4095 downto 0) := To_StdLogicVector(INITP_0F) &
                                                       To_StdLogicVector(INITP_0E) &
                                                       To_StdLogicVector(INITP_0D) &
                                                       To_StdLogicVector(INITP_0C) &
                                                       To_StdLogicVector(INITP_0B) &
                                                       To_StdLogicVector(INITP_0A) &
                                                       To_StdLogicVector(INITP_09) &
                                                       To_StdLogicVector(INITP_08) &
                                                       To_StdLogicVector(INITP_07) &
                                                       To_StdLogicVector(INITP_06) &
                                                       To_StdLogicVector(INITP_05) &
                                                       To_StdLogicVector(INITP_04) &
                                                       To_StdLogicVector(INITP_03) &
                                                       To_StdLogicVector(INITP_02) &
                                                       To_StdLogicVector(INITP_01) &
                                                       To_StdLogicVector(INITP_00);

    variable tmp_mem : Two_D_array_type_tmp_mem := two_D_mem_initf(widest_width);
    variable mem : Two_D_array_type := two_D_mem_init(mem_depth, width, mem_slv, tmp_mem);
    variable memp : Two_D_parity_array_type := two_D_mem_initp(memp_depth, widthp, memp_slv, tmp_mem, width);
    variable tmp_addra_dly_depth : integer;
    variable tmp_addra_dly_width : integer;
    variable tmp_addrb_dly_depth : integer;
    variable tmp_addrb_dly_width : integer;
    variable junk1 : std_logic;
    variable wr_mode_a : std_logic_vector(1 downto 0) := "00";
    variable wr_mode_b : std_logic_vector(1 downto 0) := "00";
    variable tmp_syndrome_int : integer;    
    variable doa_buf : std_logic_vector(63 downto 0) := (others => '0');
    variable dob_buf : std_logic_vector(63 downto 0) := (others => '0');
    variable dopa_buf : std_logic_vector(7 downto 0) := (others => '0');
    variable dopb_buf : std_logic_vector(7 downto 0) := (others => '0');    
    variable syndrome : std_logic_vector(7 downto 0) := (others => '0');
    variable dopr_ecc : std_logic_vector(7 downto 0) := (others => '0');        
    variable dia_dly_ecc_corrected : std_logic_vector(63 downto 0) := (others => '0');
    variable dib_ecc_col : std_logic_vector(63 downto 0) := (others => '0');
    variable dib_dly_ecc : std_logic_vector(63 downto 0) := (others => '0');
    variable dipa_dly_ecc_corrected : std_logic_vector(7 downto 0) := (others => '0');
    variable dip_ecc : std_logic_vector(7 downto 0) := (others => '0');
    variable dipb_dly_ecc : std_logic_vector(7 downto 0) := (others => '0');        
    variable ecc_bit_position : std_logic_vector(71 downto 0) := (others => '0');
    variable addra_dly_15_reg_var : std_logic := '0';
    variable addrb_dly_15_reg_var : std_logic := '0';
    variable addra_dly_15_reg_bram_var : std_logic := '0';
    variable addrb_dly_15_reg_bram_var : std_logic := '0';
    variable FIRST_TIME : boolean := true;

    variable time_port_a : time := 0 ps;
    variable time_port_b : time := 0 ps;
    variable viol_time : integer := 0;
    variable viol_type : std_logic_vector(1 downto 0) := (others => '0');
    variable message : line;
    variable dip_ecc_col : std_logic_vector (7 downto 0) := (others => '0');
    variable dbiterr_out_var : std_ulogic := '0';
    variable sbiterr_out_var : std_ulogic := '0';

    variable dia_reg_dly : std_logic_vector(63 downto 0) := (others => '0');
    variable dipa_reg_dly : std_logic_vector(7 downto 0) := (others => '0');
    variable wea_reg_dly : std_logic_vector(7 downto 0) := (others => '0');
    variable addra_reg_dly : std_logic_vector(15 downto 0) := (others => '0');
    variable dib_reg_dly : std_logic_vector(63 downto 0) := (others => '0');
    variable dipb_reg_dly : std_logic_vector(7 downto 0) := (others => '0');
    variable web_reg_dly : std_logic_vector(7 downto 0) := (others => '0');
    variable addrb_reg_dly : std_logic_vector(15 downto 0) := (others => '0');
    variable col_wr_wr_msg : std_ulogic := '1';
    variable col_wra_rdb_msg : std_ulogic := '1';
    variable col_wrb_rda_msg : std_ulogic := '1';
    variable addr_col : std_logic := '0';
    variable ox_addra_reconstruct_reg : std_logic_vector(15 downto 0) := (others => '0');
    variable ox_addrb_reconstruct_reg : std_logic_vector(15 downto 0) := (others => '0');
    variable chk_ox_msg : integer := 0;
    variable chk_ox_same_clk : integer := 0;
    variable chk_col_same_clk : integer := 0;
    variable string_length_1 : integer;
    variable string_length_2 : integer;
    constant MsgSeverity : severity_level := Failure;

    variable time_clka_period : time := 0 ps;
    variable time_clkb_period : time := 0 ps;
    variable time_period : time := 0 ps;
    variable time_skew_a_flag : std_ulogic := '0';
    variable time_skew_b_flag : std_ulogic := '0';
    variable time_period_check_flag : std_ulogic := '0';

      
  begin  -- process prcs_clka    

    if (FIRST_TIME) then


      if (RAM_MODE = "TDP") then
        
        if (EN_ECC_WRITE = TRUE) then
                              
          assert false
          report "DRC Error : The attribute EN_ECC_WRITE on RAMB36E1 instance is set to TRUE which requires RAM_MODE = SDP."
          severity failure;
          
        end if;
                        
        if (EN_ECC_READ = TRUE) then
                              
          assert false
          report "DRC Error : The attribute EN_ECC_READ on RAMB36E1 instance is set to TRUE which requires RAM_MODE = SDP."
          severity failure;

        end if;

      elsif (RAM_MODE = "SDP") then

        if ((WRITE_MODE_A /= WRITE_MODE_B) or WRITE_MODE_A = "NO_CHANGE" or WRITE_MODE_A = "NO_CHANGE") then

          assert false
          report "DRC Error : Both attributes WRITE_MODE_A and WRITE_MODE_B must be set to READ_FIRST or both attributes must be set to WRITE_FIRST when RAM_MODE = SDP on RAMB36E1 instance."
          severity failure;

        end if;           
        
        if (BRAM_SIZE = 18) then
          if (not(WRITE_WIDTH_B = 36 or READ_WIDTH_A = 36)) then
                          
            assert false
            report "DRC Error : One of the attribute WRITE_WIDTH_B or READ_WIDTH_A must set to 36 when RAM_MODE = SDP."
            severity failure;

          end if;
        else
          if (not(WRITE_WIDTH_B = 72 or READ_WIDTH_A = 72)) then
                          
            assert false
            report "DRC Error : One of the attribute WRITE_WIDTH_B or READ_WIDTH_A must set to 72 when RAM_MODE = SDP."
            severity failure;
              
          end if;
        end if;

      else
            
        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " RAM_MODE ",
            EntityName           => "RAMB36E1",
            GenericValue         => RAM_MODE,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " TDP or SDP ",
            TailMsg              => "",
            MsgSeverity          => failure
            );

      end if;
      
      
      case READ_WIDTH_A is
        when 0 | 1 | 2 | 4 | 9 | 18 => null;
        when 36 => if (BRAM_SIZE = 18 and RAM_MODE = "TDP") then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " READ_WIDTH_A ",
                           EntityName           => "RAMB36E1",
                           GenericValue         => READ_WIDTH_A,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   end if;
        when 72 => if (BRAM_SIZE = 18) then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " READ_WIDTH_A ",
                           EntityName           => "RAMB36E1",
                           GenericValue         => READ_WIDTH_A,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   elsif (BRAM_SIZE = 36 and RAM_MODE = "TDP") then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " READ_WIDTH_A ",
                           EntityName           => "RAMB36E1",
                           GenericValue         => READ_WIDTH_A,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9, 18 or 36.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   end if;
        when others => if (BRAM_SIZE = 18 and RAM_MODE = "TDP") then
                         GenericValueCheckMessage
                           (  HeaderMsg            => " Attribute Syntax Error : ",
                              GenericName          => " READ_WIDTH_A ",
                              EntityName           => "RAMB36E1",
                              GenericValue         => READ_WIDTH_A,
                              Unit                 => "",
                              ExpectedValueMsg     => " The Legal values for this attribute are ",
                              ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                              TailMsg              => "",
                              MsgSeverity          => failure
                              );
                       elsif (BRAM_SIZE = 36 or (BRAM_SIZE = 18 and RAM_MODE = "SDP")) then
                         GenericValueCheckMessage
                           (  HeaderMsg            => " Attribute Syntax Error : ",
                              GenericName          => " READ_WIDTH_A ",
                              EntityName           => "RAMB36E1",
                              GenericValue         => READ_WIDTH_A,
                              Unit                 => "",
                              ExpectedValueMsg     => " The Legal values for this attribute are ",
                              ExpectedGenericValue => " 0, 1, 2, 4, 9, 18 or 36.",
                              TailMsg              => "",
                              MsgSeverity          => failure
                              );
                       end if;
      end case;


      case READ_WIDTH_B is
        when 0 | 1 | 2 | 4 | 9 | 18 => null;
        when 36 => if (BRAM_SIZE = 18 and RAM_MODE = "TDP") then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " READ_WIDTH_B ",
                           EntityName           => "RAMB36E1",
                           GenericValue         => READ_WIDTH_B,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   end if;
        when 72 => if (BRAM_SIZE = 18) then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " READ_WIDTH_B ",
                           EntityName           => "RAMB36E1",
                           GenericValue         => READ_WIDTH_B,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   elsif (BRAM_SIZE = 36 and RAM_MODE = "TDP") then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " READ_WIDTH_B ",
                           EntityName           => "RAMB36E1",
                           GenericValue         => READ_WIDTH_B,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9, 18 or 36.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   end if;
        when others => if (BRAM_SIZE = 18 and RAM_MODE = "TDP") then
                         GenericValueCheckMessage
                           (  HeaderMsg            => " Attribute Syntax Error : ",
                              GenericName          => " READ_WIDTH_B ",
                              EntityName           => "RAMB36E1",
                              GenericValue         => READ_WIDTH_B,
                              Unit                 => "",
                              ExpectedValueMsg     => " The Legal values for this attribute are ",
                              ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                              TailMsg              => "",
                              MsgSeverity          => failure
                              );
                       elsif (BRAM_SIZE = 36 or (BRAM_SIZE = 18 and RAM_MODE = "SDP")) then
                         GenericValueCheckMessage
                           (  HeaderMsg            => " Attribute Syntax Error : ",
                              GenericName          => " READ_WIDTH_B ",
                              EntityName           => "RAMB36E1",
                              GenericValue         => READ_WIDTH_B,
                              Unit                 => "",
                              ExpectedValueMsg     => " The Legal values for this attribute are ",
                              ExpectedGenericValue => " 0, 1, 2, 4, 9, 18 or 36.",
                              TailMsg              => "",
                              MsgSeverity          => failure
                              );
                       end if;
      end case;


      case WRITE_WIDTH_A is
        when 0 | 1 | 2 | 4 | 9 | 18 => null;
        when 36 => if (BRAM_SIZE = 18 and RAM_MODE = "TDP") then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " WRITE_WIDTH_A ",
                           EntityName           => "RAMB36E1",
                           GenericValue         => WRITE_WIDTH_A,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   end if;
        when 72 => if (BRAM_SIZE = 18) then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " WRITE_WIDTH_A ",
                           EntityName           => "RAMB36E1",
                           GenericValue         => WRITE_WIDTH_A,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   elsif (BRAM_SIZE = 36 and RAM_MODE = "TDP") then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " WRITE_WIDTH_A ",
                           EntityName           => "RAMB36E1",
                           GenericValue         => WRITE_WIDTH_A,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9, 18 or 36.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   end if;
        when others => if (BRAM_SIZE = 18 and RAM_MODE = "TDP") then
                         GenericValueCheckMessage
                           (  HeaderMsg            => " Attribute Syntax Error : ",
                              GenericName          => " WRITE_WIDTH_A ",
                              EntityName           => "RAMB36E1",
                              GenericValue         => WRITE_WIDTH_A,
                              Unit                 => "",
                              ExpectedValueMsg     => " The Legal values for this attribute are ",
                              ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                              TailMsg              => "",
                              MsgSeverity          => failure
                              );
                       elsif (BRAM_SIZE = 36 or (BRAM_SIZE = 18 and RAM_MODE = "SDP")) then
                         GenericValueCheckMessage
                           (  HeaderMsg            => " Attribute Syntax Error : ",
                              GenericName          => " WRITE_WIDTH_A ",
                              EntityName           => "RAMB36E1",
                              GenericValue         => WRITE_WIDTH_A,
                              Unit                 => "",
                              ExpectedValueMsg     => " The Legal values for this attribute are ",
                              ExpectedGenericValue => " 0, 1, 2, 4, 9, 18 or 36.",
                              TailMsg              => "",
                              MsgSeverity          => failure
                              );
                       end if;
      end case;


      case WRITE_WIDTH_B is
        when 0 | 1 | 2 | 4 | 9 | 18 => null;
        when 36 => if (BRAM_SIZE = 18 and RAM_MODE = "TDP") then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " WRITE_WIDTH_B ",
                           EntityName           => "RAMB36E1",
                           GenericValue         => WRITE_WIDTH_B,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   end if;
        when 72 => if (BRAM_SIZE = 18) then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " WRITE_WIDTH_B ",
                           EntityName           => "RAMB36E1",
                           GenericValue         => WRITE_WIDTH_B,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   elsif (BRAM_SIZE = 36 and RAM_MODE = "TDP") then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " WRITE_WIDTH_B ",
                           EntityName           => "RAMB36E1",
                           GenericValue         => WRITE_WIDTH_B,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9, 18 or 36.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   end if;
        when others => if (BRAM_SIZE = 18 and RAM_MODE = "TDP") then
                         GenericValueCheckMessage
                           (  HeaderMsg            => " Attribute Syntax Error : ",
                              GenericName          => " WRITE_WIDTH_B ",
                              EntityName           => "RAMB36E1",
                              GenericValue         => WRITE_WIDTH_B,
                              Unit                 => "",
                              ExpectedValueMsg     => " The Legal values for this attribute are ",
                              ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                              TailMsg              => "",
                              MsgSeverity          => failure
                              );
                       elsif (BRAM_SIZE = 36 or (BRAM_SIZE = 18 and RAM_MODE = "SDP")) then
                         GenericValueCheckMessage
                           (  HeaderMsg            => " Attribute Syntax Error : ",
                              GenericName          => " WRITE_WIDTH_B ",
                              EntityName           => "RAMB36E1",
                              GenericValue         => WRITE_WIDTH_B,
                              Unit                 => "",
                              ExpectedValueMsg     => " The Legal values for this attribute are ",
                              ExpectedGenericValue => " 0, 1, 2, 4, 9, 18 or 36.",
                              TailMsg              => "",
                              MsgSeverity          => failure
                              );
                       end if;
      end case;

      
      if (not(EN_ECC_READ = TRUE or EN_ECC_READ = FALSE)) then

        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " EN_ECC_READ ",
            EntityName           => "RAMB36E1",
            GenericValue         => EN_ECC_READ,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " TRUE or FALSE ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
      end if;

      
      if (not(EN_ECC_WRITE = TRUE or EN_ECC_WRITE = FALSE)) then

        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " EN_ECC_WRITE ",
            EntityName           => "RAMB36E1",
            GenericValue         => EN_ECC_WRITE,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " TRUE or FALSE ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
      end if;

      
      if (READ_WIDTH_A = 0 and READ_WIDTH_B = 0) then
        assert false
        report "Attribute Syntax Error : Attributes READ_WIDTH_A and READ_WIDTH_B on RAMB36E1 instance, both can not be 0."
        severity failure;
      end if;

      
      if (WRITE_MODE_A = "WRITE_FIRST") then
        wr_mode_a := "00";
      elsif (WRITE_MODE_A = "READ_FIRST") then
        wr_mode_a := "01";
      elsif (WRITE_MODE_A = "NO_CHANGE") then
        wr_mode_a := "10";
      else
        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " WRITE_MODE_A ",
            EntityName           => "RAMB36E1",
            GenericValue         => WRITE_MODE_A,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " WRITE_FIRST, READ_FIRST or NO_CHANGE ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
      end if;
    
      if (WRITE_MODE_B = "WRITE_FIRST") then
        wr_mode_b := "00";
      elsif (WRITE_MODE_B = "READ_FIRST") then
        wr_mode_b := "01";
      elsif (WRITE_MODE_B = "NO_CHANGE") then
        wr_mode_b := "10";
      else
        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " WRITE_MODE_B ",
            EntityName           => "RAMB36E1",
            GenericValue         => WRITE_MODE_B,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " WRITE_FIRST, READ_FIRST or NO_CHANGE ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
      end if;

    
      if (RAM_EXTENSION_A = "UPPER") then
        cascade_a <= "11";
      elsif (RAM_EXTENSION_A = "LOWER") then
        cascade_a <= "01";
      elsif (RAM_EXTENSION_A= "NONE") then
        cascade_a <= "00";
      else
        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " RAM_EXTENSION_A ",
            EntityName           => "RAMB36E1",
            GenericValue         => RAM_EXTENSION_A,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " NONE, LOWER or UPPER ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
      end if;

    
      if (RAM_EXTENSION_B = "UPPER") then
        cascade_b <= "11";
      elsif (RAM_EXTENSION_B = "LOWER") then
        cascade_b <= "01";
      elsif (RAM_EXTENSION_B= "NONE") then
        cascade_b <= "00";
      else
        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " RAM_EXTENSION_B ",
            EntityName           => "RAMB36E1",
            GenericValue         => RAM_EXTENSION_A,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " NONE, LOWER or UPPER ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
      end if;

      
      if( ((RAM_EXTENSION_A = "LOWER") or (RAM_EXTENSION_A = "UPPER")) and (READ_WIDTH_A /= 1)) then
        assert false
          report "Attribute Syntax Error: If RAM_EXTENSION_A is set to either LOWER or UPPER, then READ_WIDTH_A has to be set to 1."
          severity Failure;
      end if;
    
      if( ((RAM_EXTENSION_A = "LOWER") or (RAM_EXTENSION_A = "UPPER")) and (WRITE_WIDTH_A /= 1)) then
        assert false
          report "Attribute Syntax Error: If RAM_EXTENSION_A is set to either LOWER or UPPER, then WRITE_WIDTH_A has to be set to 1."
          severity Failure;
      end if;

      if( ((RAM_EXTENSION_B = "LOWER") or (RAM_EXTENSION_B = "UPPER")) and (READ_WIDTH_B /= 1)) then
        assert false
          report "Attribute Syntax Error: If RAM_EXTENSION_B is set to either LOWER or UPPER, then READ_WIDTH_B has to be set to 1."
          severity Failure;
      end if;
    
      if( ((RAM_EXTENSION_B = "LOWER") or (RAM_EXTENSION_B = "UPPER")) and (WRITE_WIDTH_B /= 1)) then
        assert false
          report "Attribute Syntax Error: If RAM_EXTENSION_B is set to either LOWER or UPPER, then WRITE_WIDTH_B has to be set to 1."
          severity Failure;
      end if;


      if (not ((SIM_COLLISION_CHECK = "NONE") or (SIM_COLLISION_CHECK = "WARNING_ONLY") or (SIM_COLLISION_CHECK = "GENERATE_X_ONLY") or (SIM_COLLISION_CHECK = "ALL"))) then
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "SIM_COLLISION_CHECK",
           EntityName => "RAMB36E1",
           GenericValue => SIM_COLLISION_CHECK,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are ALL, NONE, WARNING_ONLY or GENERATE_X_ONLY",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => failure
           );
      end if;

      
      if (not(RSTREG_PRIORITY_A = "RSTREG" or RSTREG_PRIORITY_A = "REGCE")) then

        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " RSTREG_PRIORITY_A ",
            EntityName           => "RAMB36E1",
            GenericValue         => RSTREG_PRIORITY_A,
            Unit                 => "",
            ExpectedValueMsg     => " Legal values for this attribute are ",
            ExpectedGenericValue => " RSTREG or REGCE ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
      end if;


      if (not(RSTREG_PRIORITY_B = "RSTREG" or RSTREG_PRIORITY_B = "REGCE")) then

        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " RSTREG_PRIORITY_B ",
            EntityName           => "RAMB36E1",
            GenericValue         => RSTREG_PRIORITY_B,
            Unit                 => "",
            ExpectedValueMsg     => " Legal values for this attribute are ",
            ExpectedGenericValue => " RSTREG or REGCE ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
      end if;


      if ((EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE) and (WRITE_WIDTH_B /= 72 or READ_WIDTH_A /= 72)) then

        assert false
        report "DRC Error : Attributes WRITE_WIDTH_B and READ_WIDTH_A have to be set to 72 on RAMB36E1 instance when either attribute EN_ECC_WRITE or EN_ECC_READ is set to TRUE."
        severity Failure;

      end if;


      if (RDADDR_COLLISION_HWCONFIG /= "DELAYED_WRITE" and RDADDR_COLLISION_HWCONFIG /= "PERFORMANCE") then
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error : ",
           GenericName => "RDADDR_COLLISION_HWCONFIG",
           EntityName => "RAMB36E1",
           GenericValue => RDADDR_COLLISION_HWCONFIG,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are ",
           ExpectedGenericValue => "DELAYED_WRITE or PERFORMANCE ",
           TailMsg => "",
           MsgSeverity => failure
           );
      end if;


      if (not(SIM_DEVICE = "VIRTEX6" or SIM_DEVICE = "7SERIES")) then
        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error ",
            GenericName          => " SIM_DEVICE ",
            EntityName           => "RAMB36E1",
            GenericValue         => SIM_DEVICE,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " VIRTEX6 or 7SERIES ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
      end if;

      
  end if;                         
    

    if (rising_edge(clka_dly)) then

      if ((now > 110 ns) and time_skew_a_flag = '0') then
        time_clka_period := now - time_port_a;
        time_skew_a_flag := '1';
      end if;
      
      if (ena_dly = '1') then      
        time_port_a := now;
        addra_reg_dly := addra_dly;
        wea_reg_dly := wea_dly;
        dia_reg_dly := dia_dly;
        dipa_reg_dly := dipa_dly;
        ox_addra_reconstruct_reg := ox_addra_reconstruct;
      end if;
      
    end if;
    
    if (rising_edge(clkb_dly)) then

      if ((now > 110 ns) and time_skew_b_flag = '0') then
        time_clkb_period := now - time_port_b;
        time_skew_b_flag := '1';
      end if;
      
      if (enb_dly = '1') then
        time_port_b := now;
        addrb_reg_dly := addrb_dly;
        web_reg_dly := web_dly;
        dib_reg_dly := dib_dly;
        dipb_reg_dly := dipb_dly;
        ox_addrb_reconstruct_reg := ox_addrb_reconstruct;
      end if;
      
    end if;


    if (time_clka_period /= 0 ps and time_clkb_period /= 0 ps and time_period_check_flag = '0') then

      if (time_clka_period <= time_clkb_period) then
        
        if (time_clka_period <= SETUP_READ_FIRST) then
          time_period := time_clka_period;
        else
          time_period := SETUP_READ_FIRST;
        end if;
	    
      elsif (time_clkb_period <= SETUP_READ_FIRST) then
        time_period := time_clkb_period;
      else
        time_period := SETUP_READ_FIRST;

      end if;

      time_period_check_flag := '1';

    end if;
    
    
    if (gsr_dly = '1' or FIRST_TIME) then

      doa_out(ra_width-1 downto 0) <= INIT_A_STD(ra_width-1 downto 0);

      if (ra_width >= 8) then
        dopa_out(ra_widthp-1 downto 0) <= INIT_A_STD((ra_width+ra_widthp)-1 downto ra_width);            
      end if;

      dob_out(rb_width-1 downto 0) <= INIT_B_STD(rb_width-1 downto 0);          

      if (rb_width >= 8) then
        dopb_out(rb_widthp-1 downto 0) <= INIT_B_STD((rb_width+rb_widthp)-1 downto rb_width);            
      end if;

      dbiterr_out <= '0';
      sbiterr_out <= '0';
      rdaddrecc_out <= (others => '0');

      FIRST_TIME := false;
      
    elsif (gsr_dly = '0') then

      if (rising_edge(clka_dly)) then
       if (cascade_a(1) = '1') then
         addra_dly_15_reg_bram_var := not addra_dly(15);
       else
         addra_dly_15_reg_bram_var := addra_dly(15);
       end if;
      end if;

      if (rising_edge(clkb_dly)) then
       if (cascade_b(1) = '1') then
         addrb_dly_15_reg_bram_var := not addrb_dly(15);
       else
         addrb_dly_15_reg_bram_var := addrb_dly(15);
       end if;
      end if;
      
     if (rising_edge(clka_dly) or rising_edge(clkb_dly)) then

      if ((cascade_a = "00" or (addra_dly_15_reg_bram_var = '0' and cascade_a /= "00")) and (cascade_b = "00" or (addrb_dly_15_reg_bram_var = '0' and cascade_b /= "00"))) then
            
-------------------------------------------------------------------------------
-- Collision starts
-------------------------------------------------------------------------------

       if (SIM_COLLISION_CHECK /= "NONE") then

        if (SIM_DEVICE = "7SERIES") then
         
          if (time_port_a > time_port_b) then
           
            if (time_port_a - time_port_b <= 50 ps) then
              viol_time := 1;
            elsif (time_port_a - time_port_b <= time_period) then
              viol_time := 2;
            end if;

          else
  
            if (time_port_b - time_port_a <= 50 ps) then
              viol_time := 1;
            elsif (time_port_b - time_port_a <= time_period) then
              viol_time := 2;
            end if;

          end if;

        else
           
          if (time_port_a > time_port_b) then
           
            if (time_port_a - time_port_b <= 100 ps) then
              viol_time := 1;
            elsif (time_port_a - time_port_b <= time_period) then
              viol_time := 2;
            end if;

          else
  
            if (time_port_b - time_port_a <= 100 ps) then
              viol_time := 1;
            elsif (time_port_b - time_port_a <= time_period) then
              viol_time := 2;
            end if;

          end if;

        end if;

        
        if (ena_dly = '0' or enb_dly = '0') then
          viol_time := 0;
        end if;

        
        if ((WRITE_WIDTH_A <= 9 and wea_dly(0) = '0') or (WRITE_WIDTH_A = 18 and wea_dly(1 downto 0) = "00") or ((WRITE_WIDTH_A = 36 or WRITE_WIDTH_A = 72) and wea_dly(3 downto 0) = "0000")) then
          if ((WRITE_WIDTH_B <= 9 and web_dly(0) = '0') or (WRITE_WIDTH_B = 18 and web_dly(1 downto 0) = "00") or (WRITE_WIDTH_B = 36 and web_dly(3 downto 0) = "0000") or (WRITE_WIDTH_B = 72 and web_dly(7 downto 0) = "00000000")) then
            viol_time := 0;
          end if;
        end if;

        
        if (viol_time /= 0) then

         if (SIM_DEVICE = "VIRTEX6") then

          if ((rising_edge(clka_dly) and rising_edge(clkb_dly)) or viol_time = 1) then

            if (ADDRA_dly(15 downto col_addr_lsb) = ADDRB_dly(15 downto col_addr_lsb)) then            

              viol_type := "01";
              chk_col_same_clk := 1;


              if ((wr_mode_a = "01" or wr_mode_b = "01") and (time_port_a > time_port_b)) then
                doa_buf := dob_buf;
                dopa_buf := dopb_buf;
              elsif ((wr_mode_a = "01" or wr_mode_b = "01") and (time_port_b > time_port_a)) then
                dob_buf := doa_buf;
                dopb_buf := dopa_buf;
              else
                prcd_rd_ram_a (addra_dly, doa_buf, dopa_buf, mem, memp);
                prcd_rd_ram_b (addrb_dly, dob_buf, dopb_buf, mem, memp);
              end if;
              
                
              prcd_col_wr_ram_a (viol_type, "00", web_dly, wea_dly, di_x, di_x(7 downto 0), addrb_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              prcd_col_wr_ram_b (viol_type, "00", wea_dly, web_dly, di_x, di_x(7 downto 0), addra_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              chk_col_same_clk := 0;
              
              prcd_col_rd_ram_a (viol_type, "01", web_dly, wea_dly, addra_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              prcd_col_rd_ram_b (viol_type, "01", wea_dly, web_dly, addrb_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);

              prcd_col_wr_ram_a (viol_type, "10", web_dly, wea_dly, dia_dly, dipa_dly, addrb_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);


              dib_ecc_col := dib_dly;

              if (EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE) then

                if (injectdbiterr_dly = '1') then
                  dib_ecc_col(30) := not(dib_ecc_col(30));
                  dib_ecc_col(62) := not(dib_ecc_col(62));
                elsif (injectsbiterr_dly = '1') then
                  dib_ecc_col(30) := not(dib_ecc_col(30));
                end if;

              end if;
              
              
              if (RAM_MODE = "SDP" and EN_ECC_WRITE = TRUE and enb_dly = '1') then
                  
                dip_ecc_col := fn_dip_ecc('1', dib_dly, dipb_dly);				
                eccparity_out <= dip_ecc_col;
                prcd_col_wr_ram_b (viol_type, "10", wea_dly, web_dly, dib_ecc_col, dip_ecc_col, addra_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              else
                
                prcd_col_wr_ram_b (viol_type, "10", wea_dly, web_dly, dib_ecc_col, dipb_dly, addra_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              end if;
			    
              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", web_dly, wea_dly, addra_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", wea_dly, web_dly, addrb_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);
              end if;

              
              if ((wr_mode_a = "01" or wr_mode_b = "01") and RDADDR_COLLISION_HWCONFIG = "PERFORMANCE") then
                prcd_col_wr_ram_a (viol_type, "10", web_dly, wea_dly, di_x, di_x(7 downto 0), addrb_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
                prcd_col_wr_ram_b (viol_type, "10", wea_dly, web_dly, di_x, di_x(7 downto 0), addra_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              end if;

              
              if ((RAM_MODE = "SDP" and EN_ECC_READ = TRUE) and ((time_port_a > time_port_b) or (rising_edge(clka_dly) and rising_edge(clkb_dly)))) then
                prcd_col_ecc_read (doa_buf, dopa_buf, addra_dly, dbiterr_out_var, sbiterr_out_var, mem, memp, syndrome);
              end if;


            elsif ((wr_mode_a = "01" or wr_mode_b = "01") and (ox_addra_reconstruct(15 downto col_addr_lsb) = ox_addrb_reconstruct(15 downto col_addr_lsb))) then

              viol_type := "01";
              chk_ox_msg := 1;
              chk_ox_same_clk := 1;

              if (time_port_a > time_port_b) then
                prcd_rd_ram_a (addra_dly, doa_buf, dopa_buf, mem, memp);
              elsif (time_port_b > time_port_a) then
                prcd_rd_ram_b (addrb_dly, dob_buf, dopb_buf, mem, memp);
              else
                prcd_rd_ram_a (addra_dly, doa_buf, dopa_buf, mem, memp);
                prcd_rd_ram_b (addrb_dly, dob_buf, dopb_buf, mem, memp);
              end if;
              
              prcd_col_wr_ram_a (viol_type, "00", web_dly, wea_dly, di_x, di_x(7 downto 0), addrb_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              prcd_col_wr_ram_b (viol_type, "00", wea_dly, web_dly, di_x, di_x(7 downto 0), addra_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              chk_ox_msg := 0;
              chk_ox_same_clk := 0;
              
              prcd_ox_wr_ram_a (viol_type, "10", web_dly, wea_dly, dia_dly, dipa_dly, addrb_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);


              dib_ecc_col := dib_dly;

              if (EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE) then

                if (injectdbiterr_dly = '1') then
                  dib_ecc_col(30) := not(dib_ecc_col(30));
                  dib_ecc_col(62) := not(dib_ecc_col(62));
                elsif (injectsbiterr_dly = '1') then
                  dib_ecc_col(30) := not(dib_ecc_col(30));
                end if;

              end if;
              
              
              if (RAM_MODE = "SDP" and EN_ECC_WRITE = TRUE and enb_dly = '1') then
                  
                dip_ecc_col := fn_dip_ecc('1', dib_dly, dipb_dly);				
                eccparity_out <= dip_ecc_col;
                prcd_ox_wr_ram_b (viol_type, "10", wea_dly, web_dly, dib_ecc_col, dip_ecc_col, addra_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              else
                
                prcd_ox_wr_ram_b (viol_type, "10", wea_dly, web_dly, dib_ecc_col, dipb_dly, addra_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              end if;
			    
              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", web_dly, wea_dly, addra_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", wea_dly, web_dly, addrb_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);
              end if;

              
              if (RDADDR_COLLISION_HWCONFIG = "PERFORMANCE") then
                prcd_col_wr_ram_a (viol_type, "10", web_dly, "11111111", di_x, di_x(7 downto 0), addrb_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
                prcd_col_wr_ram_b (viol_type, "10", wea_dly, "11111111", di_x, di_x(7 downto 0), addra_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              end if;

              if ((RAM_MODE = "SDP" and EN_ECC_READ = TRUE) and ((time_port_a > time_port_b) or (rising_edge(clka_dly) and rising_edge(clkb_dly)))) then
                prcd_col_ecc_read (doa_buf, dopa_buf, addra_dly, dbiterr_out_var, sbiterr_out_var, mem, memp, syndrome);
              end if;

              
            else
              viol_time := 0;
              
            end if;

          elsif (rising_edge(clka_dly) and  (not(rising_edge(clkb_dly)))) then

            if (ADDRA_dly(15 downto col_addr_lsb) = ADDRB_reg_dly(15 downto col_addr_lsb)) then
              
              viol_type := "10";

              prcd_rd_ram_a (addra_dly, doa_buf, dopa_buf, mem, memp);

              prcd_col_wr_ram_a (viol_type, "00", web_reg_dly, wea_dly, di_x, di_x(7 downto 0), addrb_reg_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              prcd_col_wr_ram_b (viol_type, "00", wea_dly, web_reg_dly, di_x, di_x(7 downto 0), addra_dly, addrb_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              prcd_col_rd_ram_a (viol_type, "01", web_reg_dly, wea_dly, addra_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              prcd_col_rd_ram_b (viol_type, "01", wea_dly, web_reg_dly, addrb_reg_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);

              prcd_col_wr_ram_a (viol_type, "10", web_reg_dly, wea_dly, dia_dly, dipa_dly, addrb_reg_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);


              dib_ecc_col := dib_reg_dly;

              if (EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE) then

                if (injectdbiterr_dly = '1') then
                  dib_ecc_col(30) := not(dib_ecc_col(30));
                  dib_ecc_col(62) := not(dib_ecc_col(62));
                elsif (injectsbiterr_dly = '1') then
                  dib_ecc_col(30) := not(dib_ecc_col(30));
                end if;

              end if;
              
              
              if (RAM_MODE = "SDP" and EN_ECC_WRITE = TRUE and enb_dly = '1') then
                  
                dip_ecc_col := fn_dip_ecc('1', dib_reg_dly, dipb_reg_dly);				
                eccparity_out <= dip_ecc_col;
                prcd_col_wr_ram_b (viol_type, "10", wea_dly, web_reg_dly, dib_ecc_col, dip_ecc_col, addra_dly, addrb_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              else
                
                prcd_col_wr_ram_b (viol_type, "10", wea_dly, web_reg_dly, dib_ecc_col, dipb_reg_dly, addra_dly, addrb_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              end if;
			    
              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", web_reg_dly, wea_dly, addra_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", wea_dly, web_reg_dly, addrb_reg_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);
              end if;


              if (wr_mode_a = "01" or wr_mode_b = "01") then
                prcd_col_wr_ram_a (viol_type, "10", web_reg_dly, wea_dly, di_x, di_x(7 downto 0), addrb_reg_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
                prcd_col_wr_ram_b (viol_type, "10", wea_dly, web_reg_dly, di_x, di_x(7 downto 0), addra_dly, addrb_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              end if;
              
              
              if (RAM_MODE = "SDP" and EN_ECC_READ = TRUE) then
                prcd_col_ecc_read (doa_buf, dopa_buf, addra_dly, dbiterr_out_var, sbiterr_out_var, mem, memp, syndrome);
              end if;

            elsif ((wr_mode_a = "01" or wr_mode_b = "01") and (ox_addra_reconstruct(15 downto col_addr_lsb) = ox_addrb_reconstruct_reg(15 downto col_addr_lsb))) then
              
              viol_type := "10";
              chk_ox_msg := 1;
              
              prcd_rd_ram_a (addra_dly, doa_buf, dopa_buf, mem, memp);

              prcd_col_wr_ram_a (viol_type, "00", web_reg_dly, wea_dly, di_x, di_x(7 downto 0), addrb_reg_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              prcd_col_wr_ram_b (viol_type, "00", wea_dly, web_reg_dly, di_x, di_x(7 downto 0), addra_dly, addrb_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              chk_ox_msg := 0;
              
              prcd_ox_wr_ram_a (viol_type, "10", web_reg_dly, wea_dly, dia_dly, dipa_dly, addrb_reg_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);


              dib_ecc_col := dib_reg_dly;

              if (EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE) then

                if (injectdbiterr_dly = '1') then
                  dib_ecc_col(30) := not(dib_ecc_col(30));
                  dib_ecc_col(62) := not(dib_ecc_col(62));
                elsif (injectsbiterr_dly = '1') then
                  dib_ecc_col(30) := not(dib_ecc_col(30));
                end if;

              end if;
              
              
              if (RAM_MODE = "SDP" and EN_ECC_WRITE = TRUE and enb_dly = '1') then
                  
                dip_ecc_col := fn_dip_ecc('1', dib_reg_dly, dipb_reg_dly);				
                eccparity_out <= dip_ecc_col;
                prcd_ox_wr_ram_b (viol_type, "10", wea_dly, web_reg_dly, dib_ecc_col, dip_ecc_col, addra_dly, addrb_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              else
                
                prcd_ox_wr_ram_b (viol_type, "10", wea_dly, web_reg_dly, dib_ecc_col, dipb_reg_dly, addra_dly, addrb_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              end if;
			    
              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", web_reg_dly, wea_dly, addra_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", wea_dly, web_reg_dly, addrb_reg_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);
              end if;


              prcd_col_wr_ram_a (viol_type, "10", web_reg_dly, "11111111", di_x, di_x(7 downto 0), addrb_reg_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              prcd_col_wr_ram_b (viol_type, "10", wea_dly, "11111111", di_x, di_x(7 downto 0), addra_dly, addrb_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              
              
              if (RAM_MODE = "SDP" and EN_ECC_READ = TRUE) then
                prcd_col_ecc_read (doa_buf, dopa_buf, addra_dly, dbiterr_out_var, sbiterr_out_var, mem, memp, syndrome);
              end if;

              
            else
              viol_time := 0;
              
            end if;

          elsif ((not(rising_edge(clka_dly))) and rising_edge(clkb_dly)) then

            if (ADDRA_reg_dly(15 downto col_addr_lsb) = ADDRB_dly(15 downto col_addr_lsb)) then
                              
              viol_type := "11";

              prcd_rd_ram_b (addrb_dly, dob_buf, dopb_buf, mem, memp);

              prcd_col_wr_ram_a (viol_type, "00", web_dly, wea_reg_dly, di_x, di_x(7 downto 0), addrb_dly, addra_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              prcd_col_wr_ram_b (viol_type, "00", wea_reg_dly, web_dly, di_x, di_x(7 downto 0), addra_reg_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              prcd_col_rd_ram_a (viol_type, "01", web_dly, wea_reg_dly, addra_reg_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              prcd_col_rd_ram_b (viol_type, "01", wea_reg_dly, web_dly, addrb_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);

              prcd_col_wr_ram_a (viol_type, "10", web_dly, wea_reg_dly, dia_reg_dly, dipa_reg_dly, addrb_dly, addra_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              
              dib_ecc_col := dib_dly;

              if (EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE) then

                if (injectdbiterr_dly = '1') then
                  dib_ecc_col(30) := not(dib_ecc_col(30));
                  dib_ecc_col(62) := not(dib_ecc_col(62));
                elsif (injectsbiterr_dly = '1') then
                  dib_ecc_col(30) := not(dib_ecc_col(30));
                end if;

              end if;
              
              
              if (RAM_MODE = "SDP" and EN_ECC_WRITE = TRUE and enb_dly = '1') then
                  
                dip_ecc_col := fn_dip_ecc('1', dib_dly, dipb_dly);				
                eccparity_out <= dip_ecc_col;
                prcd_col_wr_ram_b (viol_type, "10", wea_reg_dly, web_dly, dib_ecc_col, dip_ecc_col, addra_reg_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              else
                
                prcd_col_wr_ram_b (viol_type, "10", wea_reg_dly, web_dly, dib_ecc_col, dipb_dly, addra_reg_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              end if;
			    
              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", web_dly, wea_reg_dly, addra_reg_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", wea_reg_dly, web_dly, addrb_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);
              end if;


              if (wr_mode_a = "01" or wr_mode_b = "01") then
                prcd_col_wr_ram_a (viol_type, "10", web_dly, wea_reg_dly, di_x, di_x(7 downto 0), addrb_dly, addra_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
                prcd_col_wr_ram_b (viol_type, "10", wea_reg_dly, web_dly, di_x, di_x(7 downto 0), addra_reg_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              end if;

              
              if (RAM_MODE = "SDP" and EN_ECC_READ = TRUE) then
                prcd_col_ecc_read (doa_buf, dopa_buf, addra_reg_dly, dbiterr_out_var, sbiterr_out_var, mem, memp, syndrome);
              end if;

            elsif ((wr_mode_a = "01" or wr_mode_b = "01") and (ox_addra_reconstruct_reg(15 downto col_addr_lsb) = ox_addrb_reconstruct(15 downto col_addr_lsb))) then
                              
              viol_type := "11";
              chk_ox_msg := 1;

              prcd_rd_ram_b (addrb_dly, dob_buf, dopb_buf, mem, memp);

              prcd_col_wr_ram_a (viol_type, "00", web_dly, wea_reg_dly, di_x, di_x(7 downto 0), addrb_dly, addra_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              prcd_col_wr_ram_b (viol_type, "00", wea_reg_dly, web_dly, di_x, di_x(7 downto 0), addra_reg_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              chk_ox_msg := 0;
              
              prcd_ox_wr_ram_a (viol_type, "10", web_dly, wea_reg_dly, dia_reg_dly, dipa_reg_dly, addrb_dly, addra_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              
              dib_ecc_col := dib_dly;

              if (EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE) then

                if (injectdbiterr_dly = '1') then
                  dib_ecc_col(30) := not(dib_ecc_col(30));
                  dib_ecc_col(62) := not(dib_ecc_col(62));
                elsif (injectsbiterr_dly = '1') then
                  dib_ecc_col(30) := not(dib_ecc_col(30));
                end if;

              end if;
              
              
              if (RAM_MODE = "SDP" and EN_ECC_WRITE = TRUE and enb_dly = '1') then
                  
                dip_ecc_col := fn_dip_ecc('1', dib_dly, dipb_dly);				
                eccparity_out <= dip_ecc_col;
                prcd_ox_wr_ram_b (viol_type, "10", wea_reg_dly, web_dly, dib_ecc_col, dip_ecc_col, addra_reg_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              else
                
                prcd_ox_wr_ram_b (viol_type, "10", wea_reg_dly, web_dly, dib_ecc_col, dipb_dly, addra_reg_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              end if;
			    
              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", web_dly, wea_reg_dly, addra_reg_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", wea_reg_dly, web_dly, addrb_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);
              end if;


              prcd_col_wr_ram_a (viol_type, "10", web_dly, "11111111", di_x, di_x(7 downto 0), addrb_dly, addra_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              prcd_col_wr_ram_b (viol_type, "10", wea_reg_dly, "11111111", di_x, di_x(7 downto 0), addra_reg_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              
              if (RAM_MODE = "SDP" and EN_ECC_READ = TRUE) then
                prcd_col_ecc_read (doa_buf, dopa_buf, addra_reg_dly, dbiterr_out_var, sbiterr_out_var, mem, memp, syndrome);
              end if;

            else
              viol_time := 0;
              
            end if;

          end if; -- /if ((rising_edge(clka_dly) and rising_edge(clkb_dly)) or viol_time = 1) then

          else
            -- 7series
                
            if ((rising_edge(clka_dly) and rising_edge(clkb_dly)) or viol_time = 1) then

             if (ADDRA_dly(15 downto col_addr_lsb) = ADDRB_dly(15 downto col_addr_lsb)) then            

              viol_type := "01";
              chk_col_same_clk := 1;

              
              if ((wr_mode_a = "01" or wr_mode_b = "01") and (time_port_a > time_port_b)) then
                doa_buf := dob_buf;
                dopa_buf := dopb_buf;
              elsif ((wr_mode_a = "01" or wr_mode_b = "01") and (time_port_b > time_port_a)) then
                dob_buf := doa_buf;
                dopb_buf := dopa_buf;
              else
                prcd_rd_ram_a (addra_dly, doa_buf, dopa_buf, mem, memp);
                prcd_rd_ram_b (addrb_dly, dob_buf, dopb_buf, mem, memp);
              end if;

              
              prcd_col_wr_ram_a (viol_type, "00", web_dly, wea_dly, di_x, di_x(7 downto 0), addrb_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              prcd_col_wr_ram_b (viol_type, "00", wea_dly, web_dly, di_x, di_x(7 downto 0), addra_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              chk_col_same_clk := 0;
              
              prcd_col_rd_ram_a (viol_type, "01", web_dly, wea_dly, addra_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              prcd_col_rd_ram_b (viol_type, "01", wea_dly, web_dly, addrb_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);

              prcd_col_wr_ram_a (viol_type, "10", web_dly, wea_dly, dia_dly, dipa_dly, addrb_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);


              dib_ecc_col := dib_dly;

              if (EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE) then

                if (injectdbiterr_dly = '1') then
                  dib_ecc_col(30) := not(dib_ecc_col(30));
                  dib_ecc_col(62) := not(dib_ecc_col(62));
                elsif (injectsbiterr_dly = '1') then
                  dib_ecc_col(30) := not(dib_ecc_col(30));
                end if;

              end if;
              
              
              if (RAM_MODE = "SDP" and EN_ECC_WRITE = TRUE and enb_dly = '1') then
                  
                dip_ecc_col := fn_dip_ecc('1', dib_dly, dipb_dly);				
                eccparity_out <= dip_ecc_col;
                prcd_col_wr_ram_b (viol_type, "10", wea_dly, web_dly, dib_ecc_col, dip_ecc_col, addra_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              else
                
                prcd_col_wr_ram_b (viol_type, "10", wea_dly, web_dly, dib_ecc_col, dipb_dly, addra_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              end if;
			    
              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", web_dly, wea_dly, addra_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", wea_dly, web_dly, addrb_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);
              end if;

              if ((RAM_MODE = "SDP" and EN_ECC_READ = TRUE) and ((time_port_a > time_port_b) or (rising_edge(clka_dly) and rising_edge(clkb_dly)))) then
                prcd_col_ecc_read (doa_buf, dopa_buf, addra_dly, dbiterr_out_var, sbiterr_out_var, mem, memp, syndrome);
              end if;


            elsif ((wr_mode_a = "01" or wr_mode_b = "01") and (ox_addra_reconstruct(15 downto col_addr_lsb) = ox_addrb_reconstruct(15 downto col_addr_lsb)) and RDADDR_COLLISION_HWCONFIG = "PERFORMANCE") then

              prcd_disp_addr_ox_msg (addra_dly,  addrb_dly);
              
            else
              viol_time := 0;
              
            end if;

          elsif (rising_edge(clka_dly) and  (not(rising_edge(clkb_dly)))) then

            if (ADDRA_dly(15 downto col_addr_lsb) = ADDRB_reg_dly(15 downto col_addr_lsb)) then
              
              viol_type := "10";

              prcd_rd_ram_a (addra_dly, doa_buf, dopa_buf, mem, memp);

              prcd_col_wr_ram_a (viol_type, "00", web_reg_dly, wea_dly, di_x, di_x(7 downto 0), addrb_reg_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              prcd_col_wr_ram_b (viol_type, "00", wea_dly, web_reg_dly, di_x, di_x(7 downto 0), addra_dly, addrb_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              prcd_col_rd_ram_a (viol_type, "01", web_reg_dly, wea_dly, addra_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              prcd_col_rd_ram_b (viol_type, "01", wea_dly, web_reg_dly, addrb_reg_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);

              prcd_col_wr_ram_a (viol_type, "10", web_reg_dly, wea_dly, dia_dly, dipa_dly, addrb_reg_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);


              dib_ecc_col := dib_reg_dly;

              if (EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE) then

                if (injectdbiterr_dly = '1') then
                  dib_ecc_col(30) := not(dib_ecc_col(30));
                  dib_ecc_col(62) := not(dib_ecc_col(62));
                elsif (injectsbiterr_dly = '1') then
                  dib_ecc_col(30) := not(dib_ecc_col(30));
                end if;

              end if;
              
              
              if (RAM_MODE = "SDP" and EN_ECC_WRITE = TRUE and enb_dly = '1') then
                  
                dip_ecc_col := fn_dip_ecc('1', dib_reg_dly, dipb_reg_dly);				
                eccparity_out <= dip_ecc_col;
                prcd_col_wr_ram_b (viol_type, "10", wea_dly, web_reg_dly, dib_ecc_col, dip_ecc_col, addra_dly, addrb_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              else
                
                prcd_col_wr_ram_b (viol_type, "10", wea_dly, web_reg_dly, dib_ecc_col, dipb_reg_dly, addra_dly, addrb_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              end if;
			    
              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", web_reg_dly, wea_dly, addra_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", wea_dly, web_reg_dly, addrb_reg_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);
              end if;


              if (RAM_MODE = "SDP" and EN_ECC_READ = TRUE) then
                prcd_col_ecc_read (doa_buf, dopa_buf, addra_dly, dbiterr_out_var, sbiterr_out_var, mem, memp, syndrome);
              end if;

            elsif ((wr_mode_a = "01" or wr_mode_b = "01") and (ox_addra_reconstruct(15 downto col_addr_lsb) = ox_addrb_reconstruct_reg(15 downto col_addr_lsb)) and RDADDR_COLLISION_HWCONFIG = "PERFORMANCE") then

              prcd_disp_addr_ox_msg (addra_dly,  addrb_reg_dly);

            else
              viol_time := 0;
              
            end if;

          elsif ((not(rising_edge(clka_dly))) and rising_edge(clkb_dly)) then

            if (ADDRA_reg_dly(15 downto col_addr_lsb) = ADDRB_dly(15 downto col_addr_lsb)) then

              viol_type := "11";

              prcd_rd_ram_b (addrb_dly, dob_buf, dopb_buf, mem, memp);

              prcd_col_wr_ram_a (viol_type, "00", web_dly, wea_reg_dly, di_x, di_x(7 downto 0), addrb_dly, addra_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);
              prcd_col_wr_ram_b (viol_type, "00", wea_reg_dly, web_dly, di_x, di_x(7 downto 0), addra_reg_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              prcd_col_rd_ram_a (viol_type, "01", web_dly, wea_reg_dly, addra_reg_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              prcd_col_rd_ram_b (viol_type, "01", wea_reg_dly, web_dly, addrb_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);

              prcd_col_wr_ram_a (viol_type, "10", web_dly, wea_reg_dly, dia_reg_dly, dipa_reg_dly, addrb_dly, addra_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              
              dib_ecc_col := dib_dly;

              if (EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE) then

                if (injectdbiterr_dly = '1') then
                  dib_ecc_col(30) := not(dib_ecc_col(30));
                  dib_ecc_col(62) := not(dib_ecc_col(62));
                elsif (injectsbiterr_dly = '1') then
                  dib_ecc_col(30) := not(dib_ecc_col(30));
                end if;

              end if;
              
              
              if (RAM_MODE = "SDP" and EN_ECC_WRITE = TRUE and enb_dly = '1') then
                  
                dip_ecc_col := fn_dip_ecc('1', dib_dly, dipb_dly);				
                eccparity_out <= dip_ecc_col;
                prcd_col_wr_ram_b (viol_type, "10", wea_reg_dly, web_dly, dib_ecc_col, dip_ecc_col, addra_reg_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              else
                
                prcd_col_wr_ram_b (viol_type, "10", wea_reg_dly, web_dly, dib_ecc_col, dipb_dly, addra_reg_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg, chk_col_same_clk, chk_ox_same_clk, chk_ox_msg);

              end if;
			    
              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", web_dly, wea_reg_dly, addra_reg_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", wea_reg_dly, web_dly, addrb_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);
              end if;


              if (RAM_MODE = "SDP" and EN_ECC_READ = TRUE) then
                prcd_col_ecc_read (doa_buf, dopa_buf, addra_reg_dly, dbiterr_out_var, sbiterr_out_var, mem, memp, syndrome);
              end if;

            elsif ((wr_mode_a = "01" or wr_mode_b = "01") and (ox_addra_reconstruct_reg(15 downto col_addr_lsb) = ox_addrb_reconstruct(15 downto col_addr_lsb)) and RDADDR_COLLISION_HWCONFIG = "PERFORMANCE") then
                              
              prcd_disp_addr_ox_msg (addra_reg_dly,  addrb_dly);
              
            else
              viol_time := 0;
              
            end if;
          end if;
         
        end if;
         

         if (SIM_COLLISION_CHECK = "WARNING_ONLY") then
           viol_time := 0;
         end if;
          
        end if;
      end if;
-------------------------------------------------------------------------------
-- end collision
-------------------------------------------------------------------------------

    end if;
       
-------------------------------------------------------------------------------
-- Port A
-------------------------------------------------------------------------------        
    if (rising_edge(clka_dly)) then

      -- DRC
      if (rstrama_dly = '1' and RAM_MODE = "SDP" and (EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE)) then
        assert false
        report "DRC Warning : SET/RESET (RSTRAM) is not supported in ECC mode."
        severity Warning;
      end if;
      
      
      -- registering addra_dly(15) the second time
      if (regcea_dly = '1') then
        addra_dly_15_reg1 <= addra_dly_15_reg_var;        
      end if;


      -- registering addra[15)
      if (ena_dly = '1' and (wr_mode_a /= "10" or wea_dly(0) = '0' or rstrama_dly = '1')) then
        if (cascade_a(1) = '1') then
          addra_dly_15_reg_var :=  not addra_dly(15);
        else
          addra_dly_15_reg_var := addra_dly(15);
        end if;
      end if;

      
      addra_dly_15_reg <= addra_dly_15_reg_var;

      
      if (gsr_dly = '0' and ena_dly = '1' and (cascade_a = "00" or (addra_dly_15_reg_bram_var = '0' and cascade_a /= "00"))) then

        if (rstrama_dly = '1') then

          doa_buf(ra_width-1 downto 0) := SRVAL_A_STD(ra_width-1 downto 0);
          doa_out(ra_width-1 downto 0) <= SRVAL_A_STD(ra_width-1 downto 0);          

          if (ra_width >= 8) then
            dopa_buf(ra_widthp-1 downto 0) := SRVAL_A_STD((ra_width+ra_widthp)-1 downto ra_width);
            dopa_out(ra_widthp-1 downto 0) <= SRVAL_A_STD((ra_width+ra_widthp)-1 downto ra_width);            
          end if;

        end if;
      
        if (viol_time = 0) then

            -- read for rf
            if (wr_mode_a = "01" or (RAM_MODE = "SDP" and EN_ECC_READ = TRUE)) then
              prcd_rd_ram_a (addra_dly, doa_buf, dopa_buf, mem, memp);

              -- ECC decode  -- only port A
              if (RAM_MODE = "SDP" and EN_ECC_READ = TRUE) then

                dopr_ecc := fn_dip_ecc('0', doa_buf, dopa_buf);

                syndrome := dopr_ecc xor dopa_buf;

                if (syndrome /= "00000000") then

                  if (syndrome(7) = '1') then  -- dectect single bit error

                    ecc_bit_position := doa_buf(63 downto 57) & dopa_buf(6) & doa_buf(56 downto 26) & dopa_buf(5) & doa_buf(25 downto 11) & dopa_buf(4) & doa_buf(10 downto 4) & dopa_buf(3) & doa_buf(3 downto 1) & dopa_buf(2) & doa_buf(0) & dopa_buf(1 downto 0) & dopa_buf(7);

                    tmp_syndrome_int := SLV_TO_INT(syndrome(6 downto 0));

                    if (tmp_syndrome_int > 71) then
                      assert false
                        report "DRC Error : Simulation halted due Corrupted DIP. To correct this problem, make sure that reliable data is fed to the DIP. The correct Parity must be generated by a Hamming code encoder or encoder in the Block RAM. The output from the model is unreliable if there are more than 2 bit errors. The model doesn't warn if there is sporadic input of more than 2 bit errors due to the limitation in Hamming code."
                        severity failure;
                    end if;
        
                    ecc_bit_position(tmp_syndrome_int) := not ecc_bit_position(tmp_syndrome_int); -- correct single bit error in the output 

                    dia_dly_ecc_corrected := ecc_bit_position(71 downto 65) & ecc_bit_position(63 downto 33) & ecc_bit_position(31 downto 17) & ecc_bit_position(15 downto 9) & ecc_bit_position(7 downto 5) & ecc_bit_position(3); -- correct single bit error in the memory

                    doa_buf := dia_dly_ecc_corrected;
			
                    dipa_dly_ecc_corrected := ecc_bit_position(0) & ecc_bit_position(64) & ecc_bit_position(32) & ecc_bit_position(16) & ecc_bit_position(8) & ecc_bit_position(4) & ecc_bit_position(2 downto 1); -- correct single bit error in the parity memory
                
                    dopa_buf := dipa_dly_ecc_corrected;
                
                    dbiterr_out_var := '0';
                    sbiterr_out_var := '1';

                  elsif (syndrome(7) = '0') then  -- double bit error
                    sbiterr_out_var := '0';
                    dbiterr_out_var := '1';
                  end if;
                else
                  dbiterr_out_var := '0';
                  sbiterr_out_var := '0';
                end if;

                -- output of rdaddrecc
                rdaddrecc_out(8 downto 0) <= addra_dly(14 downto 6);

              end if;
          end if;


          -- Write
          prcd_wr_ram_a (wea_dly, dia_dly, dipa_dly, addra_dly, mem, memp, syndrome);    

          -- Read if not read first
          if (wr_mode_a /= "01" and (not(RAM_MODE = "SDP" and EN_ECC_READ = TRUE))) then
            prcd_rd_ram_a (addra_dly, doa_buf, dopa_buf, mem, memp);
          end if;


         end if;
     end if;
   end if;
    
-------------------------------------------------------------------------------
-- Port B
-------------------------------------------------------------------------------

    if (rising_edge(clkb_dly)) then

      -- DRC
      if (rstramb_dly = '1' and RAM_MODE = "SDP" and (EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE)) then
        assert false
        report "DRC Warning : SET/RESET (RSTRAM) is not supported in ECC mode."
        severity Warning;
      end if;
      

      if (not(EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE)) then
      
        if (injectsbiterr_dly = '1') then
          assert false
            report "DRC Warning : INJECTSBITERR is not supported when neither EN_ECC_WRITE nor EN_ECCREAD = TRUE on RAMB36E1 instance."
            severity Warning;
        end if;

        if (injectdbiterr_dly = '1') then
          assert false
            report "DRC Warning : INJECTDBITERR is not supported when neither EN_ECC_WRITE nor EN_ECCREAD = TRUE on RAMB36E1 instance."
            severity Warning;
        end if;

      end if;

      
      -- registering addrb_dly(15) the second time
      if (regceb_dly = '1') then
        addrb_dly_15_reg1 <= addrb_dly_15_reg_var;        
      end if;


      -- registering addrb(15)
      if (enb_dly = '1' and (wr_mode_b /= "10" or web_dly(0) = '0' or rstramb_dly = '1')) then
        if (cascade_b(1) = '1') then
          addrb_dly_15_reg_var :=  not addrb_dly(15);
        else
          addrb_dly_15_reg_var := addrb_dly(15);
        end if;
      end if;

      
      addrb_dly_15_reg <= addrb_dly_15_reg_var;

      if (gsr_dly = '0' and enb_dly = '1' and (cascade_b = "00" or (addrb_dly_15_reg_bram_var = '0' and cascade_b /= "00"))) then

        if (rstramb_dly = '1') then

          dob_buf(rb_width-1 downto 0) := SRVAL_B_STD(rb_width-1 downto 0);
          dob_out(rb_width-1 downto 0) <= SRVAL_B_STD(rb_width-1 downto 0);          

          if (rb_width >= 8) then
            dopb_buf(rb_widthp-1 downto 0) := SRVAL_B_STD((rb_width+rb_widthp)-1 downto rb_width);
            dopb_out(rb_widthp-1 downto 0) <= SRVAL_B_STD((rb_width+rb_widthp)-1 downto rb_width);            
          end if;

        end if;

        
        if (viol_time = 0) then

          -- ECC encode
          if (RAM_MODE = "SDP" and EN_ECC_WRITE = TRUE) then  

            dip_ecc := fn_dip_ecc('1', dib_dly, dipb_dly);
            eccparity_out <= dip_ecc;
            dipb_dly_ecc := dip_ecc;

          else

            dipb_dly_ecc := dipb_dly;

          end if;


          -- injecting error
          dib_dly_ecc := dib_dly;

          if (EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE) then

            if (injectdbiterr_dly = '1') then
              dib_dly_ecc(30) := not(dib_dly_ecc(30));
              dib_dly_ecc(62) := not(dib_dly_ecc(62));
            elsif (injectsbiterr_dly = '1') then
              dib_dly_ecc(30) := not(dib_dly_ecc(30));
            end if;

          end if;
          
          
          -- Read first
          if (wr_mode_b = "01" and rstramb_dly = '0') then
            prcd_rd_ram_b (addrb_dly, dob_buf, dopb_buf, mem, memp);            
          end if;

          
          -- Write
          prcd_wr_ram_b (web_dly, dib_dly_ecc, dipb_dly_ecc, addrb_dly, mem, memp);
            

          if (wr_mode_b /= "01" and rstramb_dly = '0') then
            prcd_rd_ram_b (addrb_dly, dob_buf, dopb_buf, mem, memp);
          end if;
          
        end if;
      end if;
    end if;
    

    -- outputs of port A
    if (ena_dly = '1' and (rising_edge(clka_dly) or viol_time /= 0)) then
      if (rstrama_dly = '0' and (wr_mode_a /= "10" or (WRITE_WIDTH_A <= 9 and wea_dly(0) = '0') or (WRITE_WIDTH_A = 18 and wea_dly(1 downto 0) = "00") or ((WRITE_WIDTH_A = 36 or WRITE_WIDTH_A = 72) and wea_dly(3 downto 0) = "0000"))) then

        doa_out <= doa_buf;
        dopa_out <= dopa_buf;

      end if;
    end if;


    -- outputs of port B
    if (enb_dly = '1' and (rising_edge(clkb_dly) or viol_time /= 0)) then
      if (rstramb_dly = '0' and (wr_mode_b /= "10" or (WRITE_WIDTH_B <= 9 and web_dly(0) = '0') or (WRITE_WIDTH_B = 18 and web_dly(1 downto 0) = "00") or (WRITE_WIDTH_B = 36 and web_dly(3 downto 0) = "0000") or (WRITE_WIDTH_B = 72 and web_dly(7 downto 0) = "00000000"))) then

        dob_out <= dob_buf;
        dopb_out <= dopb_buf;

      end if;
    end if;

    
    viol_time := 0;
    viol_type := "00";
    col_wr_wr_msg := '1';
    col_wra_rdb_msg := '1';
    col_wrb_rda_msg := '1';
    dbiterr_out <= dbiterr_out_var;
    sbiterr_out <= sbiterr_out_var;

   end if;
  end if;

  end process prcs_clk;

    
  -- ***** Output Registers **** Port A *****
  outreg_clka: process (clka_dly, gsr_dly)
    variable FIRST_TIME : boolean := true;
    
  begin  -- process outreg_clka

    if (rising_edge(clka_dly) or rising_edge(gsr_dly) or FIRST_TIME) then

      if (DOA_REG = 1) then
        
        if (gsr_dly = '1' or FIRST_TIME) then

          rdaddrecc_outreg <= (others => '0');
          dbiterr_outreg <= '0';
          sbiterr_outreg <= '0';
          
          doa_outreg(ra_width-1 downto 0) <= INIT_A_STD(ra_width-1 downto 0);

          if (ra_width >= 8) then
            dopa_outreg(ra_widthp-1 downto 0) <= INIT_A_STD((ra_width+ra_widthp)-1 downto ra_width);
          end if;

          FIRST_TIME := false;
          
        elsif (gsr_dly = '0') then
          
          if (regcea_dly = '1') then
            dbiterr_outreg <= dbiterr_out;
            sbiterr_outreg <= sbiterr_out;
            rdaddrecc_outreg <= rdaddrecc_out;
          end if;
            
          if (RSTREG_PRIORITY_A = "REGCE") then -- Virtex5 behavior

            if (regcea_dly = '1') then
              if (rstrega_dly = '1') then

                doa_outreg(ra_width-1 downto 0) <= SRVAL_A_STD(ra_width-1 downto 0);

                if (ra_width >= 8) then
                  dopa_outreg(ra_widthp-1 downto 0) <= SRVAL_A_STD((ra_width+ra_widthp)-1 downto ra_width);
                end if;

              elsif (rstrega_dly = '0') then

                doa_outreg <= doa_out;
                dopa_outreg <= dopa_out;

              end if;     
            end if;

          else

            if (rstrega_dly = '1') then
              
              doa_outreg(ra_width-1 downto 0) <= SRVAL_A_STD(ra_width-1 downto 0);

              if (ra_width >= 8) then
                dopa_outreg(ra_widthp-1 downto 0) <= SRVAL_A_STD((ra_width+ra_widthp)-1 downto ra_width);
              end if;

            elsif (rstrega_dly = '0') then

              if (regcea_dly = '1') then
                doa_outreg <= doa_out;
                dopa_outreg <= dopa_out;
              end if;     

            end if;
            
          end if;
        end if;
        
      end if;

    end if;
  end process outreg_clka;
  
  -- ********* Cascade  Port A ********
  cascade_a_mux: process (clka_dly, cascadeina_dly, addra_dly_15_reg, doa_out, dopa_out)
  begin  -- process cascade_a_mux
    
    if (rising_edge(clka_dly) or cascadeina_dly'event or addra_dly_15_reg'event or doa_out'event or dopa_out'event) then
      if (cascade_a(1) = '1' and addra_dly_15_reg = '1') then 
        doa_out_mux(0) <= cascadeina_dly;
      else
        doa_out_mux <= doa_out;
        dopa_out_mux <= dopa_out;
      end if;
    end if;

  end process cascade_a_mux;
  
  cascade_a_muxreg: process (clka_dly, cascadeina_dly, addra_dly_15_reg1, doa_outreg, dopa_outreg)
  begin  -- process cascade_a_muxreg
    
    if (rising_edge(clka_dly) or cascadeina_dly'event or addra_dly_15_reg1'event or doa_outreg'event or dopa_outreg'event) then
      if (cascade_a(1) = '1' and addra_dly_15_reg1 = '1') then 
        doa_outreg_mux(0) <= cascadeina_dly;
      else
        doa_outreg_mux <= doa_outreg;
        dopa_outreg_mux <= dopa_outreg;
      end if;
    end if;

  end process cascade_a_muxreg;
  

  outmux_clka: process (doa_out_mux, dopa_out_mux, doa_outreg_mux, dopa_outreg_mux, dbiterr_out, dbiterr_outreg, sbiterr_out, sbiterr_outreg, rdaddrecc_out, rdaddrecc_outreg)
  begin  -- process outmux_clka

      case DOA_REG is
        when 0 =>
                  dbiterr_out_out <= dbiterr_out;
                  sbiterr_out_out <= sbiterr_out;
                  doa_out_out(ra_width-1 downto 0) <= doa_out_mux(ra_width-1 downto 0);
                  dopa_out_out(ra_widthp-1 downto 0) <= dopa_out_mux(ra_widthp-1 downto 0);
                  rdaddrecc_out_out <= rdaddrecc_out;
        when 1 =>
                  dbiterr_out_out <= dbiterr_outreg;
                  sbiterr_out_out <= sbiterr_outreg;
                  doa_out_out(ra_width-1 downto 0) <= doa_outreg_mux(ra_width-1 downto 0);
                  dopa_out_out(ra_widthp-1 downto 0) <= dopa_outreg_mux(ra_widthp-1 downto 0);
                  rdaddrecc_out_out <= rdaddrecc_outreg;
        when others => assert false
                       report "Attribute Syntax Error: The allowed integer values for DOA_REG are 0 or 1."
                       severity Failure;
      end case;

  end process outmux_clka;

    
  -- ***** Output Registers **** Port B *****
  outreg_clkb: process (clkb_dly, gsr_dly)
    variable FIRST_TIME : boolean := true;

  begin  -- process outreg_clkb

    if (rising_edge(clkb_dly) or rising_edge(gsr_dly) or FIRST_TIME) then

      if (DOB_REG = 1) then
        
        if (gsr_dly = '1' or FIRST_TIME) then
          dob_outreg(rb_width-1 downto 0) <= INIT_B_STD(rb_width-1 downto 0);

          if (rb_width >= 8) then
            dopb_outreg(rb_widthp-1 downto 0) <= INIT_B_STD((rb_width+rb_widthp)-1 downto rb_width);
          end if;

          FIRST_TIME := false;
          
        elsif (gsr_dly = '0') then

          if (RSTREG_PRIORITY_B = "REGCE") then -- Virtex5 behavior

            if (regceb_dly = '1') then
              if (rstregb_dly = '1') then

                dob_outreg(rb_width-1 downto 0) <= SRVAL_B_STD(rb_width-1 downto 0);

                if (rb_width >= 8) then
                  dopb_outreg(rb_widthp-1 downto 0) <= SRVAL_B_STD((rb_width+rb_widthp)-1 downto rb_width);
                end if;

              elsif (rstregb_dly = '0') then

                dob_outreg <= dob_out;
                dopb_outreg <= dopb_out;

              end if;     
            end if;

          else

            if (rstregb_dly = '1') then
              
              dob_outreg(rb_width-1 downto 0) <= SRVAL_B_STD(rb_width-1 downto 0);

              if (rb_width >= 8) then
                dopb_outreg(rb_widthp-1 downto 0) <= SRVAL_B_STD((rb_width+rb_widthp)-1 downto rb_width);
              end if;

            elsif (rstregb_dly = '0') then

              if (regceb_dly = '1') then
                dob_outreg <= dob_out;
                dopb_outreg <= dopb_out;
              end if;     

            end if;
            
          end if;

        end if;
      end if;
      
    end if;
  end process outreg_clkb;

    
  -- ********* Cascade  Port B ********
  cascade_b_mux: process (clkb_dly, cascadeinb_dly, addrb_dly_15_reg, dob_out, dopb_out)
  begin  -- process cascade_b_mux
    
    if (rising_edge(clkb_dly) or cascadeinb_dly'event or addrb_dly_15_reg'event or dob_out'event or dopb_out'event) then
      if (cascade_b(1) = '1' and addrb_dly_15_reg = '1') then 
        dob_out_mux(0) <= cascadeinb_dly;
      else
        dob_out_mux <= dob_out;
        dopb_out_mux <= dopb_out;
      end if;
    end if;

  end process cascade_b_mux;
  
  cascade_b_muxreg: process (clkb_dly, cascadeinb_dly, addrb_dly_15_reg1, dob_outreg, dopb_outreg)
  begin  -- process cascade_b_muxreg
    
    if (rising_edge(clkb_dly) or cascadeinb_dly'event or addrb_dly_15_reg1'event or dob_outreg'event or dopb_outreg'event) then
      if (cascade_b(1) = '1' and addrb_dly_15_reg1 = '1') then 
        dob_outreg_mux(0) <= cascadeinb_dly;
      else
        dob_outreg_mux <= dob_outreg;
        dopb_outreg_mux <= dopb_outreg;
      end if;
    end if;

  end process cascade_b_muxreg;

  
  outmux_clkb: process (dob_out_mux, dopb_out_mux, dob_outreg_mux, dopb_outreg_mux)
  begin  -- process outmux_clkb

      case DOB_REG is
        when 0 =>
                  dob_out_out(rb_width-1 downto 0) <= dob_out_mux(rb_width-1 downto 0);
                  dopb_out_out(rb_widthp-1 downto 0) <= dopb_out_mux(rb_widthp-1 downto 0);
        when 1 =>
                  dob_out_out(rb_width-1 downto 0) <= dob_outreg_mux(rb_width-1 downto 0);
                  dopb_out_out(rb_widthp-1 downto 0) <= dopb_outreg_mux(rb_widthp-1 downto 0);
        when others => assert false
                       report "Attribute Syntax Error: The allowed integer values for DOB_REG are 0 or 1."
                       severity Failure;
      end case;

  end process outmux_clkb;


-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------
    
  prcs_output: process (doa_out_out, dopa_out_out, dob_out_out, dopb_out_out, eccparity_out,
                        dbiterr_out_out, sbiterr_out_out, rdaddrecc_out_out)
  begin  -- process prcs_output

    DOA <= doa_out_out;
    DOPA <= dopa_out_out;
    DOB <= dob_out_out;
    DOPB <= dopb_out_out;
    RDADDRECC <= rdaddrecc_out_out;
    ECCPARITY <= eccparity_out;
    DBITERR <= dbiterr_out_out;
    SBITERR <= sbiterr_out_out;
    CASCADEOUTA <= doa_out_out(0);
    CASCADEOUTB <= dob_out_out(0);
    
  end process prcs_output;
  

end RB36_INTERNAL_VHDL_V;

-- end of RB36_INTERNAL_VHDL - Note: Not an user primitive


-------------------------------------------------------------------------------
-- RAMB36E1
-------------------------------------------------------------------------------

----- CELL RAMB36E1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;

entity RAMB36E1 is
generic (

    DOA_REG : integer := 0;
    DOB_REG : integer := 0;
    EN_ECC_READ : boolean := FALSE;
    EN_ECC_WRITE : boolean := FALSE; 
    INITP_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_08 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_09 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_0A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_0B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_0C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_0D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_0E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_08 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_09 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_10 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_11 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_12 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_13 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_14 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_15 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_16 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_17 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_18 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_19 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_20 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_21 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_22 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_23 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_24 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_25 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_26 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_27 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_28 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_29 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_30 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_31 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_32 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_33 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_34 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_35 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_36 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_37 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_38 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_39 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_40 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_41 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_42 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_43 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_44 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_45 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_46 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_47 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_48 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_49 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_4A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_4B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_4C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_4D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_4E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_4F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_50 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_51 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_52 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_53 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_54 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_55 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_56 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_57 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_58 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_59 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_5A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_5B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_5C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_5D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_5E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_5F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_60 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_61 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_62 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_63 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_64 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_65 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_66 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_67 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_68 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_69 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_6A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_6B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_6C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_6D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_6E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_6F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_70 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_71 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_72 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_73 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_74 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_75 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_76 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_77 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_78 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_79 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_7A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_7B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_7C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_7D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_7E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_7F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_A : bit_vector := X"000000000";
    INIT_B : bit_vector := X"000000000";
    INIT_FILE : string := "NONE";
    RAM_EXTENSION_A : string := "NONE";
    RAM_EXTENSION_B : string := "NONE";
    RAM_MODE : string := "TDP";
    RDADDR_COLLISION_HWCONFIG : string := "DELAYED_WRITE";
    READ_WIDTH_A : integer := 0;
    READ_WIDTH_B : integer := 0;
    RSTREG_PRIORITY_A : string := "RSTREG";
    RSTREG_PRIORITY_B : string := "RSTREG";
    SIM_COLLISION_CHECK : string := "ALL";
    SIM_DEVICE : string := "VIRTEX6";
    SRVAL_A : bit_vector := X"000000000";
    SRVAL_B : bit_vector := X"000000000";
    WRITE_MODE_A : string := "WRITE_FIRST";
    WRITE_MODE_B : string := "WRITE_FIRST";
    WRITE_WIDTH_A : integer := 0;
    WRITE_WIDTH_B : integer := 0
    
  );

port (

    CASCADEOUTA : out std_ulogic;
    CASCADEOUTB : out std_ulogic;
    DBITERR : out std_ulogic;
    DOADO : out std_logic_vector(31 downto 0);
    DOBDO : out std_logic_vector(31 downto 0);
    DOPADOP : out std_logic_vector(3 downto 0);
    DOPBDOP : out std_logic_vector(3 downto 0);
    ECCPARITY : out std_logic_vector(7 downto 0);
    RDADDRECC : out std_logic_vector(8 downto 0);
    SBITERR : out std_ulogic;
    
    ADDRARDADDR : in std_logic_vector(15 downto 0);
    ADDRBWRADDR : in std_logic_vector(15 downto 0);
    CASCADEINA : in std_ulogic;
    CASCADEINB : in std_ulogic;
    CLKARDCLK : in std_ulogic;
    CLKBWRCLK : in std_ulogic;
    DIADI : in std_logic_vector(31 downto 0);
    DIBDI : in std_logic_vector(31 downto 0);
    DIPADIP : in std_logic_vector(3 downto 0);
    DIPBDIP : in std_logic_vector(3 downto 0);
    ENARDEN : in std_ulogic;
    ENBWREN : in std_ulogic;
    INJECTDBITERR : in std_ulogic;
    INJECTSBITERR : in std_ulogic;
    REGCEAREGCE : in std_ulogic;
    REGCEB : in std_ulogic;
    RSTRAMARSTRAM : in std_ulogic;
    RSTRAMB : in std_ulogic;
    RSTREGARSTREG : in std_ulogic;
    RSTREGB : in std_ulogic;
    WEA : in std_logic_vector(3 downto 0);
    WEBWE : in std_logic_vector(7 downto 0)

  );
end RAMB36E1;
                                                                        
architecture RAMB36E1_V of RAMB36E1 is

  component RB36_INTERNAL_VHDL
	generic
	(
          RAM_MODE : string := "TDP";
          BRAM_SIZE : integer := 36;
          DOA_REG : integer := 0;
          DOB_REG : integer := 0;
          EN_ECC_READ : boolean := FALSE;
          EN_ECC_WRITE : boolean := FALSE; 
          INIT_A : bit_vector := X"000000000000000000";
          INIT_B : bit_vector := X"000000000000000000";
          RDADDR_COLLISION_HWCONFIG : string := "DELAYED_WRITE";
          RAM_EXTENSION_A : string := "NONE";
          RAM_EXTENSION_B : string := "NONE";
          RSTREG_PRIORITY_A : string := "RSTREG";
          RSTREG_PRIORITY_B : string := "RSTREG";
          READ_WIDTH_A : integer := 0;
          READ_WIDTH_B : integer := 0;
          SIM_COLLISION_CHECK : string := "ALL";
          SIM_DEVICE : string := "VIRTEX6";
          SRVAL_A : bit_vector := X"000000000000000000";
          SRVAL_B : bit_vector := X"000000000000000000";
          WRITE_MODE_A : string := "WRITE_FIRST";
          WRITE_MODE_B : string := "WRITE_FIRST";
          WRITE_WIDTH_A : integer := 0;
          WRITE_WIDTH_B : integer := 0;
          INIT_FILE : string := "NONE";
          INIT_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_08 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_09 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_0A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_0B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_0C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_0D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_0E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_10 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_11 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_12 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_13 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_14 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_15 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_16 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_17 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_18 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_19 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_1A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_1B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_1C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_1D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_1E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_1F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_20 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_21 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_22 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_23 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_24 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_25 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_26 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_27 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_28 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_29 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_2A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_2B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_2C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_2D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_2E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_2F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_30 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_31 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_32 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_33 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_34 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_35 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_36 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_37 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_38 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_39 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_3A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_3B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_3C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_3D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_3E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_3F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_40 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_41 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_42 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_43 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_44 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_45 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_46 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_47 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_48 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_49 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_4A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_4B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_4C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_4D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_4E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_4F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_50 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_51 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_52 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_53 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_54 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_55 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_56 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_57 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_58 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_59 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_5A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_5B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_5C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_5D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_5E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_5F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_60 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_61 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_62 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_63 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_64 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_65 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_66 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_67 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_68 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_69 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_6A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_6B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_6C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_6D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_6E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_6F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_70 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_71 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_72 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_73 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_74 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_75 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_76 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_77 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_78 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_79 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_7A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_7B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_7C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_7D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_7E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_7F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_08 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_09 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_0A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_0B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_0C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_0D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_0E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000"
           );
	port
	(
          CASCADEOUTA : out std_ulogic;
          CASCADEOUTB : out std_ulogic;
          DBITERR : out std_ulogic;
          DOA : out std_logic_vector(63 downto 0);
          DOB : out std_logic_vector(63 downto 0);
          DOPA : out std_logic_vector(7 downto 0);
          DOPB : out std_logic_vector(7 downto 0);
          ECCPARITY : out std_logic_vector(7 downto 0);
          SBITERR : out std_ulogic;
          RDADDRECC : out std_logic_vector(8 downto 0);
        
          ADDRA : in std_logic_vector(15 downto 0);
          ADDRB : in std_logic_vector(15 downto 0);
          CASCADEINA : in std_ulogic;
          CASCADEINB : in std_ulogic;
          CLKA : in std_ulogic;
          CLKB : in std_ulogic;
          DIA : in std_logic_vector(63 downto 0);
          DIB : in std_logic_vector(63 downto 0);
          DIPA : in std_logic_vector(7 downto 0);
          DIPB : in std_logic_vector(7 downto 0);
          ENA : in std_ulogic;
          ENB : in std_ulogic;
          INJECTDBITERR : in std_ulogic;
          INJECTSBITERR : in std_ulogic;
          REGCEA : in std_ulogic;
          REGCEB : in std_ulogic;
          RSTRAMA : in std_ulogic;
          RSTRAMB : in std_ulogic;
          RSTREGA : in std_ulogic;
          RSTREGB : in std_ulogic;
          WEA : in std_logic_vector(7 downto 0);
          WEB : in std_logic_vector(7 downto 0)
 	);
  end component;

    
  constant SYNC_PATH_DELAY : time := 100 ps;
  signal GND_4 : std_logic_vector(3 downto 0) := (others => '0');
  signal GND_8 : std_logic_vector(7 downto 0) := (others => '0');
  signal GND_32 : std_logic_vector(31 downto 0) := (others => '0');
  signal GND_64 : std_logic_vector(63 downto 0) := (others => '0');
  signal OPEN_4 : std_logic_vector(3 downto 0);
  signal OPEN_32 : std_logic_vector(31 downto 0);
  signal doa_dly : std_logic_vector(31 downto 0) :=  (others => '0');
  signal dob_dly : std_logic_vector(31 downto 0) :=  (others => '0');
  signal dopa_dly : std_logic_vector(3 downto 0) :=  (others => '0');
  signal dopb_dly : std_logic_vector(3 downto 0) :=  (others => '0');
  signal cascadeouta_dly : std_logic := '0';
  signal cascadeoutb_dly : std_logic := '0';
  signal eccparity_dly : std_logic_vector(7 downto 0) :=  (others => '0');
  signal dbiterr_dly : std_logic := '0';
  signal sbiterr_dly : std_logic := '0';
  signal rdaddrecc_dly : std_logic_vector(8 downto 0) :=  (others => '1');


  function INIT_SRVAL_SDP (
    input_a : bit_vector(35 downto 0);
    input_b : bit_vector(35 downto 0))
    return bit_vector is variable out_init_srval : bit_vector(71 downto 0);
  begin

    if (READ_WIDTH_A = 72) then
      out_init_srval := input_b(35 downto 32) & input_a(35 downto 32) & input_b(31 downto 0) & input_a(31 downto 0);
    else
      out_init_srval := input_b & input_a;
    end if;

    return out_init_srval;  
                         
  end;

  
begin

  TDP: if (RAM_MODE = "TDP") generate
    
    RAMB36E1_TDP_inst : RB36_INTERNAL_VHDL
      generic map (

                DOA_REG => DOA_REG,
                DOB_REG => DOB_REG,
		INIT_A  => INIT_A,
		INIT_B  => INIT_B,
                INIT_FILE => INIT_FILE,
                
		INIT_00 => INIT_00,
		INIT_01 => INIT_01,
		INIT_02 => INIT_02,
		INIT_03 => INIT_03,
		INIT_04 => INIT_04,
		INIT_05 => INIT_05,
		INIT_06 => INIT_06,
		INIT_07 => INIT_07,
		INIT_08 => INIT_08,
		INIT_09 => INIT_09,
		INIT_0A => INIT_0A,
		INIT_0B => INIT_0B,
		INIT_0C => INIT_0C,
		INIT_0D => INIT_0D,
		INIT_0E => INIT_0E,
		INIT_0F => INIT_0F,
		INIT_10 => INIT_10,
		INIT_11 => INIT_11,
		INIT_12 => INIT_12,
		INIT_13 => INIT_13,
		INIT_14 => INIT_14,
		INIT_15 => INIT_15,
		INIT_16 => INIT_16,
		INIT_17 => INIT_17,
		INIT_18 => INIT_18,
		INIT_19 => INIT_19,
		INIT_1A => INIT_1A,
		INIT_1B => INIT_1B,
		INIT_1C => INIT_1C,
		INIT_1D => INIT_1D,
		INIT_1E => INIT_1E,
		INIT_1F => INIT_1F,
		INIT_20 => INIT_20,
		INIT_21 => INIT_21,
		INIT_22 => INIT_22,
		INIT_23 => INIT_23,
		INIT_24 => INIT_24,
		INIT_25 => INIT_25,
		INIT_26 => INIT_26,
		INIT_27 => INIT_27,
		INIT_28 => INIT_28,
		INIT_29 => INIT_29,
		INIT_2A => INIT_2A,
		INIT_2B => INIT_2B,
		INIT_2C => INIT_2C,
		INIT_2D => INIT_2D,
		INIT_2E => INIT_2E,
		INIT_2F => INIT_2F,
		INIT_30 => INIT_30,
		INIT_31 => INIT_31,
		INIT_32 => INIT_32,
		INIT_33 => INIT_33,
		INIT_34 => INIT_34,
		INIT_35 => INIT_35,
		INIT_36 => INIT_36,
		INIT_37 => INIT_37,
		INIT_38 => INIT_38,
		INIT_39 => INIT_39,
		INIT_3A => INIT_3A,
		INIT_3B => INIT_3B,
		INIT_3C => INIT_3C,
		INIT_3D => INIT_3D,
		INIT_3E => INIT_3E,
		INIT_3F => INIT_3F,
		INIT_40 => INIT_40,
		INIT_41 => INIT_41,
		INIT_42 => INIT_42,
		INIT_43 => INIT_43,
		INIT_44 => INIT_44,
		INIT_45 => INIT_45,
		INIT_46 => INIT_46,
		INIT_47 => INIT_47,
		INIT_48 => INIT_48,
		INIT_49 => INIT_49,
		INIT_4A => INIT_4A,
		INIT_4B => INIT_4B,
		INIT_4C => INIT_4C,
		INIT_4D => INIT_4D,
		INIT_4E => INIT_4E,
		INIT_4F => INIT_4F,
		INIT_50 => INIT_50,
		INIT_51 => INIT_51,
		INIT_52 => INIT_52,
		INIT_53 => INIT_53,
		INIT_54 => INIT_54,
		INIT_55 => INIT_55,
		INIT_56 => INIT_56,
		INIT_57 => INIT_57,
		INIT_58 => INIT_58,
		INIT_59 => INIT_59,
		INIT_5A => INIT_5A,
		INIT_5B => INIT_5B,
		INIT_5C => INIT_5C,
		INIT_5D => INIT_5D,
		INIT_5E => INIT_5E,
		INIT_5F => INIT_5F,
		INIT_60 => INIT_60,
		INIT_61 => INIT_61,
		INIT_62 => INIT_62,
		INIT_63 => INIT_63,
		INIT_64 => INIT_64,
		INIT_65 => INIT_65,
		INIT_66 => INIT_66,
		INIT_67 => INIT_67,
		INIT_68 => INIT_68,
		INIT_69 => INIT_69,
		INIT_6A => INIT_6A,
		INIT_6B => INIT_6B,
		INIT_6C => INIT_6C,
		INIT_6D => INIT_6D,
		INIT_6E => INIT_6E,
		INIT_6F => INIT_6F,
		INIT_70 => INIT_70,
		INIT_71 => INIT_71,
		INIT_72 => INIT_72,
		INIT_73 => INIT_73,
		INIT_74 => INIT_74,
		INIT_75 => INIT_75,
		INIT_76 => INIT_76,
		INIT_77 => INIT_77,
		INIT_78 => INIT_78,
		INIT_79 => INIT_79,
		INIT_7A => INIT_7A,
		INIT_7B => INIT_7B,
		INIT_7C => INIT_7C,
		INIT_7D => INIT_7D,
		INIT_7E => INIT_7E,
		INIT_7F => INIT_7F,
                
		INITP_00 => INITP_00,
		INITP_01 => INITP_01,
		INITP_02 => INITP_02,
		INITP_03 => INITP_03,
		INITP_04 => INITP_04,
		INITP_05 => INITP_05,
		INITP_06 => INITP_06,
		INITP_07 => INITP_07,
		INITP_08 => INITP_08,
		INITP_09 => INITP_09,
		INITP_0A => INITP_0A,
		INITP_0B => INITP_0B,
		INITP_0C => INITP_0C,
		INITP_0D => INITP_0D,
		INITP_0E => INITP_0E,
		INITP_0F => INITP_0F,
                
                EN_ECC_READ => EN_ECC_READ,
                EN_ECC_WRITE => EN_ECC_WRITE,
		SIM_COLLISION_CHECK => SIM_COLLISION_CHECK,
                SIM_DEVICE => SIM_DEVICE,
		SRVAL_A => SRVAL_A,
		SRVAL_B => SRVAL_B,
		WRITE_MODE_A => WRITE_MODE_A,
		WRITE_MODE_B => WRITE_MODE_B,                
                RAM_MODE => RAM_MODE,
                BRAM_SIZE => 36,
                RAM_EXTENSION_A => RAM_EXTENSION_A,
                RAM_EXTENSION_B => RAM_EXTENSION_B,
                RDADDR_COLLISION_HWCONFIG => RDADDR_COLLISION_HWCONFIG,
                READ_WIDTH_A => READ_WIDTH_A,
                READ_WIDTH_B => READ_WIDTH_B,
                RSTREG_PRIORITY_A => RSTREG_PRIORITY_A,
                RSTREG_PRIORITY_B => RSTREG_PRIORITY_B, 
                WRITE_WIDTH_A => WRITE_WIDTH_A,
                WRITE_WIDTH_B => WRITE_WIDTH_B          

                )
        port map (
                ADDRA => ADDRARDADDR,
                ADDRB => ADDRBWRADDR,
                CLKA => CLKARDCLK,
                CLKB => CLKBWRCLK,
                DIA(31 downto 0)  => DIADI,
                DIA(63 downto 32) => GND_32,
                DIB(31 downto 0) => DIBDI,
                DIB(63 downto 32) => GND_32,
                DIPA(3 downto 0) => DIPADIP,
                DIPA(7 downto 4) => GND_4,
                DIPB(3 downto 0) => DIPBDIP,
                DIPB(7 downto 4) => GND_4,
                ENA => ENARDEN,
                ENB => ENBWREN,
                RSTRAMA => RSTRAMARSTRAM,
                RSTRAMB => RSTRAMB,
                WEA(3 downto 0) => WEA,
                WEA(7 downto 4) => WEA,
                WEB => WEBWE,
                DOA(31  downto 0) => doa_dly,
                DOA(63 downto 32) => OPEN_32,
                DOB(31 downto 0) => dob_dly,
                DOB(63 downto 32) => OPEN_32,
                DOPA(3 downto 0) => dopa_dly,
                DOPA(7 downto 4) => OPEN_4,
                DOPB(3 downto 0) => dopb_dly,
                DOPB(7 downto 4) => OPEN_4,
                CASCADEOUTA => cascadeouta_dly,
                CASCADEOUTB => cascadeoutb_dly,
                CASCADEINA => CASCADEINA,
                CASCADEINB => CASCADEINB,
                REGCEA => REGCEAREGCE,
                REGCEB => REGCEB,
                RSTREGA => RSTREGARSTREG,
                RSTREGB => RSTREGB,
                RDADDRECC => rdaddrecc_dly,
                INJECTDBITERR => INJECTDBITERR,
                INJECTSBITERR => INJECTSBITERR,
                DBITERR => dbiterr_dly,
                SBITERR => sbiterr_dly,
                ECCPARITY => eccparity_dly
                );

  end generate TDP;


  SDP: if (RAM_MODE = "SDP") generate

    WWB72: if (WRITE_WIDTH_B = 72) generate
      
      RAMB36E1_SDP_inst : RB36_INTERNAL_VHDL
        generic map (

                DOA_REG => DOA_REG,
                DOB_REG => DOB_REG,
		INIT_A  => INIT_SRVAL_SDP(INIT_A, INIT_B),
		INIT_B  => INIT_SRVAL_SDP(INIT_A, INIT_B),
                INIT_FILE => INIT_FILE,
                
		INIT_00 => INIT_00,
		INIT_01 => INIT_01,
		INIT_02 => INIT_02,
		INIT_03 => INIT_03,
		INIT_04 => INIT_04,
		INIT_05 => INIT_05,
		INIT_06 => INIT_06,
		INIT_07 => INIT_07,
		INIT_08 => INIT_08,
		INIT_09 => INIT_09,
		INIT_0A => INIT_0A,
		INIT_0B => INIT_0B,
		INIT_0C => INIT_0C,
		INIT_0D => INIT_0D,
		INIT_0E => INIT_0E,
		INIT_0F => INIT_0F,
		INIT_10 => INIT_10,
		INIT_11 => INIT_11,
		INIT_12 => INIT_12,
		INIT_13 => INIT_13,
		INIT_14 => INIT_14,
		INIT_15 => INIT_15,
		INIT_16 => INIT_16,
		INIT_17 => INIT_17,
		INIT_18 => INIT_18,
		INIT_19 => INIT_19,
		INIT_1A => INIT_1A,
		INIT_1B => INIT_1B,
		INIT_1C => INIT_1C,
		INIT_1D => INIT_1D,
		INIT_1E => INIT_1E,
		INIT_1F => INIT_1F,
		INIT_20 => INIT_20,
		INIT_21 => INIT_21,
		INIT_22 => INIT_22,
		INIT_23 => INIT_23,
		INIT_24 => INIT_24,
		INIT_25 => INIT_25,
		INIT_26 => INIT_26,
		INIT_27 => INIT_27,
		INIT_28 => INIT_28,
		INIT_29 => INIT_29,
		INIT_2A => INIT_2A,
		INIT_2B => INIT_2B,
		INIT_2C => INIT_2C,
		INIT_2D => INIT_2D,
		INIT_2E => INIT_2E,
		INIT_2F => INIT_2F,
		INIT_30 => INIT_30,
		INIT_31 => INIT_31,
		INIT_32 => INIT_32,
		INIT_33 => INIT_33,
		INIT_34 => INIT_34,
		INIT_35 => INIT_35,
		INIT_36 => INIT_36,
		INIT_37 => INIT_37,
		INIT_38 => INIT_38,
		INIT_39 => INIT_39,
		INIT_3A => INIT_3A,
		INIT_3B => INIT_3B,
		INIT_3C => INIT_3C,
		INIT_3D => INIT_3D,
		INIT_3E => INIT_3E,
		INIT_3F => INIT_3F,
		INIT_40 => INIT_40,
		INIT_41 => INIT_41,
		INIT_42 => INIT_42,
		INIT_43 => INIT_43,
		INIT_44 => INIT_44,
		INIT_45 => INIT_45,
		INIT_46 => INIT_46,
		INIT_47 => INIT_47,
		INIT_48 => INIT_48,
		INIT_49 => INIT_49,
		INIT_4A => INIT_4A,
		INIT_4B => INIT_4B,
		INIT_4C => INIT_4C,
		INIT_4D => INIT_4D,
		INIT_4E => INIT_4E,
		INIT_4F => INIT_4F,
		INIT_50 => INIT_50,
		INIT_51 => INIT_51,
		INIT_52 => INIT_52,
		INIT_53 => INIT_53,
		INIT_54 => INIT_54,
		INIT_55 => INIT_55,
		INIT_56 => INIT_56,
		INIT_57 => INIT_57,
		INIT_58 => INIT_58,
		INIT_59 => INIT_59,
		INIT_5A => INIT_5A,
		INIT_5B => INIT_5B,
		INIT_5C => INIT_5C,
		INIT_5D => INIT_5D,
		INIT_5E => INIT_5E,
		INIT_5F => INIT_5F,
		INIT_60 => INIT_60,
		INIT_61 => INIT_61,
		INIT_62 => INIT_62,
		INIT_63 => INIT_63,
		INIT_64 => INIT_64,
		INIT_65 => INIT_65,
		INIT_66 => INIT_66,
		INIT_67 => INIT_67,
		INIT_68 => INIT_68,
		INIT_69 => INIT_69,
		INIT_6A => INIT_6A,
		INIT_6B => INIT_6B,
		INIT_6C => INIT_6C,
		INIT_6D => INIT_6D,
		INIT_6E => INIT_6E,
		INIT_6F => INIT_6F,
		INIT_70 => INIT_70,
		INIT_71 => INIT_71,
		INIT_72 => INIT_72,
		INIT_73 => INIT_73,
		INIT_74 => INIT_74,
		INIT_75 => INIT_75,
		INIT_76 => INIT_76,
		INIT_77 => INIT_77,
		INIT_78 => INIT_78,
		INIT_79 => INIT_79,
		INIT_7A => INIT_7A,
		INIT_7B => INIT_7B,
		INIT_7C => INIT_7C,
		INIT_7D => INIT_7D,
		INIT_7E => INIT_7E,
		INIT_7F => INIT_7F,
                
		INITP_00 => INITP_00,
		INITP_01 => INITP_01,
		INITP_02 => INITP_02,
		INITP_03 => INITP_03,
		INITP_04 => INITP_04,
		INITP_05 => INITP_05,
		INITP_06 => INITP_06,
		INITP_07 => INITP_07,
		INITP_08 => INITP_08,
		INITP_09 => INITP_09,
		INITP_0A => INITP_0A,
		INITP_0B => INITP_0B,
		INITP_0C => INITP_0C,
		INITP_0D => INITP_0D,
		INITP_0E => INITP_0E,
		INITP_0F => INITP_0F,
                
                EN_ECC_READ => EN_ECC_READ,
                EN_ECC_WRITE => EN_ECC_WRITE,
		SIM_COLLISION_CHECK => SIM_COLLISION_CHECK,
                SIM_DEVICE => SIM_DEVICE,
		SRVAL_A => INIT_SRVAL_SDP(SRVAL_A, SRVAL_B),
		SRVAL_B => INIT_SRVAL_SDP(SRVAL_A, SRVAL_B),
		WRITE_MODE_A => WRITE_MODE_A,
		WRITE_MODE_B => WRITE_MODE_B,                
                RAM_MODE => RAM_MODE,
                BRAM_SIZE => 36,
                RAM_EXTENSION_A => RAM_EXTENSION_A,
                RAM_EXTENSION_B => RAM_EXTENSION_B,
                RDADDR_COLLISION_HWCONFIG => RDADDR_COLLISION_HWCONFIG,
                READ_WIDTH_A => READ_WIDTH_A,
                READ_WIDTH_B => READ_WIDTH_B,
                RSTREG_PRIORITY_A => RSTREG_PRIORITY_A,
                RSTREG_PRIORITY_B => RSTREG_PRIORITY_B, 
                WRITE_WIDTH_A => WRITE_WIDTH_A,
                WRITE_WIDTH_B => WRITE_WIDTH_B          

                )
        port map (
                ADDRA => ADDRARDADDR,
                ADDRB => ADDRBWRADDR,
                CLKA => CLKARDCLK,
                CLKB => CLKBWRCLK,
                DIA => GND_64,
                DIB(31 downto 0) => DIADI,
                DIB(63 downto 32) => DIBDI,
                DIPA => GND_8,
                DIPB(3 downto 0) => DIPADIP,
                DIPB(7 downto 4) => DIPBDIP,
                ENA => ENARDEN,
                ENB => ENBWREN,
                RSTRAMA => RSTRAMARSTRAM,
                RSTRAMB => RSTRAMB,
                WEA => GND_8,
                WEB => WEBWE,
                DOA(31  downto 0) => doa_dly,
                DOA(63 downto 32) => dob_dly,
                DOB => OPEN,
                DOPA(3 downto 0) => dopa_dly,
                DOPA(7 downto 4) => dopb_dly,
                DOPB => OPEN,
                CASCADEOUTA => cascadeouta_dly,
                CASCADEOUTB => cascadeoutb_dly,
                CASCADEINA => CASCADEINA,
                CASCADEINB => CASCADEINB,
                REGCEA => REGCEAREGCE,
                REGCEB => REGCEB,
                RSTREGA => RSTREGARSTREG,
                RSTREGB => RSTREGB,
                RDADDRECC => rdaddrecc_dly,
                INJECTDBITERR => INJECTDBITERR,
                INJECTSBITERR => INJECTSBITERR,
                DBITERR => dbiterr_dly,
                SBITERR => sbiterr_dly,
                ECCPARITY => eccparity_dly
                );

    end generate WWB72;


    WWBlt36: if (WRITE_WIDTH_B <= 36) generate
      
      RAMB36E1_SDP_inst : RB36_INTERNAL_VHDL
        generic map (

                DOA_REG => DOA_REG,
                DOB_REG => DOB_REG,
		INIT_A  => INIT_SRVAL_SDP(INIT_A, INIT_B),
		INIT_B  => INIT_SRVAL_SDP(INIT_A, INIT_B),
                INIT_FILE => INIT_FILE,
                
		INIT_00 => INIT_00,
		INIT_01 => INIT_01,
		INIT_02 => INIT_02,
		INIT_03 => INIT_03,
		INIT_04 => INIT_04,
		INIT_05 => INIT_05,
		INIT_06 => INIT_06,
		INIT_07 => INIT_07,
		INIT_08 => INIT_08,
		INIT_09 => INIT_09,
		INIT_0A => INIT_0A,
		INIT_0B => INIT_0B,
		INIT_0C => INIT_0C,
		INIT_0D => INIT_0D,
		INIT_0E => INIT_0E,
		INIT_0F => INIT_0F,
		INIT_10 => INIT_10,
		INIT_11 => INIT_11,
		INIT_12 => INIT_12,
		INIT_13 => INIT_13,
		INIT_14 => INIT_14,
		INIT_15 => INIT_15,
		INIT_16 => INIT_16,
		INIT_17 => INIT_17,
		INIT_18 => INIT_18,
		INIT_19 => INIT_19,
		INIT_1A => INIT_1A,
		INIT_1B => INIT_1B,
		INIT_1C => INIT_1C,
		INIT_1D => INIT_1D,
		INIT_1E => INIT_1E,
		INIT_1F => INIT_1F,
		INIT_20 => INIT_20,
		INIT_21 => INIT_21,
		INIT_22 => INIT_22,
		INIT_23 => INIT_23,
		INIT_24 => INIT_24,
		INIT_25 => INIT_25,
		INIT_26 => INIT_26,
		INIT_27 => INIT_27,
		INIT_28 => INIT_28,
		INIT_29 => INIT_29,
		INIT_2A => INIT_2A,
		INIT_2B => INIT_2B,
		INIT_2C => INIT_2C,
		INIT_2D => INIT_2D,
		INIT_2E => INIT_2E,
		INIT_2F => INIT_2F,
		INIT_30 => INIT_30,
		INIT_31 => INIT_31,
		INIT_32 => INIT_32,
		INIT_33 => INIT_33,
		INIT_34 => INIT_34,
		INIT_35 => INIT_35,
		INIT_36 => INIT_36,
		INIT_37 => INIT_37,
		INIT_38 => INIT_38,
		INIT_39 => INIT_39,
		INIT_3A => INIT_3A,
		INIT_3B => INIT_3B,
		INIT_3C => INIT_3C,
		INIT_3D => INIT_3D,
		INIT_3E => INIT_3E,
		INIT_3F => INIT_3F,
		INIT_40 => INIT_40,
		INIT_41 => INIT_41,
		INIT_42 => INIT_42,
		INIT_43 => INIT_43,
		INIT_44 => INIT_44,
		INIT_45 => INIT_45,
		INIT_46 => INIT_46,
		INIT_47 => INIT_47,
		INIT_48 => INIT_48,
		INIT_49 => INIT_49,
		INIT_4A => INIT_4A,
		INIT_4B => INIT_4B,
		INIT_4C => INIT_4C,
		INIT_4D => INIT_4D,
		INIT_4E => INIT_4E,
		INIT_4F => INIT_4F,
		INIT_50 => INIT_50,
		INIT_51 => INIT_51,
		INIT_52 => INIT_52,
		INIT_53 => INIT_53,
		INIT_54 => INIT_54,
		INIT_55 => INIT_55,
		INIT_56 => INIT_56,
		INIT_57 => INIT_57,
		INIT_58 => INIT_58,
		INIT_59 => INIT_59,
		INIT_5A => INIT_5A,
		INIT_5B => INIT_5B,
		INIT_5C => INIT_5C,
		INIT_5D => INIT_5D,
		INIT_5E => INIT_5E,
		INIT_5F => INIT_5F,
		INIT_60 => INIT_60,
		INIT_61 => INIT_61,
		INIT_62 => INIT_62,
		INIT_63 => INIT_63,
		INIT_64 => INIT_64,
		INIT_65 => INIT_65,
		INIT_66 => INIT_66,
		INIT_67 => INIT_67,
		INIT_68 => INIT_68,
		INIT_69 => INIT_69,
		INIT_6A => INIT_6A,
		INIT_6B => INIT_6B,
		INIT_6C => INIT_6C,
		INIT_6D => INIT_6D,
		INIT_6E => INIT_6E,
		INIT_6F => INIT_6F,
		INIT_70 => INIT_70,
		INIT_71 => INIT_71,
		INIT_72 => INIT_72,
		INIT_73 => INIT_73,
		INIT_74 => INIT_74,
		INIT_75 => INIT_75,
		INIT_76 => INIT_76,
		INIT_77 => INIT_77,
		INIT_78 => INIT_78,
		INIT_79 => INIT_79,
		INIT_7A => INIT_7A,
		INIT_7B => INIT_7B,
		INIT_7C => INIT_7C,
		INIT_7D => INIT_7D,
		INIT_7E => INIT_7E,
		INIT_7F => INIT_7F,
                
		INITP_00 => INITP_00,
		INITP_01 => INITP_01,
		INITP_02 => INITP_02,
		INITP_03 => INITP_03,
		INITP_04 => INITP_04,
		INITP_05 => INITP_05,
		INITP_06 => INITP_06,
		INITP_07 => INITP_07,
		INITP_08 => INITP_08,
		INITP_09 => INITP_09,
		INITP_0A => INITP_0A,
		INITP_0B => INITP_0B,
		INITP_0C => INITP_0C,
		INITP_0D => INITP_0D,
		INITP_0E => INITP_0E,
		INITP_0F => INITP_0F,
                
                EN_ECC_READ => EN_ECC_READ,
                EN_ECC_WRITE => EN_ECC_WRITE,
		SIM_COLLISION_CHECK => SIM_COLLISION_CHECK,
                SIM_DEVICE => SIM_DEVICE,
		SRVAL_A => INIT_SRVAL_SDP(SRVAL_A, SRVAL_B),
		SRVAL_B => INIT_SRVAL_SDP(SRVAL_A, SRVAL_B),
		WRITE_MODE_A => WRITE_MODE_A,
		WRITE_MODE_B => WRITE_MODE_B,                
                RAM_MODE => RAM_MODE,
                BRAM_SIZE => 36,
                RAM_EXTENSION_A => RAM_EXTENSION_A,
                RAM_EXTENSION_B => RAM_EXTENSION_B,
                RDADDR_COLLISION_HWCONFIG => RDADDR_COLLISION_HWCONFIG,
                READ_WIDTH_A => READ_WIDTH_A,
                READ_WIDTH_B => READ_WIDTH_B,
                RSTREG_PRIORITY_A => RSTREG_PRIORITY_A,
                RSTREG_PRIORITY_B => RSTREG_PRIORITY_B, 
                WRITE_WIDTH_A => WRITE_WIDTH_A,
                WRITE_WIDTH_B => WRITE_WIDTH_B          

                )
        port map (
                ADDRA => ADDRARDADDR,
                ADDRB => ADDRBWRADDR,
                CLKA => CLKARDCLK,
                CLKB => CLKBWRCLK,
                DIA => GND_64,
                DIB(31 downto 0) => DIBDI,
                DIB(63 downto 32) => GND_32,
                DIPA => GND_8,
                DIPB(3 downto 0) => DIPBDIP,
                DIPB(7 downto 4) => GND_4,
                ENA => ENARDEN,
                ENB => ENBWREN,
                RSTRAMA => RSTRAMARSTRAM,
                RSTRAMB => RSTRAMB,
                WEA => GND_8,
                WEB => WEBWE,
                DOA(31  downto 0) => doa_dly,
                DOA(63 downto 32) => dob_dly,
                DOB => OPEN,
                DOPA(3 downto 0) => dopa_dly,
                DOPA(7 downto 4) => dopb_dly,
                DOPB => OPEN,
                CASCADEOUTA => cascadeouta_dly,
                CASCADEOUTB => cascadeoutb_dly,
                CASCADEINA => CASCADEINA,
                CASCADEINB => CASCADEINB,
                REGCEA => REGCEAREGCE,
                REGCEB => REGCEB,
                RSTREGA => RSTREGARSTREG,
                RSTREGB => RSTREGB,
                RDADDRECC => rdaddrecc_dly,
                INJECTDBITERR => INJECTDBITERR,
                INJECTSBITERR => INJECTSBITERR,
                DBITERR => dbiterr_dly,
                SBITERR => sbiterr_dly,
                ECCPARITY => eccparity_dly
                );

    end generate WWBlt36;
    
  end generate SDP;
    
    
   prcs_output_wtiming: process (doa_dly, dob_dly, dopa_dly, dopb_dly, cascadeouta_dly, cascadeoutb_dly, eccparity_dly, dbiterr_dly, sbiterr_dly, rdaddrecc_dly)
   begin  -- process prcs_output_wtiming

     CASCADEOUTA <= cascadeouta_dly after SYNC_PATH_DELAY;
     CASCADEOUTB <= cascadeoutb_dly after SYNC_PATH_DELAY;
     DOADO <= doa_dly after SYNC_PATH_DELAY;
     DOPADOP <= dopa_dly after SYNC_PATH_DELAY;
     DOBDO <= dob_dly after SYNC_PATH_DELAY;
     DOPBDOP <= dopb_dly after SYNC_PATH_DELAY;
     DBITERR <= dbiterr_dly after SYNC_PATH_DELAY;
     SBITERR <= sbiterr_dly after SYNC_PATH_DELAY;
     ECCPARITY <= eccparity_dly after SYNC_PATH_DELAY;
     RDADDRECC <= rdaddrecc_dly after SYNC_PATH_DELAY;
     
   end process prcs_output_wtiming;

end RAMB36E1_V;
