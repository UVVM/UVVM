--========================================================================================================================
-- Copyright (c) 2017 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--========================================================================================================================

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--=================================================================================================
package axilite_bfm_pkg is

  --===============================================================================================
  -- Types and constants for AXILITE BFMs
  --===============================================================================================
  constant C_SCOPE : string := "AXILITE BFM";

  type t_axilite_response_status is (OKAY, SLVERR, DECERR, EXOKAY); -- EXOKAY not supported for AXI-Lite, will raise TB_FAILURE

  type t_axilite_protection is(
    UNPRIVILIGED_UNSECURE_DATA,
    UNPRIVILIGED_UNSECURE_INSTRUCTION,
    UNPRIVILIGED_SECURE_DATA,
    UNPRIVILIGED_SECURE_INSTRUCTION,
    PRIVILIGED_UNSECURE_DATA,
    PRIVILIGED_UNSECURE_INSTRUCTION,
    PRIVILIGED_SECURE_DATA,
    PRIVILIGED_SECURE_INSTRUCTION
  );

  -- Configuration record to be assigned in the test harness.
  type t_axilite_bfm_config is
  record
    max_wait_cycles             : natural;                   -- Used for setting the maximum cycles to wait before an alert is issued when waiting for ready and valid signals from the DUT.
    max_wait_cycles_severity    : t_alert_level;             -- The above timeout will have this severity
    clock_period                : time;                      -- Period of the clock signal.
    clock_period_margin         : time;                      -- Input clock period margin to specified clock_period
    clock_margin_severity       : t_alert_level;             -- The above margin will have this severity
    setup_time                  : time;                      -- Setup time for generated signals, set to clock_period/4
    hold_time                   : time;                      -- Hold time for generated signals, set to clock_period/4
    expected_response           : t_axilite_response_status; -- Sets the expected response for both read and write transactions.
    expected_response_severity  : t_alert_level;             -- A response mismatch will have this severity.
    protection_setting          : t_axilite_protection;      -- Sets the AXI access permissions (e.g. write to data/instruction, privileged and secure access).
    num_aw_pipe_stages          : natural;                   -- Write Address Channel pipeline steps.
    num_w_pipe_stages           : natural;                   -- Write Data Channel pipeline steps.
    num_ar_pipe_stages          : natural;                   -- Read Address Channel pipeline steps.
    num_r_pipe_stages           : natural;                   -- Read Data Channel pipeline steps.
    num_b_pipe_stages           : natural;                   -- Response Channel pipeline steps.
    id_for_bfm                  : t_msg_id;                  -- The message ID used as a general message ID in the AXI-Lite BFM
    id_for_bfm_wait             : t_msg_id;                  -- The message ID used for logging waits in the AXI-Lite BFM
    id_for_bfm_poll             : t_msg_id;                  -- The message ID used for logging polling in the AXI-Lite BFM
  end record;

  constant C_AXILITE_BFM_CONFIG_DEFAULT : t_axilite_bfm_config := (
    max_wait_cycles             => 10,
    max_wait_cycles_severity    => TB_FAILURE,
    clock_period                => 10 ns,
    clock_period_margin         => 0 ns,
    clock_margin_severity       => TB_ERROR,
    setup_time                  => 2.5 ns,
    hold_time                   => 2.5 ns,
    expected_response           => OKAY,
    expected_response_severity  => TB_FAILURE,
    protection_setting          => UNPRIVILIGED_UNSECURE_DATA,
    num_aw_pipe_stages          => 1,
    num_w_pipe_stages           => 1,
    num_ar_pipe_stages          => 1,
    num_r_pipe_stages           => 1,
    num_b_pipe_stages           => 1,
    id_for_bfm                  => ID_BFM,
    id_for_bfm_wait             => ID_BFM_WAIT,
    id_for_bfm_poll             => ID_BFM_POLL
    );

  -- AXI-Lite Interface signals
  type t_axilite_write_address_channel is record
    --DUT inputs
    awaddr  : std_logic_vector;
    awvalid : std_logic;
    awprot  : std_logic_vector(2 downto 0); -- [0: '0' - unpriviliged access, '1' - priviliged access; 1: '0' - secure access, '1' - non-secure access, 2: '0' - Data access, '1' - Instruction accesss]
    --DUT outputs
    awready : std_logic;
  end record;

  type t_axilite_write_data_channel is record
    --DUT inputs
    wdata   : std_logic_vector;
    wstrb   : std_logic_vector;
    wvalid  : std_logic;
    --DUT outputs
    wready  : std_logic;
  end record;

  type t_axilite_write_response_channel is record
    --DUT inputs
    bready  : std_logic;
    --DUT outputs
    bresp   : std_logic_vector(1 downto 0);
    bvalid  : std_logic;
  end record;

  type t_axilite_read_address_channel is record
    --DUT inputs
    araddr  : std_logic_vector;
    arvalid : std_logic;
    arprot  : std_logic_vector(2 downto 0);  -- [0: '0' - unpriviliged access, '1' - priviliged access; 1: '0' - secure access, '1' - non-secure access, 2: '0' - Data access, '1' - Instruction accesss]
    --DUT outputs
    arready : std_logic;
  end record;

  type t_axilite_read_data_channel is record
    --DUT inputs
    rready  : std_logic;
    --DUT outputs
    rdata   : std_logic_vector;
    rresp   : std_logic_vector(1 downto 0);
    rvalid  : std_logic;
  end record;

  type t_axilite_if is record
    write_address_channel  : t_axilite_write_address_channel;
    write_data_channel     : t_axilite_write_data_channel;
    write_response_channel : t_axilite_write_response_channel;
    read_address_channel   : t_axilite_read_address_channel;
    read_data_channel      : t_axilite_read_data_channel;
  end record;


  --===============================================================================================
  -- BFM procedures
  --===============================================================================================

  ------------------------------------------
  -- init_axilite_if_signals
  ------------------------------------------
  -- - This function returns an AXILITE interface with initialized signals.
  -- - All AXILITE input signals are initialized to 0
  -- - All AXILITE output signals are initialized to Z
  -- - awprot and arprot are initialized to UNPRIVILIGED_UNSECURE_DATA
  function init_axilite_if_signals(
    addr_width : natural;
    data_width : natural
    ) return t_axilite_if;


  ------------------------------------------
  -- axilite_write
  ------------------------------------------
  -- This procedure writes data to the AXILITE interface specified in axilite_if
  -- - The protection setting is set to UNPRIVILIGED_UNSECURE_DATA in this procedure
  -- - The byte enable input is set to 1 for all bytes in this procedure
  -- - When the write is completed, a log message is issued with log ID id_for_bfm
  procedure axilite_write (
    constant addr_value         : in  unsigned;
    constant data_value         : in  std_logic_vector;
    constant msg                : in  string;
    signal   clk                : in std_logic;
    signal   axilite_if         : inout t_axilite_if;
    constant scope              : in  string                := C_SCOPE;
    constant msg_id_panel       : in  t_msg_id_panel        := shared_msg_id_panel;
    constant config             : in  t_axilite_bfm_config  := C_AXILITE_BFM_CONFIG_DEFAULT
    );


  ------------------------------------------
  -- axilite_write
  ------------------------------------------
  -- This procedure writes data to the AXILITE interface specified in axilite_if
  -- - When the write is completed, a log message is issued with log ID id_for_bfm
  procedure axilite_write (
    constant addr_value         : in  unsigned;
    constant data_value         : in  std_logic_vector;
    constant byte_enable        : in  std_logic_vector;
    constant msg                : in  string;
    signal   clk                : in std_logic;
    signal   axilite_if         : inout t_axilite_if;
    constant scope              : in  string                := C_SCOPE;
    constant msg_id_panel       : in  t_msg_id_panel        := shared_msg_id_panel;
    constant config             : in  t_axilite_bfm_config  := C_AXILITE_BFM_CONFIG_DEFAULT
    );


  ------------------------------------------
  -- axilite_read
  ------------------------------------------
  -- This procedure reads data from the AXILITE interface specified in axilite_if,
  -- and returns the read data in data_value.
  procedure axilite_read (
    constant addr_value     : in  unsigned;
    variable data_value     : out std_logic_vector;
    constant msg            : in  string;
    signal   clk            : in std_logic;
    signal   axilite_if     : inout t_axilite_if;
    constant scope          : in  string                := C_SCOPE;
    constant msg_id_panel   : in  t_msg_id_panel        := shared_msg_id_panel;
    constant config         : in  t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT;
    constant ext_proc_call  : in  string                    := ""  -- External proc_call; overwrite if called from other BFM procedure like axilite_check
    );


  ------------------------------------------
  -- axilite_check
  ------------------------------------------
  -- This procedure reads data from the AXILITE interface specified in axilite_if,
  -- and compares it to the data in data_exp.
  -- - If the received data inconsistent with data_exp, an alert with severity
  --   alert_level is issued.
  -- - If the received data was correct, a log message with ID id_for_bfm is issued.
  procedure axilite_check (
    constant addr_value         : in  unsigned;
    constant data_exp           : in  std_logic_vector;
    constant msg                : in  string;
    signal   clk                : in std_logic;
    signal   axilite_if         : inout t_axilite_if;
    constant alert_level        : in  t_alert_level         := error;
    constant scope              : in  string                := C_SCOPE;
    constant msg_id_panel       : in  t_msg_id_panel        := shared_msg_id_panel;
    constant config             : in  t_axilite_bfm_config  := C_AXILITE_BFM_CONFIG_DEFAULT
    );

