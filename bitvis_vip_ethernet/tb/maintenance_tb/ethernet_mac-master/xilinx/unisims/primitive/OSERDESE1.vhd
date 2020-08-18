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
-- /___/   /\     Filename : OSERDESE1.vhd
-- \   \  /  \    Timestamp : Fri Oct  3 10:34:12 PDT 2008
--  \___\/\___\
--
-- Revision:
--    10/03/08 - Initial version.
--    12/05/08 - IR 495397.
--    01/15/09 - IR 503783 CLKPERF is not inverted for OFB/ofb_out.
--    01/25/09 - IR 504180 Fixed TQ.
--    02/06/09 - CR 507373 Removed IOCLKGLITCH and CLKB
--    03/16/09 - CR 512140 and 512139 -- sdf load errors
--    05/13/09 - CR 512569 -- error in fifo 
--    06/12/09 - CR 524743 Removed glitches on OQ in DOUT module.  
--    06/22/09 - CR 525700 TQ not functioning correctly
--    09/15/09 - CR 533445 OCBEXTEND not functioning correctly
--    10/15/09 - CR 536219 submod DOUT_OSERDESE1_VHD's INTERFACE_TYPE value fix 
--    12/16/09 - CR 541171 added sequential delays
--    01/04/10 - CR 527634 Speed improved modules FIFO_ADDR, FIFO_RESET and IODLYCTRL_NPR
--    02/26/10 - CR 550826 TFB fix in IODLYCTRL_NPR
--    04/12/10 - CR 551953 Enabled TRISTATE_WIDTH to be 1 in DDR mode.
-- End Revision
----- CELL OSERDESE1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

library unisim;
use unisim.vpkg.all;
use unisim.vcomponents.all;

----- START_SUBMOD_SELFHEAL_OSERDESE1_VHD
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

--////////////////////////////////////////////////////////////
--//////////// SELFHEAL_OSERDESE1_VHD /////////////////////////
--////////////////////////////////////////////////////////////
entity selfheal_oserdese1_vhd is
  port(
      SHO               : out std_ulogic;

      clkdiv		: in std_ulogic;
      dq3		: in std_ulogic;
      dq2		: in std_ulogic;
      dq1		: in std_ulogic;
      dq0		: in std_ulogic;
      srint		: in std_ulogic;
      rst		: in std_ulogic
      );
           
end selfheal_oserdese1_vhd;

architecture selfheal_oserdese1_vhd_V of selfheal_oserdese1_vhd is

  signal selfheal       : std_logic_vector (4 downto 0) := (others => '0');

  constant DELAY_FFD	: time       := 10 ps;
  constant DELAY_FFCD   : time       := 10 ps;
  constant DELAY_MXD	: time       := 10 ps;
  constant DELAY_MXR1	: time       := 10 ps;

  signal clkint		: std_ulogic := 'X';
--  signal comp23		: std_ulogic := 'X';
--  signal comp01		: std_ulogic := 'X';
  signal shr		: std_ulogic := 'X';

  signal error		: std_ulogic := 'X';
  signal rst_in		: std_ulogic := 'X';
  signal rst_self_heal	: std_ulogic := 'X';
  signal sho_zd		: std_ulogic := 'X';


begin
  clkint <= clkdiv and selfheal(4);
--  comp23 <= (((not selfheal(4)) xor (selfheal(3))) or ((not selfheal(4)) xor (selfheal(2))));
--  comp01 <= (((not selfheal(4)) xor (selfheal(1))) or ((not selfheal(4)) xor (selfheal(0))));
    error <=  (((not SELFHEAL(4) xor SELFHEAL(3)) xor  dq3) or ((not SELFHEAL(4) xor SELFHEAL(2)) xor  dq2) or ((not SELFHEAL(4) xor SELFHEAL(1)) xor  dq1) or ((not SELFHEAL(4) xor SELFHEAL(0)) xor  dq0));

    rst_in <= (not SELFHEAL(4) or not srint); 
 
    rst_self_heal <= (rst or  not shr);

--####################################################################
--#####                     Reset Flop                           #####
--####################################################################
  prcs_resetflop:process(clkint, rst)
  begin

     if(rst = '1') then
        shr <= '0' after DELAY_FFD;
     elsif(rising_edge(clkint)) then
             shr <= rst_in after DELAY_FFD;
     end if;
  end process prcs_resetflop;

--####################################################################
--#####                 Self Heal Flop                           #####
--####################################################################
  prcs_SelfHealFlop:process(clkint, rst_self_heal)
  begin

     if(rst_self_heal = '1')  then
        SHO <= '0' after DELAY_FFD;
     elsif(rising_edge(clkint)) then
        SHO <= error after DELAY_FFD;
     end if;
  end process prcs_SelfHealFlop;
--####################################################################
end selfheal_oserdese1_vhd_V;
----- END_SUBMOD_SELFHEAL_OSERDESE1_VHD
----- START_SUBMOD_PLG_OSERDESE1_VHD
--////////////////////////////////////////////////////////////
--//////////////// PLG_OSERDESE1_VHD /////////////////////////
--////////////////////////////////////////////////////////////

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

entity plg_oserdese1_vhd is
  port(
      IOCLK_GLITCH	: out std_ulogic;
      LOAD		: out std_ulogic;

      C23		: in std_ulogic;
      C45		: in std_ulogic;
      C67		: in std_ulogic;
      CLK		: in std_ulogic;
      CLKDIV		: in std_ulogic;
      RST		: in std_ulogic;
      SEL		: in std_logic_vector (1 downto 0)
    );

end plg_oserdese1_vhd;

architecture plg_oserdese1_vhd_V OF plg_oserdese1_vhd is

  component selfheal_oserdese1_vhd is
    port(
        SHO               : out std_ulogic;

        clkdiv		: in std_ulogic;
        dq3		: in std_ulogic;
        dq2		: in std_ulogic;
        dq1		: in std_ulogic;
        dq0		: in std_ulogic;
        srint		: in std_ulogic;
        rst		: in std_ulogic
        );
           
  end component;
  constant DELAY_FFDCNT		: time       := 1 ps;
  constant DELAY_MXDCNT		: time       := 1 ps;
  constant DELAY_FFRST		: time       := 145 ps;

  constant INIT_LOADCNT		: std_logic_vector (3 downto 0)  := (others => '0');

  constant MSB_SEL		: integer    := 1;

  signal AttrSRtype		: std_ulogic := '1';
  signal SelfHeal		: std_logic_vector (4 downto 0)  := (others => '0');

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

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  C23_dly        	 <= C23;
  C45_dly        	 <= C45;
  C67_dly        	 <= C67;
  CLK_dly        	 <= CLK;
  CLKDIV_dly     	 <= CLKDIV;
--  GSR_dly        	 <= GSR;
  RST_dly        	 <= RST;
  SEL_dly        	 <= SEL;

  --------------------
  --  BEHAVIOR SECTION
  --------------------


--####################################################################
--#####                          Counter                         #####
--####################################################################
  prcs_ff_cntr:process(qhr, CLK, GSR_dly)
  variable q3_var		:  std_ulogic := TO_X01(INIT_LOADCNT(3));
  variable q2_var		:  std_ulogic := TO_X01(INIT_LOADCNT(2));
  variable q1_var		:  std_ulogic := TO_X01(INIT_LOADCNT(1));
  variable q0_var		:  std_ulogic := TO_X01(INIT_LOADCNT(0));
  begin
     if(GSR_dly = '1') then
         q3_var		:= TO_X01(INIT_LOADCNT(3));
         q2_var		:= TO_X01(INIT_LOADCNT(2));
         q1_var		:= TO_X01(INIT_LOADCNT(1));
         q0_var		:= TO_X01(INIT_LOADCNT(0));
     elsif(GSR_dly = '0') then
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

----------------------------------------------------------------------
-----------    Instance SELFHEAL_OSERDESE1_VHD   ---------------------
----------------------------------------------------------------------


  inst_fixcntr:selfheal_oserdese1_vhd
  port map (
      SHO        => IOCLK_GLITCH,

      CLKDIV     => CLKDIV_dly,
      DQ3        => q3,
      DQ2        => q2,
      DQ1        => q1,
      DQ0        => q0,
      SRINT      => qlr,
      RST        => RST_dly
      );
--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(load_zd)
  begin
      load <= load_zd;
  end process prcs_output;
--####################################################################


end plg_oserdese1_vhd_V;
----- END_SUBMOD_PLG_OSERDESE1_VHD
----- START_SUBMOD_RANK12D_OSERDESE1_VHD
--////////////////////////////////////////////////////////////
--//////////////// RANK12D_OSERDESE1_VHD /////////////////////
--////////////////////////////////////////////////////////////
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

entity RANK12D_OSERDESE1_VHD is

  generic(

         DATA_RATE_OQ		: string	:= "DDR";
         DATA_WIDTH		: integer	:= 4;
         SERDES_MODE		: string	:= "MASTER";
         INIT_OQ		: bit		:= '0';
         SRVAL_OQ		: bit		:= '1'
    );

  port(
      DATA1_OUT		: out std_ulogic;
      DATA2_OUT		: out std_ulogic;
      IOCLK_GLITCH	: out std_ulogic;
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
      D2RNK2		: in std_ulogic;
      OCE		: in std_ulogic;
      SR	        : in std_ulogic;
      SHIFTIN1		: in std_ulogic;
      SHIFTIN2		: in std_ulogic
    );

end RANK12D_OSERDESE1_VHD;

architecture RANK12D_OSERDESE1_VHD_V OF RANK12D_OSERDESE1_VHD is

