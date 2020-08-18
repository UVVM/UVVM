-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Source Synchronous Output Serializer
-- /___/   /\     Filename : OSERDES.vhd
-- \   \  /  \    Timestamp : Fri Mar 26 08:18:21 PST 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    01/23/06 - 223369 fixed Vital delays from CLK to OQ
--    05/29/06 - CR 232324 -- Added timing checks for REV/SR wrt negedge CLKDIV
--    08/08/06 - CR 225414 -- Added 100 ps delay to data inputs to resolve
--               race condition when data/clk change at the same time.
--    01/08/08 - CR 458156 -- enabled TRISTATE_WIDTH to be 1 in DDR mode.
--    04/07/08 - CR 469973 -- Header Description fix
-- End Revision

----- CELL OSERDES -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;


library unisim;
use unisim.vpkg.all;

entity PLG is

  generic(

         SRTYPE			: string;

         INIT_LOADCNT		: bit_vector(3 downto 0)
    );

  port(
      LOAD		: out std_ulogic;

      C23		: in std_ulogic;
      C45		: in std_ulogic;
      C67		: in std_ulogic;
      CLK		: in std_ulogic;
      CLKDIV		: in std_ulogic;
      RST		: in std_ulogic;
      SEL		: in std_logic_vector (1 downto 0)
    );

end PLG;

architecture PLG_V OF PLG is


  constant DELAY_FFDCNT		: time       := 1 ps;
  constant DELAY_MXDCNT		: time       := 1 ps;
  constant DELAY_FFRST		: time       := 145 ps;

  constant MSB_SEL		: integer    := 1;

  signal CLK_ipd                : std_ulogic := 'X';
  signal CLKDIV_ipd             : std_ulogic := 'X';
  signal C23_ipd                : std_ulogic := 'X';
  signal C45_ipd                : std_ulogic := 'X';
  signal C67_ipd                : std_ulogic := 'X';
  signal GSR            : std_ulogic := '0';
  signal GSR_ipd                : std_ulogic := 'X';
  signal RST_ipd                : std_ulogic := 'X';
  signal SEL_ipd                : std_logic_vector(1 downto 0) := (others => 'X');

  signal CLK_dly                : std_ulogic := 'X';
  signal CLKDIV_dly             : std_ulogic := 'X';
  signal C23_dly                : std_ulogic := 'X';
  signal C45_dly                : std_ulogic := 'X';
  signal C67_dly                : std_ulogic := 'X';
  signal GSR_dly                : std_ulogic := '0';
  signal RST_dly                : std_ulogic := 'X';
  signal SEL_dly                : std_logic_vector(1 downto 0) := (others => 'X');

  signal q0			: std_ulogic := 'X';
  signal q1			: std_ulogic := 'X';
  signal q2			: std_ulogic := 'X';
  signal q3			: std_ulogic := 'X';

  signal qhr			: std_ulogic := 'X';
  signal qlr			: std_ulogic := 'X';

  signal mux			: std_ulogic := 'X';

  signal load_zd		: std_ulogic := 'X';

  signal AttrSRtype		: std_ulogic := 'X';

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  C23_dly        	 <= C23            	after 0 ps;
  C45_dly        	 <= C45            	after 0 ps;
  C67_dly        	 <= C67            	after 0 ps;
  CLK_dly        	 <= CLK            	after 0 ps;
  CLKDIV_dly     	 <= CLKDIV         	after 0 ps;
  GSR_dly        	 <= GSR            	after 0 ps;
  RST_dly        	 <= RST            	after 0 ps;
  SEL_dly        	 <= SEL            	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------


--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  begin
     if((SRTYPE = "ASYNC") or (SRTYPE = "async")) then
        AttrSRtype <= '1';
     elsif((SRTYPE = "SYNC") or (SRTYPE = "sync")) then
        AttrSRtype <= '0';
     end if;

     wait;
  end process prcs_init;
--####################################################################
--#####                          Counter                         #####
--####################################################################
  prcs_ff_cntr:process(qhr, CLK, GSR)
  variable q3_var		:  std_ulogic := TO_X01(INIT_LOADCNT(3));
  variable q2_var		:  std_ulogic := TO_X01(INIT_LOADCNT(2));
  variable q1_var		:  std_ulogic := TO_X01(INIT_LOADCNT(1));
  variable q0_var		:  std_ulogic := TO_X01(INIT_LOADCNT(0));
  begin
     if(GSR = '1') then
         q3_var		:= TO_X01(INIT_LOADCNT(3));
         q2_var		:= TO_X01(INIT_LOADCNT(2));
         q1_var		:= TO_X01(INIT_LOADCNT(1));
         q0_var		:= TO_X01(INIT_LOADCNT(0));
     elsif(GSR = '0') then
        case AttrSRtype is
           when '1' => 
           --------------- // async SET/RESET
                   if(qhr = '1') then
                      q0_var := '0';
                      q1_var := '0';
                      q2_var := '0';
                      q3_var := '0';
                   else
                      if(rising_edge(CLK)) then
                         q3_var := q2_var;
                         q2_var :=( NOT((NOT q0_var) and (NOT q2_var)) and q1_var);
                         q1_var := q0_var;
                         q0_var := mux;
                      end if;
                   end if;

           when '0' => 
           --------------- // sync SET/RESET
                   if(rising_edge(CLK)) then
                      if(qhr = '1') then
                         q0_var := '0';
                         q1_var := '0';
                         q2_var := '0';
                         q3_var := '0';
                      else
                         q3_var := q2_var;
                         q2_var :=( NOT((NOT q0_var) and (NOT q2_var)) and q1_var);
                         q1_var := q0_var;
                         q0_var := mux;
                      end if;
                   end if;

           when others => 
                   null;
           end case;

           q0 <= q0_var after DELAY_FFDCNT;
           q1 <= q1_var after DELAY_FFDCNT;
           q2 <= q2_var after DELAY_FFDCNT;
           q3 <= q3_var after DELAY_FFDCNT;

     end if;
  end process prcs_ff_cntr;
--####################################################################
--#####                     mux signal                           #####
--####################################################################
  prcs_mux_sel:process(sel, c23, c45, c67, q0, q1, q2, q3)
  begin
    case sel is
        when "00" =>
              mux <=  ((not q0) and  (not(c23 and q1))) after DELAY_MXDCNT;
        when "01" =>
              mux <=  ((not q1) and  (not(c45 and q2))) after DELAY_MXDCNT;
        when "10" =>
              mux <=  ((not q2) and  (not(c67 and q3))) after DELAY_MXDCNT;
        when "11" =>
              mux <=  (not (q3)) after DELAY_MXDCNT;
        when others =>
              mux <=  '0' after DELAY_MXDCNT;
    end case;
  end process prcs_mux_sel;
--####################################################################
--#####                    load signal                           #####
--####################################################################
  prcs_load_sel:process(sel, c23, c45, c67, q0, q1, q2, q3)
  begin
    case sel is
        when "00" =>
              load_zd <=  q0 after DELAY_MXDCNT;
        when "01" =>
              load_zd <=  (q0 and q1) after DELAY_MXDCNT;
        when "10" =>
              load_zd <=  (q0 and q2) after DELAY_MXDCNT;
        when "11" =>
              load_zd <=  (q0 and q3) after DELAY_MXDCNT;
        when others =>
              load_zd <=  '0' after DELAY_MXDCNT;
    end case;
  end process prcs_load_sel;
--####################################################################
--#####                 Low/High speed  FFs                      #####
--####################################################################
  prcs_lowspeed:process(clkdiv, rst)
  begin
      case AttrSRtype is
          when '1' => 
           --------------- // async SET/RESET
               if(rst = '1') then
                  qlr        <= '1' after DELAY_FFRST;
               else 
                  if(rising_edge(clkdiv)) then
                     qlr      <= '0' after DELAY_FFRST;
                  end if;
               end if;

          when '0' => 
           --------------- // sync SET/RESET
               if(rising_edge(clkdiv)) then
                  if(rst = '1') then
                     qlr      <= '1' after DELAY_FFRST;
                  else 
                     qlr      <= '0' after DELAY_FFRST;
                  end if;
               end if;
          when others => 
                  null;
      end case;
  end process  prcs_lowspeed;
----------------------------------------------------------------------
  prcs_highspeed:process(clk, rst)
  begin
      case AttrSRtype is
          when '1' => 
           --------------- // async SET/RESET
               if(rst = '1') then
                  qhr <= '1' after DELAY_FFDCNT;
               else 
                  if(rising_edge(clk)) then
                     qhr <= qlr after DELAY_FFDCNT;
                  end if;
               end if;

          when '0' => 
           --------------- // sync SET/RESET
               if(rising_edge(clk)) then
                  if(rst = '1') then
                     qhr <= '1' after DELAY_FFDCNT;
                  else 
                     qhr <= qlr after DELAY_FFDCNT;
                  end if;
               end if;
          when others => 
                  null;
      end case;
  end process  prcs_highspeed;


--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(load_zd)
  begin
      load <= load_zd;
  end process prcs_output;
--####################################################################


end PLG_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;


library unisim;
use unisim.vpkg.all;

entity IOOUT is

  generic(

         SERDES			: boolean	:= TRUE;
         SERDES_MODE		: string	:= "MASTER";
         DATA_RATE_OQ		: string	:= "DDR";
         DATA_WIDTH		: integer	:= 4;
         DDR_CLK_EDGE		: string	:= "SAME_EDGE";
         INIT_OQ		: bit		:= '0';
         SRVAL_OQ		: bit		:= '1';
         INIT_ORANK1		: bit_vector(5 downto 0) := "000000";
         INIT_ORANK2_PARTIAL	: bit_vector(3 downto 0) := "0000";
         INIT_LOADCNT		: bit_vector(3 downto 0) := "0000";

         SRTYPE			: string	:= "ASYNC"
    );

  port(
      OQ		: out std_ulogic;
      LOAD		: out std_ulogic;
      SHIFTOUT1		: out std_ulogic;
      SHIFTOUT2		: out std_ulogic;

      C			: in std_ulogic;
      CLKDIV		: in std_ulogic;
      D1		: in std_ulogic;
      D2		: in std_ulogic;
      D3		: in std_ulogic;
      D4		: in std_ulogic;
      D5		: in std_ulogic;
      D6		: in std_ulogic;
      OCE		: in std_ulogic;
      REV	        : in std_ulogic;
      SR	        : in std_ulogic;
      SHIFTIN1		: in std_ulogic;
      SHIFTIN2		: in std_ulogic
    );

