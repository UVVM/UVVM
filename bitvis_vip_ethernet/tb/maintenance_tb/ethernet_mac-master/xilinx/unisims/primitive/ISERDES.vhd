-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Source Synchronous Input Deserializer
-- /___/   /\     Filename : ISERDES.vhd
-- \   \  /  \    Timestamp : Fri Mar 26 08:18:20 PST 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    05/29/06 - CR 232324 -- Added  timing checks for SR/REV wrt negedge CLKDIV
--    07/19/06 - CR 234556 fix. Added sim_DELAY_D, sim_SETUP_D_CLK and sim_HOLD_D_CLK --FP
--    10/13/06 - CR 426606 fix
--    08/29/07 - CR 447556 Fixed attribute INTERFACE_TYPE to be case insensitive 
--    09/10/07 - CR 447760 Added Strict DRC for BITSLIP and INTERFACE_TYPE combinations
--    04/07/08 - CR 469973 -- Header Description fix
--    27/05/08 - CR 472154 Removed Vital GSR constructs
-- End Revision
----- CELL ISERDES -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;


library unisim;
use unisim.vpkg.all;
use unisim.vcomponents.all;

--//////////////////////////////////////////////////////////// 
--////////////////////////// BSCNTRL /////////////////////////
--//////////////////////////////////////////////////////////// 
entity bscntrl is
  generic(
      SRTYPE        : string;
      INIT_BITSLIPCNT	: bit_vector(3 downto 0)
      );
  port(
      CLKDIV_INT	: out std_ulogic;
      MUXC		: out std_ulogic;

      BITSLIP		: in std_ulogic;
      C23		: in std_ulogic;
      C45		: in std_ulogic;
      C67		: in std_ulogic;
      CLK		: in std_ulogic;
      CLKDIV		: in std_ulogic;
      DATA_RATE		: in std_ulogic;
      GSR		: in std_ulogic;
      R			: in std_ulogic;
      SEL		: in std_logic_vector (1 downto 0)
      );
           
end bscntrl;

architecture bscntrl_V of bscntrl is
--  constant DELAY_FFBSC		: time       := 300 ns;
--  constant DELAY_MXBSC		: time       := 60  ns;
  constant DELAY_FFBSC			: time       := 300 ps;
  constant DELAY_MXBSC			: time       := 60  ps;

  signal AttrSRtype		: integer := 0;

  signal q1			: std_ulogic := 'X';
  signal q2			: std_ulogic := 'X';
  signal q3			: std_ulogic := 'X';
  signal mux			: std_ulogic := 'X';
  signal qhc1			: std_ulogic := 'X';
  signal qhc2			: std_ulogic := 'X';
  signal qlc1			: std_ulogic := 'X';
  signal qlc2			: std_ulogic := 'X';
  signal qr1			: std_ulogic := 'X';
  signal qr2			: std_ulogic := 'X';
  signal mux1			: std_ulogic := 'X';
  signal clkdiv_zd		: std_ulogic := 'X';

begin
--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  begin

     if((SRTYPE = "ASYNC") or (SRTYPE = "async")) then
        AttrSrtype <= 0;
     elsif((SRTYPE = "SYNC") or (SRTYPE = "sync")) then
        AttrSrtype <= 1;
     end if;

     wait;
  end process prcs_init;
--####################################################################
--#####              Divide by 2 - 8 counter                     #####
--####################################################################
  prcs_div_2_8_cntr:process(qr2, CLK, GSR)
  variable clkdiv_int_var	:  std_ulogic := TO_X01(INIT_BITSLIPCNT(0));
  variable q1_var		:  std_ulogic := TO_X01(INIT_BITSLIPCNT(1));
  variable q2_var		:  std_ulogic := TO_X01(INIT_BITSLIPCNT(2));
  variable q3_var		:  std_ulogic := TO_X01(INIT_BITSLIPCNT(3));
  begin
     if(GSR = '1') then
         clkdiv_int_var	:= TO_X01(INIT_BITSLIPCNT(0));
         q1_var		:= TO_X01(INIT_BITSLIPCNT(1));
         q2_var		:= TO_X01(INIT_BITSLIPCNT(2));
         q3_var		:= TO_X01(INIT_BITSLIPCNT(3));
     elsif(GSR = '0') then
        case AttrSRtype is
           when 0 => 
           --------------- // async SET/RESET
                   if(qr2 = '1') then
                      clkdiv_int_var := '0';
                      q1_var := '0';
                      q2_var := '0';
                      q3_var := '0';
                   elsif (qhc1 = '1') then
                      clkdiv_int_var := clkdiv_int_var;
                      q1_var := q1_var;
                      q2_var := q2_var;
                      q3_var := q3_var;
                   else
                      if(rising_edge(CLK)) then
                         q3_var := q2_var;
                         q2_var :=( NOT((NOT clkdiv_int_var) and (NOT q2_var)) and q1_var);
                         q1_var := clkdiv_int_var;
                         clkdiv_int_var := mux;
                      end if;
                   end if;

           when 1 => 
           --------------- // sync SET/RESET
                   if(rising_edge(CLK)) then
                      if(qr2 = '1') then
                         clkdiv_int_var := '0';
                         q1_var := '0';
                         q2_var := '0';
                         q3_var := '0';
                      elsif (qhc1 = '1') then
                         clkdiv_int_var := clkdiv_int_var;
                         q1_var := q1_var;
                         q2_var := q2_var;
                         q3_var := q3_var;
                      else
                         q3_var := q2_var;
                         q2_var :=( NOT((NOT clkdiv_int_var) and (NOT q2_var)) and q1_var);
                         q1_var := clkdiv_int_var;
                         clkdiv_int_var := mux;
                      end if;
                   end if;

           when others => 
                   null;
           end case;


     end if;

     q1 <= q1_var after DELAY_FFBSC;
     q2 <= q2_var after DELAY_FFBSC;
     q3 <= q3_var after DELAY_FFBSC;
     clkdiv_zd <= clkdiv_int_var after DELAY_FFBSC;

  end process prcs_div_2_8_cntr;
--####################################################################
--#####          Divider selections and 4:1 selector mux         #####
--####################################################################
  prcs_mux_sel:process(sel, c23 , c45 , c67 , clkdiv_zd , q1 , q2 , q3)
  begin
    case sel is
        when "00" =>
              mux <= NOT (clkdiv_zd or  (c23 and q1)) after DELAY_MXBSC;
        when "01" =>
              mux <= NOT (q1 or (c45 and q2)) after DELAY_MXBSC;
        when "10" =>
              mux <= NOT (q2 or (c67 and q3)) after DELAY_MXBSC;
        when "11" =>
              mux <= NOT (q3) after DELAY_MXBSC;
        when others =>
              mux <= NOT (clkdiv_zd or  (c23 and q1)) after DELAY_MXBSC;
    end case;
  end process prcs_mux_sel;
--####################################################################
--#####                  Bitslip control logic                   #####
--####################################################################
  prcs_logictrl:process(qr1, clkdiv)
  begin
      case AttrSRtype is
          when 0 => 
           --------------- // async SET/RESET
               if(qr1 = '1') then
                 qlc1        <= '0' after DELAY_FFBSC;
                 qlc2        <= '0' after DELAY_FFBSC;
               elsif(bitslip = '0') then
                 qlc1        <= qlc1 after DELAY_FFBSC;
                 qlc2        <= '0'  after DELAY_FFBSC;
               else 
                   if(rising_edge(clkdiv)) then
                      qlc1      <= NOT qlc1 after DELAY_FFBSC;
                      qlc2      <= (bitslip and mux1) after DELAY_FFBSC;
                   end if;
               end if;

          when 1 => 
           --------------- // sync SET/RESET
               if(rising_edge(clkdiv)) then
                  if(qr1 = '1') then
                    qlc1        <= '0' after DELAY_FFBSC;
                    qlc2        <= '0' after DELAY_FFBSC;
                  elsif(bitslip = '0') then
                    qlc1        <= qlc1 after DELAY_FFBSC;
                    qlc2        <= '0'  after DELAY_FFBSC;
                  else 
                    qlc1      <= NOT qlc1 after DELAY_FFBSC;
                    qlc2      <= (bitslip and mux1) after DELAY_FFBSC;
                  end if;
               end if;
          when others => 
                  null;
      end case;
  end process  prcs_logictrl;

--####################################################################
--#####        Mux to select between sdr "0" and ddr "1"         #####
--####################################################################
  prcs_sdr_ddr_mux:process(qlc1, DATA_RATE)
  begin
    case DATA_RATE is
        when '0' =>
             mux1 <= qlc1 after DELAY_MXBSC;
        when '1' =>
             mux1 <= '1' after DELAY_MXBSC;
        when others =>
             null;
    end case;
  end process  prcs_sdr_ddr_mux;

--####################################################################
--#####                       qhc1 and qhc2                      #####
--####################################################################
  prcs_qhc1_qhc2:process(qr2, CLK)
  begin
