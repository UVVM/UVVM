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
-- /___/   /\     Filename : ISERDESE1.vhd
-- \   \  /  \    Timestamp : Thu Aug 28 15:20:20 PDT 2008
--  \___\/\___\
--
-- Revision:
--    08/28/08 - Initial version.
--    01/21/09 - IR 504341
--    02/06/09 - CR 507371 removed OCLKB
--    02/18/09 - CR 509177 DYNCLKSEL inverts the clock when it is low
--    04/15/09 - CR 518368 Removed DYNOCLKSEL pin and DYN_OCLK_INV_EN attribute.
--    06/04/09 - CR 523086 When ((DYN_CLK_INV_EN = TRUE) and (DYNCLKSEL = '0')), swap  CLK and CLKB signals
--    11/25/09 - CR 539356 Simprim O output fix
--    12/15/09 - CR 541284/541285 Enabled OverSampling
--    01/18/09 - CR 545277 Updated CLK to Q timing due OverSampling
--    02/23/10 - CR 550912  Fixed OVERSAMPLE issues
--    03/08/10 - CR 552611  Fixed race conditon in OVERSAMPLE to match verilog 
-- End Revision
----- CELL ISERDESE1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

library unisim;
use unisim.vpkg.all;
use unisim.vcomponents.all;

--//////////////////////////////////////////////////////////// 
--//////////// BSCNTRL_ISERDESE1_VHD /////////////////////////
--//////////////////////////////////////////////////////////// 
entity bscntrl_iserdese1_vhd is
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
           
end bscntrl_iserdese1_vhd;

architecture bscntrl_iserdese1_vhd_V of bscntrl_iserdese1_vhd is
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
end bscntrl_iserdese1_vhd_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

library unisim;
use unisim.vpkg.all;
use unisim.vcomponents.all;

--//////////////////////////////////////////////////////////// 
--//////////////////////// ICE MODULE ////////////////////////
--//////////////////////////////////////////////////////////// 

entity ice_iserdese1_vhd is
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
end ice_iserdese1_vhd;

architecture ice_iserdese1_vhd_V of ice_iserdese1_vhd is
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
end ice_iserdese1_vhd_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

library unisim;
use unisim.vpkg.all;
use unisim.vcomponents.all;

----- CELL ISERDESE1 -----
--//////////////////////////////////////////////////////////// 
--////////////////////////// ISERDES /////////////////////////
--//////////////////////////////////////////////////////////// 

entity ISERDESE1 is

  generic(

      DATA_RATE		: string	:= "DDR";
      DATA_WIDTH	: integer	:= 4;
      DYN_CLKDIV_INV_EN : boolean       := FALSE; 
      DYN_CLK_INV_EN    : boolean       := FALSE; 
      INIT_Q1		: bit		:= '0';
      INIT_Q2		: bit		:= '0';
      INIT_Q3		: bit		:= '0';
      INIT_Q4		: bit		:= '0';
      INTERFACE_TYPE	: string	:= "MEMORY";
      IOBDELAY		: string	:= "NONE";
      NUM_CE		: integer	:= 2;
      OFB_USED		: boolean       := FALSE; 
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
      CLKB		: in std_ulogic;
      CLKDIV		: in std_ulogic;
      D			: in std_ulogic;
      DDLY		: in std_ulogic;
      DYNCLKDIVSEL	: in std_ulogic;
      DYNCLKSEL		: in std_ulogic;
      OCLK		: in std_ulogic;
      OFB		: in std_ulogic;
      RST		: in std_ulogic;
      SHIFTIN1		: in std_ulogic;
      SHIFTIN2		: in std_ulogic
    );

end ISERDESE1;

architecture ISERDESE1_V OF ISERDESE1 is

component bscntrl_iserdese1_vhd
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