end IOOUT;

architecture IOOUT_V OF IOOUT is

component PLG
  generic(
      SRTYPE            : string;
      INIT_LOADCNT      : bit_vector(3 downto 0)
      );
  port(
      LOAD              : out std_ulogic;

      C23               : in std_ulogic;
      C45               : in std_ulogic;
      C67               : in std_ulogic;
      CLK               : in std_ulogic;
      CLKDIV            : in std_ulogic;
      RST               : in std_ulogic;
      SEL               : in std_logic_vector (1 downto 0)
      );

end component;

  constant DELAY_FFD            : time       := 1 ps; 
  constant DELAY_FFCD           : time       := 1 ps; 
  constant DELAY_MXD	        : time       := 1 ps;
  constant DELAY_MXR1	        : time       := 1 ps;

  constant SWALLOW_PULSE        : time       := 2 ps;

  constant MAX_DATAWIDTH	: integer    := 4;

  signal C_ipd		        : std_ulogic := 'X';
  signal CLKDIV_ipd		: std_ulogic := 'X';
  signal D1_ipd			: std_ulogic := 'X';
  signal D2_ipd			: std_ulogic := 'X';
  signal D3_ipd			: std_ulogic := 'X';
  signal D4_ipd			: std_ulogic := 'X';
  signal D5_ipd			: std_ulogic := 'X';
  signal D6_ipd			: std_ulogic := 'X';
  signal GSR            : std_ulogic := '0';
  signal GSR_ipd		: std_ulogic := 'X';
  signal OCE_ipd	        : std_ulogic := 'X';
  signal REV_ipd	        : std_ulogic := 'X';
  signal SR_ipd		        : std_ulogic := 'X';
  signal SHIFTIN1_ipd		: std_ulogic := 'X';
  signal SHIFTIN2_ipd		: std_ulogic := 'X';

  signal C_dly	                : std_ulogic := 'X';
  signal CLKDIV_dly		: std_ulogic := 'X';
  signal D1_dly			: std_ulogic := 'X';
  signal D2_dly			: std_ulogic := 'X';
  signal D3_dly			: std_ulogic := 'X';
  signal D4_dly			: std_ulogic := 'X';
  signal D5_dly			: std_ulogic := 'X';
  signal D6_dly			: std_ulogic := 'X';
  signal GSR_dly		: std_ulogic := '0';
  signal OCE_dly	        : std_ulogic := 'X';
  signal REV_dly	        : std_ulogic := 'X';
  signal SR_dly		        : std_ulogic := 'X';
  signal SHIFTIN1_dly		: std_ulogic := 'X';
  signal SHIFTIN2_dly		: std_ulogic := 'X';

  signal OQ_zd			: std_ulogic := TO_X01(INIT_OQ);
  signal LOAD_zd		: std_ulogic := 'X';
  signal SHIFTOUT1_zd		: std_ulogic := 'X';
  signal SHIFTOUT2_zd		: std_ulogic := 'X';

  signal AttrDataRateOQ		: std_ulogic := 'X';
  signal AttrDataRateTQ		: std_logic_vector(1 downto 0) := (others => 'X');
  signal AttrDataWidth		: std_logic_vector(3 downto 0) := (others => 'X');
  signal AttrTriStateWidth	: std_logic_vector(1 downto 0) := (others => 'X');
  signal AttrMode		: std_ulogic := 'X';
  signal AttrDdrClkEdge		: std_ulogic := 'X';

  signal AttrSRtype		: std_logic_vector(5 downto 0) := (others => '1');

  signal AttrSerdes		: std_ulogic := 'X';

  signal d1r			: std_ulogic := 'X';
  signal d2r			: std_ulogic := 'X';
  signal d3r			: std_ulogic := 'X';
  signal d4r			: std_ulogic := 'X';
  signal d5r			: std_ulogic := 'X';
  signal d6r			: std_ulogic := 'X';

  signal d1rnk2			: std_ulogic := 'X';
  signal d2rnk2			: std_ulogic := 'X';
  signal d2nrnk2		: std_ulogic := 'X';
  signal d3rnk2			: std_ulogic := 'X';
  signal d4rnk2			: std_ulogic := 'X';
  signal d5rnk2			: std_ulogic := 'X';
  signal d6rnk2			: std_ulogic := 'X';

  signal data1			: std_ulogic := 'X';
  signal data2			: std_ulogic := 'X';
  signal data3			: std_ulogic := 'X';
  signal data4			: std_ulogic := 'X';
  signal data5			: std_ulogic := 'X';
  signal data6			: std_ulogic := 'X';

  signal ddr_data		: std_ulogic := 'X';
  signal odata_edge		: std_ulogic := 'X';
  signal sdata_edge		: std_ulogic := 'X';

  signal c23			: std_ulogic := 'X';
  signal c45			: std_ulogic := 'X';
  signal c67			: std_ulogic := 'X';

  signal sel			: std_logic_vector(1 downto 0) := (others => 'X');

  signal C2p			: std_ulogic := 'X';
  signal C3			: std_ulogic := 'X';

  signal loadint		: std_ulogic := 'X';

  signal seloq			: std_logic_vector(3 downto 0) := (others => 'X');

  signal oqsr			: std_ulogic := 'X';

  signal oqrev			: std_ulogic := 'X';

  signal sel1_4			: std_logic_vector(2 downto 0) := (others => 'X');
  signal sel5_6			: std_logic_vector(3 downto 0) := (others => 'X');

  signal plgcnt			: std_logic_vector(4 downto 0) := (others => 'X');

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  C_dly          	 <= C              	after 0 ps;
  CLKDIV_dly     	 <= CLKDIV         	after 0 ps;
  D1_dly         	 <= D1             	after 0 ps;
  D2_dly         	 <= D2             	after 0 ps;
  D3_dly         	 <= D3             	after 0 ps;
  D4_dly         	 <= D4             	after 0 ps;
  D5_dly         	 <= D5             	after 0 ps;
  D6_dly         	 <= D6             	after 0 ps;
  GSR_dly        	 <= GSR            	after 0 ps;
  OCE_dly        	 <= OCE            	after 0 ps;
  REV_dly        	 <= REV            	after 0 ps;
  SR_dly         	 <= SR             	after 0 ps;
  SHIFTIN1_dly   	 <= SHIFTIN1       	after 0 ps;
  SHIFTIN2_dly   	 <= SHIFTIN2       	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  variable AttrDataRateOQ_var		: std_ulogic := 'X';
  variable AttrDataWidth_var		: std_logic_vector(3 downto 0) := (others => 'X');
  variable AttrMode_var			: std_ulogic := 'X';
  variable AttrDdrClkEdge_var		: std_ulogic := 'X';
  variable AttrSerdes_var		: std_ulogic := 'X';

  begin
      -------------------- SERDES validity check --------------------
      if(SERDES = true) then
        AttrSerdes_var := '1';
      else
        AttrSerdes_var := '0';
      end if;

      ------------ SERDES_MODE validity check --------------------
      if((SERDES_MODE = "MASTER") or (SERDES_MODE = "master")) then
         AttrMode_var := '0';
      elsif((SERDES_MODE = "SLAVE") or (SERDES_MODE = "slave")) then
         AttrMode_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => "SERDES_MODE ",
             EntityName => "/IOOUT",
             GenericValue => SERDES_MODE,
             Unit => "",
             ExpectedValueMsg => " The legal values for this attribute are ",
             ExpectedGenericValue => " MASTER or SLAVE.",
             TailMsg => "",
             MsgSeverity => FAILURE 
         );
      end if;

      ------------------ DATA_RATE validity check ------------------

      if((DATA_RATE_OQ = "DDR") or (DATA_RATE_OQ = "ddr")) then
         AttrDataRateOQ_var := '0';
      elsif((DATA_RATE_OQ = "SDR") or (DATA_RATE_OQ = "sdr")) then
         AttrDataRateOQ_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DATA_RATE_OQ ",
             EntityName => "/IOOUT",
             GenericValue => DATA_RATE_OQ,
             Unit => "",
             ExpectedValueMsg => " The legal values for this attribute are ",
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
             EntityName => "/IOOUT",
             GenericValue => DATA_WIDTH,
             Unit => "",
             ExpectedValueMsg => " The legal values for this attribute are ",
             ExpectedGenericValue => " 2, 3, 4, 5, 6, 7, 8, or 10 ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;
      ------------ DATA_WIDTH /DATA_RATE combination check ------------
      if((DATA_RATE_OQ = "DDR") or (DATA_RATE_OQ = "ddr")) then
         case (DATA_WIDTH) is
             when 4|6|8|10  => null;
             when others       =>
                GenericValueCheckMessage
                (  HeaderMsg  => " Attribute Syntax Warning ",
                   GenericName => " DATA_WIDTH ",
                   EntityName => "/IOOUT",
                   GenericValue => DATA_WIDTH,
                   Unit => "",
                   ExpectedValueMsg => " The legal values for this attribute in DDR mode are ",
                   ExpectedGenericValue => " 4, 6, 8, or 10 ",
                   TailMsg => "",
                   MsgSeverity => Failure
                );
          end case;
      end if;

      if((DATA_RATE_OQ = "SDR") or (DATA_RATE_OQ = "sdr")) then
         case (DATA_WIDTH) is
             when 2|3|4|5|6|7|8  => null;
             when others       =>
                GenericValueCheckMessage
                (  HeaderMsg  => " Attribute Syntax Warning ",
                   GenericName => " DATA_WIDTH ",
                   EntityName => "/IOOUT",
                   GenericValue => DATA_WIDTH,
                   Unit => "",
                   ExpectedValueMsg => " The legal values for this attribute in SDR mode are ",
                   ExpectedGenericValue => " 2, 3, 4, 5, 6, 7 or 8.",
                   TailMsg => "",
                   MsgSeverity => Failure
                );
          end case;
      end if;

      ------------------ DDR_CLK_EDGE validity check ------------------

      if((DDR_CLK_EDGE = "SAME_EDGE") or (DDR_CLK_EDGE = "same_edge")) then
         AttrDdrClkEdge_var := '1';
      elsif((DDR_CLK_EDGE = "OPPOSITE_EDGE") or (DDR_CLK_EDGE = "opposite_edge")) then
         AttrDdrClkEdge_var := '0';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DDR_CLK_EDGE ",
             EntityName => "/IOOUT",
             GenericValue => DDR_CLK_EDGE,
             Unit => "",
             ExpectedValueMsg => " The legal values for this attribute are ",
             ExpectedGenericValue => " SAME_EDGE or OPPOSITE_EDGE ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;
      ------------------ DATA_RATE validity check ------------------
      if((SRTYPE = "ASYNC") or (SRTYPE = "async")) then
         AttrSRtype  <= (others => '1');
      elsif((SRTYPE = "SYNC") or (SRTYPE = "sync")) then
         AttrSRtype  <= (others => '0');
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " SRTYPE ",
             EntityName => "/IOOUT",
             GenericValue => SRTYPE,
             Unit => "",
             ExpectedValueMsg => " The legal values for this attribute are ",
             ExpectedGenericValue => " ASYNC or SYNC. ",
             TailMsg => "",
             MsgSeverity => ERROR
         );
      end if;

      AttrSerdes		<= AttrSerdes_var;
      AttrMode		<= AttrMode_var;
      AttrDataRateOQ	<= AttrDataRateOQ_var;
      AttrDataWidth	<= AttrDataWidth_var;
      AttrDdrClkEdge	<= AttrDdrClkEdge_var;

      plgcnt     <= AttrDataRateOQ_var & AttrDataWidth_var; 

      wait;
  end process prcs_init;
