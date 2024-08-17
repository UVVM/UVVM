-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  16K-Bit Data and 2K-Bit Parity Dual Port Block RAM
-- /___/   /\     Filename : RAMB16_S9_S36.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:56 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    01/23/07 - Fixed invalid address of port B. (CR 430253).
-- End Revision
  
----- CELL ramb16_s9_s36 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;

library STD;
use STD.TEXTIO.all;

library UNISIM;
use UNISIM.VPKG.all;

entity RAMB16_S9_S36 is
  generic (
    TimingChecksOn : boolean := false;
    Xon            : boolean := false;
    MsgOn          : boolean := false;

    tipd_ADDRA : VitalDelayArrayType01(10 downto 0)  := (others => (0 ps, 0 ps));
    tipd_CLKA  : VitalDelayType01                   := (0 ps, 0 ps);
    tipd_DIA   : VitalDelayArrayType01(7 downto 0) := (others => (0 ps, 0 ps));
    tipd_DIPA  : VitalDelayArrayType01(0 downto 0)  := (others => (0 ps, 0 ps));
    tipd_ENA   : VitalDelayType01                   := (0 ps, 0 ps);
    tipd_SSRA  : VitalDelayType01                   := (0 ps, 0 ps);
    tipd_WEA   : VitalDelayType01                   := (0 ps, 0 ps);

    tipd_ADDRB : VitalDelayArrayType01(8 downto 0)  := (others => (0 ps, 0 ps));
    tipd_CLKB  : VitalDelayType01                   := (0 ps, 0 ps);
    tipd_DIB   : VitalDelayArrayType01(31 downto 0) := (others => (0 ps, 0 ps));
    tipd_DIPB  : VitalDelayArrayType01(3 downto 0)  := (others => (0 ps, 0 ps));
    tipd_ENB   : VitalDelayType01                   := (0 ps, 0 ps);
    tipd_WEB   : VitalDelayType01                   := (0 ps, 0 ps);
    tipd_SSRB  : VitalDelayType01                   := (0 ps, 0 ps);

    tpd_CLKA_DOA  : VitalDelayArrayType01(7 downto 0) := (others => (100 ps, 100 ps));
    tpd_CLKA_DOPA : VitalDelayArrayType01(0 downto 0)  := (others => (100 ps, 100 ps));
    tpd_CLKB_DOB  : VitalDelayArrayType01(31 downto 0) := (others => (100 ps, 100 ps));
    tpd_CLKB_DOPB : VitalDelayArrayType01(3 downto 0)  := (others => (100 ps, 100 ps));

    tsetup_ADDRA_CLKA_negedge_posedge : VitalDelayArrayType(10 downto 0)  := (others => 0 ps);
    tsetup_ADDRA_CLKA_posedge_posedge : VitalDelayArrayType(10 downto 0)  := (others => 0 ps);
    tsetup_DIA_CLKA_negedge_posedge   : VitalDelayArrayType(7 downto 0) := (others => 0 ps);
    tsetup_DIA_CLKA_posedge_posedge   : VitalDelayArrayType(7 downto 0) := (others => 0 ps);
    tsetup_DIPA_CLKA_negedge_posedge  : VitalDelayArrayType(0 downto 0)  := (others => 0 ps);
    tsetup_DIPA_CLKA_posedge_posedge  : VitalDelayArrayType(0 downto 0)  := (others => 0 ps);
    tsetup_ENA_CLKA_negedge_posedge   : VitalDelayType                   := 0 ps;
    tsetup_ENA_CLKA_posedge_posedge   : VitalDelayType                   := 0 ps;
    tsetup_SSRA_CLKA_negedge_posedge  : VitalDelayType                   := 0 ps;
    tsetup_SSRA_CLKA_posedge_posedge  : VitalDelayType                   := 0 ps;
    tsetup_WEA_CLKA_negedge_posedge   : VitalDelayType                   := 0 ps;
    tsetup_WEA_CLKA_posedge_posedge   : VitalDelayType                   := 0 ps;

    tsetup_ADDRB_CLKB_negedge_posedge : VitalDelayArrayType(8 downto 0)  := (others => 0 ps);
    tsetup_ADDRB_CLKB_posedge_posedge : VitalDelayArrayType(8 downto 0)  := (others => 0 ps);
    tsetup_DIB_CLKB_negedge_posedge   : VitalDelayArrayType(31 downto 0) := (others => 0 ps);
    tsetup_DIB_CLKB_posedge_posedge   : VitalDelayArrayType(31 downto 0) := (others => 0 ps);
    tsetup_DIPB_CLKB_negedge_posedge  : VitalDelayArrayType(3 downto 0)  := (others => 0 ps);
    tsetup_DIPB_CLKB_posedge_posedge  : VitalDelayArrayType(3 downto 0)  := (others => 0 ps);
    tsetup_ENB_CLKB_negedge_posedge   : VitalDelayType                   := 0 ps;
    tsetup_ENB_CLKB_posedge_posedge   : VitalDelayType                   := 0 ps;
    tsetup_SSRB_CLKB_negedge_posedge  : VitalDelayType                   := 0 ps;
    tsetup_SSRB_CLKB_posedge_posedge  : VitalDelayType                   := 0 ps;
    tsetup_WEB_CLKB_negedge_posedge   : VitalDelayType                   := 0 ps;
    tsetup_WEB_CLKB_posedge_posedge   : VitalDelayType                   := 0 ps;

    thold_ADDRA_CLKA_negedge_posedge : VitalDelayArrayType(10 downto 0)  := (others => 0 ps);
    thold_ADDRA_CLKA_posedge_posedge : VitalDelayArrayType(10 downto 0)  := (others => 0 ps);
    thold_DIA_CLKA_negedge_posedge   : VitalDelayArrayType(7 downto 0) := (others => 0 ps);
    thold_DIA_CLKA_posedge_posedge   : VitalDelayArrayType(7 downto 0) := (others => 0 ps);
    thold_DIPA_CLKA_negedge_posedge  : VitalDelayArrayType(0 downto 0)  := (others => 0 ps);
    thold_DIPA_CLKA_posedge_posedge  : VitalDelayArrayType(0 downto 0)  := (others => 0 ps);
    thold_ENA_CLKA_negedge_posedge   : VitalDelayType                   := 0 ps;
    thold_ENA_CLKA_posedge_posedge   : VitalDelayType                   := 0 ps;
    thold_SSRA_CLKA_negedge_posedge  : VitalDelayType                   := 0 ps;
    thold_SSRA_CLKA_posedge_posedge  : VitalDelayType                   := 0 ps;
    thold_WEA_CLKA_negedge_posedge   : VitalDelayType                   := 0 ps;
    thold_WEA_CLKA_posedge_posedge   : VitalDelayType                   := 0 ps;

    thold_ADDRB_CLKB_negedge_posedge : VitalDelayArrayType(8 downto 0)  := (others => 0 ps);
    thold_ADDRB_CLKB_posedge_posedge : VitalDelayArrayType(8 downto 0)  := (others => 0 ps);
    thold_DIB_CLKB_negedge_posedge   : VitalDelayArrayType(31 downto 0) := (others => 0 ps);
    thold_DIB_CLKB_posedge_posedge   : VitalDelayArrayType(31 downto 0) := (others => 0 ps);
    thold_DIPB_CLKB_negedge_posedge  : VitalDelayArrayType(3 downto 0)  := (others => 0 ps);
    thold_DIPB_CLKB_posedge_posedge  : VitalDelayArrayType(3 downto 0)  := (others => 0 ps);
    thold_ENB_CLKB_negedge_posedge   : VitalDelayType                   := 0 ps;
    thold_ENB_CLKB_posedge_posedge   : VitalDelayType                   := 0 ps;
    thold_SSRB_CLKB_negedge_posedge  : VitalDelayType                   := 0 ps;
    thold_SSRB_CLKB_posedge_posedge  : VitalDelayType                   := 0 ps;
    thold_WEB_CLKB_negedge_posedge   : VitalDelayType                   := 0 ps;
    thold_WEB_CLKB_posedge_posedge   : VitalDelayType                   := 0 ps;

    tpw_CLKA_negedge : VitalDelayType := 0 ps;
    tpw_CLKA_posedge : VitalDelayType := 0 ps;
    tpw_CLKB_negedge : VitalDelayType := 0 ps;
    tpw_CLKB_posedge : VitalDelayType := 0 ps;

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

    INITP_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";

    INIT_A : bit_vector := X"000";
    INIT_B : bit_vector := X"000000000";


    SIM_COLLISION_CHECK : string := "ALL";

    SRVAL_A : bit_vector := X"000";
    SRVAL_B : bit_vector := X"000000000";

    WRITE_MODE_A : string := "WRITE_FIRST";
    WRITE_MODE_B : string := "WRITE_FIRST"
    );

  port(
    DOA  : out std_logic_vector(7 downto 0);
    DOB  : out std_logic_vector(31 downto 0);
    DOPA : out std_logic_vector(0 downto 0);
    DOPB : out std_logic_vector(3 downto 0);

    ADDRA : in std_logic_vector(10 downto 0);
    ADDRB : in std_logic_vector(8 downto 0);
    CLKA  : in std_ulogic;
    CLKB  : in std_ulogic;
    DIA   : in std_logic_vector(7 downto 0);
    DIB   : in std_logic_vector(31 downto 0);
    DIPA  : in std_logic_vector(0 downto 0);
    DIPB  : in std_logic_vector(3 downto 0);
    ENA   : in std_ulogic;
    ENB   : in std_ulogic;
    SSRA  : in std_ulogic;
    SSRB  : in std_ulogic;
    WEA   : in std_ulogic;
    WEB   : in std_ulogic
    );

  attribute VITAL_LEVEL0 of
    RAMB16_S9_S36 : entity is true;
end ramb16_s9_s36;