component PLG_OSERDESE1_VHD 
  port(
      IOCLK_GLITCH      : out std_ulogic;
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

  signal C_dly	                : std_ulogic := 'X';
  signal CLKDIV_dly		: std_ulogic := 'X';
  signal D1_dly			: std_ulogic := 'X';
  signal D2_dly			: std_ulogic := 'X';
  signal D3_dly			: std_ulogic := 'X';
  signal D4_dly			: std_ulogic := 'X';
  signal D5_dly			: std_ulogic := 'X';
  signal D6_dly			: std_ulogic := 'X';
  signal D2RNK2_dly		: std_ulogic := 'X';
  signal GSR_dly		: std_ulogic := '0';
  signal OCE_dly	        : std_ulogic := 'X';
  signal REV_dly	        : std_ulogic := 'X';
  signal SR_dly		        : std_ulogic := 'X';
  signal SHIFTIN1_dly		: std_ulogic := 'X';
  signal SHIFTIN2_dly		: std_ulogic := 'X';

  signal DATA1_zd		: std_ulogic := 'X';
  signal DATA2_zd		: std_ulogic := 'X';
  signal IOCLK_GLITCH_zd	: std_ulogic := 'X';
  signal LOAD_zd		: std_ulogic := 'X';
  signal SHIFTOUT1_zd		: std_ulogic := 'X';
  signal SHIFTOUT2_zd		: std_ulogic := 'X';

  signal AttrDdrClkEdge_int	: std_ulogic := '1';
  signal AttrSerdes_int		: std_ulogic := '1';
  signal AttrSRtype_int		: std_logic_vector(3 downto 0) := (others => '1');
  signal AttrsSelfHeal_int	: std_logic_vector(4 downto 0) := (others => '0');

  signal AttrDataRateOQ		: std_ulogic := 'X';
  signal AttrDataWidth		: std_logic_vector(3 downto 0) := (others => 'X');
  signal AttrMode		: std_ulogic := 'X';

  signal d1r			: std_ulogic := 'X';
  signal d2r			: std_ulogic := 'X';
  signal d3r			: std_ulogic := 'X';
  signal d4r			: std_ulogic := 'X';
  signal d5r			: std_ulogic := 'X';
  signal d6r			: std_ulogic := 'X';

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

-- FP  signal ddr_data		: std_ulogic := 'X';
-- FP  signal odata_edge		: std_ulogic := 'X';
-- FP  signal sdata_edge		: std_ulogic := 'X';

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

  C_dly          	 <= C;
  CLKDIV_dly     	 <= CLKDIV;
  D1_dly         	 <= D1;
  D2_dly         	 <= D2;
  D3_dly         	 <= D3;
  D4_dly         	 <= D4;
  D5_dly         	 <= D5;
  D6_dly         	 <= D6;
  D2RNK2_dly         	 <= D2RNK2;
  OCE_dly        	 <= OCE;
  SR_dly         	 <= SR;
  SHIFTIN1_dly   	 <= SHIFTIN1;
  SHIFTIN2_dly   	 <= SHIFTIN2;

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

  begin
      ------------ SERDES_MODE --------------------
      if((SERDES_MODE = "MASTER") or (SERDES_MODE = "master")) then
         AttrMode_var := '0';
      elsif((SERDES_MODE = "SLAVE") or (SERDES_MODE = "slave")) then
         AttrMode_var := '1';
      end if;

      ------------------ DATA_RATE ------------------

      if((DATA_RATE_OQ = "DDR") or (DATA_RATE_OQ = "ddr")) then
         AttrDataRateOQ_var := '0';
      elsif((DATA_RATE_OQ = "SDR") or (DATA_RATE_OQ = "sdr")) then
         AttrDataRateOQ_var := '1';
      end if;

      ------------------ DATA_WIDTH ------------------
      if((DATA_WIDTH = 2) or (DATA_WIDTH = 3) or  (DATA_WIDTH = 4) or
         (DATA_WIDTH = 5) or (DATA_WIDTH = 6) or  (DATA_WIDTH = 7) or
         (DATA_WIDTH = 8) or (DATA_WIDTH = 10)) then
         AttrDataWidth_var := CONV_STD_LOGIC_VECTOR(DATA_WIDTH, MAX_DATAWIDTH); 
      end if;

      --------------------------------------------------
      AttrDataRateOQ	<= AttrDataRateOQ_var;
      AttrDataWidth	<= AttrDataWidth_var;
      AttrMode		<= AttrMode_var;

      plgcnt     <= AttrDataRateOQ_var & AttrDataWidth_var; 

      wait;
  end process prcs_init;
--###################################################################
--#####                   Concurrent exe                        #####
--###################################################################
   C2p    <= (C_dly and AttrDdrClkEdge_int) or 
             ((not C_dly) and (not AttrDdrClkEdge_int)); 
   C3     <= not C2p;
   sel1_4 <= AttrSerdes_int & loadint & AttrDataRateOQ;
   sel5_6 <= AttrSerdes_int & AttrMode & loadint & AttrDataRateOQ;
   seloq   <= OCE_dly & AttrDataRateOQ & oqsr & oqrev;
   
   oqsr    <= ((not AttrSRtype_int(1)) and SR_dly and not (TO_X01(SRVAL_OQ)));

   oqrev   <= ((not AttrSRtype_int(1)) and SR_dly and (TO_X01(SRVAL_OQ)));

   DATA1_zd <= data1;
   DATA2_zd <= data2;
   LOAD_zd <= loadint;
   SHIFTOUT1_zd <= d3rnk2 and AttrMode;
   SHIFTOUT2_zd <= d4rnk2 and AttrMode;

--###################################################################
--#####                     q1rnk2 / d1rnk2 reg                 #####
--###################################################################

--###################################################################
--#####                     d2rnk2 reg                          #####
--###################################################################

--###################################################################
--#####                     d2nrnk2 reg                          #####
--###################################################################

--###################################################################
--#####              d3rnk2, d4rnk2, d5rnk2 and d6rnk2          #####
--###################################################################
  prcs_D3D4D5D6_rnk2:process(C_dly, GSR_dly)
  variable d6rnk2_var         : std_ulogic := '0';
  variable d5rnk2_var         : std_ulogic := '0';
  variable d4rnk2_var         : std_ulogic := '0';
  variable d3rnk2_var         : std_ulogic := '0';
  variable FIRST_TIME         : boolean    := true;

  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         d6rnk2_var  := '0';
         d5rnk2_var  := '0';
         d4rnk2_var  := '0';
         d3rnk2_var  := '0';
         FIRST_TIME  := false;
     elsif(GSR_dly = '0') then
           --------- // sync SET/RESET  -- Not full featured FFs
         if(rising_edge(C_dly)) then
            if(SR_dly = '1') then
               d6rnk2_var  := '0';
               d5rnk2_var  := '0';
               d4rnk2_var  := '0';
               d3rnk2_var  := '0';
            else
               d6rnk2_var  := data6;
               d5rnk2_var  := data5;
               d4rnk2_var  := data4;
               d3rnk2_var  := data3;
            end if;
         end if;
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
  variable d6r_var            : std_ulogic := '0';
  variable d5r_var            : std_ulogic := '0';
  variable d4r_var            : std_ulogic := '0';
  variable d3r_var            : std_ulogic := '0';
  variable d2r_var            : std_ulogic := '0';
  variable d1r_var            : std_ulogic := '0';
  variable FIRST_TIME         : boolean    := true;

  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         d6r_var     := '0';
         d5r_var     := '0';
         d4r_var     := '0';
         d3r_var     := '0';
         d2r_var     := '0';
         d1r_var     := '0';
         FIRST_TIME  := false;
     elsif(GSR_dly = '0') then
           --------- // sync SET/RESET  -- Not full featured FFs
         if(rising_edge(CLKDIV_dly)) then
            if(SR_dly = '1') then
               d6r_var  := '0';
               d5r_var  := '0';
               d4r_var  := '0';
               d3r_var  := '0';
               d2r_var  := '0';
               d1r_var  := '0';
            else
               d6r_var  := D6_dly;
               d5r_var  := D5_dly;
               d4r_var  := D4_dly;
               d3r_var  := D3_dly;
               d2r_var  := D2_dly;
               d1r_var  := D1_dly;
            end if;
         end if;
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
  prcs_data1234_mux:process(sel1_4, d1r, d2r, d3r, d4r, D2RNK2_dly,
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
                    data1 <= D2RNK2_dly after DELAY_MXR1;
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

--###################################################################
--#####             odata_edge                                  #####
--###################################################################

--###################################################################
--#####                 ddr_data                               ######
--###################################################################

----------------------------------------------------------------------
-----------    Instant PLG  --------------------------------------
----------------------------------------------------------------------
  INST_PLG : PLG_OSERDESE1_VHD
  port map (
      IOCLK_GLITCH => IOCLK_GLITCH_zd,
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
  prcs_output:process(DATA1_zd, DATA2_zd, IOCLK_GLITCH_zd,  LOAD_zd, SHIFTOUT1_zd, SHIFTOUT2_zd)
  begin
      DATA1_OUT        <= DATA1_zd;
      DATA2_OUT        <= DATA2_zd; 
      IOCLK_GLITCH <= IOCLK_GLITCH_zd;
      LOAD         <= LOAD_zd;
      SHIFTOUT1    <= SHIFTOUT1_zd;
      SHIFTOUT2    <= SHIFTOUT2_zd;
  end process prcs_output;
--####################################################################


end RANK12D_OSERDESE1_VHD_V;
----- END_SUBMOD_RANK12D_OSERDESE1_VHD
----- START_SUBMOD_TRIF_OSERDESE1_VHD
--////////////////////////////////////////////////////////////
--//////////////// TRIF_OSERDESE1_VHD ////////////////////////
--////////////////////////////////////////////////////////////
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;



entity TRIF_OSERDESE1_VHD is

  generic(

         DATA_RATE_TQ		: string;
         TRISTATE_WIDTH		: integer	:= 1;
         INIT_TQ		: bit		:= '0';
         SRVAL_TQ		: bit		:= '1'
    );

  port(
      DATA1_OUT		: out std_ulogic;
      DATA2_OUT		: out std_ulogic;

      C			: in std_ulogic;
      CLKDIV		: in std_ulogic;
      LOAD		: in std_ulogic;
      SR	        : in std_ulogic;
      T1		: in std_ulogic;
      T2		: in std_ulogic;
      T3		: in std_ulogic;
      T4		: in std_ulogic;
      TCE		: in std_ulogic
    );

end TRIF_OSERDESE1_VHD;

architecture TRIF_OSERDESE1_VHD_V OF TRIF_OSERDESE1_VHD is


  constant GSR_PULSE_TIME       : time       := 1 ns; 

  constant DELAY_FFD            : time       := 1 ps; 
  constant DELAY_MXD	        : time       := 1  ps;
  constant DELAY_ZERO	        : time       := 0  ps;
  constant DELAY_ONE	        : time       := 1  ps;
  constant SWALLOW_PULSE	: time       := 2  ps;

  constant MAX_DATAWIDTH	: integer    := 4;

  signal AttrSRtype_int		: std_logic_vector(1 downto 0) := (others => '1');
  signal AttrDdrClkEdge_int	: std_ulogic := '1';
  constant INIT_TRANK1_int	: std_logic_vector(3 downto 0) := (others => '0');

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
--  signal tqsr			: std_ulogic := 'X';
--  signal tqrev			: std_ulogic := 'X';

  signal sel			: std_logic_vector(4 downto 0) := (others => 'X');

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  C_dly          	 <= C;
  CLKDIV_dly     	 <= CLKDIV;
  GSR_dly        	 <= '0';
  LOAD_dly       	 <= LOAD;
  SR_dly         	 <= SR;
  T1_dly         	 <= T1;
  T2_dly         	 <= T2;
  T3_dly         	 <= T3;
  T4_dly         	 <= T4;
  TCE_dly        	 <= TCE;

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
      end if;

---------------------------------------------------------------------

     AttrDataRateTQ	<= AttrDataRateTQ_var;
     AttrTriStateWidth	<= AttrTriStateWidth_var;
     wait;
  end process prcs_init;
--###################################################################
--#####                   Concurrent exe                        #####
--###################################################################

   sel    <= load &  AttrDataRateTQ & AttrTriStateWidth;


--###################################################################
--#####               t1r, t2r, t3r and tr4                     #####
--###################################################################
  prcs_t1rt2rt3rt4r_rnk1:process(CLKDIV_dly, GSR_dly, SR_dly)
  variable t1r_var    : std_ulogic := TO_X01(INIT_TRANK1_int(0));
  variable t2r_var    : std_ulogic := TO_X01(INIT_TRANK1_int(1));
  variable t3r_var    : std_ulogic := TO_X01(INIT_TRANK1_int(2));
  variable t4r_var    : std_ulogic := TO_X01(INIT_TRANK1_int(3));
  variable FIRST_TIME : boolean    := true;

  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         t1r_var    := TO_X01(INIT_TRANK1_int(0));
         t2r_var    := TO_X01(INIT_TRANK1_int(1));
         t3r_var    := TO_X01(INIT_TRANK1_int(2));
         t4r_var    := TO_X01(INIT_TRANK1_int(3));
         FIRST_TIME := false;
     elsif(GSR_dly = '0') then
           --------- // sync SET/RESET  -- Not full featured FFs
         if(rising_edge(CLKDIV_dly)) then
            if(SR_dly = '1') then
               t1r_var  := '0';
               t2r_var  := '0';
               t3r_var  := '0';
               t4r_var  := '0';
            else
               t1r_var  := T1_dly;
               t2r_var  := T2_dly;
               t3r_var  := T3_dly;
               t4r_var  := T4_dly;
            end if;
         end if;
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
-- CR 551953 -- allow/enabled TRISTATE_WIDTH to be 1 in DDR mode. No func change, but removed warnings,
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
-- CR 551953 -- allow/enable TRISTATE_WIDTH to be 1 in DDR mode. No func change, but removed warnings,
          when "01000" | "11000" | "X1000" => 
          when others =>
                  assert FALSE 
                  report "WARNING : DATA_RATE_TQ and/or  TRISTATE_WIDTH have illegal values."
                  severity Warning;
       end case;
    end if;
  end process prcs_data2_mux;


--###################################################################
--#####                       Outputs                           ##### 
--###################################################################
   DATA1_OUT <= data1;
   DATA2_OUT <= data2;
--####################################################################


end TRIF_OSERDESE1_VHD_V;
----- END_SUBMOD_TRIF_OSERDESE1_VHD
----- START_SUBMOD_TXBUFFER_OSERDESE1_VHD
--////////////////////////////////////////////////////////////
--//////////////// TXBUFFER_OSERDESE1_VHD /////////////////////////
--////////////////////////////////////////////////////////////

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

entity TXBUFFER_OSERDESE1_VHD is
  port(
      EXTRA	        : out std_ulogic;
      IODELAY_STATE	: out std_ulogic;
      QMUX1		: out std_ulogic;
      QMUX2		: out std_ulogic;
      TMUX1		: out std_ulogic;
      TMUX2		: out std_ulogic;

      BUFO		: in std_ulogic;
      BUFOP		: in std_ulogic;
      CLK		: in std_ulogic;
      CLKDIV		: in std_ulogic;
      D1		: in std_ulogic;
      D2		: in std_ulogic;
      DDR3_DATA		: in std_ulogic;
      DDR3_MODE		: in std_ulogic;
      ODELAY_USED	: in std_ulogic;
      ODV		: in std_ulogic;
      T1		: in std_ulogic;
      T2		: in std_ulogic;
      TRIF		: in std_ulogic;
      RST		: in std_ulogic;
      WC		: in std_ulogic
    );

end TXBUFFER_OSERDESE1_VHD;

architecture TXBUFFER_OSERDESE1_VHD_V OF TXBUFFER_OSERDESE1_VHD is

  component FIFO_TDPIPE_OSERDESE1_VHD is
    port(
        MUXOUT          : out std_ulogic;
  
        DIN		: in std_ulogic;
        QWC		: in std_logic_vector (1 downto 0);
        QRD		: in std_logic_vector (1 downto 0);
        RD_GAP1		: in std_ulogic;
        BUFG_CLK	: in std_ulogic;
        BUFO_CLK	: in std_ulogic;
        RST_BUFG_P	: in std_ulogic;
        RST_BUFO_P	: in std_ulogic;
        DDR3_DATA	: in std_ulogic;
        EXTRA		: in std_ulogic;
        ODV		: in std_ulogic;
        DDR3_MODE	: in std_ulogic
        );
  end component;

  component FIFO_RESET_OSERDESE1_VHD is
    port(
        RST_BUFG_P	: out std_ulogic;
        RST_BUFG_WC	: out std_ulogic;
        RST_BUFO_P	: out std_ulogic;
        RST_BUFO_RC	: out std_ulogic;
        RST_BUFOP_RC	: out std_ulogic;

        BUFG_CLK		: in std_ulogic;
        BUFO_CLK		: in std_ulogic;
        BUFOP_CLK		: in std_ulogic;
        CLKDIV		: in std_ulogic;
        DIVIDE_2		: in std_ulogic;
        RST		: in std_ulogic;
        RST_CNTR		: in std_ulogic
        );
  end component;
           
  component FIFO_ADDR_OSERDESE1_VHD is
    port(
        EXTRA             : out std_ulogic;
        QRD		: out std_logic_vector (1 downto 0);
        QWC		: out std_logic_vector (1 downto 0);
        RD_GAP1           : out std_ulogic;

        BUFG_CLK		: in std_ulogic;
        BUFO_CLK		: in std_ulogic;
        BUFOP_CLK		: in std_ulogic;
        DATA		: in std_ulogic;
        RST_BUFG_WC	: in std_ulogic;
        RST_BUFO_RC	: in std_ulogic;
        RST_BUFOP_RC	: in std_ulogic
        );
  end component;

  component IODLYCTRL_NPRE_OSERDESE1_VHD is
    port(
        BUFO_OUT          : out std_ulogic;
        IODELAY_STATE     : out std_ulogic;
        RST_CNTR     	: out std_ulogic;

        BUFG_CLK		: in std_ulogic;
        BUFG_CLKDIV	: in std_ulogic;
        BUFO_CLK		: in std_ulogic;
        DDR3_DIMM		: in std_ulogic;
        RST		: in std_ulogic;
        TRIF		: in std_ulogic;
        WC		: in std_ulogic;
        WL6		: in std_ulogic
        );
  end component;

  constant DELAY_FFDCNT		: time       := 1 ps;
  constant DELAY_MXDCNT		: time       := 1 ps;
  constant DELAY_FFRST		: time       := 145 ps;

  constant INIT_LOADCNT		: std_logic_vector (3 downto 0)  := (others => '0');

  constant MSB_SEL		: integer    := 1;

  signal WC_DELAY_int           : std_ulogic := '0';

  signal rd_gap1                : std_ulogic := 'X';
  signal extra_zd                  : std_ulogic := 'X';

  signal rst_bufo_p             : std_ulogic := 'X';
  signal rst_bufg_p             : std_ulogic := 'X';

  signal rst_bufo_rc             : std_ulogic := 'X';
  signal rst_bufg_wc             : std_ulogic := 'X';
  signal rst_cntr                : std_ulogic := 'X';
  signal rst_bufop_rc            : std_ulogic := 'X';

  signal qwc	        	 : std_logic_vector (1 downto 0)  := (others => '0');
  signal qrd	        	 : std_logic_vector (1 downto 0)  := (others => '0');

  signal bufo_out                : std_ulogic := 'X';

  signal IODELAY_STATE_zd        : std_ulogic := 'X';

  signal inv_qmux1                : std_ulogic := 'X';
  signal inv_qmux2                : std_ulogic := 'X';

  signal inv_tmux1                : std_ulogic := 'X';
  signal inv_tmux2                : std_ulogic := 'X';

  signal inv_d1                : std_ulogic := 'X';
  signal inv_d2                : std_ulogic := 'X';

  signal inv_t1                : std_ulogic := 'X';
  signal inv_t2                : std_ulogic := 'X';
begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------


  --------------------
  --  BEHAVIOR SECTION
  --------------------

  inv_d1 <= not D1; 
  inv_d2 <= not D2; 
  inv_t1 <= not T1; 
  inv_t2 <= not T2; 

----------------------------------------------------------------------
---------------             Instance DATA1          ------------------
----------------------------------------------------------------------

  inst_data1:FIFO_TDPIPE_OSERDESE1_VHD
  port map (
        MUXOUT          => inv_qmux1,
  
        DIN		=> inv_d1,
        QWC		=> qwc,
        QRD		=> qrd,
        RD_GAP1		=> rd_gap1,
        BUFG_CLK	=> CLK,
        BUFO_CLK	=> BUFO,
        RST_BUFG_P	=> rst_bufg_p,
        RST_BUFO_P	=> rst_bufo_p,
        DDR3_DATA	=> DDR3_DATA,
        EXTRA		=> extra_zd,
        ODV		=> ODV,
        DDR3_MODE	=> DDR3_MODE
      );

----------------------------------------------------------------------
---------------             Instance DATA2          ------------------
----------------------------------------------------------------------

  inst_data2:FIFO_TDPIPE_OSERDESE1_VHD
  port map (
        MUXOUT          => inv_qmux2,
  
        DIN		=> inv_d2,
        QWC		=> qwc,
        QRD		=> qrd,
        RD_GAP1		=> rd_gap1,
        BUFG_CLK	=> CLK,
        BUFO_CLK	=> BUFO,
        RST_BUFG_P	=> rst_bufg_p,
        RST_BUFO_P	=> rst_bufo_p,
        DDR3_DATA	=> DDR3_DATA,
        EXTRA		=> extra_zd,
        ODV		=> ODV,
        DDR3_MODE	=> DDR3_MODE
      );

----------------------------------------------------------------------
---------------             Instance TRIS1          ------------------
----------------------------------------------------------------------

  inst_tris1:FIFO_TDPIPE_OSERDESE1_VHD
  port map (
        MUXOUT          => inv_tmux1,
  
        DIN		=> inv_t1,
        QWC		=> qwc,
        QRD		=> qrd,
        RD_GAP1		=> rd_gap1,
        BUFG_CLK	=> CLK,
        BUFO_CLK	=> BUFO,
        RST_BUFG_P	=> rst_bufg_p,
        RST_BUFO_P	=> rst_bufo_p,
        DDR3_DATA	=> DDR3_DATA,
        EXTRA		=> extra_zd,
        ODV		=> ODV,
        DDR3_MODE	=> DDR3_MODE
      );

----------------------------------------------------------------------
---------------             Instance TRIS2          ------------------
----------------------------------------------------------------------

  inst_tris2:FIFO_TDPIPE_OSERDESE1_VHD
  port map (
        MUXOUT          => inv_tmux2,
  
        DIN		=> inv_t2,
        QWC		=> qwc,
        QRD		=> qrd,
        RD_GAP1		=> rd_gap1,
        BUFG_CLK	=> CLK,
        BUFO_CLK	=> BUFO,
        RST_BUFG_P	=> rst_bufg_p,
        RST_BUFO_P	=> rst_bufo_p,
        DDR3_DATA	=> DDR3_DATA,
        EXTRA		=> extra_zd,
        ODV		=> ODV,
        DDR3_MODE	=> DDR3_MODE
      );

----------------------------------------------------------------------
---------------             Instance RSTCKT         ------------------
----------------------------------------------------------------------

  inst_rstckt:FIFO_RESET_OSERDESE1_VHD
  port map (
        RST_BUFG_P   => rst_bufg_p,
        RST_BUFG_WC  => rst_bufg_wc,
        RST_BUFO_P   => rst_bufo_p,
        RST_BUFO_RC  => rst_bufo_rc,
        RST_BUFOP_RC => rst_bufop_rc,

        BUFG_CLK     => CLK,
        BUFO_CLK     => BUFO,
        BUFOP_CLK    => BUFOP,
        CLKDIV       => CLKDIV,
        DIVIDE_2     => WC_DELAY_int,
        RST          => rst,
        RST_CNTR     => rst_cntr
      );

----------------------------------------------------------------------
---------------             Instance ADDCNTR        ------------------
----------------------------------------------------------------------

  inst_addcntr:FIFO_ADDR_OSERDESE1_VHD
  port map (
        EXTRA        => extra_zd,
        QRD          => qrd,
        QWC          => qwc,
        RD_GAP1      => rd_gap1,

        BUFG_CLK     => CLK,
        BUFO_CLK     => BUFO,
        BUFOP_CLK    => BUFOP,
        DATA         => DDR3_DATA,
        RST_BUFG_WC  => rst_bufg_wc,
        RST_BUFO_RC  => rst_bufo_rc,
        RST_BUFOP_RC => rst_bufop_rc
      );

----------------------------------------------------------------------
---------------            Instance IDLYCTRL        ------------------
----------------------------------------------------------------------

  inst_idlyctrl:IODLYCTRL_NPRE_OSERDESE1_VHD
  port map (
        BUFO_OUT      => bufo_out,
        IODELAY_STATE => IODELAY_STATE_zd,
        RST_CNTR      => rst_cntr,

        BUFG_CLK      => CLK,
        BUFG_CLKDIV   => CLKDIV,
        BUFO_CLK      => BUFO,
        DDR3_DIMM     => ODELAY_USED,
        RST           => rst_bufg_p,
        TRIF          => TRIF,
        WC            => WC,
        WL6           => WC_DELAY_int 
      );
--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  EXTRA <= extra_zd;
  QMUX1 <= NOT inv_qmux1;
  QMUX2 <= NOT inv_qmux2;
  TMUX1 <= NOT inv_tmux1;
  TMUX2 <= NOT inv_tmux2;
  IODELAY_STATE <= IODELAY_STATE_zd;
--####################################################################


end TXBUFFER_OSERDESE1_VHD_V;
----- END_SUBMOD_TXBUFFER_OSERDESE1_VHD
----- START_SUBMOD_FIFO_TDPIPE_OSERDESE1_VHD
--////////////////////////////////////////////////////////////
--//////////// FIFO_TDPIPE_OSERDESE1_VHD /////////////////////
--////////////////////////////////////////////////////////////

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

entity FIFO_TDPIPE_OSERDESE1_VHD is
  port(
      MUXOUT            : out std_ulogic;

      DIN		: in std_ulogic;
      QWC		: in std_logic_vector (1 downto 0);
      QRD		: in std_logic_vector (1 downto 0);
      RD_GAP1		: in std_ulogic;
      BUFG_CLK		: in std_ulogic;
      BUFO_CLK		: in std_ulogic;
      RST_BUFG_P	: in std_ulogic;
      RST_BUFO_P	: in std_ulogic;
      DDR3_DATA		: in std_ulogic;
      EXTRA		: in std_ulogic;
      ODV		: in std_ulogic;
      DDR3_MODE		: in std_ulogic
      );
           
end FIFO_TDPIPE_OSERDESE1_VHD;

architecture FIFO_TDPIPE_OSERDESE1_VHD_V of FIFO_TDPIPE_OSERDESE1_VHD is


  constant DELAY_BASIC	: time       := 10 ps;
  constant DELAY_14	: time       := 14 ps;
  constant DELAY_MUXOUT	: time       := 1 ps;

  signal qout1		: std_ulogic := 'X';
  signal qout2		: std_ulogic := 'X';
  signal qout_int	: std_ulogic := 'X';
  signal qout_int2	: std_ulogic := 'X';

  signal fifo		:  std_logic_vector (4 downto 1) := (others => '0');
  signal cin		: std_ulogic := 'X';
  signal omux		: std_ulogic := 'X';
  signal sel		:  std_logic_vector (2 downto 0) := (others => '0');
  signal pipe1		: std_ulogic := 'X';
  signal pipe2		: std_ulogic := 'X';
  signal selqoi		: std_ulogic := 'X';
  signal selqoi2	: std_ulogic := 'X';
  signal selmuxout	:  std_logic_vector (2 downto 0) := (others => '0');


  signal MUXOUT_zd		: std_ulogic := 'X';


begin

--####################################################################
--#####                     Basic FIFO                           #####
--####################################################################
  prcs_fifo:process(BUFG_CLK, RST_BUFG_P)
  begin

     if(RST_BUFG_P = '1') then
        fifo  <= (others => '0') after DELAY_BASIC;
     elsif(qwc(1) = '0' and qwc(0) = '0') then
        fifo  <= (fifo(4 downto 2) & DIN) after DELAY_BASIC;
     elsif(qwc(1) = '0' and qwc(0) = '1') then
        fifo  <= (fifo(4 downto 3) & DIN & fifo(1)) after DELAY_BASIC;
     elsif(qwc(1) = '1' and qwc(0) = '1') then
        fifo  <= (fifo(4) & DIN & fifo(2 downto 1)) after DELAY_BASIC;
     elsif(qwc(1) = '1' and qwc(0) = '0') then
        fifo  <= (DIN & fifo(3 downto 1)) after DELAY_BASIC;
     end if;
  end process prcs_fifo;

--####################################################################
--#####                          OMUX                            #####
--####################################################################
  prcs_omux:process(QRD, fifo)
  begin
     case QRD is
          when "00" =>
                    omux <= fifo(1) after DELAY_BASIC;
          when "01" =>
                    omux <= fifo(2) after DELAY_BASIC;
          when "10" =>
                    omux <= fifo(4) after DELAY_BASIC;
          when "11" =>
                    omux <= fifo(3) after DELAY_BASIC;
          when others =>
                    omux <= fifo(1) after DELAY_BASIC;
     end case;

  end process prcs_omux;

--####################################################################
--#####                          OMUX                            #####
--####################################################################
  prcs_qout_int:process(BUFO_CLK, RST_BUFO_P)
  begin
     if(RST_BUFG_P = '1') then
        qout_int  <= '0'  after DELAY_BASIC;
        qout_int2 <= '0'  after DELAY_BASIC;
     elsif(rising_edge(BUFO_CLK)) then
         qout_int  <= omux     after DELAY_BASIC;
         qout_int2 <= qout_int after DELAY_BASIC;
     end if;
  end process prcs_qout_int;

--####################################################################
--#####                        SELQOI                            #####
--####################################################################
  selqoi <= ODV or RD_GAP1 after DELAY_BASIC;

--####################################################################
--#####                          qout1                           #####
--####################################################################
  prcs_qout1:process(selqoi, qout_int, omux )
  begin
     case selqoi is
          when '0' => qout1 <= omux after DELAY_BASIC;
          when '1' => qout1 <= qout_int after DELAY_BASIC;
          when others => qout1 <= omux after DELAY_BASIC;
     end case;
  end process prcs_qout1;

--####################################################################
--#####                        SELQOI2                           #####
--####################################################################
--  selqoi2 <= ODV or RD_GAP1 after DELAY_BASIC;
  selqoi2 <= ODV and RD_GAP1 after DELAY_BASIC;

--####################################################################
--#####                          qout2                           #####
--####################################################################
  prcs_qout2:process(selqoi2, qout_int2, qout_int )
  begin
     case selqoi2 is
          when '0' => qout2 <= qout_int after DELAY_BASIC;
          when '1' => qout2 <= qout_int2 after DELAY_BASIC;
          when others => qout2 <= qout_int after DELAY_BASIC;
     end case;
  end process prcs_qout2;

--####################################################################
--#####                        SELQOI2                           #####
--####################################################################
--  selmuxout <= (DDR3_MODE & DDR3_DATA & EXTRA) after DELAY_BASIC;
  selmuxout <= (DDR3_MODE & DDR3_DATA & EXTRA) after DELAY_14;

--####################################################################
--#####                        MUXOUT                            #####
--####################################################################
  prcs_muxout:process(selmuxout, DIN, omux, qout1, qout2)
  begin
     case selmuxout is
          when "000"  => MUXOUT_zd <= DIN   after DELAY_MUXOUT;
          when "001"  => MUXOUT_zd <= DIN   after DELAY_MUXOUT;
          when "010"  => MUXOUT_zd <= DIN   after DELAY_MUXOUT;
          when "011"  => MUXOUT_zd <= DIN   after DELAY_MUXOUT;
          when "100"  => MUXOUT_zd <= omux  after DELAY_MUXOUT;
          when "101"  => MUXOUT_zd <= omux  after DELAY_MUXOUT;
          when "110"  => MUXOUT_zd <= qout1 after DELAY_MUXOUT;
          when "111"  => MUXOUT_zd <= qout2 after DELAY_MUXOUT;
          when others => MUXOUT_zd <= DIN   after DELAY_MUXOUT;
     end case;
  end process prcs_muxout;

--####################################################################
--#####                        OUTPUT                            #####
--####################################################################
  prcs_output:process(MUXOUT_zd)
  begin
     MUXOUT <= MUXOUT_zd;
  end process prcs_output;
--####################################################################
end FIFO_TDPIPE_OSERDESE1_VHD_V;
----- END_SUBMOD_FIFO_TDPIPE_OSERDESE1_VHD
----- START_SUBMOD_FIFO_RESET_OSERDESE1_VHD
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

--////////////////////////////////////////////////////////////
--//////////// FIFO_RESET_OSERDESE1_VHD /////////////////////
--////////////////////////////////////////////////////////////

entity FIFO_RESET_OSERDESE1_VHD is
  port(
      RST_BUFG_P	: out std_ulogic;
      RST_BUFG_WC	: out std_ulogic;
      RST_BUFO_P	: out std_ulogic;
      RST_BUFO_RC	: out std_ulogic;
      RST_BUFOP_RC	: out std_ulogic;

      BUFG_CLK		: in std_ulogic;
      BUFO_CLK		: in std_ulogic;
      BUFOP_CLK		: in std_ulogic;
      CLKDIV		: in std_ulogic;
      DIVIDE_2		: in std_ulogic;
      RST		: in std_ulogic;
      RST_CNTR		: in std_ulogic
      );
           
end FIFO_RESET_OSERDESE1_VHD;

architecture FIFO_RESET_OSERDESE1_VHD_V of FIFO_RESET_OSERDESE1_VHD is


  constant DELAY_BASIC	: time       := 10 ps;
  constant DELAY_ONE	: time       := 1 ps;

  signal clkdiv_pipe	:  std_logic_vector (1 downto 0);

  signal bufg_pipe	: std_ulogic;

  signal rst_cntr_reg	: std_ulogic;

  signal bufo_rst_p	:  std_logic_vector (2 downto 0);
  signal bufo_rst_rc	:  std_logic_vector (2 downto 0);

  signal bufop_rst_rc	:  std_logic_vector (1 downto 0);

  signal bufg_rst_p	:  std_logic_vector (1 downto 0);
  signal bufg_rst_wc	:  std_logic_vector (1 downto 0);

  signal bufg_clkdiv_latch		: std_ulogic;
  signal ltint1				: std_ulogic;
  signal ltint2				: std_ulogic;
  signal ltint3				: std_ulogic;

  signal latch_in			: std_ulogic;



begin

--####################################################################
--#####                     rst_cntr_reg                         #####
--####################################################################
  prcs_rst_cntr_reg:process(BUFG_CLK, RST)
  begin
     if(RST = '1') then
        rst_cntr_reg  <= '0' after DELAY_BASIC;
     else
        if(rising_edge(BUFG_CLK)) then 
           rst_cntr_reg  <= RST_CNTR after DELAY_BASIC;
        end if;
     end if;
  end process prcs_rst_cntr_reg;

--####################################################################
--#####                      clkdiv_pipe                         #####
--####################################################################
  prcs_clkdiv_pipe:process(CLKDIV, RST)
  begin
     if(RST = '1') then
        clkdiv_pipe  <= "11" after DELAY_BASIC;
     else
        if(rising_edge(CLKDIV)) then  
           clkdiv_pipe  <= (clkdiv_pipe(0) & '0') after DELAY_BASIC;
        end if;
     end if;
  end process prcs_clkdiv_pipe;

--####################################################################
--#####                  latch_in, ltint1/2/3                    #####
--####################################################################

--  latch_in <= clkdiv_pipe(1) when (DIVIDE_2 = '1')  else '0' after DELAY_ONE;
  latch_in <= clkdiv_pipe(1) after DELAY_ONE;

  bufg_clkdiv_latch <= not (ltint1 and ltint3)            after DELAY_ONE;
  ltint1            <= not (latch_in and bufg_clk)        after DELAY_ONE;
  ltint2            <= not (ltint1 and bufg_clk)          after DELAY_ONE;
  ltint3            <= not (bufg_clkdiv_latch and ltint2) after DELAY_ONE;

--####################################################################
--#####                       bufg_pipe                          #####
--####################################################################
  prcs_bufg_pipe:process(BUFG_CLK, RST)
  begin
     if(RST = '1') then
        bufg_pipe  <= '1' after DELAY_BASIC;  -- ?? '0' ?
     elsif(rising_edge(BUFG_CLK)) then  
        bufg_pipe  <= bufg_clkdiv_latch after DELAY_BASIC;
     end if;
  end process prcs_bufg_pipe;

--####################################################################
--#####                       bufg_rst_p                         #####
--####################################################################
  prcs_bufg_rst_p:process(BUFG_CLK, RST)
  begin
     if(RST = '1') then
        bufg_rst_p  <= "11" after DELAY_BASIC; -- ?? "00" ?
     elsif(rising_edge(BUFG_CLK)) then  
        bufg_rst_p  <= (bufg_rst_p(0) & bufg_pipe) after DELAY_BASIC;
     end if;
  end process prcs_bufg_rst_p;

--####################################################################
--#####                       bufg_rst_wc                         #####
--####################################################################
  prcs_bufg_rst_wc:process(BUFG_CLK, RST_CNTR, RST)
  begin
     if((RST = '1') or (RST_CNTR = '1')) then
        bufg_rst_wc  <= "11" after DELAY_BASIC;
     elsif(rising_edge(BUFG_CLK)) then  
        bufg_rst_wc  <= (bufg_rst_wc(0) & bufg_pipe) after DELAY_BASIC;
     end if;
  end process prcs_bufg_rst_wc;

--####################################################################
--#####                       bufo_rst_p                         #####
--####################################################################
  prcs_bufo_rst_p:process(BUFO_CLK, RST)
  begin
     if(RST = '1') then
        bufo_rst_p  <= "111" after DELAY_BASIC;
     elsif(rising_edge(BUFO_CLK)) then  
        bufo_rst_p  <= (bufo_rst_p(1 downto 0) & bufg_pipe) after DELAY_BASIC;
     end if;
  end process prcs_bufo_rst_p;

--####################################################################
--#####                      bufg_rst_wc                         #####
--####################################################################
  prcs_bufo_rst_rc:process(BUFO_CLK, RST_CNTR, RST)
  begin
     if((RST = '1') or (RST_CNTR = '1')) then
        bufo_rst_rc  <= "111" after DELAY_BASIC;
     elsif(rising_edge(BUFO_CLK)) then  
        bufo_rst_rc  <= (bufo_rst_rc(1 downto 0) & bufg_pipe) after DELAY_BASIC;
     end if;
  end process prcs_bufo_rst_rc;

--####################################################################
--#####                      bufop_rst_rc                        #####
--####################################################################
  prcs_bufop_rst_rc:process(BUFOP_CLK, RST_CNTR, RST)
  begin
     if((RST = '1') or (RST_CNTR = '1')) then
        bufop_rst_rc  <= "11" after DELAY_BASIC;
     elsif(rising_edge(BUFOP_CLK)) then  
        bufop_rst_rc  <= (bufop_rst_rc(0) & bufg_pipe) after DELAY_BASIC;
     end if;
  end process prcs_bufop_rst_rc;

--####################################################################
--#####                        OUTPUT                            #####
--####################################################################
      RST_BUFG_P	<= bufg_rst_p(1);
      RST_BUFG_WC	<= bufg_rst_wc(1);
      RST_BUFO_P	<= bufo_rst_p(1);
      RST_BUFO_RC	<= bufo_rst_rc(1);
      RST_BUFOP_RC	<= bufop_rst_rc(1);
--####################################################################
end FIFO_RESET_OSERDESE1_VHD_V;
----- END_SUBMOD_FIFO_RESET_OSERDESE1_VHD
----- START_SUBMOD_FIFO_ADDR_OSERDESE1_VHD
--////////////////////////////////////////////////////////////
--////////////// FIFO_ADDR_OSERDESE1_VHD /////////////////////
--////////////////////////////////////////////////////////////
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

entity FIFO_ADDR_OSERDESE1_VHD is
  port(
      EXTRA             : out std_ulogic;
      QRD		: out std_logic_vector (1 downto 0);
      QWC		: out std_logic_vector (1 downto 0);
      RD_GAP1           : out std_ulogic;

      BUFG_CLK		: in std_ulogic;
      BUFO_CLK		: in std_ulogic;
      BUFOP_CLK		: in std_ulogic;
      DATA		: in std_ulogic;
      RST_BUFG_WC	: in std_ulogic;
      RST_BUFO_RC	: in std_ulogic;
      RST_BUFOP_RC	: in std_ulogic
      );
           
end FIFO_ADDR_OSERDESE1_VHD;

architecture FIFO_ADDR_OSERDESE1_VHD_V of FIFO_ADDR_OSERDESE1_VHD is


  constant DELAY_BASIC	: time       := 10 ps;
  constant DELAY_ONE	: time       := 1 ps;

  signal stop_rd	: std_ulogic;

  signal rd_cor 	: std_ulogic;
  signal rd_cor_cnt 	: std_ulogic;
  signal rd_cor_cnt1 	: std_ulogic;

  signal qwc0_latch	: std_ulogic;
  signal qwc1_latch	: std_ulogic;

  signal li01		: std_ulogic;
  signal li02		: std_ulogic;
  signal li03		: std_ulogic;

  signal li11		: std_ulogic;
  signal li12		: std_ulogic;
  signal li13		: std_ulogic;

  signal stop_rdn	: std_ulogic;
  signal rd_cor_cntn	: std_ulogic;
  signal rd_cor_cnt1n	: std_ulogic;
  signal stop_rc	: std_ulogic;

  signal qwcd		:  std_logic_vector (1 downto 0);
  signal qrdd		:  std_logic_vector (1 downto 0);

  signal stop_rdd	: std_ulogic;
  signal rd_gap1d	: std_ulogic;
  signal extrad		: std_ulogic;

  signal rd_cord	: std_ulogic;
  signal rd_cor_cntd	: std_ulogic;
  signal rd_cor_cnt1d	: std_ulogic;

  signal qwcd0_latch	: std_ulogic;
  signal qwcd1_latch	: std_ulogic;

  signal li01d		: std_ulogic;
  signal li02d		: std_ulogic;
  signal li03d		: std_ulogic;

  signal li11d		: std_ulogic;
  signal li12d		: std_ulogic;
  signal li13d		: std_ulogic;


  signal EXTRA_zd 	: std_ulogic := '0';
  signal QRD_zd		:  std_logic_vector (1 downto 0) := (others => '0');
  signal QWC_zd		:  std_logic_vector (1 downto 0) := (others => '0');
  signal RD_GAP1_zd	: std_ulogic := '0';

begin

--####################################################################
--#####                     Write_Count                          #####
--####################################################################
  prcs_qwc:process(BUFG_CLK, RST_BUFG_WC)
  begin

     if(RST_BUFG_WC = '1') then
        QWC_zd  <= (others => '1') after DELAY_BASIC;
     elsif(rising_edge(BUFG_CLK)) then
         if((QWC_zd(1) xor QWC_zd(0)) = '1') then 
            QWC_zd(1) <= not QWC_zd(1) after DELAY_BASIC; 
            QWC_zd(0) <=     QWC_zd(0) after DELAY_BASIC; 
         else
            QWC_zd(1) <=     QWC_zd(1) after DELAY_BASIC; 
            QWC_zd(0) <= not QWC_zd(0) after DELAY_BASIC; 
         end if;
     end if;
  end process prcs_qwc;

--####################################################################
--#####                     Read_Count                           #####
--####################################################################
  prcs_qrd:process(BUFO_CLK, RST_BUFO_RC)
  begin

     if(RST_BUFO_RC = '1') then
        QRD_zd  <= (others => '0') after DELAY_BASIC;
     elsif(rising_edge(BUFO_CLK)) then
         if(stop_rd = '1' and  DATA /= '1') then  
            QRD_zd <= QRD_zd after DELAY_BASIC;  
         elsif((QRD_zd(1) xor QRD_zd(0)) = '1') then 
            QRD_zd(1) <= not QRD_zd(1) after DELAY_BASIC; 
            QRD_zd(0) <=     QRD_zd(0) after DELAY_BASIC; 
         else
            QRD_zd(1) <=     QRD_zd(1) after DELAY_BASIC; 
            QRD_zd(0) <= not QRD_zd(0) after DELAY_BASIC; 
         end if;
     end if;
  end process prcs_qrd;

--####################################################################
--#####                       rd_gap1                            #####
--####################################################################
  prcs_rd_gap1:process(BUFO_CLK, RST_BUFO_RC)
  begin

     if(RST_BUFO_RC = '1') then
        RD_GAP1_zd  <= '0' after DELAY_BASIC;
     elsif(rising_edge(BUFO_CLK)) then
--         if((qwc1_latch = '1' and  qwc0_latch = '1')  and ((QRD_zd(0) xor QRD_zd(0)) = '1')) then
         if((qwc1_latch = '1' and  qwc0_latch = '1')  and (QRD_zd(0) = '1')) then
            RD_GAP1_zd <= '1' after DELAY_BASIC;  
         else
            RD_GAP1_zd <=  RD_GAP1_zd after DELAY_BASIC; 
         end if;
     end if;
  end process prcs_rd_gap1;

--####################################################################
--#####     qwc0/1_latch  and li(0)(1) ... li(1)(3)              #####
--####################################################################

  qwc0_latch 		<= not (li01 and li03)		after DELAY_ONE;
  li01			<= not (QWC_zd(0) and bufo_clk)	after DELAY_ONE;
  li02			<= not (li01 and bufo_clk)	after DELAY_ONE;
  li03			<= not (qwc0_latch and li02)	after DELAY_ONE;

  qwc1_latch 		<= not (li11 and li13)		after DELAY_ONE;
  li11			<= not (QWC_zd(1) and bufo_clk)	after DELAY_ONE;
  li12			<= not (li11 and bufo_clk)	after DELAY_ONE;
  li13			<= not (qwc1_latch and li12)	after DELAY_ONE;

--####################################################################
--#####                     Read_Count_Pipeline                  #####
--####################################################################
  prcs_qrdd:process(BUFOP_CLK, RST_BUFOP_RC)
  begin

     if(RST_BUFOP_RC = '1') then
        qrdd  <= (others => '0') after DELAY_BASIC;
     elsif(rising_edge(BUFOP_CLK)) then
         if((qrdd(1) xor qrdd(0)) = '1') then  
            qrdd(1) <= not qrdd(1) after DELAY_BASIC;  
            qrdd(0) <=     qrdd(0) after DELAY_BASIC;  
         else
            qrdd(1) <=     qrdd(1) after DELAY_BASIC;  
            qrdd(0) <= not qrdd(0) after DELAY_BASIC;  
         end if;
     end if;
  end process prcs_qrdd;

--####################################################################
--#####     qwcd0/1_latch  and li(0)(1)d ... li(1)(3)d           #####
--####################################################################

  qwcd0_latch 		<= not (li01d and li03d)		after DELAY_ONE;
  li01d			<= not (QWC_zd(0) and bufop_clk)	after DELAY_ONE;
  li02d			<= not (li01d and bufop_clk)		after DELAY_ONE;
  li03d			<= not (qwcd0_latch and li02d)		after DELAY_ONE;

  qwcd1_latch 		<= not (li11d and li13d)		after DELAY_ONE;
  li11d			<= not (QWC_zd(1) and bufop_clk)	after DELAY_ONE;
  li12d			<= not (li11d and bufop_clk)		after DELAY_ONE;
  li13d			<= not (qwcd1_latch and li12d)		after DELAY_ONE;

--####################################################################
--#####                     Read_Address_count correction        #####
--####################################################################
  prcs_rd_cor_cnt:process(BUFOP_CLK, RST_BUFOP_RC)
  begin

     if(RST_BUFOP_RC = '1') then
        stop_rd     <= '0' after DELAY_BASIC;
        rd_cor_cnt  <= '0' after DELAY_BASIC;
        rd_cor_cnt1 <= '0' after DELAY_BASIC;
     elsif(rising_edge(BUFOP_CLK)) then
-- CR 533445
--        if((qwcd1_latch = '1' and  qwcd0_latch = '1')  and ((qrdd(0) xor qrdd(0)) = '1')) then
        if((qwcd1_latch = '1' and  qwcd0_latch = '1')  and ((qrdd(0) xor qrdd(1)) = '1') and (rd_cor_cnt1 = '0')) then
            stop_rd     <= '1' after DELAY_BASIC;
            rd_cor_cnt  <= '1' after DELAY_BASIC;
            rd_cor_cnt1 <= rd_cor_cnt after DELAY_BASIC;
         else
            stop_rd     <= '0' after DELAY_BASIC;
            rd_cor_cnt  <= '1' after DELAY_BASIC;
            rd_cor_cnt1 <= rd_cor_cnt after DELAY_BASIC;
         end if;
     end if;
  end process prcs_rd_cor_cnt;

--####################################################################
--#####                               Extra                      #####
--####################################################################
  prcs_extra:process(BUFOP_CLK, RST_BUFOP_RC)
  begin

     if(RST_BUFOP_RC = '1') then
        EXTRA_zd     <= '0' after DELAY_BASIC;
     elsif(rising_edge(BUFOP_CLK)) then
        if(stop_rd = '1') then
            EXTRA_zd     <= '1' after DELAY_BASIC;
         end if;
     end if;
  end process prcs_extra;
--####################################################################
--#####                        OUTPUT                            #####
--####################################################################
      EXTRA	<=	EXTRA_zd;
      QRD	<=	QRD_zd;
      QWC	<=	QWC_zd;
      RD_GAP1  	<=	RD_GAP1_zd;

--####################################################################
end FIFO_ADDR_OSERDESE1_VHD_V;
----- END_SUBMOD_FIFO_ADDR_OSERDESE1_VHD
----- START_SUBMOD_IODLYCTRL_NPRE_OSERDESE1_VHD
--////////////////////////////////////////////////////////////
--//////////// IODLYCTRL_NPRE_OSERDESE1_VHD /////////////////////////
--////////////////////////////////////////////////////////////
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;


entity IODLYCTRL_NPRE_OSERDESE1_VHD is
  port(
      BUFO_OUT          : out std_ulogic;
      IODELAY_STATE     : out std_ulogic;
      RST_CNTR     	: out std_ulogic;

      BUFG_CLK		: in std_ulogic;
      BUFG_CLKDIV	: in std_ulogic;
      BUFO_CLK		: in std_ulogic;
      DDR3_DIMM		: in std_ulogic;
      RST		: in std_ulogic;
      TRIF		: in std_ulogic;
      WC		: in std_ulogic;
      WL6		: in std_ulogic
      );
           
end IODLYCTRL_NPRE_OSERDESE1_VHD;

architecture IODLYCTRL_NPRE_OSERDESE1_VHD_V of IODLYCTRL_NPRE_OSERDESE1_VHD is


  constant DELAY_BASIC	: time       := 10 ps;
  constant DELAY_ONE    : time       := 1 ps;

  signal qw0cd		: std_ulogic;
  signal qw1cd		: std_ulogic;

  signal turn		: std_ulogic;
  signal turn_p1	: std_ulogic;

  signal w_to_w		: std_ulogic := 'X';

  signal wtw_cntr       : std_logic_vector (2 downto 0);
  signal wtw_cntr_int   : integer    := 0;

  signal cmd0		: std_ulogic;
  signal cmd0_n6	: std_ulogic;
  signal cmd0_6		: std_ulogic;
  signal cmd1		: std_ulogic;

  signal wr_cmd0	: std_ulogic;

  signal lt0int1	: std_ulogic;
  signal lt0int2	: std_ulogic;
  signal lt0int3	: std_ulogic;

  signal lt1int1	: std_ulogic;
  signal lt1int2	: std_ulogic;
  signal lt1int3	: std_ulogic;

  signal latch_in	: std_ulogic;

  signal qwcd		: std_ulogic;

  signal prcs_wtw_cntr_chk : boolean := false;

  signal RST_CNTR_zd	: std_ulogic := 'X';

begin

--####################################################################
--#####                     Write Command                        #####
--####################################################################
  prcs_qwcd:process(BUFG_CLKDIV)
  begin
     if(rising_edge(BUFG_CLKDIV)) then
        if (RST = '1') then
           qwcd <= '0' after DELAY_BASIC;
        else 
           qwcd <= wc after DELAY_BASIC;
        end if;
     end if;
  end process prcs_qwcd;

--####################################################################
--#####                       latch to allow skew               #####
--####################################################################

  wr_cmd0               <= not (lt0int1 and lt0int3)    after DELAY_ONE;
  lt0int1               <= not (qwcd and bufg_clk)      after DELAY_ONE;
  lt0int2               <= not (lt0int1 and bufg_clk)      after DELAY_ONE;
  lt0int3               <= not (wr_cmd0 and lt0int2)    after DELAY_ONE;


--####################################################################
--#####                        cmd0_(n6/6)                       #####
--####################################################################
  prcs_cmd0:process(BUFG_CLK)
  begin
     if(rising_edge(BUFG_CLK)) then
        if(RST= '1') then
            cmd0_n6 <=     '0' after DELAY_BASIC;
            cmd0_6  <=     '0' after DELAY_BASIC;
        else
            cmd0_n6 <=     wr_cmd0 after DELAY_BASIC;
            cmd0_6  <=     cmd0_n6 after DELAY_BASIC;
         end if;
     end if;

  end process prcs_cmd0;

--####################################################################
--#####                        cmd0                              #####
--####################################################################
--  mux to add extra pipe stage for WL = 6
  prcs_cmd0_mux:process(cmd0_n6 , WL6 , cmd0_6)
  begin
     case WL6 is
           when '0' => cmd0 <= cmd0_n6 after DELAY_BASIC; 
           when '1' => cmd0 <= cmd0_6  after DELAY_BASIC; 
           when others => cmd0 <= cmd0_n6 after DELAY_BASIC;
     end case;
  end process prcs_cmd0_mux;

--####################################################################
--#####                        turn                              #####
--####################################################################
  prcs_turn:process(BUFG_CLK)
  begin
     if(rising_edge(BUFG_CLK)) then
        if(RST= '1') then
            turn <=     '0' after DELAY_BASIC;
        else
            turn <=     (w_to_w or (cmd0 and (not turn)) or (not wtw_cntr(2) and turn))  after DELAY_BASIC;
        end if;
     end if;
  end process prcs_turn;

--####################################################################
--#####                        rst_cntr                          #####
--####################################################################
  prcs_rst_cntr:process(BUFG_CLK)
  begin
     if(rising_edge(BUFG_CLK)) then
        if(RST= '1') then
            RST_CNTR_zd <=   '0' after DELAY_BASIC;
        else
            RST_CNTR_zd <=   (not w_to_w and (cmd0 and  not turn)) after DELAY_BASIC;
        end if;
     end if;
  end process prcs_rst_cntr;

--####################################################################
--#####                       turn_p1                            #####
--####################################################################
  prcs_turn_p1:process(BUFG_CLK)
  begin
     if(rising_edge(BUFG_CLK)) then
        if(RST= '1') then
            turn_p1 <= '0' after DELAY_BASIC;
        else
            turn_p1 <= turn after DELAY_BASIC;
        end if;
     end if;
  end process prcs_turn_p1;

--####################################################################
--#####                         w_to_w                           #####
--####################################################################
  prcs_w_to_w:process(BUFG_CLK)
  begin
     if(rising_edge(BUFG_CLK)) then
        if(RST= '1') then
            w_to_w <= '0' after DELAY_BASIC;
        else
            w_to_w <= ((cmd0 and turn_p1) or (w_to_w and  ( not wtw_cntr(2) or not wtw_cntr(1))))  after DELAY_BASIC;
        end if;
     end if;
  end process prcs_w_to_w;

--####################################################################
--#####                         wtw_cntr                         #####
--####################################################################

--  prcs_wtw_cntr_chk <= (not (w_to_w or turn) or (cmd0 and turn_p1));
  prcs_wtw_cntr_chk <= ((w_to_w= '0' and  turn = '0') or (cmd0 = '1' and turn_p1 = '1'));
  prcs_wtw_cntr:process(BUFG_CLK)
  begin
     if(rising_edge(BUFG_CLK)) then
        if(prcs_wtw_cntr_chk) then
            wtw_cntr_int <= 0;
        elsif( w_to_w = '1' or turn_p1 = '1') then 
            wtw_cntr_int <= wtw_cntr_int + 1;
        end if;
     end if;
     wtw_cntr <= CONV_STD_LOGIC_VECTOR(wtw_cntr_int, 3) after DELAY_BASIC;   
  end process prcs_wtw_cntr;

--####################################################################
--#####                     OUTPUT                               #####
--####################################################################
  BUFO_OUT <= BUFO_CLK;
  IODELAY_STATE <= (TRIF and not w_to_w ) and ((not turn and not turn_p1) or not DDR3_DIMM );
  RST_CNTR <= RST_CNTR_zd;

end IODLYCTRL_NPRE_OSERDESE1_VHD_V;
----- END_SUBMOD_IODLYCTRL_NPRE_OSERDESE1_VHD
----- START_SUBMOD_DOUT_OSERDESE1_VHD
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

--////////////////////////////////////////////////////////////
--//////////////// DOUT_OSERDESE1_VHD /////////////////////////
--////////////////////////////////////////////////////////////

entity DOUT_OSERDESE1_VHD is

  generic(
         DATA_RATE_OQ		: string	:= "DDR";
         INIT_OQ		: bit		:= '0';
         SRVAL_OQ		: bit		:= '0';
         INTERFACE_TYPE		: string	:= "DEFAULT"
    );

  port(
      OQ		: out std_ulogic;
      D2RNK2_OUT	: out std_ulogic;

      BUFO		: in std_ulogic;
      CLK		: in std_ulogic;
      DATA1		: in std_ulogic;
      DATA2		: in std_ulogic;
      OCE		: in std_ulogic;
      SR	        : in std_ulogic;
      DDR3_MODE         : in std_ulogic
    );

end DOUT_OSERDESE1_VHD;

architecture DOUT_OSERDESE1_VHD_V OF DOUT_OSERDESE1_VHD is


  constant DELAY_FFD            : time       := 1 ps; 
  constant DELAY_FFCD           : time       := 1 ps; 
  constant DELAY_MXD	        : time       := 1 ps;
  constant DELAY_MXR1	        : time       := 1 ps;

  signal AttrDdrClkEdge		: std_ulogic := '1';
  signal AttrDataRateOQ		: std_ulogic := 'X';
  signal Ddr3Mode		: std_ulogic := 'X';
  signal AttrSRtype		: std_logic_vector(4 downto 0) := (others => '1');


  signal BUFO_dly               : std_ulogic := 'X';
  signal CLK_dly	        : std_ulogic := 'X';
  signal DATA1_dly		: std_ulogic := 'X';
  signal DATA2_dly		: std_ulogic := 'X';

  signal GSR_dly	        : std_ulogic := '0';

  signal OCE_dly	        : std_ulogic := 'X';
  signal SR_dly		        : std_ulogic := 'X';

  signal OQ_zd			: std_ulogic := TO_X01(INIT_OQ);

  signal d1rnk2			: std_ulogic := 'X';
  signal d2rnk2			: std_ulogic := 'X';
  signal d2nrnk2		: std_ulogic := 'X';

  signal ddr_data		: std_ulogic := 'X';
  signal odata_edge		: std_ulogic := 'X';
  signal sdata_edge		: std_ulogic := 'X';

  signal c23			: std_ulogic := 'X';
  signal c45			: std_ulogic := 'X';
  signal c67			: std_ulogic := 'X';

  signal C_dly	                : std_ulogic := 'X';
  signal C2p			: std_ulogic := 'X';
  signal C3			: std_ulogic := 'X';

  signal seloq			: std_logic_vector(3 downto 0) := (others => 'X');

  signal oqsr			: std_ulogic := 'X';
  signal oqrev			: std_ulogic := 'X';

  constant SWALLOW_PULSE_OQ     : time := 2 ps;


begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  BUFO_dly          	 <= BUFO;
  CLK_dly          	 <= CLK;
  DATA1_dly         	 <= DATA1;
  DATA2_dly         	 <= DATA2;
  GSR_dly        	 <= '0';
  OCE_dly        	 <= OCE;
  SR_dly         	 <= SR;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  variable AttrDataRateOQ_var           : std_ulogic := 'X';
  variable Ddr3Mode_var             : std_ulogic := 'X';
  begin

      ------------------ DATA_RATE validity check ------------------

      if((DATA_RATE_OQ = "DDR") or (DATA_RATE_OQ = "ddr")) then
         AttrDataRateOQ_var := '0';
      elsif((DATA_RATE_OQ = "SDR") or (DATA_RATE_OQ = "sdr")) then
         AttrDataRateOQ_var := '1';
      end if;

      ------------------ DDR3_MODE validity check ------------------

      if(INTERFACE_TYPE = "MEMORY_DDR3") then
         Ddr3Mode_var := '1';
      else
         Ddr3Mode_var := '0';
      end if;

      AttrDataRateOQ <= AttrDataRateOQ_var;
      Ddr3Mode       <= Ddr3Mode_var;

      wait;
  end process prcs_init;
--###################################################################
--#####                   Concurrent exe                        #####
--###################################################################
   C_dly      <= BUFO_dly when (Ddr3Mode = '1') else CLK_dly; 
   C2p    <= (C_dly and AttrDdrClkEdge) or 
             ((not C_dly) and (not AttrDdrClkEdge)); 
   C3     <= not C2p;
   seloq   <= OCE_dly & AttrDataRateOQ & oqsr & oqrev;
   oqsr    <= ((not(AttrSRtype(1))) and SR_dly and not (TO_X01(SRVAL_OQ)));
   oqrev   <= ((not(AttrSRtype(1))) and SR_dly and (TO_X01(SRVAL_OQ)));

--###################################################################
--#####                     q1rnk2 reg                          #####
--###################################################################
  prcs_D1_rnk2:process(C_dly, GSR_dly)
  variable d1rnk2_var         : std_ulogic := TO_X01(INIT_OQ);
  variable FIRST_TIME         : boolean    := true;
  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         d1rnk2_var  :=  TO_X01(INIT_OQ);
         FIRST_TIME  := false;
     elsif(GSR_dly = '0') then
         if(rising_edge(C_dly)) then
            if(SR_dly = '1') then
               d1rnk2_var := TO_X01(SRVAL_OQ);
            elsif (OCE = '1') then
                  d1rnk2_var := DATA1_dly;
            elsif(OCE = '0') then
                  d1rnk2_var := OQ_zd;
            end if;
         end if;

     end if;

     d1rnk2  <= d1rnk2_var  after DELAY_FFD;

  end process prcs_D1_rnk2;
--###################################################################
--#####                     d2rnk2 reg                          #####
--###################################################################
  prcs_D2_rnk2:process(C2p, GSR_dly)
  variable d2rnk2_var         : std_ulogic := TO_X01(INIT_OQ);
  variable FIRST_TIME         : boolean    := true;
  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         d2rnk2_var  :=  TO_X01(INIT_OQ);
         FIRST_TIME  := false;
     elsif(GSR_dly = '0') then
         if(rising_edge(C2p)) then
            if(SR_dly = '1') then
               d2rnk2_var :=  TO_X01(SRVAL_OQ);
            elsif(OCE = '1') then
               d2rnk2_var := DATA2_dly;
            elsif(OCE = '0') then
               d2rnk2_var := OQ_zd;
            end if;
         end if;
     end if;

     d2rnk2  <= d2rnk2_var  after DELAY_FFD;

  end process prcs_D2_rnk2;
--###################################################################
--#####                     d2nrnk2 reg                          #####
--###################################################################
  prcs_D2_nrnk2:process(C3, GSR_dly)
  variable d2nrnk2_var         : std_ulogic := TO_X01(INIT_OQ);
  variable FIRST_TIME          : boolean    := true;
  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         d2nrnk2_var  := TO_X01(INIT_OQ);
         FIRST_TIME  := false;
     elsif(GSR_dly = '0') then
         if(rising_edge(C3)) then
            if(SR_dly = '1') then
               d2nrnk2_var :=  TO_X01(SRVAL_OQ);
            elsif(OCE = '1') then
               d2nrnk2_var := d2rnk2;
            elsif(OCE = '0') then
               d2nrnk2_var := OQ_zd;
            end if;
         end if;
     end if;

     d2nrnk2  <= d2nrnk2_var  after DELAY_FFD;

  end process prcs_D2_nrnk2;

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
   
--           when "0000" =>
--                       OQ_zd <= OQ_zd after DELAY_MXD;
   
--           when "0100" =>
--                       OQ_zd <= OQ_zd after DELAY_MXD;
   
           when "1000" =>
                       OQ_zd <= ddr_data after DELAY_MXD;
   
           when "1100" =>
                       OQ_zd <= d1rnk2 after DELAY_MXD;
   
           when others =>
-- the below "now > DEALY_MXD" is added since 
-- the INIT value of OQ_zd is getting wiped off by ddr_data=X at time 0.
-- At time 0, seloq is XXXX
                       if(now > DELAY_MXD) then
                         OQ_zd <= ddr_data after DELAY_MXD;
                       end if;
   
        end case;

     end if; 

  end process prcs_OQ_mux;

--####################################################################

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(OQ_zd, d2rnk2)
  begin
      OQ   <= OQ_zd after SWALLOW_PULSE_OQ;
      D2RNK2_OUT <= d2rnk2;
  end process prcs_output;
--####################################################################
end DOUT_OSERDESE1_VHD_V;
----- START_SUBMOD_TOUT_OSERDESE1_VHD
--////////////////////////////////////////////////////////////
--//////////// TOUT_OSERDESE1_VHD ////////////////////////////
--////////////////////////////////////////////////////////////
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;


entity TOUT_OSERDESE1_VHD is

  generic(

         DATA_RATE_TQ		: string;
         TRISTATE_WIDTH		: integer	:= 1;
         INIT_TQ		: bit		:= '0';
         SRVAL_TQ		: bit		:= '1'

    );

  port(
      TQ		: out std_ulogic;

      BUFO		: in std_ulogic;
      CLK		: in std_ulogic;
      DATA1		: in std_ulogic;
      DATA2		: in std_ulogic;
      DDR3_MODE		: in std_ulogic;
      SR	        : in std_ulogic;
      TCE		: in std_ulogic
    );

end TOUT_OSERDESE1_VHD;

architecture TOUT_OSERDESE1_VHD_V OF TOUT_OSERDESE1_VHD is


  constant GSR_PULSE_TIME       : time       := 1 ns; 

  constant DELAY_FFD            : time       := 1 ps; 
  constant DELAY_MXD	        : time       := 1  ps;
  constant DELAY_ZERO	        : time       := 0  ps;
  constant DELAY_ONE	        : time       := 1  ps;
  constant SWALLOW_PULSE	: time       := 2  ps;

  constant MAX_DATAWIDTH	: integer    := 4;

  signal AttrDdrClkEdge_int	: std_ulogic := '1';
  signal AttrSRtype		: std_logic_vector(1 downto 0) := (others => '1');

  signal C_dly			: std_ulogic := 'X';
  signal DATA1_dly		: std_ulogic := 'X';
  signal DATA2_dly		: std_ulogic := 'X';
  signal GSR_dly		: std_ulogic := '0';
  signal TCE_dly	        : std_ulogic := 'X';
  signal SR_dly		        : std_ulogic := 'X';

  signal TQ_zd			: std_ulogic := TO_X01(INIT_TQ);

  signal AttrDataRateTQ		: std_logic_vector(1 downto 0) := (others => 'X');
  signal AttrTriStateWidth	: std_logic_vector(1 downto 0) := (others => 'X');

  signal t1r			: std_ulogic := 'X';
  signal t2r			: std_ulogic := 'X';
  signal t3r			: std_ulogic := 'X';
  signal t4r			: std_ulogic := 'X';

  signal qt1			: std_ulogic := 'X';
  signal qt2			: std_ulogic := 'X';
  signal qt2n			: std_ulogic := 'X';

  signal sdata_edge		: std_ulogic := 'X';
  signal odata_edge		: std_ulogic := 'X';
  signal ddr_data		: std_ulogic := 'X';

  signal C			: std_ulogic := 'X';
  signal C2p			: std_ulogic := 'X';
  signal C3			: std_ulogic := 'X';

  signal tqsel			: std_logic_vector(5 downto 0) := (others => 'X');
  signal tqsr			: std_ulogic := 'X';
  signal tqrev			: std_ulogic := 'X';

  signal sel			: std_logic_vector(4 downto 0) := (others => 'X');

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  DATA1_dly          	 <= DATA1;
  DATA2_dly          	 <= DATA2;
  GSR_dly        	 <= '0';
  SR_dly         	 <= SR;
  TCE_dly        	 <= TCE;

  --------------------
  --  BEHAVIOR SECTION
  --------------------


--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  variable AttrDataRateTQ_var		: std_logic_vector(1 downto 0) := (others => 'X');
  variable AttrTriStateWidth_var	: std_logic_vector(1 downto 0) := (others => 'X');
  variable AttrDdrClkEdge_int_var		: std_ulogic := 'X';

  begin

      ------------------ DATA_RATE_TQ validity check ------------------
      if((DATA_RATE_TQ = "BUF") or (DATA_RATE_TQ = "buf")) then
         AttrDataRateTQ_var := "00";
      elsif((DATA_RATE_TQ = "SDR") or (DATA_RATE_TQ = "sdr")) then
         AttrDataRateTQ_var := "01";
      elsif((DATA_RATE_TQ = "DDR") or (DATA_RATE_TQ = "ddr")) then
         AttrDataRateTQ_var := "10";
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
      end if;

---------------------------------------------------------------------
     AttrDataRateTQ	<= AttrDataRateTQ_var;
     AttrTriStateWidth	<= AttrTriStateWidth_var;
     wait;
  end process prcs_init;

--###################################################################
--#####                   Concurrent exe                        #####
--###################################################################
   C_dly <= BUFO when (DDR3_MODE = '1') else CLK when (DDR3_MODE = '0'); 

   C2p    <= (C_dly and AttrDdrClkEdge_int) or 
             ((not C_dly) and (not AttrDdrClkEdge_int)); 
   C3     <= not C2p;

   tqsr   <= (not (AttrSRtype(0)) and SR_dly and not (TO_X01(SRVAL_TQ)))
                               or
              (not (AttrSRtype(0)) and (TO_X01(SRVAL_TQ)));

   tqrev  <= (not (AttrSRtype(0)) and SR_dly and (TO_X01(SRVAL_TQ)))
                               or
              (not (AttrSRtype(0)) and not (TO_X01(SRVAL_TQ)));

   tqsel  <= TCE & AttrDataRateTQ & AttrTriStateWidth & tqsr;


--###################################################################
--#####                        qt1 reg                          #####
--###################################################################
  prcs_qt1_reg:process(C_dly, GSR_dly, SR_dly)
  variable qt1_var    : std_ulogic := TO_X01(INIT_TQ);
  variable FIRST_TIME : boolean    := true;
  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         qt1_var    :=  TO_X01(INIT_TQ);
         FIRST_TIME := false;
     elsif(GSR_dly = '0') then
         if(rising_edge(C_dly)) then
            if(SR_dly = '1') then
               qt1_var  :=  TO_X01(SRVAL_TQ);
            elsif(TCE_dly = '1') then
                qt1_var := DATA1_dly;
            end if;
         end if;
     end if;

     qt1  <= qt1_var  after DELAY_FFD;

  end process prcs_qt1_reg;
--###################################################################
--#####                        qt2 reg                          #####
--###################################################################
  prcs_qt2_reg:process(C2p, GSR_dly, SR_dly)
  variable qt2_var    : std_ulogic := TO_X01(INIT_TQ);
  variable FIRST_TIME : boolean    := true;
  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         qt2_var    :=  TO_X01(INIT_TQ);
         FIRST_TIME := false;
     elsif(GSR_dly = '0') then
         if(rising_edge(C2p)) then
            if(SR_dly = '1') then
               qt2_var  :=  TO_X01(SRVAL_TQ);
            elsif(TCE_dly = '1') then
               qt2_var := DATA2_dly;
            end if;
         end if;
     end if;

     qt2  <= qt2_var  after DELAY_FFD;

  end process prcs_qt2_reg;

--###################################################################
--#####                        qt2n reg                          #####
--###################################################################
  prcs_qt2n_reg:process(C3, GSR_dly, SR_dly)
  variable qt2n_var   : std_ulogic := TO_X01(INIT_TQ);
  variable FIRST_TIME : boolean    := true;
  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         qt2n_var    :=  TO_X01(INIT_TQ);
         FIRST_TIME := false;
     elsif(GSR_dly = '0') then
         if(rising_edge(C3)) then
            if(SR_dly = '1') then
               qt2n_var  :=  TO_X01(SRVAL_TQ);
            elsif(TCE_dly = '1') then
               qt2n_var := qt2;
            end if;
         end if;

     end if;

     qt2n  <= qt2n_var  after DELAY_FFD;

  end process prcs_qt2n_reg;

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
  prcs_ddrdata:process(ddr_data, sdata_edge, odata_edge, AttrDdrClkEdge_int)
  begin
     ddr_data <= ((odata_edge and (not AttrDdrClkEdge_int)) or 
                    (sdata_edge and AttrDdrClkEdge_int)) after DELAY_ONE;
  end process prcs_ddrdata;

---////////////////////////////////////////////////////////////////////
---                       Outputs
---////////////////////////////////////////////////////////////////////
  prcs_TQ_mux:process(tqsel, DATA1_dly, ddr_data, qt1, GSR_dly)

  variable FIRST_TIME : boolean := true;

  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
       TQ_zd    <=  TO_X01(INIT_TQ);
       FIRST_TIME := false;
     elsif(GSR_dly = '0') then

        if((tqsel(4 downto 3) = "01") and  (tqsel(0) = '1')) then
           TQ_zd <= '0' after DELAY_ONE;

        elsif((tqsel(4 downto 3) = "10") and (tqsel(0) = '1')) then
           TQ_zd <= '0' after DELAY_ONE;

        elsif((tqsel(4 downto 3) = "01") and (tqsel(0) = '1')) then
           TQ_zd <= '0' after DELAY_ONE;

        elsif((tqsel(4 downto 3) = "10") and (tqsel(0) = '1')) then
           TQ_zd <= '0' after DELAY_ONE;

        elsif(tqsel(4 downto 1) = "0000") then
           TQ_zd <= DATA1_dly  after DELAY_ONE;
        else
           case tqsel is
--              when "001000" |  "010010" |  "010100" =>
--                    TQ_zd <= TQ_zd after DELAY_ONE;
              when "101000" =>
                    TQ_zd <= qt1 after DELAY_ONE;
              when "110010" | "110100" =>
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


end TOUT_OSERDESE1_VHD_V;
----- END_SUBMOD_TOUT_OSERDESE1_VHD

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

library unisim;
use unisim.vpkg.all;
use unisim.vcomponents.all;

----- CELL OSERDESE1 -----
--//////////////////////////////////////////////////////////// 
--////////////////////// OSERDESE1 /////////////////////////
--//////////////////////////////////////////////////////////// 

entity OSERDESE1 is

  generic(


      DATA_RATE_OQ : string := "DDR";
      DATA_RATE_TQ : string := "DDR";
      DATA_WIDTH : integer := 4;
      DDR3_DATA : integer := 1;
      INIT_OQ : bit := '0';
      INIT_TQ : bit := '0';
      INTERFACE_TYPE : string := "DEFAULT";
      ODELAY_USED : integer := 0;
      SERDES_MODE : string := "MASTER";
      SRVAL_OQ : bit := '0';
      SRVAL_TQ : bit := '0';
      TRISTATE_WIDTH : integer := 4
      );

  port(
      OCBEXTEND            : out std_ulogic;
      OFB                  : out std_ulogic;
      OQ                   : out std_ulogic;
      SHIFTOUT1            : out std_ulogic;
      SHIFTOUT2            : out std_ulogic;
      TFB                  : out std_ulogic;
      TQ                   : out std_ulogic;
      CLK                  : in std_ulogic;
      CLKDIV               : in std_ulogic;
      CLKPERF              : in std_ulogic;
      CLKPERFDELAY         : in std_ulogic;
      D1                   : in std_ulogic;
      D2                   : in std_ulogic;
      D3                   : in std_ulogic;
      D4                   : in std_ulogic;
      D5                   : in std_ulogic;
      D6                   : in std_ulogic;
      OCE                  : in std_ulogic;
      ODV                  : in std_ulogic;
      RST                  : in std_ulogic;
      SHIFTIN1             : in std_ulogic;
      SHIFTIN2             : in std_ulogic;
      T1                   : in std_ulogic;
      T2                   : in std_ulogic;
      T3                   : in std_ulogic;
      T4                   : in std_ulogic;
      TCE                  : in std_ulogic;
      WC                   : in std_ulogic
    );

end OSERDESE1;

architecture OSERDESE1_V OF OSERDESE1 is


component RANK12D_OSERDESE1_VHD is
  generic(

         DATA_RATE_OQ		: string	:= "DDR";
         DATA_WIDTH		: integer	:= 4;
         SERDES_MODE		: string	:= "MASTER";
         INIT_OQ		: bit		:= '0';
         SRVAL_OQ		: bit		:= '1'
    );
  port(
      DATA1_OUT		: out std_ulogic;
      DATA2_OUT		: out std_ulogic;
      IOCLK_GLITCH	: out std_ulogic;
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
      D2RNK2		: in std_ulogic;
      OCE		: in std_ulogic;
      SR	        : in std_ulogic;
      SHIFTIN1		: in std_ulogic;
      SHIFTIN2		: in std_ulogic
    );
end component;


component TRIF_OSERDESE1_VHD is
  generic(

         DATA_RATE_TQ           : string;
         TRISTATE_WIDTH         : integer       := 1;
         INIT_TQ                : bit           := '0';
         SRVAL_TQ               : bit           := '1'
    );
  port(
      DATA1_OUT         : out std_ulogic;
      DATA2_OUT         : out std_ulogic;

      C                 : in std_ulogic;
      CLKDIV            : in std_ulogic;
      LOAD              : in std_ulogic;
      SR                : in std_ulogic;
      T1                : in std_ulogic;
      T2                : in std_ulogic;
      T3                : in std_ulogic;
      T4                : in std_ulogic;
      TCE               : in std_ulogic
    );
end component;

component TXBUFFER_OSERDESE1_VHD is
  port(
      EXTRA             : out std_ulogic;
      IODELAY_STATE     : out std_ulogic;
      QMUX1             : out std_ulogic;
      QMUX2             : out std_ulogic;
      TMUX1             : out std_ulogic;
      TMUX2             : out std_ulogic;

      BUFO              : in std_ulogic;
      BUFOP             : in std_ulogic;
      CLK               : in std_ulogic;
      CLKDIV            : in std_ulogic;
      D1                : in std_ulogic;
      D2                : in std_ulogic;
      DDR3_DATA         : in std_ulogic;
      DDR3_MODE         : in std_ulogic;
      ODELAY_USED       : in std_ulogic;
      ODV               : in std_ulogic;
      T1                : in std_ulogic;
      T2                : in std_ulogic;
      TRIF              : in std_ulogic;
      RST               : in std_ulogic;
      WC                : in std_ulogic
    );

end component;

component DOUT_OSERDESE1_VHD is

  generic(
         DATA_RATE_OQ           : string        := "DDR";
         INIT_OQ                : bit           := '0';
         SRVAL_OQ               : bit           := '0';
         INTERFACE_TYPE         : string        := "DEFAULT"
    );

  port(
      OQ                : out std_ulogic;
      D2RNK2_OUT        : out std_ulogic;

      BUFO              : in std_ulogic;
      CLK               : in std_ulogic;
      DATA1             : in std_ulogic;
      DATA2             : in std_ulogic;
      OCE               : in std_ulogic;
      SR                : in std_ulogic;
      DDR3_MODE         : in std_ulogic
    );
end component;

component TOUT_OSERDESE1_VHD is
  generic(

         DATA_RATE_TQ		: string;
         TRISTATE_WIDTH		: integer;
         INIT_TQ		: bit		:= '0';
         SRVAL_TQ		: bit		:= '1'
    );
  port(
      TQ		: out std_ulogic;

      BUFO		: in std_ulogic;
      CLK		: in std_ulogic;
      DATA1		: in std_ulogic;
      DATA2		: in std_ulogic;
      DDR3_MODE		: in std_ulogic;
      SR	        : in std_ulogic;
      TCE		: in std_ulogic
    );
end component;

  constant SYNC_PATH_DELAY      : time       := 100 ps; 

  constant DELAY_FFINP          : time       := 300 ps; 
  constant DELAY_MXINP1         : time       := 60  ps;
  constant DELAY_MXINP2         : time       := 120 ps;
  constant DELAY_OCLKDLY        : time       := 750 ps;

  constant MAX_DATAWIDTH	: integer    := 4;
 
  signal CLK_ipd                : std_ulogic := 'X';
  signal CLKDIV_ipd             : std_ulogic := 'X';
  signal CLKPERF_ipd            : std_ulogic := 'X';
  signal CLKPERFDELAY_ipd       : std_ulogic := 'X';
  signal D1_ipd                 : std_ulogic := 'X';
  signal D2_ipd                 : std_ulogic := 'X';
  signal D3_ipd                 : std_ulogic := 'X';
  signal D4_ipd                 : std_ulogic := 'X';
  signal D5_ipd                 : std_ulogic := 'X';
  signal D6_ipd                 : std_ulogic := 'X';
  signal GSR            : std_ulogic := '0';
  signal GSR_ipd                : std_ulogic := 'X';
  signal OCE_ipd                : std_ulogic := 'X';
  signal ODV_ipd                : std_ulogic := 'X';
  signal RST_ipd                : std_ulogic := 'X';
  signal SHIFTIN1_ipd           : std_ulogic := 'X';
  signal SHIFTIN2_ipd           : std_ulogic := 'X';
  signal TCE_ipd                : std_ulogic := 'X';
  signal T1_ipd                 : std_ulogic := 'X';
  signal T2_ipd                 : std_ulogic := 'X';
  signal T3_ipd                 : std_ulogic := 'X';
  signal T4_ipd                 : std_ulogic := 'X';
  signal WC_ipd                 : std_ulogic := 'X';

  signal CLK_dly                : std_ulogic := 'X';
  signal CLKDIV_dly             : std_ulogic := 'X';
  signal CLKPERF_dly            : std_ulogic := 'X';
  signal CLKPERFDELAY_dly       : std_ulogic := 'X';
  signal CLKPERFDELAY_dly_zero  : std_ulogic := 'X';
  signal D1_dly                 : std_ulogic := 'X';
  signal D2_dly                 : std_ulogic := 'X';
  signal D3_dly                 : std_ulogic := 'X';
  signal D4_dly                 : std_ulogic := 'X';
  signal D5_dly                 : std_ulogic := 'X';
  signal D6_dly                 : std_ulogic := 'X';
  signal GSR_dly                : std_ulogic := '0';
  signal OCE_dly                : std_ulogic := 'X';
  signal ODV_dly                : std_ulogic := 'X';
  signal RST_dly                : std_ulogic := 'X';
--  signal SR_dly                 : std_ulogic := 'X';
  signal SHIFTIN1_dly           : std_ulogic := 'X';
  signal SHIFTIN2_dly           : std_ulogic := 'X';
  signal T1_dly                 : std_ulogic := 'X';
  signal T2_dly                 : std_ulogic := 'X';
  signal T3_dly                 : std_ulogic := 'X';
  signal T4_dly                 : std_ulogic := 'X';
  signal TCE_dly                : std_ulogic := 'X';
  signal WC_dly                 : std_ulogic := 'X';

  signal IOCLKGLITCH_zd		: std_ulogic := 'X';
  signal OFB_zd			: std_ulogic := 'X';
  signal OQ_zd                  : std_ulogic := 'X';
  signal SHIFTOUT1_zd           : std_ulogic := 'X';
  signal SHIFTOUT2_zd           : std_ulogic := 'X';
  signal TFB_zd                 : std_ulogic := 'X';
  signal TQ_zd                  : std_ulogic := 'X';
  signal OCBEXTEND_zd           : std_ulogic := 'X';

  signal AttrDataRateOQ		: std_ulogic := 'X';
  signal AttrDataRateTQ		: std_logic_vector(1 downto 0) := (others => 'X');
  signal AttrDataWidth		: std_logic_vector(3 downto 0) := (others => 'X');
  signal AttrDdr3Data		: std_ulogic := 'X';
  signal AttrInterfaceType	: std_ulogic := 'X';
  signal AttrOdelayUsed		: std_ulogic := 'X';
  signal AttrSerdesMode		: std_ulogic := 'X';
  signal AttrTriStateWidth	: std_logic_vector(1 downto 0) := (others => 'X');

  signal data1_int              : std_ulogic := '0';
  signal data2_int              : std_ulogic := '0';
  signal load_int               : std_ulogic := '0';
  signal d2rnk2_int             : std_ulogic := '0';

  signal triin1_int             : std_ulogic := '0';
  signal triin2_int             : std_ulogic := '0';

  signal iodelay_state_int      : std_ulogic := '0';
  signal qmux1_int              : std_ulogic := '0';
  signal qmux2_int              : std_ulogic := '0';

  signal tmux1_int              : std_ulogic := '0';
  signal tmux2_int              : std_ulogic := '0';

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  CLK_dly        	 <= CLK            ;
  CLKDIV_dly     	 <= CLKDIV         ;
  CLKPERF_dly    	 <= CLKPERF        ;
  CLKPERFDELAY_dly	 <= CLKPERFDELAY   ;
  D1_dly         	 <= D1             ;
  D2_dly         	 <= D2             ;
  D3_dly         	 <= D3             ;
  D4_dly         	 <= D4             ;
  D5_dly         	 <= D5             ;
  D6_dly         	 <= D6             ;
  OCE_dly        	 <= OCE            ;
  ODV_dly        	 <= ODV            ;
  RST_dly        	 <= RST            ;
  SHIFTIN1_dly   	 <= SHIFTIN1       ;
  SHIFTIN2_dly   	 <= SHIFTIN2       ;
  T1_dly         	 <= T1             ;
  T2_dly         	 <= T2             ;
  T3_dly         	 <= T3             ;
  T4_dly         	 <= T4             ;
  TCE_dly        	 <= TCE            ;
  WC_dly         	 <= WC             ;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  variable AttrDataRateOQ_var		: std_ulogic := 'X';
  variable AttrDataRateTQ_var		: std_logic_vector(1 downto 0) := (others => 'X');
  variable AttrDataWidth_var		: std_logic_vector(3 downto 0) := (others => 'X');
  variable AttrDdr3Data_var		: std_ulogic := 'X';
  variable AttrInterfaceType_var	: std_ulogic := 'X';
  variable AttrOdelayUsed_var		: std_ulogic := 'X';
  variable AttrSerdesMode_var		: std_ulogic := 'X';
  variable AttrTriStateWidth_var	: std_logic_vector(1 downto 0) := (others => 'X');


  begin
-----------------------------------------------------------------
--------------------- DATA_RATE_OQ validity check ------------------
-----------------------------------------------------------------

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
             EntityName => "/OSERDESE1",
             GenericValue => DATA_WIDTH,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
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
                   EntityName => "/OSERDESE1",
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
                   EntityName => "/OSERDESE1",
                   GenericValue => DATA_WIDTH,
                   Unit => "",
                   ExpectedValueMsg => " The legal values for this attribute in SDR mode are ",
                   ExpectedGenericValue => " 2, 3, 4, 5, 6, 7 or 8.",
                   TailMsg => "",
                   MsgSeverity => Failure
                );
          end case;
      end if;

-----------------------------------------------------------------
------------------- DATA_RATE_TQ validity check -----------------
-----------------------------------------------------------------
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
             EntityName => "/OSERDESE1",
             GenericValue => DATA_RATE_TQ,
             Unit => "",
             ExpectedValueMsg => " The legal values for this attribute are ",
             ExpectedGenericValue => " BUF, SDR or DDR. ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

-----------------------------------------------------------------
------------------- TRISTATE_WIDTH validity check ---------------
-----------------------------------------------------------------
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
             EntityName => "/OSERDESE1",
             GenericValue => TRISTATE_WIDTH,
             Unit => "",
             ExpectedValueMsg => " The legal values for this attribute are ",
             ExpectedGenericValue => " 1, 2 or 4 ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

      ------------ TRISTATE_WIDTH /DATA_RATE combination check ------------
-- CR 551953 -- enabled TRISTATE_WIDTH to be 1 in DDR mode.
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


-----------------------------------------------------------------
------------------- INTERFACE_TYPE validity check ---------------
-----------------------------------------------------------------
      if(INTERFACE_TYPE = "DEFAULT") then
         AttrInterfaceType_var := '0';
      elsif(INTERFACE_TYPE = "MEMORY_DDR3") then
         AttrInterfaceType_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => "INTERFACE_TYPE ",
             EntityName => "/OSERDESE1",
             GenericValue => INTERFACE_TYPE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " DEFAULT or MEMORY_DDR3.",
             TailMsg => "",
             MsgSeverity => FAILURE 
         );
      end if;

-----------------------------------------------------------------
-------------------    DDR3_DATA  validity check  ---------------
-----------------------------------------------------------------
      if(DDR3_DATA = 0) then
         AttrDdr3Data_var := '0';
      elsif(DDR3_DATA = 1) then
         AttrDdr3Data_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => "DDR3_DATA",
             EntityName => "/OSERDESE1",
             GenericValue => DDR3_DATA,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " 0 or 1.",
             TailMsg => "",
             MsgSeverity => FAILURE 
         );
      end if;