--###################################################################
--#####                   Concurrent exe                        #####
--###################################################################
   C2p    <= (C_dly and AttrDdrClkEdge) or 
             ((not C_dly) and (not AttrDdrClkEdge)); 
   C3     <= not C2p;
   sel1_4 <= AttrSerdes & loadint & AttrDataRateOQ;
   sel5_6 <= AttrSerdes & AttrMode & loadint & AttrDataRateOQ;
   LOAD_zd <= loadint;
   seloq   <= OCE_dly & AttrDataRateOQ & oqsr & oqrev;
   
   oqsr    <= ((AttrSRtype(1) and SR_dly and not (TO_X01(SRVAL_OQ)))
                               or
                (AttrSRtype(1) and REV_dly and (TO_X01(SRVAL_OQ))));

   oqrev   <= ((AttrSRtype(1) and SR_dly and (TO_X01(SRVAL_OQ)))
                               or
                (AttrSRtype(1) and REV_dly and not (TO_X01(SRVAL_OQ))));

   SHIFTOUT1_zd <= d3rnk2 and AttrMode;
   SHIFTOUT2_zd <= d4rnk2 and AttrMode;
--###################################################################
--#####                     q1rnk2 reg                          #####
--###################################################################
  prcs_D1_rnk2:process(C_dly, GSR_dly, REV_dly, SR_dly)
  variable d1rnk2_var         : std_ulogic := TO_X01(INIT_OQ);
  variable FIRST_TIME         : boolean    := true;
  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         d1rnk2_var  :=  TO_X01(INIT_OQ);
         FIRST_TIME  := false;
     elsif(GSR_dly = '0') then
        case AttrSRtype(1) is
           when '1' => 
           --------------- // async SET/RESET
                   if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_OQ) = '1')))) then
                      d1rnk2_var := TO_X01(SRVAL_OQ);
                   elsif(REV_dly = '1') then
                      d1rnk2_var := not TO_X01(SRVAL_OQ);
                   elsif((SR_dly = '0') and (REV_dly = '0')) then
                      if(OCE = '1') then
                         if(rising_edge(C_dly)) then
                            d1rnk2_var := data1;
                         end if;
                      elsif(OCE = '0') then
                         if(rising_edge(C_dly)) then
                            d1rnk2_var := OQ_zd;
                         end if;
                      end if;
                   end if;

           when '0' => 
           --------------- // sync SET/RESET
                   if(rising_edge(C_dly)) then
                      if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_OQ) = '1')))) then
                         d1rnk2_var := TO_X01(SRVAL_OQ);
                      elsif(REV_dly = '1') then
                         d1rnk2_var := not TO_X01(SRVAL_OQ);
                      elsif((SR_dly = '0') and (REV_dly = '0')) then
                         if(OCE = '1') then
                            d1rnk2_var := data1;
                         elsif(OCE = '0') then
                            d1rnk2_var := OQ_zd;
                         end if;
                      end if;
                   end if;

           when others =>
                   null;
                        
        end case;
     end if;

     d1rnk2  <= d1rnk2_var  after DELAY_FFD;

  end process prcs_D1_rnk2;
--###################################################################
--#####                     d2rnk2 reg                          #####
--###################################################################
  prcs_D2_rnk2:process(C2p, GSR_dly, REV_dly, SR_dly)
  variable d2rnk2_var         : std_ulogic := TO_X01(INIT_OQ);
  variable FIRST_TIME         : boolean    := true;
  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         d2rnk2_var  :=  TO_X01(INIT_OQ);
         FIRST_TIME  := false;
     elsif(GSR_dly = '0') then
        case AttrSRtype(1) is
           when '1' => 
           --------------- // async SET/RESET
                   if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_OQ) = '1')))) then
                      d2rnk2_var :=  TO_X01(SRVAL_OQ);
                   elsif(REV_dly = '1') then
                      d2rnk2_var :=  not TO_X01(SRVAL_OQ);
                   elsif((SR_dly = '0') and (REV_dly = '0')) then
                      if(OCE = '1') then
                         if(rising_edge(C2p)) then
                            d2rnk2_var := data2;
                         end if;
                      elsif(OCE = '0') then
                         if(rising_edge(C2p)) then
                            d2rnk2_var := OQ_zd;
                         end if;
                      end if;
                   end if;

           when '0' => 
           --------------- // sync SET/RESET
                   if(rising_edge(C2p)) then
                      if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_OQ) = '1')))) then
                         d2rnk2_var :=  TO_X01(SRVAL_OQ);
                      elsif(REV_dly = '1') then
                         d2rnk2_var :=  not TO_X01(SRVAL_OQ);
                      elsif((SR_dly = '0') and (REV_dly = '0')) then
                         if(OCE = '1') then
                            d2rnk2_var := data2;
                         elsif(OCE = '0') then
                            d2rnk2_var := OQ_zd;
                         end if;
                      end if;
                   end if;

           when others =>
                   null;
                        
        end case;
     end if;

     d2rnk2  <= d2rnk2_var  after DELAY_FFD;

  end process prcs_D2_rnk2;
--###################################################################
--#####                     d2nrnk2 reg                          #####
--###################################################################
  prcs_D2_nrnk2:process(C3, GSR_dly, REV_dly, SR_dly)
  variable d2nrnk2_var         : std_ulogic := TO_X01(INIT_OQ);
  variable FIRST_TIME          : boolean    := true;
  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         d2nrnk2_var  := TO_X01(INIT_OQ);
         FIRST_TIME  := false;
     elsif(GSR_dly = '0') then
        case AttrSRtype(1) is
           when '1' => 
           --------------- // async SET/RESET
                   if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_OQ) = '1')))) then
                      d2nrnk2_var :=  TO_X01(SRVAL_OQ);
                   elsif(REV_dly = '1') then
                      d2nrnk2_var :=  not TO_X01(SRVAL_OQ);
                   elsif((SR_dly = '0') and (REV_dly = '0')) then
                      if(OCE = '1') then
                         if(rising_edge(C3)) then
                            d2nrnk2_var := d2rnk2;
                         end if;
                      elsif(OCE = '0') then
                         if(rising_edge(C3)) then
                            d2nrnk2_var := OQ_zd;
                         end if;
                      end if;
                   end if;

           when '0' => 
           --------------- // sync SET/RESET
                   if(rising_edge(C3)) then
                      if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_OQ) = '1')))) then
                         d2nrnk2_var :=  TO_X01(SRVAL_OQ);
                      elsif(REV_dly = '1') then
                         d2nrnk2_var :=  not TO_X01(SRVAL_OQ);
                      elsif((SR_dly = '0') and (REV_dly = '0')) then
                         if(OCE = '1') then
                            d2nrnk2_var := d2rnk2;
                         elsif(OCE = '0') then
                            d2nrnk2_var := OQ_zd;
                         end if;
                      end if;
                   end if;

           when others =>
                   null;
                        
        end case;
     end if;

     d2nrnk2  <= d2nrnk2_var  after DELAY_FFD;

  end process prcs_D2_nrnk2;
