-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  I/O Clock Buffer/Divider for the Spartan Series
-- /___/   /\     Filename : BUFIO2.vhd
-- \   \  /  \    Timestamp : Fri Feb 22 15:43:23 PST 2008
--  \___\/\___\
--
-- Revision:
--    02/22/08 - Initial version.
--    08/19/08 - IR 479918 fix ... added 100 ps latency to sequential paths.
--    09/03/08 - Added timing paths to unisim
--    10/16/08 - Added default timing to unisim
--    01/22/09 - Added attribute I_INVERT
--    02/03/09 - CR 506731 -- Add attribute USE_DOUBLER
--    02/15/09 - CR 508344 -- Fixed USE_DOUBLER effects
--    02/25/09 - CR 508344 -- Rework DIVCLK when DIVIDE=1 and USE_DOUBLER=TRUE
--                         -- Fixed IOCLK to be the same as I.
--    02/25/09 - CR 509386 -- Added 100 ps delay to DIVCLK output
--    03/12/09 - CR 511597 -- DRC check for invalid combination -- USE_DOUBLER=TRUE and DIVIDE=1
--    07/07/09 - CR 526436 -- DRC check for DIVIDE_BYPASS{TRUE}/DIVIDE{2...8} combinations
--    09/09/09 - CR 531517 -- DRC check for invalid combination --  USE_DOUBLER=TRUE and I_INVERT=TRUE
--    12/07/09 - CR 540087 -- Aligned serdesstrobe to the falling edge of the divclk
--    02/18/10 - Reverted back above CR 
--    02/18/10 - CR 556149 -- Changed DRC check (DIVIDE_BYPASS) and (DIVIDE /= 1)) to exit on assert 
--    05/25/10 - CR 561858 -- when DDR/DIVIDE=even #s, DIVCLK/SERDESSTROBE should rise 1/2 period sooner than the current version
--    06/17/10 - CR 565595 -- Fixed side effect of above CR -- SDR mode BVT failures.
--    05/24/13 - CR 720291 -- remove divide 2.
-- End Revision


----- CELL BUFIO2 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


library unisim;
use unisim.vpkg.all;

entity BUFIO2 is

  generic(

      DIVIDE_BYPASS : boolean := TRUE;  -- TRUE, FALSE
      DIVIDE        : integer := 1;     -- {1,3..8}
      I_INVERT      : boolean := FALSE; -- TRUE, FALSE
      USE_DOUBLER   : boolean := FALSE  -- TRUE, FALSE
      );

  port(
      DIVCLK       : out std_ulogic;
      IOCLK        : out std_ulogic;
      SERDESSTROBE : out std_ulogic;

      I            : in  std_ulogic
    );

end BUFIO2;

architecture BUFIO2_V OF BUFIO2 is

-- CR 561858  added InitFunction for various DIVIDE widths, the count is set differently to match the BUFIO2_2CLK's CR 512001
 
  function InitEdgeCount(
        use_doubler : in boolean;
        divide_sz : in integer

          ) return  std_logic_vector is

  begin
       if(use_doubler) then
       case divide_sz  is
           when 4|6|8 =>
              return CONV_STD_LOGIC_VECTOR(DIVIDE -1, 3);
           when 3|5|7 =>
              return CONV_STD_LOGIC_VECTOR(1, 3);
           when others =>
              return CONV_STD_LOGIC_VECTOR(DIVIDE -1, 3);
        end case;
      else
        return CONV_STD_LOGIC_VECTOR(0, 3);
     end if;
  end;

  constant SYNC_PATH_DELAY : time := 100 ps;

  signal I_ipd       : std_ulogic := 'X';

  signal I_dly       : std_ulogic := 'X';

  signal DIVCLK_zd		: std_ulogic := 'X';
  signal IOCLK_zd		: std_ulogic := 'X';
  signal SERDESSTROBE_zd	: std_ulogic := '0';


  signal DIVCLK_viol		: std_ulogic := 'X';
  signal IOCLK_viol		: std_ulogic := 'X';
  signal SERDESSTROBE_viol	: std_ulogic := 'X';

  signal  clk_period_found          : boolean := false;
  signal  clk_period                : time    := 0 ps;

-- Counters
  signal ce_count         : std_logic_vector(2 downto 0) := (others => '0');
  signal edge_count       : std_logic_vector(2 downto 0) := InitEdgeCount(USE_DOUBLER, DIVIDE);
  signal RisingEdgeCount  : std_logic_vector(2 downto 0) := (others => '0');
  signal FallingEdgeCount : std_logic_vector(2 downto 0) := (others => '0');
  signal TriggerOnRise    : std_ulogic := '0';

