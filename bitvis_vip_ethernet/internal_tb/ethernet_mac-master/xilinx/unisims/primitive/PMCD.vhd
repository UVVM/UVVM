-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Phase-Matched Clock Divider
-- /___/   /\     Filename : PMCD.vhd
-- \   \  /  \    Timestamp : Fri Mar 26 08:18:21 PST 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    06/20/07 - generate clka1d2 clka1d4 clka1d8 in same block to remove delta delay (CR440337)
--    04/03/08 - CR 467565 -- Div clocks toggle before REL goes high when EN_REL=TRUE
--    04/07/08 - CR 469973 -- Header Description fix
-- End Revision

----- CELL PMCD -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;


library unisim;
use unisim.vpkg.all;

entity PMCD is

  generic(
      EN_REL           : boolean := FALSE;
      RST_DEASSERT_CLK : string  := "CLKA"
      );

  port(
      CLKA1   : out std_ulogic;
      CLKA1D2 : out std_ulogic;
      CLKA1D4 : out std_ulogic;
      CLKA1D8 : out std_ulogic;
      CLKB1   : out std_ulogic;
      CLKC1   : out std_ulogic;
      CLKD1   : out std_ulogic;

      CLKA    : in  std_ulogic;
      CLKB    : in  std_ulogic;
      CLKC    : in  std_ulogic;
      CLKD    : in  std_ulogic;
      REL     : in  std_ulogic;
      RST     : in  std_ulogic
      );

end PMCD;

architecture PMCD_V OF PMCD is


  constant SYNC_PATH_DELAY	: time := 100 ps;

  signal CLKA_ipd		: std_ulogic := 'X';
  signal CLKB_ipd		: std_ulogic := 'X';
  signal CLKC_ipd		: std_ulogic := 'X';
  signal CLKD_ipd		: std_ulogic := 'X';

  signal REL_ipd		: std_ulogic := 'X';
  signal RST_ipd		: std_ulogic := 'X';

  signal CLKA_dly		: std_ulogic := 'X';
  signal CLKB_dly		: std_ulogic := 'X';
  signal CLKC_dly		: std_ulogic := 'X';
  signal CLKD_dly		: std_ulogic := 'X';

  signal REL_dly		: std_ulogic := 'X';
  signal RST_dly		: std_ulogic := 'X';

  signal CLKA1_zd		: std_ulogic := 'X';
  signal CLKA1D2_zd		: std_ulogic := 'X';
  signal CLKA1D4_zd		: std_ulogic := 'X';
  signal CLKA1D8_zd		: std_ulogic := 'X';
  signal CLKB1_zd		: std_ulogic := 'X';
  signal CLKC1_zd		: std_ulogic := 'X';
  signal CLKD1_zd		: std_ulogic := 'X';

  signal rel_clk_sel		: integer    := 0;
  signal rst_active    		: boolean;
  signal r1_out        		: std_ulogic;
  signal rdiv_out      		: std_ulogic;
  signal active_clk    		: std_ulogic := 'X';

  signal Violation_CLKA1        : std_ulogic := '0';
  signal Violation_CLKB1        : std_ulogic := '0';
  signal Violation_CLKC1        : std_ulogic := '0';
  signal Violation_CLKD1        : std_ulogic := '0';

  signal GSR_dly		: std_ulogic := '0';

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  CLKA_dly       	 <= CLKA           	after 0 ps;
  CLKB_dly       	 <= CLKB           	after 0 ps;
  CLKC_dly       	 <= CLKC           	after 0 ps;
  CLKD_dly       	 <= CLKD           	after 0 ps;
  REL_dly        	 <= REL            	after 0 ps;
  RST_dly        	 <= RST            	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  variable FIRST_TIME : boolean := true;
  begin
      if((RST_DEASSERT_CLK = "clka") or (RST_DEASSERT_CLK = "CLKA")) then
         rel_clk_sel <= 1;
      elsif((RST_DEASSERT_CLK = "clkb") or (RST_DEASSERT_CLK = "CLKB")) then
         rel_clk_sel <= 2;
      elsif((RST_DEASSERT_CLK = "clkc") or (RST_DEASSERT_CLK = "CLKC")) then
         rel_clk_sel <= 3;
      elsif((RST_DEASSERT_CLK = "clkd") or (RST_DEASSERT_CLK = "CLKD")) then
         rel_clk_sel <= 4;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " RST_DEASSERT_CLK ",
             EntityName => "/PMCD",
             GenericValue => RST_DEASSERT_CLK,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " CLKA, CLKB, CLKC or CLKD ",
             TailMsg => "",
             MsgSeverity => ERROR
         );
      end if;

      if(EN_REL = true) then
         rst_active <= false;
      elsif(EN_REL = false) then
         rst_active <= true;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " EN_REL ",
             EntityName => "/PMCD",
             GenericValue => EN_REL,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => "True or False",
             TailMsg => "",
             MsgSeverity => ERROR
         );
      end if;
     wait;
  end process prcs_init;