component ice_iserdese1_vhd
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

  constant DDR_CLK_EDGE	        : string	         := "SAME_EDGE_PIPELINED";
  constant INIT_BITSLIPCNT	: bit_vector(3 downto 0) := "0000";
  constant INIT_CE		: bit_vector(1 downto 0) := "00";
  constant INIT_RANK1_PARTIAL	: bit_vector(4 downto 0) := "00000";
  constant INIT_RANK2		: bit_vector(5 downto 0) := "000000";
  constant INIT_RANK3		: bit_vector(5 downto 0) := "000000";
  constant SERDES		: boolean	         := TRUE;
  constant SRTYPE		: string	         := "ASYNC";

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
  signal CLKB_ipd	        : std_ulogic := 'X';
  signal CLKDIV_ipd		: std_ulogic := 'X';
  signal D_ipd			: std_ulogic := 'X';
  signal DDLY_ipd		: std_ulogic := 'X';
  signal DYNCLKDIVSEL_ipd	: std_ulogic := 'X';
  signal DYNCLKSEL_ipd		: std_ulogic := 'X';
  signal GSR            : std_ulogic := '0';
  signal GSR_ipd		: std_ulogic := 'X';
  signal OCLK_ipd		: std_ulogic := 'X';
  signal OFB_ipd		: std_ulogic := 'X';
  signal RST_ipd		: std_ulogic := 'X';
  signal SHIFTIN1_ipd		: std_ulogic := 'X';
  signal SHIFTIN2_ipd		: std_ulogic := 'X';

  signal BITSLIP_dly	        : std_ulogic := 'X';
  signal CE1_dly	        : std_ulogic := 'X';
  signal CE2_dly	        : std_ulogic := 'X';
  signal CLK_dly	        : std_ulogic := 'X';
  signal CLKB_dly	        : std_ulogic := 'X';
  signal CLKDIV_dly		: std_ulogic := 'X';
  signal D_dly			: std_ulogic := 'X';
  signal D_CLK_dly		: std_ulogic := 'X';
  signal D_CLKB_dly		: std_ulogic := 'X';
  signal D_OCLK_dly		: std_ulogic := 'X';
  signal DDLY_dly		: std_ulogic := 'X';
  signal DDLY_CLK_dly		: std_ulogic := 'X';
  signal DDLY_CLKB_dly		: std_ulogic := 'X';
  signal DDLY_OCLK_dly		: std_ulogic := 'X';
  signal OFB_CLK_dly		: std_ulogic := 'X';
  signal OFB_CLKB_dly		: std_ulogic := 'X';
  signal OFB_OCLK_dly		: std_ulogic := 'X';
  signal DYNCLKDIVSEL_dly	: std_ulogic := 'X';
  signal DYNCLKSEL_dly		: std_ulogic := 'X';
  signal DLYCE_dly		: std_ulogic := 'X';
  signal DLYINC_dly		: std_ulogic := 'X';
  signal DLYRST_dly		: std_ulogic := 'X';
  signal GSR_dly		: std_ulogic := '0';
  signal OCLK_dly		: std_ulogic := 'X';
  signal OFB_dly		: std_ulogic := 'X';
  signal RST_dly		: std_ulogic := '0';
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

  signal AttrDataRate		: std_ulogic := 'X';
  signal AttrDataWidth		: std_logic_vector(3 downto 0) := (others => 'X');
  signal AttrDynClkdivInvEn	: std_ulogic := 'X';
  signal AttrDynClkInvEn	: std_ulogic := 'X';
  signal AttrInterfaceType	: std_logic_vector(1 downto 0) := (others => 'X');
  signal AttrNumCe		: std_ulogic := 'X';
  signal AttrIobDelay           : integer := 0;
  signal AttrOfbUsed		: std_ulogic := 'X';
  signal AttrSerdesMode		: std_ulogic := 'X';

  signal OVERSAMPLE		: std_ulogic := '0';
  signal sel			: std_logic_vector(1 downto 0) := (others => 'X');
  signal selrnk3		: std_logic_vector(3 downto 0) := (others => 'X');
  signal cntr			: std_logic_vector(4 downto 0) := (others => 'X');
  signal sel1			: std_logic_vector(1 downto 0) := (others => 'X');
  
  signal bsmux			: std_logic_vector(3 downto 0) := (others => 'X');

  signal bitslip_en		: std_ulogic := 'X';
  signal int_typ		: std_ulogic := 'X';
  signal os_en			: std_logic_vector(1 downto 0) := (others => 'X');
  signal rank2_cksel		: std_logic_vector(2 downto 0) := (others => 'X');

  signal q1rnk1			: std_ulogic := TO_X01(INIT_Q1);
  signal q2nrnk1		: std_ulogic := TO_X01(INIT_Q2);
  signal q5rnk1			: std_ulogic := 'X';
  signal q6rnk1			: std_ulogic := 'X';
  signal q6prnk1		: std_ulogic := 'X';

  signal q1prnk1		: std_ulogic := TO_X01(INIT_Q3);
  signal q2prnk1		: std_ulogic := TO_X01(INIT_Q4);
  signal q3rnk1			: std_ulogic := 'X';
  signal q4rnk1			: std_ulogic := 'X';

  signal dataq3rnk1		: std_ulogic := 'X';
  signal dataq4rnk1		: std_ulogic := 'X';

  signal dataq5rnk1		: std_ulogic := 'X';
  signal dataq6rnk1		: std_ulogic := 'X';

  signal memmux			: std_ulogic := '0';
  signal q2pmux			: std_ulogic := '0';

  signal clkmux1		: std_ulogic := '0';
  signal clkmux2		: std_ulogic := '0';
  signal clkmux3		: std_ulogic := '0';
  signal clkmux4		: std_ulogic := '0';

  signal clkoimux		: std_ulogic := '0';
  signal oclkoimux		: std_ulogic := '0';
  signal clkdivoimux		: std_ulogic := '0';

  signal clkboimux		: std_ulogic := '0';
  signal oclkboimux		: std_ulogic := '0';
  signal clkdivboimux		: std_ulogic := '0';

  signal clkdiv_int		: std_ulogic := '0';
  signal clkdivmux1		: std_ulogic := '0';
  signal clkdivmux2		: std_ulogic := '0';

  signal ddr3clkmux		: std_ulogic := '0';

  signal rank3clkmux		: std_ulogic := '0';

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

  signal ice			: std_ulogic := 'X';
