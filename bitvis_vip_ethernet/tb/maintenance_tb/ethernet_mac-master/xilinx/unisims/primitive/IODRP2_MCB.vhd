-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/stan/VITAL/IODRP2_MCB.vhd,v 1.19 2012/04/05 19:52:03 robh Exp $
-------------------------------------------------------
--  Copyright (c) 2009 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   / 
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version : 11.1
--  \   \          Description : Xilinx Functional Simulation Library Component
--  /   /                        IODELAY2 Dynamic Reconfiguration Port port for MCB
-- /___/   /\      Filename    : IODRP2_MCB.vhd
-- \   \  /  \      
--  \__ \/\__ \                  
--                                  
--  Revision Date:  Comment
--     10/03/2008:  Initial version. From IODELAY2/IODRP2
--     11/05/2008   I/O, structure change
--                  Correct BKST functionality
--     11/19/2008   Change SIM_TAP_DELAY to SIM_TAPDELAY_VALUE
--     02/12/2009   CR1016 update DOUT to match HW
--                  CR506027 IODRP state machine, sync_to_data off
--                  CR502236 lumped delay reg
--     02/19/2009   CR508947 remove pin READEN, sync with yml
--     03/05/2009   CR511015 VHDL - VER sync
--                  CR511054 Output at time 0 fix
--                  CR511378 Remove timing from AUX* and MEMUPDATE, add to SDO per yml
--     04/09/2009   CR480001 fix calibration.
--     04/22/2009   CR518721 ODELAY value fix at time 0
--     07/23/2009   CR527208 Race condition in cal sig
--     08/07/2009   CR511054 Time 0 output initialization
--                  CR529368 Input bypass ouput when delay line idle
--     09/01/2009   CR531995 remove pci_ce_reg, byp_ts_ff_reg, byp_op_ff_reg from addr6
--     11/04/2009   CR538116 fix calibrate_done when cal_delay saturates
--     07/07/2010   CR565218 IDELAY_MODE=PCI fix
--     08/30/2010   CR573470 default delay value
--     10/22/2010   CR578478 Update delay values when T_INDELAY changes
--     01/06/2011   CR587485 behaviour change for delay increments or decrements
--     01/12/2012   CR639067 data transitions not required after CAL
--     01/12/2012   CR639265 X input causes delay line in PCI mode to lock up in X
--     01/12/2012   CR639618 Change delay line update after INC
--     04/05/2012   CR652228 INC, RST, BUSY inconsistent between ver vhdl
--  End Revision
-------------------------------------------------------

----- CELL IODRP2_MCB -----

library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

  entity IODRP2_MCB is
    generic (
      DATA_RATE : string := "SDR";
      IDELAY_VALUE : integer := 0;
      MCB_ADDRESS : integer := 0;
      ODELAY_VALUE : integer := 0;
      SERDES_MODE : string := "NONE";
      SIM_TAPDELAY_VALUE : integer := 75
    );

    port (
      AUXSDO               : out std_ulogic;
      DATAOUT              : out std_ulogic;
      DATAOUT2             : out std_ulogic;
      DOUT                 : out std_ulogic;
      DQSOUTN              : out std_ulogic;
      DQSOUTP              : out std_ulogic;
      SDO                  : out std_ulogic;
      TOUT                 : out std_ulogic;
      ADD                  : in std_ulogic;
      AUXADDR              : in std_logic_vector(4 downto 0);
      AUXSDOIN             : in std_ulogic;
      BKST                 : in std_ulogic;
      CLK                  : in std_ulogic;
      CS                   : in std_ulogic;
      IDATAIN              : in std_ulogic;
      IOCLK0               : in std_ulogic;
      IOCLK1               : in std_ulogic;
      MEMUPDATE            : in std_ulogic;
      ODATAIN              : in std_ulogic;
      SDI                  : in std_ulogic;
      T                    : in std_ulogic      
    );
    end IODRP2_MCB;

    architecture IODRP2_MCB_V of IODRP2_MCB is

    constant IN_DELAY : time := 110 ps;
    constant OUT_DELAY : time := 0 ps;
    constant INCLK_DELAY : time := 1 ps;
    constant OUTCLK_DELAY : time := 0 ps;
    constant WRAPAROUND : std_ulogic := '0';
    constant STAY_AT_LIMIT : std_ulogic := '1';
    constant SDR : std_ulogic := '1';
    constant DDR : std_ulogic := '0';
    constant IO : std_logic_vector(1 downto 0) := "00";
    constant I : std_logic_vector(1 downto 0) := "01";
    constant O : std_logic_vector(1 downto 0) := "11";
    constant PCI : std_ulogic := '0';
    constant NORMAL : std_ulogic := '1';
    constant DEFAULT : std_logic_vector(3 downto 0) := "1001";
    constant FIXED : std_logic_vector(3 downto 0) := "1000";
    constant VAR : std_logic_vector(3 downto 0) := "1100";
    constant DIFF_PHASE_DETECTOR : std_logic_vector(3 downto 0) := "1111";
    constant NONE : std_ulogic := '1';
    constant MASTER : std_ulogic := '1';
    constant SLAVE : std_ulogic := '0';
    constant MODULE_NAME : string  := "IODRP2_MCB";
    constant IDLE        : std_logic_vector(2 downto 0) := "000";
    constant ADDR_ACTIVE : std_logic_vector(2 downto 0) := "001";
    constant DATA_ACTIVE : std_logic_vector(2 downto 0) := "010";
    constant IDELAY_MODE : string := "NORMAL";
    constant PAD_STRING : string := "                                                                                                   ";
    constant WRAPAROUND_STRING    : string  := "WRAPAROUND   ";
    constant STAY_AT_LIMIT_STRING : string  := "STAY_AT_LIMIT";
    constant IO_STRING      : string := "IO     ";
    constant IDATAIN_STRING : string := "IDATAIN";
    constant ODATAIN_STRING : string := "ODATAIN";
    constant NORMAL_STRING : string := "NORMAL";
    constant PCI_STRING    : string := "PCI   ";
    constant NONE_STRING   : string := "NONE  ";
    constant MASTER_STRING : string := "MASTER";
    constant SLAVE_STRING  : string := "SLAVE ";
    constant DEFAULT_STRING                : string := "DEFAULT               ";
    constant DIFF_PHASE_DETECTOR_STRING    : string := "DIFF_PHASE_DETECTOR   ";
    constant FIXED_STRING                  : string := "FIXED                 ";
    constant VARIABLE_FROM_HALF_MAX_STRING : string := "VARIABLE_FROM_HALF_MAX";
    constant VARIABLE_FROM_ZERO_STRING     : string := "VARIABLE_FROM_ZERO    ";
    constant COUNTER_WRAPAROUND_MAX : integer := STAY_AT_LIMIT_STRING'length;
    constant DELAY_SRC_MAX          : integer := ODATAIN_STRING'length;
    constant IDELAY_MODE_MAX        : integer := NORMAL_STRING'length;
    constant IDELAY_TYPE_MAX        : integer := VARIABLE_FROM_HALF_MAX_STRING'length;
    constant SERDES_MODE_MAX        : integer := MASTER_STRING'length;
    type iob_type is array(8 downto 0) of std_logic_vector(7 downto 0);

function boolean_to_string(bool: boolean)
    return string is
    begin
      if bool then
        return "TRUE";
      else
        return "FALSE";
      end if;
    end boolean_to_string;

    signal COUNTER_WRAPAROUND_BINARY : std_ulogic := WRAPAROUND;
    signal DATA_RATE_BINARY : std_ulogic := SDR;
    signal IDELAY2_VALUE_BINARY : std_logic_vector(7 downto 0) := "00000000";
    signal IDELAY_MODE_BINARY : std_ulogic := NORMAL;
    signal IDELAY_TYPE_BINARY : std_logic_vector(3 downto 0) := VAR;
    signal IDELAY_VALUE_BINARY : std_logic_vector(7 downto 0) := "00000000";
    signal MCB_ADDRESS_BINARY      : std_logic_vector(3 downto 0) := "0000"; 
    signal ODELAY_VALUE_BINARY : std_logic_vector(7 downto 0) := "00000000";
    signal SERDES_MODE_BINARY : std_ulogic := NONE;
    signal SIM_TAPDELAY_VALUE_BINARY : std_logic_vector(6 downto 0) := CONV_STD_LOGIC_VECTOR(75, 7);
    signal Tstep : time := 75 ps;

    signal COUNTER_WRAPAROUND_PAD   : string(1 to COUNTER_WRAPAROUND_MAX) := (others => ' ');
    signal DELAY_SRC_PAD            : string(1 to DELAY_SRC_MAX) := (others => ' ');
    signal IDELAY_MODE_PAD          : string(1 to IDELAY_MODE_MAX) := (others => ' ');
    signal IDELAY_TYPE_PAD          : string(1 to IDELAY_TYPE_MAX) := (others => ' ');
    signal SERDES_MODE_PAD          : string(1 to SERDES_MODE_MAX) := (others => ' ');

    signal GSR_INDELAY : std_ulogic;
    signal rst_sig       : std_ulogic := '0';
    signal ce_sig        : std_ulogic := '0';
    signal inc_sig       : std_ulogic := '0';
    signal cal_sig       : std_ulogic := '0';
    signal cs_sig       : std_ulogic := 'X';

-- FF outputs
    signal delay1_out_sig: std_ulogic := '0';
    signal delay1_out    : std_ulogic := '0';
    signal delay2_out    : std_ulogic := '0';
    signal delay1_out_dly: std_ulogic := '0';
    signal tout_out_int  : std_ulogic := '0';
    signal busy_out_int  : std_ulogic := '1';
    signal busy_out_pe_one_shot : std_ulogic := '1';
    signal busy_out_ne_one_shot : std_ulogic := '1';
    signal busy_out_dly  : std_ulogic := '1';
    signal busy_out_pe_dly  : std_ulogic := '1';
    signal busy_out_pe_dly1 : std_ulogic := '1';
    signal busy_out_ne_dly  : std_ulogic := '1';
    signal busy_out_ne_dly1 : std_ulogic := '1';
    signal sdo_out_int   : std_ulogic := '0';