--###################################################################
--#####              d3rnk2, d4rnk2, d5rnk2 and d6rnk2          #####
--###################################################################
  prcs_D3D4D5D6_rnk2:process(C_dly, GSR_dly, SR_dly)
  variable d6rnk2_var         : std_ulogic := TO_X01(INIT_ORANK2_PARTIAL(3));
  variable d5rnk2_var         : std_ulogic := TO_X01(INIT_ORANK2_PARTIAL(2));
  variable d4rnk2_var         : std_ulogic := TO_X01(INIT_ORANK2_PARTIAL(1));
  variable d3rnk2_var         : std_ulogic := TO_X01(INIT_ORANK2_PARTIAL(0));
  variable FIRST_TIME         : boolean    := true;

  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         d6rnk2_var  := TO_X01(INIT_ORANK2_PARTIAL(3));
         d5rnk2_var  := TO_X01(INIT_ORANK2_PARTIAL(2));
         d4rnk2_var  := TO_X01(INIT_ORANK2_PARTIAL(1));
         d3rnk2_var  := TO_X01(INIT_ORANK2_PARTIAL(0));
         FIRST_TIME  := false;
     elsif(GSR_dly = '0') then
        case AttrSRtype(2) is
           when '1' => 
           --------- // async SET/RESET  -- Not full featured FFs
                   if(SR_dly = '1') then
                      d6rnk2_var  := '0';
                      d5rnk2_var  := '0';
                      d4rnk2_var  := '0';
                      d3rnk2_var  := '0';
                   elsif(SR_dly = '0') then
                      if(rising_edge(C_dly)) then
                         d6rnk2_var  := data6;
                         d5rnk2_var  := data5;
                         d4rnk2_var  := data4;
                         d3rnk2_var  := data3;
                      end if;
                   end if;

           when '0' => 
           --------- // sync SET/RESET  -- Not full featured FFs
                   if(rising_edge(C_dly)) then
                      if(SR_dly = '1') then
                         d6rnk2_var  := '0';
                         d5rnk2_var  := '0';
                         d4rnk2_var  := '0';
                         d3rnk2_var  := '0';
                      elsif(SR_dly = '0') then
                         d6rnk2_var  := data6;
                         d5rnk2_var  := data5;
                         d4rnk2_var  := data4;
                         d3rnk2_var  := data3;
                      end if;
                   end if;

           when others =>
                   null;
                        
        end case;
     end if;

     d6rnk2  <= d6rnk2_var  after DELAY_FFD;
     d5rnk2  <= d5rnk2_var  after DELAY_FFD;
     d4rnk2  <= d4rnk2_var  after DELAY_FFD;
     d3rnk2  <= d3rnk2_var  after DELAY_FFD;

  end process prcs_D3D4D5D6_rnk2;

--//////////////////////////////////////////////////////////////////
--//                   First rank of FF for input data            //
--//////////////////////////////////////////////////////////////////

--###################################################################
--#####              d1r, d2r, d3r, d4r, d5r and d6r            #####
--###################################################################
  prcs_D1D2D3D4D5D6_r:process(CLKDIV_dly, GSR_dly, SR_dly)
  variable d6r_var            : std_ulogic := TO_X01(INIT_ORANK1(5));
  variable d5r_var            : std_ulogic := TO_X01(INIT_ORANK1(4));
  variable d4r_var            : std_ulogic := TO_X01(INIT_ORANK1(3));
  variable d3r_var            : std_ulogic := TO_X01(INIT_ORANK1(2));
  variable d2r_var            : std_ulogic := TO_X01(INIT_ORANK1(1));
  variable d1r_var            : std_ulogic := TO_X01(INIT_ORANK1(0));
  variable FIRST_TIME         : boolean    := true;

  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         d6r_var     := TO_X01(INIT_ORANK1(5));
         d5r_var     := TO_X01(INIT_ORANK1(4));
         d4r_var     := TO_X01(INIT_ORANK1(3));
         d3r_var     := TO_X01(INIT_ORANK1(2));
         d2r_var     := TO_X01(INIT_ORANK1(1));
         d1r_var     := TO_X01(INIT_ORANK1(0));
         FIRST_TIME  := false;
     elsif(GSR_dly = '0') then
        case AttrSRtype(3) is
           when '1' => 
           --------- // async SET/RESET  -- Not full featured FFs
                   if(SR_dly = '1') then
                      d6r_var  := '0';
                      d5r_var  := '0';
                      d4r_var  := '0';
                      d3r_var  := '0';
                      d2r_var  := '0';
                      d1r_var  := '0';
                   elsif(SR_dly = '0') then
                      if(rising_edge(CLKDIV_dly)) then
                         d6r_var  := D6_dly;
                         d5r_var  := D5_dly;
                         d4r_var  := D4_dly;
                         d3r_var  := D3_dly;
                         d2r_var  := D2_dly;
                         d1r_var  := D1_dly;
                      end if;
                   end if;

           when '0' => 
           --------- // sync SET/RESET  -- Not full featured FFs
                   if(rising_edge(CLKDIV_dly)) then
                      if(SR_dly = '1') then
                         d6r_var  := '0';
                         d5r_var  := '0';
                         d4r_var  := '0';
                         d3r_var  := '0';
                         d2r_var  := '0';
                         d1r_var  := '0';
                      elsif(SR_dly = '0') then
                         d6r_var  := D6_dly;
                         d5r_var  := D5_dly;
                         d4r_var  := D4_dly;
                         d3r_var  := D3_dly;
                         d2r_var  := D2_dly;
                         d1r_var  := D1_dly;
                      end if;
                   end if;

           when others =>
                   null;
                        
        end case;
     end if;

     d6r  <= d6r_var  after DELAY_FFCD;
     d5r  <= d5r_var  after DELAY_FFCD;
     d4r  <= d4r_var  after DELAY_FFCD;
     d3r  <= d3r_var  after DELAY_FFCD;
     d2r  <= d2r_var  after DELAY_FFCD;
     d1r  <= d1r_var  after DELAY_FFCD;

  end process prcs_D1D2D3D4D5D6_r;

--###################################################################
--#####                Muxes for 2nd rank of FFS                #####
--###################################################################
  prcs_data1234_mux:process(sel1_4, d1r, d2r, d3r, d4r, d2rnk2,
                                d3rnk2, d4rnk2, d5rnk2, d6rnk2)

  begin
     case sel1_4 is
           when "100" =>
                    data1 <= d3rnk2 after DELAY_MXR1;
                    data2 <= d4rnk2 after DELAY_MXR1;
                    data3 <= d5rnk2 after DELAY_MXR1;
                    data4 <= d6rnk2 after DELAY_MXR1;
           when "110" =>
                    data1 <= d1r    after DELAY_MXR1;
                    data2 <= d2r    after DELAY_MXR1;
                    data3 <= d3r    after DELAY_MXR1;
                    data4 <= d4r    after DELAY_MXR1;
           when "101" =>
                    data1 <= d2rnk2 after DELAY_MXR1;
                    data2 <= d3rnk2 after DELAY_MXR1;
                    data3 <= d4rnk2 after DELAY_MXR1;
                    data4 <= d5rnk2 after DELAY_MXR1;
           when "111" =>
                    data1 <= d1r    after DELAY_MXR1;
                    data2 <= d2r    after DELAY_MXR1;
                    data3 <= d3r    after DELAY_MXR1;
                    data4 <= d4r    after DELAY_MXR1;
           when others =>
                    data1 <= d3rnk2 after DELAY_MXR1;
                    data2 <= d4rnk2 after DELAY_MXR1;
                    data3 <= d5rnk2 after DELAY_MXR1;
                    data4 <= d6rnk2 after DELAY_MXR1;
     end case;

  end process prcs_data1234_mux;

----------------------------------------------------------------------

  prcs_data56_mux:process(sel5_6, d5r, d6r, d6rnk2, SHIFTIN1_dly,
                                                    SHIFTIN2_dly )

  begin
     case sel5_6 is
           when "1000" =>
                    data5 <=  SHIFTIN1_dly after DELAY_MXR1;
                    data6 <=  SHIFTIN2_dly after DELAY_MXR1;
           when "1010" =>
                    data5 <=  d5r after DELAY_MXR1;
                    data6 <=  d6r after DELAY_MXR1;
           when "1001" =>
                    data5 <=  d6rnk2 after DELAY_MXR1;
                    data6 <=  SHIFTIN1_dly after DELAY_MXR1;
           when "1011" =>
                    data5 <=  d5r after DELAY_MXR1;
                    data6 <=  d6r after DELAY_MXR1;
           when "1100" =>
                    data5 <=  '0' after DELAY_MXR1;
                    data6 <=  '0' after DELAY_MXR1;
           when "1110" =>
                    data5 <=  d5r after DELAY_MXR1;
                    data6 <=  d6r after DELAY_MXR1;
           when "1101" =>
                    data5 <=  d6rnk2 after DELAY_MXR1;
                    data6 <=  '0' after DELAY_MXR1;
           when "1111" =>
                    data5 <=  d5r after DELAY_MXR1;
                    data6 <=  d6r after DELAY_MXR1;

           when others =>
                    data5 <=  SHIFTIN1_dly after DELAY_MXR1;
                    data6 <=  SHIFTIN2_dly after DELAY_MXR1;
     end case;

  end process prcs_data56_mux;
--###################################################################
--#####        sdata_edge                                      ######
--###################################################################
  prcs_sdata:process(C_dly, C3, d1rnk2, d2nrnk2)
  begin
     sdata_edge <= ((d1rnk2 and C_dly) or (d2nrnk2 and C3)) after DELAY_MXD;
  end process prcs_sdata;

--###################################################################
--#####             odata_edge                                  #####
--###################################################################
  prcs_odata:process(C_dly, d1rnk2, d2rnk2)
  begin
     case C_dly is
           when '0' => 
                    odata_edge <= d2rnk2 after DELAY_MXD;
           when '1' => 
                    odata_edge <= d1rnk2 after DELAY_MXD;
           when others =>
                    odata_edge <= d2rnk2 after DELAY_MXD;
     end case;
  end process prcs_odata;
