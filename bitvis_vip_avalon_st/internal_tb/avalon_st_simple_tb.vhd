--================================================================================================================================
-- Copyright (c) 2019 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
-- THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--================================================================================================================================

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_avalon_st;
use bitvis_vip_avalon_st.avalon_st_bfm_pkg.all;


-- Test case entity
entity avalon_st_simple_tb is
  generic(
    GC_TEST          : string  := "UVVM";
    GC_CHANNEL_WIDTH : natural := 8;
    GC_DATA_WIDTH    : natural := 32;
    GC_ERROR_WIDTH   : natural := 1;
    GC_EMPTY_WIDTH   : natural := 1
  );
end entity;

-- Test case architecture
architecture func of avalon_st_simple_tb is
  --------------------------------------------------------------------------------
  -- Types and constants declarations
  --------------------------------------------------------------------------------
  constant C_CLK_PERIOD : time   := 10 ns;
  constant C_SCOPE      : string := C_TB_SCOPE_DEFAULT;

  --------------------------------------------------------------------------------
  -- Signal declarations
  --------------------------------------------------------------------------------
  signal clk       : std_logic := '0';
  signal areset    : std_logic := '0';
  signal clock_ena : boolean   := false;

  -- The avalon_st interface is gathered in a record, so procedures that use the
  -- avalon_st interface have less arguments
  signal avalon_st_master_if : t_avalon_st_if(channel(GC_CHANNEL_WIDTH-1 downto 0),
                                              data(GC_DATA_WIDTH-1 downto 0),
                                              data_error(GC_ERROR_WIDTH-1 downto 0),
                                              empty(GC_EMPTY_WIDTH-1 downto 0));
  signal avalon_st_slave_if  : t_avalon_st_if(channel(GC_CHANNEL_WIDTH-1 downto 0),
                                              data(GC_DATA_WIDTH-1 downto 0),
                                              data_error(GC_ERROR_WIDTH-1 downto 0),
                                              empty(GC_EMPTY_WIDTH-1 downto 0));

  --------------------------------------------------------------------------------
  -- Component declarations
  --------------------------------------------------------------------------------
  -- sc_fifo generated with Quartus Qsys system
  component sc_fifo is
    port (
      clk               : in  std_logic;
      csr_address       : in  std_logic_vector(2 downto 0);
      csr_read          : in  std_logic;
      csr_readdata      : out std_logic_vector(31 downto 0);
      csr_write         : in  std_logic;
      csr_writedata     : in  std_logic_vector(31 downto 0);
      in_data           : in  std_logic_vector(7 downto 0);
      in_endofpacket    : in  std_logic;
      in_ready          : out std_logic;
      in_startofpacket  : in  std_logic;
      in_valid          : in  std_logic;
      out_data          : out std_logic_vector(7 downto 0);
      out_endofpacket   : out std_logic;
      out_ready         : in  std_logic;
      out_startofpacket : out std_logic;
      out_valid         : out std_logic;
      reset             : in  std_logic);
  end component sc_fifo;

