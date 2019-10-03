-------------------------------------------------------------------------------
-- Copyright (c) 1995/2010 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx TEST ONLY Simulation Library Component
--  /   /                  Delay Element
-- /___/   /\     Filename : ZHOLD_DELAY.vhd
-- \   \  /  \    Timestamp : Thu Apr 29 17:11:57 PDT 2010
--  \___\/\___\
--
-- Revision:
--    04/29/10 - Initial version.
--    04/29/11 - 607742 -- Changed IFF_DELAY_VALUE to IFF_DELAY_VALUE
--    07/11/11 - 616630 -- Change/Combine attributes
-- End Revision

----- CELL ZHOLD_DELAY -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;


library unisim;
use unisim.vpkg.all;

entity ZHOLD_DELAY is

  generic(
      ZHOLD_FABRIC              : string        := "DEFAULT";
      ZHOLD_IFF                 : string        := "DEFAULT"
      );

  port(
      DLYFABRIC	  : out std_ulogic;
      DLYIFF	  : out std_ulogic;

      DLYIN       : in  std_ulogic
      );

end ZHOLD_DELAY;

architecture ZHOLD_DELAY_V OF ZHOLD_DELAY is



-------------------- constants --------------------------

  constant	MAX_DELAY_COUNT		: integer := 31;
  constant	MIN_DELAY_COUNT		: integer := 0;

  constant	MAX_IFF_DELAY_COUNT	: integer := 31;
  constant	MIN_IFF_DELAY_COUNT	: integer := 0;

  constant 	TapDelay        	: time := 200.0 ps; 

  signal	DLYIN_ipd		: std_ulogic := 'X';
  signal	DLYIN_dly		: std_ulogic := 'X';

  signal	DLYFABRIC_zd		: std_ulogic := 'X';
  signal	DLYIFF_zd		: std_ulogic := 'X';

-- IDELAY_VALUE; 
  signal       idelay_count		: integer := 0;

-- IFF_DELAY_VALUE
  signal       iff_delay_count		: integer := 0;

  signal       tap_out_fabric		: std_ulogic := '0'; 
  signal       tap_out_iff		: std_ulogic := '0'; 

-------------- variable declaration -------------------------


  signal   delay_chain_0,  delay_chain_1,  delay_chain_2,  delay_chain_3,
           delay_chain_4,  delay_chain_5,  delay_chain_6,  delay_chain_7,
           delay_chain_8,  delay_chain_9,  delay_chain_10, delay_chain_11,
           delay_chain_12, delay_chain_13, delay_chain_14, delay_chain_15,
           delay_chain_16, delay_chain_17, delay_chain_18, delay_chain_19,
           delay_chain_20, delay_chain_21, delay_chain_22, delay_chain_23,
           delay_chain_24, delay_chain_25, delay_chain_26, delay_chain_27,
           delay_chain_28, delay_chain_29, delay_chain_30, delay_chain_31 : std_ulogic;

