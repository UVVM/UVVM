-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                       Device DNA Data Access Port
-- /___/   /\     Filename : DNA_PORT.vhd
-- \   \  /  \    Timestamp : Mon Oct 10 15:21:52 PDT 2005
--  \___\/\___\
--
-- Revision:
--    10/10/05 - Initial version
--    27/05/08 - CR 472154 Removed Vital GSR constructs
--    06/04/08 - CR 472697 -- added check for SIM_DNA_VALUE bits [56:55] 
--    09/18/08 - CR 488646 -- added period check for unisim
--    10/28/08 - IR 494079 -- Shifting of dna_value is corrected to MSB first 
--    11/10/09 - CR 537739 -- Fixed DOUT to be high in READ mode
--    09/07/11 - CR 621903 -- Reinitialized buffer to dna_value when READ is asserted 
--    07/27/12 - Removed DRC warning for SIM_DNA_VALUE (CR 669726).
-- End Revision

----- CELL DNA_PORT -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.vpkg.all;

entity DNA_PORT is
  generic(

      SIM_DNA_VALUE : bit_vector := X"000000000000000"
      );

  port(
    DOUT  : out std_ulogic;

    CLK   : in std_ulogic;
    DIN   : in std_ulogic;
    READ  : in std_ulogic;
    SHIFT : in std_ulogic
    );

end DNA_PORT;

architecture DNA_PORT_V of DNA_PORT is


-----------------------------------------------------------
-----------------------------------------------------------
  function eval_init (
                         sim_dna_val : in  bit_vector;
                         msb         : in integer
              ) return std_logic_vector is
  variable ret_sim_dna_val : std_logic_vector (msb downto 0);
  variable tmp_sim_dna_val : std_logic_vector ((sim_dna_val'length-1) downto 0);
  begin
    if (sim_dna_val'length >= msb ) then
--        ret_sim_dna_val(msb downto 0)  := To_stdLogicVector(sim_dna_val((sim_dna_val'length-msb-1) to (sim_dna_val'length-1)));
        tmp_sim_dna_val((sim_dna_val'length-1) downto 0) := To_stdLogicVector(sim_dna_val);
        ret_sim_dna_val(msb downto 0) := tmp_sim_dna_val(msb downto 0);

    else
        ret_sim_dna_val := (others => '0');
        ret_sim_dna_val((sim_dna_val'length-1) downto 0) := To_stdLogicVector(sim_dna_val);
    end if;

    return ret_sim_dna_val(msb downto 0);
  end;
-----------------------------------------------------------
-----------------------------------------------------------

  constant MAX_DNA_BITS     : integer := 57;
  constant MSB_DNA_BITS     : integer := (MAX_DNA_BITS - 1);

  constant SYNC_PATH_DELAY      : time := 100 ps;

  signal        CLK_ipd          : std_ulogic := 'X';
  signal        DIN_ipd          : std_ulogic := 'X';
  signal        GSR              : std_ulogic := '0';
  signal        GSR_ipd          : std_ulogic := '0';
  signal        READ_ipd         : std_ulogic := 'X';
  signal        SHIFT_ipd        : std_ulogic := 'X';

  signal        CLK_dly          : std_ulogic := 'X';
  signal        DIN_dly          : std_ulogic := 'X';
  signal        GSR_dly          : std_ulogic := '0';
  signal        READ_dly         : std_ulogic := 'X';
  signal        SHIFT_dly        : std_ulogic := 'X';

  signal        DOUT_zd          : std_ulogic := 'X';

  signal        dna_val          : std_logic_vector(MSB_DNA_BITS downto 0) := eval_init(SIM_DNA_VALUE, MSB_DNA_BITS);

  signal	Violation        : std_ulogic := '0';

begin

  CLK_dly        	 <= CLK            	after 0 ps;
  DIN_dly        	 <= DIN            	after 0 ps;
  READ_dly       	 <= READ           	after 0 ps;
  SHIFT_dly      	 <= SHIFT          	after 0 ps;
  GSR_dly        	 <= GSR            	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                            READ                            ###
--####################################################################
  prcs_read:process(CLK_dly, GSR_dly, READ_dly, SHIFT_dly)
  variable        dna_val_var          : std_logic_vector(MSB_DNA_BITS downto 0) := eval_init(SIM_DNA_VALUE, MSB_DNA_BITS);
  begin
     if(GSR_dly = '1') then
        dna_val(0) <= '0';
     elsif(GSR_dly = '0') then
        if(rising_edge(CLK_dly)) then
           if(READ_dly = '1') then
-- CR 621903
                dna_val_var := eval_init(SIM_DNA_VALUE, MSB_DNA_BITS);
                DOUT_zd <= '1';
           elsif(READ_dly = '0') then
               if(SHIFT_dly = '1') then
-- IR 494079 
--                  dna_val <= DIN_dly & dna_val(MSB_DNA_BITS downto 1);
                  dna_val_var := dna_val_var((MSB_DNA_BITS - 1) downto 0) & DIN_dly;
                  DOUT_zd     <= dna_val_var(MSB_DNA_BITS);
               end if; -- SHIFT_dly = '1'   
           end if;  -- READ_dly = '1'  
        end if; -- rising_edge(CLK_dly)   
     end if; -- GSR_dly = '1'   
  end process prcs_read;

--####################################################################
--#####             Update Zero Delay Output                     #####
--####################################################################

-- IR 494079 
-- DOUT_zd <= dna_val(0);
-- CR 537739 
--   DOUT_zd <= dna_val(MSB_DNA_BITS);



--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(DOUT_zd)
  begin
      DOUT <= DOUT_zd after SYNC_PATH_DELAY;
  end process prcs_output;

end DNA_PORT_V;

