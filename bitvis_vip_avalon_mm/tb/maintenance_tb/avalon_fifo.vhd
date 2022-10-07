--Legal Notice: (C)2014 Altera Corporation. All rights reserved.  Your
--use of Altera Corporation's design tools, logic functions and other
--software and tools, and its AMPP partner logic functions, and any
--output files any of the foregoing (including device programming or
--simulation files), and any associated documentation or information are
--expressly subject to the terms and conditions of the Altera Program
--License Subscription Agreement or other applicable license agreement,
--including, without limitation, that your use is for the sole purpose
--of programming logic devices manufactured by Altera and sold by Altera
--or its authorized distributors.  Please refer to the applicable
--agreement for further details.

-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library altera_mf;
use altera_mf.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library lpm;
use lpm.all;

entity avalon_fifo_single_clock_fifo is
  port(
    -- inputs:
    signal aclr  : IN  STD_LOGIC;
    signal clock : IN  STD_LOGIC;
    signal data  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal rdreq : IN  STD_LOGIC;
    signal wrreq : IN  STD_LOGIC;
    -- outputs:
    signal empty : OUT STD_LOGIC;
    signal full  : OUT STD_LOGIC;
    signal q     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal usedw : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
  );
end entity avalon_fifo_single_clock_fifo;

architecture europa of avalon_fifo_single_clock_fifo is
  component scfifo is
    GENERIC(
      add_ram_output_register : STRING;
      intended_device_family  : STRING;
      lpm_numwords            : NATURAL;
      lpm_showahead           : STRING;
      lpm_type                : STRING;
      lpm_width               : NATURAL;
      lpm_widthu              : NATURAL;
      overflow_checking       : STRING;
      underflow_checking      : STRING;
      use_eab                 : STRING
    );
    PORT(
      signal full  : OUT STD_LOGIC;
      signal q     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      signal usedw : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      signal empty : OUT STD_LOGIC;
      signal aclr  : IN  STD_LOGIC;
      signal rdreq : IN  STD_LOGIC;
      signal data  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
      signal clock : IN  STD_LOGIC;
      signal wrreq : IN  STD_LOGIC
    );
  end component scfifo;
  signal internal_empty1 : STD_LOGIC;
  signal internal_full1  : STD_LOGIC;
  signal internal_q1     : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal internal_usedw  : STD_LOGIC_VECTOR(3 DOWNTO 0);

begin

  single_clock_fifo : scfifo
    generic map(
      add_ram_output_register => "OFF",
      intended_device_family  => "CYCLONEIVGX",
      lpm_numwords            => 16,
      lpm_showahead           => "ON",
      lpm_type                => "scfifo",
      lpm_width               => 32,
      lpm_widthu              => 4,
      overflow_checking       => "ON",
      underflow_checking      => "ON",
      use_eab                 => "ON"
    )
    port map(
      aclr  => aclr,
      clock => clock,
      data  => data,
      empty => internal_empty1,
      full  => internal_full1,
      q     => internal_q1,
      rdreq => rdreq,
      usedw => internal_usedw,
      wrreq => wrreq
    );

  --vhdl renameroo for output signals
  empty <= internal_empty1;
  --vhdl renameroo for output signals
  full  <= internal_full1;
  --vhdl renameroo for output signals
  q     <= internal_q1;
  --vhdl renameroo for output signals
  usedw <= internal_usedw;

end europa;