-- FP TMP -- should CLK and q2 have to be rising_edge
     case AttrSRtype is
        when 0 => 
         --------------- // async SET/RESET
             if(qr2 = '1') then
                qhc1 <= '0' after DELAY_FFBSC;
                qhc2 <= '0' after DELAY_FFBSC;
             elsif(rising_edge(CLK)) then
                qhc1 <= (qlc2 and (NOT qhc2)) after DELAY_FFBSC;
                qhc2 <= qlc2 after DELAY_FFBSC;
             end if;

        when 1 => 
         --------------- // sync SET/RESET
             if(rising_edge(CLK)) then
                if(qr2 = '1') then
                   qhc1 <= '0' after DELAY_FFBSC;
                   qhc2 <= '0' after DELAY_FFBSC;
                else
                   qhc1 <= (qlc2 and (NOT qhc2)) after DELAY_FFBSC;
                   qhc2 <= qlc2 after DELAY_FFBSC;
                end if;
             end if;

        when others =>
             null;
     end case;

  end process  prcs_qhc1_qhc2;

--####################################################################
--#####     Mux drives ctrl lines of mux in front of 2nd rnk FFs  ####
--####################################################################
  prcs_muxc:process(mux1, DATA_RATE)
  begin
    case DATA_RATE is
        when '0' =>
             muxc <= mux1 after DELAY_MXBSC;
        when '1' =>
             muxc <= '0'  after DELAY_MXBSC;
        when others =>
             null;
    end case;
  end process  prcs_muxc;

--####################################################################
--#####                       Asynchronous set flops             #####
--####################################################################
  prcs_qr1:process(R, CLKDIV)
  begin
-- FP TMP -- should CLKDIV and R have to be rising_edge
     case AttrSRtype is
        when 0 => 
         --------------- // async SET/RESET
             if(R = '1') then
                qr1        <= '1' after DELAY_FFBSC;
             elsif(rising_edge(CLKDIV)) then
                qr1        <= '0' after DELAY_FFBSC;
             end if;

        when 1 => 
         --------------- // sync SET/RESET
             if(rising_edge(CLKDIV)) then
                if(R = '1') then
                   qr1        <= '1' after DELAY_FFBSC;
                else
                   qr1        <= '0' after DELAY_FFBSC;
                end if;
             end if;

        when others => 
             null;
     end case;
  end process  prcs_qr1;
----------------------------------------------------------------------
  prcs_qr2:process(R, CLK)
  begin
-- FP TMP -- should CLK and R have to be rising_edge
     case AttrSRtype is
        when 0 => 
         --------------- // async SET/RESET
             if(R = '1') then
                qr2        <= '1' after DELAY_FFBSC;
             elsif(rising_edge(CLK)) then
                qr2        <= qr1 after DELAY_FFBSC;
             end if;

        when 1 => 
         --------------- // sync SET/RESET
             if(rising_edge(CLK)) then
                if(R = '1') then
                   qr2        <= '1' after DELAY_FFBSC;
                else
                   qr2        <= qr1 after DELAY_FFBSC;
                end if;
             end if;

        when others => 
             null;
     end case;
  end process  prcs_qr2;
--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(clkdiv_zd)
  begin
      CLKDIV_INT <= clkdiv_zd;
  end process prcs_output;
--####################################################################
end bscntrl_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;


library unisim;
use unisim.vpkg.all;
use unisim.vcomponents.all;

--//////////////////////////////////////////////////////////// 
--//////////////////////// ICE MODULE ////////////////////////
--//////////////////////////////////////////////////////////// 

entity ice_module is
  generic(
      SRTYPE  : string;
      INIT_CE : bit_vector(1 downto 0)
      );
  port(
      ICE		: out std_ulogic;

      CE1		: in std_ulogic;
      CE2		: in std_ulogic;
      GSR		: in std_ulogic;
      NUM_CE		: in std_ulogic;
      CLKDIV		: in std_ulogic;
      R			: in std_ulogic
      );
end ice_module;

architecture ice_V of ice_module is
--  constant DELAY_FFICE		: time := 300 ns;
--  constant DELAY_MXICE		: time := 60 ns;
  constant DELAY_FFICE			: time := 300 ps;
  constant DELAY_MXICE			: time := 60 ps;

  signal AttrSRtype		: integer := 0;

  signal ce1r			: std_ulogic := 'X';
  signal ce2r			: std_ulogic := 'X';
  signal cesel			: std_logic_vector(1 downto 0) := (others => 'X');

  signal ice_zd			: std_ulogic := 'X';

begin

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  begin

     if((SRTYPE = "ASYNC") or (SRTYPE = "async")) then
        AttrSrtype <= 0;
     elsif((SRTYPE = "SYNC") or (SRTYPE = "sync")) then
        AttrSrtype <= 1;
     end if;

     wait;
  end process prcs_init;

--###################################################################
--#####                      update cesel                       #####
--###################################################################

  cesel  <= NUM_CE & CLKDIV; 

--####################################################################
--#####                         registers                        #####
--####################################################################
  prcs_reg:process(CLKDIV, GSR)
  variable ce1r_var		:  std_ulogic := TO_X01(INIT_CE(1));
  variable ce2r_var		:  std_ulogic := TO_X01(INIT_CE(0));
  begin
     if(GSR = '1') then
         ce1r_var		:= TO_X01(INIT_CE(1));
         ce2r_var		:= TO_X01(INIT_CE(0));
     elsif(GSR = '0') then
        case AttrSRtype is
           when 0 => 
            --------------- // async SET/RESET
                if(R = '1') then
                   ce1r_var := '0';
                   ce2r_var := '0';
                elsif(rising_edge(CLKDIV)) then
                   ce1r_var := ce1;
                   ce2r_var := ce2;
                end if;

           when 1 => 
            --------------- // sync SET/RESET
                if(rising_edge(CLKDIV)) then
                   if(R = '1') then
                      ce1r_var := '0';
                      ce2r_var := '0';
                   else
                      ce1r_var := ce1;
                      ce2r_var := ce2;
                   end if;
                end if;

           when others => 
                null;

        end case;
    end if;

   ce1r <= ce1r_var after DELAY_FFICE;
   ce2r <= ce2r_var after DELAY_FFICE;

  end process prcs_reg;
--####################################################################
--#####                        Output mux                        #####
--####################################################################
  prcs_mux:process(cesel, ce1, ce1r, ce2r)
  begin
    case cesel is
        when "00" =>
             ice_zd  <= ce1;
        when "01" =>
             ice_zd  <= ce1;
-- 426606
        when "10" =>
             ice_zd  <= ce2r;
        when "11" =>
             ice_zd  <= ce1r;
        when others =>
             null;
    end case;
  end process  prcs_mux;

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(ice_zd)
  begin
      ICE <= ice_zd;
  end process prcs_output;
end ice_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;


library unisim;
use unisim.vpkg.all;
use unisim.vcomponents.all;
use unisim.vcomponents.all;

----- CELL ISERDES -----
--//////////////////////////////////////////////////////////// 
--////////////////////////// ISERDES /////////////////////////
--//////////////////////////////////////////////////////////// 

entity ISERDES is

  generic(

      DDR_CLK_EDGE	: string	:= "SAME_EDGE_PIPELINED";
      INIT_BITSLIPCNT	: bit_vector(3 downto 0) := "0000";
      INIT_CE		: bit_vector(1 downto 0) := "00";
      INIT_RANK1_PARTIAL: bit_vector(4 downto 0) := "00000";
      INIT_RANK2	: bit_vector(5 downto 0) := "000000";
      INIT_RANK3	: bit_vector(5 downto 0) := "000000";
      SERDES		: boolean	:= TRUE;
      SRTYPE		: string	:= "ASYNC";

      BITSLIP_ENABLE	: boolean	:= false;
      DATA_RATE		: string	:= "DDR";
      DATA_WIDTH	: integer	:= 4;
      INIT_Q1		: bit		:= '0';
      INIT_Q2		: bit		:= '0';
      INIT_Q3		: bit		:= '0';
      INIT_Q4		: bit		:= '0';
      INTERFACE_TYPE	: string	:= "MEMORY";
      IOBDELAY		: string	:= "NONE";
      IOBDELAY_TYPE	: string	:= "DEFAULT";
      IOBDELAY_VALUE	: integer	:= 0;
      NUM_CE		: integer	:= 2;
      SERDES_MODE	: string	:= "MASTER";
      SRVAL_Q1		: bit		:= '0';
      SRVAL_Q2		: bit		:= '0';
      SRVAL_Q3		: bit		:= '0';
      SRVAL_Q4		: bit		:= '0'
      );

  port(
      O			: out std_ulogic;
      Q1		: out std_ulogic;
      Q2		: out std_ulogic;
      Q3		: out std_ulogic;
      Q4		: out std_ulogic;
      Q5		: out std_ulogic;
      Q6		: out std_ulogic;
      SHIFTOUT1		: out std_ulogic;
      SHIFTOUT2		: out std_ulogic;

      BITSLIP		: in std_ulogic;
      CE1		: in std_ulogic;
      CE2		: in std_ulogic;
      CLK		: in std_ulogic;
      CLKDIV		: in std_ulogic;
      D			: in std_ulogic;
      DLYCE		: in std_ulogic;
      DLYINC		: in std_ulogic;
      DLYRST		: in std_ulogic;
      OCLK		: in std_ulogic;
      REV		: in std_ulogic;
      SHIFTIN1		: in std_ulogic;
      SHIFTIN2		: in std_ulogic;
      SR		: in std_ulogic
    );