-- clk doubler signals 
    signal ioclk0_int       : std_ulogic := '0';
    signal ioclk1_int       : std_ulogic := '0';
    signal ioclk_int        : std_ulogic := '0';
    signal first_edge       : std_ulogic := '0';

-- Attribute settings 
    signal sat_at_max_reg        : std_ulogic := '0';
    signal rst_to_half_reg       : std_ulogic := '0';
    signal ignore_rst            : std_ulogic := '0';
    signal force_rx_reg          : std_ulogic := '0';
    signal force_dly_dir_reg     : std_ulogic := '0';
    signal output_delay_off      : std_ulogic := '0';
    signal input_delay_off       : std_ulogic := '0';
    signal isslave               : std_ulogic := '0';
    signal encasc                : std_ulogic := '0';


-- Error flags
    signal counter_wraparound_err_flag : boolean := FALSE;
    signal data_rate_err_flag          : boolean := FALSE;
    signal serdes_mode_err_flag        : boolean := FALSE;
    signal odelay_value_err_flag       : boolean := FALSE;
    signal idelay_value_err_flag       : boolean := FALSE;
    signal sim_tap_delay_err_flag      : boolean := FALSE;
    signal idelay_type_err_flag        : boolean := FALSE;
    signal idelay_mode_err_flag        : boolean := FALSE;
    signal delay_src_err_flag          : boolean := FALSE;
    signal idelay2_value_err_flag      : boolean := FALSE;
    signal mcb_address_err_flag        : boolean := FALSE;
    signal attr_err_flag               : std_ulogic := '0';

-- internal logic
    signal cal_count          : std_logic_vector(3 downto 0) := "1011"; -- 0 to 11
    signal cal_delay          : std_logic_vector(7 downto 0) := (others => '0');
    signal max_delay          : std_logic_vector(7 downto 0) := (others => '0');
    signal half_max           : std_logic_vector(7 downto 0) := (others => '0');
    signal delay_val_pe_1     : std_logic_vector(7 downto 0) := (others => '0');
    signal delay_val_ne_1     : std_logic_vector(7 downto 0) := (others => '0');
    signal delay_val_pe_clk   : std_ulogic;
    signal delay_val_ne_clk   : std_ulogic;
    signal first_time_pe      : std_ulogic := '1';
    signal first_time_ne      : std_ulogic := '1';
    signal idelay_val_pe_reg  : std_logic_vector(7 downto 0) :=  CONV_STD_LOGIC_VECTOR(IDELAY_VALUE, 8);
    signal idelay_val_pe_m_reg  : std_logic_vector(7 downto 0) :=  CONV_STD_LOGIC_VECTOR(IDELAY_VALUE, 8);
    signal idelay_val_pe_s_reg  : std_logic_vector(7 downto 0) :=  CONV_STD_LOGIC_VECTOR(IDELAY_VALUE, 8);
    signal idelay_val_pe_m_reg1 : std_logic_vector(7 downto 0) :=  CONV_STD_LOGIC_VECTOR(IDELAY_VALUE, 8);
    signal idelay_val_pe_s_reg1 : std_logic_vector(7 downto 0) :=  CONV_STD_LOGIC_VECTOR(IDELAY_VALUE, 8);
    signal idelay_val_ne_reg  : std_logic_vector(7 downto 0) :=  CONV_STD_LOGIC_VECTOR(IDELAY_VALUE, 8);
    signal idelay_val_ne_m_reg  : std_logic_vector(7 downto 0) :=  CONV_STD_LOGIC_VECTOR(IDELAY_VALUE, 8);
    signal idelay_val_ne_s_reg  : std_logic_vector(7 downto 0) :=  CONV_STD_LOGIC_VECTOR(IDELAY_VALUE, 8);
    signal idelay_val_ne_m_reg1 : std_logic_vector(7 downto 0) :=  CONV_STD_LOGIC_VECTOR(IDELAY_VALUE, 8);
    signal idelay_val_ne_s_reg1 : std_logic_vector(7 downto 0) :=  CONV_STD_LOGIC_VECTOR(IDELAY_VALUE, 8);
    signal delay1_reached     : std_ulogic := '0';
    signal delay1_reached_1   : std_ulogic := '0';
    signal delay1_reached_2   : std_ulogic := '0';
    signal delay1_working     : std_ulogic := '0';
    signal delay1_working_1   : std_ulogic := '0';
    signal delay1_working_2   : std_ulogic := '0';
    signal delay1_ignore      : std_ulogic := '0';
    signal delay_val_pe_2     : std_logic_vector(7 downto 0) := (others => '0');
    signal delay_val_ne_2     : std_logic_vector(7 downto 0) := (others => '0');
    signal odelay_val_pe_reg  : std_logic_vector(7 downto 0) :=  CONV_STD_LOGIC_VECTOR(ODELAY_VALUE, 8);
    signal odelay_val_ne_reg  : std_logic_vector(7 downto 0) :=  CONV_STD_LOGIC_VECTOR(ODELAY_VALUE, 8);
    signal delay2_reached     : std_ulogic := '0';
    signal delay2_reached_1   : std_ulogic := '0';
    signal delay2_reached_2   : std_ulogic := '0';
    signal delay2_working     : std_ulogic := '0';
    signal delay2_working_1   : std_ulogic := '0';
    signal delay2_working_2   : std_ulogic := '0';
    signal delay2_ignore      : std_ulogic := '0';
    signal delay1_in          : std_ulogic := '0';
    signal delay2_in          : std_ulogic := '0';
    signal calibrate          : std_ulogic := '0';
    signal calibrate_done     : std_ulogic := '0';
    signal sync_to_data_reg   : std_ulogic := '0';
    signal pci_ce_reg         : std_ulogic := '0';

    signal data_reg      : std_logic_vector(7 downto 0) := "00000000";
    signal addr_reg      : std_logic_vector(7 downto 0) := "10000000";
    signal mem_updated   : std_ulogic := '1';
    signal shift_in      : std_logic_vector(7 downto 0) := "00000000";
    signal shift_out     : std_logic_vector(7 downto 0) := "11111111";
    signal mask          : std_logic_vector(7 downto 0) := "00000000";
    signal mc_iob        : iob_type;
    signal mc_iob_mask   : iob_type;
    signal if_state      : std_logic_vector(2 downto 0) := IDLE;
    signal cal_reg       : std_ulogic := '0';
    signal snapback_reg  : std_ulogic := '0';
    signal half_reg      : std_ulogic := '0';
    signal inc_reg       : std_ulogic := '0';
    signal ce_reg        : std_ulogic := '0';
    signal rst_reg       : std_ulogic := '0';
    signal direct_in_reg      : std_ulogic := '0';
    signal event_sel_m_reg    : std_logic_vector(1 downto 0) := (others => '0');
    signal plus1_s_reg        : std_ulogic := '0';
    signal lumped_delay_select_reg      : std_logic_vector(3 downto 0) := (others => '0');
    signal lumped_delay_reg : std_ulogic := '0';

    signal AUXSDO_OUT : std_ulogic;
    signal DATAOUT2_OUT : std_ulogic;
    signal DATAOUT_OUT : std_ulogic;
    signal DOUT_OUT : std_ulogic;
    signal DQSOUTN_OUT : std_ulogic;
    signal DQSOUTP_OUT : std_ulogic;
    signal SDO_OUT : std_ulogic;
    signal TOUT_OUT : std_ulogic;
    
    signal AUXSDO_OUTDELAY : std_ulogic;
    signal DATAOUT2_OUTDELAY : std_ulogic;
    signal DATAOUT_OUTDELAY : std_ulogic;
    signal DOUT_OUTDELAY : std_ulogic;
    signal DQSOUTN_OUTDELAY : std_ulogic;
    signal DQSOUTP_OUTDELAY : std_ulogic;
    signal SDO_OUTDELAY : std_ulogic;
    signal TOUT_OUTDELAY : std_ulogic;
    
  signal ADD_ipd : std_ulogic;
  signal AUXADDR_ipd : std_logic_vector(4 downto 0);
  signal AUXSDOIN_ipd : std_ulogic;
  signal BKST_ipd : std_ulogic;
  signal CLK_ipd : std_ulogic;
  signal CS_ipd : std_ulogic;
  signal IDATAIN_ipd : std_ulogic;
  signal IOCLK0_ipd : std_ulogic;
  signal IOCLK1_ipd : std_ulogic;
  signal MEMUPDATE_ipd : std_ulogic;
  signal ODATAIN_ipd : std_ulogic;
  signal SDI_ipd : std_ulogic;
  signal T_ipd : std_ulogic;
    
    signal ADD_INDELAY : std_ulogic;
    signal AUXADDR_INDELAY : std_logic_vector(4 downto 0);
    signal AUXSDOIN_INDELAY : std_ulogic;
    signal BKST_INDELAY : std_ulogic;
    signal CLK_INDELAY : std_ulogic;
    signal CS_INDELAY : std_ulogic;
    signal IDATAIN_INDELAY : std_ulogic;
    signal IOCLK0_INDELAY : std_ulogic;
    signal IOCLK1_INDELAY : std_ulogic;
    signal MEMUPDATE_INDELAY : std_ulogic;
    signal ODATAIN_INDELAY : std_ulogic;
    signal SDI_INDELAY : std_ulogic;
    signal T_INDELAY : std_ulogic := '1';
    

  procedure inc_dec(
  signal rst_sig                       : in std_ulogic;
  signal GSR_INDELAY                   : in std_ulogic;
  signal CLK_INDELAY                   : in std_ulogic;
  signal busy_out                      : in std_ulogic;
  signal ce_sig                        : in std_ulogic;
  signal pci_ce_reg                    : in std_ulogic;
  signal inc_sig                       : in std_ulogic;
  signal IDELAY_TYPE_BINARY            : in std_logic_vector(3 downto 0);
  signal SERDES_MODE_BINARY            : in std_ulogic;
  signal sat_at_max_reg                : in std_ulogic;
  signal max_delay                     : in std_logic_vector(7 downto 0);
  signal half_max                      : in std_logic_vector(7 downto 0);
  signal rst_to_half_reg               : in std_ulogic;
  signal ignore_rst                    : inout std_ulogic;
  signal idelay_val_pe_m_reg             : inout std_logic_vector(7 downto 0);
  signal idelay_val_pe_s_reg             : inout std_logic_vector(7 downto 0);
  signal idelay_val_ne_m_reg             : inout std_logic_vector(7 downto 0);
  signal idelay_val_ne_s_reg             : inout std_logic_vector(7 downto 0)
     ) is
  begin
     if (GSR_INDELAY = '1') then
        idelay_val_pe_m_reg <= IDELAY_VALUE_BINARY;
        idelay_val_pe_s_reg <= IDELAY_VALUE_BINARY;
        if (pci_ce_reg = '1') then -- PCI
           idelay_val_ne_m_reg <= IDELAY2_VALUE_BINARY;
           idelay_val_ne_s_reg <= IDELAY2_VALUE_BINARY;
        else
           idelay_val_ne_m_reg <= IDELAY_VALUE_BINARY;
           idelay_val_ne_s_reg <= IDELAY_VALUE_BINARY;
        end if;
     elsif (rst_sig= '1') then
        if (rst_to_half_reg = '1') then
           if (SERDES_MODE_BINARY = SLAVE) then
              if ((ignore_rst = '0') and (IDELAY_TYPE_BINARY = DIFF_PHASE_DETECTOR)) then
              -- slave phase detector first rst
                 idelay_val_pe_m_reg <= half_max;
                 idelay_val_ne_m_reg <= half_max;
                 idelay_val_pe_s_reg <= half_max(6 downto 0) & '0';
                 idelay_val_ne_s_reg <= half_max(6 downto 0) & '0';
                 ignore_rst <= '1';
              elsif (ignore_rst = '0') then
              -- all non diff phase detector slave rst
                 idelay_val_pe_s_reg <= half_max;
                 idelay_val_ne_s_reg <= half_max;
              else
              -- slave phase detector second or more rst
                 if ((idelay_val_pe_m_reg + half_max) > max_delay) then
                    idelay_val_pe_s_reg <= idelay_val_pe_m_reg + half_max - max_delay - 1;
                    idelay_val_ne_s_reg <= idelay_val_ne_m_reg + half_max - max_delay - 1;
                 else
                    idelay_val_pe_s_reg <= idelay_val_pe_m_reg + half_max;
                    idelay_val_ne_s_reg <= idelay_val_ne_m_reg + half_max;
                 end if;
              end if;
           elsif ((ignore_rst = '0') or (IDELAY_TYPE_BINARY /= DIFF_PHASE_DETECTOR)) then
           -- master or none first diff phase rst or all others
              idelay_val_pe_m_reg <= half_max;
              idelay_val_ne_m_reg <= half_max;
              ignore_rst <= '1';
           end if;
        else
           idelay_val_pe_m_reg <= "00000000";
           idelay_val_ne_m_reg <= "00000000";
           idelay_val_pe_s_reg <= "00000000";
           idelay_val_ne_s_reg <= "00000000";
        end if;