--  signal datain			: std_ulogic := 'X';
  signal idelay_out		: std_ulogic := 'X';

  signal datain_CLK             : std_ulogic := 'X';
  signal datain_CLKB            : std_ulogic := 'X';


  signal CLKN_dly		: std_ulogic := '0';

  signal pre_fdbk_O_zd          : std_ulogic := 'X';
  signal pre_fdbk_datain_CLK    : std_ulogic := 'X';
  signal pre_fdbk_datain_CLKB   : std_ulogic := 'X';

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  BITSLIP_dly    	 <= BITSLIP        ;
  CE1_dly        	 <= CE1            ;
  CE2_dly        	 <= CE2            ;
  CLK_dly        	 <= CLK            ;
  CLKB_dly       	 <= CLKB           ;
  CLKDIV_dly     	 <= CLKDIV         ;
  D_dly          	 <= D              ;
  D_CLK_dly      	 <= D              ;
  D_CLKB_dly     	 <= D              ;
  DDLY_dly       	 <= DDLY           ;
  DDLY_CLK_dly   	 <= DDLY           ;
  DDLY_CLKB_dly  	 <= DDLY           ;
  DYNCLKDIVSEL_dly	 <= DYNCLKDIVSEL   ;
  DYNCLKSEL_dly  	 <= DYNCLKSEL      ;
  OCLK_dly       	 <= OCLK           ;
  OFB_dly        	 <= OFB            ;
  RST_dly        	 <= RST            ;
  SHIFTIN1_dly   	 <= SHIFTIN1       ;
  SHIFTIN2_dly   	 <= SHIFTIN2       ;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  variable AttrDataRate_var		: std_ulogic := 'X';
  variable AttrDataWidth_var		: std_logic_vector(3 downto 0) := (others => 'X');
  variable AttrDynClkdivInvEn_var	: std_ulogic := 'X';
  variable AttrDynClkInvEn_var		: std_ulogic := 'X';
  variable AttrInterfaceType_var	: std_logic_vector(1 downto 0) := (others => 'X');
  variable AttrNumCe_var		: std_ulogic := 'X';
  variable AttrIobDelay_var             : integer := 0;
  variable AttrOfbUsed_var		: std_ulogic := 'X';
  variable AttrSerdesMode_var		: std_ulogic := 'X';

  variable OVERSAMPLE_var		: std_ulogic := '0';


  begin
-----------------------------------------------------------------
--------------------- DATA_RATE validity check ------------------
-----------------------------------------------------------------
      if(DATA_RATE = "DDR") then
         AttrDataRate_var := '0';
      elsif(DATA_RATE = "SDR") then
         AttrDataRate_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DATA_RATE ",
             EntityName => "/ISERDESE1",
             GenericValue => DATA_RATE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " DDR or SDR. ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;



-----------------------------------------------------------------
-------------------- DATA_WIDTH validity check ------------------
-----------------------------------------------------------------
      if((DATA_WIDTH = 2) or (DATA_WIDTH = 3) or  (DATA_WIDTH = 4) or
         (DATA_WIDTH = 5) or (DATA_WIDTH = 6) or  (DATA_WIDTH = 7) or
         (DATA_WIDTH = 8) or (DATA_WIDTH = 10)) then
         AttrDataWidth_var := CONV_STD_LOGIC_VECTOR(DATA_WIDTH, MAX_DATAWIDTH); 
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DATA_WIDTH ",
             EntityName => "/ISERDESE1",
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
                   EntityName => "/ISERDESE1",
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
                   EntityName => "/ISERDESE1",
                   GenericValue => DATA_WIDTH,
                   Unit => "",
                   ExpectedValueMsg => " The Legal values for SDR mode are ",
                   ExpectedGenericValue => " 2, 3, 4, 5, 6, 7 or 8",
                   TailMsg => "",
                   MsgSeverity => Failure
                );
          end case;
      end if;

-----------------------------------------------------------------
------------ DYN_CLKDIV_INV_EN validity check -------------------
-----------------------------------------------------------------
      if(DYN_CLKDIV_INV_EN = false) then
         AttrDynClkdivInvEn_var := '0';
      elsif(DYN_CLKDIV_INV_EN = true) then
         AttrDynClkdivInvEn_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DYN_CLKDIV_INV_EN ",
             EntityName => "/ISERDESE1",
             GenericValue => DYN_CLKDIV_INV_EN,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " TRUE or FALSE ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

-----------------------------------------------------------------
--------------- DYN_CLK_INV_EN validity check -------------------
-----------------------------------------------------------------
      if(DYN_CLK_INV_EN = false) then
         AttrDynClkInvEn_var := '0';
      elsif(DYN_CLK_INV_EN = true) then
         AttrDynClkInvEn_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DYN_CLK_INV_EN ",
             EntityName => "/ISERDESE1",
             GenericValue => DYN_CLK_INV_EN,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " TRUE or FALSE ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

-----------------------------------------------------------------
---------------    IOBDELAY validity check    -------------------
-----------------------------------------------------------------
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
             EntityName => "/ISERDESE1",
             GenericValue => IOBDELAY,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " NONE or IBUF or IFD or BOTH ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;


-----------------------------------------------------------------
--------------- OFB_USED validity check -------------------
-----------------------------------------------------------------
      if(OFB_USED = false) then
         AttrOfbUsed_var := '0';
      elsif(OFB_USED = true) then
         AttrOfbUsed_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " OFB_USED ",
             EntityName => "/ISERDESE1",
             GenericValue => OFB_USED,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " TRUE or FALSE ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

-----------------------------------------------------------------
----------------     NUM_CE validity check    -------------------
-----------------------------------------------------------------
      case NUM_CE is
         when 1 =>
                AttrNumCe_var := '0';
         when 2 =>
                AttrNumCe_var := '1';
         when others =>
                GenericValueCheckMessage
                  (  HeaderMsg  => " Attribute Syntax Warning ",
                     GenericName => " NUM_CE ",
                     EntityName => "/ISERDESE1",
                     GenericValue => NUM_CE,
                     Unit => "",
                     ExpectedValueMsg => " The Legal values for this attribute are ",
                     ExpectedGenericValue => " 1 or 2 ",
                     TailMsg => "",
                     MsgSeverity => Failure
                  );
      end case;

