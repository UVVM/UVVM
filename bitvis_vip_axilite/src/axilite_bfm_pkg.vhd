--================================================================================================================================
-- Copyright 2024 UVVM
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================
-- Note : Any functionality not explicitly described in the documentation is subject to change at any time
----------------------------------------------------------------------------------------------------------------------------------

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
  constant C_BFM_SCOPE : string := "AXILITE_BFM";

  -- EXOKAY not supported for AXI-Lite, will raise TB_FAILURE
  type t_xresp is (
    OKAY,
    SLVERR,
    DECERR,
    EXOKAY
  );

  type t_axprot is (
    UNPRIVILEGED_NONSECURE_DATA,
    UNPRIVILEGED_NONSECURE_INSTRUCTION,
    UNPRIVILEGED_SECURE_DATA,
    UNPRIVILEGED_SECURE_INSTRUCTION,
    PRIVILEGED_NONSECURE_DATA,
    PRIVILEGED_NONSECURE_INSTRUCTION,
    PRIVILEGED_SECURE_DATA,
    PRIVILEGED_SECURE_INSTRUCTION
  );

  -- Configuration record to be assigned in the test harness.
  type t_axilite_bfm_config is record
    max_wait_cycles            : natural; -- Used for setting the maximum cycles to wait before an alert is issued when waiting for ready and valid signals from the DUT.
    max_wait_cycles_severity   : t_alert_level; -- The above timeout will have this severity
    clock_period               : time;  -- Period of the clock signal.
    clock_period_margin        : time;  -- Input clock period margin to specified clock_period
    clock_margin_severity      : t_alert_level; -- The above margin will have this severity
    setup_time                 : time;  -- Setup time for generated signals, set to clock_period/4
    hold_time                  : time;  -- Hold time for generated signals, set to clock_period/4
    bfm_sync                   : t_bfm_sync; -- Synchronisation of the BFM procedures, i.e. using clock signals, using setup_time and hold_time.
    match_strictness           : t_match_strictness; -- Matching strictness for std_logic values in check procedures.
    expected_response          : t_xresp; -- Sets the expected response for both read and write transactions.
    expected_response_severity : t_alert_level; -- A response mismatch will have this severity.
    protection_setting         : t_axprot; -- Sets the AXI access permissions (e.g. write to data/instruction, privileged and secure access).
    num_aw_pipe_stages         : natural; -- Write Address Channel pipeline steps.
    num_w_pipe_stages          : natural; -- Write Data Channel pipeline steps.
    num_ar_pipe_stages         : natural; -- Read Address Channel pipeline steps.
    num_r_pipe_stages          : natural; -- Read Data Channel pipeline steps.
    num_b_pipe_stages          : natural; -- Response Channel pipeline steps.
    id_for_bfm                 : t_msg_id; -- The message ID used as a general message ID in the AXI-Lite BFM
    id_for_bfm_wait            : t_msg_id; -- The message ID used for logging waits in the AXI-Lite BFM   -- DEPRECATE: will be removed
    id_for_bfm_poll            : t_msg_id; -- The message ID used for logging polling in the AXI-Lite BFM -- DEPRECATE: will be removed
  end record;

  constant C_AXILITE_BFM_CONFIG_DEFAULT : t_axilite_bfm_config := (
    max_wait_cycles            => 10,
    max_wait_cycles_severity   => TB_FAILURE,
    clock_period               => -1 ns,
    clock_period_margin        => 0 ns,
    clock_margin_severity      => TB_ERROR,
    setup_time                 => -1 ns,
    hold_time                  => -1 ns,
    bfm_sync                   => SYNC_ON_CLOCK_ONLY,
    match_strictness           => MATCH_EXACT,
    expected_response          => OKAY,
    expected_response_severity => TB_FAILURE,
    protection_setting         => UNPRIVILEGED_NONSECURE_DATA,
    num_aw_pipe_stages         => 1,
    num_w_pipe_stages          => 1,
    num_ar_pipe_stages         => 1,
    num_r_pipe_stages          => 1,
    num_b_pipe_stages          => 1,
    id_for_bfm                 => ID_BFM,
    id_for_bfm_wait            => ID_BFM_WAIT,
    id_for_bfm_poll            => ID_BFM_POLL
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
    wdata  : std_logic_vector;
    wstrb  : std_logic_vector;
    wvalid : std_logic;
    --DUT outputs
    wready : std_logic;
  end record;

  type t_axilite_write_response_channel is record
    --DUT inputs
    bready : std_logic;
    --DUT outputs
    bresp  : std_logic_vector(1 downto 0);
    bvalid : std_logic;
  end record;

  type t_axilite_read_address_channel is record
    --DUT inputs
    araddr  : std_logic_vector;
    arvalid : std_logic;
    arprot  : std_logic_vector(2 downto 0); -- [0: '0' - unpriviliged access, '1' - priviliged access; 1: '0' - secure access, '1' - non-secure access, 2: '0' - Data access, '1' - Instruction accesss]
    --DUT outputs
    arready : std_logic;
  end record;

  type t_axilite_read_data_channel is record
    --DUT inputs
    rready : std_logic;
    --DUT outputs
    rdata  : std_logic_vector;
    rresp  : std_logic_vector(1 downto 0);
    rvalid : std_logic;
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
  -- This function returns an AXILITE interface with initialized signals.
  -- All BFM output signals are initialized to 0
  -- All BFM input signals are initialized to Z
  -- awprot and arprot are initialized to UNPRIVILEGED_NONSECURE_DATA
  function init_axilite_if_signals(
    addr_width : natural;
    data_width : natural
  ) return t_axilite_if;

  ------------------------------------------
  -- axilite_write
  ------------------------------------------
  -- This procedure writes data to the AXILITE interface specified in axilite_if
  -- - The protection setting is set to UNPRIVILEGED_NONSECURE_DATA in this procedure
  -- - The byte enable input is set to 1 for all bytes in this procedure
  -- - When the write is completed, a log message is issued with log ID id_for_bfm
  procedure axilite_write(
    constant addr_value   : in unsigned;
    constant data_value   : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   axilite_if   : inout t_axilite_if;
    constant scope        : in string               := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel       := shared_msg_id_panel;
    constant config       : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- axilite_write
  ------------------------------------------
  -- This procedure writes data to the AXILITE interface specified in axilite_if
  -- - When the write is completed, a log message is issued with log ID id_for_bfm
  procedure axilite_write(
    constant addr_value   : in unsigned;
    constant data_value   : in std_logic_vector;
    constant byte_enable  : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   axilite_if   : inout t_axilite_if;
    constant scope        : in string               := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel       := shared_msg_id_panel;
    constant config       : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- axilite_read
  ------------------------------------------
  -- This procedure reads data from the AXILITE interface specified in axilite_if,
  -- and returns the read data in data_value.
  procedure axilite_read(
    constant addr_value    : in unsigned;
    variable data_value    : out std_logic_vector;
    constant msg           : in string;
    signal   clk           : in std_logic;
    signal   axilite_if    : inout t_axilite_if;
    constant scope         : in string               := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel       := shared_msg_id_panel;
    constant config        : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string               := "" -- External proc_call. Overwrite if called from another BFM procedure
  );

  ------------------------------------------
  -- axilite_check
  ------------------------------------------
  -- This procedure reads data from the AXILITE interface specified in axilite_if,
  -- and compares it to the data in data_exp.
  -- - If the received data inconsistent with data_exp, an alert with severity
  --   alert_level is issued.
  -- - If the received data was correct, a log message with ID id_for_bfm is issued.
  procedure axilite_check(
    constant addr_value   : in unsigned;
    constant data_exp     : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   axilite_if   : inout t_axilite_if;
    constant alert_level  : in t_alert_level        := error;
    constant scope        : in string               := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel       := shared_msg_id_panel;
    constant config       : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT
  );

  function axprot_to_slv(
    axprot : t_axprot
  ) return std_logic_vector;

  function xresp_to_slv(
    constant axilite_response_status : in t_xresp;
    constant scope                   : in string         := C_BFM_SCOPE;
    constant msg_id_panel            : in t_msg_id_panel := shared_msg_id_panel
  ) return std_logic_vector;

end package axilite_bfm_pkg;

--=================================================================================================
--=================================================================================================

package body axilite_bfm_pkg is

  ----------------------------------------------------
  -- Support procedures
  ----------------------------------------------------

  function axprot_to_slv(
    axprot : t_axprot
  ) return std_logic_vector is
    variable v_axprot_slv : std_logic_vector(2 downto 0);
  begin
    case axprot is
      when UNPRIVILEGED_SECURE_DATA =>
        v_axprot_slv := "000";
      when PRIVILEGED_SECURE_DATA =>
        v_axprot_slv := "001";
      when UNPRIVILEGED_NONSECURE_DATA =>
        v_axprot_slv := "010";
      when PRIVILEGED_NONSECURE_DATA =>
        v_axprot_slv := "011";
      when UNPRIVILEGED_SECURE_INSTRUCTION =>
        v_axprot_slv := "100";
      when PRIVILEGED_SECURE_INSTRUCTION =>
        v_axprot_slv := "101";
      when UNPRIVILEGED_NONSECURE_INSTRUCTION =>
        v_axprot_slv := "110";
      when PRIVILEGED_NONSECURE_INSTRUCTION =>
        v_axprot_slv := "111";
    end case;
    return v_axprot_slv;
  end function axprot_to_slv;

  function xresp_to_slv(
    constant axilite_response_status : in t_xresp;
    constant scope                   : in string         := C_BFM_SCOPE;
    constant msg_id_panel            : in t_msg_id_panel := shared_msg_id_panel
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

  ----------------------------------------------------
  -- BFM procedures
  ----------------------------------------------------

  function init_axilite_if_signals(
    addr_width : natural;
    data_width : natural
  ) return t_axilite_if is
    variable init_if : t_axilite_if(write_address_channel(awaddr(addr_width - 1 downto 0)),
                                    write_data_channel(wdata(data_width - 1 downto 0),
                                                       wstrb((data_width / 8) - 1 downto 0)),
                                    read_address_channel(araddr(addr_width - 1 downto 0)),
                                    read_data_channel(rdata(data_width - 1 downto 0)));
  begin
    -- Write Address Channel
    init_if.write_address_channel.awaddr  := (init_if.write_address_channel.awaddr'range => '0');
    init_if.write_address_channel.awvalid := '0';
    init_if.write_address_channel.awprot  := axprot_to_slv(UNPRIVILEGED_NONSECURE_DATA); --"010"
    init_if.write_address_channel.awready := 'Z';
    -- Write Data Channel
    init_if.write_data_channel.wdata      := (init_if.write_data_channel.wdata'range => '0');
    init_if.write_data_channel.wstrb      := (init_if.write_data_channel.wstrb'range => '0');
    init_if.write_data_channel.wvalid     := '0';
    init_if.write_data_channel.wready     := 'Z';
    -- Write Response Channel
    init_if.write_response_channel.bready := '0';
    init_if.write_response_channel.bresp  := (init_if.write_response_channel.bresp'range => 'Z');
    init_if.write_response_channel.bvalid := 'Z';
    -- Read Address Channel
    init_if.read_address_channel.araddr   := (init_if.read_address_channel.araddr'range => '0');
    init_if.read_address_channel.arvalid  := '0';
    init_if.read_address_channel.arprot   := axprot_to_slv(UNPRIVILEGED_NONSECURE_DATA); --"010"
    init_if.read_address_channel.arready  := 'Z';
    -- Read Data Channel
    init_if.read_data_channel.rready      := '0';
    init_if.read_data_channel.rdata       := (init_if.read_data_channel.rdata'range => 'Z');
    init_if.read_data_channel.rresp       := (init_if.read_data_channel.rresp'range => 'Z');
    init_if.read_data_channel.rvalid      := 'Z';
    return init_if;
  end function;

  procedure axilite_write(
    constant addr_value   : in unsigned;
    constant data_value   : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   axilite_if   : inout t_axilite_if;
    constant scope        : in string               := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel       := shared_msg_id_panel;
    constant config       : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT
  ) is
    constant C_BYTE_ENABLE : std_logic_vector(axilite_if.write_data_channel.wstrb'length - 1 downto 0) := (others => '1');
  begin
    axilite_write(addr_value, data_value, C_BYTE_ENABLE, msg, clk, axilite_if, scope, msg_id_panel, config);
  end procedure axilite_write;

  procedure axilite_write(
    constant addr_value   : in unsigned;
    constant data_value   : in std_logic_vector;
    constant byte_enable  : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   axilite_if   : inout t_axilite_if;
    constant scope        : in string               := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel       := shared_msg_id_panel;
    constant config       : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT
  ) is
    constant proc_call : string := "axilite_write(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_value, HEX, AS_IS, INCL_RADIX) & ")";

    constant max_pipe_stages : integer := maximum(maximum(config.num_w_pipe_stages, config.num_aw_pipe_stages), config.num_b_pipe_stages);
    variable v_await_awready : boolean := true;
    variable v_await_wready  : boolean := true;
    variable v_await_bvalid  : boolean := true;

    -- Normalize to the DUT addr/data widths
    variable v_normalized_addr      : std_logic_vector(axilite_if.write_address_channel.awaddr'length - 1 downto 0) := normalize_and_check(std_logic_vector(addr_value), axilite_if.write_address_channel.awaddr, ALLOW_NARROWER, "addr", "axilite_if.write_address_channel.awaddr", msg);
    variable v_normalized_data      : std_logic_vector(axilite_if.write_data_channel.wdata'length - 1 downto 0)     := normalize_and_check(data_value, axilite_if.write_data_channel.wdata, ALLOW_NARROWER, "data", "axilite_if.write_data_channel.wdata", msg);
    -- Helper variables
    variable v_time_of_rising_edge  : time                                                                          := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge : time                                                                          := -1 ns; -- time stamp for clk period checking
    variable v_wready               : std_logic;
    variable v_awready              : std_logic;
  begin
    check_value(v_normalized_data'length = 32 or v_normalized_data'length = 64, TB_ERROR, "AXI-lite data width must be either 32 or 64!", scope, ID_NEVER, msg_id_panel);
    if config.bfm_sync = SYNC_WITH_SETUP_AND_HOLD then
      check_value(config.clock_period > -1 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, proc_call);
      check_value(config.setup_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
      check_value(config.hold_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
    end if;

    for cycle in 0 to config.max_wait_cycles loop

      -- Wait according to config.bfm_sync setup
      wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);

      if cycle = config.num_w_pipe_stages then
        axilite_if.write_data_channel.wdata  <= v_normalized_data;
        axilite_if.write_data_channel.wstrb  <= byte_enable;
        axilite_if.write_data_channel.wvalid <= '1';
      end if;

      if cycle = config.num_aw_pipe_stages then
        axilite_if.write_address_channel.awaddr  <= v_normalized_addr;
        axilite_if.write_address_channel.awvalid <= '1';
        axilite_if.write_address_channel.awprot  <= axprot_to_slv(config.protection_setting);
      end if;

      wait until rising_edge(clk);
      if v_time_of_rising_edge = -1 ns then
        v_time_of_rising_edge := now;
      end if;

      check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                                config.clock_period, config.clock_period_margin, config.clock_margin_severity);

      -- Sample ready signals
      v_wready  := axilite_if.write_data_channel.wready;
      v_awready := axilite_if.write_address_channel.awready;
      -- Wait according to config.bfm_sync setup
      wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);

      if v_wready = '1' and cycle >= config.num_w_pipe_stages then
        axilite_if.write_data_channel.wdata  <= (axilite_if.write_data_channel.wdata'range => '0');
        axilite_if.write_data_channel.wstrb  <= (axilite_if.write_data_channel.wstrb'range => '0');
        axilite_if.write_data_channel.wvalid <= '0';
        v_await_wready                       := false;
      end if;

      if v_awready = '1' and cycle >= config.num_aw_pipe_stages then
        axilite_if.write_address_channel.awaddr  <= (axilite_if.write_address_channel.awaddr'range => '0');
        axilite_if.write_address_channel.awvalid <= '0';
        v_await_awready                          := false;
      end if;

      if not v_await_awready and not v_await_wready then
        exit;
      end if;
    end loop;

    check_value(not v_await_wready, config.max_wait_cycles_severity, ": Timeout waiting for WREADY", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(not v_await_awready, config.max_wait_cycles_severity, ": Timeout waiting for AWREADY", scope, ID_NEVER, msg_id_panel, proc_call);

    for cycle in 0 to config.max_wait_cycles loop

      -- Wait according to config.bfm_sync setup
      wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);

      -- Brady - Add support for num_b_pipe_stages
      if cycle = config.num_b_pipe_stages then
        axilite_if.write_response_channel.bready <= '1';
      end if;

      wait until rising_edge(clk);
      if v_time_of_rising_edge = -1 ns then
        v_time_of_rising_edge := now;
      end if;

      if axilite_if.write_response_channel.bvalid = '1' and cycle >= config.num_b_pipe_stages then
        check_value(axilite_if.write_response_channel.bresp, xresp_to_slv(config.expected_response), config.expected_response_severity, ": BRESP detected", scope, BIN, KEEP_LEADING_0, ID_NEVER, msg_id_panel, proc_call);
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);

        axilite_if.write_response_channel.bready <= '0';
        v_await_bvalid                           := false;
      end if;

      if not v_await_bvalid then
        exit;
      end if;
    end loop;

    check_value(not v_await_bvalid, config.max_wait_cycles_severity, ": Timeout waiting for BVALID", scope, ID_NEVER, msg_id_panel, proc_call);

    log(config.id_for_bfm, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure axilite_write;

  procedure axilite_read(
    constant addr_value    : in unsigned;
    variable data_value    : out std_logic_vector;
    constant msg           : in string;
    signal   clk           : in std_logic;
    signal   axilite_if    : inout t_axilite_if;
    constant scope         : in string               := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel       := shared_msg_id_panel;
    constant config        : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string               := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    constant local_proc_name : string := "axilite_read"; -- Local proc_name; used if called from sequncer or VVC
    constant local_proc_call : string := local_proc_name & "(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ")"; -- Local proc_call; used if called from sequncer or VVC

    -- Normalize to the DUT addr/data widths
    variable v_normalized_addr      : std_logic_vector(axilite_if.read_address_channel.araddr'length - 1 downto 0) := normalize_and_check(std_logic_vector(addr_value), axilite_if.read_address_channel.araddr, ALLOW_NARROWER, "addr", "axilite_if.read_address_channel.araddr", msg);
    -- Helper variables
    variable v_proc_call            : line;
    variable v_await_arready        : boolean                                                                      := true;
    variable v_await_rvalid         : boolean                                                                      := true;
    variable v_data_value           : std_logic_vector(axilite_if.read_data_channel.rdata'length - 1 downto 0);
    variable v_time_of_rising_edge  : time                                                                         := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge : time                                                                         := -1 ns; -- time stamp for clk period checking

  begin
    if config.bfm_sync = SYNC_WITH_SETUP_AND_HOLD then
      check_value(config.clock_period > -1 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, local_proc_call);
      check_value(config.setup_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, local_proc_call);
      check_value(config.hold_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, local_proc_call);
    end if;

    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC, log 'axilite_read...'
      write(v_proc_call, local_proc_call);
    else
      -- Called from another BFM procedure, log 'ext_proc_call while executing axilite_read...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    check_value(v_data_value'length = 32 or v_data_value'length = 64, TB_ERROR, "AXI-lite data width must be either 32 or 64!" & add_msg_delimiter(msg), scope, ID_NEVER, msg_id_panel);

    for cycle in 0 to config.max_wait_cycles loop

      -- Wait according to config.bfm_sync setup
      wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);

      -- Brady - Add support for num_ar_pipe_stages
      if cycle = config.num_ar_pipe_stages then
        axilite_if.read_address_channel.araddr  <= v_normalized_addr;
        axilite_if.read_address_channel.arprot  <= axprot_to_slv(config.protection_setting);
        axilite_if.read_address_channel.arvalid <= '1';
      end if;

      wait until rising_edge(clk);
      if v_time_of_rising_edge = -1 ns then
        v_time_of_rising_edge := now;
      end if;

      check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                                config.clock_period, config.clock_period_margin, config.clock_margin_severity);

      if axilite_if.read_address_channel.arready = '1' and cycle >= config.num_ar_pipe_stages then
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
        axilite_if.read_address_channel.araddr  <= (axilite_if.read_address_channel.araddr'range => '0');
        axilite_if.read_address_channel.arprot  <= (others => '0');
        axilite_if.read_address_channel.arvalid <= '0';
        v_await_arready                         := false;
      end if;

      if not v_await_arready then
        exit;
      end if;
    end loop;

    check_value(not v_await_arready, config.max_wait_cycles_severity, ": Timeout waiting for ARREADY", scope, ID_NEVER, msg_id_panel, v_proc_call.all);

    for cycle in 0 to config.max_wait_cycles loop

      -- Wait according to config.bfm_sync setup
      wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);

      -- Brady - Add support for num_r_pipe_stages
      if cycle = config.num_r_pipe_stages then
        axilite_if.read_data_channel.rready <= '1';
      end if;

      wait until rising_edge(clk);
      if v_time_of_rising_edge = -1 ns then
        v_time_of_rising_edge := now;
      end if;

      if axilite_if.read_data_channel.rvalid = '1' and cycle >= config.num_r_pipe_stages then
        v_await_rvalid                      := false;
        check_value(axilite_if.read_data_channel.rresp, xresp_to_slv(config.expected_response), config.expected_response_severity, ": RRESP detected", scope, BIN, KEEP_LEADING_0, ID_NEVER, msg_id_panel, v_proc_call.all);
        v_data_value                        := axilite_if.read_data_channel.rdata;
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
        axilite_if.read_data_channel.rready <= '0';
      end if;

      if not v_await_rvalid then
        exit;
      end if;
    end loop;

    check_value(not v_await_rvalid, config.max_wait_cycles_severity, ": Timeout waiting for RVALID", scope, ID_NEVER, msg_id_panel, v_proc_call.all);

    data_value := v_data_value;

    if ext_proc_call = "" then
      log(config.id_for_bfm, v_proc_call.all & "=> " & to_string(v_data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
    -- Log will be handled by calling procedure (e.g. axilite_check)
    end if;

    DEALLOCATE(v_proc_call);
  end procedure axilite_read;

  procedure axilite_check(
    constant addr_value   : in unsigned;
    constant data_exp     : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   axilite_if   : inout t_axilite_if;
    constant alert_level  : in t_alert_level        := error;
    constant scope        : in string               := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel       := shared_msg_id_panel;
    constant config       : in t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT
  ) is
    constant proc_call     : string                                                                    := "axilite_check(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_data_value  : std_logic_vector(axilite_if.write_data_channel.wdata'length - 1 downto 0) := (others => '0');
    variable v_check_ok    : boolean                                                                   := true;
    variable v_alert_radix : t_radix;

    -- Normalize to the DUT addr/data widths
    variable v_normalized_data : std_logic_vector(axilite_if.write_data_channel.wdata'length - 1 downto 0) := normalize_and_check(data_exp, axilite_if.write_data_channel.wdata, ALLOW_NARROWER, "data", "axilite_if.write_data_channel.wdata", msg);
  begin
    axilite_read(addr_value, v_data_value, msg, clk, axilite_if, scope, msg_id_panel, config, proc_call);

    for i in v_normalized_data'range loop
      -- Allow don't care in expected value and use match strictness from config for comparison
      if v_normalized_data(i) = '-' or check_value(v_data_value(i), v_normalized_data(i), config.match_strictness, NO_ALERT, msg, scope, ID_NEVER) then
        v_check_ok := true;
      else
        v_check_ok := false;
        exit;
      end if;
    end loop;

    if not v_check_ok then
      -- Use binary representation when mismatch is due to weak signals
      v_alert_radix := BIN when config.match_strictness = MATCH_EXACT and check_value(v_data_value, v_normalized_data, MATCH_STD, NO_ALERT, msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER) else HEX;
      alert(alert_level, proc_call & "=> Failed. Was " & to_string(v_data_value, v_alert_radix, AS_IS, INCL_RADIX) & ". Expected " & to_string(v_normalized_data, v_alert_radix, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
    else
      log(config.id_for_bfm, proc_call & "=> OK, received data = " & to_string(v_normalized_data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;

  end procedure axilite_check;
end package body axilite_bfm_pkg;