--###################################################################
--#####                 ddr_data                               ######
--###################################################################
  prcs_ddrdata:process(ddr_data, sdata_edge, odata_edge, AttrDdrClkEdge)
  begin
     ddr_data <= ((odata_edge and (not AttrDdrClkEdge)) or 
                    (sdata_edge and AttrDdrClkEdge)) after DELAY_MXD;
  end process prcs_ddrdata;

---////////////////////////////////////////////////////////////////////
---                       Outputs
---////////////////////////////////////////////////////////////////////
  prcs_OQ_mux:process(seloq, d1rnk2, ddr_data, OQ_zd, GSR_dly)

  variable FIRST_TIME : boolean := true;

  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
       OQ_zd    <=  TO_X01(INIT_OQ);
       FIRST_TIME := false;
     elsif(GSR_dly = '0') then
        case seloq is
           when "0001" | "0101"| "1001" | "1101" |
                "0X01" | "1X01"| "XX01" | "X001" |
                "X101" 
                       => 
                       OQ_zd <= '1' after DELAY_MXD;

           when "0010" | "0110"| "1010" | "1110" |
                "0X10" | "1X10"| "XX10" | "X010" |
                "X110" 
                       => 
                       OQ_zd <= '0' after DELAY_MXD;
   
           when "0011" | "0111"| "1011" | "1111" |
                "0X11" | "1X11"| "XX11" | "X011" |
                "X111" 
                       => 
                       OQ_zd <= '0' after DELAY_MXD;
   
           when "0000" =>
                       OQ_zd <= OQ_zd after DELAY_MXD;
   
           when "0100" =>
                       OQ_zd <= OQ_zd after DELAY_MXD;
   
           when "1000" =>
                       OQ_zd <= ddr_data after DELAY_MXD;
   
           when "1100" =>
                       OQ_zd <= d1rnk2 after DELAY_MXD;
   
           when others =>
-- CR 192533 the below "now > DEALY_MXD" is added since 
-- the INIT value of OQ_zd is getting wiped off by ddr_data=X at time 0.
-- At time 0, seloq is XXXX
                       if(now > DELAY_MXD) then
                         OQ_zd <= ddr_data after DELAY_MXD;
                       end if;
   
        end case;

     end if; 

  end process prcs_OQ_mux;
----------------------------------------------------------------------
-----------    Instant PLG  --------------------------------------
----------------------------------------------------------------------
  INST_PLG : PLG
  generic map (
      SRTYPE => SRTYPE,
      INIT_LOADCNT => INIT_LOADCNT
     )
  port map (
      LOAD       => loadint,

      C23        => c23,
      C45        => c45,
      C67        => c67,
      CLK        => C_dly,
      CLKDIV     => CLKDIV_dly,
      RST        => SR_dly,
      SEL        => sel
      );

--###################################################################
--#####           Set value of the counter in PLG             ##### 
--###################################################################
  prcs_plg_plgcnt:process
  begin
     wait for 10 ps;
     case plgcnt is
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
                report "WARNING : DATA_WIDTH or DATA_RATE has illegal values."
                severity Warning;
     end case;
    wait;
  end process prcs_plg_plgcnt;
         

--####################################################################

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(OQ_zd, LOAD_zd, SHIFTOUT1_zd, SHIFTOUT2_zd)
  begin
      OQ   <= OQ_zd;
      LOAD <= LOAD_zd;
      SHIFTOUT1 <= SHIFTOUT1_zd;
      SHIFTOUT2 <= SHIFTOUT2_zd;
  end process prcs_output;
--####################################################################


end IOOUT_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;


library unisim;
use unisim.vpkg.all;

entity IOT is

  generic(

         DATA_RATE_TQ		: string;
         TRISTATE_WIDTH		: integer	:= 1;
         DDR_CLK_EDGE		: string	:= "SAME_EDGE";
         INIT_TQ		: bit		:= '0';
         INIT_TRANK1		: bit_vector(3 downto 0) := "0000";
         SRVAL_TQ		: bit		:= '1';

         SRTYPE			: string	:= "ASYNC"
    );

  port(
      TQ		: out std_ulogic;

      C			: in std_ulogic;
      CLKDIV		: in std_ulogic;
      LOAD		: in std_ulogic;
      REV	        : in std_ulogic;
      SR	        : in std_ulogic;
      T1		: in std_ulogic;
      T2		: in std_ulogic;
      T3		: in std_ulogic;
      T4		: in std_ulogic;
      TCE		: in std_ulogic
    );

end IOT;

architecture IOT_V OF IOT is


  constant GSR_PULSE_TIME       : time       := 1 ns; 

  constant DELAY_FFD            : time       := 1 ps; 
  constant DELAY_MXD	        : time       := 1  ps;
  constant DELAY_ZERO	        : time       := 0  ps;
  constant DELAY_ONE	        : time       := 1  ps;
  constant SWALLOW_PULSE	: time       := 2  ps;

  constant MAX_DATAWIDTH	: integer    := 4;

  signal C_ipd			: std_ulogic := 'X';
  signal CLKDIV_ipd		: std_ulogic := 'X';
  signal GSR            : std_ulogic := '0';
  signal GSR_ipd		: std_ulogic := 'X';
  signal LOAD_ipd		: std_ulogic := 'X';
  signal T1_ipd			: std_ulogic := 'X';
  signal T2_ipd			: std_ulogic := 'X';
  signal T3_ipd			: std_ulogic := 'X';
  signal T4_ipd			: std_ulogic := 'X';
  signal TCE_ipd	        : std_ulogic := 'X';
  signal REV_ipd	        : std_ulogic := 'X';
  signal SR_ipd		        : std_ulogic := 'X';

  signal C_dly			: std_ulogic := 'X';
  signal CLKDIV_dly		: std_ulogic := 'X';
  signal GSR_dly		: std_ulogic := '0';
  signal LOAD_dly		: std_ulogic := 'X';
  signal T1_dly			: std_ulogic := 'X';
  signal T2_dly			: std_ulogic := 'X';
  signal T3_dly			: std_ulogic := 'X';
  signal T4_dly			: std_ulogic := 'X';
  signal TCE_dly	        : std_ulogic := 'X';
  signal REV_dly	        : std_ulogic := 'X';
  signal SR_dly		        : std_ulogic := 'X';

  signal TQ_zd			: std_ulogic := TO_X01(INIT_TQ);

  signal AttrDataRateTQ		: std_logic_vector(1 downto 0) := (others => 'X');
  signal AttrTriStateWidth	: std_logic_vector(1 downto 0) := (others => 'X');
  signal AttrDdrClkEdge		: std_ulogic := 'X';

  signal AttrSRtype		: std_logic_vector(1 downto 0) := (others => '1');

  signal t1r			: std_ulogic := 'X';
  signal t2r			: std_ulogic := 'X';
  signal t3r			: std_ulogic := 'X';
  signal t4r			: std_ulogic := 'X';

  signal qt1			: std_ulogic := 'X';
  signal qt2			: std_ulogic := 'X';
  signal qt2n			: std_ulogic := 'X';

  signal data1			: std_ulogic := 'X';
  signal data2			: std_ulogic := 'X';

  signal sdata_edge		: std_ulogic := 'X';
  signal odata_edge		: std_ulogic := 'X';
  signal ddr_data		: std_ulogic := 'X';

  signal C2p			: std_ulogic := 'X';
  signal C3			: std_ulogic := 'X';

  signal tqsel			: std_logic_vector(6 downto 0) := (others => 'X');
  signal tqsr			: std_ulogic := 'X';
  signal tqrev			: std_ulogic := 'X';

  signal sel			: std_logic_vector(4 downto 0) := (others => 'X');

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  C_dly          	 <= C              	after 0 ps;
  CLKDIV_dly     	 <= CLKDIV         	after 0 ps;
  GSR_dly        	 <= GSR            	after 0 ps;
  LOAD_dly       	 <= LOAD           	after 0 ps;
  REV_dly        	 <= REV            	after 0 ps;
  SR_dly         	 <= SR             	after 0 ps;
  T1_dly         	 <= T1             	after 0 ps;
  T2_dly         	 <= T2             	after 0 ps;
  T3_dly         	 <= T3             	after 0 ps;
  T4_dly         	 <= T4             	after 0 ps;
  TCE_dly        	 <= TCE            	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  variable AttrDataRateTQ_var		: std_logic_vector(1 downto 0) := (others => 'X');
  variable AttrTriStateWidth_var	: std_logic_vector(1 downto 0) := (others => 'X');
  variable AttrDdrClkEdge_var		: std_ulogic := 'X';

  begin

      ------------------ DATA_RATE_TQ validity check ------------------
-- FP check with Paul
      if((DATA_RATE_TQ = "BUF") or (DATA_RATE_TQ = "buf")) then
         AttrDataRateTQ_var := "00";
      elsif((DATA_RATE_TQ = "SDR") or (DATA_RATE_TQ = "sdr")) then
         AttrDataRateTQ_var := "01";
      elsif((DATA_RATE_TQ = "DDR") or (DATA_RATE_TQ = "ddr")) then
         AttrDataRateTQ_var := "10";
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DATA_RATE_TQ ",
             EntityName => "/X_IOOUT",
             GenericValue => DATA_RATE_TQ,
             Unit => "",
             ExpectedValueMsg => " The legal values for this attribute are ",
             ExpectedGenericValue => " BUF, SDR or DDR. ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;


      ------------------ TRISTATE_WIDTH validity check ------------------
      if((TRISTATE_WIDTH = 1) or (TRISTATE_WIDTH = 2) or  (TRISTATE_WIDTH = 4)) then
         case TRISTATE_WIDTH is
            when   1  =>  AttrTriStateWidth_var := "00";
            when   2  =>  AttrTriStateWidth_var := "01";
            when   4  =>  AttrTriStateWidth_var := "10";
            when others  =>
                   null;
         end case;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " TRISTATE_WIDTH ",
             EntityName => "/IOT",
             GenericValue => TRISTATE_WIDTH,
             Unit => "",
             ExpectedValueMsg => " The legal values for this attribute are ",
             ExpectedGenericValue => " 1, 2 or 4 ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

      ------------ TRISTATE_WIDTH /DATA_RATE combination check ------------