end ISERDES;

architecture ISERDES_V OF ISERDES is

component bscntrl
  generic (
      SRTYPE            : string;
      INIT_BITSLIPCNT	: bit_vector(3 downto 0)
    );
  port(
      CLKDIV_INT        : out std_ulogic;
      MUXC              : out std_ulogic;

      BITSLIP           : in std_ulogic;
      C23               : in std_ulogic;
      C45               : in std_ulogic;
      C67               : in std_ulogic;
      CLK               : in std_ulogic;
      CLKDIV            : in std_ulogic;
      DATA_RATE         : in std_ulogic;
      GSR               : in std_ulogic;
      R                 : in std_ulogic;
      SEL               : in std_logic_vector (1 downto 0)
      );
end component;

component ice_module
  generic(
      SRTYPE            : string;
      INIT_CE		: bit_vector(1 downto 0)
      );
  port(
      ICE		: out std_ulogic;

      CE1		: in std_ulogic;
      CE2		: in std_ulogic;
      GSR		: in std_ulogic;
      NUM_CE		: in std_ulogic;
      CLKDIV		: in std_ulogic;
      R			: in std_ulogic
      );
end component;

component IDELAY
  generic(
      IOBDELAY_VALUE : integer := 0;
      IOBDELAY_TYPE  : string  := "DEFAULT"
    );

  port(
      O      : out std_ulogic;

      C      : in  std_ulogic;
      CE     : in  std_ulogic;
       
      I      : in  std_ulogic;
      INC    : in  std_ulogic;
      RST    : in  std_ulogic
    );
end component;

--  constant DELAY_FFINP          : time       := 300 ns; 
--  constant DELAY_MXINP1         : time       := 60  ns;
--  constant DELAY_MXINP2         : time       := 120 ns;
--  constant DELAY_OCLKDLY        : time       := 750 ns;

  constant SYNC_PATH_DELAY      : time       := 100 ps; 

  constant DELAY_FFINP          : time       := 300 ps; 
  constant DELAY_MXINP1         : time       := 60  ps;
  constant DELAY_MXINP2         : time       := 120 ps;
  constant DELAY_OCLKDLY        : time       := 750 ps;

  constant MAX_DATAWIDTH	: integer    := 4;

  signal BITSLIP_ipd	        : std_ulogic := 'X';
  signal CE1_ipd	        : std_ulogic := 'X';
  signal CE2_ipd	        : std_ulogic := 'X';
  signal CLK_ipd	        : std_ulogic := 'X';
  signal CLKDIV_ipd		: std_ulogic := 'X';
  signal D_ipd			: std_ulogic := 'X';
  signal DLYCE_ipd		: std_ulogic := 'X';
  signal DLYINC_ipd		: std_ulogic := 'X';
  signal DLYRST_ipd		: std_ulogic := 'X';
  signal GSR			: std_ulogic := '0';
  signal GSR_ipd		: std_ulogic := 'X';
  signal OCLK_ipd		: std_ulogic := 'X';
  signal REV_ipd		: std_ulogic := 'X';
  signal SR_ipd			: std_ulogic := 'X';
  signal SHIFTIN1_ipd		: std_ulogic := 'X';
  signal SHIFTIN2_ipd		: std_ulogic := 'X';

  signal BITSLIP_dly	        : std_ulogic := 'X';
  signal CE1_dly	        : std_ulogic := 'X';
  signal CE2_dly	        : std_ulogic := 'X';
  signal CLK_dly	        : std_ulogic := 'X';
  signal CLKDIV_dly		: std_ulogic := 'X';
  signal D_dly			: std_ulogic := 'X';
  signal DLYCE_dly		: std_ulogic := 'X';
  signal DLYINC_dly		: std_ulogic := 'X';
  signal DLYRST_dly		: std_ulogic := 'X';
  signal GSR_dly		: std_ulogic := '0';
  signal OCLK_dly		: std_ulogic := 'X';
  signal REV_dly		: std_ulogic := 'X';
  signal SR_dly			: std_ulogic := 'X';
  signal SHIFTIN1_dly		: std_ulogic := 'X';
  signal SHIFTIN2_dly		: std_ulogic := 'X';


  signal O_zd			: std_ulogic := 'X';
  signal Q1_zd			: std_ulogic := 'X';
  signal Q2_zd			: std_ulogic := 'X';
  signal Q3_zd			: std_ulogic := 'X';
  signal Q4_zd			: std_ulogic := 'X';
  signal Q5_zd			: std_ulogic := 'X';
  signal Q6_zd			: std_ulogic := 'X';
  signal SHIFTOUT1_zd		: std_ulogic := 'X';
  signal SHIFTOUT2_zd		: std_ulogic := 'X';

  signal O_viol			: std_ulogic := 'X';
  signal Q1_viol		: std_ulogic := 'X';
  signal Q2_viol		: std_ulogic := 'X';
  signal Q3_viol		: std_ulogic := 'X';
  signal Q4_viol		: std_ulogic := 'X';
  signal Q5_viol		: std_ulogic := 'X';
  signal Q6_viol		: std_ulogic := 'X';
  signal SHIFTOUT1_viol		: std_ulogic := 'X';
  signal SHIFTOUT2_viol		: std_ulogic := 'X';

  signal AttrSerdes		: std_ulogic := 'X';
  signal AttrMode		: std_ulogic := 'X';
  signal AttrDataRate		: std_ulogic := 'X';
  signal AttrDataWidth		: std_logic_vector(3 downto 0) := (others => 'X');
  signal AttrInterfaceType	: std_ulogic := 'X';
  signal AttrBitslipEnable	: std_ulogic := 'X';
  signal AttrNumCe		: std_ulogic := 'X';
  signal AttrDdrClkEdge		: std_logic_vector(1 downto 0) := (others => 'X');
  signal AttrSRtype		: integer := 0;
  signal AttrIobDelay		: integer := 0;

  signal sel1			: std_logic_vector(1 downto 0) := (others => 'X');
  signal selrnk3		: std_logic_vector(3 downto 0) := (others => 'X');
  signal bsmux			: std_logic_vector(2 downto 0) := (others => 'X');
  signal cntr			: std_logic_vector(4 downto 0) := (others => 'X');
  
  signal q1rnk1			: std_ulogic := 'X';
  signal q2nrnk1		: std_ulogic := 'X';
  signal q5rnk1			: std_ulogic := 'X';
  signal q6rnk1			: std_ulogic := 'X';
  signal q6prnk1		: std_ulogic := 'X';

  signal q1prnk1		: std_ulogic := 'X';
  signal q2prnk1		: std_ulogic := 'X';
  signal q3rnk1			: std_ulogic := 'X';
  signal q4rnk1			: std_ulogic := 'X';

  signal dataq5rnk1		: std_ulogic := 'X';
  signal dataq6rnk1		: std_ulogic := 'X';

  signal dataq3rnk1		: std_ulogic := 'X';
  signal dataq4rnk1		: std_ulogic := 'X';

  signal oclkmux		: std_ulogic := '0';
  signal memmux			: std_ulogic := '0';
  signal q2pmux			: std_ulogic := '0';

  signal clkdiv_int		: std_ulogic := '0';
  signal clkdivmux		: std_ulogic := '0';

  signal q1rnk2			: std_ulogic := 'X';
  signal q2rnk2			: std_ulogic := 'X';
  signal q3rnk2			: std_ulogic := 'X';
  signal q4rnk2			: std_ulogic := 'X';
  signal q5rnk2			: std_ulogic := 'X';
  signal q6rnk2			: std_ulogic := 'X';
  signal dataq1rnk2		: std_ulogic := 'X';
  signal dataq2rnk2		: std_ulogic := 'X';
  signal dataq3rnk2		: std_ulogic := 'X';
  signal dataq4rnk2		: std_ulogic := 'X';
  signal dataq5rnk2		: std_ulogic := 'X';
  signal dataq6rnk2		: std_ulogic := 'X';

  signal muxc			: std_ulogic := 'X';

  signal q1rnk3			: std_ulogic := 'X';
  signal q2rnk3			: std_ulogic := 'X';
  signal q3rnk3			: std_ulogic := 'X';
  signal q4rnk3			: std_ulogic := 'X';
  signal q5rnk3			: std_ulogic := 'X';
  signal q6rnk3			: std_ulogic := 'X';

  signal c23			: std_ulogic := 'X';
  signal c45			: std_ulogic := 'X';
  signal c67			: std_ulogic := 'X';
  signal sel			: std_logic_vector(1 downto 0) := (others => 'X');

  signal ice			: std_ulogic := 'X';
  signal datain			: std_ulogic := 'X';
  signal idelay_out		: std_ulogic := 'X';

  signal CLKN_dly		: std_ulogic := '0';