-----------------------------------------------------------------
------------------- INTERFACE_TYPE validity check ---------------
-----------------------------------------------------------------
      if(INTERFACE_TYPE = "MEMORY") then
         AttrInterfaceType_var := "00";
      elsif(INTERFACE_TYPE = "NETWORKING") then
         AttrInterfaceType_var := "01";
      elsif(INTERFACE_TYPE = "MEMORY_QDR") then
         AttrInterfaceType_var := "10";
      elsif(INTERFACE_TYPE = "MEMORY_DDR3") then
         AttrInterfaceType_var := "11";
      elsif(INTERFACE_TYPE = "OVERSAMPLE") then
         AttrInterfaceType_var := "01";
         OVERSAMPLE_var        := '1';  
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => "INTERFACE_TYPE ",
             EntityName => "/ISERDESE1",
             GenericValue => INTERFACE_TYPE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " MEMORY, NETWORKING, MEMORY_QDR, MEMORY_DDR3 or OVERSAMPLE.",
             TailMsg => "",
             MsgSeverity => FAILURE 
         );
      end if;


-----------------------------------------------------------------
----------------- SERDES_MODE validity check --------------------
-----------------------------------------------------------------
      if(SERDES_MODE = "MASTER") then
         AttrSerdesMode_var := '0';
      elsif(SERDES_MODE = "SLAVE") then 
         AttrSerdesMode_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => "SERDES_MODE ",
             EntityName => "/ISERDESE1",
             GenericValue => SERDES_MODE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " MASTER or SLAVE.",
             TailMsg => "",
             MsgSeverity => FAILURE 
         );
      end if;

---------------------------------------------------------------------

     AttrDataRate	<= AttrDataRate_var;
     AttrDataWidth	<= AttrDataWidth_var;
     AttrDynClkdivInvEn	<= AttrDynClkdivInvEn_var;
     AttrDynClkInvEn	<= AttrDynClkInvEn_var;
     AttrInterfaceType	<= AttrInterfaceType_var;
     AttrNumCe	        <= AttrNumCe_var;
     AttrIobDelay       <= AttrIobDelay_var;
     AttrOfbUsed 	<= AttrOfbUsed_var;
     AttrSerdesMode	<= AttrSerdesMode_var;

--   CR 541284
     OVERSAMPLE	        <= OVERSAMPLE_var;


     int_typ     <= AttrInterfaceType_var(1) or AttrInterfaceType_var(0); 
     bitslip_en  <= AttrInterfaceType_var(0); 
--   os_en       <= int_typ & '0';                          --  {int_typ,OVERSAMPLE}
     sel1        <= AttrSerdesMode_var & AttrDataRate_var; 

--   CR 541284
--     rank2_cksel <= AttrInterfaceType_var & '0';            --  {INTERFACE_TYPE,OVERSAMPLE}
--     rank2_cksel <= AttrInterfaceType_var & OVERSAMPLE;            --  {INTERFACE_TYPE,OVERSAMPLE}
     rank2_cksel <= AttrInterfaceType_var & OVERSAMPLE_var;            --  {INTERFACE_TYPE,OVERSAMPLE}
--   selrnk3     <= '1' & bitslip_en & "11";                -- {SERDES,bitslip_en,DDR_CLK_EDGE}
     selrnk3     <= '1' & AttrInterfaceType_var(0) & "11";                -- {SERDES,bitslip_en,DDR_CLK_EDGE}
--   bsmux       <= bitslip_en & AttrDataRate_var & muxc & '0'; -- {bitslip_en,DATA_RATE,muxc,OVERSAMPLE}; 
     cntr        <= AttrDataRate_var & AttrDataWidth_var;

     wait;
  end process prcs_init;

--###################################################################
--#####               SHIFTOUT1 and SHIFTOUT2                   #####
--###################################################################
--   CR 541284
--  bsmux       <= bitslip_en & AttrDataRate & muxc & '0'; -- {bitslip_en,DATA_RATE,muxc,OVERSAMPLE};
  bsmux       <= bitslip_en & AttrDataRate & muxc & OVERSAMPLE; -- {bitslip_en,DATA_RATE,muxc,OVERSAMPLE};

--   CR 541284
--  os_en       <= int_typ & '0';
    os_en       <= int_typ & OVERSAMPLE;

  SHIFTOUT2_zd <= q5rnk1;
  SHIFTOUT1_zd <= q6rnk1;

--###################################################################
--#####                   Input to ISERDES                      #####
--###################################################################
  prcs_pre_fdbk_d_delay:process(D_dly, DDLY_dly, D_CLK_dly, D_CLKB_dly, DDLY_CLK_dly, DDLY_CLKB_dly)
  begin
     case AttrIobDelay is
        when 0 =>
               pre_fdbk_O_zd        <= D_dly;
               pre_fdbk_datain_CLK  <= D_CLK_dly;
               pre_fdbk_datain_CLKB <= D_CLKB_dly;
        when 1 =>
               pre_fdbk_O_zd   <= DDLY_dly;
               pre_fdbk_datain_CLK  <= D_CLK_dly;
               pre_fdbk_datain_CLKB <= D_CLKB_dly;
        when 2 =>
               pre_fdbk_O_zd   <= D_dly;
               pre_fdbk_datain_CLK  <= DDLY_CLK_dly;
               pre_fdbk_datain_CLKB <= DDLY_CLKB_dly;
        when 3 =>
               pre_fdbk_O_zd   <= DDLY_dly;
               pre_fdbk_datain_CLK  <= DDLY_CLK_dly;
               pre_fdbk_datain_CLKB <= DDLY_CLKB_dly;
        when others =>
               null;
     end case;
  end process prcs_pre_fdbk_d_delay;

--  datain <= OFB_dly when (AttrOfbUsed = '1') else D_dly;
 