-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity avalon_fifo_scfifo_with_controls is
  port(
    -- inputs:
    signal clock                         : IN  STD_LOGIC;
    signal data                          : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal rdreq                         : IN  STD_LOGIC;
    signal reset_n                       : IN  STD_LOGIC;
    signal wrclk_control_slave_address   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal wrclk_control_slave_read      : IN  STD_LOGIC;
    signal wrclk_control_slave_write     : IN  STD_LOGIC;
    signal wrclk_control_slave_writedata : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal wrreq                         : IN  STD_LOGIC;
    -- outputs:
    signal empty                         : OUT STD_LOGIC;
    signal full                          : OUT STD_LOGIC;
    signal q                             : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal wrclk_control_slave_irq       : OUT STD_LOGIC;
    signal wrclk_control_slave_readdata  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
end entity avalon_fifo_scfifo_with_controls;

architecture europa of avalon_fifo_scfifo_with_controls is
  component avalon_fifo_single_clock_fifo is
    port(
      -- inputs:
      signal aclr  : IN  STD_LOGIC;
      signal clock : IN  STD_LOGIC;
      signal data  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
      signal rdreq : IN  STD_LOGIC;
      signal wrreq : IN  STD_LOGIC;
      -- outputs:
      signal empty : OUT STD_LOGIC;
      signal full  : OUT STD_LOGIC;
      signal q     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      signal usedw : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
  end component avalon_fifo_single_clock_fifo;

  signal internal_empty                                     : STD_LOGIC;
  signal internal_full                                      : STD_LOGIC;
  signal internal_q                                         : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal level                                              : STD_LOGIC_VECTOR(4 DOWNTO 0);
  signal module_input                                       : STD_LOGIC;
  signal overflow                                           : STD_LOGIC;
  signal underflow                                          : STD_LOGIC;
  signal usedw                                              : STD_LOGIC_VECTOR(3 DOWNTO 0);
  signal wrclk_control_slave_almostempty_n_reg              : STD_LOGIC;
  signal wrclk_control_slave_almostempty_pulse              : STD_LOGIC;
  signal wrclk_control_slave_almostempty_signal             : STD_LOGIC;
  signal wrclk_control_slave_almostempty_threshold_register : STD_LOGIC_VECTOR(4 DOWNTO 0);
  signal wrclk_control_slave_almostfull_n_reg               : STD_LOGIC;
  signal wrclk_control_slave_almostfull_pulse               : STD_LOGIC;
  signal wrclk_control_slave_almostfull_signal              : STD_LOGIC;
  signal wrclk_control_slave_almostfull_threshold_register  : STD_LOGIC_VECTOR(4 DOWNTO 0);
  signal wrclk_control_slave_empty_n_reg                    : STD_LOGIC;
  signal wrclk_control_slave_empty_pulse                    : STD_LOGIC;
  signal wrclk_control_slave_empty_signal                   : STD_LOGIC;
  signal wrclk_control_slave_event_almostempty_q            : STD_LOGIC;
  signal wrclk_control_slave_event_almostempty_signal       : STD_LOGIC;
  signal wrclk_control_slave_event_almostfull_q             : STD_LOGIC;
  signal wrclk_control_slave_event_almostfull_signal        : STD_LOGIC;
  signal wrclk_control_slave_event_empty_q                  : STD_LOGIC;
  signal wrclk_control_slave_event_empty_signal             : STD_LOGIC;
  signal wrclk_control_slave_event_full_q                   : STD_LOGIC;
  signal wrclk_control_slave_event_full_signal              : STD_LOGIC;
  signal wrclk_control_slave_event_overflow_q               : STD_LOGIC;
  signal wrclk_control_slave_event_overflow_signal          : STD_LOGIC;
  signal wrclk_control_slave_event_register                 : STD_LOGIC_VECTOR(5 DOWNTO 0);
  signal wrclk_control_slave_event_underflow_q              : STD_LOGIC;
  signal wrclk_control_slave_event_underflow_signal         : STD_LOGIC;
  signal wrclk_control_slave_full_n_reg                     : STD_LOGIC;
  signal wrclk_control_slave_full_pulse                     : STD_LOGIC;
  signal wrclk_control_slave_full_signal                    : STD_LOGIC;
  signal wrclk_control_slave_ienable_register               : STD_LOGIC_VECTOR(5 DOWNTO 0);
  signal wrclk_control_slave_level_register                 : STD_LOGIC_VECTOR(4 DOWNTO 0);
  signal wrclk_control_slave_read_mux                       : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal wrclk_control_slave_status_almostempty_q           : STD_LOGIC;
  signal wrclk_control_slave_status_almostempty_signal      : STD_LOGIC;
  signal wrclk_control_slave_status_almostfull_q            : STD_LOGIC;
  signal wrclk_control_slave_status_almostfull_signal       : STD_LOGIC;
  signal wrclk_control_slave_status_empty_q                 : STD_LOGIC;
  signal wrclk_control_slave_status_empty_signal            : STD_LOGIC;
  signal wrclk_control_slave_status_full_q                  : STD_LOGIC;
  signal wrclk_control_slave_status_full_signal             : STD_LOGIC;
  signal wrclk_control_slave_status_overflow_q              : STD_LOGIC;
  signal wrclk_control_slave_status_overflow_signal         : STD_LOGIC;
  signal wrclk_control_slave_status_register                : STD_LOGIC_VECTOR(5 DOWNTO 0);
  signal wrclk_control_slave_status_underflow_q             : STD_LOGIC;
  signal wrclk_control_slave_status_underflow_signal        : STD_LOGIC;
  signal wrclk_control_slave_threshold_writedata            : STD_LOGIC_VECTOR(4 DOWNTO 0);
  signal wrreq_valid                                        : STD_LOGIC;

begin

  --the_scfifo, which is an e_instance
  the_scfifo : avalon_fifo_single_clock_fifo
    port map(
      empty => internal_empty,
      full  => internal_full,
      q     => internal_q,
      usedw => usedw,
      aclr  => module_input,
      clock => clock,
      data  => data,
      rdreq => rdreq,
      wrreq => wrreq_valid
    );

  module_input <= NOT reset_n;

  level                                         <= Std_Logic_Vector'(A_ToStdLogicVector(internal_full) & usedw);
  wrreq_valid                                   <= wrreq AND NOT internal_full;
  overflow                                      <= wrreq AND internal_full;
  underflow                                     <= rdreq AND internal_empty;
  wrclk_control_slave_threshold_writedata       <= A_EXT(A_WE_StdLogicVector(((wrclk_control_slave_writedata < std_logic_vector'("00000000000000000000000000000001"))), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector(((wrclk_control_slave_writedata > std_logic_vector'("00000000000000000000000000001111"))), std_logic_vector'("00000000000000000000000000001111"), (std_logic_vector'("000000000000000000000000000") & (wrclk_control_slave_writedata(4 DOWNTO 0))))), 5);
  wrclk_control_slave_event_almostfull_signal   <= wrclk_control_slave_almostfull_pulse;
  wrclk_control_slave_event_almostempty_signal  <= wrclk_control_slave_almostempty_pulse;
  wrclk_control_slave_status_almostfull_signal  <= wrclk_control_slave_almostfull_signal;
  wrclk_control_slave_status_almostempty_signal <= wrclk_control_slave_almostempty_signal;
  wrclk_control_slave_event_full_signal         <= wrclk_control_slave_full_pulse;
  wrclk_control_slave_event_empty_signal        <= wrclk_control_slave_empty_pulse;
  wrclk_control_slave_status_full_signal        <= wrclk_control_slave_full_signal;
  wrclk_control_slave_status_empty_signal       <= wrclk_control_slave_empty_signal;
  wrclk_control_slave_event_overflow_signal     <= overflow;
  wrclk_control_slave_event_underflow_signal    <= underflow;
  wrclk_control_slave_status_overflow_signal    <= overflow;
  wrclk_control_slave_status_underflow_signal   <= underflow;
  wrclk_control_slave_empty_signal              <= internal_empty;
  wrclk_control_slave_empty_pulse               <= wrclk_control_slave_empty_signal AND wrclk_control_slave_empty_n_reg;
  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_empty_n_reg <= std_logic'('0');
    elsif clock'event and clock = '1' then
      wrclk_control_slave_empty_n_reg <= NOT (wrclk_control_slave_empty_signal);
    end if;

  end process;

  wrclk_control_slave_full_signal <= internal_full;
  wrclk_control_slave_full_pulse  <= wrclk_control_slave_full_signal AND wrclk_control_slave_full_n_reg;
  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_full_n_reg <= std_logic'('0');
    elsif clock'event and clock = '1' then
      wrclk_control_slave_full_n_reg <= NOT (wrclk_control_slave_full_signal);
    end if;

  end process;

  wrclk_control_slave_almostempty_signal <= to_std_logic((level <= wrclk_control_slave_almostempty_threshold_register));
  wrclk_control_slave_almostempty_pulse  <= wrclk_control_slave_almostempty_signal AND wrclk_control_slave_almostempty_n_reg;
  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_almostempty_n_reg <= std_logic'('0');
    elsif clock'event and clock = '1' then
      wrclk_control_slave_almostempty_n_reg <= NOT (wrclk_control_slave_almostempty_signal);
    end if;

  end process;

  wrclk_control_slave_almostfull_signal <= to_std_logic((level >= wrclk_control_slave_almostfull_threshold_register));
  wrclk_control_slave_almostfull_pulse  <= wrclk_control_slave_almostfull_signal AND wrclk_control_slave_almostfull_n_reg;
  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_almostfull_n_reg <= std_logic'('0');
    elsif clock'event and clock = '1' then
      wrclk_control_slave_almostfull_n_reg <= NOT (wrclk_control_slave_almostfull_signal);
    end if;

  end process;

  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_almostempty_threshold_register <= std_logic_vector'("00001");
    elsif clock'event and clock = '1' then
      if std_logic'((to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000101")))) AND wrclk_control_slave_write)) = '1' then
        wrclk_control_slave_almostempty_threshold_register <= wrclk_control_slave_threshold_writedata;
      end if;
    end if;

  end process;

  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_almostfull_threshold_register <= std_logic_vector'("01111");
    elsif clock'event and clock = '1' then
      if std_logic'((to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000100")))) AND wrclk_control_slave_write)) = '1' then
        wrclk_control_slave_almostfull_threshold_register <= wrclk_control_slave_threshold_writedata;
      end if;
    end if;

  end process;

  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_ienable_register <= std_logic_vector'("000000");
    elsif clock'event and clock = '1' then
      if std_logic'((to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000011")))) AND wrclk_control_slave_write)) = '1' then
        wrclk_control_slave_ienable_register <= wrclk_control_slave_writedata(5 DOWNTO 0);
      end if;
    end if;

  end process;

  wrclk_control_slave_level_register <= level;
  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_event_underflow_q <= std_logic'('0');
    elsif clock'event and clock = '1' then
      if std_logic'(((wrclk_control_slave_write AND to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000010"))))) AND wrclk_control_slave_writedata(5))) = '1' then
        wrclk_control_slave_event_underflow_q <= std_logic'('0');
      elsif std_logic'(wrclk_control_slave_event_underflow_signal) = '1' then
        wrclk_control_slave_event_underflow_q <= Vector_To_Std_Logic(-SIGNED(std_logic_vector'("00000000000000000000000000000001")));
      end if;
    end if;

  end process;

  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_event_overflow_q <= std_logic'('0');
    elsif clock'event and clock = '1' then
      if std_logic'(((wrclk_control_slave_write AND to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000010"))))) AND wrclk_control_slave_writedata(4))) = '1' then
        wrclk_control_slave_event_overflow_q <= std_logic'('0');
      elsif std_logic'(wrclk_control_slave_event_overflow_signal) = '1' then
        wrclk_control_slave_event_overflow_q <= Vector_To_Std_Logic(-SIGNED(std_logic_vector'("00000000000000000000000000000001")));
      end if;
    end if;

  end process;

  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_event_almostempty_q <= std_logic'('0');
    elsif clock'event and clock = '1' then
      if std_logic'(((wrclk_control_slave_write AND to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000010"))))) AND wrclk_control_slave_writedata(3))) = '1' then
        wrclk_control_slave_event_almostempty_q <= std_logic'('0');
      elsif std_logic'(wrclk_control_slave_event_almostempty_signal) = '1' then
        wrclk_control_slave_event_almostempty_q <= Vector_To_Std_Logic(-SIGNED(std_logic_vector'("00000000000000000000000000000001")));
      end if;
    end if;

  end process;

  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_event_almostfull_q <= std_logic'('0');
    elsif clock'event and clock = '1' then
      if std_logic'(((wrclk_control_slave_write AND to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000010"))))) AND wrclk_control_slave_writedata(2))) = '1' then
        wrclk_control_slave_event_almostfull_q <= std_logic'('0');
      elsif std_logic'(wrclk_control_slave_event_almostfull_signal) = '1' then
        wrclk_control_slave_event_almostfull_q <= Vector_To_Std_Logic(-SIGNED(std_logic_vector'("00000000000000000000000000000001")));
      end if;
    end if;

  end process;

  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_event_empty_q <= std_logic'('0');
    elsif clock'event and clock = '1' then
      if std_logic'(((wrclk_control_slave_write AND to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000010"))))) AND wrclk_control_slave_writedata(1))) = '1' then
        wrclk_control_slave_event_empty_q <= std_logic'('0');
      elsif std_logic'(wrclk_control_slave_event_empty_signal) = '1' then
        wrclk_control_slave_event_empty_q <= Vector_To_Std_Logic(-SIGNED(std_logic_vector'("00000000000000000000000000000001")));
      end if;
    end if;

  end process;

  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_event_full_q <= std_logic'('0');
    elsif clock'event and clock = '1' then
      if std_logic'(((wrclk_control_slave_write AND to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000010"))))) AND wrclk_control_slave_writedata(0))) = '1' then
        wrclk_control_slave_event_full_q <= std_logic'('0');
      elsif std_logic'(wrclk_control_slave_event_full_signal) = '1' then
        wrclk_control_slave_event_full_q <= Vector_To_Std_Logic(-SIGNED(std_logic_vector'("00000000000000000000000000000001")));
      end if;
    end if;

  end process;

  wrclk_control_slave_event_register <= Std_Logic_Vector'(A_ToStdLogicVector(wrclk_control_slave_event_underflow_q) & A_ToStdLogicVector(wrclk_control_slave_event_overflow_q) & A_ToStdLogicVector(wrclk_control_slave_event_almostempty_q) & A_ToStdLogicVector(wrclk_control_slave_event_almostfull_q) & A_ToStdLogicVector(wrclk_control_slave_event_empty_q) & A_ToStdLogicVector(wrclk_control_slave_event_full_q));
  wrclk_control_slave_irq            <= or_reduce(((wrclk_control_slave_event_register AND wrclk_control_slave_ienable_register)));
  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_status_underflow_q <= std_logic'('0');
    elsif clock'event and clock = '1' then
      wrclk_control_slave_status_underflow_q <= wrclk_control_slave_status_underflow_signal;
    end if;

  end process;

  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_status_overflow_q <= std_logic'('0');
    elsif clock'event and clock = '1' then
      wrclk_control_slave_status_overflow_q <= wrclk_control_slave_status_overflow_signal;
    end if;

  end process;

  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_status_almostempty_q <= std_logic'('0');
    elsif clock'event and clock = '1' then
      wrclk_control_slave_status_almostempty_q <= wrclk_control_slave_status_almostempty_signal;
    end if;

  end process;

  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_status_almostfull_q <= std_logic'('0');
    elsif clock'event and clock = '1' then
      wrclk_control_slave_status_almostfull_q <= wrclk_control_slave_status_almostfull_signal;
    end if;

  end process;

  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_status_empty_q <= std_logic'('0');
    elsif clock'event and clock = '1' then
      wrclk_control_slave_status_empty_q <= wrclk_control_slave_status_empty_signal;
    end if;

  end process;

  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_status_full_q <= std_logic'('0');
    elsif clock'event and clock = '1' then
      wrclk_control_slave_status_full_q <= wrclk_control_slave_status_full_signal;
    end if;

  end process;

  wrclk_control_slave_status_register <= Std_Logic_Vector'(A_ToStdLogicVector(wrclk_control_slave_status_underflow_q) & A_ToStdLogicVector(wrclk_control_slave_status_overflow_q) & A_ToStdLogicVector(wrclk_control_slave_status_almostempty_q) & A_ToStdLogicVector(wrclk_control_slave_status_almostfull_q) & A_ToStdLogicVector(wrclk_control_slave_status_empty_q) & A_ToStdLogicVector(wrclk_control_slave_status_full_q));
  wrclk_control_slave_read_mux        <= (((((((A_REP(to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000000")))), 32) AND (std_logic_vector'("000000000000000000000000000") & (wrclk_control_slave_level_register)))) OR ((A_REP(to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000001")))), 32) AND (std_logic_vector'("00000000000000000000000000") & (wrclk_control_slave_status_register))))) OR ((A_REP(to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000010")))), 32) AND (std_logic_vector'("00000000000000000000000000") & (wrclk_control_slave_event_register))))) OR ((A_REP(to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000011")))), 32) AND (std_logic_vector'("00000000000000000000000000") & (wrclk_control_slave_ienable_register))))) OR ((A_REP(to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000100")))), 32) AND (std_logic_vector'("000000000000000000000000000") & (wrclk_control_slave_almostfull_threshold_register))))) OR ((A_REP(to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000101")))), 32) AND (std_logic_vector'("000000000000000000000000000") & (wrclk_control_slave_almostempty_threshold_register))))) OR ((A_REP(to_std_logic(((((((NOT (((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000000")))) AND (NOT (((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000001"))))) AND (NOT (((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000010"))))) AND (NOT (((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000011"))))) AND (NOT (((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000100"))))) AND (NOT (((std_logic_vector'("00000000000000000000000000000") & (wrclk_control_slave_address)) = std_logic_vector'("00000000000000000000000000000101")))))), 32) AND (std_logic_vector'("000000000000000000000000000") & (wrclk_control_slave_level_register))));
  process(clock, reset_n)
  begin
    if reset_n = '0' then
      wrclk_control_slave_readdata <= std_logic_vector'("00000000000000000000000000000000");
    elsif clock'event and clock = '1' then
      if std_logic'(wrclk_control_slave_read) = '1' then
        wrclk_control_slave_readdata <= wrclk_control_slave_read_mux;
      end if;
    end if;

  end process;

  --vhdl renameroo for output signals
  empty <= internal_empty;
  --vhdl renameroo for output signals
  full  <= internal_full;
  --vhdl renameroo for output signals
  q     <= internal_q;

end europa;

-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity avalon_fifo is
  port(
    -- inputs:
    signal avalonmm_read_slave_read         : IN  STD_LOGIC;
    signal avalonmm_write_slave_write       : IN  STD_LOGIC;
    signal avalonmm_write_slave_writedata   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal reset_n                          : IN  STD_LOGIC;
    signal wrclk_control_slave_address      : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal wrclk_control_slave_read         : IN  STD_LOGIC;
    signal wrclk_control_slave_write        : IN  STD_LOGIC;
    signal wrclk_control_slave_writedata    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal wrclock                          : IN  STD_LOGIC;
    -- outputs:
    signal avalonmm_read_slave_readdata     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal avalonmm_read_slave_waitrequest  : OUT STD_LOGIC;
    signal avalonmm_write_slave_waitrequest : OUT STD_LOGIC;
    signal wrclk_control_slave_irq          : OUT STD_LOGIC;
    signal wrclk_control_slave_readdata     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
end entity avalon_fifo;

architecture europa of avalon_fifo is
  component avalon_fifo_scfifo_with_controls is
    port(
      -- inputs:
      signal clock                         : IN  STD_LOGIC;
      signal data                          : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
      signal rdreq                         : IN  STD_LOGIC;
      signal reset_n                       : IN  STD_LOGIC;
      signal wrclk_control_slave_address   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
      signal wrclk_control_slave_read      : IN  STD_LOGIC;
      signal wrclk_control_slave_write     : IN  STD_LOGIC;
      signal wrclk_control_slave_writedata : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
      signal wrreq                         : IN  STD_LOGIC;
      -- outputs:
      signal empty                         : OUT STD_LOGIC;
      signal full                          : OUT STD_LOGIC;
      signal q                             : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      signal wrclk_control_slave_irq       : OUT STD_LOGIC;
      signal wrclk_control_slave_readdata  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
  end component avalon_fifo_scfifo_with_controls;

  signal clock                                 : STD_LOGIC;
  signal data                                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal empty                                 : STD_LOGIC;
  signal full                                  : STD_LOGIC;
  signal internal_wrclk_control_slave_irq      : STD_LOGIC;
  signal internal_wrclk_control_slave_readdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal q                                     : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal rdreq                                 : STD_LOGIC;
  signal wrreq                                 : STD_LOGIC;

begin

  --the_scfifo_with_controls, which is an e_instance
  the_scfifo_with_controls : avalon_fifo_scfifo_with_controls
    port map(
      empty                         => empty,
      full                          => full,
      q                             => q,
      wrclk_control_slave_irq       => internal_wrclk_control_slave_irq,
      wrclk_control_slave_readdata  => internal_wrclk_control_slave_readdata,
      clock                         => clock,
      data                          => data,
      rdreq                         => rdreq,
      reset_n                       => reset_n,
      wrclk_control_slave_address   => wrclk_control_slave_address,
      wrclk_control_slave_read      => wrclk_control_slave_read,
      wrclk_control_slave_write     => wrclk_control_slave_write,
      wrclk_control_slave_writedata => wrclk_control_slave_writedata,
      wrreq                         => wrreq
    );

  --in, which is an e_avalon_slave
  --out, which is an e_avalon_slave
  data                             <= avalonmm_write_slave_writedata;
  wrreq                            <= avalonmm_write_slave_write;
  avalonmm_read_slave_readdata     <= q;
  rdreq                            <= avalonmm_read_slave_read;
  clock                            <= wrclock;
  avalonmm_write_slave_waitrequest <= full;
  avalonmm_read_slave_waitrequest  <= empty;
  --in_csr, which is an e_avalon_slave
  --vhdl renameroo for output signals
  wrclk_control_slave_irq          <= internal_wrclk_control_slave_irq;
  --vhdl renameroo for output signals
  wrclk_control_slave_readdata     <= internal_wrclk_control_slave_readdata;

end europa;