begin

  BITSLIP_dly    	 <= BITSLIP        	after 0 ps;
  CE1_dly        	 <= CE1            	after 0 ps;
  CE2_dly        	 <= CE2            	after 0 ps;
  CLK_dly        	 <= CLK            	after 0 ps;
  CLKDIV_dly     	 <= CLKDIV         	after 0 ps;
  D_dly          	 <= D              	after 0 ps;
  DLYCE_dly      	 <= DLYCE          	after 0 ps;
  DLYINC_dly     	 <= DLYINC         	after 0 ps;
  DLYRST_dly     	 <= DLYRST         	after 0 ps;
  GSR_dly        	 <= GSR            	after 0 ps;
  OCLK_dly       	 <= OCLK           	after 0 ps;
  REV_dly        	 <= REV            	after 0 ps;
  SHIFTIN1_dly   	 <= SHIFTIN1       	after 0 ps;
  SHIFTIN2_dly   	 <= SHIFTIN2       	after 0 ps;
  SR_dly         	 <= SR             	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  variable AttrSerdes_var		: std_ulogic := 'X';
  variable AttrMode_var			: std_ulogic := 'X';
  variable AttrDataRate_var		: std_ulogic := 'X';
  variable AttrDataWidth_var		: std_logic_vector(3 downto 0) := (others => 'X');
  variable AttrInterfaceType_var	: std_ulogic := 'X';
  variable AttrBitslipEnable_var	: std_ulogic := 'X';
  variable AttrDdrClkEdge_var		: std_logic_vector(1 downto 0) := (others => 'X');
  variable AttrIobDelay_var		: integer := 0;

  begin

      --------CR 447760  DRC -- BITSLIP - INTERFACE_TYPE combination  ------------------

      if((INTERFACE_TYPE = "MEMORY") and (BITSLIP_ENABLE = TRUE)) then
        assert false
        report "Attribute Syntax Error: BITSLIP_ENABLE is currently set to TRUE when INTERFACE_TYPE is set to MEMORY. This is an invalid configuration."
        severity Failure;
     elsif((INTERFACE_TYPE = "NETWORKING") and (BITSLIP_ENABLE = FALSE)) then
        assert false
        report "Attribute Syntax Error: BITSLIP_ENABLE is currently set to FALSE when INTERFACE_TYPE is set to NETWORKING. If BITSLIP is not intended to be used, please set BITSLIP_ENABLE to TRUE and tie the BITSLIP port to ground."
        severity Failure;
     end if;

      -------------------- SERDES validity check --------------------
      if(SERDES = true) then
        AttrSerdes_var := '1';
      else
        AttrSerdes_var := '0';
      end if;

      ------------- SERDES_MODE validity check --------------------
      if((SERDES_MODE = "MASTER") or (SERDES_MODE = "master")) then
         AttrMode_var := '0';
      elsif((SERDES_MODE = "SLAVE") or (SERDES_MODE = "slave")) then
         AttrMode_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => "SERDES_MODE ",
             EntityName => "/ISERDES",
             GenericValue => SERDES_MODE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " MASTER or SLAVE.",
             TailMsg => "",
             MsgSeverity => FAILURE 
         );
      end if;

      ------------------ DATA_RATE validity check ------------------
      if((DATA_RATE = "DDR") or (DATA_RATE = "ddr")) then
         AttrDataRate_var := '0';
      elsif((DATA_RATE = "SDR") or (DATA_RATE = "sdr")) then
         AttrDataRate_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DATA_RATE ",
             EntityName => "/ISERDES",
             GenericValue => DATA_RATE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " DDR or SDR. ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

      ------------------ DATA_WIDTH validity check ------------------
      if((DATA_WIDTH = 2) or (DATA_WIDTH = 3) or  (DATA_WIDTH = 4) or
         (DATA_WIDTH = 5) or (DATA_WIDTH = 6) or  (DATA_WIDTH = 7) or
         (DATA_WIDTH = 8) or (DATA_WIDTH = 10)) then
         AttrDataWidth_var := CONV_STD_LOGIC_VECTOR(DATA_WIDTH, MAX_DATAWIDTH); 
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DATA_WIDTH ",
             EntityName => "/ISERDES",
             GenericValue => DATA_WIDTH,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " 2, 3, 4, 5, 6, 7, 8, or 10 ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;
      ------------ DATA_WIDTH /DATA_RATE combination check ------------
      if((DATA_RATE = "DDR") or (DATA_RATE = "ddr")) then
         case (DATA_WIDTH) is
             when 4|6|8|10  => null;
             when others       =>
                GenericValueCheckMessage
                (  HeaderMsg  => " Attribute Syntax Warning ",
                   GenericName => " DATA_WIDTH ",
                   EntityName => "/ISERDES",
                   GenericValue => DATA_WIDTH,
                   Unit => "",
                   ExpectedValueMsg => " The Legal values for DDR mode are ",
                   ExpectedGenericValue => " 4, 6, 8, or 10 ",
                   TailMsg => "",
                   MsgSeverity => Failure
                );
          end case;
      end if;

      if((DATA_RATE = "SDR") or (DATA_RATE = "sdr")) then
         case (DATA_WIDTH) is
             when 2|3|4|5|6|7|8  => null;
             when others       =>
                GenericValueCheckMessage
                (  HeaderMsg  => " Attribute Syntax Warning ",
                   GenericName => " DATA_WIDTH ",
                   EntityName => "/ISERDES",
                   GenericValue => DATA_WIDTH,
                   Unit => "",
                   ExpectedValueMsg => " The Legal values for SDR mode are ",
                   ExpectedGenericValue => " 2, 3, 4, 5, 6, 7 or 8",
                   TailMsg => "",
                   MsgSeverity => Failure
                );
          end case;
      end if;
      ---------------- INTERFACE_TYPE validity check ---------------
      if((INTERFACE_TYPE = "MEMORY") or (INTERFACE_TYPE = "memory")) then
         AttrInterfaceType_var := '0';
      elsif((INTERFACE_TYPE = "NETWORKING") or (INTERFACE_TYPE = "networking")) then
         AttrInterfaceType_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => "INTERFACE_TYPE ",
             EntityName => "/ISERDES",
             GenericValue => INTERFACE_TYPE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " MEMORY or NETWORKING.",
             TailMsg => "",
             MsgSeverity => FAILURE 
         );
      end if;

      ---------------- BITSLIP_ENABLE validity check -------------------
      if(BITSLIP_ENABLE = false) then
         AttrBitslipEnable_var := '0';
      elsif(BITSLIP_ENABLE = true) then
         AttrBitslipEnable_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " BITSLIP_ENABLE ",
             EntityName => "/ISERDES",
             GenericValue => BITSLIP_ENABLE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " TRUE or FALSE ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

      ----------------     NUM_CE validity check    -------------------
      case NUM_CE is
         when 1 =>
                AttrNumCe <= '0';
         when 2 =>
                AttrNumCe <= '1';
         when others =>
                GenericValueCheckMessage
                  (  HeaderMsg  => " Attribute Syntax Warning ",
                     GenericName => " NUM_CE ",
                     EntityName => "/ISERDES",
                     GenericValue => NUM_CE,
                     Unit => "",
                     ExpectedValueMsg => " The Legal values for this attribute are ",
                     ExpectedGenericValue => " 1 or 2 ",
                     TailMsg => "",
                     MsgSeverity => Failure
                  );
      end case;
      ----------------     IOBDELAY validity check  -------------------
      if((IOBDELAY = "NONE") or (IOBDELAY = "none")) then
         AttrIobDelay_var := 0;
      elsif((IOBDELAY = "IBUF") or (IOBDELAY = "ibuf")) then
         AttrIobDelay_var := 1;
      elsif((IOBDELAY = "IFD") or (IOBDELAY = "ifd")) then
         AttrIobDelay_var := 2;
      elsif((IOBDELAY = "BOTH") or (IOBDELAY = "both")) then
         AttrIobDelay_var := 3;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " IOBDELAY ",
             EntityName => "/ISERDES",
             GenericValue => IOBDELAY,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " NONE or IBUF or IFD or BOTH ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;
      ------------     IOBDELAY_VALUE validity check  -----------------
      ------------     IOBDELAY_TYPE validity check   -----------------