architecture RAMB16_S9_S36_V of RAMB16_S9_S36 is
  attribute VITAL_LEVEL0 of
    RAMB16_S9_S36_V : architecture is true;

  signal ADDRA_ipd : std_logic_vector(10 downto 0)  := (others => 'X');
  signal CLKA_ipd  : std_ulogic                    := 'X';
  signal DIA_ipd   : std_logic_vector(7 downto 0) := (others => 'X');
  signal DIPA_ipd  : std_logic_vector(0 downto 0)  := (others => 'X');
  signal ENA_ipd   : std_ulogic                    := 'X';
  signal SSRA_ipd  : std_ulogic                    := 'X';
  signal WEA_ipd   : std_ulogic                    := 'X';

  signal ADDRB_ipd : std_logic_vector(8 downto 0)  := (others => 'X');
  signal CLKB_ipd  : std_ulogic                    := 'X';
  signal DIB_ipd   : std_logic_vector(31 downto 0) := (others => 'X');
  signal DIPB_ipd  : std_logic_vector(3 downto 0)  := (others => 'X');
  signal ENB_ipd   : std_ulogic                    := 'X';
  signal SSRB_ipd  : std_ulogic                    := 'X';
  signal WEB_ipd   : std_ulogic                    := 'X';

  constant SETUP_ALL        : VitalDelayType := 1000 ps;
  constant SETUP_READ_FIRST : VitalDelayType := 1000 ps;
  constant length_a : integer := 2048;
  constant length_b : integer := 512;
  constant width_a : integer := 8;
  constant width_b : integer := 32;  

  constant parity_width_a : integer := 1;
  constant parity_width_b : integer := 4;  
  
  type Two_D_array_type is array ((length_b -  1) downto 0) of std_logic_vector((width_b - 1) downto 0);
  type Two_D_parity_array_type is array ((length_b - 1) downto 0) of std_logic_vector((parity_width_b -1) downto 0);

  function slv_to_two_D_array(
    slv_length : integer;
    slv_width : integer;
    SLV : in std_logic_vector
    )
    return two_D_array_type is
    variable two_D_array : two_D_array_type;
    variable intermediate : std_logic_vector((slv_width - 1) downto 0);
  begin
    for i in 0 to (slv_length - 1)loop
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
begin
  WireDelay     : block
  begin
    ADDRA_DELAY : for i in 10 downto 0 generate
      VitalWireDelay (ADDRA_ipd(i), ADDRA(i), tipd_ADDRA(i));
    end generate ADDRA_DELAY;
    VitalWireDelay (CLKA_ipd, CLKA, tipd_CLKA);
    DIA_DELAY   : for i in 7 downto 0 generate
      VitalWireDelay (DIA_ipd(i), DIA(i), tipd_DIA(i));
    end generate DIA_DELAY;
    DIPA_DELAY  : for i in 0 downto 0 generate
      VitalWireDelay (DIPA_ipd(i), DIPA(i), tipd_DIPA(i));
    end generate DIPA_DELAY;
    VitalWireDelay (ENA_ipd, ENA, tipd_ENA);
    VitalWireDelay (SSRA_ipd, SSRA, tipd_SSRA);
    VitalWireDelay (WEA_ipd, WEA, tipd_WEA);

    ADDRB_DELAY : for i in 8 downto 0 generate
      VitalWireDelay (ADDRB_ipd(i), ADDRB(i), tipd_ADDRB(i));
    end generate ADDRB_DELAY;
    VitalWireDelay (CLKB_ipd, CLKB, tipd_CLKB);
    DIB_DELAY   : for i in 31 downto 0 generate
      VitalWireDelay (DIB_ipd(i), DIB(i), tipd_DIB(i));
    end generate DIB_DELAY;
    DIPB_DELAY  : for i in 3 downto 0 generate
      VitalWireDelay (DIPB_ipd(i), DIPB(i), tipd_DIPB(i));
    end generate DIPB_DELAY;
    VitalWireDelay (ENB_ipd, ENB, tipd_ENB);
    VitalWireDelay (SSRB_ipd, SSRB, tipd_SSRB);
    VitalWireDelay (WEB_ipd, WEB, tipd_WEB);
  end block;

  VITALBehavior                        : process
    variable Tviol_ADDRA0_CLKA_posedge : std_ulogic := '0';
    variable Tviol_ADDRA1_CLKA_posedge : std_ulogic := '0';
    variable Tviol_ADDRA2_CLKA_posedge : std_ulogic := '0';
    variable Tviol_ADDRA3_CLKA_posedge : std_ulogic := '0';
    variable Tviol_ADDRA4_CLKA_posedge : std_ulogic := '0';
    variable Tviol_ADDRA5_CLKA_posedge : std_ulogic := '0';
    variable Tviol_ADDRA6_CLKA_posedge : std_ulogic := '0';
    variable Tviol_ADDRA7_CLKA_posedge : std_ulogic := '0';
    variable Tviol_ADDRA8_CLKA_posedge : std_ulogic := '0';
    variable Tviol_ADDRA9_CLKA_posedge : std_ulogic := '0';
    variable Tviol_ADDRA10_CLKA_posedge : std_ulogic := '0';
    variable Tviol_DIA0_CLKA_posedge   : std_ulogic := '0';
    variable Tviol_DIA1_CLKA_posedge   : std_ulogic := '0';
    variable Tviol_DIA2_CLKA_posedge   : std_ulogic := '0';
    variable Tviol_DIA3_CLKA_posedge   : std_ulogic := '0';
    variable Tviol_DIA4_CLKA_posedge   : std_ulogic := '0';
    variable Tviol_DIA5_CLKA_posedge   : std_ulogic := '0';
    variable Tviol_DIA6_CLKA_posedge   : std_ulogic := '0';
    variable Tviol_DIA7_CLKA_posedge   : std_ulogic := '0';
    variable Tviol_DIPA0_CLKA_posedge  : std_ulogic := '0';
    variable Tviol_ENA_CLKA_posedge    : std_ulogic := '0';
    variable Tviol_SSRA_CLKA_posedge   : std_ulogic := '0';
    variable Tviol_WEA_CLKA_posedge    : std_ulogic := '0';

    variable Tviol_ADDRB0_CLKB_posedge : std_ulogic := '0';
    variable Tviol_ADDRB1_CLKB_posedge : std_ulogic := '0';
    variable Tviol_ADDRB2_CLKB_posedge : std_ulogic := '0';
    variable Tviol_ADDRB3_CLKB_posedge : std_ulogic := '0';
    variable Tviol_ADDRB4_CLKB_posedge : std_ulogic := '0';
    variable Tviol_ADDRB5_CLKB_posedge : std_ulogic := '0';
    variable Tviol_ADDRB6_CLKB_posedge : std_ulogic := '0';
    variable Tviol_ADDRB7_CLKB_posedge : std_ulogic := '0';
    variable Tviol_ADDRB8_CLKB_posedge : std_ulogic := '0';
    variable Tviol_DIB0_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB1_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB2_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB3_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB4_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB5_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB6_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB7_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB8_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB9_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB10_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB11_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB12_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB13_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB14_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB15_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB16_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB17_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB18_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB19_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB20_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB21_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB22_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB23_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB24_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB25_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB26_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB27_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB28_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB29_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB30_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIB31_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_DIPB0_CLKB_posedge  : std_ulogic := '0';
    variable Tviol_DIPB1_CLKB_posedge  : std_ulogic := '0';
    variable Tviol_DIPB2_CLKB_posedge  : std_ulogic := '0';
    variable Tviol_DIPB3_CLKB_posedge  : std_ulogic := '0';
    variable Tviol_ENB_CLKB_posedge    : std_ulogic := '0';
    variable Tviol_SSRB_CLKB_posedge   : std_ulogic := '0';
    variable Tviol_WEB_CLKB_posedge    : std_ulogic := '0';

    variable PViol_CLKA                 : std_ulogic := '0';
    variable PViol_CLKB                 : std_ulogic := '0';
    variable Tviol_CLKA_CLKB_all        : std_ulogic := '0';
    variable Tviol_CLKA_CLKB_read_first : std_ulogic := '0';
    variable Tviol_CLKB_CLKA_all        : std_ulogic := '0';
    variable Tviol_CLKB_CLKA_read_first : std_ulogic := '0';

    variable Tmkr_ADDRA0_CLKA_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ADDRA1_CLKA_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ADDRA2_CLKA_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ADDRA3_CLKA_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ADDRA4_CLKA_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ADDRA5_CLKA_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ADDRA6_CLKA_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ADDRA7_CLKA_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ADDRA8_CLKA_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ADDRA9_CLKA_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ADDRA10_CLKA_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIA0_CLKA_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIA1_CLKA_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIA2_CLKA_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIA3_CLKA_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIA4_CLKA_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIA5_CLKA_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIA6_CLKA_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIA7_CLKA_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIPA0_CLKA_posedge  : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ENA_CLKA_posedge    : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_SSRA_CLKA_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_WEA_CLKA_posedge    : VitalTimingDataType := VitalTimingDataInit;

    variable Tmkr_ADDRB0_CLKB_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ADDRB1_CLKB_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ADDRB2_CLKB_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ADDRB3_CLKB_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ADDRB4_CLKB_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ADDRB5_CLKB_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ADDRB6_CLKB_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ADDRB7_CLKB_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ADDRB8_CLKB_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB0_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB1_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB2_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB3_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB4_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB5_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB6_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB7_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB8_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB9_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB10_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB11_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB12_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB13_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB14_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB15_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB16_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB17_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB18_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB19_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB20_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB21_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB22_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB23_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB24_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB25_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB26_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB27_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB28_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB29_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB30_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIB31_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIPB0_CLKB_posedge  : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIPB1_CLKB_posedge  : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIPB2_CLKB_posedge  : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_DIPB3_CLKB_posedge  : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_ENB_CLKB_posedge    : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_SSRB_CLKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_WEB_CLKB_posedge    : VitalTimingDataType := VitalTimingDataInit;

    variable PInfo_CLKA                : VitalPeriodDataType := VitalPeriodDataInit;
    variable PInfo_CLKB                : VitalPeriodDataType := VitalPeriodDataInit;
    variable Tmkr_CLKA_CLKB_all        : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_CLKA_CLKB_read_first : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_CLKB_CLKA_all        : VitalTimingDataType := VitalTimingDataInit;
    variable Tmkr_CLKB_CLKA_read_first : VitalTimingDataType := VitalTimingDataInit;

    variable DOA_GlitchData0  : VitalGlitchDataType;
    variable DOA_GlitchData1  : VitalGlitchDataType;
    variable DOA_GlitchData2  : VitalGlitchDataType;
    variable DOA_GlitchData3  : VitalGlitchDataType;
    variable DOA_GlitchData4  : VitalGlitchDataType;
    variable DOA_GlitchData5  : VitalGlitchDataType;
    variable DOA_GlitchData6  : VitalGlitchDataType;
    variable DOA_GlitchData7  : VitalGlitchDataType;
    variable DOPA_GlitchData0 : VitalGlitchDataType;

    variable DOB_GlitchData0  : VitalGlitchDataType;
    variable DOB_GlitchData1  : VitalGlitchDataType;
    variable DOB_GlitchData2  : VitalGlitchDataType;
    variable DOB_GlitchData3  : VitalGlitchDataType;
    variable DOB_GlitchData4  : VitalGlitchDataType;
    variable DOB_GlitchData5  : VitalGlitchDataType;
    variable DOB_GlitchData6  : VitalGlitchDataType;
    variable DOB_GlitchData7  : VitalGlitchDataType;
    variable DOB_GlitchData8  : VitalGlitchDataType;
    variable DOB_GlitchData9  : VitalGlitchDataType;
    variable DOB_GlitchData10  : VitalGlitchDataType;
    variable DOB_GlitchData11  : VitalGlitchDataType;
    variable DOB_GlitchData12  : VitalGlitchDataType;
    variable DOB_GlitchData13  : VitalGlitchDataType;
    variable DOB_GlitchData14  : VitalGlitchDataType;
    variable DOB_GlitchData15  : VitalGlitchDataType;
    variable DOB_GlitchData16  : VitalGlitchDataType;
    variable DOB_GlitchData17  : VitalGlitchDataType;
    variable DOB_GlitchData18  : VitalGlitchDataType;
    variable DOB_GlitchData19  : VitalGlitchDataType;
    variable DOB_GlitchData20  : VitalGlitchDataType;
    variable DOB_GlitchData21  : VitalGlitchDataType;
    variable DOB_GlitchData22  : VitalGlitchDataType;
    variable DOB_GlitchData23  : VitalGlitchDataType;
    variable DOB_GlitchData24  : VitalGlitchDataType;
    variable DOB_GlitchData25  : VitalGlitchDataType;
    variable DOB_GlitchData26  : VitalGlitchDataType;
    variable DOB_GlitchData27  : VitalGlitchDataType;
    variable DOB_GlitchData28  : VitalGlitchDataType;
    variable DOB_GlitchData29  : VitalGlitchDataType;
    variable DOB_GlitchData30  : VitalGlitchDataType;
    variable DOB_GlitchData31  : VitalGlitchDataType;
    variable DOPB_GlitchData0 : VitalGlitchDataType;
    variable DOPB_GlitchData1 : VitalGlitchDataType;
    variable DOPB_GlitchData2 : VitalGlitchDataType;
    variable DOPB_GlitchData3 : VitalGlitchDataType;

    variable mem_slv : std_logic_vector(16383 downto 0) := To_StdLogicVector(INIT_3F) &
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

    variable memp_slv : std_logic_vector(2047 downto 0) := To_StdLogicVector(INITP_07) &
                                                       To_StdLogicVector(INITP_06) &
                                                       To_StdLogicVector(INITP_05) &
                                                       To_StdLogicVector(INITP_04) &
                                                       To_StdLogicVector(INITP_03) &
                                                       To_StdLogicVector(INITP_02) &
                                                       To_StdLogicVector(INITP_01) &
                                                       To_StdLogicVector(INITP_00);

    variable mem : Two_D_array_type := slv_to_two_D_array(length_b, width_b, mem_slv);
    variable memp : Two_D_parity_array_type := slv_to_two_D_parity_array(length_b, parity_width_b, memp_slv);        


    variable ADDRESS_A         : integer;
    variable ADDRESS_B         : integer;
    variable DOA_OV_LSB        : integer;
    variable DOA_OV_MSB        : integer;
    variable DOB_OV_LSB        : integer;
    variable DOB_OV_MSB        : integer;
    variable DOPA_OV_LSB       : integer := 0;
    variable DOPA_OV_MSB       : integer := 0;
    variable DOPB_OV_LSB       : integer := 0;
    variable DOPB_OV_MSB       : integer := 3;
    variable FIRST_TIME        : boolean                                     := true;
    variable HAS_OVERLAP       : boolean                                     := false;
    variable HAS_OVERLAP_P     : boolean                                     := false;
    variable INIT_A_val        : std_logic_vector(INIT_A'length-1 downto 0)  := (others => 'X');
    variable INIT_B_val        : std_logic_vector(INIT_B'length-1 downto 0)  := (others => 'X');
    variable INI_A             : std_logic_vector (8 downto 0)              := "000000000";
    variable INI_A_UNBOUND     : std_logic_vector (INIT_A'length-1 downto 0);
    variable INI_B             : std_logic_vector (35 downto 0)              := "000000000000000000000000000000000000";
    variable INI_B_UNBOUND     : std_logic_vector (INIT_B'length-1 downto 0);
    variable IS_VALID          : boolean                                     := true;
    variable OLPP_LSB          : integer;
    variable OLPP_MSB          : integer;
    variable OLP_LSB           : integer;
    variable OLP_MSB           : integer;
    variable SRVAL_A_val       : std_logic_vector(SRVAL_A'length-1 downto 0) := (others => 'X');
    variable SRVAL_B_val       : std_logic_vector(SRVAL_B'length-1 downto 0) := (others => 'X');
    variable SRVA_A            : std_logic_vector (8 downto 0)              := "000000000";
    variable SRVA_A_UNBOUND    : std_logic_vector (SRVAL_A'length-1 downto 0);
    variable SRVA_B            : std_logic_vector (35 downto 0)              := "000000000000000000000000000000000000";
    variable SRVA_B_UNBOUND    : std_logic_vector (SRVAL_B'length-1 downto 0);
    variable TEMPLINE          : line;
    variable VALID_ADDRA       : boolean                                     := false;
    variable VALID_ADDRB       : boolean                                     := false;
    variable WR_A_LATER        : boolean                                     := false;
    variable WR_B_LATER        : boolean                                     := false;
    variable ViolationA        : std_ulogic                                  := '0';
    variable ViolationB        : std_ulogic                                  := '0';
    variable ViolationCLKAB    : std_ulogic                                  := '0';
    variable ViolationCLKAB_S0 : boolean                                     := false;
    variable Violation_S1      : boolean                                     := false;
    variable Violation_S3      : boolean                                     := false;
    variable wr_mode_a         : integer                                     := 0;
    variable wr_mode_b         : integer                                     := 0;

    variable DOA_zd  : std_logic_vector(7 downto 0) := INI_A(7 downto 0);
    variable DOB_zd  : std_logic_vector(31 downto 0) := INI_B(31 downto 0);
    variable DOPA_zd : std_logic_vector(0 downto 0)  := INI_A(8 downto 8);
    variable DOPB_zd : std_logic_vector(3 downto 0)  := INI_B(35 downto 32);

    variable ADDRA_ipd_sampled : std_logic_vector(10 downto 0) := (others => 'X');
    variable ADDRB_ipd_sampled : std_logic_vector(8 downto 0) := (others => 'X');
    variable ENA_ipd_sampled   : std_ulogic                    := 'X';
    variable ENB_ipd_sampled   : std_ulogic                    := 'X';
    variable SSRA_ipd_sampled  : std_ulogic                    := 'X';
    variable SSRB_ipd_sampled  : std_ulogic                    := 'X';
    variable WEA_ipd_sampled   : std_ulogic                    := 'X';
    variable WEB_ipd_sampled   : std_ulogic                    := 'X';
    variable full_4bit_words   : integer                       := 0;
    variable needed_bits       : integer                       := 0;
    variable collision_type : integer := 3;

  begin
    if (FIRST_TIME) then
      if ((SIM_COLLISION_CHECK = "none") or (SIM_COLLISION_CHECK = "NONE"))  then
        collision_type := 0;
      elsif ((SIM_COLLISION_CHECK = "warning_only") or (SIM_COLLISION_CHECK = "WARNING_ONLY"))  then
        collision_type := 1;
      elsif ((SIM_COLLISION_CHECK = "generate_x_only") or (SIM_COLLISION_CHECK = "GENERATE_X_ONLY"))  then
        collision_type := 2;
      elsif ((SIM_COLLISION_CHECK = "all") or (SIM_COLLISION_CHECK = "ALL"))  then        
        collision_type := 3;
      else
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "SIM_COLLISION_CHECK",
           EntityName => "RAMB16_S9_S36",
           GenericValue => SIM_COLLISION_CHECK,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are ALL, NONE, WARNING_ONLY or GENERATE_X_ONLY",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
      end if;
      if (INIT_A'length > 9) then
        INI_A_UNBOUND(INIT_A'length-1 downto 0) := To_StdLogicVector(INIT_A);
        INI_A(8 downto 0)                      := INI_A_UNBOUND(8 downto 0);

        for I in INI_A_UNBOUND'high downto 9 loop
          if (INI_A_UNBOUND(I) /= '0') then
            IS_VALID := false;
          end if;
        end loop;

        if (IS_VALID = true) then
          full_4bit_words :=  9 / 4;
          needed_bits := (full_4bit_words +1) * 4;
          if(INIT_A'length /= needed_bits) then
            write(TEMPLINE, string'("Length of INIT_A passed is greater than expected one."));
            write(TEMPLINE, LF);
            write(TEMPLINE, string'("Ignoring the extra leading bits as those bits are all zeros."));
            write(TEMPLINE, LF);
            assert false report
              TEMPLINE.all
              severity warning;
            write(TEMPLINE, LF);
            DEALLOCATE (TEMPLINE);
          end if;

        else
          GenericValueCheckMessage
            (HeaderMsg            => " Attribute Syntax Warning ",
             GenericName          => " INIT_A ",
             EntityName           => "/RAMB16_S9_S36",
             GenericValue         => INIT_A'length,
             Unit                 => " bit value ",
             ExpectedValueMsg     => " The expected length for this attribute is ",
             ExpectedGenericValue => 9,
             TailMsg              => "",
             MsgSeverity          => warning
             );
        end if;

      elsif (INIT_A'length < 9) then
        INI_A(INIT_A'length-1 downto 0) := To_StdLogicVector(INIT_A);
        GenericValueCheckMessage
          (HeaderMsg            => " Attribute Syntax Warning ",
           GenericName          => " INIT_A ",
           EntityName           => "/RAMB16_S9_S36",
           GenericValue         => INIT_A'length,
           Unit                 => " bit value ",
           ExpectedValueMsg     => " The expected length for this attribute is ",
           ExpectedGenericValue => 9,
           TailMsg              => " Remaining MSB's of INIT_A are padded with 0's ",
           MsgSeverity          => warning
           );

      elsif (INIT_A'length = 9) then
        INI_A(INIT_A'length-1 downto 0) := To_StdLogicVector(INIT_A);
      end if;

      if (INIT_B'length > 36) then
        IS_VALID := true;
        INI_B_UNBOUND(INIT_B'length-1 downto 0) := To_StdLogicVector(INIT_B);
        INI_B(35 downto 0)                      := INI_B_UNBOUND(35 downto 0);

        for I in INI_B_UNBOUND'high downto 36 loop
          if (INI_B_UNBOUND(I) /= '0') then
            IS_VALID := false;
          end if;
        end loop;

        if (IS_VALID = true) then
          full_4bit_words :=  36 / 4;
          needed_bits := (full_4bit_words +1) * 4;
          if(INIT_B'length /= needed_bits) then
            write(TEMPLINE, string'("Length of INIT_B passed is greater than expected one."));
            write(TEMPLINE, LF);
            write(TEMPLINE, string'("Ignoring the extra leading bits as those bits are all zeros."));
            write(TEMPLINE, LF);
            assert false report
              TEMPLINE.all
              severity warning;
              write(TEMPLINE, LF);
            DEALLOCATE (TEMPLINE);
          end if;

        else
          GenericValueCheckMessage
            (HeaderMsg            => " Attribute Syntax Warning ",
             GenericName          => " INIT_B ",
             EntityName           => "/RAMB16_S9_S36",
             GenericValue         => INIT_B'length,
             Unit                 => " bit value ",
             ExpectedValueMsg     => " The expected length for this attribute is ",
             ExpectedGenericValue => 36,
             TailMsg              => "",
             MsgSeverity          => warning
             );
        end if;

      elsif (INIT_B'length < 36) then
        INI_B(INIT_B'length-1 downto 0) := To_StdLogicVector(INIT_B);
        GenericValueCheckMessage
          (HeaderMsg            => " Attribute Syntax Warning ",
           GenericName          => " INIT_B ",
           EntityName           => "/RAMB16_S9_S36",
           GenericValue         => INIT_B'length,
           Unit                 => " bit value ",
           ExpectedValueMsg     => " The expected length for this attribute is ",
           ExpectedGenericValue => 36,
           TailMsg              => " Remaining MSB's of INIT_B are padded with 0's ",
           MsgSeverity          => warning
           );

      elsif (INIT_B'length = 36) then
        INI_B(INIT_B'length-1 downto 0) := To_StdLogicVector(INIT_B);
      end if;

      if (SRVAL_A'length > 9) then
        IS_VALID := true;
        SRVA_A_UNBOUND(SRVAL_A'length-1 downto 0) := To_StdLogicVector(SRVAL_A);
        SRVA_A(8 downto 0)                       := SRVA_A_UNBOUND(8 downto 0);

        for I in SRVA_A_UNBOUND'high downto 9 loop
          if (SRVA_A_UNBOUND(I) /= '0') then
            IS_VALID := false;
          end if;
        end loop;

        if (IS_VALID = true) then
          full_4bit_words :=  9 / 4;
          needed_bits := (full_4bit_words +1) * 4;
          if(SRVAL_A'length /= needed_bits) then
            write(TEMPLINE, string'("Length of SRVAL_A passed is greater than expected one."));
            write(TEMPLINE, LF);
            write(TEMPLINE, string'("Ignoring the extra leading bits as those bits are all zeros."));
            write(TEMPLINE, LF);
            assert false report
              TEMPLINE.all
              severity warning;
            write(TEMPLINE, LF);
            DEALLOCATE (TEMPLINE);
          end if;

        else
          GenericValueCheckMessage
            (HeaderMsg            => " Attribute Syntax Warning ",
             GenericName          => " SRVAL_A ",
             EntityName           => "/RAMB16_S9_S36",
             GenericValue         => SRVAL_A'length,
             Unit                 => " bit value ",
             ExpectedValueMsg     => " The expected length for this attribute is ",
             ExpectedGenericValue => 9,
             TailMsg              => "",
             MsgSeverity          => warning
             );
        end if;

      elsif (SRVAL_A'length < 9) then
        SRVA_A(SRVAL_A'length-1 downto 0) := To_StdLogicVector(SRVAL_A);
        GenericValueCheckMessage
          (HeaderMsg            => " Attribute Syntax Warning ",
           GenericName          => " SRVAL_A ",
           EntityName           => "/RAMB16_S9_S36",
           GenericValue         => SRVAL_A'length,
           Unit                 => " bit value ",
           ExpectedValueMsg     => " The expected length for this attribute is ",
           ExpectedGenericValue => 9,
           TailMsg              => " Remaining MSB's of SRVAL_A are padded with 0's ",
           MsgSeverity          => warning
           );

      elsif (SRVAL_A'length = 9) then
        SRVA_A(SRVAL_A'length-1 downto 0) := To_StdLogicVector(SRVAL_A);
      end if;

      if (SRVAL_B'length > 36) then
        IS_VALID := true;
        SRVA_B_UNBOUND(SRVAL_B'length-1 downto 0) := To_StdLogicVector(SRVAL_B);
        SRVA_B(35 downto 0)                       := SRVA_B_UNBOUND(35 downto 0);

        for I in SRVA_B_UNBOUND'high downto 36 loop
          if (SRVA_B_UNBOUND(I) /= '0') then
            IS_VALID := false;
          end if;
        end loop;

        if (IS_VALID = true) then
          full_4bit_words :=  36 / 4;
          needed_bits := (full_4bit_words +1) * 4;
          if(SRVAL_B'length /= needed_bits) then
            write(TEMPLINE, string'("Length of SRVAL_B passed is greater than expected one."));
            write(TEMPLINE, LF);
            write(TEMPLINE, string'("Ignoring the extra leading bits as those bits are all zeros."));
            write(TEMPLINE, LF);
            assert false report
              TEMPLINE.all
              severity warning;
            write(TEMPLINE, LF);
            DEALLOCATE (TEMPLINE);
          end if;

        else
          GenericValueCheckMessage
            (HeaderMsg            => " Attribute Syntax Warning ",
             GenericName          => " SRVAL_B ",
             EntityName           => "/RAMB16_S9_S36",
             GenericValue         => SRVAL_B'length,
             Unit                 => " bit value ",
             ExpectedValueMsg     => " The expected length for this attribute is ",
             ExpectedGenericValue => 36,
             TailMsg              => "",
             MsgSeverity          => warning
             );
        end if;

      elsif (SRVAL_B'length < 36) then
        SRVA_B(SRVAL_B'length-1 downto 0) := To_StdLogicVector(SRVAL_B);
        GenericValueCheckMessage
          (HeaderMsg            => " Attribute Syntax Warning ",
           GenericName          => " SRVAL_B ",
           EntityName           => "/RAMB16_S9_S36",
           GenericValue         => SRVAL_B'length,
           Unit                 => " bit value ",
           ExpectedValueMsg     => " The expected length for this attribute is ",
           ExpectedGenericValue => 36,
           TailMsg              => " Remaining MSB's of SRVAL_B are padded with 0's ",
           MsgSeverity          => warning
           );

      elsif (SRVAL_B'length = 36) then
        SRVA_B(SRVAL_B'length-1 downto 0) := To_StdLogicVector(SRVAL_B);
      end if;

      DOA_zd(7 downto 0) := INI_A(7 downto 0);
      DOB_zd(31 downto 0) := INI_B(31 downto 0);
      DOPA_zd(0 downto 0) := INI_A(8 downto 8);
      DOPB_zd(3 downto 0) := INI_B(35 downto 32);
      DOA  <= DOA_zd;
      DOPA <= DOPA_zd;
      DOB  <= DOB_zd;
      DOPB <= DOPB_zd;

      if ((WRITE_MODE_A = "write_first") or (WRITE_MODE_A = "WRITE_FIRST")) then
        wr_mode_a := 0;

      elsif ((WRITE_MODE_A = "read_first") or (WRITE_MODE_A = "READ_FIRST")) then
        wr_mode_a := 1;

      elsif ((WRITE_MODE_A = "no_change") or (WRITE_MODE_A = "NO_CHANGE")) then
        wr_mode_a := 2;

      else
        GenericValueCheckMessage
          (HeaderMsg            => " Attribute Syntax Warning ",
           GenericName          => " WRITE_MODE_A ",
           EntityName           => "/RAMB16_S9_S36",
           GenericValue         => WRITE_MODE_A,
           Unit                 => "",
           ExpectedValueMsg     => " The Legal values for this attribute are ",
           ExpectedGenericValue => " WRITE_FIRST, READ_FIRST or NO_CHANGE ",
           TailMsg              => "",
           MsgSeverity          => warning
           );
      end if;

      if ((WRITE_MODE_B = "write_first") or (WRITE_MODE_B = "WRITE_FIRST")) then
        wr_mode_b := 0;

      elsif ((WRITE_MODE_B = "read_first") or (WRITE_MODE_B = "READ_FIRST")) then
        wr_mode_b := 1;

      elsif ((WRITE_MODE_B = "no_change") or (WRITE_MODE_B = "NO_CHANGE")) then
        wr_mode_b := 2;

      else
        GenericValueCheckMessage
          (HeaderMsg            => " Attribute Syntax Warning ",
           GenericName          => " WRITE_MODE_B ",
           EntityName           => "/RAMB16_S9_S36",
           GenericValue         => WRITE_MODE_B,
           Unit                 => "",
           ExpectedValueMsg     => " The Legal values for this attribute are ",
           ExpectedGenericValue => " WRITE_FIRST, READ_FIRST or NO_CHANGE ",
           TailMsg              => "",
           MsgSeverity          => warning
           );
      end if;

      FIRST_TIME := false;
    end if;

    if (CLKA_ipd'event) then
      ENA_ipd_sampled   := ENA_ipd;
      SSRA_ipd_sampled  := SSRA_ipd;
      WEA_ipd_sampled   := WEA_ipd;
      ADDRA_ipd_sampled := ADDRA_ipd;
    end if;

    if (CLKB_ipd'event) then
      ENB_ipd_sampled   := ENB_ipd;
      SSRB_ipd_sampled  := SSRB_ipd;
      WEB_ipd_sampled   := WEB_ipd;
      ADDRB_ipd_sampled := ADDRB_ipd;
    end if;

    if (TimingChecksOn) then
      VitalSetupHoldCheck (
        Violation      => Tviol_ENA_CLKA_posedge,
        TimingData     => Tmkr_ENA_CLKA_posedge,
        TestSignal     => ENA_ipd,
        TestSignalName => "ENA",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ENA_CLKA_posedge_posedge,
        SetupLow       => tsetup_ENA_CLKA_negedge_posedge,
        HoldLow        => thold_ENA_CLKA_posedge_posedge,
        HoldHigh       => thold_ENA_CLKA_negedge_posedge,
        CheckEnabled   => true,
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_SSRA_CLKA_posedge,
        TimingData     => Tmkr_SSRA_CLKA_posedge,
        TestSignal     => SSRA_ipd,
        TestSignalName => "SSRA",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_SSRA_CLKA_posedge_posedge,
        SetupLow       => tsetup_SSRA_CLKA_negedge_posedge,
        HoldLow        => thold_SSRA_CLKA_posedge_posedge,
        HoldHigh       => thold_SSRA_CLKA_negedge_posedge,
        CheckEnabled   => TO_X01(ena_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_WEA_CLKA_posedge,
        TimingData     => Tmkr_WEA_CLKA_posedge,
        TestSignal     => WEA_ipd,
        TestSignalName => "WEA",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_WEA_CLKA_posedge_posedge,
        SetupLow       => tsetup_WEA_CLKA_negedge_posedge,
        HoldLow        => thold_WEA_CLKA_posedge_posedge,
        HoldHigh       => thold_WEA_CLKA_negedge_posedge,
        CheckEnabled   => TO_X01(ena_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_ADDRA0_CLKA_posedge,
        TimingData     => Tmkr_ADDRA0_CLKA_posedge,
        TestSignal     => ADDRA_ipd(0),
        TestSignalName => "ADDRA(0)",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ADDRA_CLKA_posedge_posedge(0),
        SetupLow       => tsetup_ADDRA_CLKA_negedge_posedge(0),
        HoldLow        => thold_ADDRA_CLKA_posedge_posedge(0),
        HoldHigh       => thold_ADDRA_CLKA_negedge_posedge(0),
        CheckEnabled   => TO_X01(ena_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_ADDRA1_CLKA_posedge,
        TimingData     => Tmkr_ADDRA1_CLKA_posedge,
        TestSignal     => ADDRA_ipd(1),
        TestSignalName => "ADDRA(1)",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ADDRA_CLKA_posedge_posedge(1),
        SetupLow       => tsetup_ADDRA_CLKA_negedge_posedge(1),
        HoldLow        => thold_ADDRA_CLKA_posedge_posedge(1),
        HoldHigh       => thold_ADDRA_CLKA_negedge_posedge(1),
        CheckEnabled   => TO_X01(ena_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_ADDRA2_CLKA_posedge,
        TimingData     => Tmkr_ADDRA2_CLKA_posedge,
        TestSignal     => ADDRA_ipd(2),
        TestSignalName => "ADDRA(2)",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ADDRA_CLKA_posedge_posedge(2),
        SetupLow       => tsetup_ADDRA_CLKA_negedge_posedge(2),
        HoldLow        => thold_ADDRA_CLKA_posedge_posedge(2),
        HoldHigh       => thold_ADDRA_CLKA_negedge_posedge(2),
        CheckEnabled   => TO_X01(ena_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_ADDRA3_CLKA_posedge,
        TimingData     => Tmkr_ADDRA3_CLKA_posedge,
        TestSignal     => ADDRA_ipd(3),
        TestSignalName => "ADDRA(3)",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ADDRA_CLKA_posedge_posedge(3),
        SetupLow       => tsetup_ADDRA_CLKA_negedge_posedge(3),
        HoldLow        => thold_ADDRA_CLKA_posedge_posedge(3),
        HoldHigh       => thold_ADDRA_CLKA_negedge_posedge(3),
        CheckEnabled   => TO_X01(ena_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_ADDRA4_CLKA_posedge,
        TimingData     => Tmkr_ADDRA4_CLKA_posedge,
        TestSignal     => ADDRA_ipd(4),
        TestSignalName => "ADDRA(4)",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ADDRA_CLKA_posedge_posedge(4),
        SetupLow       => tsetup_ADDRA_CLKA_negedge_posedge(4),
        HoldLow        => thold_ADDRA_CLKA_posedge_posedge(4),
        HoldHigh       => thold_ADDRA_CLKA_negedge_posedge(4),
        CheckEnabled   => TO_X01(ena_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_ADDRA5_CLKA_posedge,
        TimingData     => Tmkr_ADDRA5_CLKA_posedge,
        TestSignal     => ADDRA_ipd(5),
        TestSignalName => "ADDRA(5)",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ADDRA_CLKA_posedge_posedge(5),
        SetupLow       => tsetup_ADDRA_CLKA_negedge_posedge(5),
        HoldLow        => thold_ADDRA_CLKA_posedge_posedge(5),
        HoldHigh       => thold_ADDRA_CLKA_negedge_posedge(5),
        CheckEnabled   => TO_X01(ena_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_ADDRA6_CLKA_posedge,
        TimingData     => Tmkr_ADDRA6_CLKA_posedge,
        TestSignal     => ADDRA_ipd(6),
        TestSignalName => "ADDRA(6)",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ADDRA_CLKA_posedge_posedge(6),
        SetupLow       => tsetup_ADDRA_CLKA_negedge_posedge(6),
        HoldLow        => thold_ADDRA_CLKA_posedge_posedge(6),
        HoldHigh       => thold_ADDRA_CLKA_negedge_posedge(6),
        CheckEnabled   => TO_X01(ena_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_ADDRA7_CLKA_posedge,
        TimingData     => Tmkr_ADDRA7_CLKA_posedge,
        TestSignal     => ADDRA_ipd(7),
        TestSignalName => "ADDRA(7)",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ADDRA_CLKA_posedge_posedge(7),
        SetupLow       => tsetup_ADDRA_CLKA_negedge_posedge(7),
        HoldLow        => thold_ADDRA_CLKA_posedge_posedge(7),
        HoldHigh       => thold_ADDRA_CLKA_negedge_posedge(7),
        CheckEnabled   => TO_X01(ena_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_ADDRA8_CLKA_posedge,
        TimingData     => Tmkr_ADDRA8_CLKA_posedge,
        TestSignal     => ADDRA_ipd(8),
        TestSignalName => "ADDRA(8)",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ADDRA_CLKA_posedge_posedge(8),
        SetupLow       => tsetup_ADDRA_CLKA_negedge_posedge(8),
        HoldLow        => thold_ADDRA_CLKA_posedge_posedge(8),
        HoldHigh       => thold_ADDRA_CLKA_negedge_posedge(8),
        CheckEnabled   => TO_X01(ena_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_ADDRA9_CLKA_posedge,
        TimingData     => Tmkr_ADDRA9_CLKA_posedge,
        TestSignal     => ADDRA_ipd(9),
        TestSignalName => "ADDRA(9)",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ADDRA_CLKA_posedge_posedge(9),
        SetupLow       => tsetup_ADDRA_CLKA_negedge_posedge(9),
        HoldLow        => thold_ADDRA_CLKA_posedge_posedge(9),
        HoldHigh       => thold_ADDRA_CLKA_negedge_posedge(9),
        CheckEnabled   => TO_X01(ena_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIA0_CLKA_posedge,
        TimingData     => Tmkr_DIA0_CLKA_posedge,
        TestSignal     => DIA_ipd(0),
        TestSignalName => "DIA(0)",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIA_CLKA_posedge_posedge(0),
        SetupLow       => tsetup_DIA_CLKA_negedge_posedge(0),
        HoldLow        => thold_DIA_CLKA_posedge_posedge(0),
        HoldHigh       => thold_DIA_CLKA_negedge_posedge(0),
        CheckEnabled   => (TO_X01(ena_ipd_sampled) = '1' and TO_X01(wea_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIA1_CLKA_posedge,
        TimingData     => Tmkr_DIA1_CLKA_posedge,
        TestSignal     => DIA_ipd(1),
        TestSignalName => "DIA(1)",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIA_CLKA_posedge_posedge(1),
        SetupLow       => tsetup_DIA_CLKA_negedge_posedge(1),
        HoldLow        => thold_DIA_CLKA_posedge_posedge(1),
        HoldHigh       => thold_DIA_CLKA_negedge_posedge(1),
        CheckEnabled   => (TO_X01(ena_ipd_sampled) = '1' and TO_X01(wea_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIA2_CLKA_posedge,
        TimingData     => Tmkr_DIA2_CLKA_posedge,
        TestSignal     => DIA_ipd(2),
        TestSignalName => "DIA(2)",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIA_CLKA_posedge_posedge(2),
        SetupLow       => tsetup_DIA_CLKA_negedge_posedge(2),
        HoldLow        => thold_DIA_CLKA_posedge_posedge(2),
        HoldHigh       => thold_DIA_CLKA_negedge_posedge(2),
        CheckEnabled   => (TO_X01(ena_ipd_sampled) = '1' and TO_X01(wea_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIA3_CLKA_posedge,
        TimingData     => Tmkr_DIA3_CLKA_posedge,
        TestSignal     => DIA_ipd(3),
        TestSignalName => "DIA(3)",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIA_CLKA_posedge_posedge(3),
        SetupLow       => tsetup_DIA_CLKA_negedge_posedge(3),
        HoldLow        => thold_DIA_CLKA_posedge_posedge(3),
        HoldHigh       => thold_DIA_CLKA_negedge_posedge(3),
        CheckEnabled   => (TO_X01(ena_ipd_sampled) = '1' and TO_X01(wea_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIA4_CLKA_posedge,
        TimingData     => Tmkr_DIA4_CLKA_posedge,
        TestSignal     => DIA_ipd(4),
        TestSignalName => "DIA(4)",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIA_CLKA_posedge_posedge(4),
        SetupLow       => tsetup_DIA_CLKA_negedge_posedge(4),
        HoldLow        => thold_DIA_CLKA_posedge_posedge(4),
        HoldHigh       => thold_DIA_CLKA_negedge_posedge(4),
        CheckEnabled   => (TO_X01(ena_ipd_sampled) = '1' and TO_X01(wea_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIA5_CLKA_posedge,
        TimingData     => Tmkr_DIA5_CLKA_posedge,
        TestSignal     => DIA_ipd(5),
        TestSignalName => "DIA(5)",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIA_CLKA_posedge_posedge(5),
        SetupLow       => tsetup_DIA_CLKA_negedge_posedge(5),
        HoldLow        => thold_DIA_CLKA_posedge_posedge(5),
        HoldHigh       => thold_DIA_CLKA_negedge_posedge(5),
        CheckEnabled   => (TO_X01(ena_ipd_sampled) = '1' and TO_X01(wea_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIA6_CLKA_posedge,
        TimingData     => Tmkr_DIA6_CLKA_posedge,
        TestSignal     => DIA_ipd(6),
        TestSignalName => "DIA(6)",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIA_CLKA_posedge_posedge(6),
        SetupLow       => tsetup_DIA_CLKA_negedge_posedge(6),
        HoldLow        => thold_DIA_CLKA_posedge_posedge(6),
        HoldHigh       => thold_DIA_CLKA_negedge_posedge(6),
        CheckEnabled   => (TO_X01(ena_ipd_sampled) = '1' and TO_X01(wea_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_ENB_CLKB_posedge,
        TimingData     => Tmkr_ENB_CLKB_posedge,
        TestSignal     => ENB_ipd,
        TestSignalName => "ENB",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ENB_CLKB_posedge_posedge,
        SetupLow       => tsetup_ENB_CLKB_negedge_posedge,
        HoldLow        => thold_ENB_CLKB_posedge_posedge,
        HoldHigh       => thold_ENB_CLKB_negedge_posedge,
        CheckEnabled   => true,
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_SSRB_CLKB_posedge,
        TimingData     => Tmkr_SSRB_CLKB_posedge,
        TestSignal     => SSRB_ipd,
        TestSignalName => "SSRB",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_SSRB_CLKB_posedge_posedge,
        SetupLow       => tsetup_SSRB_CLKB_negedge_posedge,
        HoldLow        => thold_SSRB_CLKB_posedge_posedge,
        HoldHigh       => thold_SSRB_CLKB_negedge_posedge,
        CheckEnabled   => TO_X01(enb_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_WEB_CLKB_posedge,
        TimingData     => Tmkr_WEB_CLKB_posedge,
        TestSignal     => WEB_ipd,
        TestSignalName => "WEB",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_WEB_CLKB_posedge_posedge,
        SetupLow       => tsetup_WEB_CLKB_negedge_posedge,
        HoldLow        => thold_WEB_CLKB_posedge_posedge,
        HoldHigh       => thold_WEB_CLKB_negedge_posedge,
        CheckEnabled   => TO_X01(enb_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_ADDRB0_CLKB_posedge,
        TimingData     => Tmkr_ADDRB0_CLKB_posedge,
        TestSignal     => ADDRB_ipd(0),
        TestSignalName => "ADDRB(0)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ADDRB_CLKB_posedge_posedge(0),
        SetupLow       => tsetup_ADDRB_CLKB_negedge_posedge(0),
        HoldLow        => thold_ADDRB_CLKB_posedge_posedge(0),
        HoldHigh       => thold_ADDRB_CLKB_negedge_posedge(0),
        CheckEnabled   => TO_X01(enb_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/${CELL}",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_ADDRB1_CLKB_posedge,
        TimingData     => Tmkr_ADDRB1_CLKB_posedge,
        TestSignal     => ADDRB_ipd(1),
        TestSignalName => "ADDRB(1)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ADDRB_CLKB_posedge_posedge(1),
        SetupLow       => tsetup_ADDRB_CLKB_negedge_posedge(1),
        HoldLow        => thold_ADDRB_CLKB_posedge_posedge(1),
        HoldHigh       => thold_ADDRB_CLKB_negedge_posedge(1),
        CheckEnabled   => TO_X01(enb_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/${CELL}",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_ADDRB2_CLKB_posedge,
        TimingData     => Tmkr_ADDRB2_CLKB_posedge,
        TestSignal     => ADDRB_ipd(2),
        TestSignalName => "ADDRB(2)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ADDRB_CLKB_posedge_posedge(2),
        SetupLow       => tsetup_ADDRB_CLKB_negedge_posedge(2),
        HoldLow        => thold_ADDRB_CLKB_posedge_posedge(2),
        HoldHigh       => thold_ADDRB_CLKB_negedge_posedge(2),
        CheckEnabled   => TO_X01(enb_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/${CELL}",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_ADDRB3_CLKB_posedge,
        TimingData     => Tmkr_ADDRB3_CLKB_posedge,
        TestSignal     => ADDRB_ipd(3),
        TestSignalName => "ADDRB(3)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ADDRB_CLKB_posedge_posedge(3),
        SetupLow       => tsetup_ADDRB_CLKB_negedge_posedge(3),
        HoldLow        => thold_ADDRB_CLKB_posedge_posedge(3),
        HoldHigh       => thold_ADDRB_CLKB_negedge_posedge(3),
        CheckEnabled   => TO_X01(enb_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/${CELL}",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_ADDRB4_CLKB_posedge,
        TimingData     => Tmkr_ADDRB4_CLKB_posedge,
        TestSignal     => ADDRB_ipd(4),
        TestSignalName => "ADDRB(4)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ADDRB_CLKB_posedge_posedge(4),
        SetupLow       => tsetup_ADDRB_CLKB_negedge_posedge(4),
        HoldLow        => thold_ADDRB_CLKB_posedge_posedge(4),
        HoldHigh       => thold_ADDRB_CLKB_negedge_posedge(4),
        CheckEnabled   => TO_X01(enb_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/${CELL}",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_ADDRB5_CLKB_posedge,
        TimingData     => Tmkr_ADDRB5_CLKB_posedge,
        TestSignal     => ADDRB_ipd(5),
        TestSignalName => "ADDRB(5)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ADDRB_CLKB_posedge_posedge(5),
        SetupLow       => tsetup_ADDRB_CLKB_negedge_posedge(5),
        HoldLow        => thold_ADDRB_CLKB_posedge_posedge(5),
        HoldHigh       => thold_ADDRB_CLKB_negedge_posedge(5),
        CheckEnabled   => TO_X01(enb_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/${CELL}",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_ADDRB6_CLKB_posedge,
        TimingData     => Tmkr_ADDRB6_CLKB_posedge,
        TestSignal     => ADDRB_ipd(6),
        TestSignalName => "ADDRB(6)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ADDRB_CLKB_posedge_posedge(6),
        SetupLow       => tsetup_ADDRB_CLKB_negedge_posedge(6),
        HoldLow        => thold_ADDRB_CLKB_posedge_posedge(6),
        HoldHigh       => thold_ADDRB_CLKB_negedge_posedge(6),
        CheckEnabled   => TO_X01(enb_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/${CELL}",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_ADDRB7_CLKB_posedge,
        TimingData     => Tmkr_ADDRB7_CLKB_posedge,
        TestSignal     => ADDRB_ipd(7),
        TestSignalName => "ADDRB(7)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_ADDRB_CLKB_posedge_posedge(7),
        SetupLow       => tsetup_ADDRB_CLKB_negedge_posedge(7),
        HoldLow        => thold_ADDRB_CLKB_posedge_posedge(7),
        HoldHigh       => thold_ADDRB_CLKB_negedge_posedge(7),
        CheckEnabled   => TO_X01(enb_ipd_sampled) = '1',
        RefTransition  => 'R',
        HeaderMsg      => "/${CELL}",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIPB0_CLKB_posedge,
        TimingData     => Tmkr_DIPB0_CLKB_posedge,
        TestSignal     => DIPB_ipd(0),
        TestSignalName => "DIPB(0)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIPB_CLKB_posedge_posedge(0),
        SetupLow       => tsetup_DIPB_CLKB_negedge_posedge(0),
        HoldLow        => thold_DIPB_CLKB_posedge_posedge(0),
        HoldHigh       => thold_DIPB_CLKB_negedge_posedge(0),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIPB1_CLKB_posedge,
        TimingData     => Tmkr_DIPB1_CLKB_posedge,
        TestSignal     => DIPB_ipd(1),
        TestSignalName => "DIPB(1)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIPB_CLKB_posedge_posedge(1),
        SetupLow       => tsetup_DIPB_CLKB_negedge_posedge(1),
        HoldLow        => thold_DIPB_CLKB_posedge_posedge(1),
        HoldHigh       => thold_DIPB_CLKB_negedge_posedge(1),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIPB2_CLKB_posedge,
        TimingData     => Tmkr_DIPB2_CLKB_posedge,
        TestSignal     => DIPB_ipd(2),
        TestSignalName => "DIPB(2)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIPB_CLKB_posedge_posedge(2),
        SetupLow       => tsetup_DIPB_CLKB_negedge_posedge(2),
        HoldLow        => thold_DIPB_CLKB_posedge_posedge(2),
        HoldHigh       => thold_DIPB_CLKB_negedge_posedge(2),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB0_CLKB_posedge,
        TimingData     => Tmkr_DIB0_CLKB_posedge,
        TestSignal     => DIB_ipd(0),
        TestSignalName => "DIB(0)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(0),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(0),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(0),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(0),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB1_CLKB_posedge,
        TimingData     => Tmkr_DIB1_CLKB_posedge,
        TestSignal     => DIB_ipd(1),
        TestSignalName => "DIB(1)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(1),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(1),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(1),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(1),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB2_CLKB_posedge,
        TimingData     => Tmkr_DIB2_CLKB_posedge,
        TestSignal     => DIB_ipd(2),
        TestSignalName => "DIB(2)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(2),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(2),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(2),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(2),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB3_CLKB_posedge,
        TimingData     => Tmkr_DIB3_CLKB_posedge,
        TestSignal     => DIB_ipd(3),
        TestSignalName => "DIB(3)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(3),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(3),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(3),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(3),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB4_CLKB_posedge,
        TimingData     => Tmkr_DIB4_CLKB_posedge,
        TestSignal     => DIB_ipd(4),
        TestSignalName => "DIB(4)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(4),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(4),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(4),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(4),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB5_CLKB_posedge,
        TimingData     => Tmkr_DIB5_CLKB_posedge,
        TestSignal     => DIB_ipd(5),
        TestSignalName => "DIB(5)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(5),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(5),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(5),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(5),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB6_CLKB_posedge,
        TimingData     => Tmkr_DIB6_CLKB_posedge,
        TestSignal     => DIB_ipd(6),
        TestSignalName => "DIB(6)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(6),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(6),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(6),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(6),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB7_CLKB_posedge,
        TimingData     => Tmkr_DIB7_CLKB_posedge,
        TestSignal     => DIB_ipd(7),
        TestSignalName => "DIB(7)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(7),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(7),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(7),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(7),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB8_CLKB_posedge,
        TimingData     => Tmkr_DIB8_CLKB_posedge,
        TestSignal     => DIB_ipd(8),
        TestSignalName => "DIB(8)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(8),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(8),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(8),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(8),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB9_CLKB_posedge,
        TimingData     => Tmkr_DIB9_CLKB_posedge,
        TestSignal     => DIB_ipd(9),
        TestSignalName => "DIB(9)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(9),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(9),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(9),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(9),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB10_CLKB_posedge,
        TimingData     => Tmkr_DIB10_CLKB_posedge,
        TestSignal     => DIB_ipd(10),
        TestSignalName => "DIB(10)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(10),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(10),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(10),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(10),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB11_CLKB_posedge,
        TimingData     => Tmkr_DIB11_CLKB_posedge,
        TestSignal     => DIB_ipd(11),
        TestSignalName => "DIB(11)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(11),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(11),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(11),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(11),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB12_CLKB_posedge,
        TimingData     => Tmkr_DIB12_CLKB_posedge,
        TestSignal     => DIB_ipd(12),
        TestSignalName => "DIB(12)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(12),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(12),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(12),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(12),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB13_CLKB_posedge,
        TimingData     => Tmkr_DIB13_CLKB_posedge,
        TestSignal     => DIB_ipd(13),
        TestSignalName => "DIB(13)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(13),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(13),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(13),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(13),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB14_CLKB_posedge,
        TimingData     => Tmkr_DIB14_CLKB_posedge,
        TestSignal     => DIB_ipd(14),
        TestSignalName => "DIB(14)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(14),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(14),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(14),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(14),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB15_CLKB_posedge,
        TimingData     => Tmkr_DIB15_CLKB_posedge,
        TestSignal     => DIB_ipd(15),
        TestSignalName => "DIB(15)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(15),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(15),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(15),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(15),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB16_CLKB_posedge,
        TimingData     => Tmkr_DIB16_CLKB_posedge,
        TestSignal     => DIB_ipd(16),
        TestSignalName => "DIB(16)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(16),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(16),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(16),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(16),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB17_CLKB_posedge,
        TimingData     => Tmkr_DIB17_CLKB_posedge,
        TestSignal     => DIB_ipd(17),
        TestSignalName => "DIB(17)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(17),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(17),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(17),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(17),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB18_CLKB_posedge,
        TimingData     => Tmkr_DIB18_CLKB_posedge,
        TestSignal     => DIB_ipd(18),
        TestSignalName => "DIB(18)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(18),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(18),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(18),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(18),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB19_CLKB_posedge,
        TimingData     => Tmkr_DIB19_CLKB_posedge,
        TestSignal     => DIB_ipd(19),
        TestSignalName => "DIB(19)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(19),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(19),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(19),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(19),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB20_CLKB_posedge,
        TimingData     => Tmkr_DIB20_CLKB_posedge,
        TestSignal     => DIB_ipd(20),
        TestSignalName => "DIB(20)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(20),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(20),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(20),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(20),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB21_CLKB_posedge,
        TimingData     => Tmkr_DIB21_CLKB_posedge,
        TestSignal     => DIB_ipd(21),
        TestSignalName => "DIB(21)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(21),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(21),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(21),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(21),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB22_CLKB_posedge,
        TimingData     => Tmkr_DIB22_CLKB_posedge,
        TestSignal     => DIB_ipd(22),
        TestSignalName => "DIB(22)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(22),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(22),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(22),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(22),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB23_CLKB_posedge,
        TimingData     => Tmkr_DIB23_CLKB_posedge,
        TestSignal     => DIB_ipd(23),
        TestSignalName => "DIB(23)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(23),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(23),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(23),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(23),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB24_CLKB_posedge,
        TimingData     => Tmkr_DIB24_CLKB_posedge,
        TestSignal     => DIB_ipd(24),
        TestSignalName => "DIB(24)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(24),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(24),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(24),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(24),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB25_CLKB_posedge,
        TimingData     => Tmkr_DIB25_CLKB_posedge,
        TestSignal     => DIB_ipd(25),
        TestSignalName => "DIB(25)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(25),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(25),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(25),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(25),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB26_CLKB_posedge,
        TimingData     => Tmkr_DIB26_CLKB_posedge,
        TestSignal     => DIB_ipd(26),
        TestSignalName => "DIB(26)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(26),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(26),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(26),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(26),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB27_CLKB_posedge,
        TimingData     => Tmkr_DIB27_CLKB_posedge,
        TestSignal     => DIB_ipd(27),
        TestSignalName => "DIB(27)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(27),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(27),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(27),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(27),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB28_CLKB_posedge,
        TimingData     => Tmkr_DIB28_CLKB_posedge,
        TestSignal     => DIB_ipd(28),
        TestSignalName => "DIB(28)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(28),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(28),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(28),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(28),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB29_CLKB_posedge,
        TimingData     => Tmkr_DIB29_CLKB_posedge,
        TestSignal     => DIB_ipd(29),
        TestSignalName => "DIB(29)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(29),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(29),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(29),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(29),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalSetupHoldCheck (
        Violation      => Tviol_DIB30_CLKB_posedge,
        TimingData     => Tmkr_DIB30_CLKB_posedge,
        TestSignal     => DIB_ipd(30),
        TestSignalName => "DIB(30)",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        SetupHigh      => tsetup_DIB_CLKB_posedge_posedge(30),
        SetupLow       => tsetup_DIB_CLKB_negedge_posedge(30),
        HoldLow        => thold_DIB_CLKB_posedge_posedge(30),
        HoldHigh       => thold_DIB_CLKB_negedge_posedge(30),
        CheckEnabled   => (TO_X01(enb_ipd_sampled) = '1' and TO_X01(web_ipd_sampled) = '1'),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalPeriodPulseCheck (
        Violation      => Pviol_CLKA,
        PeriodData     => PInfo_CLKA,
        TestSignal     => CLKA_ipd,
        TestSignalName => "CLKA",
        TestDelay      => 0 ps,
        Period         => 0 ps,
        PulseWidthHigh => tpw_CLKA_posedge,
        PulseWidthLow  => tpw_CLKA_negedge,
        CheckEnabled   => TO_X01(ena_ipd_sampled) = '1',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
      VitalPeriodPulseCheck (
        Violation      => Pviol_CLKB,
        PeriodData     => PInfo_CLKB,
        TestSignal     => CLKB_ipd,
        TestSignalName => "CLKB",
        TestDelay      => 0 ps,
        Period         => 0 ps,
        PulseWidthHigh => tpw_CLKB_posedge,
        PulseWidthLow  => tpw_CLKB_negedge,
        CheckEnabled   => TO_X01(enb_ipd_sampled) = '1',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => Xon,
        MsgOn          => MsgOn,
        MsgSeverity    => warning);
    end if;

    ViolationA := Pviol_CLKA or
                  Tviol_ADDRA0_CLKA_posedge or
                  Tviol_ADDRA1_CLKA_posedge or
                  Tviol_ADDRA2_CLKA_posedge or
                  Tviol_ADDRA3_CLKA_posedge or
                  Tviol_ADDRA4_CLKA_posedge or
                  Tviol_ADDRA5_CLKA_posedge or
                  Tviol_ADDRA6_CLKA_posedge or
                  Tviol_ADDRA7_CLKA_posedge or
                  Tviol_ADDRA8_CLKA_posedge or
                  Tviol_ADDRA9_CLKA_posedge or
                  Tviol_ADDRA10_CLKA_posedge or
                  Tviol_DIA0_CLKA_posedge or
                  Tviol_DIA1_CLKA_posedge or
                  Tviol_DIA2_CLKA_posedge or
                  Tviol_DIA3_CLKA_posedge or
                  Tviol_DIA4_CLKA_posedge or
                  Tviol_DIA5_CLKA_posedge or
                  Tviol_DIA6_CLKA_posedge or
                  Tviol_DIA7_CLKA_posedge or
                  Tviol_DIPA0_CLKA_posedge or
                  Tviol_ENA_CLKA_posedge or
                  Tviol_SSRA_CLKA_posedge or
                  Tviol_WEA_CLKA_posedge;

    ViolationB := Pviol_CLKB or
                  Tviol_ADDRB0_CLKB_posedge or
                  Tviol_ADDRB1_CLKB_posedge or
                  Tviol_ADDRB2_CLKB_posedge or
                  Tviol_ADDRB3_CLKB_posedge or
                  Tviol_ADDRB4_CLKB_posedge or
                  Tviol_ADDRB5_CLKB_posedge or
                  Tviol_ADDRB6_CLKB_posedge or
                  Tviol_ADDRB7_CLKB_posedge or
                  Tviol_ADDRB8_CLKB_posedge or
                  Tviol_DIB0_CLKB_posedge or
                  Tviol_DIB1_CLKB_posedge or
                  Tviol_DIB2_CLKB_posedge or
                  Tviol_DIB3_CLKB_posedge or
                  Tviol_DIB4_CLKB_posedge or
                  Tviol_DIB5_CLKB_posedge or
                  Tviol_DIB6_CLKB_posedge or
                  Tviol_DIB7_CLKB_posedge or
                  Tviol_DIB8_CLKB_posedge or
                  Tviol_DIB9_CLKB_posedge or
                  Tviol_DIB10_CLKB_posedge or
                  Tviol_DIB11_CLKB_posedge or
                  Tviol_DIB12_CLKB_posedge or
                  Tviol_DIB13_CLKB_posedge or
                  Tviol_DIB14_CLKB_posedge or
                  Tviol_DIB15_CLKB_posedge or
                  Tviol_DIB16_CLKB_posedge or
                  Tviol_DIB17_CLKB_posedge or
                  Tviol_DIB18_CLKB_posedge or
                  Tviol_DIB19_CLKB_posedge or
                  Tviol_DIB20_CLKB_posedge or
                  Tviol_DIB21_CLKB_posedge or
                  Tviol_DIB22_CLKB_posedge or
                  Tviol_DIB23_CLKB_posedge or
                  Tviol_DIB24_CLKB_posedge or
                  Tviol_DIB25_CLKB_posedge or
                  Tviol_DIB26_CLKB_posedge or
                  Tviol_DIB27_CLKB_posedge or
                  Tviol_DIB28_CLKB_posedge or
                  Tviol_DIB29_CLKB_posedge or
                  Tviol_DIB30_CLKB_posedge or
                  Tviol_DIB31_CLKB_posedge or
                  Tviol_DIPB0_CLKB_posedge or
                  Tviol_DIPB1_CLKB_posedge or
                  Tviol_DIPB2_CLKB_posedge or
                  Tviol_DIPB3_CLKB_posedge or
                  Tviol_ENB_CLKB_posedge or
                  Tviol_SSRB_CLKB_posedge or
                  Tviol_WEB_CLKB_posedge;

    VALID_ADDRA := ADDR_IS_VALID(addra_ipd_sampled);
    VALID_ADDRB := ADDR_IS_VALID(addrb_ipd_sampled);

    if (VALID_ADDRA) then
      ADDRESS_A := SLV_TO_INT(addra_ipd_sampled);
    end if;

    if (VALID_ADDRB) then
      ADDRESS_B := SLV_TO_INT(addrb_ipd_sampled);
    end if;

    if (VALID_ADDRA and VALID_ADDRB) then
      addr_overlap (address_a, address_b, width_a, width_b, has_overlap, olp_lsb, olp_msb, doa_ov_lsb, doa_ov_msb, dob_ov_lsb, dob_ov_msb);
      addr_overlap (address_a, address_b, parity_width_a, parity_width_b, has_overlap_p, olpp_lsb, olpp_msb, dopa_ov_lsb, dopa_ov_msb, dopb_ov_lsb, dopb_ov_msb);
    end if;

    ViolationCLKAB    := '0';
    ViolationCLKAB_S0 := false;
    Violation_S1      := false;
    Violation_S3      := false;

    if ((collision_type = 1) or (collision_type = 2) or (collision_type = 3)) then    
      VitalRecoveryRemovalCheck (
        Violation      => Tviol_CLKB_CLKA_all,
        TimingData     => Tmkr_CLKB_CLKA_all,
        TestSignal     => CLKB_ipd,
        TestSignalName => "CLKB",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        Recovery       => SETUP_ALL,
        Removal       => 1 ps,
        ActiveLow      => true,
        CheckEnabled   => (HAS_OVERLAP = true and ena_ipd_sampled = '1' and enb_ipd_sampled = '1' and ((web_ipd_sampled = '1' and wr_mode_b /= 1) or (wea_ipd_sampled = '1' and wr_mode_a /= 1 and web_ipd_sampled = '0'))),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => true,
        MsgOn          => false,
        MsgSeverity    => warning);

      VitalRecoveryRemovalCheck (
        Violation      => Tviol_CLKA_CLKB_all,
        TimingData     => Tmkr_CLKA_CLKB_all,
        TestSignal     => CLKA_ipd,
        TestSignalName => "CLKA",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        Recovery       => SETUP_ALL,
        Removal       => 1 ps,
        ActiveLow      => true,
        CheckEnabled   => (HAS_OVERLAP = true and ena_ipd_sampled = '1' and enb_ipd_sampled = '1' and ((wea_ipd_sampled = '1' and wr_mode_a /= 1) or (web_ipd_sampled = '1' and wea_ipd_sampled = '0' and wr_mode_b /= 1))),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => true,
        MsgOn          => false,
        MsgSeverity    => warning);

      VitalRecoveryRemovalCheck (
        Violation      => Tviol_CLKB_CLKA_read_first,
        TimingData     => Tmkr_CLKB_CLKA_read_first,
        TestSignal     => CLKB_ipd,
        TestSignalName => "CLKB",
        TestDelay      => 0 ps,
        RefSignal      => CLKA_ipd,
        RefSignalName  => "CLKA",
        RefDelay       => 0 ps,
        Recovery       => SETUP_READ_FIRST,
        Removal       => 1 ps,
        ActiveLow      => true,
        CheckEnabled   => (HAS_OVERLAP = true and ena_ipd_sampled = '1' and enb_ipd_sampled = '1' and web_ipd_sampled = '1' and wr_mode_b = 1 and (CLKA_ipd'last_event /= CLKB_ipd'last_event)),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => true,
        MsgOn          => false,
        MsgSeverity    => warning);

      VitalRecoveryRemovalCheck (
        Violation      => Tviol_CLKA_CLKB_read_first,
        TimingData     => Tmkr_CLKA_CLKB_read_first,
        TestSignal     => CLKA_ipd,
        TestSignalName => "CLKA",
        TestDelay      => 0 ps,
        RefSignal      => CLKB_ipd,
        RefSignalName  => "CLKB",
        RefDelay       => 0 ps,
        Recovery       => SETUP_READ_FIRST,
        Removal       => 1 ps,
        ActiveLow      => true,
        CheckEnabled   => (HAS_OVERLAP = true and ena_ipd_sampled = '1' and enb_ipd_sampled = '1' and wea_ipd_sampled = '1' and wr_mode_a = 1 and (CLKA_ipd'last_event /= CLKB_ipd'last_event)),
        RefTransition  => 'R',
        HeaderMsg      => "/RAMB16_S9_S36",
        Xon            => true,
        MsgOn          => false,
        MsgSeverity    => warning);        
    end if;
    ViolationCLKAB := Tviol_CLKB_CLKA_all or Tviol_CLKA_CLKB_all or Tviol_CLKB_CLKA_read_first or Tviol_CLKA_CLKB_read_first;        


    WR_A_LATER := false;
    WR_B_LATER := false;

    if (ena_ipd_sampled = '1')then
      if (rising_edge(CLKA_ipd)) then

        if (wea_ipd_sampled = '1') then
          case wr_mode_a is
            when 0 =>
              DOA_zd  := DIA_ipd;
              DOPA_zd := DIPA_ipd;

              if (ViolationCLKAB = 'X') then
                if (web_ipd_sampled /= '0') then
                  if ((collision_type = 1) or (collision_type = 3)) then
                    Memory_Collision_Msg
                      (collision_type => Write_A_Write_B,
                       EntityName => "RAMB16_S9_S36",
                       InstanceName => ramb16_s9_s36'path_name,
                       address_a => addra_ipd_sampled,
                       address_b => addrb_ipd_sampled
                       );
                  end if;
                  if ((collision_type = 2) or (collision_type = 3)) then
                    MEM(ADDRESS_A/(length_a/length_b))(DOB_OV_MSB downto DOB_OV_LSB) := (others => 'X');
                    MEMP(ADDRESS_A/(length_a/length_b))(DOPB_OV_MSB downto DOPB_OV_LSB) := (others => 'X');    

                    DOA_zd := (others => 'X');
                    DOPA_zd := (others => 'X');

                    if (wr_mode_b /= 2 ) then
                      DOB_zd (DOB_OV_MSB downto DOB_OV_LSB)    := (others => 'X');
                      DOPB_zd (DOPB_OV_MSB downto DOPB_OV_LSB) := (others => 'X');
                    end if;

                  end if;
                else
                  if ((collision_type = 1) or (collision_type = 3)) then                
                    Memory_Collision_Msg
                      (collision_type => Read_B_Write_A,
                       EntityName => "RAMB16_S9_S36",
                       InstanceName => ramb16_s9_s36'path_name,
                       address_a => addra_ipd_sampled,
                       address_b => addrb_ipd_sampled
                       );
                  end if;
                  MEM(ADDRESS_A/(length_a/length_b))(((((address_a)rem(length_a/length_b))*(width_a)) + (width_a - 1)) downto (((address_a)rem(length_a/length_b))*(width_a))):= DIA_ipd;
                  MEMP(ADDRESS_A/(length_a/length_b))(((((address_a)rem(length_a/length_b))*(parity_width_a)) + (parity_width_a - 1)) downto (((address_a)rem(length_a/length_b))*(parity_width_a))):= DIPA_ipd;                                      
                  if ((collision_type = 2) or (collision_type = 3)) then
                    DOB_zd (DOB_OV_MSB downto DOB_OV_LSB)                      := (others => 'X');
                    DOPB_zd (DOPB_OV_MSB downto DOPB_OV_LSB)                   := (others => 'X');
                  end if;
                end if;

              else
                if (VALID_ADDRA ) then
                    MEM(ADDRESS_A/(length_a/length_b))(((((address_a)rem(length_a/length_b))*(width_a)) + (width_a - 1)) downto (((address_a)rem(length_a/length_b))*(width_a))):= DIA_ipd;
                    MEMP(ADDRESS_A/(length_a/length_b))(((((address_a)rem(length_a/length_b))*(parity_width_a)) + (parity_width_a - 1)) downto (((address_a)rem(length_a/length_b))*(parity_width_a))):= DIPA_ipd;
                end if;
              end if;

            when 1 =>
               if (VALID_ADDRA ) then
                DOA_zd  := MEM(ADDRESS_A/(length_a/length_b))(((((address_a)rem(length_a/length_b))*(width_a)) + (width_a - 1)) downto (((address_a)rem(length_a/length_b))*(width_a)));
                DOPA_zd := MEMP(ADDRESS_A/(length_a/length_b))(((((address_a)rem(length_a/length_b))*(parity_width_a)) + (parity_width_a - 1)) downto (((address_a)rem(length_a/length_b))*(parity_width_a)));
                WR_A_LATER := true;
              end if;

              if (ViolationCLKAB = 'X') then

                if (web_ipd_sampled /= '0') then
                  if ((collision_type = 1) or (collision_type = 3)) then
                    Memory_Collision_Msg
                      (collision_type => Write_A_Write_B,
                       EntityName => "RAMB16_S9_S36",
                       InstanceName => ramb16_s9_s36'path_name,
                       address_a => addra_ipd_sampled,
                       address_b => addrb_ipd_sampled
                       );
                  end if;
                  if ((collision_type = 2) or (collision_type = 3)) then
                    MEM(ADDRESS_A/(length_a/length_b))(DOB_OV_MSB downto DOB_OV_LSB) := (others => 'X');
                    MEMP(ADDRESS_A/(length_a/length_b))(DOPB_OV_MSB downto DOPB_OV_LSB) := (others => 'X');

                    DOA_zd := (others => 'X');
                    DOPA_zd := (others => 'X');

                    if (wr_mode_b /= 2 ) then
                      DOB_zd (DOB_OV_MSB downto DOB_OV_LSB)    := (others => 'X');
                      DOPB_zd (DOPB_OV_MSB downto DOPB_OV_LSB) := (others => 'X');
                    end if;
                  end if;

                else
                  if ((collision_type = 1) or (collision_type = 3)) then
                    Memory_Collision_Msg
                      (collision_type => Read_B_Write_A,
                       EntityName => "RAMB16_S9_S36",
                       InstanceName => ramb16_s9_s36'path_name,
                       address_a => addra_ipd_sampled,
                       address_b => addrb_ipd_sampled
                       );
                  end if;
                    MEM(ADDRESS_A/(length_a/length_b))(((((address_a)rem(length_a/length_b))*(width_a)) + (width_a - 1)) downto (((address_a)rem(length_a/length_b))*(width_a))):= DIA_ipd;
                    MEMP(ADDRESS_A/(length_a/length_b))(((((address_a)rem(length_a/length_b))*(parity_width_a)) + (parity_width_a - 1)) downto (((address_a)rem(length_a/length_b))*(parity_width_a))):= DIPA_ipd;
                if ((collision_type = 2) or (collision_type = 3)) then                
                  DOB_zd (DOB_OV_MSB downto DOB_OV_LSB)                      := (others => 'X');
                  DOPB_zd (DOPB_OV_MSB downto DOPB_OV_LSB)                   := (others => 'X');
                end if;
              end if;

            end if;

            when 2 =>
              if (ViolationCLKAB = 'X') then
                if (web_ipd_sampled /= '0') then
                  if ((collision_type = 1) or (collision_type = 3)) then
                    Memory_Collision_Msg
                      (collision_type => Write_A_Write_B,
                       EntityName => "RAMB16_S9_S36",
                       InstanceName => ramb16_s9_s36'path_name,
                       address_a => addra_ipd_sampled,
                       address_b => addrb_ipd_sampled
                       );
                  end if;
                  if ((collision_type = 2) or (collision_type = 3)) then
                    MEM(ADDRESS_A/(length_a/length_b))(DOB_OV_MSB downto DOB_OV_LSB) := (others => 'X');
                    MEMP(ADDRESS_A/(length_a/length_b))(DOPB_OV_MSB downto DOPB_OV_LSB) := (others => 'X');

                    if (wr_mode_b /= 2 ) then
                      DOB_zd (DOB_OV_MSB downto DOB_OV_LSB)    := (others => 'X');
                      DOPB_zd (DOPB_OV_MSB downto DOPB_OV_LSB) := (others => 'X');
                    end if;
                  end if;

                else
                  if ((collision_type = 1) or (collision_type = 3)) then
                    Memory_Collision_Msg
                      (collision_type => Read_B_Write_A,
                       EntityName => "RAMB16_S9_S36",
                       InstanceName => ramb16_s9_s36'path_name,
                       address_a => addra_ipd_sampled,
                       address_b => addrb_ipd_sampled
                       );
                  end if;
                  if ((collision_type = 2) or (collision_type = 3)) then
                    DOB_zd (DOB_OV_MSB downto DOB_OV_LSB)                      := (others => 'X');
                    DOPB_zd (DOPB_OV_MSB downto DOPB_OV_LSB)                   := (others => 'X');
                  end if;
                    MEM(ADDRESS_A/(length_a/length_b))(((((address_a)rem(length_a/length_b))*(width_a)) + (width_a - 1)) downto (((address_a)rem(length_a/length_b))*(width_a))):= DIA_ipd;
                    MEMP(ADDRESS_A/(length_a/length_b))(((((address_a)rem(length_a/length_b))*(parity_width_a)) + (parity_width_a - 1)) downto (((address_a)rem(length_a/length_b))*(parity_width_a))):= DIPA_ipd;
                end if;

              else
                if (VALID_ADDRA) then
                  MEM(ADDRESS_A/(length_a/length_b))(((((address_a)rem(length_a/length_b))*(width_a)) + (width_a - 1)) downto (((address_a)rem(length_a/length_b))*(width_a))):= DIA_ipd;
                  MEMP(ADDRESS_A/(length_a/length_b))(((((address_a)rem(length_a/length_b))*(parity_width_a)) + (parity_width_a - 1)) downto (((address_a)rem(length_a/length_b))*(parity_width_a))):= DIPA_ipd;
                end if;
              end if;

            when others => null;
          end case;

        else
          if (VALID_ADDRA) then
            DOA_zd  := MEM(ADDRESS_A/(length_a/length_b))(((((address_a)rem(length_a/length_b))*(width_a)) + (width_a - 1)) downto (((address_a)rem(length_a/length_b))*(width_a)));
            DOPA_zd := MEMP(ADDRESS_A/(length_a/length_b))(((((address_a)rem(length_a/length_b))*(parity_width_a)) + (parity_width_a - 1)) downto (((address_a)rem(length_a/length_b))*(parity_width_a)));
          end if;

          if (ViolationCLKAB = 'X') then
            if ((collision_type = 1) or (collision_type = 3)) then                
              Memory_Collision_Msg
                (collision_type => Read_A_Write_B,
                 EntityName => "RAMB16_S9_S36",
                 InstanceName => ramb16_s9_s36'path_name,
                 address_a => addra_ipd_sampled,
                 address_b => addrb_ipd_sampled
                 );
            end if;
            if ((collision_type = 2) or (collision_type = 3)) then                
              DOA_zd := (others => 'X');
              DOPA_zd := (others => 'X');
            end if;
          end if;
        end if;

        if (ssra_ipd_sampled = '1') then
          DOA_zd  := SRVA_A(7 downto 0);
          DOPA_zd := SRVA_A(8 downto 8);
        end if;
      end if;
    end if;

    if (enb_ipd_sampled = '1') then
      if (rising_edge(CLKB_ipd)) then

        if (web_ipd_sampled = '1') then
          case wr_mode_b is
            when 0 =>
              DOB_zd  := DIB_ipd;
              DOPB_zd := DIPB_ipd;
               if (VALID_ADDRB) then
                MEM(ADDRESS_B) := DIB_ipd;
                MEMP(ADDRESS_B) := DIPB_ipd;
               end if;
              if (ViolationCLKAB = 'X') then
                if (wea_ipd_sampled /= '0') then
                  if ((collision_type = 1) or (collision_type = 3)) then
                    Memory_Collision_Msg
                      (collision_type => Write_A_Write_B,
                       EntityName => "RAMB16_S9_S36",
                       InstanceName => ramb16_s9_s36'path_name,
                       address_a => addra_ipd_sampled,
                       address_b => addrb_ipd_sampled
                       );
                 end if;
                 if ((collision_type = 2) or (collision_type = 3)) then
                   MEM(ADDRESS_B)(DOB_OV_MSB downto DOB_OV_LSB) := (others => 'X');
                   MEMP(ADDRESS_B)(DOPB_OV_MSB downto DOPB_OV_LSB) := (others => 'X');

                   DOB_zd (DOB_OV_MSB downto DOB_OV_LSB)    := (others => 'X');
                   DOPB_zd (DOPB_OV_MSB downto DOPB_OV_LSB) := (others => 'X');

                   if (wr_mode_a /= 2 ) then
                     DOA_zd := (others => 'X');
                     DOPA_zd := (others => 'X');
                   end if;
                 end if;

                else
                  if ((collision_type = 1) or (collision_type = 3)) then
                    Memory_Collision_Msg
                      (collision_type => Read_A_Write_B,
                       EntityName => "RAMB16_S9_S36",
                       InstanceName => ramb16_s9_s36'path_name,
                       address_a => addra_ipd_sampled,
                       address_b => addrb_ipd_sampled
                       );
                  end if;
                  if ((collision_type = 2) or (collision_type = 3)) then
                    DOA_zd := (others => 'X');
                    DOPA_zd := (others => 'X');
                  end if;
                end if;
              end if;

            when 1 =>
              if (VALID_ADDRB) then
                DOB_zd  := MEM(ADDRESS_B);
                DOPB_zd := MEMP(ADDRESS_B);
                WR_B_LATER := true;
                MEM(ADDRESS_B)     := DIB_ipd ;
                MEMP(ADDRESS_B) := DIPB_ipd;
               end if;
              if (ViolationCLKAB = 'X') then
                if (wea_ipd_sampled /= '0') then
                  if ((collision_type = 1) or (collision_type = 3)) then
                    Memory_Collision_Msg
                      (collision_type => Write_A_Write_B,
                       EntityName => "RAMB16_S9_S36",
                       InstanceName => ramb16_s9_s36'path_name,
                       address_a => addra_ipd_sampled,
                       address_b => addrb_ipd_sampled
                       );
                  end if;
                  if ((collision_type = 2) or (collision_type = 3)) then
                    MEM(ADDRESS_B)(DOB_OV_MSB downto DOB_OV_LSB) := (others => 'X');
                    MEMP(ADDRESS_B)(DOPB_OV_MSB downto DOPB_OV_LSB) := (others => 'X');

                    DOB_zd (DOB_OV_MSB downto DOB_OV_LSB)    := (others => 'X');
                    DOPB_zd (DOPB_OV_MSB downto DOPB_OV_LSB) := (others => 'X');

                    if (wr_mode_a /= 2 ) then
                      DOA_zd := (others => 'X');
                      DOPA_zd := (others => 'X');
                    end if;
                  end if;

                else
                  if ((collision_type = 1) or (collision_type = 3)) then
                    Memory_Collision_Msg
                      (collision_type => Read_A_Write_B,
                       EntityName => "RAMB16_S9_S36",
                       InstanceName => ramb16_s9_s36'path_name,
                       address_a => addra_ipd_sampled,
                       address_b => addrb_ipd_sampled
                       );
                  end if;
                  if ((collision_type = 2) or (collision_type = 3)) then
                    DOA_zd := (others => 'X');
                    DOPA_zd := (others => 'X');
                  end if;
                end if;
              end if;

            when 2 =>
              if (VALID_ADDRB) then
                MEM(ADDRESS_B) := DIB_ipd;
                MEMP(ADDRESS_B) := DIPB_ipd;
            end if;
            if (ViolationCLKAB = 'X') then

              if (wea_ipd_sampled /= '0') then
                if ((collision_type = 1) or (collision_type = 3)) then
                  Memory_Collision_Msg
                    (collision_type => Write_A_Write_B,
                     EntityName => "RAMB16_S9_S36",
                     InstanceName => ramb16_s9_s36'path_name,
                     address_a => addra_ipd_sampled,
                     address_b => addrb_ipd_sampled
                     );
                end if;
                if ((collision_type = 2) or (collision_type = 3)) then
                    MEM(ADDRESS_B)(DOB_OV_MSB downto DOB_OV_LSB) := (others => 'X');
                    MEMP(ADDRESS_B)(DOPB_OV_MSB downto DOPB_OV_LSB) := (others => 'X');

                  if (wr_mode_a /= 2 ) then
                    DOA_zd := (others => 'X');
                    DOPA_zd := (others => 'X');
                  end if;
                end if;

                else
                  if ((collision_type = 1) or (collision_type = 3)) then
                    Memory_Collision_Msg
                      (collision_type => Read_A_Write_B,
                       EntityName => "RAMB16_S9_S36",
                       InstanceName => ramb16_s9_s36'path_name,
                       address_a => addra_ipd_sampled,
                       address_b => addrb_ipd_sampled
                       );
                  end if;
                  if ((collision_type = 2) or (collision_type = 3)) then
                    DOA_zd := (others => 'X');
                    DOPA_zd := (others => 'X');
                  end if;
                end if;
              end if;
            when others => null;
          end case;

        else
          if (VALID_ADDRB) then
            DOB_zd  := MEM(ADDRESS_B);
            DOPB_zd := MEMP(ADDRESS_B);
           end if;

          if (ViolationCLKAB = 'X') then
            if ((collision_type = 1) or (collision_type = 3)) then                
              Memory_Collision_Msg
                (collision_type => Read_B_Write_A,
                 EntityName => "RAMB16_S9_S36",
                 InstanceName => ramb16_s9_s36'path_name,
                 address_a => addra_ipd_sampled,
                 address_b => addrb_ipd_sampled
                 );
            end if;
            if ((collision_type = 2) or (collision_type = 3)) then                
              DOB_zd (DOB_OV_MSB downto DOB_OV_LSB)    := (others => 'X');
              DOPB_zd (DOPB_OV_MSB downto DOPB_OV_LSB) := (others => 'X');
            end if;
          end if;
        end if;

        if (ssrb_ipd_sampled = '1') then
          DOB_zd  := SRVA_B(31 downto 0);
          DOPB_zd := SRVA_B(35 downto 32);
        end if;
      end if;
    end if;

    if ((WR_A_LATER = true) and (VALID_ADDRA)) then
      MEM(ADDRESS_A/(length_a/length_b))(((((address_a)rem(length_a/length_b))*(width_a)) + (width_a - 1)) downto (((address_a)rem(length_a/length_b))*(width_a))):= DIA_ipd;
      MEMP(ADDRESS_A/(length_a/length_b))(((((address_a)rem(length_a/length_b))*(parity_width_a)) + (parity_width_a - 1)) downto (((address_a)rem(length_a/length_b))*(parity_width_a))):= DIPA_ipd;
    end if;

    if ((WR_B_LATER = true ) and (VALID_ADDRB))then
      MEM(ADDRESS_B) := DIB_ipd;
      MEMP(ADDRESS_B) := DIPB_ipd;
    end if;

    DOA_zd(0)  := ViolationA xor DOA_zd(0);
    DOA_zd(1)  := ViolationA xor DOA_zd(1);
    DOA_zd(2)  := ViolationA xor DOA_zd(2);
    DOA_zd(3)  := ViolationA xor DOA_zd(3);
    DOA_zd(4)  := ViolationA xor DOA_zd(4);
    DOA_zd(5)  := ViolationA xor DOA_zd(5);
    DOA_zd(6)  := ViolationA xor DOA_zd(6);
    DOA_zd(7)  := ViolationA xor DOA_zd(7);
    DOPA_zd(0) := ViolationA xor DOPA_zd(0);
    DOB_zd(0)  := ViolationB xor DOB_zd(0);
    DOB_zd(1)  := ViolationB xor DOB_zd(1);
    DOB_zd(2)  := ViolationB xor DOB_zd(2);
    DOB_zd(3)  := ViolationB xor DOB_zd(3);
    DOB_zd(4)  := ViolationB xor DOB_zd(4);
    DOB_zd(5)  := ViolationB xor DOB_zd(5);
    DOB_zd(6)  := ViolationB xor DOB_zd(6);
    DOB_zd(7)  := ViolationB xor DOB_zd(7);
    DOB_zd(8)  := ViolationB xor DOB_zd(8);
    DOB_zd(9)  := ViolationB xor DOB_zd(9);
    DOB_zd(10)  := ViolationB xor DOB_zd(10);
    DOB_zd(11)  := ViolationB xor DOB_zd(11);
    DOB_zd(12)  := ViolationB xor DOB_zd(12);
    DOB_zd(13)  := ViolationB xor DOB_zd(13);
    DOB_zd(14)  := ViolationB xor DOB_zd(14);
    DOB_zd(15)  := ViolationB xor DOB_zd(15);
    DOB_zd(16)  := ViolationB xor DOB_zd(16);
    DOB_zd(17)  := ViolationB xor DOB_zd(17);
    DOB_zd(18)  := ViolationB xor DOB_zd(18);
    DOB_zd(19)  := ViolationB xor DOB_zd(19);
    DOB_zd(20)  := ViolationB xor DOB_zd(20);
    DOB_zd(21)  := ViolationB xor DOB_zd(21);
    DOB_zd(22)  := ViolationB xor DOB_zd(22);
    DOB_zd(23)  := ViolationB xor DOB_zd(23);
    DOB_zd(24)  := ViolationB xor DOB_zd(24);
    DOB_zd(25)  := ViolationB xor DOB_zd(25);
    DOB_zd(26)  := ViolationB xor DOB_zd(26);
    DOB_zd(27)  := ViolationB xor DOB_zd(27);
    DOB_zd(28)  := ViolationB xor DOB_zd(28);
    DOB_zd(29)  := ViolationB xor DOB_zd(29);
    DOB_zd(30)  := ViolationB xor DOB_zd(30);
    DOB_zd(31)  := ViolationB xor DOB_zd(31);
    DOPB_zd(0) := ViolationB xor DOPB_zd(0);
    DOPB_zd(1) := ViolationB xor DOPB_zd(1);
    DOPB_zd(2) := ViolationB xor DOPB_zd(2);
    DOPB_zd(3) := ViolationB xor DOPB_zd(3);

    VitalPathDelay01 (
      OutSignal     => DOA(0),
      GlitchData    => DOA_GlitchData0,
      OutSignalName => "DOA(0)",
      OutTemp       => DOA_zd(0),
      Paths         => (0 => (CLKA_ipd'last_event, tpd_CLKA_DOA(0), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOA(1),
      GlitchData    => DOA_GlitchData1,
      OutSignalName => "DOA(1)",
      OutTemp       => DOA_zd(1),
      Paths         => (0 => (CLKA_ipd'last_event, tpd_CLKA_DOA(1), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOA(2),
      GlitchData    => DOA_GlitchData2,
      OutSignalName => "DOA(2)",
      OutTemp       => DOA_zd(2),
      Paths         => (0 => (CLKA_ipd'last_event, tpd_CLKA_DOA(2), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOA(3),
      GlitchData    => DOA_GlitchData3,
      OutSignalName => "DOA(3)",
      OutTemp       => DOA_zd(3),
      Paths         => (0 => (CLKA_ipd'last_event, tpd_CLKA_DOA(3), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOA(4),
      GlitchData    => DOA_GlitchData4,
      OutSignalName => "DOA(4)",
      OutTemp       => DOA_zd(4),
      Paths         => (0 => (CLKA_ipd'last_event, tpd_CLKA_DOA(4), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOA(5),
      GlitchData    => DOA_GlitchData5,
      OutSignalName => "DOA(5)",
      OutTemp       => DOA_zd(5),
      Paths         => (0 => (CLKA_ipd'last_event, tpd_CLKA_DOA(5), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOA(6),
      GlitchData    => DOA_GlitchData6,
      OutSignalName => "DOA(6)",
      OutTemp       => DOA_zd(6),
      Paths         => (0 => (CLKA_ipd'last_event, tpd_CLKA_DOA(6), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOA(7),
      GlitchData    => DOA_GlitchData7,
      OutSignalName => "DOA(7)",
      OutTemp       => DOA_zd(7),
      Paths         => (0 => (CLKA_ipd'last_event, tpd_CLKA_DOA(7), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOPA(0),
      GlitchData    => DOPA_GlitchData0,
      OutSignalName => "DOPA(0)",
      OutTemp       => DOPA_zd(0),
      Paths         => (0 => (CLKA_ipd'last_event, tpd_CLKA_DOPA(0), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(0),
      GlitchData    => DOB_GlitchData0,
      OutSignalName => "DOB(0)",
      OutTemp       => DOB_zd(0),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(0), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(1),
      GlitchData    => DOB_GlitchData1,
      OutSignalName => "DOB(1)",
      OutTemp       => DOB_zd(1),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(1), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(2),
      GlitchData    => DOB_GlitchData2,
      OutSignalName => "DOB(2)",
      OutTemp       => DOB_zd(2),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(2), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(3),
      GlitchData    => DOB_GlitchData3,
      OutSignalName => "DOB(3)",
      OutTemp       => DOB_zd(3),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(3), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(4),
      GlitchData    => DOB_GlitchData4,
      OutSignalName => "DOB(4)",
      OutTemp       => DOB_zd(4),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(4), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(5),
      GlitchData    => DOB_GlitchData5,
      OutSignalName => "DOB(5)",
      OutTemp       => DOB_zd(5),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(5), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(6),
      GlitchData    => DOB_GlitchData6,
      OutSignalName => "DOB(6)",
      OutTemp       => DOB_zd(6),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(6), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(7),
      GlitchData    => DOB_GlitchData7,
      OutSignalName => "DOB(7)",
      OutTemp       => DOB_zd(7),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(7), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(8),
      GlitchData    => DOB_GlitchData8,
      OutSignalName => "DOB(8)",
      OutTemp       => DOB_zd(8),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(8), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(9),
      GlitchData    => DOB_GlitchData9,
      OutSignalName => "DOB(9)",
      OutTemp       => DOB_zd(9),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(9), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(10),
      GlitchData    => DOB_GlitchData10,
      OutSignalName => "DOB(10)",
      OutTemp       => DOB_zd(10),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(10), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(11),
      GlitchData    => DOB_GlitchData11,
      OutSignalName => "DOB(11)",
      OutTemp       => DOB_zd(11),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(11), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(12),
      GlitchData    => DOB_GlitchData12,
      OutSignalName => "DOB(12)",
      OutTemp       => DOB_zd(12),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(12), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(13),
      GlitchData    => DOB_GlitchData13,
      OutSignalName => "DOB(13)",
      OutTemp       => DOB_zd(13),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(13), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(14),
      GlitchData    => DOB_GlitchData14,
      OutSignalName => "DOB(14)",
      OutTemp       => DOB_zd(14),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(14), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(15),
      GlitchData    => DOB_GlitchData15,
      OutSignalName => "DOB(15)",
      OutTemp       => DOB_zd(15),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(15), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(16),
      GlitchData    => DOB_GlitchData16,
      OutSignalName => "DOB(16)",
      OutTemp       => DOB_zd(16),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(16), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(17),
      GlitchData    => DOB_GlitchData17,
      OutSignalName => "DOB(17)",
      OutTemp       => DOB_zd(17),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(17), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(18),
      GlitchData    => DOB_GlitchData18,
      OutSignalName => "DOB(18)",
      OutTemp       => DOB_zd(18),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(18), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(19),
      GlitchData    => DOB_GlitchData19,
      OutSignalName => "DOB(19)",
      OutTemp       => DOB_zd(19),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(19), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(20),
      GlitchData    => DOB_GlitchData20,
      OutSignalName => "DOB(20)",
      OutTemp       => DOB_zd(20),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(20), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(21),
      GlitchData    => DOB_GlitchData21,
      OutSignalName => "DOB(21)",
      OutTemp       => DOB_zd(21),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(21), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(22),
      GlitchData    => DOB_GlitchData22,
      OutSignalName => "DOB(22)",
      OutTemp       => DOB_zd(22),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(22), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(23),
      GlitchData    => DOB_GlitchData23,
      OutSignalName => "DOB(23)",
      OutTemp       => DOB_zd(23),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(23), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(24),
      GlitchData    => DOB_GlitchData24,
      OutSignalName => "DOB(24)",
      OutTemp       => DOB_zd(24),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(24), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(25),
      GlitchData    => DOB_GlitchData25,
      OutSignalName => "DOB(25)",
      OutTemp       => DOB_zd(25),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(25), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(26),
      GlitchData    => DOB_GlitchData26,
      OutSignalName => "DOB(26)",
      OutTemp       => DOB_zd(26),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(26), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(27),
      GlitchData    => DOB_GlitchData27,
      OutSignalName => "DOB(27)",
      OutTemp       => DOB_zd(27),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(27), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(28),
      GlitchData    => DOB_GlitchData28,
      OutSignalName => "DOB(28)",
      OutTemp       => DOB_zd(28),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(28), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(29),
      GlitchData    => DOB_GlitchData29,
      OutSignalName => "DOB(29)",
      OutTemp       => DOB_zd(29),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(29), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(30),
      GlitchData    => DOB_GlitchData30,
      OutSignalName => "DOB(30)",
      OutTemp       => DOB_zd(30),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(30), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOB(31),
      GlitchData    => DOB_GlitchData31,
      OutSignalName => "DOB(31)",
      OutTemp       => DOB_zd(31),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOB(31), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOPB(0),
      GlitchData    => DOPB_GlitchData0,
      OutSignalName => "DOPB(0)",
      OutTemp       => DOPB_zd(0),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOPB(0), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOPB(1),
      GlitchData    => DOPB_GlitchData1,
      OutSignalName => "DOPB(1)",
      OutTemp       => DOPB_zd(1),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOPB(1), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOPB(2),
      GlitchData    => DOPB_GlitchData2,
      OutSignalName => "DOPB(2)",
      OutTemp       => DOPB_zd(2),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOPB(2), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);
    VitalPathDelay01 (
      OutSignal     => DOPB(3),
      GlitchData    => DOPB_GlitchData3,
      OutSignalName => "DOPB(3)",
      OutTemp       => DOPB_zd(3),
      Paths         => (0 => (CLKB_ipd'last_event, tpd_CLKB_DOPB(3), true)),
      Mode          => OnEvent,
      Xon           => Xon,
      MsgOn         => MsgOn,
      MsgSeverity   => warning);

    wait on ADDRA_ipd, ADDRB_ipd, CLKA_ipd, CLKB_ipd, DIA_ipd, DIB_ipd, DIPA_ipd, DIPB_ipd, ENA_ipd, ENB_ipd, SSRA_ipd, SSRB_ipd, WEA_ipd, WEB_ipd;
  end process VITALBehavior;
end RAMB16_S9_S36_V;