-- Flags
  signal allEqual         : std_ulogic := '0';
  signal RisingEdgeMatch  : std_ulogic := '0';
  signal FallingEdgeMatch : std_ulogic := '0';

-- Attribute settings 
  signal DivclkBypass_attr : std_ulogic := '0';

-- Internal signal
  signal DIVCLK_int		: std_ulogic := '0';
  signal match			: std_ulogic := '0';
  signal nmatch			: std_ulogic := '0';

  signal I_int			: std_ulogic := '0';

  signal i1_int			: std_ulogic := '0';
  signal i2_int			: std_ulogic := '0';
  signal I_inv			: std_ulogic := '0';
  signal div1_clk_dblr		: std_ulogic := '0';
  signal div1_clk		: std_ulogic := '0';

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  I_dly          	 <= I              	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process

  variable AttrIinvert_var    : std_ulogic := '0';
  variable AttrUseDoubler_var : std_ulogic := '0';

  begin

      wait for 1 ps;
-------------------------------------------------
------ DIVIDE Check
-------------------------------------------------

      if((DIVIDE = 1) or (DIVIDE = 3) or
         (DIVIDE = 4) or (DIVIDE = 5) or  (DIVIDE = 6) or
         (DIVIDE = 7) or (DIVIDE = 8)) then
         case DIVIDE is
            when 1 => 
                       RisingEdgeCount  <= "000"; 
                       FallingEdgeCount <= "000"; 
                       TriggerOnRise    <= '1'; 
 --           when 2 => 
 --                      RisingEdgeCount  <= "001"; 
 --                      FallingEdgeCount <= "000"; 
 --                      TriggerOnRise    <= '1'; 
	    when 3 => 
                       RisingEdgeCount  <= "010"; 
                       FallingEdgeCount <= "000"; 
                       TriggerOnRise    <= '0'; 
            when 4 => 
                       RisingEdgeCount  <= "011"; 
                       FallingEdgeCount <= "001"; 
                       TriggerOnRise    <= '1'; 
            when 5 => 
                       RisingEdgeCount  <= "100"; 
                       FallingEdgeCount <= "001"; 
                       TriggerOnRise    <= '0'; 
            when 6 => 
                       RisingEdgeCount  <= "101"; 
                       FallingEdgeCount <= "010"; 
                       TriggerOnRise    <= '1'; 
            when 7 => 
                       RisingEdgeCount  <= "110"; 
                       FallingEdgeCount <= "010"; 
                       TriggerOnRise    <= '0'; 
            when 8 => 
                       RisingEdgeCount  <= "111"; 
                       FallingEdgeCount <= "011"; 
                       TriggerOnRise    <= '1'; 
            when others=>
                       null; 
         end case;
      else
         GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error ",
             GenericName => " DIVIDE ",
             EntityName => "/BUFIO2",
             GenericValue => DIVIDE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " 1, 3, 4, 5, 6, 7, or 8 ",
             TailMsg => "",
             MsgSeverity => Failure
         );
--         attr_err_flag <= '1';
      end if;

-------------------------------------------------
------ DIVIDE_BYPASS Check
-------------------------------------------------
      if((DIVIDE_BYPASS) or (DIVIDE = 1))  then
           DivclkBypass_attr <= '1';
      else
           DivclkBypass_attr <= '0';
      end if;

-------------------------------------------------
------ I_INVERT Check
-------------------------------------------------
      if(I_INVERT = false) then
         AttrIinvert_var := '0';
      elsif(I_INVERT = true) then
         AttrIinvert_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " I_INVERT ",
             EntityName => "/BUFIO2",
             GenericValue => I_INVERT,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " TRUE or FALSE ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

-------------------------------------------------
------ USE_DOUBLER Check
-------------------------------------------------
      if(USE_DOUBLER = false) then
         AttrUseDoubler_var := '0';
      elsif(USE_DOUBLER = true) then
         AttrUseDoubler_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " USE_DOUBLER ",
             EntityName => "/BUFIO2",
             GenericValue => USE_DOUBLER,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " TRUE or FALSE ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;