--
--
--
      ------------------ DDR_CLK_EDGE validity check ------------------
      if((DDR_CLK_EDGE = "SAME_EDGE_PIPELINED") or (DDR_CLK_EDGE = "same_edge_pipelined")) then
         AttrDdrClkEdge_var := "00";
      elsif((DDR_CLK_EDGE = "SAME_EDGE") or (DDR_CLK_EDGE = "same_edge")) then
         AttrDdrClkEdge_var := "01";
      elsif((DDR_CLK_EDGE = "OPPOSITE_EDGE") or (DDR_CLK_EDGE = "opposite_edge")) then
         AttrDdrClkEdge_var := "10";
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DDR_CLK_EDGE ",
             EntityName => "/ISERDES",
             GenericValue => DDR_CLK_EDGE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " SAME_EDGE_PIPELINED or SAME_EDGE or OPPOSITE_EDGE ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;
      ------------------ DATA_RATE validity check ------------------
      if((SRTYPE = "ASYNC") or (SRTYPE = "async")) then
         AttrSrtype <= 0;
      elsif((SRTYPE = "SYNC") or (SRTYPE = "sync")) then
         AttrSrtype <= 1;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " SRTYPE ",
             EntityName => "/ISERDES",
             GenericValue => SRTYPE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " ASYNC or SYNC. ",
             TailMsg => "",
             MsgSeverity => ERROR
         );
      end if;
---------------------------------------------------------------------

     AttrSerdes		<= AttrSerdes_var;
     AttrMode		<= AttrMode_var;
     AttrDataRate	<= AttrDataRate_var;
     AttrDataWidth	<= AttrDataWidth_var;
     AttrInterfaceType	<= AttrInterfaceType_var;
     AttrBitslipEnable	<= AttrBitslipEnable_var;
     AttrDdrClkEdge	<= AttrDdrClkEdge_var;
     AttrIobDelay	<= AttrIobDelay_var;

     sel1     <= AttrMode_var & AttrDataRate_var; 
     selrnk3  <= AttrSerdes_var & AttrBitslipEnable_var & AttrDdrClkEdge_var; 
     cntr     <= AttrDataRate_var & AttrDataWidth_var;

     wait;
  end process prcs_init;

--###################################################################
--#####               SHIFTOUT1 and SHIFTOUT2                   #####
--###################################################################

  SHIFTOUT2_zd <= q5rnk1;
  SHIFTOUT1_zd <= q6rnk1;

--###################################################################
--#####                     q1rnk1 reg                          #####
--###################################################################
  prcs_Q1_rnk1:process(CLK_dly, GSR_dly, REV_dly, SR_dly)
  variable q1rnk1_var         : std_ulogic := TO_X01(INIT_Q1);
  begin
     if(GSR_dly = '1') then
         q1rnk1_var  :=  TO_X01(INIT_Q1);
     elsif(GSR_dly = '0') then
        case AttrSRtype is
           when 0 => 
           --------------- // async SET/RESET
                   if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_Q1) = '1')))) then
                      q1rnk1_var := TO_X01(SRVAL_Q1);
                   elsif(REV_dly = '1') then
                      q1rnk1_var := not TO_X01(SRVAL_Q1);
                   elsif((SR_dly = '0') and (REV_dly = '0')) then
                      if(ice = '1') then
                         if(rising_edge(CLK_dly)) then
                            q1rnk1_var := datain;
                         end if;
                      end if;
                   end if;

           when 1 => 
           --------------- // sync SET/RESET
                   if(rising_edge(CLK_dly)) then
                      if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_Q1) = '1')))) then
                         q1rnk1_var := TO_X01(SRVAL_Q1);
                      Elsif(REV_dly = '1') then
                         q1rnk1_var := not TO_X01(SRVAL_Q1);
                      elsif((SR_dly = '0') and (REV_dly = '0')) then
                         if(ice = '1') then
                            q1rnk1_var := datain;
                         end if;
                      end if;
                   end if;

           when others =>
                   null;
                        
        end case;
     end if;

     q1rnk1  <= q1rnk1_var  after DELAY_FFINP;

  end process prcs_Q1_rnk1;
--###################################################################
--#####              q5rnk1, q6rnk1 and q6prnk1 reg             #####
--###################################################################
  prcs_Q5Q6Q6p_rnk1:process(CLK_dly, GSR_dly, SR_dly)
  variable q5rnk1_var         : std_ulogic := TO_X01(INIT_RANK1_PARTIAL(2));
  variable q6rnk1_var         : std_ulogic := TO_X01(INIT_RANK1_PARTIAL(1));
  variable q6prnk1_var        : std_ulogic := TO_X01(INIT_RANK1_PARTIAL(0));
  begin
     if(GSR_dly = '1') then
         q5rnk1_var  := TO_X01(INIT_RANK1_PARTIAL(2));
         q6rnk1_var  := TO_X01(INIT_RANK1_PARTIAL(1));
         q6prnk1_var := TO_X01(INIT_RANK1_PARTIAL(0));
     elsif(GSR_dly = '0') then
        case AttrSRtype is
           when 0 => 
           --------- // async SET/RESET  -- Not full featured FFs
                   if(SR_dly = '1') then
                      q5rnk1_var  := '0';
                      q6rnk1_var  := '0';
                      q6prnk1_var := '0';
                   elsif(SR_dly = '0') then
                      if(rising_edge(CLK_dly)) then
                         q5rnk1_var  := dataq5rnk1;
                         q6rnk1_var  := dataq6rnk1;
                         q6prnk1_var := q6rnk1;
                      end if;
                   end if;

           when 1 => 
           --------- // sync SET/RESET  -- Not full featured FFs
                   if(rising_edge(CLK_dly)) then
                      if(SR_dly = '1') then
                         q5rnk1_var  := '0';
                         q6rnk1_var  := '0';
                         q6prnk1_var := '0';
                      elsif(SR_dly = '0') then
                         q5rnk1_var  := dataq5rnk1;
                         q6rnk1_var  := dataq6rnk1;
                         q6prnk1_var := q6rnk1;
                      end if;
                   end if;

           when others =>
                   null;
                        
        end case;
     end if;

     q5rnk1  <= q5rnk1_var  after DELAY_FFINP;
     q6rnk1  <= q6rnk1_var  after DELAY_FFINP;
     q6prnk1 <= q6prnk1_var after DELAY_FFINP;

  end process prcs_Q5Q6Q6p_rnk1;
--###################################################################
--#####                     q2nrnk1 reg                          #####
--###################################################################
  prcs_Q2_rnk1:process(CLK_dly, GSR_dly, SR_dly, REV_dly)
  variable q2nrnk1_var         : std_ulogic := TO_X01(INIT_Q2);
  begin
     if(GSR_dly = '1') then
         q2nrnk1_var  := TO_X01(INIT_Q2);
     elsif(GSR_dly = '0') then
        case AttrSRtype is
           when 0 => 
           --------------- // async SET/RESET
                   if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_Q2) = '1')))) then
                      q2nrnk1_var  := TO_X01(SRVAL_Q2);
                   elsif(REV_dly = '1') then
                      q2nrnk1_var  := not TO_X01(SRVAL_Q2);
                   elsif((SR_dly = '0') and (REV_dly = '0')) then
                      if(ice = '1') then
                         if(falling_edge(CLK_dly)) then
                            q2nrnk1_var     := datain;
                         end if;
                      end if;
                   end if;

           when 1 => 
           --------------- // sync SET/RESET
                   if(falling_edge(CLK_dly)) then
                      if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_Q2) = '1')))) then
                         q2nrnk1_var  := TO_X01(SRVAL_Q2);
                      elsif(REV_dly = '1') then
                         q2nrnk1_var  := not TO_X01(SRVAL_Q2);
                      elsif((SR_dly = '0') and (REV_dly = '0')) then
                         if(ice = '1') then
                            q2nrnk1_var := datain;
                         end if;
                      end if;
                   end if;

           when others =>
                   null;
                        
        end case;
     end if;

     q2nrnk1  <= q2nrnk1_var after DELAY_FFINP;

  end process prcs_Q2_rnk1;
--###################################################################
--#####                       q2prnk1 reg                       #####
--###################################################################
  prcs_Q2p_rnk1:process(q2pmux, GSR_dly, REV_dly, SR_dly)
  variable q2prnk1_var        : std_ulogic := TO_X01(INIT_Q4);
  begin
     if(GSR_dly = '1') then
         q2prnk1_var := TO_X01(INIT_Q4);
     elsif(GSR_dly = '0') then
        case AttrSRtype is
           when 0 => 
           --------------- // async SET/RESET
                   if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_Q4) = '1')))) then
                      q2prnk1_var := TO_X01(SRVAL_Q4);
                   elsif(REV_dly = '1') then
                      q2prnk1_var := not TO_X01(SRVAL_Q4);
                   elsif((SR_dly = '0') and (REV_dly = '0')) then
                      if(ice = '1') then
                         if(rising_edge(q2pmux)) then
                            q2prnk1_var := q2nrnk1;
                         end if;
                      end if;
                   end if;

           when 1 => 
           --------------- // sync SET/RESET
                   if(rising_edge(q2pmux)) then
                      if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_Q4) = '1')))) then
                         q2prnk1_var := TO_X01(SRVAL_Q4);
                      elsif(REV_dly = '1') then
                         q2prnk1_var := not TO_X01(SRVAL_Q4);
                      elsif((SR_dly = '0') and (REV_dly = '0')) then
                         if(ice = '1') then
                              q2prnk1_var := q2nrnk1;
                         end if;
                      end if;
                   end if;

           when others =>
                   null;
                        
        end case;
     end if;

     q2prnk1  <= q2prnk1_var after DELAY_FFINP;

  end process prcs_Q2p_rnk1;
