-------------------------------------------------------------------------------
-- Copyright (c) 1995/2010 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Differential Signaling Input Buffer
-- /___/   /\     Filename : IBUFDS_GTE2.vhd
-- \   \  /  \    Timestamp : Tue Jun  1 14:31:01 PDT 2010
--  \___\/\___\
--
-- Revision:
--    06/01/10 - Initial version.
--    09/12/11 - 624988 -- Changed CLKSWING_CFG from blooean to bits
--    02/13/12 - 645706 -- Changed defaulut value of CLKSWING_CFG to "11"
-- End Revision


----- CELL IBUFDS_GTE2 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.STD_LOGIC_arith.all;

library unisim;
use unisim.vpkg.all;



  entity IBUFDS_GTE2 is
    generic (
      CLKCM_CFG : boolean := TRUE;
      CLKRCV_TRST : boolean := TRUE;
      CLKSWING_CFG : bit_vector := "11"
    );

    port (
      O                    : out std_ulogic;
      ODIV2                : out std_ulogic;
      CEB                  : in std_ulogic;
      I                    : in std_ulogic;
      IB                   : in std_ulogic
    );
  end IBUFDS_GTE2;

  architecture IBUFDS_GTE2_V of IBUFDS_GTE2 is

  constant SYNC_PATH_DELAY : time := 100 ps;
  constant DIVIDE : integer := 2;

  signal CEB_ipd : std_ulogic := 'X';
  signal CEB_dly : std_ulogic := 'X';
  signal I_ipd  : std_ulogic := 'X';
  signal I_dly  : std_ulogic := 'X';
  signal IB_ipd : std_ulogic := 'X';
  signal IB_dly : std_ulogic := 'X';

  signal O_zd     : std_ulogic := 'X';
  signal ODIV2_zd : std_ulogic := 'X';



-- Counters
  signal ce_count         : std_logic_vector(2 downto 0) := (others => '0');
  signal edge_count       : std_logic_vector(2 downto 0) := (others => '0');

-- Flags
  signal allEqual         : std_ulogic := '0';


begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  CEB_dly        	 <= CEB            	after 0 ps;
  I_dly          	 <= I              	after 0 ps;
  IB_dly         	 <= IB             	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  variable AttrClkCmCfg_var             : std_ulogic := 'X';
  variable AttrClkRcvTrst_var           : std_ulogic := 'X';
  variable AttrClkSwingTrst_var           : std_ulogic := 'X';


  begin
-----------------------------------------------------------------
-------------------- CLKCM_CFG validity check -------------------
-----------------------------------------------------------------
      if(CLKCM_CFG = false) then
         AttrClkCmCfg_var := '0';
      elsif(CLKCM_CFG = true) then
         AttrClkCmCfg_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " CLKCM_CFG ",
             EntityName => "/IBUFDS_GTE2",
             GenericValue => CLKCM_CFG,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " TRUE or FALSE ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

-----------------------------------------------------------------
-------------------- CLKRCV_TRST validity check -----------------
-----------------------------------------------------------------
      if(CLKRCV_TRST = false) then
         AttrClkRcvTrst_var := '0';
      elsif(CLKRCV_TRST = true) then
         AttrClkRcvTrst_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " CLKRCV_TRST ",
             EntityName => "/IBUFDS_GTE2",
             GenericValue => CLKCM_CFG,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " TRUE or FALSE ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

-----------------------------------------------------------------
-------------------- CLKSWING_CFG validity check -------------------
-----------------------------------------------------------------
     if((CLKSWING_CFG = "00") OR
         (CLKSWING_CFG = "01") OR 
         (CLKSWING_CFG = "10") OR 
         (CLKSWING_CFG = "11")) then
         AttrClkSwingTrst_var := '0';
      else
         assert false
          report "Attribute Syntax Error: The legal values for attribute CLKSWING_CFG on IBUFDS_GTE2 are 00, 01, 10 or 11"
          severity Failure;
      end if;


     wait;
  end process prcs_init;

--####################################################################
--#####         Count the rising edges of the clk                #####
--####################################################################
  prcs_RiseEdgeCount:process(I_dly)
  begin
     if(rising_edge(I_dly)) then
         if(allEqual = '1') then
            edge_count <= "000";
         else
            edge_count <= edge_count + 1;
         end if;
     end if;
  end process prcs_RiseEdgeCount;

-- Generate synchronous reset after DIVIDE number of counts

  prcs_allEqual:process(edge_count)
  variable ce_count_var  : std_logic_vector(2 downto 0) :=  CONV_STD_LOGIC_VECTOR(DIVIDE -1, 3);
  begin
     if(edge_count = ce_count_var) then
        allEqual <= '1'; 
     else
        allEqual <= '0'; 
     end if;
  end process prcs_allEqual;

--####################################################################
--#####          Generate ODIV2                                  #####
--####################################################################

  prcs_SerdesStrobe:process(I_dly)
  begin
     if(rising_edge(I_dly)) then
        ODIV2_zd <= allEqual;
     end if;
  end process prcs_SerdesStrobe;
     
--####################################################################
--#####              Generate O                                  #####
--####################################################################

  O_zd <= I_dly and (not CEB_dly);
     

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  O          <= O_zd     after SYNC_PATH_DELAY;
  ODIV2      <= ODIV2_zd after SYNC_PATH_DELAY;
--####################################################################

  end IBUFDS_GTE2_V;