--  O_zd <= datain;

    O_zd        <= OFB_dly when (AttrOfbUsed = '1') else pre_fdbk_O_zd; 
    datain_CLK  <= OFB_dly when (AttrOfbUsed = '1') else pre_fdbk_datain_CLK;
    datain_CLKB <= OFB_dly when (AttrOfbUsed = '1') else pre_fdbk_datain_CLKB;

--////////////////////////////////////////////////////////////
--//   High Speed  Clock Generation  and Polarity Control  ///
--////////////////////////////////////////////////////////////


--###################################################################
--#####                     clkoimux                            #####
--###################################################################

--  CR 523086
--  clkoimux <= NOT CLK_dly when ((DYN_CLK_INV_EN) and (DYNCLKSEL = '0')) else CLK_dly; 
  clkoimux <= CLKB_dly when ((DYN_CLK_INV_EN) and (DYNCLKSEL = '0')) else CLK_dly; 
 
--###################################################################
--#####                     clkboimux                           #####
--###################################################################

--  CR 523086
--  clkboimux <= NOT CLKB_dly when ((DYN_CLK_INV_EN) and (DYNCLKSEL = '0')) else CLKB_dly; 
  clkboimux <= CLK_dly when ((DYN_CLK_INV_EN) and (DYNCLKSEL = '0')) else CLKB_dly; 

--###################################################################
--#####                     oclkoimux                           #####
--###################################################################
-- CR 518368
--  oclkoimux <= NOT OCLK_dly when ((DYN_OCLK_INV_EN) and (DYNOCLKSEL = '1')) else OCLK_dly; 
    oclkoimux <= OCLK_dly; 

--###################################################################
--#####                     oclkboimux                          #####
--###################################################################
--  CR 507371
--  oclkboimux <= NOT OCLKB_dly when ((DYN_OCLK_INV_EN) and (DYNOCLKSEL = '1')) else OCLKB_dly; 

--###################################################################
--#####                     clkdivoimux                         #####
--###################################################################

  clkdivoimux <= NOT CLKDIV_dly when ((DYN_CLKDIV_INV_EN) and (DYNCLKDIVSEL = '1')) else CLKDIV_dly; 

--###################################################################
--#####                        clkmux2                          #####
--###################################################################
-- clkmux for 2nd flop in rank1
--  all changed to clkboimux
   clkmux2 <= clkboimux;  -- 550912 OVERSAMPLE included
--  prcs_clkmux2:process(AttrInterfaceType, clkoimux, clkboimux)
--  begin
--     case AttrInterfaceType is
--           when "00" =>   clkmux2 <= NOT clkoimux;
--           when "01" =>   clkmux2 <= NOT clkoimux;
--           when "10" =>   clkmux2 <= clkboimux;
--           when "11" =>   clkmux2 <= NOT clkoimux;
--           when others => clkmux2 <= NOT clkoimux;
--     end case; 
--  end process prcs_clkmux2;

--###################################################################
--#####                        clkmux3                          #####
--###################################################################
-- clkmux for 3rd  flop in rank1
  prcs_clkmux3:process(os_en, oclkoimux, clkoimux)
  begin
     case os_en is
           when "00" =>   clkmux3 <= oclkoimux;
           when "01" =>   clkmux3 <= oclkoimux;
           when "10" =>   clkmux3 <= clkoimux;
           when "11" =>   clkmux3 <= oclkoimux after 1 ps; -- CR 552611 -- Matched verilog - fixed race condition during OS 
           when others => clkmux3 <= oclkoimux;
     end case; 
  end process prcs_clkmux3;
--###################################################################
--#####                        clkmux4                          #####
--###################################################################
-- clkmux for 4th flop in rank1
  prcs_clkmux4:process(os_en, oclkoimux, clkoimux, oclkboimux)
  begin
     case os_en is
           when "00" =>   clkmux4 <= NOT oclkoimux;
           when "01" =>   clkmux4 <= NOT oclkoimux;
           when "10" =>   clkmux4 <= clkoimux;
           when "11" =>   clkmux4 <= NOT oclkoimux after 1 ps; -- CR 552611 -- Matched verilog - fixed race condition during OS 
                          -- CR 550912 changed from grounded oclkboimux to ~oclkoimux -- need for OVERSAMPLE 
           when others => clkmux4 <= NOT oclkoimux;
     end case; 
  end process prcs_clkmux4;
--###################################################################
--#####                        memmux                           #####
--###################################################################
-- Rest of clock muxs in first rank
  prcs_memmux:process(int_typ, oclkoimux, clkoimux)
  begin
     case int_typ is
           when '0' =>    memmux <= oclkoimux after DELAY_MXINP1;
           when '1' =>    memmux <= clkoimux  after DELAY_MXINP1;
           when others => memmux <= oclkoimux after DELAY_MXINP1;
     end case; 
  end process prcs_memmux;
--###################################################################
--#####                     q1rnk1 reg                          #####
--###################################################################
  prcs_Q1_rnk1:process(clkoimux, GSR_dly)
  variable q1rnk1_var         : std_ulogic := '0';
  begin
     if(GSR_dly = '1') then
         q1rnk1_var  :=  TO_X01(INIT_Q1);
     elsif(GSR_dly = '0') then
     --------------- // sync SET/RESET
        if(rising_edge(clkoimux)) then
           if(RST_dly = '1') then
              q1rnk1_var := TO_X01(SRVAL_Q1);
           elsif(ice = '1') then
--              q1rnk1_var := datain;
              q1rnk1_var := datain_CLK;
           end if;
        end if;
     end if;

     q1rnk1  <= q1rnk1_var  after DELAY_FFINP;

  end process prcs_Q1_rnk1;