--###################################################################
--#####                      q1prnk1  reg                       #####
--###################################################################
  prcs_Q1p_rnk1:process(memmux, GSR_dly, REV_dly, SR_dly)
  variable q1prnk1_var        : std_ulogic := TO_X01(INIT_Q3);
  begin
     if(GSR_dly = '1') then
         q1prnk1_var := TO_X01(INIT_Q3);
     elsif(GSR_dly = '0') then
        case AttrSRtype is
           when 0 => 
           --------------- // async SET/RESET
                   if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_Q3) = '1')))) then
                      q1prnk1_var := TO_X01(SRVAL_Q3);
                   elsif(REV_dly = '1') then
                      q1prnk1_var := not TO_X01(SRVAL_Q3);
                   elsif((SR_dly = '0') and (REV_dly = '0')) then
                      if(ice = '1') then
                         if(rising_edge(memmux)) then
                            q1prnk1_var := q1rnk1;
                         end if;
                      end if;
                   end if;


           when 1 => 
           --------------- // sync SET/RESET
                   if(rising_edge(memmux)) then
                      if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_Q3) = '1')))) then
                         q1prnk1_var := TO_X01(SRVAL_Q3);
                      elsif(REV_dly = '1') then
                         q1prnk1_var := not TO_X01(SRVAL_Q3);
                      elsif((SR_dly = '0') and (REV_dly = '0')) then
                         if(ice = '1') then
                            q1prnk1_var := q1rnk1;
                         end if;
                      end if;
                   end if;

           when others =>
                   null;
                        
        end case;
     end if;

     q1prnk1  <= q1prnk1_var after DELAY_FFINP;

  end process prcs_Q1p_rnk1;
--###################################################################
--#####                  q3rnk1 and q4rnk1 reg                  #####
--###################################################################
  prcs_Q3Q4_rnk1:process(memmux, GSR_dly, SR_dly)
  variable q3rnk1_var         : std_ulogic := TO_X01(INIT_RANK1_PARTIAL(4));
  variable q4rnk1_var         : std_ulogic := TO_X01(INIT_RANK1_PARTIAL(3));
  begin
     if(GSR_dly = '1') then
         q3rnk1_var  := TO_X01(INIT_RANK1_PARTIAL(4));
         q4rnk1_var  := TO_X01(INIT_RANK1_PARTIAL(3));
     elsif(GSR_dly = '0') then
        case AttrSRtype is
           when 0 => 
           -------- // async SET/RESET  -- not fully featured FFs
                   if(SR_dly = '1') then
                      q3rnk1_var  := '0';
                      q4rnk1_var  := '0';
                   elsif(SR_dly = '0') then
                      if(rising_edge(memmux)) then
                         q3rnk1_var  := dataq3rnk1;
                         q4rnk1_var  := dataq4rnk1;
                      end if;
                   end if;

           when 1 => 
           -------- // sync SET/RESET -- not fully featured FFs
                   if(rising_edge(memmux)) then
                      if(SR_dly = '1') then
                         q3rnk1_var  := '0';
                         q4rnk1_var  := '0';
                      elsif(SR_dly = '0') then
                         q3rnk1_var  := dataq3rnk1;
                         q4rnk1_var  := dataq4rnk1;
                      end if;
                   end if;

           when others =>
                   null;
                        
        end case;
     end if;

     q3rnk1   <= q3rnk1_var after DELAY_FFINP;
     q4rnk1   <= q4rnk1_var after DELAY_FFINP;

  end process prcs_Q3Q4_rnk1;
--###################################################################
--#####        clock mux --  oclkmux with delay element         #####
--###################################################################
--  prcs_oclkmux:process(OCLK_dly)
--  begin
--     case AttrOclkDelay is
--           when '0' => 
--                    oclkmux <= OCLK_dly after DELAY_MXINP1;
--           when '1' => 
--                    oclkmux <= OCLK_dly after DELAY_OCLKDLY;
--           when others =>
--                    oclkmux <= OCLK_dly after DELAY_MXINP1;
--     end case;
--  end process prcs_oclkmux;
--
--
--
--///////////////////////////////////////////////////////////////////
--// Mux elements for the 1st Rank
--///////////////////////////////////////////////////////////////////
--###################################################################
--#####              memmux -- 4 clock muxes in first rank      #####
--###################################################################
  prcs_memmux:process(CLK_dly, OCLK_dly)
  begin
     case AttrInterfaceType is
           when '0' => 
                    memmux <= OCLK_dly after DELAY_MXINP1;
           when '1' => 
                    memmux <= CLK_dly after DELAY_MXINP1;
           when others =>
                    memmux <= OCLK_dly after DELAY_MXINP1;
     end case;
  end process prcs_memmux;

--###################################################################
--#####      q2pmux -- Optional inverter for q2p (4th flop in rank1)
--###################################################################
  prcs_q2pmux:process(memmux)
  begin
     case AttrInterfaceType is
           when '0' => 
                    q2pmux <= not memmux after DELAY_MXINP1;
           when '1' => 
                    q2pmux <= memmux after DELAY_MXINP1;
           when others =>
                    q2pmux <= memmux after DELAY_MXINP1;
     end case;
  end process prcs_q2pmux;
--###################################################################
--#####                data input muxes for q3q4  and q5q6      #####
--###################################################################
  prcs_Q3Q4_mux:process(q1prnk1, q2prnk1, q3rnk1, SHIFTIN1_dly, SHIFTIN2_dly)
  begin
     case sel1 is
           when "00" =>
                    dataq3rnk1 <= q1prnk1 after DELAY_MXINP1;
                    dataq4rnk1 <= q2prnk1 after DELAY_MXINP1;
           when "01" =>
                    dataq3rnk1 <= q1prnk1 after DELAY_MXINP1;
                    dataq4rnk1 <= q3rnk1  after DELAY_MXINP1;
           when "10" =>
                    dataq3rnk1 <= SHIFTIN2_dly after DELAY_MXINP1;
                    dataq4rnk1 <= SHIFTIN1_dly after DELAY_MXINP1;
           when "11" =>
                    dataq3rnk1 <= SHIFTIN1_dly after DELAY_MXINP1;
                    dataq4rnk1 <= q3rnk1   after DELAY_MXINP1;
           when others =>
                    dataq3rnk1 <= q1prnk1 after DELAY_MXINP1;
                    dataq4rnk1 <= q2prnk1 after DELAY_MXINP1;
     end case;

  end process prcs_Q3Q4_mux;
----------------------------------------------------------------------
  prcs_Q5Q6_mux:process(q3rnk1, q4rnk1, q5rnk1)
  begin
     case AttrDataRate is 
           when '0' =>
                    dataq5rnk1 <= q3rnk1 after DELAY_MXINP1;
                    dataq6rnk1 <= q4rnk1 after DELAY_MXINP1;
           when '1' =>
                    dataq5rnk1 <= q4rnk1 after DELAY_MXINP1;
                    dataq6rnk1 <= q5rnk1 after DELAY_MXINP1;
           when others =>
                    dataq5rnk1 <= q4rnk1 after DELAY_MXINP1;
                    dataq6rnk1 <= q5rnk1 after DELAY_MXINP1;
     end case;
  end process prcs_Q5Q6_mux;



---////////////////////////////////////////////////////////////////////
---                       2nd rank of registors
---////////////////////////////////////////////////////////////////////

--###################################################################
--#####    clkdivmux to choose between clkdiv_int or CLKDIV     #####
--###################################################################
  prcs_clkdivmux:process(clkdiv_int, CLKDIV_dly)
  begin
     case AttrBitslipEnable is
           when '0' =>
                    clkdivmux <= CLKDIV_dly after DELAY_MXINP1;
           when '1' =>
                    clkdivmux <= clkdiv_int after DELAY_MXINP1;
           when others =>
                    clkdivmux <= CLKDIV_dly after DELAY_MXINP1;
     end case;
  end process prcs_clkdivmux;