-----------------------------------------------------------------
-------------------    ODELAY_USED  validity check --------------
-----------------------------------------------------------------
      if(ODELAY_USED = 0) then
         AttrOdelayUsed_var := '0';
      elsif(ODELAY_USED = 1) then
         AttrOdelayUsed_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => "ODELAY_USED",
             EntityName => "/OSERDESE1",
             GenericValue => ODELAY_USED,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " 0 or 1.",
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
             EntityName => "/OSERDESE1",
             GenericValue => SERDES_MODE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " MASTER or SLAVE.",
             TailMsg => "",
             MsgSeverity => FAILURE 
         );
      end if;

---------------------------------------------------------------------

     AttrDataRateOQ	<= AttrDataRateOQ_var;
     AttrDataRateTQ	<= AttrDataRateTQ_var;
     AttrDataWidth	<= AttrDataWidth_var;
     AttrDdr3Data	<= AttrDdr3Data_var;
     AttrInterfaceType	<= AttrInterfaceType_var;
     AttrOdelayUsed 	<= AttrOdelayUsed_var;
     AttrSerdesMode	<= AttrSerdesMode_var;
     AttrTriStateWidth	<= AttrTriStateWidth_var;

     wait;
  end process prcs_init;

  OFB_zd <= CLKPERF_dly when (ODELAY_USED = 1) else OQ_zd;
  TFB_zd <= iodelay_state_int;

