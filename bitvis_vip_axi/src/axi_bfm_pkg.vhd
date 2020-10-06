--================================================================================================================================
-- Copyright 2020 Bitvis
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
package axi_bfm_pkg is

  --===============================================================================================
  -- Types and constants for AXI BFMs
  --===============================================================================================
  constant C_SCOPE : string := "AXI_BFM";

  constant C_EMPTY_SLV_ARRAY : t_slv_array(0 to 0)(0 downto 0) := (others=>"U");

  type t_xresp is (
    OKAY,
    EXOKAY,
    SLVERR,
    DECERR,
    ILLEGAL
  );

  type t_xresp_array is array (natural range <>) of t_xresp;
  
  constant C_EMPTY_XRESP_ARRAY : t_xresp_array(0 to 0) := (others=>ILLEGAL);

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

  type t_axburst is (
    FIXED,
    INCR,
    WRAP
  );

  type t_axlock is (
    NORMAL,
    EXCLUSIVE
  );

  -- Configuration record to be assigned in the test harness.
  type t_axi_bfm_config is
  record
    max_wait_cycles             : natural;                    -- Used for setting the maximum cycles to wait before an alert is issued when waiting for ready and valid signals from the DUT.
    max_wait_cycles_severity    : t_alert_level;              -- The above timeout will have this severity
    clock_period                : time;                       -- Period of the clock signal.
    clock_period_margin         : time;                       -- Input clock period margin to specified clock_period
    clock_margin_severity       : t_alert_level;              -- The above margin will have this severity
    setup_time                  : time;                       -- Setup time for generated signals, set to clock_period/4
    hold_time                   : time;                       -- Hold time for generated signals, set to clock_period/4
    bfm_sync                    : t_bfm_sync;                 -- Synchronisation of the BFM procedures, i.e. using clock signals, using setup_time and hold_time.
    match_strictness            : t_match_strictness;         -- Matching strictness for std_logic values in check procedures.
    num_aw_pipe_stages          : natural;                    -- Write Address Channel pipeline steps.
    num_w_pipe_stages           : natural;                    -- Write Data Channel pipeline steps.
    num_ar_pipe_stages          : natural;                    -- Read Address Channel pipeline steps.
    num_r_pipe_stages           : natural;                    -- Read Data Channel pipeline steps.
    num_b_pipe_stages           : natural;                    -- Response Channel pipeline steps.
    id_for_bfm                  : t_msg_id;                   -- The message ID used as a general message ID in the AXI BFM
    id_for_bfm_wait             : t_msg_id;                   -- The message ID used for logging waits in the AXI BFM
    id_for_bfm_poll             : t_msg_id;                   -- The message ID used for logging polling in the AXI BFM
  end record;

  constant C_AXI_BFM_CONFIG_DEFAULT : t_axi_bfm_config := (
    max_wait_cycles             => 1000,
    max_wait_cycles_severity    => TB_FAILURE,
    clock_period                => -1 ns,
    clock_period_margin         => 0 ns,
    clock_margin_severity       => TB_ERROR,
    setup_time                  => -1 ns,
    hold_time                   => -1 ns,
    bfm_sync                    => SYNC_ON_CLOCK_ONLY,
    match_strictness            => MATCH_EXACT,
    num_aw_pipe_stages          => 1,
    num_w_pipe_stages           => 1,
    num_ar_pipe_stages          => 1,
    num_r_pipe_stages           => 1,
    num_b_pipe_stages           => 1,
    id_for_bfm                  => ID_BFM,
    id_for_bfm_wait             => ID_BFM_WAIT,
    id_for_bfm_poll             => ID_BFM_POLL
    );

  -- AXI Interface signals
  type t_axi_write_address_channel is record
    -- Source: Master
    awid      : std_logic_vector;
    awaddr    : std_logic_vector;
    awlen     : std_logic_vector(7 downto 0);
    awsize    : std_logic_vector(2 downto 0);
    awburst   : std_logic_vector(1 downto 0);
    awlock    : std_logic;
    awcache   : std_logic_vector(3 downto 0);
    awprot    : std_logic_vector(2 downto 0);
    awqos     : std_logic_vector(3 downto 0);
    awregion  : std_logic_vector(3 downto 0);
    awuser    : std_logic_vector;
    awvalid   : std_logic;
    -- Source: Slave
    awready   : std_logic;
  end record;

  type t_axi_write_data_channel is record
    -- Source: Master
    wdata   : std_logic_vector;
    wstrb   : std_logic_vector;
    wlast   : std_logic;
    wuser   : std_logic_vector;
    wvalid  : std_logic;
    -- Source: Slave
    wready  : std_logic;
  end record;

  type t_axi_write_response_channel is record
    -- Source: Slave
    bid     : std_logic_vector;
    bresp   : std_logic_vector(1 downto 0);
    buser   : std_logic_vector;
    bvalid  : std_logic;
    -- Source: Master
    bready  : std_logic;
  end record;

  type t_axi_read_address_channel is record
    -- Source: Master
    arid      : std_logic_vector;
    araddr    : std_logic_vector;
    arlen     : std_logic_vector(7 downto 0);
    arsize    : std_logic_vector(2 downto 0);
    arburst   : std_logic_vector(1 downto 0);
    arlock    : std_logic;
    arcache   : std_logic_vector(3 downto 0);
    arprot    : std_logic_vector(2 downto 0);
    arqos     : std_logic_vector(3 downto 0);
    arregion  : std_logic_vector(3 downto 0);
    aruser    : std_logic_vector;
    arvalid   : std_logic;
    -- Source: Slave
    arready   : std_logic;
  end record;

  type t_axi_read_data_channel is record
    -- Source: Slave
    rid     : std_logic_vector;
    rdata   : std_logic_vector;
    rresp   : std_logic_vector(1 downto 0);
    rlast   : std_logic;
    ruser   : std_logic_vector;
    rvalid  : std_logic;
    -- Source: Master
    rready  : std_logic;
  end record;

  type t_axi_if is record
    write_address_channel  : t_axi_write_address_channel;
    write_data_channel     : t_axi_write_data_channel;
    write_response_channel : t_axi_write_response_channel;
    read_address_channel   : t_axi_read_address_channel;
    read_data_channel      : t_axi_read_data_channel;
  end record;

  --===============================================================================================
  -- BFM procedures
  --===============================================================================================

  ------------------------------------------
  -- init_axi_if_signals
  ------------------------------------------
  -- - This function returns an AXI interface with initialized signals.
  -- - All AXI input signals are initialized to 0
  -- - All AXI output signals are initialized to Z
  function init_axi_if_signals(
    addr_width : natural;
    data_width : natural;
    id_width   : natural;
    user_width : natural
    ) return t_axi_if;

  function axprot_to_slv(
    axprot : t_axprot
  ) return std_logic_vector;

  function xresp_to_slv(
    xresp : t_xresp
  ) return std_logic_vector;

  function slv_to_xresp(
    value : std_logic_vector(1 downto 0)
  ) return t_xresp;

  function axburst_to_slv(
    axburst : t_axburst
  ) return std_logic_vector;

  function bytes_to_axsize(
    bytes : positive
  ) return std_logic_vector;

  function axlock_to_sl(
    axlock : t_axlock
  ) return std_logic;

  ------------------------------------------
  -- axi_write
  ------------------------------------------
  -- This procedure writes data to the AXI interface specified in axi_if
  -- - When the write is completed, a log message is issued with log ID id_for_bfm
  procedure axi_write (
    constant awid_value         : in    std_logic_vector              := "";
    constant awaddr_value       : in    unsigned;
    constant awlen_value        : in    unsigned(7 downto 0)          := (others=>'0');
    constant awsize_value       : in    integer range 1 to 128        := 4;
    constant awburst_value      : in    t_axburst                     := INCR;
    constant awlock_value       : in    t_axlock                      := NORMAL;
    constant awcache_value      : in    std_logic_vector(3 downto 0)  := (others=>'0');
    constant awprot_value       : in    t_axprot                      := UNPRIVILEGED_NONSECURE_DATA;
    constant awqos_value        : in    std_logic_vector(3 downto 0)  := (others=>'0');
    constant awregion_value     : in    std_logic_vector(3 downto 0)  := (others=>'0');
    constant awuser_value       : in    std_logic_vector              := "";
    constant wdata_value        : in    t_slv_array;
    constant wstrb_value        : in    t_slv_array                   := C_EMPTY_SLV_ARRAY;
    constant wuser_value        : in    t_slv_array                   := C_EMPTY_SLV_ARRAY;
    variable buser_value        : out   std_logic_vector;
    variable bresp_value        : out   t_xresp;
    constant msg                : in    string;
    signal   clk                : in    std_logic;
    signal   axi_if             : inout t_axi_if;
    constant scope              : in    string                        := C_SCOPE;
    constant msg_id_panel       : in    t_msg_id_panel                := shared_msg_id_panel;
    constant config             : in    t_axi_bfm_config              := C_AXI_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- axi_read
  ------------------------------------------
  -- This procedure reads data from the AXI interface specified in axi_if,
  -- and returns the read data in rdata_value.
  procedure axi_read (
    constant arid_value     : in    std_logic_vector              := "";
    constant araddr_value   : in    unsigned;
    constant arlen_value    : in    unsigned(7 downto 0)          := (others=>'0');
    constant arsize_value   : in    integer range 1 to 128        := 4;
    constant arburst_value  : in    t_axburst                     := INCR;
    constant arlock_value   : in    t_axlock                      := NORMAL;
    constant arcache_value  : in    std_logic_vector(3 downto 0)  := (others=>'0');
    constant arprot_value   : in    t_axprot                      := UNPRIVILEGED_NONSECURE_DATA;
    constant arqos_value    : in    std_logic_vector(3 downto 0)  := (others=>'0');
    constant arregion_value : in    std_logic_vector(3 downto 0)  := (others=>'0');
    constant aruser_value   : in    std_logic_vector              := "";
    variable rdata_value    : out   t_slv_array;
    variable rresp_value    : out   t_xresp_array;
    variable ruser_value    : out   t_slv_array;
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axi_if         : inout t_axi_if;
    constant scope          : in    string                        := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel                := shared_msg_id_panel;
    constant config         : in    t_axi_bfm_config              := C_AXI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call  : in    string                        := ""  -- External proc_call. Overwrite if called from another BFM procedure
  );

  ------------------------------------------
  -- axi_check
  ------------------------------------------
  -- This procedure reads data from the AXI interface specified in axi_if,
  -- and compares it to the data in data_exp.
  -- - If the received data inconsistent with data_exp, an alert with severity
  --   alert_level is issued.
  -- - If the received data was correct, a log message with ID id_for_bfm is issued.
  procedure axi_check (
    constant arid_value     : in    std_logic_vector              := "";
    constant araddr_value   : in    unsigned;
    constant arlen_value    : in    unsigned(7 downto 0)          := (others=>'0');
    constant arsize_value   : in    integer range 1 to 128        := 4;
    constant arburst_value  : in    t_axburst                     := INCR;
    constant arlock_value   : in    t_axlock                      := NORMAL;
    constant arcache_value  : in    std_logic_vector(3 downto 0)  := (others=>'0');
    constant arprot_value   : in    t_axprot                      := UNPRIVILEGED_NONSECURE_DATA;
    constant arqos_value    : in    std_logic_vector(3 downto 0)  := (others=>'0');
    constant arregion_value : in    std_logic_vector(3 downto 0)  := (others=>'0');
    constant aruser_value   : in    std_logic_vector              := "";
    constant rdata_exp      : in    t_slv_array;
    constant rresp_exp      : in    t_xresp_array                 := C_EMPTY_XRESP_ARRAY;
    constant ruser_exp      : in    t_slv_array                   := C_EMPTY_SLV_ARRAY;
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axi_if         : inout t_axi_if;
    constant alert_level    : in    t_alert_level                 := error;
    constant scope          : in    string                        := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel                := shared_msg_id_panel;
    constant config         : in    t_axi_bfm_config              := C_AXI_BFM_CONFIG_DEFAULT
  );

end package axi_bfm_pkg;


--=================================================================================================
--=================================================================================================

package body axi_bfm_pkg is

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
    xresp : t_xresp
  ) return std_logic_vector is
    variable v_xresp_slv : std_logic_vector(1 downto 0);
  begin
    case xresp is
      when OKAY =>
        v_xresp_slv := "00";
      when SLVERR =>
        v_xresp_slv := "10";
      when DECERR =>
        v_xresp_slv := "11";
      when EXOKAY =>
        v_xresp_slv := "01";
      when ILLEGAL =>
        v_xresp_slv := "XX";
    end case;
    return v_xresp_slv;
  end function xresp_to_slv;

  function slv_to_xresp(
    value : std_logic_vector(1 downto 0)
  ) return t_xresp is
  begin
    case value is
      when "00" =>
        return OKAY;
      when "01" =>
        return EXOKAY;
      when "10" =>
        return SLVERR;
      when "11" =>
        return DECERR;
      when others =>
        return ILLEGAL;
    end case;
  end function slv_to_xresp;

  function axburst_to_slv(
    axburst : t_axburst
  ) return std_logic_vector is
    variable v_axburst_slv : std_logic_vector(1 downto 0);
  begin
    case axburst is
      when FIXED =>
        v_axburst_slv := "00";
      when INCR =>
        v_axburst_slv := "01";
      when WRAP =>
        v_axburst_slv := "10";
    end case;
    return v_axburst_slv;
  end function axburst_to_slv;

  function bytes_to_axsize(
    constant bytes : positive
  ) return std_logic_vector is
    variable v_return_value : std_logic_vector(2 downto 0);
  begin
    case bytes is
      when 1 =>
        v_return_value := "000";
      when 2 =>
        v_return_value := "001";
      when 4 =>
        v_return_value := "010";
      when 8 =>
        v_return_value := "011";
      when 16 =>
        v_return_value := "100";
      when 32 =>
        v_return_value := "101";
      when 64 =>
        v_return_value := "110";
      when 128 =>
        v_return_value := "111";
      when others =>
        tb_error(to_string(bytes) & " is not a valid number of bytes for AxSISE. Need to be 2^n where n is between 0 and 7", C_SCOPE);
        v_return_value := "XXX";
    end case;
    return v_return_value;
  end function bytes_to_axsize;

  function axlock_to_sl(
    constant axlock : t_axlock
  ) return std_logic is
  begin
    case axlock is
      when NORMAL =>
        return '0';
      when EXCLUSIVE =>
        return '1';
    end case;
  end function axlock_to_sl;

  ----------------------------------------------------
  -- BFM procedures
  ----------------------------------------------------

  function init_axi_if_signals(
    addr_width : natural;
    data_width : natural;
    id_width   : natural;
    user_width : natural
  ) return t_axi_if is
    variable init_if : t_axi_if(write_address_channel( awid(   id_width      -1 downto 0),
                                                       awaddr( addr_width    -1 downto 0),
                                                       awuser( user_width    -1 downto 0)),
                                write_data_channel(    wdata(  data_width    -1 downto 0),
                                                       wstrb(( data_width/8) -1 downto 0),
                                                       wuser(  user_width    -1 downto 0)),
                                write_response_channel(bid(    id_width      -1 downto 0),
                                                       buser(  user_width    -1 downto 0)),
                                read_address_channel(  arid(   id_width      -1 downto 0),
                                                       araddr( addr_width    -1 downto 0),
                                                       aruser( user_width    -1 downto 0)),
                                read_data_channel(     rid(    id_width      -1 downto 0),
                                                       rdata(  data_width    -1 downto 0),
                                                       ruser(  user_width    -1 downto 0)));
  begin
    -- Write Address Channel
    init_if.write_address_channel.awid      := (others=>'0');
    init_if.write_address_channel.awaddr    := (others=>'0');
    init_if.write_address_channel.awlen     := (others=>'0');
    init_if.write_address_channel.awsize    := (others=>'0');
    init_if.write_address_channel.awburst   := (others=>'0');
    init_if.write_address_channel.awlock    := '0';
    init_if.write_address_channel.awcache   := (others=>'0');
    init_if.write_address_channel.awprot    := (others=>'0');
    init_if.write_address_channel.awqos     := (others=>'0');
    init_if.write_address_channel.awregion  := (others=>'0');
    init_if.write_address_channel.awuser    := (others=>'0');
    init_if.write_address_channel.awvalid   := '0';
    init_if.write_address_channel.awready   := 'Z';
    -- Write Data Channel
    init_if.write_data_channel.wdata   := (others=>'0');
    init_if.write_data_channel.wstrb   := (others=>'0');
    init_if.write_data_channel.wlast   := '0';
    init_if.write_data_channel.wuser   := (others=>'0');
    init_if.write_data_channel.wvalid  := '0';
    init_if.write_data_channel.wready  := 'Z';
    -- Write Response Channel
    init_if.write_response_channel.bid    := (others=>'Z');
    init_if.write_response_channel.bresp  := (others=>'Z');
    init_if.write_response_channel.buser  := (others=>'Z');
    init_if.write_response_channel.bvalid := 'Z';
    init_if.write_response_channel.bready := '0';
    -- Read Address Channel
    init_if.read_address_channel.arid     := (others=>'0');
    init_if.read_address_channel.araddr   := (others=>'0');
    init_if.read_address_channel.arlen    := (others=>'0');
    init_if.read_address_channel.arsize   := (others=>'0');
    init_if.read_address_channel.arburst  := (others=>'0');
    init_if.read_address_channel.arlock   := '0';
    init_if.read_address_channel.arcache  := (others=>'0');
    init_if.read_address_channel.arprot   := (others=>'0');
    init_if.read_address_channel.arqos    := (others=>'0');
    init_if.read_address_channel.arregion := (others=>'0');
    init_if.read_address_channel.aruser   := (others=>'0');
    init_if.read_address_channel.arvalid  := '0';
    init_if.read_address_channel.arready  := 'Z';
    -- Read Data Channel
    init_if.read_data_channel.rid    := (others=>'Z');
    init_if.read_data_channel.rdata  := (others=>'Z');
    init_if.read_data_channel.rresp  := (others=>'Z');
    init_if.read_data_channel.rlast  := 'Z';
    init_if.read_data_channel.ruser  := (others=>'Z');
    init_if.read_data_channel.rvalid := 'Z';
    init_if.read_data_channel.rready := '0';
    return init_if;
  end function;

  procedure axi_write (
    constant awid_value         : in    std_logic_vector              := "";
    constant awaddr_value       : in    unsigned;
    constant awlen_value        : in    unsigned(7 downto 0)          := (others=>'0');
    constant awsize_value       : in    integer range 1 to 128        := 4;
    constant awburst_value      : in    t_axburst                     := INCR;
    constant awlock_value       : in    t_axlock                      := NORMAL;
    constant awcache_value      : in    std_logic_vector(3 downto 0)  := (others=>'0');
    constant awprot_value       : in    t_axprot                      := UNPRIVILEGED_NONSECURE_DATA;
    constant awqos_value        : in    std_logic_vector(3 downto 0)  := (others=>'0');
    constant awregion_value     : in    std_logic_vector(3 downto 0)  := (others=>'0');
    constant awuser_value       : in    std_logic_vector              := "";
    constant wdata_value        : in    t_slv_array;
    constant wstrb_value        : in    t_slv_array                   := C_EMPTY_SLV_ARRAY;
    constant wuser_value        : in    t_slv_array                   := C_EMPTY_SLV_ARRAY;
    variable buser_value        : out   std_logic_vector;
    variable bresp_value        : out   t_xresp;
    constant msg                : in    string;
    signal   clk                : in    std_logic;
    signal   axi_if             : inout t_axi_if;
    constant scope              : in    string                        := C_SCOPE;
    constant msg_id_panel       : in    t_msg_id_panel                := shared_msg_id_panel;
    constant config             : in    t_axi_bfm_config              := C_AXI_BFM_CONFIG_DEFAULT
  ) is 
    constant proc_call : string := "axi_write(A:" & to_string(awaddr_value, HEX, AS_IS, INCL_RADIX) &
                                   ", " & to_string(wdata_value, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_await_awready : boolean := true;
    variable v_await_wready  : boolean := true;
    variable v_await_bvalid  : boolean := true;
    -- Normalize to the DUT addr/data widths
    variable v_normalized_addr : std_logic_vector(axi_if.write_address_channel.awaddr'length-1 downto 0) :=
      normalize_and_check(std_logic_vector(awaddr_value), axi_if.write_address_channel.awaddr, ALLOW_WIDER_NARROWER, "awaddr", "axi_if.write_address_channel.awaddr", msg);
    variable v_normalized_data : std_logic_vector(axi_if.write_data_channel.wdata'length-1 downto 0) :=
      normalize_and_check(wdata_value(0), axi_if.write_data_channel.wdata, ALLOW_WIDER_NARROWER, "wdata", "axi_if.write_data_channel.wdata", msg);
    -- Variables for the unconstrained inputs
    variable v_awid_value   : std_logic_vector(axi_if.write_address_channel.awid'length-1 downto 0);
    variable v_awuser_value : std_logic_vector(axi_if.write_address_channel.awuser'length-1 downto 0);
    variable v_wstrb_value  : t_slv_array(0 to to_integer(unsigned(awlen_value)))(axi_if.write_data_channel.wstrb'length-1 downto 0);
    variable v_wuser_value  : t_slv_array(0 to to_integer(unsigned(awlen_value)))(axi_if.write_data_channel.wuser'length-1 downto 0);
    -- Helper variables
    variable v_time_of_rising_edge    : time := -1 ns;  -- time stamp for clk period checking
    variable v_time_of_falling_edge   : time := -1 ns;  -- time stamp for clk period checking
    variable v_wready                 : std_logic;
    variable v_awready                : std_logic;
  begin
    -- Setting default values
    if awid_value'length = 0 then
      v_awid_value := (others=>'0'); -- Default value
    else
      v_awid_value := normalize_and_check(awid_value, axi_if.write_address_channel.awid, ALLOW_WIDER_NARROWER, "awid", "axi_if.write_address_channel.awid", msg);
    end if;

    if awuser_value'length = 0 then
      v_awuser_value := (others=>'0'); -- Default value
    else
      v_awuser_value := normalize_and_check(awuser_value, axi_if.write_address_channel.awuser, ALLOW_WIDER_NARROWER, "awuser", "axi_if.write_address_channel.awuser", msg);
    end if;

    if wstrb_value'length = 1 and wstrb_value(0)'length = 1 and wstrb_value(0) = "U" then
      v_wstrb_value := (others=>(others=>'1')); -- Default value
    else
      v_wstrb_value := normalize_and_check(wstrb_value, v_wstrb_value, ALLOW_WIDER_NARROWER, "wstrb", "v_wstrb_value", msg);
    end if;

    if wuser_value'length = 1 and wuser_value(0)'length = 1 and wuser_value(0) = "U" then
      v_wuser_value := (others=>(others=>'0')); -- Default value
    else
      v_wuser_value := normalize_and_check(wuser_value, v_wuser_value, ALLOW_WIDER_NARROWER, "wuser", "v_wuser_value", msg);
    end if;

    if config.bfm_sync = SYNC_WITH_SETUP_AND_HOLD then
      check_value(config.clock_period > -1 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, proc_call);
      check_value(config.setup_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
      check_value(config.hold_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
    end if;

    for write_transfer_num in 0 to to_integer(unsigned(awlen_value)) loop
      for cycle in 0 to config.max_wait_cycles loop
        
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);

        if cycle = config.num_w_pipe_stages then
          v_normalized_data := normalize_and_check(wdata_value(write_transfer_num), axi_if.write_data_channel.wdata, ALLOW_WIDER_NARROWER, "wdata", "axi_if.write_data_channel.wdata", msg);
          axi_if.write_data_channel.wdata  <= v_normalized_data;
          axi_if.write_data_channel.wstrb  <= v_wstrb_value(write_transfer_num);
          axi_if.write_data_channel.wuser  <= v_wuser_value(write_transfer_num);
          axi_if.write_data_channel.wvalid <= '1';
          if write_transfer_num = unsigned(awlen_value) then
            axi_if.write_data_channel.wlast <= '1';
          end if;
        end if;

        if cycle = config.num_aw_pipe_stages and write_transfer_num = 0 then
          axi_if.write_address_channel.awid     <= v_awid_value;
          axi_if.write_address_channel.awaddr   <= v_normalized_addr;
          axi_if.write_address_channel.awlen    <= std_logic_vector(awlen_value);
          axi_if.write_address_channel.awsize   <= bytes_to_axsize(awsize_value);
          axi_if.write_address_channel.awburst  <= axburst_to_slv(awburst_value);
          axi_if.write_address_channel.awlock   <= axlock_to_sl(awlock_value);
          axi_if.write_address_channel.awcache  <= awcache_value;
          axi_if.write_address_channel.awprot   <= axprot_to_slv(awprot_value);
          axi_if.write_address_channel.awqos    <= awqos_value;
          axi_if.write_address_channel.awregion <= awregion_value;
          axi_if.write_address_channel.awuser   <= v_awuser_value;
          axi_if.write_address_channel.awvalid  <= '1';
        end if;

        wait until rising_edge(clk);
        if v_time_of_rising_edge =  -1 ns then
          v_time_of_rising_edge := now;
        end if;

        check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge, 
                                  config.clock_period, config.clock_period_margin, config.clock_margin_severity);

        -- Sample ready signals
        v_wready  := axi_if.write_data_channel.wready;
        v_awready := axi_if.write_address_channel.awready;
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
    
        if v_wready = '1' and cycle >= config.num_w_pipe_stages then
          axi_if.write_data_channel.wdata  <= (axi_if.write_data_channel.wdata'range => '0');
          axi_if.write_data_channel.wstrb  <= (axi_if.write_data_channel.wstrb'range => '0');
          axi_if.write_data_channel.wlast  <= '0';
          axi_if.write_data_channel.wuser  <= (axi_if.write_data_channel.wuser'range => '0');
          axi_if.write_data_channel.wvalid <= '0';
          v_await_wready := false;
        end if;

        if v_awready = '1' and cycle >= config.num_aw_pipe_stages then
          axi_if.write_address_channel.awid     <= (axi_if.write_address_channel.awid'range => '0');
          axi_if.write_address_channel.awaddr   <= (axi_if.write_address_channel.awaddr'range => '0');
          axi_if.write_address_channel.awlen    <= (others=>'0');
          axi_if.write_address_channel.awsize   <= (others=>'0');
          axi_if.write_address_channel.awburst  <= (others=>'0');
          axi_if.write_address_channel.awlock   <= '0';
          axi_if.write_address_channel.awcache  <= (others=>'0');
          axi_if.write_address_channel.awprot   <= (others=>'0');
          axi_if.write_address_channel.awqos    <= (others=>'0');
          axi_if.write_address_channel.awregion <= (others=>'0');
          axi_if.write_address_channel.awuser   <= (axi_if.write_address_channel.awuser'range => '0');
          axi_if.write_address_channel.awvalid  <= '0';
          v_await_awready := false;
        end if;

        if not v_await_awready and not v_await_wready then
          exit;
        end if;
      end loop;

      check_value(not v_await_wready, config.max_wait_cycles_severity, ": Timeout waiting for WREADY", scope, ID_NEVER, msg_id_panel, proc_call);
      check_value(not v_await_awready, config.max_wait_cycles_severity, ": Timeout waiting for AWREADY", scope, ID_NEVER, msg_id_panel, proc_call);

      v_await_wready := true;
    end loop;

    for cycle in 0 to config.max_wait_cycles loop

      -- Wait according to config.bfm_sync setup
      wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);

      -- Brady - Add support for num_b_pipe_stages
      if cycle = config.num_b_pipe_stages then
          axi_if.write_response_channel.bready <= '1';
      end if;

      wait until rising_edge(clk);
      if v_time_of_rising_edge = -1 ns then
        v_time_of_rising_edge := now;
      end if;

      if axi_if.write_response_channel.bvalid = '1' and cycle >= config.num_b_pipe_stages then
        -- Checking response
        check_value(axi_if.write_response_channel.bid, v_awid_value, error, "Checking BID", scope, BIN, KEEP_LEADING_0, ID_NEVER, msg_id_panel, proc_call);
        buser_value := normalize_and_check(axi_if.write_response_channel.buser, buser_value, ALLOW_WIDER_NARROWER, "axi_if.write_response_channel.buser", "buser_value", msg);
        bresp_value := slv_to_xresp(axi_if.write_response_channel.bresp);
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);

        axi_if.write_response_channel.bready <= '0';
        v_await_bvalid := false;
      end if;

      if not v_await_bvalid then
        exit;
      end if;
    end loop;

    check_value(not v_await_bvalid, config.max_wait_cycles_severity, ": Timeout waiting for BVALID", scope, ID_NEVER, msg_id_panel, proc_call);

    log(config.id_for_bfm, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure axi_write;

  procedure axi_read (
    constant arid_value     : in    std_logic_vector              := "";
    constant araddr_value   : in    unsigned;
    constant arlen_value    : in    unsigned(7 downto 0)          := (others=>'0');
    constant arsize_value   : in    integer range 1 to 128        := 4;
    constant arburst_value  : in    t_axburst                     := INCR;
    constant arlock_value   : in    t_axlock                      := NORMAL;
    constant arcache_value  : in    std_logic_vector(3 downto 0)  := (others=>'0');
    constant arprot_value   : in    t_axprot                      := UNPRIVILEGED_NONSECURE_DATA;
    constant arqos_value    : in    std_logic_vector(3 downto 0)  := (others=>'0');
    constant arregion_value : in    std_logic_vector(3 downto 0)  := (others=>'0');
    constant aruser_value   : in    std_logic_vector              := "";
    variable rdata_value    : out   t_slv_array;
    variable rresp_value    : out   t_xresp_array;
    variable ruser_value    : out   t_slv_array;
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axi_if         : inout t_axi_if;
    constant scope          : in    string                        := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel                := shared_msg_id_panel;
    constant config         : in    t_axi_bfm_config              := C_AXI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call  : in    string                        := ""  -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    constant local_proc_name : string := "axi_read"; -- Local proc_name; used if called from sequncer or VVC
    constant local_proc_call : string := local_proc_name & "(A:" & to_string(araddr_value, HEX, AS_IS, INCL_RADIX) & ")"; -- Local proc_call; used if called from sequncer or VVC
    -- Normalize to the DUT addr/data widths
    variable v_normalized_addr : std_logic_vector(axi_if.read_address_channel.araddr'length-1 downto 0) :=
      normalize_and_check(std_logic_vector(araddr_value), axi_if.read_address_channel.araddr, ALLOW_WIDER_NARROWER, "addr", "axi_if.read_address_channel.araddr", msg);
    -- Variables for the unconstrained inputs
    variable v_arid_value   : std_logic_vector(axi_if.read_address_channel.arid'length-1 downto 0);
    variable v_aruser_value : std_logic_vector(axi_if.read_address_channel.aruser'length-1 downto 0);
    -- Helper variables
    variable v_proc_call              : line;
    variable v_await_arready          : boolean := true;
    variable v_await_rvalid           : boolean := true;
    variable v_data_value             : std_logic_vector(axi_if.read_data_channel.rdata'length-1 downto 0);
    variable v_time_of_rising_edge    : time := -1 ns;  -- time stamp for clk period checking
    variable v_time_of_falling_edge   : time := -1 ns;  -- time stamp for clk period checking
  begin
    -- Setting default values
    if arid_value'length = 0 then
      v_arid_value := (others=>'0'); -- Default value
    else
      v_arid_value := normalize_and_check(arid_value, axi_if.read_address_channel.arid, ALLOW_WIDER_NARROWER, "arid", "axi_if.read_address_channel.arid", msg);
    end if;

    if aruser_value'length = 0 then
      v_aruser_value := (others=>'0'); -- Default value
    else
      v_aruser_value := normalize_and_check(aruser_value, axi_if.read_address_channel.aruser, ALLOW_WIDER_NARROWER, "aruser", "axi_if.read_address_channel.aruser", msg);
    end if;

    if config.bfm_sync = SYNC_WITH_SETUP_AND_HOLD then
      check_value(config.clock_period > -1 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, local_proc_call);
      check_value(config.setup_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, local_proc_call);
      check_value(config.hold_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, local_proc_call);
    end if;

    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC, log 'axi_read...'
      write(v_proc_call, local_proc_call);
    else
      -- Called from another BFM procedure, log 'ext_proc_call while executing axi_read...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    for cycle in 0 to config.max_wait_cycles loop

      -- Wait according to config.bfm_sync setup
      wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);

      -- Brady - Add support for num_ar_pipe_stages
      if cycle = config.num_ar_pipe_stages then
        axi_if.read_address_channel.arid     <= v_arid_value;
        axi_if.read_address_channel.araddr   <= v_normalized_addr;
        axi_if.read_address_channel.arlen    <= std_logic_vector(arlen_value);
        axi_if.read_address_channel.arsize   <= bytes_to_axsize(arsize_value);
        axi_if.read_address_channel.arburst  <= axburst_to_slv(arburst_value);
        axi_if.read_address_channel.arlock   <= axlock_to_sl(arlock_value);
        axi_if.read_address_channel.arcache  <= arcache_value;
        axi_if.read_address_channel.arprot   <= axprot_to_slv(arprot_value);
        axi_if.read_address_channel.arqos    <= arqos_value;
        axi_if.read_address_channel.arregion <= arregion_value;
        axi_if.read_address_channel.aruser   <= v_aruser_value;
        axi_if.read_address_channel.arvalid  <= '1';
      end if;

      wait until rising_edge(clk);
      if v_time_of_rising_edge = -1 ns then
        v_time_of_rising_edge := now;
      end if;

      check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge, 
                                config.clock_period, config.clock_period_margin, config.clock_margin_severity);

      if axi_if.read_address_channel.arready = '1' and cycle >= config.num_ar_pipe_stages then
        -- Wait according to config.bfm_sync setup
        wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
        axi_if.read_address_channel.arid     <= (axi_if.read_address_channel.arid'range => '0');
        axi_if.read_address_channel.araddr   <= (axi_if.read_address_channel.araddr'range => '0');
        axi_if.read_address_channel.arlen    <= (others=>'0');
        axi_if.read_address_channel.arsize   <= (others=>'0');
        axi_if.read_address_channel.arburst  <= (others=>'0');
        axi_if.read_address_channel.arlock   <= '0';
        axi_if.read_address_channel.arcache  <= (others=>'0');
        axi_if.read_address_channel.arprot   <= (others=>'0');
        axi_if.read_address_channel.arqos    <= (others=>'0');
        axi_if.read_address_channel.arregion <= (others=>'0');
        axi_if.read_address_channel.aruser   <= (axi_if.read_address_channel.aruser'range => '0');
        axi_if.read_address_channel.arvalid  <= '0';
        v_await_arready := false;
      end if;

      if not v_await_arready then
        exit;
      end if;
    end loop;

    check_value(not v_await_arready, config.max_wait_cycles_severity, ": Timeout waiting for ARREADY", scope, ID_NEVER, msg_id_panel, v_proc_call.all);

    for read_transfer_num in 0 to to_integer(unsigned(arlen_value)) loop
      for cycle in 0 to config.max_wait_cycles loop

        -- Wait according to config.bfm_sync setup
        wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);

        -- Brady - Add support for num_r_pipe_stages
        if cycle = config.num_r_pipe_stages then
          axi_if.read_data_channel.rready <= '1';
        end if;

        wait until rising_edge(clk);
        if v_time_of_rising_edge = -1 ns then
          v_time_of_rising_edge := now;
        end if;

        if axi_if.read_data_channel.rvalid = '1' and cycle >= config.num_r_pipe_stages then
          v_await_rvalid := false;
          check_value(axi_if.read_data_channel.rid, v_arid_value, config.match_strictness, error, "Checking RID", scope, HEX, KEEP_LEADING_0, ID_POS_ACK, msg_id_panel);
          rdata_value(read_transfer_num) := normalize_and_check(axi_if.read_data_channel.rdata, rdata_value(read_transfer_num), ALLOW_WIDER_NARROWER, "axi_if.read_data_channel.rdata", "rdata_value(" & to_string(read_transfer_num) & ")", msg);
          rresp_value(read_transfer_num) := slv_to_xresp(axi_if.read_data_channel.rresp);
          ruser_value(read_transfer_num) := normalize_and_check(axi_if.read_data_channel.ruser, ruser_value(read_transfer_num), ALLOW_WIDER_NARROWER, "axi_if.read_data_channel.ruser", "ruser_value("  & to_string(read_transfer_num) & ")", msg);
          -- Wait according to config.bfm_sync setup
          wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
          axi_if.read_data_channel.rready <= '0';
        end if;

        if not v_await_rvalid then
          exit;
        end if;
      end loop;
      check_value(not v_await_rvalid, config.max_wait_cycles_severity, ": Timeout waiting for RVALID", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
      v_await_rvalid := true;
    end loop;

    if ext_proc_call = "" then
      log(config.id_for_bfm, v_proc_call.all & "=> " & to_string(v_data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
      -- Log will be handled by calling procedure (e.g. axi_check)
    end if;

    DEALLOCATE(v_proc_call);
  end procedure axi_read;

  procedure axi_check (
    constant arid_value     : in    std_logic_vector              := "";
    constant araddr_value   : in    unsigned;
    constant arlen_value    : in    unsigned(7 downto 0)          := (others=>'0');
    constant arsize_value   : in    integer range 1 to 128        := 4;
    constant arburst_value  : in    t_axburst                     := INCR;
    constant arlock_value   : in    t_axlock                      := NORMAL;
    constant arcache_value  : in    std_logic_vector(3 downto 0)  := (others=>'0');
    constant arprot_value   : in    t_axprot                      := UNPRIVILEGED_NONSECURE_DATA;
    constant arqos_value    : in    std_logic_vector(3 downto 0)  := (others=>'0');
    constant arregion_value : in    std_logic_vector(3 downto 0)  := (others=>'0');
    constant aruser_value   : in    std_logic_vector              := "";
    constant rdata_exp      : in    t_slv_array;
    constant rresp_exp      : in    t_xresp_array                 := C_EMPTY_XRESP_ARRAY;
    constant ruser_exp      : in    t_slv_array                   := C_EMPTY_SLV_ARRAY;
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axi_if         : inout t_axi_if;
    constant alert_level    : in    t_alert_level                 := error;
    constant scope          : in    string                        := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel                := shared_msg_id_panel;
    constant config         : in    t_axi_bfm_config              := C_AXI_BFM_CONFIG_DEFAULT
  ) is
    constant proc_call     : string := "axi_check(A:" & to_string(araddr_value, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_rdata_value : t_slv_array(0 to to_integer(unsigned(arlen_value)))(axi_if.read_data_channel.rdata'length-1 downto 0);
    variable v_rresp_value : t_xresp_array(0 to to_integer(unsigned(arlen_value)));
    variable v_ruser_value : t_slv_array(0 to to_integer(unsigned(arlen_value)))(axi_if.read_data_channel.ruser'length-1 downto 0);
    variable v_rresp_exp   : t_xresp_array(0 to to_integer(unsigned(arlen_value))) := (others=>ILLEGAL);
    variable v_ruser_exp   : t_slv_array(0 to to_integer(unsigned(arlen_value)))(axi_if.read_data_channel.ruser'length-1 downto 0);
    variable v_check_ok    : boolean := true;
  begin

    if rresp_exp'length = 1 and rresp_exp(0) = ILLEGAL then
      v_rresp_exp := (others=>OKAY); -- Default value
    else
      if not rresp_exp'ascending then
        tb_error("The array rresp_exp is instantiated as 'downto', but only 'to' is supported" & add_msg_delimiter(msg), scope);
      else
        for i in 0 to minimum(v_rresp_exp'length, rresp_exp'length) - 1 loop
          v_rresp_exp(i) := rresp_exp(i);
        end loop;
      end if;
      
    end if;

    if ruser_exp'length = 1 and ruser_exp(0)'length = 1 and ruser_exp(0) = "U" then
      v_ruser_exp := (others=>(others=>'0')); -- Default value
    else
      v_ruser_exp := normalize_and_check(ruser_exp, v_ruser_exp, ALLOW_WIDER_NARROWER, "ruser_exp", "v_ruser_exp", msg);
    end if;

    axi_read(arid_value     => arid_value,
             araddr_value   => araddr_value,
             arlen_value    => arlen_value,
             arsize_value   => arsize_value,
             arburst_value  => arburst_value,
             arlock_value   => arlock_value,
             arcache_value  => arcache_value,
             arprot_value   => arprot_value,
             arqos_value    => arqos_value,
             arregion_value => arregion_value,
             aruser_value   => aruser_value,
             rdata_value    => v_rdata_value,
             rresp_value    => v_rresp_value,
             ruser_value    => v_ruser_value,
             msg            => msg,
             clk            => clk,
             axi_if         => axi_if,
             scope          => scope,
             msg_id_panel   => msg_id_panel,
             config         => config,
             ext_proc_call  => proc_call);

    if not check_value(v_rdata_value, rdata_exp, alert_level, "Checking RDATA", scope, HEX, KEEP_LEADING_0, ID_POS_ACK, msg_id_panel) then
      v_check_ok := false;
    end if;
    if not check_value(v_rresp_value = v_rresp_exp, alert_level, "Checking RRESP", scope, ID_POS_ACK, msg_id_panel) then
      v_check_ok := false;
    end if;
    if not check_value(v_ruser_value, v_ruser_exp, alert_level, "Checking RUSER ", scope, HEX, KEEP_LEADING_0, ID_POS_ACK, msg_id_panel) then
      v_check_ok := false;
    end if;

    if v_check_ok then
      log(config.id_for_bfm, proc_call & "=> OK. " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;

  end procedure axi_check;

end package body axi_bfm_pkg;