begin

  DLYIN_dly      	 <= DLYIN          	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process

  begin
     -------- ZHOLD_FABRIC check
     if(ZHOLD_FABRIC = "DEFAULT") then idelay_count <= 0;
     elsif(ZHOLD_FABRIC = "0")    then idelay_count <= 0;
     elsif(ZHOLD_FABRIC = "1")    then idelay_count <= 1;
     elsif(ZHOLD_FABRIC = "2")    then idelay_count <= 2;
     elsif(ZHOLD_FABRIC = "3")    then idelay_count <= 3;
     elsif(ZHOLD_FABRIC = "4")    then idelay_count <= 4;
     elsif(ZHOLD_FABRIC = "5")    then idelay_count <= 5;
     elsif(ZHOLD_FABRIC = "6")    then idelay_count <= 6;
     elsif(ZHOLD_FABRIC = "7")    then idelay_count <= 7;
     elsif(ZHOLD_FABRIC = "8")    then idelay_count <= 8;
     elsif(ZHOLD_FABRIC = "9")    then idelay_count <= 9;
     elsif(ZHOLD_FABRIC = "10")   then idelay_count <= 10;
     elsif(ZHOLD_FABRIC = "11")   then idelay_count <= 11;
     elsif(ZHOLD_FABRIC = "12")   then idelay_count <= 12;
     elsif(ZHOLD_FABRIC = "13")   then idelay_count <= 13;
     elsif(ZHOLD_FABRIC = "14")   then idelay_count <= 14;
     elsif(ZHOLD_FABRIC = "15")   then idelay_count <= 15;
     elsif(ZHOLD_FABRIC = "16")   then idelay_count <= 16;
     elsif(ZHOLD_FABRIC = "17")   then idelay_count <= 17;
     elsif(ZHOLD_FABRIC = "18")   then idelay_count <= 18;
     elsif(ZHOLD_FABRIC = "19")   then idelay_count <= 19;
     elsif(ZHOLD_FABRIC = "20")   then idelay_count <= 20;
     elsif(ZHOLD_FABRIC = "21")   then idelay_count <= 21;
     elsif(ZHOLD_FABRIC = "22")   then idelay_count <= 22;
     elsif(ZHOLD_FABRIC = "23")   then idelay_count <= 23;
     elsif(ZHOLD_FABRIC = "24")   then idelay_count <= 24;
     elsif(ZHOLD_FABRIC = "25")   then idelay_count <= 25;
     elsif(ZHOLD_FABRIC = "26")   then idelay_count <= 26;
     elsif(ZHOLD_FABRIC = "27")   then idelay_count <= 27;
     elsif(ZHOLD_FABRIC = "28")   then idelay_count <= 28;
     elsif(ZHOLD_FABRIC = "29")   then idelay_count <= 29;
     elsif(ZHOLD_FABRIC = "30")   then idelay_count <= 30;
     elsif(ZHOLD_FABRIC = "31")   then idelay_count <= 31;
     else
          assert false
          report "Attribute Syntax Error: The attribute ZHOLD_FABRIC on ZHOLD_DELAY must be set to DEFAULT, 0, ... 31 "
          severity Failure;
     end if;

     -------- ZHOLD_IFF check
     if(ZHOLD_IFF = "DEFAULT") then iff_delay_count <= 0;
     elsif(ZHOLD_IFF = "0")    then iff_delay_count <= 0;
     elsif(ZHOLD_IFF = "1")    then iff_delay_count <= 1;
     elsif(ZHOLD_IFF = "2")    then iff_delay_count <= 2;
     elsif(ZHOLD_IFF = "3")    then iff_delay_count <= 3;
     elsif(ZHOLD_IFF = "4")    then iff_delay_count <= 4;
     elsif(ZHOLD_IFF = "5")    then iff_delay_count <= 5;
     elsif(ZHOLD_IFF = "6")    then iff_delay_count <= 6;
     elsif(ZHOLD_IFF = "7")    then iff_delay_count <= 7;
     elsif(ZHOLD_IFF = "8")    then iff_delay_count <= 8;
     elsif(ZHOLD_IFF = "9")    then iff_delay_count <= 9;
     elsif(ZHOLD_IFF = "10")   then iff_delay_count <= 10;
     elsif(ZHOLD_IFF = "11")   then iff_delay_count <= 11;
     elsif(ZHOLD_IFF = "12")   then iff_delay_count <= 12;
     elsif(ZHOLD_IFF = "13")   then iff_delay_count <= 13;
     elsif(ZHOLD_IFF = "14")   then iff_delay_count <= 14;
     elsif(ZHOLD_IFF = "15")   then iff_delay_count <= 15;
     elsif(ZHOLD_IFF = "16")   then iff_delay_count <= 16;
     elsif(ZHOLD_IFF = "17")   then iff_delay_count <= 17;
     elsif(ZHOLD_IFF = "18")   then iff_delay_count <= 18;
     elsif(ZHOLD_IFF = "19")   then iff_delay_count <= 19;
     elsif(ZHOLD_IFF = "20")   then iff_delay_count <= 20;
     elsif(ZHOLD_IFF = "21")   then iff_delay_count <= 21;
     elsif(ZHOLD_IFF = "22")   then iff_delay_count <= 22;
     elsif(ZHOLD_IFF = "23")   then iff_delay_count <= 23;
     elsif(ZHOLD_IFF = "24")   then iff_delay_count <= 24;
     elsif(ZHOLD_IFF = "25")   then iff_delay_count <= 25;
     elsif(ZHOLD_IFF = "26")   then iff_delay_count <= 26;
     elsif(ZHOLD_IFF = "27")   then iff_delay_count <= 27;
     elsif(ZHOLD_IFF = "28")   then iff_delay_count <= 28;
     elsif(ZHOLD_IFF = "29")   then iff_delay_count <= 29;
     elsif(ZHOLD_IFF = "30")   then iff_delay_count <= 30;
     elsif(ZHOLD_IFF = "31")   then iff_delay_count <= 31;
     else
          assert false
          report "Attribute Syntax Error: The attribute ZHOLD_IFF on ZHOLD_DELAY must be set to DEFAULT, 0, ... 31 "
          severity Failure;
     end if;

     wait;
  end process prcs_init;
        