--###################################################################
--#####              q5rnk1, q6rnk1 and q6prnk1 reg             #####
--###################################################################
  prcs_Q5Q6Q6p_rnk1:process(clkoimux, GSR_dly)
  variable q5rnk1_var         : std_ulogic := '0';
  variable q6rnk1_var         : std_ulogic := '0';
  variable q6prnk1_var        : std_ulogic := '0';
  begin
     if(GSR_dly = '1') then
         q5rnk1_var  := '0';
         q6rnk1_var  := '0';
         q6prnk1_var := '0';
     elsif(GSR_dly = '0') then
     --------- // sync SET/RESET  -- Not full featured FFs
         if(rising_edge(clkoimux)) then
            if(RST_dly = '1') then
               q5rnk1_var  := '0';
               q6rnk1_var  := '0';
               q6prnk1_var := '0';
            else 
               q5rnk1_var  := dataq5rnk1;
               q6rnk1_var  := dataq6rnk1;
               q6prnk1_var := q6rnk1;
            end if;
         end if;
     end if;

     q5rnk1  <= q5rnk1_var  after DELAY_FFINP;
     q6rnk1  <= q6rnk1_var  after DELAY_FFINP;
     q6prnk1 <= q6prnk1_var after DELAY_FFINP;

  end process prcs_Q5Q6Q6p_rnk1;
--###################################################################
--#####                     q2nrnk1 reg                          #####
--###################################################################
  prcs_Q2_rnk1:process(clkmux2, GSR_dly)
  variable q2nrnk1_var         : std_ulogic := TO_X01(INIT_Q2);
  begin
     if(GSR_dly = '1') then
         q2nrnk1_var  := TO_X01(INIT_Q2);
     elsif(GSR_dly = '0') then
     --------------- // sync SET/RESET
        if(rising_edge(clkmux2)) then
           if(RST_dly = '1') then
              q2nrnk1_var  := TO_X01(SRVAL_Q2);
           elsif(ice = '1') then
--                 q2nrnk1_var := datain;
                 q2nrnk1_var := datain_CLKB;
           end if;
        end if;
     end if;

     q2nrnk1  <= q2nrnk1_var after DELAY_FFINP;

  end process prcs_Q2_rnk1;
--###################################################################
--#####                      q1prnk1  reg                       #####
--###################################################################
  prcs_Q1p_rnk1:process(clkmux3, GSR_dly)
  variable q1prnk1_var        : std_ulogic := TO_X01(INIT_Q3);
  begin
     if(GSR_dly = '1') then
         q1prnk1_var := TO_X01(INIT_Q3);
     elsif(GSR_dly = '0') then
     --------------- // sync RESET
         if(rising_edge(clkmux3)) then
            if(RST_dly = '1') then
               q1prnk1_var := TO_X01(SRVAL_Q3);
            elsif(ice = '1') then
--                  q1prnk1_var := q1rnk1;
                  if(OVERSAMPLE='1') then
                     q1prnk1_var := datain_CLK; -- CR 550912  OVERSAMPLE
                  else 
                     q1prnk1_var := q1rnk1;
                  end if;
            end if;
         end if;
     end if;

     q1prnk1  <= q1prnk1_var after DELAY_FFINP;

  end process prcs_Q1p_rnk1;
--###################################################################
--#####                  q3rnk1 and q4rnk1 reg                  #####
--###################################################################
  prcs_Q3Q4_rnk1:process(memmux, GSR_dly)
  variable q3rnk1_var         : std_ulogic := '0';
  variable q4rnk1_var         : std_ulogic := '0';
  begin
     if(GSR_dly = '1') then
         q3rnk1_var  := '0';
         q4rnk1_var  := '0';
     elsif(GSR_dly = '0') then
     -------- // sync SET/RESET -- not fully featured FFs
         if(rising_edge(memmux)) then
            if(RST_dly = '1') then
               q3rnk1_var  := '0';
               q4rnk1_var  := '0';
            else
               q3rnk1_var  := dataq3rnk1;
               q4rnk1_var  := dataq4rnk1;
            end if;
         end if;
     end if;

     q3rnk1   <= q3rnk1_var after DELAY_FFINP;
     q4rnk1   <= q4rnk1_var after DELAY_FFINP;

  end process prcs_Q3Q4_rnk1;
--###################################################################
--#####                       q2prnk1 reg                       #####
--###################################################################
  prcs_Q2p_rnk1:process(clkmux4, GSR_dly)
  variable q2prnk1_var        : std_ulogic := TO_X01(INIT_Q4);
  begin
     if(GSR_dly = '1') then
         q2prnk1_var := TO_X01(INIT_Q4);
     elsif(GSR_dly = '0') then
     --------------- // sync RESET
        if(rising_edge(clkmux4)) then
           if(RST_dly = '1') then
              q2prnk1_var := TO_X01(SRVAL_Q4);
           elsif(ice = '1') then
--              q2prnk1_var := q2nrnk1;
               if(OVERSAMPLE='1') then
                   q2prnk1_var := datain_CLK; -- CR 550912  OVERSAMPLE
               else
                   q2prnk1_var := q2nrnk1;
               end if;
           end if;
        end if;
     end if;

     q2prnk1  <= q2prnk1_var after DELAY_FFINP;

  end process prcs_Q2p_rnk1;
--///////////////////////////////////////////////////////////////////
--// Mux elements for the 1st Rank
--///////////////////////////////////////////////////////////////////

--###################################################################
--#####          data input muxes for q3, q4 q5 and q6      #####
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