--####################################################################
--#####                           CLKA                           #####
--####################################################################
  prcs_clka:process(CLKA_dly, r1_out, rdiv_out, GSR_dly)
  variable first_time : boolean := true;
  begin
     if(GSR_dly = '1') then
         CLKA1_zd <= '0';
         CLKA1D2_zd <= '0';
         CLKA1D4_zd <= '0';
         CLKA1D8_zd <= '0';
     elsif(GSR_dly = '0') then

        if((first_time) and ((CLKA_dly = '0') or CLKA_dly = '1')) then
          CLKA1_zd <= CLKA_dly;
          CLKA1D2_zd <= CLKA_dly;
          CLKA1D4_zd <= CLKA_dly;
          CLKA1D8_zd <= CLKA_dly;
          first_time := false;
        end if;

        if(r1_out = '0') then
            CLKA1_zd <= CLKA_dly;
        elsif (r1_out = '1') then
          CLKA1_zd <= '0';
        end if;

        if(rdiv_out = '1') then
           CLKA1D2_zd <= '0';
           CLKA1D4_zd <= '0';
           CLKA1D8_zd <= '0';
        elsif(rdiv_out = '0') then
          if(rising_edge(CLKA_dly)) then
            CLKA1D2_zd <= NOT CLKA1D2_zd;
            if (CLKA1D2_zd = '0') then
                CLKA1D4_zd <= NOT CLKA1D4_zd;
                if (CLKA1D4_zd = '0') then
                    CLKA1D8_zd <= NOT CLKA1D8_zd;
                end if;
             end if;
          end if;
        end if;
     end if;
  end process prcs_clka;
--####################################################################
--#####                           CLKB                           #####
--####################################################################
 prcs_clkb:process(CLKB_dly, r1_out, GSR_dly)
  variable first_time : boolean := true;
  begin
     if((GSR_dly = '1') or (r1_out = '1')) then
          CLKB1_zd <= '0';
     elsif ((GSR_dly = '0') and (r1_out = '0')) then
           CLKB1_zd <= CLKB_dly;
     end if;
  end process prcs_clkb;
--####################################################################
--#####                           CLKC                           #####
--####################################################################
 prcs_clkc:process(CLKC_dly, r1_out, GSR_dly)
  variable first_time : boolean := true;
  begin
     if((GSR_dly = '1') or (r1_out = '1')) then
          CLKC1_zd <= '0';
     elsif ((GSR_dly = '0') and (r1_out = '0')) then
           CLKC1_zd <= CLKC_dly;
     end if;
  end process prcs_clkc;
--####################################################################
--#####                           CLKD                           #####
--####################################################################
 prcs_clkd:process(CLKD_dly, r1_out, GSR_dly)
  variable first_time : boolean := true;
  begin
     if((GSR_dly = '1') or (r1_out = '1')) then
          CLKD1_zd <= '0';
     elsif ((GSR_dly = '0') and (r1_out = '0')) then
           CLKD1_zd <= CLKD_dly;
     end if;
  end process prcs_clkd;