end package axilite_bfm_pkg;


--=================================================================================================
--=================================================================================================

package body axilite_bfm_pkg is

  ----------------------------------------------------
  -- Support procedures
  ----------------------------------------------------

  function to_slv(
    protection : t_axilite_protection
    ) return std_logic_vector is
    variable v_prot_slv : std_logic_vector(2 downto 0);
  begin
    case protection is
      when UNPRIVILIGED_UNSECURE_DATA =>
        v_prot_slv := "010";
      when UNPRIVILIGED_UNSECURE_INSTRUCTION =>
        v_prot_slv := "011";
      when UNPRIVILIGED_SECURE_DATA =>
        v_prot_slv := "000";
      when UNPRIVILIGED_SECURE_INSTRUCTION =>
        v_prot_slv := "001";
      when PRIVILIGED_UNSECURE_DATA =>
        v_prot_slv := "110";
      when PRIVILIGED_UNSECURE_INSTRUCTION =>
        v_prot_slv := "111";
      when PRIVILIGED_SECURE_DATA =>
        v_prot_slv := "100";
      when PRIVILIGED_SECURE_INSTRUCTION =>
        v_prot_slv := "101";
    end case;

    return v_prot_slv;
  end function;

  function to_slv(
    axilite_response_status : t_axilite_response_status;
    constant scope          : in  string           := C_SCOPE;
    constant msg_id_panel   : in  t_msg_id_panel   := shared_msg_id_panel
    ) return std_logic_vector is
    variable v_axilite_response_status_slv : std_logic_vector(1 downto 0);
  begin
    check_value(axilite_response_status /= EXOKAY, TB_FAILURE, "EXOKAY response status is not supported in AXI-Lite", scope, ID_NEVER, msg_id_panel);

    case axilite_response_status is
      when OKAY =>
        v_axilite_response_status_slv := "00";
      when SLVERR =>
        v_axilite_response_status_slv := "10";
      when DECERR =>
        v_axilite_response_status_slv := "11";
      when EXOKAY =>
        v_axilite_response_status_slv := "01";
    end case;
    return v_axilite_response_status_slv;
  end function;

  function to_axilite_response_status(
    resp : std_logic_vector(1 downto 0);
    constant scope          : in  string           := C_SCOPE;
    constant msg_id_panel   : in  t_msg_id_panel   := shared_msg_id_panel
    ) return t_axilite_response_status is
  begin
    check_value(resp /= "01", TB_FAILURE, "EXOKAY response status is not supported in AXI-Lite", scope, ID_NEVER, msg_id_panel);
    case resp is
      when "00" =>
        return OKAY;
      when "10" =>
        return SLVERR;
      when "11" =>
        return DECERR;
      when others =>
        return EXOKAY;
    end case;
  end function;

  ----------------------------------------------------
  -- BFM procedures
  ----------------------------------------------------

  function init_axilite_if_signals(
    addr_width : natural;
    data_width : natural
    ) return t_axilite_if is
    variable init_if : t_axilite_if(  write_address_channel( awaddr( addr_width    -1 downto 0)),
                                      write_data_channel(    wdata(  data_width    -1 downto 0),
                                                             wstrb(( data_width/8) -1 downto 0)),
                                      read_address_channel(  araddr( addr_width    -1 downto 0)),
                                      read_data_channel(     rdata(  data_width    -1 downto 0)));
  begin
    -- Write Address Channel
    init_if.write_address_channel.awaddr  := (init_if.write_address_channel.awaddr'range => '0');
    init_if.write_address_channel.awvalid := '0';
    init_if.write_address_channel.awprot  := to_slv(UNPRIVILIGED_UNSECURE_DATA); --"010"
    init_if.write_address_channel.awready := 'Z';
    -- Write Data Channel
    init_if.write_data_channel.wdata   := (init_if.write_data_channel.wdata'range => '0');
    init_if.write_data_channel.wstrb   := (init_if.write_data_channel.wstrb'range => '0');
    init_if.write_data_channel.wvalid  := '0';
    init_if.write_data_channel.wready  := 'Z';
    -- Write Response Channel
    init_if.write_response_channel.bready := '0';
    init_if.write_response_channel.bresp  := (init_if.write_response_channel.bresp'range => 'Z');
    init_if.write_response_channel.bvalid := 'Z';
    -- Read Address Channel
    init_if.read_address_channel.araddr  := (init_if.read_address_channel.araddr'range => '0');
    init_if.read_address_channel.arvalid := '0';
    init_if.read_address_channel.arprot  := to_slv(UNPRIVILIGED_UNSECURE_DATA); --"010"
    init_if.read_address_channel.arready := 'Z';
    -- Read Data Channel
    init_if.read_data_channel.rready := '0';
    init_if.read_data_channel.rdata  := (init_if.read_data_channel.rdata'range => 'Z');
    init_if.read_data_channel.rresp  := (init_if.read_data_channel.rresp'range => 'Z');
    init_if.read_data_channel.rvalid := 'Z';
    return init_if;
  end function;

  procedure axilite_write (
    constant addr_value         : in  unsigned;
    constant data_value         : in  std_logic_vector;
    constant msg                : in  string;
    signal   clk                : in std_logic;
    signal   axilite_if         : inout t_axilite_if;
    constant scope              : in  string           := C_SCOPE;
    constant msg_id_panel       : in  t_msg_id_panel   := shared_msg_id_panel;
    constant config             : in  t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT
    ) is
    constant C_BYTE_ENABLE  : std_logic_vector(axilite_if.write_data_channel.wstrb'length-1 downto 0) := (others => '1');
  begin
    axilite_write(addr_value, data_value, C_BYTE_ENABLE, msg, clk, axilite_if, scope, msg_id_panel, config);
  end procedure axilite_write;

  procedure axilite_write (
    constant addr_value     : in  unsigned;
    constant data_value     : in  std_logic_vector;
    constant byte_enable    : in  std_logic_vector;
    constant msg            : in  string;
    signal   clk            : in std_logic;
    signal   axilite_if     : inout t_axilite_if;
    constant scope          : in  string           := C_SCOPE;
    constant msg_id_panel   : in  t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in  t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT
    ) is
    constant proc_name : string := "axilite_write";
    constant proc_call : string := "axilite_write(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) &
                                   ", " & to_string(data_value, HEX, AS_IS, INCL_RADIX) & ")";

    constant max_pipe_stages : integer := maximum(config.num_w_pipe_stages, config.num_aw_pipe_stages);
    variable v_await_awready : boolean := true;
    variable v_await_wready  : boolean := true;
    variable v_await_bvalid  : boolean := true;

    -- Normalize to the DUT addr/data widths
    variable v_normalized_addr : std_logic_vector(axilite_if.write_address_channel.awaddr'length-1 downto 0) :=
      normalize_and_check(std_logic_vector(addr_value), axilite_if.write_address_channel.awaddr, ALLOW_NARROWER, "addr", "axilite_if.write_address_channel.awaddr", msg);
    variable v_normalized_data : std_logic_vector(axilite_if.write_data_channel.wdata'length-1 downto 0) :=
      normalize_and_check(data_value, axilite_if.write_data_channel.wdata, ALLOW_NARROWER, "data", "axilite_if.write_data_channel.wdata", msg);
    -- Helper variables
    variable v_last_rising_edge  : time    := -1 ns;  -- time stamp for clk period checking
  begin
    check_value(v_normalized_data'length = 32 or v_normalized_data'length = 64, TB_ERROR, "AXI-lite data width must be either 32 or 64!", scope, ID_NEVER, msg_id_panel);
    -- setup_time and hold_time checking
    check_value(config.setup_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(config.hold_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(config.setup_time > 0 ns, TB_FAILURE, "Sanity check: Check that setup_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(config.hold_time > 0 ns, TB_FAILURE, "Sanity check: Check that hold_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, proc_call);

    for cycle in 0 to config.max_wait_cycles loop

      -- check if enough room for setup_time in low period
      if (clk = '0') and (config.setup_time > (config.clock_period/2 - clk'last_event))then
        await_value(clk, '1', 0 ns, config.clock_period/2, TB_FAILURE, proc_call & ": timeout waiting for clk low period for setup_time.");
      end if;
      -- Wait setup_time specified in config record
      wait_until_given_time_before_rising_edge(clk, config.setup_time, config.clock_period);

      if cycle = config.num_w_pipe_stages then
        axilite_if.write_data_channel.wdata  <= v_normalized_data;
        axilite_if.write_data_channel.wstrb  <= byte_enable;
        axilite_if.write_data_channel.wvalid <= '1';
      end if;

      if cycle = config.num_aw_pipe_stages then
        axilite_if.write_address_channel.awaddr  <= v_normalized_addr;
        axilite_if.write_address_channel.awvalid <= '1';
        axilite_if.write_address_channel.awprot  <= to_slv(config.protection_setting);
      end if;

      wait until rising_edge(clk);
      -- check if clk period since last rising edge is within specifications and take a new time stamp
      if v_last_rising_edge > -1 ns then
        check_value_in_range(now - v_last_rising_edge, config.clock_period - config.clock_period_margin, config.clock_period + config.clock_period_margin, config.clock_margin_severity, "clk period not within requirement.");
      end if;
      v_last_rising_edge := now; -- time stamp for clk period checking

      if axilite_if.write_data_channel.wready = '1' and cycle >= config.num_w_pipe_stages then
        axilite_if.write_data_channel.wvalid <= '0' after config.clock_period/4;
        v_await_wready := false;
      end if;

      if axilite_if.write_address_channel.awready = '1' and cycle >= config.num_aw_pipe_stages then
        axilite_if.write_address_channel.awvalid <= '0' after config.clock_period/4;
        v_await_awready := false;
      end if;

      if not v_await_awready and not v_await_wready then
        exit;
      end if;
    end loop;

    check_value(not v_await_wready, config.max_wait_cycles_severity, ": Timeout waiting for WREADY", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(not v_await_awready, config.max_wait_cycles_severity, ": Timeout waiting for AWREADY", scope, ID_NEVER, msg_id_panel, proc_call);

    -- check if enough room for setup_time before next clk rising edge
    if (clk = '0') and (config.setup_time > (config.clock_period/2 - clk'last_event))then
      await_value(clk, '1', 0 ns, config.clock_period/2, TB_FAILURE, proc_call & ": timeout waiting for clk low period for setup_time.");
    end if;
    -- Wait setup_time specified in config record
    wait_until_given_time_before_rising_edge(clk, config.setup_time, config.clock_period);

    axilite_if.write_response_channel.bready <= '1';

    for cycle in 0 to config.max_wait_cycles loop

      wait until rising_edge(clk);
      -- check if clk period since last rising edge is within specifications and take a new time stamp
      if v_last_rising_edge > -1 ns then
        check_value_in_range(now - v_last_rising_edge, config.clock_period - config.clock_period_margin, config.clock_period + config.clock_period_margin, config.clock_margin_severity, "clk period not within requirement.");
      end if;
      v_last_rising_edge := now; -- time stamp for clk period checking

      if axilite_if.write_response_channel.bvalid = '1' then

        check_value(axilite_if.write_response_channel.bresp, to_slv(config.expected_response), config.expected_response_severity, ": BRESP detected", scope, BIN, AS_IS, ID_NEVER, msg_id_panel, proc_call);

        -- Wait hold_time specified in config record
        wait_until_given_time_after_rising_edge(clk, config.hold_time);

        axilite_if.write_response_channel.bready <= '0';
        v_await_bvalid := false;
      end if;

      if not v_await_bvalid then
        exit;
      end if;
    end loop;

    check_value(not v_await_bvalid, config.max_wait_cycles_severity, ": Timeout waiting for BVALID", scope, ID_NEVER, msg_id_panel, proc_call);

    axilite_if.write_address_channel.awaddr(axilite_if.write_address_channel.awaddr'length-1 downto 0) <= (others => '0');
    axilite_if.write_address_channel.awvalid <= '0';
    axilite_if.write_data_channel.wdata(axilite_if.write_data_channel.wdata'length-1 downto 0)   <= (others => '0');
    axilite_if.write_data_channel.wstrb(axilite_if.write_data_channel.wstrb'length-1 downto 0)   <= (others => '1');
    axilite_if.write_data_channel.wvalid  <= '0';

    log(config.id_for_bfm, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);

  end procedure axilite_write;

  procedure axilite_read (
    constant addr_value     : in  unsigned;
    variable data_value     : out std_logic_vector;
    constant msg            : in  string;
    signal   clk            : in  std_logic;
    signal   axilite_if     : inout t_axilite_if;
    constant scope          : in  string               := C_SCOPE;
    constant msg_id_panel   : in  t_msg_id_panel       := shared_msg_id_panel;
    constant config         : in  t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT;
    constant ext_proc_call  : in  string               := ""  -- External proc_call; overwrite if called from other BFM procedure like axilite_check
    ) is
    constant local_proc_name : string := "axilite_read"; -- Local proc_name; used if called from sequncer or VVC
    constant local_proc_call : string := local_proc_name & "(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ")"; -- Local proc_call; used if called from sequncer or VVC

    -- Normalize to the DUT addr/data widths
    variable v_normalized_addr : std_logic_vector(axilite_if.read_address_channel.araddr'length-1 downto 0) :=
      normalize_and_check(std_logic_vector(addr_value), axilite_if.read_address_channel.araddr, ALLOW_NARROWER, "addr", "axilite_if.read_address_channel.araddr", msg);
    -- Helper variables
    variable v_proc_call          : line;
    variable v_await_arready      : boolean := true;
    variable v_await_rvalid       : boolean := true;
    variable v_data_value         : std_logic_vector(axilite_if.read_data_channel.rdata'length-1 downto 0);
    variable v_last_rising_edge  : time    := -1 ns;  -- time stamp for clk period checking
  begin
    -- setup_time and hold_time checking
    check_value(config.setup_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, local_proc_call);
    check_value(config.hold_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, local_proc_call);
    check_value(config.setup_time > 0 ns, TB_FAILURE, "Sanity check: Check that setup_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, local_proc_call);
    check_value(config.hold_time > 0 ns, TB_FAILURE, "Sanity check: Check that hold_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, local_proc_call);

    -- If called from sequencer/VVC, show 'axilite_read...' in log
    if ext_proc_call = "" then
      write(v_proc_call, local_proc_call);
    else
      -- If called from other BFM procedure like axilite_expect, log 'axilite_check(..) while executing axilite_read..'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    check_value(v_data_value'length = 32 or v_data_value'length = 64, TB_ERROR, "AXI-lite data width must be either 32 or 64!" & add_msg_delimiter(msg), scope, ID_NEVER, msg_id_panel);

    -- Wait setup_time specified in config record
    wait_until_given_time_before_rising_edge(clk, config.setup_time, config.clock_period);

    axilite_if.read_address_channel.araddr  <= v_normalized_addr;
    axilite_if.read_address_channel.arvalid <= '1';

    for cycle in 0 to config.max_wait_cycles loop

      if axilite_if.read_address_channel.arready = '1' and cycle > 0 then
        axilite_if.read_address_channel.arvalid <= '0';
        axilite_if.read_address_channel.araddr(axilite_if.read_address_channel.araddr'length-1 downto 0)  <= (others => '0');
        axilite_if.read_address_channel.arprot <= to_slv(config.protection_setting);
        v_await_arready := false;
      end if;

      if v_await_arready then
        wait until rising_edge(clk);
        -- check if clk period since last rising edge is within specifications and take a new time stamp
        if v_last_rising_edge > -1 ns then
          check_value_in_range(now - v_last_rising_edge, config.clock_period - config.clock_period_margin, config.clock_period + config.clock_period_margin, config.clock_margin_severity, "clk period not within requirement.");
        end if;
        v_last_rising_edge := now; -- time stamp for clk period checking
      else
        exit;
      end if;
    end loop;

    check_value(not v_await_arready, config.max_wait_cycles_severity, ": Timeout waiting for ARREADY", scope, ID_NEVER, msg_id_panel, v_proc_call.all);

    -- Wait setup_time specified in config record
    wait_until_given_time_before_rising_edge(clk, config.setup_time, config.clock_period);

    axilite_if.read_data_channel.rready <= '1';

    for cycle in 0 to config.max_wait_cycles loop
      if axilite_if.read_data_channel.rvalid = '1' and cycle > 0 then
        v_await_rvalid := false;

        check_value(axilite_if.read_data_channel.rresp, to_slv(config.expected_response), config.expected_response_severity, ": RRESP detected", scope, BIN, AS_IS, ID_NEVER, msg_id_panel, v_proc_call.all);

        v_data_value := axilite_if.read_data_channel.rdata;

        -- Wait hold time specified in config record
        wait_until_given_time_after_rising_edge(clk, config.clock_period/4);

        axilite_if.read_data_channel.rready <= '0';
      end if;

      if v_await_rvalid then
        wait until rising_edge(clk);
        -- check if clk period since last rising edge is within specifications and take a new time stamp
        if v_last_rising_edge > -1 ns then
          check_value_in_range(now - v_last_rising_edge, config.clock_period - config.clock_period_margin, config.clock_period + config.clock_period_margin, config.clock_margin_severity, "clk period not within requirement.");
        end if;
        v_last_rising_edge := now; -- time stamp for clk period checking
      else
        exit;
      end if;
    end loop;

    check_value(not v_await_rvalid, config.max_wait_cycles_severity, ": Timeout waiting for RVALID", scope, ID_NEVER, msg_id_panel, v_proc_call.all);

    data_value := v_data_value;

    if ext_proc_call = "" then -- proc_name = "axilite_read" then
      log(config.id_for_bfm, v_proc_call.all & "=> " & to_string(v_data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else

    end if;
  end procedure axilite_read;

  procedure axilite_check (
    constant addr_value     : in  unsigned;
    constant data_exp       : in  std_logic_vector;
    constant msg            : in  string;
    signal   clk            : in std_logic;
    signal   axilite_if     : inout t_axilite_if;
    constant alert_level    : in  t_alert_level    := error;
    constant scope          : in  string           := C_SCOPE;
    constant msg_id_panel   : in  t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in  t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT
    ) is
    constant proc_name    : string                                         := "axilite_check";
    constant proc_call    : string                                         := "axilite_check(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_data_value : std_logic_vector(axilite_if.write_data_channel.wdata'length-1 downto 0) := (others => '0');
    variable v_check_ok   : boolean;

    -- Normalize to the DUT addr/data widths
    variable v_normalized_data : std_logic_vector(axilite_if.write_data_channel.wdata'length-1 downto 0) :=
      normalize_and_check(data_exp, axilite_if.write_data_channel.wdata, ALLOW_NARROWER, "data", "axilite_if.write_data_channel.wdata", msg);
  begin
    axilite_read(addr_value, v_data_value, msg, clk, axilite_if, scope, msg_id_panel, config, proc_call);

    v_check_ok := true;
    for i in 0 to v_normalized_data'length-1 loop
      if v_normalized_data(i) = '-' or v_normalized_data(i) = v_data_value(i) then
        v_check_ok := true;
      else
        v_check_ok := false;
        exit;
      end if;
    end loop;

    if not v_check_ok then
      alert(alert_level, proc_call & "=> Failed. slv Was " & to_string(v_data_value, HEX, AS_IS, INCL_RADIX) & ". Expected " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
    else
      log(config.id_for_bfm, proc_call & "=> OK, received data = " & to_string(v_normalized_data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;

  end procedure axilite_check;
end package body axilite_bfm_pkg;