-- IR 495397 and IR 499954
--   CLKPERFDELAY_dly_zero <= CLKPERFDELAY_dly when ((CLKPERFDELAY_dly = '1') or (CLKPERFDELAY_dly = '0')) 
--                            else '0';
                            
     CLKPERFDELAY_dly_zero <= CLKPERF_dly when (ODELAY_USED = 0) else
                              CLKPERFDELAY_dly when ((ODELAY_USED = 1) and ((CLKPERFDELAY_dly = '1') or (CLKPERFDELAY_dly = '0'))) else
                              '0';
                              
--###################################################################
--#####               Concurrent                                #####
--###################################################################

--###################################################################
--#####                    RANK12D  Instantiation               #####
--###################################################################
  INST_DFRONT : RANK12D_OSERDESE1_VHD
  generic map (
      DATA_RATE_OQ	=> DATA_RATE_OQ,
      DATA_WIDTH	=> DATA_WIDTH,
      SERDES_MODE	=> SERDES_MODE,
      INIT_OQ	=> INIT_OQ,
      SRVAL_OQ	=> SRVAL_OQ
  )
  port map (
      DATA1_OUT		=> data1_int,
      DATA2_OUT		=> data2_int,
      IOCLK_GLITCH	=> IOCLKGLITCH_zd,
      LOAD		=> load_int,
      SHIFTOUT1		=> SHIFTOUT1_zd,
      SHIFTOUT2		=> SHIFTOUT2_zd,

      C			=> CLK_dly,
      CLKDIV		=> CLKDIV_dly,
      D1		=> D1_dly,
      D2		=> D2_dly,
      D3		=> D3_dly,
      D4		=> D4_dly,
      D5		=> D5_dly,
      D6		=> D6_dly,
      D2RNK2		=> d2rnk2_int,
      OCE		=> OCE_dly,
      SR	        => RST_dly,
      SHIFTIN1		=> SHIFTIN1_dly,
      SHIFTIN2		=> SHIFTIN2_dly
  );