--###################################################################
--#####  q1rnk2, q2rnk2, q3rnk2,q4rnk2 ,q5rnk2 and q6rnk2 reg   #####
--###################################################################
  prcs_Q1Q2Q3Q4Q5Q6_rnk2:process(clkdivmux, GSR_dly, SR_dly)
  variable q1rnk2_var         : std_ulogic := TO_X01(INIT_RANK2(0));
  variable q2rnk2_var         : std_ulogic := TO_X01(INIT_RANK2(1));
  variable q3rnk2_var         : std_ulogic := TO_X01(INIT_RANK2(2));
  variable q4rnk2_var         : std_ulogic := TO_X01(INIT_RANK2(3));
  variable q5rnk2_var         : std_ulogic := TO_X01(INIT_RANK2(4));
  variable q6rnk2_var         : std_ulogic := TO_X01(INIT_RANK2(5));
  begin
     if(GSR_dly = '1') then
         q1rnk2_var := TO_X01(INIT_RANK2(0));
         q2rnk2_var := TO_X01(INIT_RANK2(1));
         q3rnk2_var := TO_X01(INIT_RANK2(2));
         q4rnk2_var := TO_X01(INIT_RANK2(3));
         q5rnk2_var := TO_X01(INIT_RANK2(4));
         q6rnk2_var := TO_X01(INIT_RANK2(5));
     elsif(GSR_dly = '0') then
        case AttrSRtype is
           when 0 => 
           --------------- // async SET/RESET
                   if(SR_dly = '1') then
                      q1rnk2_var := '0';
                      q2rnk2_var := '0';
                      q3rnk2_var := '0';
                      q4rnk2_var := '0';
                      q5rnk2_var := '0';
                      q6rnk2_var := '0';
                   elsif(SR_dly = '0') then
                       if(rising_edge(clkdivmux)) then
                           q1rnk2_var := dataq1rnk2;
                           q2rnk2_var := dataq2rnk2;
                           q3rnk2_var := dataq3rnk2;
                           q4rnk2_var := dataq4rnk2;
                           q5rnk2_var := dataq5rnk2;
                           q6rnk2_var := dataq6rnk2;
                       end if;
                   end if;

           when 1 => 
           --------------- // sync SET/RESET
                   if(rising_edge(clkdivmux)) then
                      if(SR_dly = '1') then
                         q1rnk2_var := '0';
                         q2rnk2_var := '0';
                         q3rnk2_var := '0';
                         q4rnk2_var := '0';
                         q5rnk2_var := '0';
                         q6rnk2_var := '0';
                      elsif(SR_dly = '0') then
                         q1rnk2_var := dataq1rnk2;
                         q2rnk2_var := dataq2rnk2;
                         q3rnk2_var := dataq3rnk2;
                         q4rnk2_var := dataq4rnk2;
                         q5rnk2_var := dataq5rnk2;
                         q6rnk2_var := dataq6rnk2;
                      end if;
                   end if;
           when others =>
                   null;
        end case;
     end if;

     q1rnk2  <= q1rnk2_var after DELAY_FFINP;
     q2rnk2  <= q2rnk2_var after DELAY_FFINP;
     q3rnk2  <= q3rnk2_var after DELAY_FFINP;
     q4rnk2  <= q4rnk2_var after DELAY_FFINP;
     q5rnk2  <= q5rnk2_var after DELAY_FFINP;
     q6rnk2  <= q6rnk2_var after DELAY_FFINP;

  end process prcs_Q1Q2Q3Q4Q5Q6_rnk2;

--###################################################################
--#####                    update bitslip mux                   #####
--###################################################################

  bsmux  <= AttrBitslipEnable & AttrDataRate & muxc; 

--###################################################################
--#####    Data mux for 2nd rank of registers                  ######
--###################################################################
  prcs_Q1Q2Q3Q4Q5Q6_rnk2_mux:process(bsmux, q1rnk1, q1prnk1, q2prnk1, 
                           q3rnk1, q4rnk1, q5rnk1, q6rnk1, q6prnk1)
  begin
     case bsmux is
        when "000" | "001" =>
                 dataq1rnk2 <= q2prnk1 after DELAY_MXINP2;
                 dataq2rnk2 <= q1prnk1 after DELAY_MXINP2;
                 dataq3rnk2 <= q4rnk1  after DELAY_MXINP2;
                 dataq4rnk2 <= q3rnk1  after DELAY_MXINP2;
                 dataq5rnk2 <= q6rnk1  after DELAY_MXINP2;
                 dataq6rnk2 <= q5rnk1  after DELAY_MXINP2;
        when "100"  =>
                 dataq1rnk2 <= q2prnk1 after DELAY_MXINP2;
                 dataq2rnk2 <= q1prnk1 after DELAY_MXINP2;
                 dataq3rnk2 <= q4rnk1  after DELAY_MXINP2;
                 dataq4rnk2 <= q3rnk1  after DELAY_MXINP2;
                 dataq5rnk2 <= q6rnk1  after DELAY_MXINP2;
                 dataq6rnk2 <= q5rnk1  after DELAY_MXINP2;
        when "101"  =>
                 dataq1rnk2 <= q1prnk1 after DELAY_MXINP2;
                 dataq2rnk2 <= q4rnk1  after DELAY_MXINP2;
                 dataq3rnk2 <= q3rnk1  after DELAY_MXINP2;
                 dataq4rnk2 <= q6rnk1  after DELAY_MXINP2;
                 dataq5rnk2 <= q5rnk1  after DELAY_MXINP2;
                 dataq6rnk2 <= q6prnk1 after DELAY_MXINP2;
        when "010" | "011" | "110" | "111" =>
                 dataq1rnk2 <= q1rnk1  after DELAY_MXINP2;
                 dataq2rnk2 <= q1prnk1 after DELAY_MXINP2;
                 dataq3rnk2 <= q3rnk1  after DELAY_MXINP2;
                 dataq4rnk2 <= q4rnk1  after DELAY_MXINP2;
                 dataq5rnk2 <= q5rnk1  after DELAY_MXINP2;
                 dataq6rnk2 <= q6rnk1  after DELAY_MXINP2;
        when others =>
                 dataq1rnk2 <= q2prnk1 after DELAY_MXINP2;
                 dataq2rnk2 <= q1prnk1 after DELAY_MXINP2;
                 dataq3rnk2 <= q4rnk1  after DELAY_MXINP2;
                 dataq4rnk2 <= q3rnk1  after DELAY_MXINP2;
                 dataq5rnk2 <= q6rnk1  after DELAY_MXINP2;
                 dataq6rnk2 <= q5rnk1  after DELAY_MXINP2;
     end case;
  end process prcs_Q1Q2Q3Q4Q5Q6_rnk2_mux;

---////////////////////////////////////////////////////////////////////
---                       3rd rank of registors
---////////////////////////////////////////////////////////////////////

--###################################################################
--#####  q1rnk3, q2rnk3, q3rnk3, q4rnk3, q5rnk3 and q6rnk3 reg   #####
--###################################################################
  prcs_Q1Q2Q3Q4Q5Q6_rnk3:process(CLKDIV_dly, GSR_dly, SR_dly)
  variable q1rnk3_var         : std_ulogic := TO_X01(INIT_RANK3(0));
  variable q2rnk3_var         : std_ulogic := TO_X01(INIT_RANK3(1));
  variable q3rnk3_var         : std_ulogic := TO_X01(INIT_RANK3(2));
  variable q4rnk3_var         : std_ulogic := TO_X01(INIT_RANK3(3));
  variable q5rnk3_var         : std_ulogic := TO_X01(INIT_RANK3(4));
  variable q6rnk3_var         : std_ulogic := TO_X01(INIT_RANK3(5));
  begin
     if(GSR_dly = '1') then
         q1rnk3_var := TO_X01(INIT_RANK3(0));
         q2rnk3_var := TO_X01(INIT_RANK3(1));
         q3rnk3_var := TO_X01(INIT_RANK3(2));
         q4rnk3_var := TO_X01(INIT_RANK3(3));
         q5rnk3_var := TO_X01(INIT_RANK3(4));
         q6rnk3_var := TO_X01(INIT_RANK3(5));
     elsif(GSR_dly = '0') then
        case AttrSRtype is
           when 0 => 
           --------------- // async SET/RESET
                   if(SR_dly = '1') then
                      q1rnk3_var := '0';
                      q2rnk3_var := '0';
                      q3rnk3_var := '0';
                      q4rnk3_var := '0';
                      q5rnk3_var := '0';
                      q6rnk3_var := '0';
                   elsif(SR_dly = '0') then
                       if(rising_edge(CLKDIV_dly)) then
                           q1rnk3_var := q1rnk2;
                           q2rnk3_var := q2rnk2;
                           q3rnk3_var := q3rnk2;
                           q4rnk3_var := q4rnk2;
                           q5rnk3_var := q5rnk2;
                           q6rnk3_var := q6rnk2;
                        end if;
                   end if;

           when 1 => 
           --------------- // sync SET/RESET
                   if(rising_edge(CLKDIV_dly)) then
                      if(SR_dly = '1') then
                         q1rnk3_var := '0';
                         q2rnk3_var := '0';
                         q3rnk3_var := '0';
                         q4rnk3_var := '0';
                         q5rnk3_var := '0';
                         q6rnk3_var := '0';
                      elsif(SR_dly = '0') then
                         q1rnk3_var := q1rnk2;
                         q2rnk3_var := q2rnk2;
                         q3rnk3_var := q3rnk2;
                         q4rnk3_var := q4rnk2;
                         q5rnk3_var := q5rnk2;
                         q6rnk3_var := q6rnk2;
                      end if;
                   end if;
           when others =>
                   null;
        end case;
     end if;

     q1rnk3  <= q1rnk3_var after DELAY_FFINP;
     q2rnk3  <= q2rnk3_var after DELAY_FFINP;
     q3rnk3  <= q3rnk3_var after DELAY_FFINP;
     q4rnk3  <= q4rnk3_var after DELAY_FFINP;
     q5rnk3  <= q5rnk3_var after DELAY_FFINP;
     q6rnk3  <= q6rnk3_var after DELAY_FFINP;

  end process prcs_Q1Q2Q3Q4Q5Q6_rnk3;