-- CR 458156 -- enabled TRISTATE_WIDTH to be 1 in DDR mode.
      if((DATA_RATE_TQ = "DDR") or (DATA_RATE_TQ = "ddr")) then
         case (TRISTATE_WIDTH) is
             when 1|2|4  => null;
             when others       =>
                GenericValueCheckMessage
                (  HeaderMsg  => " Attribute Syntax Warning ",
                   GenericName => " TRISTATE_WIDTH ",
                   EntityName => "/IOT",
                   GenericValue => TRISTATE_WIDTH,
                   Unit => "",
                   ExpectedValueMsg => " The legal values for this attribute in DDR mode are ",
                   ExpectedGenericValue => "1, 2 or 4",
                   TailMsg => "",
                   MsgSeverity => Failure
                );
          end case;
      end if;

      if((DATA_RATE_TQ = "SDR") or (DATA_RATE_TQ = "sdr")) then
         case (TRISTATE_WIDTH) is
             when 1  => null;
             when others       =>
                GenericValueCheckMessage
                (  HeaderMsg  => " Attribute Syntax Warning ",
                   GenericName => " TRISTATE_WIDTH ",
                   EntityName => "/IOT",
                   GenericValue => TRISTATE_WIDTH,
                   Unit => "",
                   ExpectedValueMsg => " The legal value for this attribute in SDR mode is",
                   ExpectedGenericValue => " 1. ",
                   TailMsg => "",
                   MsgSeverity => Failure
                );
          end case;
      end if;

      if((DATA_RATE_TQ = "BUF") or (DATA_RATE_TQ = "buf")) then
         case (TRISTATE_WIDTH) is
             when 1  => null;
             when others       =>
                GenericValueCheckMessage
                (  HeaderMsg  => " Attribute Syntax Warning ",
                   GenericName => " TRISTATE_WIDTH ",
                   EntityName => "/IOT",
                   GenericValue => TRISTATE_WIDTH,
                   Unit => "",
                   ExpectedValueMsg => " The legal value for this attribute in BUF mode is",
                   ExpectedGenericValue => " 1. ",
                   TailMsg => "",
                   MsgSeverity => Failure
                );
          end case;
      end if;

      ------------------ DDR_CLK_EDGE validity check ------------------

      if((DDR_CLK_EDGE = "SAME_EDGE") or (DDR_CLK_EDGE = "same_edge")) then
         AttrDdrClkEdge_var := '1';
      elsif((DDR_CLK_EDGE = "OPPOSITE_EDGE") or (DDR_CLK_EDGE = "opposite_edge")) then
         AttrDdrClkEdge_var := '0';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DDR_CLK_EDGE ",
             EntityName => "/IOT",
             GenericValue => DDR_CLK_EDGE,
             Unit => "",
             ExpectedValueMsg => " The legal values for this attribute are ",
             ExpectedGenericValue => " SAME_EDGE or OPPOSITE_EDGE ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;
      ------------------ DATA_RATE validity check ------------------
      if((SRTYPE = "ASYNC") or (SRTYPE = "async")) then
         AttrSRtype  <= (others => '1');
      elsif((SRTYPE = "SYNC") or (SRTYPE = "sync")) then
         AttrSRtype  <= (others => '0');
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " SRTYPE ",
             EntityName => "/IOT",
             GenericValue => SRTYPE,
             Unit => "",
             ExpectedValueMsg => " The legal values for this attribute are ",
             ExpectedGenericValue => " ASYNC or SYNC. ",
             TailMsg => "",
             MsgSeverity => ERROR
         );
      end if;
---------------------------------------------------------------------
     AttrDataRateTQ	<= AttrDataRateTQ_var;
     AttrTriStateWidth	<= AttrTriStateWidth_var;
     AttrDdrClkEdge	<= AttrDdrClkEdge_var;
     wait;
  end process prcs_init;
--###################################################################
--#####                   Concurrent exe                        #####
--###################################################################
   C2p    <= (C_dly and AttrDdrClkEdge) or 
             ((not C_dly) and (not AttrDdrClkEdge)); 
   C3     <= not C2p;

   tqsel  <= TCE & AttrDataRateTQ & AttrTriStateWidth & tqsr & tqrev;

   sel    <= load &  AttrDataRateTQ & AttrTriStateWidth;

   tqsr    <= ((AttrSRtype(1) and SR_dly and not (TO_X01(SRVAL_TQ)))
                               or
                (AttrSRtype(1) and REV_dly and (TO_X01(SRVAL_TQ))));

   tqrev   <= ((AttrSRtype(1) and SR_dly and (TO_X01(SRVAL_TQ)))
                               or
                (AttrSRtype(1) and REV_dly and not (TO_X01(SRVAL_TQ))));

--###################################################################
--#####                        qt1 reg                          #####
--###################################################################
  prcs_qt1_reg:process(C_dly, GSR_dly, REV_dly, SR_dly)
  variable qt1_var    : std_ulogic := TO_X01(INIT_TQ);
  variable FIRST_TIME : boolean    := true;
  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         qt1_var    :=  TO_X01(INIT_TQ);
         FIRST_TIME := false;
     elsif(GSR_dly = '0') then
        case AttrSRtype(1) is
           when '1' => 
           --------------- // async SET/RESET
                   if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_TQ) = '1')))) then
                      qt1_var  :=  TO_X01(SRVAL_TQ);
                   elsif(REV_dly = '1') then
                      qt1_var  :=  not TO_X01(SRVAL_TQ);
                   elsif((SR_dly = '0') and (REV_dly = '0')) then
                      if(TCE_dly = '1') then
                         if(rising_edge(C_dly)) then
                            qt1_var := data1;
                         end if;
                      end if;
                   end if;

           when '0' => 
           --------------- // sync SET/RESET
                   if(rising_edge(C_dly)) then
                      if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_TQ) = '1')))) then
                         qt1_var  :=  TO_X01(SRVAL_TQ);
                      elsif(REV_dly = '1') then
                         qt1_var  :=  not TO_X01(SRVAL_TQ);
                      elsif((SR_dly = '0') and (REV_dly = '0')) then
                         if(TCE_dly = '1') then
                            qt1_var := data1;
                         end if;
                      end if;
                   end if;

           when others =>
                   null;
                        
        end case;
     end if;

     qt1  <= qt1_var  after DELAY_FFD;

  end process prcs_qt1_reg;
--###################################################################
--#####                        qt2 reg                          #####
--###################################################################
  prcs_qt2_reg:process(C2p, GSR_dly, REV_dly, SR_dly)
  variable qt2_var    : std_ulogic := TO_X01(INIT_TQ);
  variable FIRST_TIME : boolean    := true;
  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         qt2_var    :=  TO_X01(INIT_TQ);
         FIRST_TIME := false;
     elsif(GSR_dly = '0') then
        case AttrSRtype(1) is
           when '1' => 
           --------------- // async SET/RESET
                   if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_TQ) = '1')))) then
                      qt2_var  :=  TO_X01(SRVAL_TQ);
                   elsif(REV_dly = '1') then
                      qt2_var  :=  not TO_X01(SRVAL_TQ);
                   elsif((SR_dly = '0') and (REV_dly = '0')) then
                      if(TCE_dly = '1') then
                         if(rising_edge(C2p)) then
                            qt2_var := data2;
                         end if;
                      end if;
                   end if;

           when '0' => 
           --------------- // sync SET/RESET
                   if(rising_edge(C2p)) then
                      if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_TQ) = '1')))) then
                         qt2_var  :=  TO_X01(SRVAL_TQ);
                      elsif(REV_dly = '1') then
                         qt2_var  :=  not TO_X01(SRVAL_TQ);
                      elsif((SR_dly = '0') and (REV_dly = '0')) then
                         if(TCE_dly = '1') then
                            qt2_var := data2;
                         end if;
                      end if;
                   end if;

           when others =>
                   null;
                        
        end case;
     end if;

     qt2  <= qt2_var  after DELAY_FFD;

  end process prcs_qt2_reg;

--###################################################################
--#####                        qt2n reg                          #####
--###################################################################
  prcs_qt2n_reg:process(C3, GSR_dly, REV_dly, SR_dly)
  variable qt2n_var   : std_ulogic := TO_X01(INIT_TQ);
  variable FIRST_TIME : boolean    := true;
  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         qt2n_var    :=  TO_X01(INIT_TQ);
         FIRST_TIME := false;
     elsif(GSR_dly = '0') then
        case AttrSRtype(1) is
           when '1' => 
           --------------- // async SET/RESET
                   if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_TQ) = '1')))) then
                      qt2n_var  :=  TO_X01(SRVAL_TQ);
                   elsif(REV_dly = '1') then
                      qt2n_var  :=  not TO_X01(SRVAL_TQ);
                   elsif((SR_dly = '0') and (REV_dly = '0')) then
                      if(TCE_dly = '1') then
                         if(rising_edge(C3)) then
                            qt2n_var := qt2;
                         end if;
                      end if;
                   end if;

           when '0' => 
           --------------- // sync SET/RESET
                   if(rising_edge(C3)) then
                      if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_TQ) = '1')))) then
                         qt2n_var  :=  TO_X01(SRVAL_TQ);
                      elsif(REV_dly = '1') then
                         qt2n_var  :=  not TO_X01(SRVAL_TQ);
                      elsif((SR_dly = '0') and (REV_dly = '0')) then
                         if(TCE_dly = '1') then
                            qt2n_var := qt2;
                         end if;
                      end if;
                   end if;

           when others =>
                   null;
                        
        end case;
     end if;

     qt2n  <= qt2n_var  after DELAY_FFD;

  end process prcs_qt2n_reg;