begin

  -----------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  -----------------------------------------------------------------------------
  -- Clock Generator
  -----------------------------------------------------------------------------
  p_clock : clock_generator(clk, clock_ena, C_CLK_PERIOD, "Avalon-ST CLK");

  --------------------------------------------------------------------------------
  -- Instantiate DUT
  --------------------------------------------------------------------------------
  i_avalon_st_fifo : entity work.avalon_st_fifo
    generic map (
      GC_DATA_WIDTH    => GC_DATA_WIDTH,
      GC_CHANNEL_WIDTH => GC_CHANNEL_WIDTH,
      GC_FIFO_DEPTH    => 256
    )
    port map (
      clk_i            => clk,
      reset_i          => areset,
      -- Slave stream interface
      slave_data_i     => avalon_st_master_if.data,
      slave_channel_i  => avalon_st_master_if.channel,
      slave_valid_i    => avalon_st_master_if.valid,
      slave_sop_i      => avalon_st_master_if.start_of_packet,
      slave_eop_i      => avalon_st_master_if.end_of_packet,
      slave_ready_o    => avalon_st_master_if.ready,
      -- Master stream interface
      master_data_o    => avalon_st_slave_if.data,
      master_channel_o => avalon_st_slave_if.channel,
      master_valid_o   => avalon_st_slave_if.valid,
      master_sop_o     => avalon_st_slave_if.start_of_packet,
      master_eop_o     => avalon_st_slave_if.end_of_packet,
      master_ready_i   => avalon_st_slave_if.ready
    );

  --------------------------------------------------------------------------------
  -- PROCESS: p_main
  --------------------------------------------------------------------------------
  p_main : process
    variable avl_st_bfm_config : t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT;
    variable data_array  : t_slv_array(0 to 7)(7 downto 0);
    variable recv_array  : t_slv_array(0 to 7)(7 downto 0);
    variable exp_array   : t_slv_array(0 to 7)(7 downto 0);

    --------------------------------------------
    -- Overloads for this testbench
    --------------------------------------------
    procedure avalon_st_transmit (
      data_array : in t_slv_array;
      channel    : in natural) is
    begin
      avalon_st_transmit(to_unsigned(channel, GC_CHANNEL_WIDTH), data_array, "", clk, avalon_st_master_if, C_SCOPE,
        shared_msg_id_panel, avl_st_bfm_config);
    end;
    procedure avalon_st_receive (
      data_array : out t_slv_array;
      channel    : in natural) is
    begin
      avalon_st_receive(to_unsigned(channel, GC_CHANNEL_WIDTH), data_array, "", clk, avalon_st_slave_if, C_SCOPE,
        shared_msg_id_panel, avl_st_bfm_config);
    end;
    procedure avalon_st_expect (
      exp_array : in t_slv_array;
      channel   : in natural) is
    begin
      avalon_st_expect(to_unsigned(channel, GC_CHANNEL_WIDTH), exp_array, "", clk, avalon_st_slave_if, error, C_SCOPE,
        shared_msg_id_panel, avl_st_bfm_config);
    end;

  begin

    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TEST & "_Log.txt");
    set_alert_file_name(GC_TEST & "_Alert.txt");

    -- Wait for UVVM to finish initialization
    await_uvvm_initialization(VOID);

    -- Override default config with settings for this testbench
    avl_st_bfm_config.max_wait_cycles          := 1000;
    avl_st_bfm_config.max_wait_cycles_severity := error;
    avl_st_bfm_config.clock_period             := C_CLK_PERIOD;
    --avl_st_bfm_config.clock_period_margin      := -- Input clock period margin to specified clock_period
    --avl_st_bfm_config.clock_margin_severity    := -- The above margin will have this severity
    avl_st_bfm_config.setup_time               := C_CLK_PERIOD/4;
    avl_st_bfm_config.hold_time                := C_CLK_PERIOD/4;
    avl_st_bfm_config.symbol_width             := 8;
    avl_st_bfm_config.first_symbol_in_msb      := false;
    avl_st_bfm_config.max_channel              := 1;

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    -- Verbosity control
    enable_log_msg(ALL_MESSAGES);

    --------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Start Simulation of Avalon-ST");
    --------------------------------------------------------------------------------
    clock_ena <= true; -- start clock generator
    gen_pulse(areset, 10*C_CLK_PERIOD, "Pulsing reset for 10 clock periods");

    wait for 10*C_CLK_PERIOD;

    for i in data_array'range loop
      data_array(i) := random(data_array(0)'length);
      exp_array(i)  := data_array(i);
    end loop;

    log(ID_LOG_HDR, "Transmit some data to FIFO and receive output");
    avalon_st_transmit(data_array, 0);
    avalon_st_receive(recv_array, 0);

    log(ID_LOG_HDR, "Transmit some data to FIFO and check expected output");
    avalon_st_transmit(data_array, 1);
    avalon_st_expect(exp_array, 1);

    log(ID_LOG_HDR, "Transmit some data to FIFO and receive output, but with too small receive buffer");
    avalon_st_transmit(data_array, 0);
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    avalon_st_receive(recv_array(0 to recv_array'length-2), 0);

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;             -- Allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);
    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely

  end process p_main;

end func;