--  DDR3 Divide By 2
--###################################################################
--#####                         ddr3clkmux                      #####
--###################################################################
  prcs_ddr3clkmux:process(clkoimux)
  begin
     if(falling_edge(clkoimux)) then
        if(RST_dly = '1') then
           ddr3clkmux <= '0';
        elsif(INTERFACE_TYPE = "MEMORY_DDR3") then
           ddr3clkmux <= NOT ddr3clkmux;
        else
           ddr3clkmux <= NOT ddr3clkmux;
        end if;
    end if;
  end process prcs_ddr3clkmux;

--###################################################################
--#####                         clkdivmux1                      #####
--###################################################################
-- clkdivmuxs to pass clkdiv_int or CLKDIV to rank 2
  prcs_clkdivmux1:process(rank2_cksel, clkdiv_int, clkdivoimux, clkoimux, cntr)
  begin
     case rank2_cksel is
           when "000" => clkdivmux1 <= clkdivoimux after DELAY_MXINP1;
           when "010" =>
                   case cntr is 
                        when "00100" | "10010" => clkdivmux1 <= NOT clkdiv_int  after DELAY_MXINP1;
                        when others           => clkdivmux1 <= clkdiv_int  after DELAY_MXINP1;
                   end case;
           when "100" => clkdivmux1 <= clkdivoimux after DELAY_MXINP1;
           when "110" => clkdivmux1 <= ddr3clkmux  after DELAY_MXINP1;
           when "011" => clkdivmux1 <= clkoimux    after DELAY_MXINP1;
           when others => null;
     end case;
  end process prcs_clkdivmux1;
--###################################################################
--#####                         clkdivmux2                      #####
--###################################################################
-- clkdivmuxs to pass clkdiv_int or CLKDIV to rank 2
-- FP
  prcs_clkdivmux2:process(rank2_cksel, clkdiv_int, clkdivoimux, clkoimux, oclkoimux, cntr)
  begin
     case rank2_cksel is
           when "000" => clkdivmux2 <= clkdivoimux after DELAY_MXINP1;
           when "010" =>
                   case cntr is 
                        when "00100" | "10010" => clkdivmux2 <= NOT clkdiv_int  after DELAY_MXINP1;
                        when others           => clkdivmux2 <= clkdiv_int  after DELAY_MXINP1;
                   end case;
           when "100" => clkdivmux2 <= clkdivoimux after DELAY_MXINP1;
           when "110" => clkdivmux2 <= ddr3clkmux  after DELAY_MXINP1;
           when "011" => clkdivmux2 <= oclkoimux   after DELAY_MXINP1;
           when others => null;
     end case;
  end process prcs_clkdivmux2;

--###################################################################
--#####  q1rnk2, q3rnk2, q5rnk2 and q6rnk2 reg   #####
--###################################################################
  prcs_Q1Q3Q5Q6_rnk2:process(clkdivmux1, GSR_dly)
  variable q1rnk2_var         : std_ulogic := '0';
  variable q3rnk2_var         : std_ulogic := '0';
  variable q5rnk2_var         : std_ulogic := '0';
  variable q6rnk2_var         : std_ulogic := '0';
  begin
     if(GSR_dly = '1') then
         q1rnk2_var := '0';
         q3rnk2_var := '0';
         q5rnk2_var := '0';
         q6rnk2_var := '0';
     elsif(GSR_dly = '0') then
     --------------- // syncRESET
         if(rising_edge(clkdivmux1)) then
            if(RST_dly = '1') then
               q1rnk2_var := '0';
               q3rnk2_var := '0';
               q5rnk2_var := '0';
               q6rnk2_var := '0';
            else
               q1rnk2_var := dataq1rnk2;
               q3rnk2_var := dataq3rnk2;
               q5rnk2_var := dataq5rnk2;
               q6rnk2_var := dataq6rnk2;
            end if;
         end if;
     end if;

     q1rnk2  <= q1rnk2_var after DELAY_FFINP;
     q3rnk2  <= q3rnk2_var after DELAY_FFINP;
     q5rnk2  <= q5rnk2_var after DELAY_FFINP;
     q6rnk2  <= q6rnk2_var after DELAY_FFINP;

  end process prcs_Q1Q3Q5Q6_rnk2;

--###################################################################
--#####                     q2rnk2, q4rnk2                      #####
--###################################################################
  prcs_Q2Q4_rnk2:process(clkdivmux2, GSR_dly)
  variable q2rnk2_var         : std_ulogic := '0';
  variable q4rnk2_var         : std_ulogic := '0';
  begin
     if(GSR_dly = '1') then
         q2rnk2_var := '0';
         q4rnk2_var := '0';
     elsif(GSR_dly = '0') then
     --------------- // syncRESET
         if(rising_edge(clkdivmux2)) then
            if(RST_dly = '1') then
               q2rnk2_var := '0';
               q4rnk2_var := '0';
            else
               q2rnk2_var := dataq2rnk2;
               q4rnk2_var := dataq4rnk2;
            end if;
         end if;
     end if;

     q2rnk2  <= q2rnk2_var after DELAY_FFINP;
     q4rnk2  <= q4rnk2_var after DELAY_FFINP;

  end process prcs_Q2Q4_rnk2;
--###################################################################
--#####                    update bitslip mux                   #####
--###################################################################