--###################################################################
--#####               t1r, t2r, t3r and tr4                     #####
--###################################################################
  prcs_t1rt2rt3rt4r_rnk1:process(CLKDIV_dly, GSR_dly, SR_dly)
  variable t1r_var    : std_ulogic := TO_X01(INIT_TRANK1(0));
  variable t2r_var    : std_ulogic := TO_X01(INIT_TRANK1(1));
  variable t3r_var    : std_ulogic := TO_X01(INIT_TRANK1(2));
  variable t4r_var    : std_ulogic := TO_X01(INIT_TRANK1(3));
  variable FIRST_TIME : boolean    := true;

  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         t1r_var    := TO_X01(INIT_TRANK1(0));
         t2r_var    := TO_X01(INIT_TRANK1(1));
         t3r_var    := TO_X01(INIT_TRANK1(2));
         t4r_var    := TO_X01(INIT_TRANK1(3));
         FIRST_TIME := false;
     elsif(GSR_dly = '0') then
        case AttrSRtype(1) is
           when '1' => 
           --------- // async SET/RESET  -- Not full featured FFs
                   if(SR_dly = '1') then
                      t1r_var  := '0';
                      t2r_var  := '0';
                      t3r_var  := '0';
                      t4r_var  := '0';
                   elsif(SR_dly = '0') then
                      if(rising_edge(CLKDIV_dly)) then
                         t1r_var  := T1_dly;
                         t2r_var  := T2_dly;
                         t3r_var  := T3_dly;
                         t4r_var  := T4_dly;
                      end if;
                   end if;

           when '0' => 
           --------- // sync SET/RESET  -- Not full featured FFs
                   if(rising_edge(C_dly)) then
                      if(SR_dly = '1') then
                         t1r_var  := '0';
                         t2r_var  := '0';
                         t3r_var  := '0';
                         t4r_var  := '0';
                      elsif(SR_dly = '0') then
                         t1r_var  := T1_dly;
                         t2r_var  := T2_dly;
                         t3r_var  := T3_dly;
                         t4r_var  := T4_dly;
                      end if;
                   end if;

           when others =>
                   null;
                        
        end case;
     end if;

     t1r  <= t1r_var  after DELAY_FFD;
     t2r  <= t2r_var  after DELAY_FFD;
     t3r  <= t3r_var  after DELAY_FFD;
     t4r  <= t4r_var  after DELAY_FFD;

  end process prcs_t1rt2rt3rt4r_rnk1;

--###################################################################
--#####                Muxes for tristate outputs               ##### 
--###################################################################
  prcs_data1_mux:process(sel, T1_dly, t1r, t3r)
  begin
    if (now > GSR_PULSE_TIME) then
       case sel is
          when "00000" | "10000" | "X0000" |
               "00100" | "10100" | "X0100" |
               "01001" | "11001" =>
                   data1 <= T1_dly after DELAY_MXD;
          when "01010" =>
                   data1 <= t3r after DELAY_MXD;
          when "11010" =>
                   data1 <= t1r after DELAY_MXD;
-- CR 458156 -- allow/enabled TRISTATE_WIDTH to be 1 in DDR mode. No func change, but removed warnings,
          when "01000" | "11000" | "X1000" => 
          when others =>
                  assert FALSE 
                  report "WARNING : DATA_RATE_TQ and/or  TRISTATE_WIDTH have illegal values."
                  severity Warning;
       end case;
    end if;
  end process prcs_data1_mux;
---------------------------------------------------------------
  prcs_data2_mux:process(sel, T2_dly, t2r, t4r)
  begin
    if (now > GSR_PULSE_TIME) then
       case sel is
          when "00000" | "00100" | "10000" |
               "10100" | "X0000" | "X0100" |
               "00X00" | "10X00" | "X0X00" |
               "01001" | "11001"  | "X1001"  =>
                   data2 <= T2_dly after DELAY_MXD;
          when "01010" =>
                   data2 <= t4r after DELAY_MXD;
          when "11010" =>
                   data2 <= t2r after DELAY_MXD;
-- CR 458156 -- allow/enabled TRISTATE_WIDTH to be 1 in DDR mode. No func change, but removed warnings,
          when "01000" | "11000" | "X1000" => 
          when others =>
                  assert FALSE 
                  report "WARNING : DATA_RATE_TQ and/or  TRISTATE_WIDTH have illegal values."
                  severity Warning;
       end case;
    end if;
  end process prcs_data2_mux;

--###################################################################
--#####        sdata_edge                                      ######
--###################################################################
  prcs_sdata:process(C_dly, C3, qt1, qt2n)
  begin
     sdata_edge <= ((qt1 and C_dly) or (qt2n and C3)) after DELAY_MXD;
  end process prcs_sdata;

--###################################################################
--#####             odata_edge                                  #####
--###################################################################
  prcs_odata:process(C_dly, qt1, qt2)
  begin
     case C_dly is
           when '0' => 
                    odata_edge <= qt2 after DELAY_MXD;
           when '1' => 
                    odata_edge <= qt1 after DELAY_MXD;
           when others =>
                    odata_edge <= '0' after DELAY_ZERO;
     end case;
  end process prcs_odata;
--###################################################################
--#####                 ddr_data                               ######
--###################################################################
  prcs_ddrdata:process(ddr_data, sdata_edge, odata_edge, AttrDdrClkEdge)
  begin
     ddr_data <= ((odata_edge and (not AttrDdrClkEdge)) or 
                    (sdata_edge and AttrDdrClkEdge)) after DELAY_ONE;
  end process prcs_ddrdata;

---////////////////////////////////////////////////////////////////////
---                       Outputs
---////////////////////////////////////////////////////////////////////
  prcs_TQ_mux:process(tqsel, data1, ddr_data, qt1, GSR_dly)

  variable FIRST_TIME : boolean := true;

  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
       TQ_zd    <=  TO_X01(INIT_TQ);
       FIRST_TIME := false;
     elsif(GSR_dly = '0') then
        if((tqsel(5 downto 4) = "01") and (tqsel(1 downto 0) = "01")) then
           TQ_zd <= '1' after DELAY_ONE;
        elsif((tqsel(5 downto 4) = "10") and (tqsel(1 downto 0) = "01")) then
           TQ_zd <= '1' after DELAY_ONE;
        elsif((tqsel(5 downto 4) = "01") and (tqsel(1 downto 0) = "10")) then
           TQ_zd <= '0' after DELAY_ONE;
        elsif((tqsel(5 downto 4) = "10") and (tqsel(1 downto 0) = "10")) then
           TQ_zd <= '0' after DELAY_ONE;
        elsif((tqsel(5 downto 4) = "01") and (tqsel(1 downto 0) = "11")) then
           TQ_zd <= '0' after DELAY_ONE;
        elsif((tqsel(5 downto 4) = "10") and (tqsel(1 downto 0) = "11")) then
           TQ_zd <= '0' after DELAY_ONE;
        elsif(tqsel(5 downto 2) = "0000") then
           TQ_zd <= data1 after DELAY_ONE;
        else

           case tqsel is
--              when "-01--01" | "-10--01" =>
--                    TQ_zd <= '1' after DELAY_ONE;
--              when "-01--10" | "-10--10" | "-01--11" | "-10--11" =>
--                    TQ_zd <= '0' after DELAY_ONE;
--              when "-----11" =>
--                    TQ_zd <= '0' after DELAY_ONE;
--              when "-0000--" =>
--                    TQ_zd <= data1 after DELAY_ONE;
              when "0010000" |  "0100100" |  "0101000" =>
                    TQ_zd <= TQ_zd after DELAY_ONE;
              when "1010000" =>
                    TQ_zd <= qt1 after DELAY_ONE;
              when "1100100" | "1101000" =>
                    TQ_zd <= ddr_data after DELAY_ONE;
              when others =>
                    TQ_zd <= ddr_data after DELAY_ONE;
           end case;
        end if;
     end if;
  end process prcs_TQ_mux;
--####################################################################

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(TQ_zd, GSR_dly)
  variable FIRST_TIME : boolean := true;
  begin
         TQ <= TQ_zd after SWALLOW_PULSE;
  end process prcs_output;
--####################################################################


end IOT_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;


library unisim;
use unisim.vpkg.all;

----- CELL OSERDES -----
-- //////////////////////////////////////////////////////////// 
-- //////////////////////// OSERDES /////////////////////////
-- //////////////////////////////////////////////////////////// 

entity OSERDES is

  generic(

      DDR_CLK_EDGE		: string	:= "SAME_EDGE";
      INIT_LOADCNT		: bit_vector(3 downto 0) := "0000";
      INIT_ORANK1		: bit_vector(5 downto 0) := "000000";
      INIT_ORANK2_PARTIAL	: bit_vector(3 downto 0) := "0000";
      INIT_TRANK1		: bit_vector(3 downto 0) := "0000";
      SERDES			: boolean	:= TRUE;
      SRTYPE			: string	:= "ASYNC";

      DATA_RATE_OQ	: string	:= "DDR";
      DATA_RATE_TQ	: string	:= "DDR";
      DATA_WIDTH	: integer	:= 4;
      INIT_OQ		: bit		:= '0';
      INIT_TQ		: bit		:= '0';
      SERDES_MODE	: string	:= "MASTER";
      SRVAL_OQ		: bit		:= '0';
      SRVAL_TQ		: bit		:= '0';
      TRISTATE_WIDTH	: integer	:= 4
      );


  port(
      OQ		: out std_ulogic;
      SHIFTOUT1		: out std_ulogic;
      SHIFTOUT2		: out std_ulogic;
      TQ		: out std_ulogic;

      CLK		: in std_ulogic;
      CLKDIV		: in std_ulogic;
      D1		: in std_ulogic;
      D2		: in std_ulogic;
      D3		: in std_ulogic;
      D4		: in std_ulogic;
      D5		: in std_ulogic;
      D6		: in std_ulogic;
      OCE		: in std_ulogic;
      REV	        : in std_ulogic;
      SHIFTIN1		: in std_ulogic;
      SHIFTIN2		: in std_ulogic;
      SR	        : in std_ulogic;
      T1		: in std_ulogic;
      T2		: in std_ulogic;
      T3		: in std_ulogic;
      T4		: in std_ulogic;
      TCE		: in std_ulogic
      );

