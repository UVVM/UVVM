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
-- /___/   /\     Filename : BUFPLL_MCB.vhd
-- \   \  /  \    Timestamp : Thu Aug 14 21:02:18 PDT 2008
--  \___\/\___\
--
-- Revision:
--    08/15/08 - Initial version.
--    08/19/08 - IR 479918 fix ... added 100 ps latency to sequential paths.
--    11/04/09 - CR 537806  -- Removed extra timing arcs
--    06/02/10 - CR 563356  -- Added  ports GCLK, LOCKED and LOCK
--    06/10/10 - CR 564656  -- Fixed LOCK signal output 
-- End Revision

----- CELL BUFPLL_MCB -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


library unisim;
use unisim.vpkg.all;

entity BUFPLL_MCB is

  generic(

      DIVIDE        : integer := 2;    -- {1..8}
      LOCK_SRC : string := "LOCK_TO_0" -- {"LOCK_TO_0", "LOCK_TO_1"}
      );

  port(
      IOCLK0        : out std_ulogic;
      IOCLK1        : out std_ulogic;
      LOCK          : out std_ulogic;
      SERDESSTROBE0 : out std_ulogic;
      SERDESSTROBE1 : out std_ulogic;

      GCLK          : in  std_ulogic;
      LOCKED        : in  std_ulogic;
      PLLIN0        : in  std_ulogic;
      PLLIN1        : in  std_ulogic
    );

end BUFPLL_MCB;

architecture BUFPLL_MCB_V OF BUFPLL_MCB is


--  constant SYNC_PATH_DELAY : time := 100 ps;

  signal PLLIN0_ipd  : std_ulogic := 'X';
  signal PLLIN1_ipd  : std_ulogic := 'X';
  signal GCLK_ipd    : std_ulogic := 'X';
  signal LOCKED_ipd  : std_ulogic := 'X';
  signal PLLIN0_dly  : std_ulogic := 'X';
  signal PLLIN1_dly  : std_ulogic := 'X';
  signal GCLK_dly    : std_ulogic := 'X';
  signal LOCKED_dly  : std_ulogic := 'X';

  signal IOCLK0_zd        : std_ulogic := 'X';
  signal IOCLK1_zd        : std_ulogic := 'X';
  signal LOCK_zd          : std_ulogic := '0';
  signal SERDESSTROBE0_zd : std_ulogic := '0';
  signal SERDESSTROBE1_zd : std_ulogic := '0';


-- Counters
  signal ce0_count         : std_logic_vector(2 downto 0) := (others => '0');
  signal ce1_count         : std_logic_vector(2 downto 0) := (others => '0');
  signal edge0_count       : std_logic_vector(2 downto 0) := (others => '0');
  signal edge1_count       : std_logic_vector(2 downto 0) := (others => '0');
  signal RisingEdgeCount0  : std_logic_vector(2 downto 0) := (others => '0');
  signal RisingEdgeCount1  : std_logic_vector(2 downto 0) := (others => '0');
  signal FallingEdgeCount0 : std_logic_vector(2 downto 0) := (others => '0');
  signal FallingEdgeCount1 : std_logic_vector(2 downto 0) := (others => '0');
  signal TriggerOnRise0    : std_ulogic := '0';
  signal TriggerOnRise1    : std_ulogic := '0';

-- Flags
  signal allEqual0         : std_ulogic := '0';
  signal allEqual1         : std_ulogic := '0';
  signal RisingEdgeMatch0  : std_ulogic := '0';
  signal RisingEdgeMatch1  : std_ulogic := '0';
  signal FallingEdgeMatch0 : std_ulogic := '0';
  signal FallingEdgeMatch1 : std_ulogic := '0';

-- Attribute settings 
  signal lock_src_0_attr : std_ulogic := '0';
  signal lock_src_1_attr : std_ulogic := '0';


-- Internal signal
  signal DIVCLK_int	: std_ulogic := '0';
  signal match		: std_ulogic := '0';
  signal nmatch		: std_ulogic := '0';

-- Other signals
  signal Violation	: std_ulogic := '0';
begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  GCLK_dly       	 <= GCLK           ;
  LOCKED_dly     	 <= LOCKED         ;
  PLLIN0_dly     	 <= PLLIN0         ;
  PLLIN1_dly     	 <= PLLIN1         ;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process

  begin