--###################################################################
--#####    Data mux for 2nd rank of registers                  ######
--###################################################################
  prcs_Q1Q2Q3Q4Q5Q6_rnk2_mux:process(bsmux, q1rnk1, q1prnk1, q2nrnk1, q2prnk1,
                           q3rnk1, q4rnk1, q5rnk1, q6rnk1, q6prnk1)
  begin
     case bsmux is
        when "0000" | "0010" =>
                 dataq1rnk2 <= q2prnk1 after DELAY_MXINP2;
                 dataq2rnk2 <= q1prnk1 after DELAY_MXINP2;
                 dataq3rnk2 <= q4rnk1  after DELAY_MXINP2;
                 dataq4rnk2 <= q3rnk1  after DELAY_MXINP2;
                 dataq5rnk2 <= q6rnk1  after DELAY_MXINP2;
                 dataq6rnk2 <= q5rnk1  after DELAY_MXINP2;
        when "1000"  =>
                 dataq1rnk2 <= q2prnk1 after DELAY_MXINP2;
                 dataq2rnk2 <= q1prnk1 after DELAY_MXINP2;
                 dataq3rnk2 <= q4rnk1  after DELAY_MXINP2;
                 dataq4rnk2 <= q3rnk1  after DELAY_MXINP2;
                 dataq5rnk2 <= q6rnk1  after DELAY_MXINP2;
                 dataq6rnk2 <= q5rnk1  after DELAY_MXINP2;
        when "1010"  =>
                 dataq1rnk2 <= q1prnk1 after DELAY_MXINP2;
                 dataq2rnk2 <= q4rnk1  after DELAY_MXINP2;
                 dataq3rnk2 <= q3rnk1  after DELAY_MXINP2;
                 dataq4rnk2 <= q6rnk1  after DELAY_MXINP2;
                 dataq5rnk2 <= q5rnk1  after DELAY_MXINP2;
                 dataq6rnk2 <= q6prnk1 after DELAY_MXINP2;
        when "0100" | "0110" | "1100" | "1110" =>
                 dataq1rnk2 <= q1rnk1  after DELAY_MXINP2;
                 dataq2rnk2 <= q1prnk1 after DELAY_MXINP2;
                 dataq3rnk2 <= q3rnk1  after DELAY_MXINP2;
                 dataq4rnk2 <= q4rnk1  after DELAY_MXINP2;
                 dataq5rnk2 <= q5rnk1  after DELAY_MXINP2;
                 dataq6rnk2 <= q6rnk1  after DELAY_MXINP2;
        when "0001" | "0011" | "0101" | "0111" |
              "1001" | "1011" | "1101" | "1111" | "00X1" |
              "01X1" | "10X1" | "11X1" =>

                 dataq1rnk2 <= q1rnk1  after DELAY_MXINP2;
                 dataq2rnk2 <= q2nrnk1 after DELAY_MXINP2;
                 dataq3rnk2 <= q1prnk1 after DELAY_MXINP2;
                 dataq4rnk2 <= q2prnk1 after DELAY_MXINP2;
                 dataq5rnk2 <= q6rnk1  after DELAY_MXINP2;
                 dataq6rnk2 <= q5rnk1  after DELAY_MXINP2;
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
--#####                         rank3clkmux                      #####
--###################################################################
  prcs_rank3clkmux:process(rank2_cksel, clkdivoimux, clkoimux)
  begin
     case OVERSAMPLE is
           when '0' => rank3clkmux <= clkdivoimux after DELAY_MXINP1;
           when '1' => rank3clkmux <= clkoimux    after DELAY_MXINP1;
           when others => null;
     end case;
  end process prcs_rank3clkmux;
--###################################################################
--#####                         clkdivmux2                      #####
--###################################################################
--#####  q1rnk3, q2rnk3, q3rnk3, q4rnk3, q5rnk3 and q6rnk3 reg   #####
--###################################################################
  prcs_Q1Q2Q3Q4Q5Q6_rnk3:process(rank3clkmux, GSR_dly)
  variable q1rnk3_var         : std_ulogic := '0';
  variable q2rnk3_var         : std_ulogic := '0';
  variable q3rnk3_var         : std_ulogic := '0';
  variable q4rnk3_var         : std_ulogic := '0';
  variable q5rnk3_var         : std_ulogic := '0';
  variable q6rnk3_var         : std_ulogic := '0';
  begin
     if(GSR_dly = '1') then
         q1rnk3_var := '0';
         q2rnk3_var := '0';
         q3rnk3_var := '0';
         q4rnk3_var := '0';
         q5rnk3_var := '0';
         q6rnk3_var := '0';
     elsif(GSR_dly = '0') then
     --------------- // sync SET/RESET
         if(rising_edge(rank3clkmux)) then
            if(RST_dly = '1') then
               q1rnk3_var := '0';
               q2rnk3_var := '0';
               q3rnk3_var := '0';
               q4rnk3_var := '0';
               q5rnk3_var := '0';
               q6rnk3_var := '0';
            else
               q1rnk3_var := q1rnk2;
               q2rnk3_var := q2rnk2;
               q3rnk3_var := q3rnk2;
               q4rnk3_var := q4rnk2;
               q5rnk3_var := q5rnk2;
               q6rnk3_var := q6rnk2;
            end if;
         end if;
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
     case bitslip_en is
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
  INST_BSCNTRL : BSCNTRL_ISERDESE1_VHD
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
      R          => RST_dly,
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
  INST_ICE : ICE_ISERDESE1_VHD
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
      CLKDIV	=> rank3clkmux,
      R		=> RST_dly 
      );

--####################################################################

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(O_zd, Q1_zd, Q2_zd, Q3_zd, Q4_zd, Q5_zd, Q6_zd, 
                      SHIFTOUT1_zd, SHIFTOUT2_zd)
  begin
      O <= O_zd;
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

end ISERDESE1_V;