---////////////////////////////////////////////////////////////////////
---                       Outputs
---////////////////////////////////////////////////////////////////////
  prcs_Q1Q2_rnk3_mux:process(q1rnk1, q1prnk1, q1rnk2, q1rnk3,  
                           q2nrnk1, q2prnk1, q2rnk2, q2rnk3)
  begin
     case selrnk3 is
        when "0000" | "0100" | "0X00" =>
                 Q1_zd <= q1prnk1 after DELAY_MXINP1;
                 Q2_zd <= q2prnk1 after DELAY_MXINP1;
        when "0001" | "0101" | "0X01" =>
                 Q1_zd <= q1rnk1  after DELAY_MXINP1;
                 Q2_zd <= q2prnk1 after DELAY_MXINP1;
        when "0010" | "0110" | "0X10" =>
                 Q1_zd <= q1rnk1  after DELAY_MXINP1;
                 Q2_zd <= q2nrnk1 after DELAY_MXINP1;
        when "1000" | "1001" | "1010" | "1011" | "10X0" | "10X1" |
             "100X" | "101X" | "10XX" =>
                 Q1_zd <= q1rnk2 after DELAY_MXINP1;
                 Q2_zd <= q2rnk2 after DELAY_MXINP1;
        when "1100" | "1101" | "1110" | "1111" | "11X0" | "11X1" |
             "110X" | "111X" | "11XX" =>
                 Q1_zd <= q1rnk3 after DELAY_MXINP1;
                 Q2_zd <= q2rnk3 after DELAY_MXINP1;
        when others =>
                 Q1_zd <= q1rnk2 after DELAY_MXINP1;
                 Q2_zd <= q2rnk2 after DELAY_MXINP1;
     end case;
  end process prcs_Q1Q2_rnk3_mux;
--------------------------------------------------------------------
  prcs_Q3Q4Q5Q6_rnk3_mux:process(q3rnk2, q3rnk3, q4rnk2, q4rnk3,  
                                 q5rnk2, q5rnk3, q6rnk2, q6rnk3)
  begin
     case AttrBitslipEnable is
        when '0'  =>
                 Q3_zd <= q3rnk2 after DELAY_MXINP1;
                 Q4_zd <= q4rnk2 after DELAY_MXINP1;
                 Q5_zd <= q5rnk2 after DELAY_MXINP1;
                 Q6_zd <= q6rnk2 after DELAY_MXINP1;
        when '1'  =>
                 Q3_zd <= q3rnk3 after DELAY_MXINP1;
                 Q4_zd <= q4rnk3 after DELAY_MXINP1;
                 Q5_zd <= q5rnk3 after DELAY_MXINP1;
                 Q6_zd <= q6rnk3 after DELAY_MXINP1;
        when others =>
                 Q3_zd <= q3rnk2 after DELAY_MXINP1;
                 Q4_zd <= q4rnk2 after DELAY_MXINP1;
                 Q5_zd <= q5rnk2 after DELAY_MXINP1;
                 Q6_zd <= q6rnk2 after DELAY_MXINP1;
     end case;
  end process prcs_Q3Q4Q5Q6_rnk3_mux;
----------------------------------------------------------------------
-----------    Inverted CLK  -----------------------------------------
----------------------------------------------------------------------

  CLKN_dly <= not CLK_dly;

----------------------------------------------------------------------
-----------    Instant BSCNTRL  --------------------------------------
----------------------------------------------------------------------
  INST_BSCNTRL : BSCNTRL
  generic map (
      SRTYPE => SRTYPE,
      INIT_BITSLIPCNT => INIT_BITSLIPCNT
     )
  port map (
      CLKDIV_INT => clkdiv_int,
      MUXC       => muxc,

      BITSLIP    => BITSLIP_dly,
      C23        => c23,
      C45        => c45,
      C67        => c67,
      CLK        => CLKN_dly,
      CLKDIV     => CLKDIV_dly,
      DATA_RATE  => AttrDataRate,
      GSR        => GSR_dly,
      R          => SR_dly,
      SEL        => sel
      );

--###################################################################
--#####           Set value of the counter in BSCNTRL           ##### 
--###################################################################
  prcs_bscntrl_cntr:process
  begin
     wait for 10 ps;
     case cntr is
        when "00100" =>
                 c23<='0'; c45<='0'; c67<='0'; sel<="00";
        when "00110" =>
                 c23<='1'; c45<='0'; c67<='0'; sel<="00";
        when "01000" =>
                 c23<='0'; c45<='0'; c67<='0'; sel<="01";
        when "01010" =>
                 c23<='0'; c45<='1'; c67<='0'; sel<="01";
        when "10010" =>
                 c23<='0'; c45<='0'; c67<='0'; sel<="00";
        when "10011" =>
                 c23<='1'; c45<='0'; c67<='0'; sel<="00";
        when "10100" =>
                 c23<='0'; c45<='0'; c67<='0'; sel<="01";
        when "10101" =>
                 c23<='0'; c45<='1'; c67<='0'; sel<="01";
        when "10110" =>
                 c23<='0'; c45<='0'; c67<='0'; sel<="10";
        when "10111" =>
                 c23<='0'; c45<='0'; c67<='1'; sel<="10";
        when "11000" =>
                 c23<='0'; c45<='0'; c67<='0'; sel<="11";
        when others =>
                assert FALSE 
                report "Error : DATA_WIDTH or DATA_RATE has illegal values."
                severity failure;
     end case;
     wait on cntr, c23, c45, c67, sel;

  end process prcs_bscntrl_cntr;
         
----------------------------------------------------------------------
-----------    Instant Clock Enable Circuit  ------------------------- 
----------------------------------------------------------------------
  INST_ICE : ICE_MODULE 
  generic map (
      SRTYPE => SRTYPE,
      INIT_CE => INIT_CE
     )
  port map (
      ICE	=> ice,

      CE1	=> CE1_dly,
      CE2	=> CE2_dly,
      GSR	=> GSR_dly,
      NUM_CE	=> AttrNumCe,
      CLKDIV	=> CLKDIV_dly,
      R		=> SR_dly 
      );
----------------------------------------------------------------------
-----------    Instant IDELAY  --------------------------------------- 
----------------------------------------------------------------------
  INST_IDELAY : IDELAY 
  generic map (
      IOBDELAY_VALUE => IOBDELAY_VALUE,
      IOBDELAY_TYPE  => IOBDELAY_TYPE
     )
  port map (
      O		=> idelay_out,

      C		=> CLKDIV_dly,
      CE	=> DLYCE_dly,
      
      I		=> D_dly,
      INC	=> DLYINC_dly,
      RST	=> DLYRST_dly
      );

--###################################################################
--#####           IOBDELAY -- Delay input Data                  ##### 
--###################################################################
  prcs_d_delay:process(D_dly, idelay_out)
  begin
     case AttrIobDelay is
        when 0 =>
               O_zd   <= D_dly;
               datain <= D_dly;
        when 1 =>
               O_zd   <= idelay_out; 
               datain <= D_dly;
        when 2 =>
               O_zd   <= D_dly; 
               datain <= idelay_out;
        when 3 =>
               O_zd   <= idelay_out; 
               datain <= idelay_out;
        when others =>
               null;
     end case;
  end process prcs_d_delay;

--####################################################################

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(O_zd, Q1_zd, Q2_zd, Q3_zd, Q4_zd, Q5_zd, Q6_zd, 
                      SHIFTOUT1_zd, SHIFTOUT2_zd)
  begin
      O  <= O_zd;
      Q1 <= Q1_zd after SYNC_PATH_DELAY;
      Q2 <= Q2_zd after SYNC_PATH_DELAY;
      Q3 <= Q3_zd after SYNC_PATH_DELAY;
      Q4 <= Q4_zd after SYNC_PATH_DELAY;
      Q5 <= Q5_zd after SYNC_PATH_DELAY;
      Q6 <= Q6_zd after SYNC_PATH_DELAY;
      SHIFTOUT1 <= SHIFTOUT1_zd after SYNC_PATH_DELAY;
      SHIFTOUT2 <= SHIFTOUT2_zd after SYNC_PATH_DELAY;
  end process prcs_output;
--####################################################################


end ISERDES_V;