-------------------------------------------------
------ DIVIDE Check
-------------------------------------------------

      if((DIVIDE = 1) or (DIVIDE = 2) or  (DIVIDE = 3) or
         (DIVIDE = 4) or (DIVIDE = 5) or  (DIVIDE = 6) or
         (DIVIDE = 7) or (DIVIDE = 8)) then
         case DIVIDE is
            when 1 => 
                       RisingEdgeCount0  <= "000"; 
                       FallingEdgeCount0 <= "000"; 
                       TriggerOnRise0    <= '1'; 
                       RisingEdgeCount1  <= "000"; 
                       FallingEdgeCount1 <= "000"; 
                       TriggerOnRise1    <= '1'; 
            when 2 => 
                       RisingEdgeCount0  <= "001"; 
                       FallingEdgeCount0 <= "000"; 
                       TriggerOnRise0    <= '1'; 
                       RisingEdgeCount1  <= "001"; 
                       FallingEdgeCount1 <= "000"; 
                       TriggerOnRise1    <= '1'; 
	    when 3 => 
                       RisingEdgeCount0  <= "010"; 
                       FallingEdgeCount0 <= "000"; 
                       TriggerOnRise0    <= '0'; 
                       RisingEdgeCount1  <= "010"; 
                       FallingEdgeCount1 <= "000"; 
                       TriggerOnRise1    <= '0'; 
            when 4 => 
                       RisingEdgeCount0  <= "011"; 
                       FallingEdgeCount0 <= "001"; 
                       TriggerOnRise0    <= '1'; 
                       RisingEdgeCount1  <= "011"; 
                       FallingEdgeCount1 <= "001"; 
                       TriggerOnRise1    <= '1'; 
            when 5 => 
                       RisingEdgeCount0  <= "100"; 
                       FallingEdgeCount0 <= "001"; 
                       TriggerOnRise0    <= '0'; 
                       RisingEdgeCount1  <= "100"; 
                       FallingEdgeCount1 <= "001"; 
                       TriggerOnRise1    <= '0'; 
            when 6 => 
                       RisingEdgeCount0  <= "101"; 
                       FallingEdgeCount0 <= "010"; 
                       TriggerOnRise0    <= '1'; 
                       RisingEdgeCount1  <= "101"; 
                       FallingEdgeCount1 <= "010"; 
                       TriggerOnRise1    <= '1'; 
            when 7 => 
                       RisingEdgeCount0  <= "110"; 
                       FallingEdgeCount0 <= "010"; 
                       TriggerOnRise0    <= '0'; 
                       RisingEdgeCount1  <= "110"; 
                       FallingEdgeCount1 <= "010"; 
                       TriggerOnRise1    <= '0'; 
            when 8 => 
                       RisingEdgeCount0  <= "111"; 
                       FallingEdgeCount0 <= "011"; 
                       TriggerOnRise0    <= '1'; 
                       RisingEdgeCount1  <= "111"; 
                       FallingEdgeCount1 <= "011"; 
                       TriggerOnRise1    <= '1'; 
            when others=>
                       null; 
         end case;
      else
         GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error ",
             GenericName => " DIVIDE ",
             EntityName => "/BUFPLL_MCB",
             GenericValue => DIVIDE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " 1, 2, 3, 4, 5, 6, 7, or 8 ",
             TailMsg => "",
             MsgSeverity => Failure
         );
--         attr_err_flag <= '1';
      end if;

-------------------------------------------------
------ LOCK_SRC Check
-------------------------------------------------
      if(LOCK_SRC = "LOCK_TO_0") then
         lock_src_0_attr  <= '1';
      elsif(LOCK_SRC = "LOCK_TO_1") then
         lock_src_1_attr  <= '1';
      else
         assert false
         report "Attribute Syntax Error: The attribute LOCK_SRC on BUFPLL_MCB is incorrect. Legal values for this attribute are LOCK_TO_0 or LOCK_TO_1."
         severity Failure;
      end if;

     wait;
  end process prcs_init;

--####################################################################
--#####         Count the rising edges of the clk0               #####
--####################################################################
  prcs_RiseEdgeCount0:process(PLLIN0_dly)
  begin
     if(rising_edge(PLLIN0_dly)) then
         if(allEqual0 = '1') then
            edge0_count <= "000";
         else
            edge0_count <= edge0_count + 1;
         end if;
     end if;
  end process prcs_RiseEdgeCount0;

  prcs_allEqual0:process(edge0_count)
  variable ce0_count_var  : std_logic_vector(2 downto 0) :=  CONV_STD_LOGIC_VECTOR(DIVIDE -1, 3);
  begin
     if(edge0_count = ce0_count_var) then
        allEqual0 <= '1';
     else
        allEqual0 <= '0';
     end if;
  end process prcs_allEqual0;

--####################################################################
--#####         Count the rising edges of the clk1               #####
--####################################################################
  prcs_RiseEdgeCount1:process(PLLIN1_dly)
  begin
     if(rising_edge(PLLIN1_dly)) then
         if(allEqual1 = '1') then
            edge1_count <= "000";
         else
            edge1_count <= edge1_count + 1;
         end if;
     end if;
  end process prcs_RiseEdgeCount1;

  prcs_allEqual1:process(edge1_count)
  variable ce1_count_var  : std_logic_vector(2 downto 0) :=  CONV_STD_LOGIC_VECTOR(DIVIDE -1, 3);
  begin
     if(edge1_count = ce1_count_var) then
        allEqual1 <= '1';
     else
        allEqual1 <= '0';
     end if;
  end process prcs_allEqual1;

--####################################################################
--#####          Generate SERDESSTROBE                          #####
--####################################################################

  prcs_SerdesStrobe0:process(PLLIN0_dly)
  begin
     if(rising_edge(PLLIN0_dly)) then
        if(LOCK_SRC = "LOCK_TO_0") then
           SERDESSTROBE0_zd <= allEqual0;
        else
           SERDESSTROBE0_zd <= SERDESSTROBE1_zd;
        end if;
     end if;
  end process prcs_SerdesStrobe0;
     
  prcs_SerdesStrobe1:process(PLLIN1_dly)
  begin
     if(rising_edge(PLLIN1_dly)) then
        if(LOCK_SRC = "LOCK_TO_1") then
           SERDESSTROBE1_zd <= allEqual1;
        else
           SERDESSTROBE1_zd <= SERDESSTROBE0_zd;
        end if;
     end if;
  end process prcs_SerdesStrobe1;

--####################################################################
--#####          Generate IOCLK                                  #####
--####################################################################

  IOCLK0_zd <= PLLIN0_dly;
  IOCLK1_zd <= PLLIN1_dly;

--####################################################################
--#####          Generate LOCK                                   #####
--####################################################################

  LOCK_zd <= LOCKED_dly;
     

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  IOCLK0          <= IOCLK0_zd;
  IOCLK1          <= IOCLK1_zd;
  LOCK            <= LOCK_zd; 
  SERDESSTROBE0   <= SERDESSTROBE0_zd after 100 ps;
  SERDESSTROBE1   <= SERDESSTROBE1_zd after 100 ps;

--####################################################################


end BUFPLL_MCB_V;