end OSERDES;

architecture OSERDES_V OF OSERDES is


component IOOUT
  generic(
         SERDES                 : boolean;
         SERDES_MODE            : string;
         DATA_RATE_OQ           : string;
         DATA_WIDTH             : integer;
         DDR_CLK_EDGE           : string;
         INIT_OQ                : bit;
         SRVAL_OQ               : bit;
         INIT_ORANK1            : bit_vector(5 downto 0);
         INIT_ORANK2_PARTIAL    : bit_vector(3 downto 0);
         INIT_LOADCNT           : bit_vector(3 downto 0);
         SRTYPE                 : string

    );
  port(
      OQ                : out std_ulogic;
      LOAD              : out std_ulogic;
      SHIFTOUT1         : out std_ulogic;
      SHIFTOUT2         : out std_ulogic;

      C                 : in std_ulogic;
      CLKDIV            : in std_ulogic;
      D1                : in std_ulogic;
      D2                : in std_ulogic;
      D3                : in std_ulogic;
      D4                : in std_ulogic;
      D5                : in std_ulogic;
      D6                : in std_ulogic;
      OCE               : in std_ulogic;
      REV               : in std_ulogic;
      SR                : in std_ulogic;
      SHIFTIN1          : in std_ulogic;
      SHIFTIN2          : in std_ulogic
    );

end component;

component IOT
  generic(
      DATA_RATE_TQ           : string;
      TRISTATE_WIDTH         : integer;
      DDR_CLK_EDGE           : string;
      INIT_TQ                : bit;
      INIT_TRANK1            : bit_vector(3 downto 0);
      SRVAL_TQ               : bit;
      SRTYPE                 : string
    );
  port(
      TQ                : out std_ulogic;

      C                 : in std_ulogic;
      CLKDIV            : in std_ulogic;
      LOAD              : in std_ulogic;
      REV               : in std_ulogic;
      SR                 : in std_ulogic;
      T1                : in std_ulogic;
      T2                : in std_ulogic;
      T3                : in std_ulogic;
      T4                : in std_ulogic;
      TCE               : in std_ulogic
    );

end component;

  constant SYNC_PATH_DELAY	: time := 100 ps;

  signal load_int		: std_ulogic := 'X';

  signal CLK_ipd                : std_ulogic := 'X';
  signal CLKDIV_ipd             : std_ulogic := 'X';
  signal D1_ipd                 : std_ulogic := 'X';
  signal D2_ipd                 : std_ulogic := 'X';
  signal D3_ipd                 : std_ulogic := 'X';
  signal D4_ipd                 : std_ulogic := 'X';
  signal D5_ipd                 : std_ulogic := 'X';
  signal D6_ipd                 : std_ulogic := 'X';
  signal GSR            : std_ulogic := '0';
  signal GSR_ipd                : std_ulogic := 'X';
  signal OCE_ipd                : std_ulogic := 'X';
  signal REV_ipd                : std_ulogic := 'X';
  signal SR_ipd                  : std_ulogic := 'X';
  signal SHIFTIN1_ipd           : std_ulogic := 'X';
  signal SHIFTIN2_ipd           : std_ulogic := 'X';
  signal TCE_ipd                : std_ulogic := 'X';
  signal T1_ipd                 : std_ulogic := 'X';
  signal T2_ipd                 : std_ulogic := 'X';
  signal T3_ipd                 : std_ulogic := 'X';
  signal T4_ipd                 : std_ulogic := 'X';

  signal CLK_dly                : std_ulogic := 'X';
  signal CLKDIV_dly             : std_ulogic := 'X';
  signal D1_dly                 : std_ulogic := 'X';
  signal D2_dly                 : std_ulogic := 'X';
  signal D3_dly                 : std_ulogic := 'X';
  signal D4_dly                 : std_ulogic := 'X';
  signal D5_dly                 : std_ulogic := 'X';
  signal D6_dly                 : std_ulogic := 'X';
  signal GSR_dly                : std_ulogic := '0';
  signal OCE_dly                : std_ulogic := 'X';
  signal REV_dly                : std_ulogic := 'X';
  signal SR_dly                  : std_ulogic := 'X';
  signal SHIFTIN1_dly           : std_ulogic := 'X';
  signal SHIFTIN2_dly           : std_ulogic := 'X';
  signal TCE_dly                : std_ulogic := 'X';
  signal T1_dly                 : std_ulogic := 'X';
  signal T2_dly                 : std_ulogic := 'X';
  signal T3_dly                 : std_ulogic := 'X';
  signal T4_dly                 : std_ulogic := 'X';

  signal CLKD                   : std_ulogic := 'X';
  signal CLKDIVD                : std_ulogic := 'X';

  signal OQ_zd                  : std_ulogic := 'X';
  signal SHIFTOUT1_zd           : std_ulogic := 'X';
  signal SHIFTOUT2_zd           : std_ulogic := 'X';
  signal TQ_zd                  : std_ulogic := 'X';

begin

  CLK_dly        	 <= CLK            	after 0 ps;
  CLKDIV_dly     	 <= CLKDIV         	after 0 ps;
  D1_dly         	 <= D1             	after 100 ps;
  D2_dly         	 <= D2             	after 100 ps;
  D3_dly         	 <= D3             	after 100 ps;
  D4_dly         	 <= D4             	after 100 ps;
  D5_dly         	 <= D5             	after 100 ps;
  D6_dly         	 <= D6             	after 100 ps;
  GSR_dly        	 <= GSR            	after 0 ps;
  OCE_dly        	 <= OCE            	after 0 ps;
  REV_dly        	 <= REV            	after 0 ps;
  SHIFTIN1_dly   	 <= SHIFTIN1       	after 0 ps;
  SHIFTIN2_dly   	 <= SHIFTIN2       	after 0 ps;
  SR_dly         	 <= SR             	after 0 ps;
  T1_dly         	 <= T1             	after 100 ps;
  T2_dly         	 <= T2             	after 100 ps;
  T3_dly         	 <= T3             	after 100 ps;
  T4_dly         	 <= T4             	after 100 ps;
  TCE_dly        	 <= TCE            	after 0 ps;


--  Delay the clock 100 ps to match the HW
  CLKD    <= CLK_dly after 0 ps;
  CLKDIVD <= CLKDIV_dly after 0 ps;
------------------------------------------------------------------
-----------    Instant IOOUT  -----------------------------------
------------------------------------------------------------------
  INST_IOOUT: IOOUT
  generic map (
      SERDES			=> SERDES,
      SERDES_MODE		=> SERDES_MODE,
      DATA_RATE_OQ		=> DATA_RATE_OQ,
      DATA_WIDTH                => DATA_WIDTH,
      DDR_CLK_EDGE		=> DDR_CLK_EDGE,
      INIT_OQ			=> INIT_OQ,
      SRVAL_OQ			=> SRVAL_OQ,
      INIT_ORANK1		=> INIT_ORANK1,
      INIT_ORANK2_PARTIAL	=> INIT_ORANK2_PARTIAL,
      INIT_LOADCNT		=> INIT_LOADCNT,
      SRTYPE			=> SRTYPE
     )
  port map (
      OQ			=> OQ_zd,
      LOAD			=> LOAD_int,
      SHIFTOUT1			=> SHIFTOUT1_zd,
      SHIFTOUT2			=> SHIFTOUT2_zd,
      C				=> CLKD,
      CLKDIV			=> CLKDIVD,
      D1			=> D1_dly,
      D2			=> D2_dly,
      D3			=> D3_dly,
      D4			=> D4_dly,
      D5			=> D5_dly,
      D6			=> D6_dly,
      OCE			=> OCE_dly,
      REV			=> REV_dly,
      SR			=> SR_dly,
      SHIFTIN1			=> SHIFTIN1_dly,
      SHIFTIN2			=> SHIFTIN2_dly
      );
------------------------------------------------------------------
-----------    Instant TRI_OUT  ----------------------------------
------------------------------------------------------------------
  INST_IOT: IOT
  generic map (
      DATA_RATE_TQ		=> DATA_RATE_TQ,
      TRISTATE_WIDTH		=> TRISTATE_WIDTH,
      DDR_CLK_EDGE		=> DDR_CLK_EDGE,
      INIT_TQ			=> INIT_TQ,
      INIT_TRANK1		=> INIT_TRANK1,
      SRVAL_TQ			=> SRVAL_TQ,
      SRTYPE			=> SRTYPE
     )
  port map (
      TQ			=> TQ_zd,

      C				=> CLKD,
      CLKDIV			=> CLKDIVD,
      LOAD			=> LOAD_int,
      REV			=> REV_dly,
      SR			=> SR_dly,
      T1			=> T1_dly,
      T2			=> T2_dly,
      T3			=> T3_dly,
      T4			=> T4_dly,
      TCE			=> TCE_dly
      );

--####################################################################

  prcs_output:process
  begin
     OQ <= OQ_zd after SYNC_PATH_DELAY; 
     SHIFTOUT1 <= SHIFTOUT1_zd after SYNC_PATH_DELAY;
     SHIFTOUT2 <= SHIFTOUT2_zd after SYNC_PATH_DELAY;
     TQ <= TQ_zd after SYNC_PATH_DELAY; 
     wait on  OQ_zd, SHIFTOUT1_zd, SHIFTOUT2_zd, TQ_zd;
  end process prcs_output;

end OSERDES_V;