--####################################################################
--#####                      DELAY BUFFERS                       #####
--####################################################################
  delay_chain_0  <= transport DLYIN_dly;
  delay_chain_1  <= transport delay_chain_0  after TapDelay;
  delay_chain_2  <= transport delay_chain_1  after TapDelay;
  delay_chain_3  <= transport delay_chain_2  after TapDelay;
  delay_chain_4  <= transport delay_chain_3  after TapDelay;
  delay_chain_5  <= transport delay_chain_4  after TapDelay;
  delay_chain_6  <= transport delay_chain_5  after TapDelay;
  delay_chain_7  <= transport delay_chain_6  after TapDelay;
  delay_chain_8  <= transport delay_chain_7  after TapDelay;
  delay_chain_9  <= transport delay_chain_8  after TapDelay;
  delay_chain_10 <= transport delay_chain_9  after TapDelay;
  delay_chain_11 <= transport delay_chain_10  after TapDelay;
  delay_chain_12 <= transport delay_chain_11  after TapDelay;
  delay_chain_13 <= transport delay_chain_12  after TapDelay;
  delay_chain_14 <= transport delay_chain_13  after TapDelay;
  delay_chain_15 <= transport delay_chain_14  after TapDelay;
  delay_chain_16 <= transport delay_chain_15  after TapDelay;
  delay_chain_17 <= transport delay_chain_16  after TapDelay;
  delay_chain_18 <= transport delay_chain_17  after TapDelay;
  delay_chain_19 <= transport delay_chain_18  after TapDelay;
  delay_chain_20 <= transport delay_chain_19  after TapDelay;
  delay_chain_21 <= transport delay_chain_20  after TapDelay;
  delay_chain_22 <= transport delay_chain_21  after TapDelay;
  delay_chain_23 <= transport delay_chain_22  after TapDelay;
  delay_chain_24 <= transport delay_chain_23  after TapDelay;
  delay_chain_25 <= transport delay_chain_24  after TapDelay;
  delay_chain_26 <= transport delay_chain_25  after TapDelay;
  delay_chain_27 <= transport delay_chain_26  after TapDelay;
  delay_chain_28 <= transport delay_chain_27  after TapDelay;
  delay_chain_29 <= transport delay_chain_28  after TapDelay;
  delay_chain_30 <= transport delay_chain_29  after TapDelay;
  delay_chain_31 <= transport delay_chain_30  after TapDelay;

--####################################################################
--#####            Assign Fabric Tap Delays                      #####
--####################################################################
  prcs_AssignFabricDelays:process
  begin
           case idelay_count is
                when 0 =>    tap_out_fabric <= delay_chain_0;
                when 1 =>    tap_out_fabric <= delay_chain_1;
                when 2 =>    tap_out_fabric <= delay_chain_2;
                when 3 =>    tap_out_fabric <= delay_chain_3;
                when 4 =>    tap_out_fabric <= delay_chain_4;
                when 5 =>    tap_out_fabric <= delay_chain_5;
                when 6 =>    tap_out_fabric <= delay_chain_6;
                when 7 =>    tap_out_fabric <= delay_chain_7;
                when 8 =>    tap_out_fabric <= delay_chain_8;
                when 9 =>    tap_out_fabric <= delay_chain_9;
                when 10 =>   tap_out_fabric <= delay_chain_10;
                when 11 =>   tap_out_fabric <= delay_chain_11;
                when 12 =>   tap_out_fabric <= delay_chain_12;
                when 13 =>   tap_out_fabric <= delay_chain_13;
                when 14 =>   tap_out_fabric <= delay_chain_14;
                when 15 =>   tap_out_fabric <= delay_chain_15;
                when 16 =>   tap_out_fabric <= delay_chain_16;
                when 17 =>   tap_out_fabric <= delay_chain_17;
                when 18 =>   tap_out_fabric <= delay_chain_18;
                when 19 =>   tap_out_fabric <= delay_chain_19;
                when 20 =>   tap_out_fabric <= delay_chain_20;
                when 21 =>   tap_out_fabric <= delay_chain_21;
                when 22 =>   tap_out_fabric <= delay_chain_22;
                when 23 =>   tap_out_fabric <= delay_chain_23;
                when 24 =>   tap_out_fabric <= delay_chain_24;
                when 25 =>   tap_out_fabric <= delay_chain_25;
                when 26 =>   tap_out_fabric <= delay_chain_26;
                when 27 =>   tap_out_fabric <= delay_chain_27;
                when 28 =>   tap_out_fabric <= delay_chain_28;
                when 29 =>   tap_out_fabric <= delay_chain_29;
                when 30 =>   tap_out_fabric <= delay_chain_30;
                when 31 =>   tap_out_fabric <= delay_chain_31;
                when others =>
                    tap_out_fabric <= delay_chain_0;
           end case;

           wait on 
           delay_chain_0,  delay_chain_1,  delay_chain_2, delay_chain_3,
           delay_chain_4,  delay_chain_5,  delay_chain_6,  delay_chain_7,
           delay_chain_8,  delay_chain_9,  delay_chain_10, delay_chain_11,
           delay_chain_12, delay_chain_13, delay_chain_14, delay_chain_15,
           delay_chain_16, delay_chain_17, delay_chain_18, delay_chain_19,
           delay_chain_20, delay_chain_21, delay_chain_22, delay_chain_23,
           delay_chain_24, delay_chain_25, delay_chain_26, delay_chain_27,
           delay_chain_28, delay_chain_29, delay_chain_30, delay_chain_31,
           idelay_count;

  end process prcs_AssignFabricDelays;

