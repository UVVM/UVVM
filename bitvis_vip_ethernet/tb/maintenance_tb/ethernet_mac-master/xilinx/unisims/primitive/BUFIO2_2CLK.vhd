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
-- /___/   /\     Filename : BUFIO2_2CLK.vhd
-- \   \  /  \    Timestamp : Fri Feb 22 15:43:23 PST 2008
--  \___\/\___\
--
-- Revision:
--    02/22/08 - Initial version.
--    08/19/08 - IR 479918 fix ... added 100 ps latency to sequential paths.
--    09/30/08 - IR 491038 fix ...  IOCLK is forwarded single clk.  
--    10/16/08 - Fixed Vital Timing
--    12/01/08 - IR 497760 fix 
--    02/25/09 - CR 509386 -- Added 100 ps delay to DIVCLK output
--    03/18/09 - CR 511597 -- Disallow DIVIDE=1
--    04/29/09 - CR 512001 -- Matched the hw latency at startup for various DIVIDEs
--    09/09/09 - CR 531517 -- Added I_INVERT feature -- Simprim Only
--    09/16/09 - CR 533710 -- Added defult return value to function 
--    12/08/09 - CR 540087 -- Aligned serdesstrobe to the falling edge of the divclk
--    02/18/10 - Revert back above CR
--    05/24/13 - CR 720291 -- remove divide 2, change default to 3.
-- End Revision

----- CELL BUFIO2_2CLK -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


library unisim;
use unisim.vpkg.all;

entity BUFIO2_2CLK is

  generic(

      DIVIDE        : integer := 3    -- {3..8}
      );

  port(
      DIVCLK       : out std_ulogic;
      IOCLK        : out std_ulogic;
      SERDESSTROBE : out std_ulogic;

      I            : in  std_ulogic;
      IB           : in  std_ulogic
    );

end BUFIO2_2CLK;

architecture BUFIO2_2CLK_V OF BUFIO2_2CLK is

-- CR 512001 -- added InitFunction
  function InitEdgeCount(divide_sz : in integer
          ) return  std_logic_vector is

  begin
       case divide_sz  is
           when 4|6|8 =>
              return CONV_STD_LOGIC_VECTOR(DIVIDE -1, 3);
           when 3|5|7 =>
              return CONV_STD_LOGIC_VECTOR(1, 3);
           when others =>
              return CONV_STD_LOGIC_VECTOR(DIVIDE -1, 3);
        end case;
  end;

  constant SYNC_PATH_DELAY : time := 100 ps;

  signal I_ipd       : std_ulogic := 'X';
  signal I_dly       : std_ulogic := 'X';
  signal IB_ipd       : std_ulogic := 'X';
  signal IB_dly       : std_ulogic := 'X';

  signal DIVCLK_zd		: std_ulogic := 'X';
  signal IOCLK_zd		: std_ulogic := 'X';
  signal SERDESSTROBE_zd	: std_ulogic := '0';


  signal DIVCLK_viol		: std_ulogic := 'X';
  signal IOCLK_viol		: std_ulogic := 'X';
  signal SERDESSTROBE_viol	: std_ulogic := 'X';

-- Counters
  signal ce_count         : std_logic_vector(2 downto 0) := (others => '0');
  signal edge_count       : std_logic_vector(2 downto 0) := InitEdgeCount(DIVIDE);
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

  signal i1_int       : std_ulogic := '0';
  signal i2_int       : std_ulogic := '0';
  signal i_int        : std_ulogic := '0';

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  I_dly          	 <= I              	after 0 ps;
  IB_dly         	 <= IB             	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process

  begin

      wait for 1 ps;
-------------------------------------------------
------ DIVIDE Check
-------------------------------------------------

      if((DIVIDE = 2) or  (DIVIDE = 3) or
         (DIVIDE = 4) or (DIVIDE = 5) or  (DIVIDE = 6) or
         (DIVIDE = 7) or (DIVIDE = 8)) then
         case DIVIDE is
--            when 1 => 
--                       RisingEdgeCount  <= "000"; 
--                       FallingEdgeCount <= "000"; 
--                       TriggerOnRise    <= '1'; 
--            when 2 => 
--                       RisingEdgeCount  <= "001"; 
--                       FallingEdgeCount <= "000"; 
--                       TriggerOnRise    <= '1'; 
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
             ExpectedGenericValue => " 3, 4, 5, 6, 7, or 8 ",
             TailMsg => "",
             MsgSeverity => Failure
         );
--         attr_err_flag <= '1';
      end if;

-------------------------------------------------
------ DIVIDE_BYPASS Check
-------------------------------------------------
      if(DIVIDE = 1)  then
           DivclkBypass_attr <= '1';
      else
           DivclkBypass_attr <= '0';
      end if;

     wait;
  end process prcs_init;


--####################################################################
--#####                     Clock doubler                        #####
--####################################################################
  prcs_ddr_dblr_i1:process(I_dly)
  begin
     if(rising_edge(I_dly)) then
        i1_int <= '1',
                  '0' after 100 ps;
     end if;
  end process prcs_ddr_dblr_i1;


  prcs_ddr_dblr_i2:process(IB_dly)
  begin
     if(rising_edge(IB_dly)) then
         i2_int <= '1',
                   '0' after 100 ps;
     end if;
  end process prcs_ddr_dblr_i2;

  i_int <= i1_int or i2_int;


--####################################################################
--#####         Count the rising edges of the clk                #####
--####################################################################
  prcs_RiseEdgeCount:process(i_int)
  begin
     if(rising_edge(i_int)) then
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

  prcs_SerdesStrobe:process(i_int)
  begin
     if(rising_edge(i_int)) then
        SERDESSTROBE_zd <= allEqual;
     end if;
  end process prcs_SerdesStrobe;
     
--####################################################################
--#####          Generate IOCLK                                  #####
--####################################################################

  IOCLK_zd <= I_dly;
     
--####################################################################
--#####          Generate Divided Clock                          #####
--####################################################################
-- CR 512001 -- added trigger at time 0 to match verilog
--  prcs_EdgeMatch:process(edge_count)
  prcs_EdgeMatch:process(edge_count, RisingEdgeCount)
  variable FIRST_TIME : boolean := true;
  begin
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
  end process prcs_EdgeMatch;

  prcs_match_nmatch:process(i_int)
  begin
     if(rising_edge(i_int)) then
-- FP
         match <= RisingEdgeMatch OR (match AND (NOT FallingEdgeMatch));
     elsif falling_edge(i_int) then
         if(TriggerOnRise = '0') then 
             nmatch <= match;
          else
             nmatch <= '0';
          end if;
     end if;
  end process prcs_match_nmatch;

  DIVCLK_int <= match or nmatch;

-- IR 497760 fix
  DIVCLK_zd  <= (DivclkBypass_attr and I_dly) or  (NOT DivclkBypass_attr and DIVCLK_int);  


--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  DIVCLK          <= DIVCLK_zd after 100 ps;
  IOCLK           <= IOCLK_zd;
  SERDESSTROBE    <= SERDESSTROBE_zd after 100 ps;
--####################################################################


end BUFIO2_2CLK_V;