--####################################################################
--#####                       RST CLK SEL                        #####
--####################################################################
  prcs_rel_clk_mux:process(CLKA_dly, CLKB_dly, CLKC_dly, CLKD_dly)
  begin
      case rel_clk_sel is
             when 1 => active_clk <= CLKA_dly;
             when 2 => active_clk <= CLKB_dly;
             when 3 => active_clk <= CLKC_dly;
             when 4 => active_clk <= CLKD_dly;
             when others => null;
      end case;
  end process prcs_rel_clk_mux;

--####################################################################
--#####                     RELEASE SIGNAL                       #####
--####################################################################
  prcs_act_rel:process(active_clk, REL_dly, RST_dly, GSR_dly)
  variable released      : boolean := false;
  variable r1_released   : boolean := false;
  variable rdiv_released : boolean := false;
  variable start_rel_clk_count : boolean := false;
  variable rel_clk_count : integer := 0;
  variable path_1_clk_count : integer := 0;
  variable path_1        : std_ulogic := '1';
  variable path_2        : std_ulogic := '1';

  begin
      if((GSR_dly = '1') or (RST_dly = '1')) then
          released      := false;
          r1_released   := false;
          rdiv_released := false;
          rel_clk_count := 0;
          start_rel_clk_count := false;
          r1_out   <= '1';
          rdiv_out <= '1';
          path_1_clk_count := 0;
          path_1 := '1';
          path_2 := '1';
      elsif ((GSR_dly = '0') and (RST_dly = '0')) then
         if(rst_active) then
           if(not released) then
             if(rising_edge(active_clk)) then
              start_rel_clk_count := true;
             end if;
             if(active_clk'event and start_rel_clk_count) then
               rel_clk_count := rel_clk_count + 1;
             end if;
             if(rel_clk_count >= 1) then
                rdiv_out <= '0';
             end if;
             if(rel_clk_count >= 2) then
                r1_out   <= '0';
                released := true;
             end if;
           end if;
         elsif(not rst_active) then
           if(not r1_released) then
             if(rising_edge(active_clk)) then
              start_rel_clk_count := true;
             end if;
             if(active_clk'event and start_rel_clk_count) then
               rel_clk_count := rel_clk_count + 1;
             end if;
             if(rel_clk_count >= 2) then
                r1_out <= '0';
                r1_released := true;
             end if;
           end if;
           if(not rdiv_released) then
             if(rising_edge(active_clk)) then
               path_1_clk_count := path_1_clk_count + 1;
               if(path_1_clk_count >=  1) then
                path_1 := '0';
               end if;
             end if;

             if(rising_edge(REL_dly)) then
                path_2 := '0';
             end if;

             if((path_1 = '0') and (path_2 = '0')) then
                rdiv_out <= '0';
                rdiv_released := true;
             end if;
           end if;
         end if;
      end if;
  end process prcs_act_rel;
--####################################################################

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(CLKA1_zd, CLKA1D2_zd, CLKA1D4_zd, CLKA1D8_zd,
                      CLKB1_zd, CLKC1_zd, CLKD1_zd)
  begin
      CLKA1 <= CLKA1_zd after SYNC_PATH_DELAY;
      CLKA1D2 <= CLKA1D2_zd after SYNC_PATH_DELAY;
      CLKA1D4 <= CLKA1D4_zd after SYNC_PATH_DELAY;
      CLKA1D8 <= CLKA1D8_zd after SYNC_PATH_DELAY;

      CLKB1 <= CLKB1_zd after SYNC_PATH_DELAY;

      CLKC1 <= CLKC1_zd after SYNC_PATH_DELAY;

      CLKD1 <= CLKD1_zd after SYNC_PATH_DELAY;

  end process prcs_output;
--####################################################################


end PMCD_V;