--####################################################################
--#####               Assign IFF Tap Delays                      #####
--####################################################################
  prcs_AssignIffDelays:process
  begin
           case iff_delay_count is
                when 0 =>    tap_out_iff <= delay_chain_0;
                when 1 =>    tap_out_iff <= delay_chain_1;
                when 2 =>    tap_out_iff <= delay_chain_2;
                when 3 =>    tap_out_iff <= delay_chain_3;
                when 4 =>    tap_out_iff <= delay_chain_4;
                when 5 =>    tap_out_iff <= delay_chain_5;
                when 6 =>    tap_out_iff <= delay_chain_6;
                when 7 =>    tap_out_iff <= delay_chain_7;
                when 8 =>    tap_out_iff <= delay_chain_8;
                when 9 =>    tap_out_iff <= delay_chain_9;
                when 10 =>   tap_out_iff <= delay_chain_10;
                when 11 =>   tap_out_iff <= delay_chain_11;
                when 12 =>   tap_out_iff <= delay_chain_12;
                when 13 =>   tap_out_iff <= delay_chain_13;
                when 14 =>   tap_out_iff <= delay_chain_14;
                when 15 =>   tap_out_iff <= delay_chain_15;
                when 16 =>   tap_out_iff <= delay_chain_16;
                when 17 =>   tap_out_iff <= delay_chain_17;
                when 18 =>   tap_out_iff <= delay_chain_18;
                when 19 =>   tap_out_iff <= delay_chain_19;
                when 20 =>   tap_out_iff <= delay_chain_20;
                when 21 =>   tap_out_iff <= delay_chain_21;
                when 22 =>   tap_out_iff <= delay_chain_22;
                when 23 =>   tap_out_iff <= delay_chain_23;
                when 24 =>   tap_out_iff <= delay_chain_24;
                when 25 =>   tap_out_iff <= delay_chain_25;
                when 26 =>   tap_out_iff <= delay_chain_26;
                when 27 =>   tap_out_iff <= delay_chain_27;
                when 28 =>   tap_out_iff <= delay_chain_28;
                when 29 =>   tap_out_iff <= delay_chain_29;
                when 30 =>   tap_out_iff <= delay_chain_30;
                when 31 =>   tap_out_iff <= delay_chain_31;
                when others =>
                    tap_out_iff <= delay_chain_0;
           end case;
           wait on 
           delay_chain_0,  delay_chain_1,  delay_chain_2, delay_chain_3,
           delay_chain_4,  delay_chain_5,  delay_chain_6,  delay_chain_7,
           delay_chain_8,  delay_chain_9,  delay_chain_10, delay_chain_11,
           delay_chain_12, delay_chain_13, delay_chain_14, delay_chain_15,
           delay_chain_16, delay_chain_17, delay_chain_18, delay_chain_19,
           delay_chain_20, delay_chain_21, delay_chain_22, delay_chain_23,
           delay_chain_24, delay_chain_25, delay_chain_26, delay_chain_27,
           delay_chain_28, delay_chain_29, delay_chain_30, delay_chain_31,
           iff_delay_count;

  end process prcs_AssignIffDelays;

--####################################################################
--####################################################################
--#####                      OUTPUT  TAP                         #####
--####################################################################

   DLYFABRIC_zd		<= tap_out_fabric;
   DLYIFF_zd		<= tap_out_iff;


--####################################################################
--#####                           OUTPUT                         #####
--####################################################################
  prcs_output:process(DLYFABRIC_zd, DLYIFF_zd)
  begin
      DLYFABRIC    <= DLYFABRIC_zd;
      DLYIFF       <= DLYIFF_zd;
  end process prcs_output;


end ZHOLD_DELAY_V;