--###################################################################
--#####                           TRIF                          #####
--###################################################################
  INST_TFRONT : TRIF_OSERDESE1_VHD
  generic map (

      DATA_RATE_TQ   => DATA_RATE_TQ,
      TRISTATE_WIDTH => TRISTATE_WIDTH,
      INIT_TQ        => INIT_TQ,
      SRVAL_TQ       => INIT_TQ
  )
  port map (
      DATA1_OUT         => triin1_int,
      DATA2_OUT         => triin2_int,

      C                 => CLK_dly,
      CLKDIV            => CLKDIV_dly,
      LOAD              => load_int,
      SR                => RST_dly,
      T1                => T1_dly,
      T2                => T2_dly,
      T3                => T3_dly,
      T4                => T4_dly,
      TCE               => TCE_dly
  );

--###################################################################
--#####                          TXBUFFER                       #####
--###################################################################
  INST_DDR3FIFO : TXBUFFER_OSERDESE1_VHD 
  port map(
      EXTRA             => OCBEXTEND_zd,
      IODELAY_STATE     => iodelay_state_int,
      QMUX1             => qmux1_int,
      QMUX2             => qmux2_int,
      TMUX1             => tmux1_int,
      TMUX2             => tmux2_int,

      BUFO              => CLKPERFDELAY_dly_zero,
      BUFOP             => CLKPERF_dly,
      CLK               => CLK_dly,
      CLKDIV            => CLKDIV_dly,
      D1                => data1_int,
      D2                => data2_int,
      DDR3_DATA         => AttrDdr3Data,
      DDR3_MODE         => AttrInterfaceType,
      ODELAY_USED       => AttrOdelayUsed,
      ODV               => ODV_dly,
      T1                => triin1_int,
      T2                => triin2_int,
      TRIF              => TQ_zd,
      RST               => RST_dly,
      WC                => WC_dly 
  );