-----------------------------------------------------------------------
------ DRC check for invalid combination USE_DOUBLER=TRUE and DIVIDE=1
-----------------------------------------------------------------------
      if((USE_DOUBLER) and (DIVIDE = 1)) then
        assert false
        report "DRC Error: The attribute USE_DOUBLER on BUFIO2 instance is set to TRUE when DIVIDE =1.";
        report "Legal values for DIVIDE when USE_DOUBLER = TRUE are: 4, 6, or 8."
        severity Failure;
      end if;

-----------------------------------------------------------------------
------ Invalid combination DRC check for DIVIDE_BYPASS = TRUE and DIVIDE={2..8}
-----------------------------------------------------------------------
-- CR 556149 -- Changed DRC check from "warning" to "failure".
      if((DIVIDE_BYPASS) and (DIVIDE /= 1)) then
        assert false
        report "DRC Error: The attribute DIVIDE_BYPASS on BUFIO2 instance must be set to FALSE for any DIVIDE value other than 1."
        severity Failure;
      end if;

-----------------------------------------------------------------------
------ DRC check for invalid combination USE_DOUBLER=TRUE and I_INVERT=TRUE
-----------------------------------------------------------------------
      if((USE_DOUBLER) and (I_INVERT)) then
        assert false
        report "DRC Error: The attribute I_INVERT on BUFIO2 instance is set to TRUE when USE_DOUBLER is set to TRUE.";
        report "I_INVERT must be set to FALSE  when USE_DOUBLER = TRUE."
        severity Failure;
      end if;

      wait;
  end process prcs_init;

--####################################################################
--#####                         I_INVERT                         #####
--####################################################################

  I_inv <= NOT I_dly when (I_INVERT) else I_dly;

--####################################################################
--#####                     Clock doubler                        #####
--####################################################################
  prcs_clk_dblr:process(I_inv)
  begin
     if(rising_edge(I_inv)) then
        i1_int <= '1',
                  '0' after 100 ps;
     elsif(falling_edge(I_inv)) then
        i2_int <= '1',
                  '0' after 100 ps;
     end if;
  end process prcs_clk_dblr;


  I_int <= (i1_int or i2_int) when USE_DOUBLER
            else I_inv;

--####################################################################
--#####         Count the rising edges of the clk                #####
--####################################################################
  prcs_RiseEdgeCount:process(I_int)
  variable first_time : boolean := true;
  variable current_time : time := 0 ps;
  begin
--     if(first_time) then
--        current_time := now;
--        if(USE_DOUBLER or ((current_time = 0 ps) and (I_int'event and (TO_X01(I_int) = '1') and (TO_X01(I_int'last_value) = 'X')))) then
--          edge_count <= "001";
--          first_time := false;
--         end if;
--     end if;

     if(rising_edge(I_int)) then
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
--#####          Generate IOCE                                   #####
--####################################################################

  prcs_SerdesStrobe:process(I_int)
  begin
     if(rising_edge(I_int)) then
        SERDESSTROBE_zd <= allEqual;
     end if;
  end process prcs_SerdesStrobe;
     
--####################################################################
--#####          Generate IOCLK                                  #####
--####################################################################

  IOCLK_zd <= I_inv;
     
--####################################################################
--#####          Generate Divided Clock                          #####
--####################################################################
  prcs_EdgeMatch:process(edge_count)
  variable FIRST_TIME : boolean := true;
  begin
     if(FIRST_TIME) then
       FIRST_TIME := false;
     else
        if(edge_count = RisingEdgeCount) then
            RisingEdgeMatch <= '1';
        else
            RisingEdgeMatch <= '0';
        end if;

        if(edge_count = FallingEdgeCount) then
            FallingEdgeMatch <= '1';
        else
            FallingEdgeMatch <= '0';
        end if;
     end if;
  end process prcs_EdgeMatch;

  prcs_match_nmatch:process(I_int)
  begin
     if(rising_edge(I_int)) then
-- FP
         match <= RisingEdgeMatch OR (match AND (NOT FallingEdgeMatch));
     elsif falling_edge(I_int) then
         if(TriggerOnRise = '0') then 
             nmatch <= match;
          else
             nmatch <= '0';
          end if;
     end if;
  end process prcs_match_nmatch;

  DIVCLK_int <= match or nmatch;

  DIVCLK_zd  <= I_int when ((DIVIDE = 1) or (DivclkBypass_attr = '1')) else
                   DIVCLK_int;




--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  DIVCLK          <= DIVCLK_zd after 100 ps;
  IOCLK           <= IOCLK_zd;
  SERDESSTROBE    <= SERDESSTROBE_zd after 100 ps;
--####################################################################


end BUFIO2_V;