--     elsif ( rising_edge(CLK_INDELAY) and (busy_out = '0') and
--             (ce_sig = '1') and (rst_sig = '0') and
-- CR652228 - inc/dec one tap per clock regardless of busy
     elsif ( rising_edge(CLK_INDELAY) and (ce_sig = '1') and
             ( (IDELAY_TYPE_BINARY = VAR) or
               (IDELAY_TYPE_BINARY = DIFF_PHASE_DETECTOR) ) ) then  -- variable
        if (inc_sig = '1') then -- inc
           -- MASTER OR NONE
           -- (lt max_delay inc)
           if (idelay_val_pe_m_reg < max_delay) then
              idelay_val_pe_m_reg <= idelay_val_pe_m_reg + "00000001";
           -- wrap to 0 wrap (gte max_delay and wrap to 0)
           elsif (sat_at_max_reg = WRAPAROUND) then
              idelay_val_pe_m_reg <= "00000000";
           -- stay at max (gte max_delay and stay at max)
           else
              idelay_val_pe_m_reg <= max_delay;
           end if;
           -- SLAVE
           -- (lt max_delay inc)
           if (idelay_val_pe_s_reg < max_delay) then
              idelay_val_pe_s_reg <= idelay_val_pe_s_reg + "00000001";
           -- wrap to 0 wrap (gte max_delay and wrap to 0)
           elsif (sat_at_max_reg = WRAPAROUND) then
              idelay_val_pe_s_reg <= "00000000";
           -- stay at max (gte max_delay and stay at max)
           else
              idelay_val_pe_s_reg <= max_delay;
           end if;
           -- MASTER OR NONE
           -- (lt max_delay inc)
           if (idelay_val_ne_m_reg < max_delay) then
              idelay_val_ne_m_reg <= idelay_val_ne_m_reg + "00000001";
           -- wrap to 0 wrap (gte max_delay and wrap to 0)
           elsif (sat_at_max_reg = WRAPAROUND) then
              idelay_val_ne_m_reg <= "00000000";
           -- stay at max (gte max_delay and stay at max)
           else
              idelay_val_ne_m_reg <= max_delay;
           end if;
           -- SLAVE
           -- (lt max_delay inc)
           if (idelay_val_ne_s_reg < max_delay) then
              idelay_val_ne_s_reg <= idelay_val_ne_s_reg + "00000001";
           -- wrap to 0 wrap (gte max_delay and wrap to 0)
           elsif (sat_at_max_reg = WRAPAROUND) then
              idelay_val_ne_s_reg <= "00000000";
           -- stay at max (gte max_delay and stay at max)
           else
              idelay_val_ne_s_reg <= max_delay;
           end if;
        else -- dec
           -- MASTER OR NONE
           -- (between 0 and max_delay dec)
           if ((idelay_val_pe_m_reg > "00000000") and (idelay_val_pe_reg <= max_delay)) then
              idelay_val_pe_m_reg <= idelay_val_pe_m_reg - "00000001";
           -- stay at min (eq 0 and stay at max/min)
           elsif ((sat_at_max_reg = STAY_AT_LIMIT) and (idelay_val_pe_m_reg = "00000000")) then
              idelay_val_pe_m_reg <= "00000000";
           -- wrap to 0 wrap (gte max_delay or (eq 0 and wrap to max))
           else
              idelay_val_pe_m_reg <= max_delay;
           end if;
           -- SLAVE
           -- (between 0 and max_delay dec)
           if ((idelay_val_pe_s_reg > "00000000") and (idelay_val_pe_reg <= max_delay)) then
              idelay_val_pe_s_reg <= idelay_val_pe_s_reg - "00000001";
           -- stay at min (eq 0 and stay at max/min)
           elsif ((sat_at_max_reg = STAY_AT_LIMIT) and (idelay_val_pe_s_reg = "00000000")) then
              idelay_val_pe_s_reg <= "00000000";
           -- wrap to 0 wrap (gte max_delay or (eq 0 and wrap to max))
           else
              idelay_val_pe_s_reg <= max_delay;
           end if;
           -- MASTER OR NONE
           -- (between 0 and max_delay dec)
           if ((idelay_val_ne_m_reg > "00000000") and (idelay_val_ne_m_reg <= max_delay)) then
              idelay_val_ne_m_reg <= idelay_val_ne_m_reg - "00000001";
           -- stay at min (eq 0 and stay at max/min)
           elsif ((sat_at_max_reg = STAY_AT_LIMIT) and (idelay_val_ne_m_reg = "00000000")) then
              idelay_val_ne_m_reg <= "00000000";
           -- wrap to 0 wrap (gte max_delay or (eq 0 and wrap to max))
           else
              idelay_val_ne_m_reg <= max_delay;
           end if;
           -- SLAVE
           -- (between 0 and max_delay dec)
           if ((idelay_val_ne_s_reg > "00000000") and (idelay_val_ne_s_reg <= max_delay)) then
              idelay_val_ne_s_reg <= idelay_val_ne_s_reg - "00000001";
           -- stay at min (eq 0 and stay at max/min)
           elsif ((sat_at_max_reg = STAY_AT_LIMIT) and (idelay_val_ne_s_reg = "00000000")) then
              idelay_val_ne_s_reg <= "00000000";
           -- wrap to 0 wrap (gte max_delay or (eq 0 and wrap to max))
           else
              idelay_val_ne_s_reg <= max_delay;
           end if;
        end if;
     end if;
  end inc_dec;

  procedure write_to_ioi(
  signal addr_reg           : in    std_logic_vector(7 downto 0);
  signal data_reg           : in    std_logic_vector(7 downto 0);
  signal shift_out          : out   std_logic_vector(7 downto 0);
  signal cal_reg            : inout std_ulogic;
  signal snapback_reg       : inout std_ulogic;
  signal half_reg           : inout std_ulogic;
  signal inc_reg            : inout std_ulogic;
  signal ce_reg             : inout std_ulogic;
  signal rst_reg            : inout std_ulogic;
  signal SERDES_MODE_BINARY : in std_ulogic;
  signal max_delay          : inout std_logic_vector(7 downto 0);
  signal half_max           : inout std_logic_vector(7 downto 0);
  signal idelay_val_pe_m_reg  : inout std_logic_vector(7 downto 0);
  signal idelay_val_pe_s_reg  : inout std_logic_vector(7 downto 0);
  signal idelay_val_ne_m_reg  : inout std_logic_vector(7 downto 0);
  signal idelay_val_ne_s_reg  : inout std_logic_vector(7 downto 0);
  signal odelay_val_pe_reg  : inout std_logic_vector(7 downto 0);
  signal odelay_val_ne_reg  : inout std_logic_vector(7 downto 0);
  signal direct_in_reg      : inout std_ulogic;
  signal force_rx_reg       : inout std_ulogic;
  signal force_dly_dir_reg  : inout std_ulogic;
  signal event_sel_m_reg    : inout std_logic_vector(1 downto 0);
  signal plus1_s_reg        : inout std_ulogic;
  signal lumped_delay_select_reg      : inout std_logic_vector(3 downto 0);
  signal lumped_delay_reg   : inout std_ulogic;
  signal sync_to_data_reg   : inout std_ulogic;
  signal sat_at_max_reg     : inout std_ulogic;
  signal rst_to_half_reg    : inout std_ulogic
     ) is
begin
   if (addr_reg(6 downto 0) = X"01") then 
      cal_reg      <= data_reg(5);
      snapback_reg <= data_reg(4);
      half_reg     <= data_reg(3);
      inc_reg      <= data_reg(2);
      ce_reg       <= data_reg(1);
      rst_reg      <= data_reg(0);
      shift_out <= X"00";
   elsif (addr_reg(6 downto 0) = X"02") then 
      idelay_val_pe_m_reg <= data_reg;
      idelay_val_pe_s_reg <= data_reg;
      shift_out <= data_reg;
   elsif (addr_reg(6 downto 0) = X"03") then 
      idelay_val_ne_m_reg <= data_reg;
      idelay_val_ne_s_reg <= data_reg;
      shift_out <= data_reg;
   elsif (addr_reg(6 downto 0) = X"04") then 
      odelay_val_pe_reg <= data_reg;
      shift_out <= data_reg;
   elsif (addr_reg(6 downto 0) = X"05") then 
      odelay_val_ne_reg <= data_reg;
      shift_out <= data_reg;
   elsif (addr_reg(6 downto 0) = X"06") then 
      direct_in_reg     <= data_reg(4);
      force_rx_reg      <= data_reg(3);
      force_dly_dir_reg <= data_reg(2);
      if (SERDES_MODE_BINARY = SLAVE) then
         plus1_s_reg <= data_reg(0);
         shift_out <= "000" & data_reg(4 downto 2) & '0' & data_reg(0);
      else
         event_sel_m_reg     <= data_reg(1 downto 0);
         shift_out <= "000" & data_reg(4 downto 0);
      end if;
   elsif (addr_reg(6 downto 0) = X"07") then 
      lumped_delay_select_reg <= data_reg(7 downto 4);
      lumped_delay_reg <= data_reg(3);
      sync_to_data_reg   <= data_reg(2);
      sat_at_max_reg     <= data_reg(1);
      rst_to_half_reg    <= data_reg(0);
      shift_out <= data_reg;
   elsif (addr_reg(6 downto 0) = X"08") then 
      max_delay <= data_reg;
      half_max  <= '0' & data_reg(7 downto 1);
      shift_out <= data_reg;
   end if;
  end write_to_ioi;

  procedure read_from_ioi(
  signal addr_reg           : in    std_logic_vector(7 downto 0);
  signal shift_out          : inout std_logic_vector(7 downto 0);
  signal cal_reg            : in    std_ulogic;
  signal snapback_reg       : in    std_ulogic;
  signal half_reg           : in    std_ulogic;
  signal inc_reg            : in    std_ulogic;
  signal ce_reg             : in    std_ulogic;
  signal rst_reg            : in    std_ulogic;
  signal SERDES_MODE_BINARY : in std_ulogic;
  signal max_delay          : in    std_logic_vector(7 downto 0);
  signal half_max           : in    std_logic_vector(7 downto 0);
  signal idelay_val_pe_m_reg  : in    std_logic_vector(7 downto 0);
  signal idelay_val_ne_m_reg  : in    std_logic_vector(7 downto 0);
  signal idelay_val_pe_s_reg  : in    std_logic_vector(7 downto 0);
  signal idelay_val_ne_s_reg  : in    std_logic_vector(7 downto 0);
  signal odelay_val_pe_reg  : in    std_logic_vector(7 downto 0);
  signal odelay_val_ne_reg  : in    std_logic_vector(7 downto 0);
  signal direct_in_reg      : in    std_ulogic;
  signal force_rx_reg       : in    std_ulogic;
  signal force_dly_dir_reg  : in    std_ulogic;
  signal event_sel_m_reg    : in    std_logic_vector(1 downto 0);
  signal plus1_s_reg        : in    std_ulogic;
  signal lumped_delay_select_reg  : in    std_logic_vector(3 downto 0);
  signal lumped_delay_reg   : in    std_ulogic;
  signal sync_to_data_reg   : in    std_ulogic;
  signal sat_at_max_reg     : in    std_ulogic;
  signal rst_to_half_reg    : in    std_ulogic
     ) is
begin
   if (addr_reg(6 downto 0) = X"00") then 
      shift_out <= "00000000";
   elsif (addr_reg(6 downto 0) = X"01") then 
      shift_out <= "00000000"; -- w/o "00" & cal_reg & snapback_reg & half_reg & inc_reg & ce_reg & rst_reg;
   elsif (addr_reg(6 downto 0) = X"02") then 
      if (SERDES_MODE_BINARY = SLAVE) then
         shift_out <= idelay_val_pe_s_reg;
      else
         shift_out <= idelay_val_pe_m_reg;
      end if;
   elsif (addr_reg(6 downto 0) = X"03") then 
      if (SERDES_MODE_BINARY = SLAVE) then
         shift_out <= idelay_val_ne_s_reg;
      else
         shift_out <= idelay_val_ne_m_reg;
      end if;
   elsif (addr_reg(6 downto 0) = X"04") then 
      shift_out <= odelay_val_pe_reg;
   elsif (addr_reg(6 downto 0) = X"05") then 
      shift_out <= odelay_val_ne_reg;
   elsif (addr_reg(6 downto 0) = X"06") then 
      if (SERDES_MODE_BINARY = SLAVE) then
         shift_out <= "000" & direct_in_reg & force_rx_reg & force_dly_dir_reg & '0' & plus1_s_reg;
      else
         shift_out <= "000" & direct_in_reg & force_rx_reg & force_dly_dir_reg & event_sel_m_reg;
      end if;
   elsif (addr_reg(6 downto 0) = X"07") then 
      shift_out <= lumped_delay_select_reg & lumped_delay_reg & sync_to_data_reg & sat_at_max_reg & rst_to_half_reg;
   elsif (addr_reg(6 downto 0) = X"08") then 
      shift_out <= max_delay;
   else
      shift_out <= "00000000";
   end if;
  end read_from_ioi;

    begin
    AUXSDO_OUTDELAY <= AUXSDO_OUT after OUT_DELAY;
    DATAOUT2_OUTDELAY <= DATAOUT2_OUT after OUT_DELAY;
    DATAOUT_OUTDELAY <= DATAOUT_OUT after OUT_DELAY;
    DOUT_OUTDELAY <= DOUT_OUT after OUT_DELAY;
    DQSOUTN_OUTDELAY <= DQSOUTN_OUT after OUT_DELAY;
    DQSOUTP_OUTDELAY <= DQSOUTP_OUT after OUT_DELAY;
    SDO_OUTDELAY <= SDO_OUT after OUT_DELAY;
    TOUT_OUTDELAY <= TOUT_OUT after OUT_DELAY;
    
    CLK_ipd <= CLK;
    IOCLK0_ipd <= IOCLK0;
    IOCLK1_ipd <= IOCLK1;
    
    ADD_ipd <= ADD;
    AUXADDR_ipd <= AUXADDR;
    AUXSDOIN_ipd <= AUXSDOIN;
    BKST_ipd <= BKST;
    CS_ipd <= CS;
    IDATAIN_ipd <= IDATAIN;
    MEMUPDATE_ipd <= MEMUPDATE;
    ODATAIN_ipd <= ODATAIN;
    SDI_ipd <= SDI;
    T_ipd <= T;
    
    CLK_INDELAY <= CLK_ipd after INCLK_DELAY;
    IOCLK0_INDELAY <= IOCLK0_ipd after INCLK_DELAY;
    IOCLK1_INDELAY <= IOCLK1_ipd after INCLK_DELAY;
    
    ADD_INDELAY <= ADD_ipd after IN_DELAY;
    AUXADDR_INDELAY <= AUXADDR_ipd after IN_DELAY;
    AUXSDOIN_INDELAY <= AUXSDOIN_ipd after IN_DELAY;
    BKST_INDELAY <= BKST_ipd after IN_DELAY;
    CS_INDELAY <= CS_ipd after IN_DELAY;
    IDATAIN_INDELAY <= IDATAIN_ipd after IN_DELAY;
    MEMUPDATE_INDELAY <= MEMUPDATE_ipd after IN_DELAY;
    ODATAIN_INDELAY <= ODATAIN_ipd after IN_DELAY;
    SDI_INDELAY <= SDI_ipd after IN_DELAY;
    T_INDELAY <= T_ipd after IN_DELAY;
    rst_sig          <= rst_reg;
    ce_sig           <= ce_reg;
    inc_sig          <= inc_reg;
    cal_sig          <= cal_reg;
    GSR_INDELAY <= GSR;
    output_delay_off <= force_dly_dir_reg and force_rx_reg;
    input_delay_off  <= force_dly_dir_reg and not force_rx_reg;
    delay1_reached <= delay1_reached_1 or delay1_reached_2;
    delay2_reached <= delay2_reached_1 or delay2_reached_2;
    delay1_working <= delay1_working_1 or delay1_working_2;
    delay2_working <= delay2_working_1 or delay2_working_2;
  --------------------
  --  BEHAVIOR SECTION
  --------------------
--####################################################################
--#####                     Param Check                          #####
--####################################################################

    INIPROC : process

    variable SERDES_MODE_STRING : string(1 to 100) := SERDES_MODE & PAD_STRING(1 to 100-SERDES_MODE'length);
begin
    SERDES_MODE_PAD <= SERDES_MODE_STRING(1 to SERDES_MODE_PAD'length);
-------------------------------------------------
------ DATA_RATE Check
-------------------------------------------------
    -- case DATA_RATE is
    if((DATA_RATE = "SDR") or (DATA_RATE = "sdr"))then
       DATA_RATE_BINARY <= SDR;
    elsif((DATA_RATE = "DDR") or (DATA_RATE = "ddr")) then
       DATA_RATE_BINARY <= DDR;
    else
       wait for 1 ps;
       GenericValueCheckMessage
        (  HeaderMsg  => " Attribute Syntax Error ",
           GenericName => " DATA_RATE ",
           EntityName => MODULE_NAME,
           GenericValue => DATA_RATE,
           Unit => "",
           ExpectedValueMsg => " The Legal values for this attribute are ",
           ExpectedGenericValue => " DDR or SDR.",
           TailMsg => "",
           MsgSeverity => Warning
       );
       data_rate_err_flag <= TRUE;
    end if;
    -- endcase;
-------------------------------------------------
------ IDELAY_VALUE Check
-------------------------------------------------
  -- case IDELAY_VALUE is
    if((IDELAY_VALUE >= 0) and (IDELAY_VALUE <= 255)) then
       IDELAY_VALUE_BINARY <= CONV_STD_LOGIC_VECTOR(IDELAY_VALUE, 8);
    else
       wait for 1 ps;
       GenericValueCheckMessage
        (  HeaderMsg  => " Attribute Syntax Error ",
           GenericName => " IDELAY_VALUE ",
           EntityName => MODULE_NAME,
           GenericValue => IDELAY_VALUE,
           Unit => "",
           ExpectedValueMsg => " The Legal values for this attribute are ",
           ExpectedGenericValue => " 0, 1, 2, ..., 253, 254, 255.",
           TailMsg => "",
           MsgSeverity => Warning
       );
       idelay_value_err_flag <= TRUE;
    end if;
  -- endcase;
-------------------------------------------------
------ MCB_ADDRESS  Check
-------------------------------------------------

    if((MCB_ADDRESS >= 0) and (MCB_ADDRESS <= 15)) then
       MCB_ADDRESS_BINARY <= CONV_STD_LOGIC_VECTOR(MCB_ADDRESS, 4);
    else
       wait for 1 ps;
       GenericValueCheckMessage
        (  HeaderMsg  => " Attribute Syntax Error ",
           GenericName => " MCB_ADDRESS ",
           EntityName => MODULE_NAME,
           GenericValue => MCB_ADDRESS,
           Unit => "",
           ExpectedValueMsg => " The Legal values for this attribute are ",
           ExpectedGenericValue => " 0, 1, 2, ..., 13, 14, 15.",
           TailMsg => "",
           MsgSeverity => Warning
       );
       mcb_address_err_flag <= TRUE;
    end if;

-------------------------------------------------
------ ODELAY_VALUE Check
-------------------------------------------------

    if((ODELAY_VALUE >= 0) and (ODELAY_VALUE <= 255)) then
       ODELAY_VALUE_BINARY <= CONV_STD_LOGIC_VECTOR(ODELAY_VALUE, 8);
    else
       wait for 1 ps;
       GenericValueCheckMessage
        (  HeaderMsg  => " Attribute Syntax Error ",
           GenericName => " ODELAY_VALUE ",
           EntityName => MODULE_NAME,
           GenericValue => ODELAY_VALUE,
           Unit => "",
           ExpectedValueMsg => " The Legal values for this attribute are ",
           ExpectedGenericValue => " 0, 1, 2, ..., 253, 254, 255.",
           TailMsg => "",
           MsgSeverity => Warning
       );
       odelay_value_err_flag <= TRUE;
    end if;

-------------------------------------------------
------ SERDES_MODE Check
-------------------------------------------------
    if    (SERDES_MODE_STRING(1 to SERDES_MODE_MAX) = NONE_STRING) then
       SERDES_MODE_BINARY <= NONE;
    elsif (SERDES_MODE_STRING(1 to SERDES_MODE_MAX) = MASTER_STRING) then
       SERDES_MODE_BINARY <= MASTER;
    elsif (SERDES_MODE_STRING(1 to SERDES_MODE_MAX) = SLAVE_STRING) then
       SERDES_MODE_BINARY <= SLAVE;
    else
       wait for 1 ps;
       GenericValueCheckMessage
        (  HeaderMsg  => " Attribute Syntax Error ",
           GenericName => " SERDES_MODE ",
           EntityName => MODULE_NAME,
           GenericValue => SERDES_MODE,
           Unit => "",
           ExpectedValueMsg => " The Legal values for this attribute are ",
           ExpectedGenericValue => " NONE, MASTER or SLAVE.",
           TailMsg => "",
           MsgSeverity => Warning 
       );
       serdes_mode_err_flag <= TRUE;
    end if;

-------------------------------------------------
------ SIM_TAPDELAY_VALUE Check
-------------------------------------------------
    if((SIM_TAPDELAY_VALUE >= 10) and (SIM_TAPDELAY_VALUE <= 90)) then
       SIM_TAPDELAY_VALUE_BINARY <= CONV_STD_LOGIC_VECTOR(SIM_TAPDELAY_VALUE, 7);
       Tstep <= SIM_TAPDELAY_VALUE * 1 ps;
    else
       wait for 1 ps;
       GenericValueCheckMessage
        (  HeaderMsg  => " Attribute Syntax Error ",
           GenericName => " SIM_TAPDELAY_VALUE ",
           EntityName => MODULE_NAME,
           GenericValue => SIM_TAPDELAY_VALUE,
           Unit => "",
           ExpectedValueMsg => " The Legal values for this attribute are ",
           ExpectedGenericValue => "between 10 and 90 ps inclusive.",
           TailMsg => "",
           MsgSeverity => Warning
       );
       sim_tap_delay_err_flag <= TRUE;
   end if;
   wait for 1 ps;
    if (serdes_mode_err_flag or odelay_value_err_flag or
        idelay_value_err_flag or sim_tap_delay_err_flag ) then
       wait for 1 ps;
       ASSERT FALSE REPORT "Attribute Errors detected, simulation cannot continue. Exiting ..." SEVERITY Error;
    end if;

    wait;
    end process INIPROC;

  prcs_init:process
  begin
      first_edge  <= '1' after 150 ps;
      if (GSR_INDELAY = '1') then
         wait on GSR_INDELAY;
      end if;
      mc_iob_mask(0) <= "00111111";
      mc_iob_mask(1) <= "10111111";
      mc_iob_mask(2) <= "01111111";
      mc_iob_mask(3) <= "11111111";
      mc_iob_mask(4) <= "11111111";
      mc_iob_mask(5) <= "11111111";
      mc_iob_mask(6) <= "11111111";
      mc_iob_mask(7) <= "11111111";
      mc_iob_mask(8) <= "01111111";
      mc_iob(0) <= "00000000";
      mc_iob(1) <= "00000000";
      mc_iob(2) <= "00000000";
      mc_iob(3) <= "00000000";
      mc_iob(4) <= "00000000";
      mc_iob(5) <= "00000000";
      mc_iob(6) <= "00000000";
      mc_iob(7) <= "00000000";
      mc_iob(8) <= "00000000";
     wait;

  end process prcs_init;

--####################################################################
--#####                       DDR doubler                        #####
--####################################################################
  prcs_ddr_dblr_clk0:process(IOCLK0_INDELAY)
  begin
     if(rising_edge(IOCLK0_INDELAY)) then
        if (first_edge = '1') then
           ioclk0_int <= '1', '0' after 100 ps;
        end if;
     end if;
  end process prcs_ddr_dblr_clk0;


  prcs_ddr_dblr_clk1:process(IOCLK1_INDELAY)
  begin
     if(rising_edge(IOCLK1_INDELAY) and (DATA_RATE_BINARY = DDR)) then -- DDR
        if (first_edge = '1') then
           ioclk1_int <= '1', '0' after 100 ps;
        end if;
     end if;
  end process prcs_ddr_dblr_clk1;

  ioclk_int <= ioclk0_int or ioclk1_int;

  prcs_delay1_out_dly:process(ioclk_int)
  begin
     if (rising_edge(ioclk_int)) then
        delay1_out_dly <= delay1_out;
     end if;
  end process prcs_delay1_out_dly;

--####################################################################
--#####               Delay Line Inputs                          #####
--####################################################################
  prcs_dly1_in:process
  begin
     if((T_INDELAY = '1' or output_delay_off = '1') and input_delay_off = '0') then
        if(pci_ce_reg = '0')     then delay1_in <= IDATAIN_INDELAY;  -- NORMAL
        elsif(DATAOUT_OUT = 'X') then delay1_in <= not IDATAIN_INDELAY;  -- PCI break X loop
        else                          delay1_in <= IDATAIN_INDELAY xor DATAOUT_OUT; -- PCI
        end if;  
     else
        if(output_delay_off = '1') then delay1_in <= '0'; 
        else delay1_in <= ODATAIN_INDELAY; 
        end if;
     end if;
     wait on IDATAIN_INDELAY, DATAOUT_OUT, T_INDELAY, ODATAIN_INDELAY, output_delay_off, input_delay_off;
   end process prcs_dly1_in;

  prcs_dly2_in:process
  begin
     if((T_INDELAY = '1' or output_delay_off = '1') and input_delay_off = '0') then
        if(pci_ce_reg = '0')      then delay2_in <= not IDATAIN_INDELAY;  -- NORMAL
        elsif(DATAOUT2_OUT = 'X') then delay2_in <= not IDATAIN_INDELAY;  -- PCI break X loop
        else                           delay2_in <= IDATAIN_INDELAY xor DATAOUT2_OUT; -- PCI
        end if;  
     else
        if(output_delay_off = '1') then delay2_in <= '0'; 
        else delay2_in <= not ODATAIN_INDELAY; 
        end if;
     end if;
     wait on IDATAIN_INDELAY, DATAOUT2_OUT, T_INDELAY, ODATAIN_INDELAY, output_delay_off, input_delay_off;
  end process prcs_dly2_in;

--####################################################################
--#####                         Delay Lines                      #####
--####################################################################
  prcs_delay_line1:process
  begin
     if(GSR_INDELAY = '1')then 
         delay1_reached_1 <= '0';
         delay1_reached_2 <= '0';
         delay1_working_1 <= '0';
         delay1_working_2 <= '0';
         delay1_ignore  <= '0';
--     elsif(rising_edge(delay1_in)) then
     elsif(delay1_in'event and delay1_in = '1') then
        if(delay1_working = '0' or delay1_reached = '1') then
           if(delay1_working_1 = '0') then
               delay1_working_1 <= '1';
           else
               delay1_working_2 <= '1';
           end if;
           if (input_delay_off = '0' and (T_INDELAY = '1' or output_delay_off = '1'))then -- input
              if (IDATAIN_INDELAY = '1') then -- positive edge
                 if (delay1_reached_1 = '0') then
                    delay1_reached_1 <= '1' after (Tstep * CONV_INTEGER(delay_val_pe_1));
                 else
                    delay1_reached_2 <= '1' after (Tstep * CONV_INTEGER(delay_val_pe_1));
                 end if;
              else -- negative edge
                 if (delay1_reached_1 = '0') then
                    delay1_reached_1 <= '1' after (Tstep * CONV_INTEGER(delay_val_ne_1));
                 else
                    delay1_reached_2 <= '1' after (Tstep * CONV_INTEGER(delay_val_ne_1));
                 end if;
              end if;
           else -- output
              if (ODATAIN_INDELAY = '1') then -- positive edge
                 if (delay1_reached_1 = '0') then
                    delay1_reached_1 <= '1' after (Tstep * CONV_INTEGER(delay_val_pe_1));
                 else
                    delay1_reached_2 <= '1' after (Tstep * CONV_INTEGER(delay_val_pe_1));
                 end if;
              else -- negative edge
                 if (delay1_reached_1 = '0') then
                    delay1_reached_1 <= '1' after (Tstep * CONV_INTEGER(delay_val_ne_1));
                 else
                    delay1_reached_2 <= '1' after (Tstep * CONV_INTEGER(delay_val_ne_1));
                 end if;
              end if;
           end if;
        else
           delay1_ignore <= '1';
        end if;
     end if;
     if (delay1_reached = '1') then
        delay1_ignore    <= '0' after 1 ps;
     end if;
     if (delay1_reached_1 = '1') then
        delay1_working_1 <= '0' after 1 ps;
        delay1_reached_1 <= '0' after 1 ps;
     end if;
     if (delay1_reached_2 = '1') then
        delay1_working_2 <= '0' after 1 ps;
        delay1_reached_2 <= '0' after 1 ps;
     end if;
     wait on delay1_in, delay1_reached, GSR_INDELAY;
  end process prcs_delay_line1;
    
  prcs_delay_line2:process
  begin
     if(GSR_INDELAY = '1')then 
         delay2_reached_1 <= '0';
         delay2_reached_2 <= '0';
         delay2_working_1 <= '0';
         delay2_working_2 <= '0';
         delay2_ignore  <= '0';
--     elsif(rising_edge(delay2_in)) then
     elsif(delay2_in'event and delay2_in = '1') then
        if(delay2_working = '0' or delay2_reached = '1') then
           if(delay2_working_1 = '0') then
              delay2_working_1 <= '1';
           else
              delay2_working_2 <= '1';
           end if;
           if (input_delay_off = '0' and (T_INDELAY = '1' or output_delay_off = '1'))then -- input
              if (IDATAIN_INDELAY = '1') then -- pos edge
                 if (delay2_reached_1 = '0') then
                    delay2_reached_1 <= '1' after (Tstep * CONV_INTEGER(delay_val_pe_2));
                 else
                    delay2_reached_2 <= '1' after (Tstep * CONV_INTEGER(delay_val_pe_2));
                 end if;
              else -- neg edge
                 if (delay2_reached_1 = '0') then
                    delay2_reached_1 <= '1' after (Tstep * CONV_INTEGER(delay_val_ne_2));
                 else
                    delay2_reached_2 <= '1' after (Tstep * CONV_INTEGER(delay_val_ne_2));
                 end if;
              end if;
           else -- output
              if (ODATAIN_INDELAY = '1') then -- pos edge
                 if (delay2_reached_1 = '0') then
                    delay2_reached_1 <= '1' after (Tstep * CONV_INTEGER(delay_val_pe_2));
                 else
                    delay2_reached_2 <= '1' after (Tstep * CONV_INTEGER(delay_val_pe_2));
                 end if;
              else -- neg edge
                 if (delay2_reached_1 = '0') then
                    delay2_reached_1 <= '1' after (Tstep * CONV_INTEGER(delay_val_ne_2));
                 else
                    delay2_reached_2 <= '1' after (Tstep * CONV_INTEGER(delay_val_ne_2));
                 end if;
              end if;
           end if;
        else
           delay2_ignore <= '1';
        end if;
     end if;
     if (delay2_reached = '1') then
        delay2_ignore  <= '0' after 1 ps;
     end if;
     if (delay2_reached_1 = '1') then
        delay2_working_1 <= '0' after 1 ps;
        delay2_reached_1 <= '0' after 1 ps;
     end if;
     if (delay2_reached_2 = '1') then
        delay2_working_2 <= '0' after 1 ps;
        delay2_reached_2 <= '0' after 1 ps;
     end if;
     wait on delay2_in, delay2_reached, GSR_INDELAY;
  end process prcs_delay_line2;
    
--####################################################################
--#####                    Output FF                             #####
--####################################################################
  prcs_delay_out:process
  begin
     if((pci_ce_reg = '0') or ((T_INDELAY = '0') and (output_delay_off = '0')) or (input_delay_off = '1')) then -- NORMAL in or output
        if ((GSR_INDELAY  = '1') or (first_edge = '0') or ((delay1_working  = '0') and (delay2_working  = '0'))) then
           delay1_out <= delay1_in;
        elsif ((rising_edge(delay1_reached) and (delay1_ignore = '0')) or
               (rising_edge(delay1_ignore) and (delay1_out = '0'))) then
           delay1_out <= '1';
        elsif ((rising_edge(delay2_reached) and (delay2_ignore = '0')) or
               (rising_edge(delay2_ignore) and (delay1_out = '1'))) then
           delay1_out <= '0';
        end if;
        delay2_out <= '0';
     else -- PCI in
        if ((GSR_INDELAY  = '1') or (delay1_reached  = '1') or (first_edge = '0')) then
           delay1_out <= IDATAIN_INDELAY;
        end if;
        if ((GSR_INDELAY  = '1') or (delay2_reached  = '1') or (first_edge = '0')) then
           delay2_out <= IDATAIN_INDELAY;
        end if;
     end if;
     wait on delay1_reached, delay2_reached, delay1_working, delay2_working, delay1_ignore, delay2_ignore, T_INDELAY, GSR_INDELAY, first_edge, IDATAIN_INDELAY;
  end process prcs_delay_out;
--####################################################################
--#####                    TOUT delay                            #####
--####################################################################
  --prcs_tout_out_int:process(T_INDELAY)
  prcs_tout_out_int:process
  begin
     if (T_INDELAY = '0') then
        tout_out_int <= '0' after Tstep;
     else
        tout_out_int <= '1' after Tstep;
     end if;
     wait on T_INDELAY;
  end process prcs_tout_out_int;
--####################################################################
--#####                    Delay Preset Values                   #####
--####################################################################
  prcs_delay_val_pe_clk:process(ioclk_int, delay1_in)
  begin
     if (sync_to_data_reg = '1') then
        delay_val_pe_clk <= delay1_in;
     else
        delay_val_pe_clk <= ioclk_int;
     end if;
  end process prcs_delay_val_pe_clk;

  prcs_delay_val_ne_clk:process(ioclk_int, delay2_in)
  begin
     if (sync_to_data_reg = '1') then
        delay_val_ne_clk <= delay2_in;
     else
        delay_val_ne_clk <= ioclk_int;
     end if;
  end process prcs_delay_val_ne_clk;

  prcs_busy_out_dly:process(busy_out_pe_dly, busy_out_ne_dly)
  begin
        busy_out_dly <= busy_out_pe_dly or busy_out_ne_dly;
  end process prcs_busy_out_dly;

  prcs_busy_out_pe_dly:process(delay_val_pe_clk, rst_sig, busy_out_int, calibrate_done)
  begin
     if ((rst_sig = '1') or 
         (((busy_out_int = '1') and (busy_out_pe_one_shot = '0')) or 
          (cal_count < "1011"))) then
        busy_out_pe_dly <= '1';
        busy_out_pe_dly1 <= '1';
        busy_out_pe_one_shot <= '1';
     elsif (falling_edge(calibrate_done)) then
           busy_out_pe_dly <= '0';
           busy_out_pe_dly1 <= '0';
     elsif (rising_edge(delay_val_pe_clk)) then
--        if (busy_out_dly = '1') then
        if ((busy_out_dly = '1') and (busy_out_int = '0')) then -- CR652228
           busy_out_pe_dly <= busy_out_pe_dly1;
           busy_out_pe_dly1 <= '0';
        end if;
        if ((busy_out_int = '0') and (busy_out_dly = '0')) then
           busy_out_pe_one_shot <= '0';
        end if;
     end if;
  end process prcs_busy_out_pe_dly;

  prcs_busy_out_ne_dly:process(delay_val_ne_clk, rst_sig, busy_out_int, calibrate_done)
  begin
     if ((rst_sig = '1') or 
         (((busy_out_int = '1') and (busy_out_ne_one_shot = '0')) or 
          (cal_count < "1011"))) then
        busy_out_ne_dly <= '1';
        busy_out_ne_dly1 <= '1';
        busy_out_ne_one_shot <= '1';
     elsif (falling_edge(calibrate_done)) then
           busy_out_ne_dly <= '0';
           busy_out_ne_dly1 <= '0';
     elsif (rising_edge(delay_val_ne_clk)) then
--        if (busy_out_dly = '1') then
        if ((busy_out_dly = '1') and (busy_out_int = '0')) then -- CR652228
           busy_out_ne_dly <= busy_out_ne_dly1;
           busy_out_ne_dly1 <= '0';
        end if;
        if ((busy_out_int = '0') and (busy_out_dly = '0')) then
           busy_out_ne_one_shot <= '0';
        end if;
     end if;
  end process prcs_busy_out_ne_dly;

  prcs_idelay_val_pe_reg:process(delay_val_pe_clk, rst_sig)
  begin
     if (rising_edge(delay_val_pe_clk) or falling_edge(rst_sig)) then
        if (SERDES_MODE_BINARY = SLAVE) then
           idelay_val_pe_reg <= idelay_val_pe_s_reg;
        else
           idelay_val_pe_reg <= idelay_val_pe_m_reg;
        end if;
     end if;
  end process prcs_idelay_val_pe_reg;

  prcs_idelay_val_ne_reg:process(delay_val_ne_clk, rst_sig)
  begin
     if (rising_edge(delay_val_ne_clk) or falling_edge(rst_sig)) then
        if (SERDES_MODE_BINARY = SLAVE) then
           idelay_val_ne_reg <= idelay_val_ne_s_reg;
        else
           idelay_val_ne_reg <= idelay_val_ne_m_reg;
        end if;
     end if;
  end process prcs_idelay_val_ne_reg;

  prcs_delay_pe_preset:process
  begin
     if (rising_edge(delay_val_pe_clk) or rising_edge(rst_sig) or falling_edge(rst_sig) or first_time_pe = '1' or rising_edge(T_INDELAY) or falling_edge(T_INDELAY)) then
        if (first_time_pe = '1') then
           first_time_pe <= '0' after 100 ps;
        end if;
        if ((T_INDELAY = '0' and output_delay_off = '0') or input_delay_off = '1') then -- OUTPUT
           delay_val_pe_1 <= odelay_val_pe_reg;
           delay_val_pe_2 <= odelay_val_pe_reg;
        -- input delays
        elsif ((IDELAY_TYPE_BINARY = FIXED) or (IDELAY_TYPE_BINARY = DEFAULT)) then
           if (pci_ce_reg = '1') then -- PCI
              delay_val_pe_1 <= IDELAY_VALUE_BINARY(7 downto 0);
              delay_val_pe_2 <= IDELAY2_VALUE_BINARY(7 downto 0);
           else -- NORMAL
              delay_val_pe_1 <= IDELAY_VALUE_BINARY(7 downto 0);
              delay_val_pe_2 <= IDELAY_VALUE_BINARY(7 downto 0);
           end if;
        elsif (IDELAY_TYPE_BINARY = VAR) then
           if ((rst_sig = '1') or falling_edge(rst_sig)) then
              if (rst_to_half_reg = '1') then
                 delay_val_pe_1 <= half_max;
                 delay_val_pe_2 <= half_max;
              else
                 delay_val_pe_1 <= "00000000";
                 delay_val_pe_2 <= "00000000";
              end if;
           else
              if (pci_ce_reg = '1') then -- PCI
                 delay_val_pe_1 <= idelay_val_pe_reg;
                 delay_val_pe_2 <= idelay_val_ne_reg;
              else -- NORMAL
                 delay_val_pe_1 <= idelay_val_pe_reg;
                 delay_val_pe_2 <= idelay_val_ne_reg;
              end if;  
           end if;  
        elsif (IDELAY_TYPE_BINARY = DIFF_PHASE_DETECTOR) then
           delay_val_pe_1 <= idelay_val_pe_reg;
           delay_val_pe_2 <= idelay_val_ne_reg;
        else
           delay_val_pe_1 <= IDELAY_VALUE_BINARY(7 downto 0);
           delay_val_pe_2 <= IDELAY_VALUE_BINARY(7 downto 0);
        end if;
     end if;
     wait on delay_val_pe_clk, rst_sig, T_INDELAY;
  end process prcs_delay_pe_preset;

  prcs_delay_ne_preset:process
  begin
     if (rising_edge(delay_val_ne_clk) or rising_edge(rst_sig) or falling_edge(rst_sig) or first_time_ne = '1' or rising_edge(T_INDELAY) or falling_edge(T_INDELAY)) then
        if (first_time_ne = '1') then
           first_time_ne <= '0' after 100 ps;
        end if;
        if ((T_INDELAY = '0' and output_delay_off = '0') or input_delay_off = '1') then -- OUTPUT
           delay_val_ne_1 <= odelay_val_ne_reg;
           delay_val_ne_2 <= odelay_val_ne_reg;
        -- input delays
        elsif ((IDELAY_TYPE_BINARY = FIXED) or (IDELAY_TYPE_BINARY = DEFAULT)) then
           if (pci_ce_reg = '1') then -- PCI
              delay_val_ne_1 <= IDELAY_VALUE_BINARY(7 downto 0);
              delay_val_ne_2 <= IDELAY2_VALUE_BINARY(7 downto 0);
           else -- NORMAL
              delay_val_ne_1 <= IDELAY_VALUE_BINARY(7 downto 0);
              delay_val_ne_2 <= IDELAY_VALUE_BINARY(7 downto 0);
           end if;
        elsif (IDELAY_TYPE_BINARY = VAR) then
           if ((rst_sig = '1') or falling_edge(rst_sig)) then
              if (rst_to_half_reg = '1') then
                 delay_val_ne_1 <= half_max;
                 delay_val_ne_2 <= half_max;
              else
                 delay_val_ne_1 <= "00000000";
                 delay_val_ne_2 <= "00000000";
              end if;
           else
              if (pci_ce_reg = '1') then -- PCI
                 delay_val_ne_1 <= idelay_val_pe_reg;
                 delay_val_ne_2 <= idelay_val_ne_reg;
              else -- NORMAL
                 delay_val_ne_1 <= idelay_val_pe_reg;
                 delay_val_ne_2 <= idelay_val_ne_reg;
              end if;  
           end if;  
        elsif (IDELAY_TYPE_BINARY = DIFF_PHASE_DETECTOR) then
           delay_val_ne_1 <= idelay_val_pe_reg;
           delay_val_ne_2 <= idelay_val_ne_reg;
        else
           delay_val_ne_1 <= IDELAY_VALUE_BINARY(7 downto 0);
           delay_val_ne_2 <= IDELAY_VALUE_BINARY(7 downto 0);
        end if;
     end if;
     wait on delay_val_ne_clk, rst_sig, T_INDELAY;
  end process prcs_delay_ne_preset;

--####################################################################
--#####                Max delay CAL                             #####
--####################################################################
  prcs_cal_delay:process(CLK_INDELAY, GSR_INDELAY)
  begin
     if (GSR_INDELAY = '1') then
        cal_count <= "1011";
        busy_out_int <= '1'; -- reset
     elsif (rising_edge(CLK_INDELAY)) then
        if ((cal_sig = '1') and (busy_out_int = '0')) then
           cal_count <= "0000";
           busy_out_int <= '1'; -- begin cal
--        elsif ((ce_sig = '1') and (busy_out_int = '0')) then
        elsif (ce_sig = '1') then -- CR652228
           cal_count <= "1011";
           busy_out_int <= '1'; -- begin inc, busy high 1 clock after CE low
        elsif ((busy_out_int = '1') and (cal_count < "1011")) then
           cal_count <= cal_count + '1';
           busy_out_int <= '1'; -- continue
        else
           busy_out_int <= '0'; -- done
        end if;
     end if;
  end process prcs_cal_delay;
 
  prcs_cal_done:process(ioclk_int)
  begin
     if (rising_edge(ioclk_int)) then
        if ((calibrate = '0') and (calibrate_done = '0') and (busy_out_int = '1') and (cal_count = "0100") ) then
           calibrate <= '1';
        elsif (calibrate = '1') then
           calibrate <= '0';
        end if;
     end if;
  end process prcs_cal_done;

  prcs_max_delay:process
  begin
     if ((GSR_INDELAY = '1') or ((cal_sig = '1') and (busy_out_int = '0'))) then
        cal_delay <= "00000000";
        calibrate_done <= '0';
     elsif ((calibrate = '1') and (cal_delay /= "11111111")) then
        wait for Tstep;
        if (calibrate = '1') then
           cal_delay <= cal_delay + "00000001";
        else 
           if ((pci_ce_reg = '1') and (DATA_RATE_BINARY = SDR)) then
              cal_delay <= '0' & cal_delay(7 downto 1);
           end if;
           calibrate_done <= '1';
        end if;
     elsif ((calibrate = '1') and (cal_delay = "11111111")) then
        calibrate_done <= '1';
     else
        wait for Tstep;
        calibrate_done <= '0';
     end if;
     wait on GSR_INDELAY, cal_sig, calibrate, cal_delay, busy_out_int;
  end process prcs_max_delay;

-----------------------------------------------------------------------------
----------------- Interface State Machine------------------------------------
-----------------------------------------------------------------------------
   prcs_if_state:process(CLK_INDELAY)
      begin -- process
      if(rising_edge(CLK_INDELAY)) then -- posedge clk
         if (GSR_INDELAY = '1' or rst_sig = '1') then -- reset
            if_state  <= IDLE;
            shift_out <= "11111111";
            addr_reg  <= "10000000";
            data_reg  <= "00000000";
            mem_updated <= '1';
            cal_reg <= '0';
            snapback_reg <= '0';
            half_reg  <= '0';
            inc_reg <= '0';
            ce_reg <= '0';
            rst_reg <= '0';
         else 
            if (cal_reg = '1') then  cal_reg <= '0'; end if;
            if (snapback_reg = '1') then  snapback_reg <= '0'; end if;
            if (half_reg = '1') then  half_reg  <= '0'; end if;
            if (inc_reg = '1') then  inc_reg <= '0'; end if;
            if (ce_reg = '1') then  ce_reg <= '0'; end if;
            if (if_state = IDLE) then
               if ((cs_sig = '1') and (ADD_INDELAY = '1')) then
                  if_state <= ADDR_ACTIVE;
                  addr_reg <= SDI_INDELAY & addr_reg(7 downto 1);
                  shift_out <= '0' & shift_out(7 downto 1);
               elsif ((cs_sig = '1') and (ADD_INDELAY = '0')) then
                  if_state <= DATA_ACTIVE;
                  data_reg <= SDI_INDELAY & data_reg(7 downto 1);
                  shift_out <= '0' & shift_out(7 downto 1);
               else
                  if_state <= IDLE;
                  if (addr_reg(7) = '0') then
                     read_from_ioi(addr_reg, shift_out, cal_reg, snapback_reg, half_reg, inc_reg, ce_reg, rst_reg, SERDES_MODE_BINARY, max_delay, half_max, idelay_val_pe_m_reg, idelay_val_pe_s_reg, idelay_val_ne_m_reg, idelay_val_ne_s_reg, odelay_val_pe_reg, odelay_val_ne_reg, direct_in_reg, force_rx_reg, force_dly_dir_reg, event_sel_m_reg, plus1_s_reg, lumped_delay_select_reg, lumped_delay_reg, sync_to_data_reg, sat_at_max_reg, rst_to_half_reg);
                  else
                     shift_out <= mc_iob(conv_integer(addr_reg(3 downto 0)));
                  end if;
               end if;
            elsif (if_state = ADDR_ACTIVE) then
               if ((cs_sig = '1') and (ADD_INDELAY = '1')) then
                  if_state <= ADDR_ACTIVE;
                  addr_reg <= SDI_INDELAY & addr_reg(7 downto 1);
                  shift_out <= '0' & shift_out(7 downto 1);
               elsif ((cs_sig = '0') and (ADD_INDELAY = '0')) then
                  if_state <= IDLE;
                  if (addr_reg(7) = '0') then
                     read_from_ioi(addr_reg, shift_out, cal_reg, snapback_reg, half_reg, inc_reg, ce_reg, rst_reg, SERDES_MODE_BINARY, max_delay, half_max, idelay_val_pe_m_reg, idelay_val_pe_s_reg, idelay_val_ne_m_reg, idelay_val_ne_s_reg, odelay_val_pe_reg, odelay_val_ne_reg, direct_in_reg, force_rx_reg, force_dly_dir_reg, event_sel_m_reg, plus1_s_reg, lumped_delay_select_reg, lumped_delay_reg, sync_to_data_reg, sat_at_max_reg, rst_to_half_reg);
                  else
                     shift_out <= mc_iob(conv_integer(addr_reg(3 downto 0)));
                  end if;
               else
                 if_state <= IDLE;
                 assert false report "State: ADDR_ACTIVE - ADD and CS must both be low for one clk to advance" severity warning;
               end if;
            elsif (if_state = DATA_ACTIVE) then
               if ((cs_sig = '1') and (ADD_INDELAY = '0')) then
                  if_state <= DATA_ACTIVE;
                  data_reg <= SDI_INDELAY & data_reg(7 downto 1);
                  shift_out <= '0' & shift_out(7 downto 1);
               elsif ((cs_sig = '0') and (ADD_INDELAY = '0')) then
                  if_state <= IDLE;
                  if (addr_reg(7) = '0') then
                     if (MEMUPDATE_INDELAY = '1') then
                        write_to_ioi(addr_reg, data_reg, shift_out, cal_reg, snapback_reg, half_reg, inc_reg, ce_reg, rst_reg, SERDES_MODE_BINARY, max_delay, half_max, idelay_val_pe_m_reg, idelay_val_pe_s_reg, idelay_val_ne_m_reg, idelay_val_ne_s_reg, odelay_val_pe_reg, odelay_val_ne_reg, direct_in_reg, force_rx_reg, force_dly_dir_reg, event_sel_m_reg, plus1_s_reg, lumped_delay_select_reg, lumped_delay_reg, sync_to_data_reg, sat_at_max_reg, rst_to_half_reg);
                     else
                        mem_updated <= '0';
                     end if;
                  else
                     if (MEMUPDATE_INDELAY = '1') then
                        mc_iob(conv_integer(addr_reg(3 downto 0))) <= data_reg and mc_iob_mask(conv_integer(addr_reg(3 downto 0)));
                        shift_out <= data_reg and mc_iob_mask(conv_integer(addr_reg(3 downto 0)));
                     else
                        mem_updated <= '0';
                     end if;
                  end if;
               else 
                  if_state <= IDLE;
                  assert false report "State: DATA_ACTIVE - Illegal next state, ADD went high" severity warning;
               end if;
            else
               if_state <= IDLE;
               assert false report "Illegal State" severity warning;
            end if;
         end if; -- reset

         if ((mem_updated = '0') and (MEMUPDATE_INDELAY = '1')) then
            if (addr_reg(7) = '0') then
               write_to_ioi(addr_reg, data_reg, shift_out, cal_reg, snapback_reg, half_reg, inc_reg, ce_reg, rst_reg, SERDES_MODE_BINARY, max_delay, half_max, idelay_val_pe_m_reg, idelay_val_pe_s_reg, idelay_val_ne_m_reg, idelay_val_ne_s_reg, odelay_val_pe_reg, odelay_val_ne_reg, direct_in_reg, force_rx_reg, force_dly_dir_reg, event_sel_m_reg, plus1_s_reg, lumped_delay_select_reg, lumped_delay_reg, sync_to_data_reg, sat_at_max_reg, rst_to_half_reg);
               mem_updated <= '1';
            else
               mc_iob(conv_integer(addr_reg(3 downto 0))) <= data_reg and mc_iob_mask(conv_integer(addr_reg(3 downto 0)));
               mem_updated <= '1';
            end if;
         end if;
    
--####################################################################
--#####          Delay Value Registers (INC/DEC)                 #####
--####################################################################
         inc_dec( rst_sig, GSR_INDELAY, CLK_INDELAY, busy_out_dly, ce_sig, pci_ce_reg, inc_sig, IDELAY_TYPE_BINARY, SERDES_MODE_BINARY, sat_at_max_reg, max_delay, half_max, rst_to_half_reg, ignore_rst, idelay_val_pe_m_reg, idelay_val_pe_s_reg, idelay_val_ne_m_reg, idelay_val_ne_s_reg);

         if (calibrate_done = '1') then
            max_delay <= cal_delay;
            half_max  <= '0' & cal_delay(7 downto 1);
         end if;

     end if; -- posedge clk
   end process prcs_if_state;

  prcs_delay1_out_sig:process(delay1_out_dly, delay1_out)
     begin
     if ((IDELAY_TYPE_BINARY = DIFF_PHASE_DETECTOR) and
         (SERDES_MODE_BINARY = SLAVE) and
         (delay_val_pe_1 < half_max)) then
        delay1_out_sig <= delay1_out_dly;
     else
        delay1_out_sig <= delay1_out;
     end if;
  end process prcs_delay1_out_sig;
--####################################################################
--#####                      OUTPUT MUXES                        #####
--####################################################################
-- input delay paths
   DATAOUT_OUT <= delay1_out_sig;
   DATAOUT2_OUT <= delay1_out_sig when (pci_ce_reg = '0') else
                        delay2_out;

-- output delay paths
  prcs_dout:process(output_delay_off, input_delay_off, T_INDELAY, delay1_in)
  begin
     if (output_delay_off = '0' and (T_INDELAY = '0' or input_delay_off = '1')) then
        DOUT_OUT <= delay1_in after Tstep;
     else
        DOUT_OUT <= '0' after Tstep;
     end if;
  end process prcs_dout;

  prcs_tout:process(output_delay_off, input_delay_off, tout_out_int, T_INDELAY)
  begin
     if (output_delay_off = '0' and (T_INDELAY = '0' or input_delay_off = '1')) then
        TOUT_OUT <= tout_out_int;
     else
        TOUT_OUT <= T_INDELAY;
     end if;
  end process prcs_tout;

  DQSOUTN_OUT <= not delay1_out;
  DQSOUTP_OUT <= delay1_out;

  prcs_cs_sig:process(AUXADDR_INDELAY, BKST_INDELAY, CS_INDELAY)
  begin
     if ((CS_INDELAY = '1') and 
         ((AUXADDR_INDELAY = (MCB_ADDRESS_BINARY & SERDES_MODE_BINARY)) or 
         (BKST_INDELAY = '1'))) then
       cs_sig <= '1';
     else
       cs_sig <= '0';
     end if;
  end process prcs_cs_sig;

  prcs_auxsdo:process(shift_out(0), cs_sig, AUXSDOIN_INDELAY)
  begin
     if (cs_sig = '1') then
        AUXSDO_OUT <= shift_out(0);
     else
        AUXSDO_OUT <= AUXSDOIN_INDELAY;
     end if;
  end process prcs_auxsdo;

  SDO_OUT <= shift_out(0);
    AUXSDO <= AUXSDO_OUTDELAY;
    DATAOUT <= DATAOUT_OUTDELAY;
    DATAOUT2 <= DATAOUT2_OUTDELAY;
    DOUT <= DOUT_OUTDELAY;
    DQSOUTN <= DQSOUTN_OUTDELAY;
    DQSOUTP <= DQSOUTP_OUTDELAY;
    SDO <= SDO_OUTDELAY;
    TOUT <= TOUT_OUTDELAY;
end IODRP2_MCB_V;