--###################################################################
--#####                            DOUT                         #####
--###################################################################
 INST_DATAO : DOUT_OSERDESE1_VHD
  generic map(
      DATA_RATE_OQ      => DATA_RATE_OQ,
      INIT_OQ           => INIT_OQ,
      SRVAL_OQ          => SRVAL_OQ,
      INTERFACE_TYPE    => INTERFACE_TYPE
  )
  port map(
      OQ                => OQ_zd,
      D2RNK2_OUT        => d2rnk2_int,

      BUFO              => CLKPERFDELAY_dly_zero,
      CLK               => CLK_dly,
      DATA1             => qmux1_int,
      DATA2             => qmux2_int,
      OCE               => OCE_dly,
      SR                => RST_dly,
      DDR3_MODE         => AttrInterfaceType
  );

--###################################################################
--#####                            TOUT                         #####
--###################################################################
 INST_TRIO : TOUT_OSERDESE1_VHD
  generic map (
      DATA_RATE_TQ      => DATA_RATE_TQ,
      TRISTATE_WIDTH    => TRISTATE_WIDTH,
      INIT_TQ           => INIT_TQ,
      SRVAL_TQ          => SRVAL_TQ
  )
  port map (
      TQ                => TQ_zd,

      BUFO              => CLKPERFDELAY_dly_zero,
      CLK               => CLK_dly,
      DATA1             => tmux1_int,
      DATA2             => tmux2_int,
      DDR3_MODE         => AttrInterfaceType,
      SR                => RST_dly,
      TCE               => TCE_dly
  );


--####################################################################

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  OCBEXTEND   <= OCBEXTEND_zd;
  OFB         <= OFB_zd after 10 ps;
  OQ          <= OQ_zd after 100 ps;
  SHIFTOUT1   <= SHIFTOUT1_zd;
  SHIFTOUT2   <= SHIFTOUT2_zd;
  TFB         <= TFB_zd after 10 ps;
  TQ          <= TQ_zd after 100 ps;
 
--####################################################################

end OSERDESE1_V;

