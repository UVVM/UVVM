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
-- VHDL unit     : Bitvis VIP AXISTREAM Library : axistream_bfm_pkg
--
-- Description   : See library quick reference (under 'doc') and README-file(s).
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library std;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--========================================================================================================================
--========================================================================================================================
package axistream_bfm_pkg is

  --========================================================================================================================
  -- Types and constants for AXISTREAM_BFM
  --========================================================================================================================
  constant C_SCOPE : string := "AXISTREAM_BFM";

  --========================================================================================================================
  -- C_MAX_*_BITS : Maximum number of bits per data word supported by the BFM.
  -- These constant can be increased as needed.
  constant C_MAX_TUSER_BITS : positive := 8;
  constant C_MAX_TSTRB_BITS : positive := 32; -- Must be large enough for number of data bytes per transfer, C_MAX_TSTRB_BITS >= tdata/8
  constant C_MAX_TID_BITS   : positive := 8; -- Recommended maximum in protocol specification (ARM IHI0051A)
  constant C_MAX_TDEST_BITS : positive := 4; -- Recommended maximum in protocol specification (ARM IHI0051A)

  type     t_user_array is array(natural range <>) of std_logic_vector(C_MAX_TUSER_BITS-1 downto 0);
  type     t_strb_array is array(natural range <>) of std_logic_vector(C_MAX_TSTRB_BITS-1 downto 0);
  type     t_id_array is array(natural range <>) of std_logic_vector(C_MAX_TID_BITS-1 downto 0);
  type     t_dest_array is array(natural range <>) of std_logic_vector(C_MAX_TDEST_BITS-1 downto 0);
  --========================================================================================================================

  -- Interface record for BFM signals
  type t_axistream_if is record
    tdata  : std_logic_vector;  -- Data. Width is constrained when the procedure is called
    tkeep  : std_logic_vector;  -- One valid-bit per data byte
    tuser  : std_logic_vector;  -- User sideband data
    tvalid : std_logic;         -- Data valid
    tlast  : std_logic;         -- Active high during last data word in packet.
    tready : std_logic;         -- Backpressure
    tstrb  : std_logic_vector;  -- Treated as sideband data by BFM: tstrb does not affect tdata
    tid    : std_logic_vector;  -- Treated as sideband data by BFM
    tdest  : std_logic_vector;  -- Treated as sideband data by BFM
  end record;

  -- Configuration record to be assigned in the test harness.
  type t_axistream_bfm_config is
  record
    -- Common
    max_wait_cycles             : integer;       -- Used for setting the maximum cycles to wait before an alert is issued when waiting for ready or valid signals from the DUT.
    max_wait_cycles_severity    : t_alert_level; -- The above timeout will have this severity
    clock_period                : time;          -- Period of the clock signal.
    clock_period_margin         : time;          -- Input clock period margin to specified clock_period
    clock_margin_severity       : t_alert_level; -- The above margin will have this severity
    setup_time                  : time;          -- Setup time for generated signals, set to clock_period/4
    hold_time                   : time;          -- Hold time for generated signals, set to clock_period/4
    byte_endianness             : t_byte_endianness; -- Byte ordering from left (big-endian) or right (little-endian)
    -- config for axistream_receive()
    check_packet_length         : boolean;       -- When true, receive() will check that last is set at data_array'high
    protocol_error_severity     : t_alert_level; -- severity if protocol errors are detected by axistream_receive()
    ready_low_at_word_num       : integer;       -- When the Sink BFM shall deassert ready
    ready_low_duration          : integer;       -- Number of clock cycles to deassert ready
    ready_default_value         : std_logic;     -- Which value the BFM shall set ready to between accesses.
    -- Common
    id_for_bfm                  : t_msg_id;      -- The message ID used as a general message ID in the BFM
    id_for_bfm_wait             : t_msg_id;      -- The message ID used for logging waits in the BFM
    id_for_bfm_poll             : t_msg_id;      -- The message ID used for logging polling in the BFM
  end record;

  -- Define the default value for the BFM config
  constant C_AXISTREAM_BFM_CONFIG_DEFAULT : t_axistream_bfm_config := (
    max_wait_cycles             => 100,
    max_wait_cycles_severity    => ERROR,
    clock_period                => 0 ns,  -- Make sure we notice if we forget to set clock period.
    clock_period_margin         => 0 ns,
    clock_margin_severity       => TB_ERROR,
    setup_time                  => 0 ns,
    hold_time                   => 0 ns,
    byte_endianness             => FIRST_BYTE_LEFT,
    check_packet_length         => false,
    protocol_error_severity     => ERROR,
    ready_low_at_word_num       => 0,
    ready_low_duration          => 0,
    ready_default_value         => '0',
    id_for_bfm                  => ID_BFM,
    id_for_bfm_wait             => ID_BFM_WAIT,
    id_for_bfm_poll             => ID_BFM_POLL
    );

  --========================================================================================================================
  -- BFM procedures
  --========================================================================================================================

  -- - This function returns an AXI Stream interface with initialized signals.
  -- - All input signals are initialized to 0
  -- - All output signals are initialized to Z
  function init_axistream_if_signals(
    is_master   : boolean;  -- When true, this BFM drives data signals
    data_width  : natural;
    user_width  : natural;
    id_width    : natural;
    dest_width  : natural;
    config      : t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) return t_axistream_if;


  --------------------------------------------------------
  --
  -- AXIStream Transmit
  --
  --------------------------------------------------------

  --
  -- Source: BFM
  -- Sink:   DUT
  --¨
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes (
    constant data_array   : in    t_byte_array;  -- Byte in index 0 is transmitted first
    constant user_array   : in    t_user_array;
    constant strb_array   : in    t_strb_array;
    constant id_array     : in    t_id_array;
    constant dest_array   : in    t_dest_array;
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );
  -- t_slv_array overload
  procedure axistream_transmit (
    constant data_array   : in    t_slv_array;  -- Byte in index 0 is transmitted first
    constant user_array   : in    t_user_array;
    constant strb_array   : in    t_strb_array;
    constant id_array     : in    t_id_array;
    constant dest_array   : in    t_dest_array;
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );
      -- std_logic_vector overload
  procedure axistream_transmit (
    constant data_array   : in    std_logic_vector;
    constant user_array   : in    t_user_array;
    constant strb_array   : in    t_strb_array;
    constant id_array     : in    t_id_array;
    constant dest_array   : in    t_dest_array;
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );


  -- Overloaded version without records
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes (
    constant data_array          : in    t_byte_array;
    constant user_array          : in    t_user_array;
    constant strb_array          : in    t_strb_array;
    constant id_array            : in    t_id_array;
    constant dest_array          : in    t_dest_array;
    constant msg                 : in    string                 := "";
    signal   clk                 : in    std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in    string                 := C_SCOPE;
    constant msg_id_panel        : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );
  -- t_slv_array overload
  procedure axistream_transmit (
    constant data_array          : in    t_slv_array;
    constant user_array          : in    t_user_array;
    constant strb_array          : in    t_strb_array;
    constant id_array            : in    t_id_array;
    constant dest_array          : in    t_dest_array;
    constant msg                 : in    string                 := "";
    signal   clk                 : in    std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in    string                 := C_SCOPE;
    constant msg_id_panel        : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );
    -- std_logic_vector overload
  procedure axistream_transmit (
    constant data_array          : in    std_logic_vector;
    constant user_array          : in    t_user_array;
    constant strb_array          : in    t_strb_array;
    constant id_array            : in    t_id_array;
    constant dest_array          : in    t_dest_array;
    constant msg                 : in    string                 := "";
    signal   clk                 : in    std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in    string                 := C_SCOPE;
    constant msg_id_panel        : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );


  -- Overload for default strb_array, id_array, dest_array
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes (
    constant data_array   : in    t_byte_array;  -- Byte in index 0 is transmitted first
    constant user_array   : in    t_user_array;
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );
  -- t_slv_array overload
  procedure axistream_transmit (
    constant data_array   : in    t_slv_array;  -- Byte in index 0 is transmitted first
    constant user_array   : in    t_user_array;
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );
  -- std_logic_vector overload
  procedure axistream_transmit (
    constant data_array   : in    std_logic_vector;
    constant user_array   : in    t_user_array;
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );

  -- Overload for default user_array, strb_array, id_array, dest_array
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes (
    constant data_array   : in    t_byte_array;
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );
  -- t_slv_array overload
  procedure axistream_transmit (
    constant data_array   : in    t_slv_array;
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );
  -- std_logic_vector overload
  procedure axistream_transmit (
    constant data_array   : in    std_logic_vector;
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );


  --------------------------------------------------------
  --
  -- AXIStream Receive
  --
  --------------------------------------------------------
  --
  -- Source: DUT
  -- Sink:   BFM
  --
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_receive_bytes (
    variable data_array   : inout t_byte_array;
    variable data_length  : inout natural;  -- Number of bytes received
    variable user_array   : inout t_user_array;
    variable strb_array   : inout t_strb_array;
    variable id_array     : inout t_id_array;
    variable dest_array   : inout t_dest_array;
    constant msg          : in    string;
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call: in    string                 := "" -- External proc_call; overwrite if called from other BFM procedure like axistream_expect
  );
  procedure axistream_receive (
    variable data_array   : inout t_slv_array;
    variable data_length  : inout natural;  -- Number of bytes received
    variable user_array   : inout t_user_array;
    variable strb_array   : inout t_strb_array;
    variable id_array     : inout t_id_array;
    variable dest_array   : inout t_dest_array;
    constant msg          : in    string;
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call: in    string                 := "" -- External proc_call; overwrite if called from other BFM procedure like axistream_expect
  );


  -- Overloaded version without records
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_receive_bytes (
    variable data_array          : inout t_byte_array;
    variable data_length         : inout natural;  -- Number of bytes received
    variable user_array          : inout t_user_array;
    variable strb_array          : inout t_strb_array;
    variable id_array            : inout t_id_array;
    variable dest_array          : inout t_dest_array;
    constant msg                 : in    string;
    signal   clk                 : in    std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in    string                   := C_SCOPE;
    constant msg_id_panel        : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config              : in    t_axistream_bfm_config   := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call       : in    string                   := "" -- External proc_call; overwrite if called from other BFM procedure like axistream_expect
  );
  -- Overloaded version without records
  procedure axistream_receive (
    variable data_array          : inout t_slv_array;
    variable data_length         : inout natural;  -- Number of bytes received
    variable user_array          : inout t_user_array;
    variable strb_array          : inout t_strb_array;
    variable id_array            : inout t_id_array;
    variable dest_array          : inout t_dest_array;
    constant msg                 : in    string;
    signal   clk                 : in    std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in    string                   := C_SCOPE;
    constant msg_id_panel        : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config              : in    t_axistream_bfm_config   := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call       : in    string                   := "" -- External proc_call; overwrite if called from other BFM procedure like axistream_expect
  );



  --------------------------------------------------------
  --
  -- AXIStream Expect
  --
  --------------------------------------------------------
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes (
    constant exp_data_array : in    t_byte_array;  -- Expected data
    constant exp_user_array : in    t_user_array;  -- Expected tuser
    constant exp_strb_array : in    t_strb_array;  -- Expected tstrb
    constant exp_id_array   : in    t_id_array;    -- Expected tid
    constant exp_dest_array : in    t_dest_array;  -- Expected tdest
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in    t_alert_level          := error;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );
  -- t_slv_array overload
  procedure axistream_expect (
    constant exp_data_array : in    t_slv_array;  -- Expected data
    constant exp_user_array : in    t_user_array;  -- Expected tuser
    constant exp_strb_array : in    t_strb_array;  -- Expected tstrb
    constant exp_id_array   : in    t_id_array;    -- Expected tid
    constant exp_dest_array : in    t_dest_array;  -- Expected tdest
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in    t_alert_level          := error;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );
  -- std_logic_vector overload
  procedure axistream_expect (
    constant exp_data_array : in    std_logic_vector;  -- Expected data
    constant exp_user_array : in    t_user_array;  -- Expected tuser
    constant exp_strb_array : in    t_strb_array;  -- Expected tstrb
    constant exp_id_array   : in    t_id_array;    -- Expected tid
    constant exp_dest_array : in    t_dest_array;  -- Expected tdest
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in    t_alert_level          := error;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );

  -- Overloaded version without records
  -- DEPRECATE: procedure with exp_data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes (
    constant exp_data_array      : in    t_byte_array;  -- Expected data
    constant exp_user_array      : in    t_user_array;  -- Expected tuser
    constant exp_strb_array      : in    t_strb_array;  -- Expected tstrb
    constant exp_id_array        : in    t_id_array;    -- Expected tid
    constant exp_dest_array      : in    t_dest_array;  -- Expected tdest
    constant msg                 : in    string;
    signal   clk                 : in    std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant alert_level         : in    t_alert_level           := error;
    constant scope               : in    string                  := C_SCOPE;
    constant msg_id_panel        : in    t_msg_id_panel          := shared_msg_id_panel;
    constant config              : in    t_axistream_bfm_config  := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );
    -- t_slv_array overload
  procedure axistream_expect (
    constant exp_data_array      : in    t_slv_array;  -- Expected data
    constant exp_user_array      : in    t_user_array;  -- Expected tuser
    constant exp_strb_array      : in    t_strb_array;  -- Expected tstrb
    constant exp_id_array        : in    t_id_array;    -- Expected tid
    constant exp_dest_array      : in    t_dest_array;  -- Expected tdest
    constant msg                 : in    string;
    signal   clk                 : in    std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant alert_level         : in    t_alert_level           := error;
    constant scope               : in    string                  := C_SCOPE;
    constant msg_id_panel        : in    t_msg_id_panel          := shared_msg_id_panel;
    constant config              : in    t_axistream_bfm_config  := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );
    -- std_logic_vector overload
    procedure axistream_expect (
      constant exp_data_array      : in    std_logic_vector;  -- Expected data
      constant exp_user_array      : in    t_user_array;  -- Expected tuser
      constant exp_strb_array      : in    t_strb_array;  -- Expected tstrb
      constant exp_id_array        : in    t_id_array;    -- Expected tid
      constant exp_dest_array      : in    t_dest_array;  -- Expected tdest
      constant msg                 : in    string;
      signal   clk                 : in    std_logic;
      signal   axistream_if_tdata  : inout std_logic_vector;
      signal   axistream_if_tkeep  : inout std_logic_vector;
      signal   axistream_if_tuser  : inout std_logic_vector;
      signal   axistream_if_tstrb  : inout std_logic_vector;
      signal   axistream_if_tid    : inout std_logic_vector;
      signal   axistream_if_tdest  : inout std_logic_vector;
      signal   axistream_if_tvalid : inout std_logic;
      signal   axistream_if_tlast  : inout std_logic;
      signal   axistream_if_tready : inout std_logic;
      constant alert_level         : in    t_alert_level           := error;
      constant scope               : in    string                  := C_SCOPE;
      constant msg_id_panel        : in    t_msg_id_panel          := shared_msg_id_panel;
      constant config              : in    t_axistream_bfm_config  := C_AXISTREAM_BFM_CONFIG_DEFAULT
      );

  -- Overload for default strb_array, id_array, dest_array
  -- DEPRECATE: procedure with exp_data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes (
    constant exp_data_array : in    t_byte_array;
    constant exp_user_array : in    t_user_array;
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in    t_alert_level          := error;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );
  -- t_slv_array overload
  procedure axistream_expect (
    constant exp_data_array : in    t_slv_array;
    constant exp_user_array : in    t_user_array;
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in    t_alert_level          := error;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );
  -- std_logic_vector overload
  procedure axistream_expect (
    constant exp_data_array : in    std_logic_vector;
    constant exp_user_array : in    t_user_array;
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in    t_alert_level          := error;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );


  -- Overload for default user_array, strb_array, id_array, dest_array
  -- DEPRECATE: procedure with exp_data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes (
    constant exp_data_array : in    t_byte_array;
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in    t_alert_level          := error;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );
  -- t_slv_array overload
  procedure axistream_expect (
    constant exp_data_array : in    t_slv_array;
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in    t_alert_level          := error;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );
  -- std_logic_vector overload
  procedure axistream_expect (
    constant exp_data_array : in    std_logic_vector;
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in    t_alert_level          := error;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );

end package axistream_bfm_pkg;


--========================================================================================================================
--========================================================================================================================

package body axistream_bfm_pkg is

  function init_axistream_if_signals(
    is_master  : boolean;  -- When true, this BFM drives data signals
    data_width : natural;
    user_width : natural;
    id_width   : natural;
    dest_width : natural;
    config     : t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) return t_axistream_if is
    variable init_if : t_axistream_if(tdata(data_width-1 downto 0),
                                      tkeep(data_width/8-1 downto 0),
                                      tuser(user_width-1 downto 0),
                                      tstrb(data_width/8-1 downto 0),
                                      tid  (id_width-1 downto 0),
                                      tdest(dest_width-1 downto 0)
                                      );
  begin

    if is_master then
      -- from slave to master
      init_if.tready := 'Z';

      -- from master to slave
      init_if.tvalid := '0';
      init_if.tdata  := (init_if.tdata'range => '0');
      init_if.tkeep  := (init_if.tkeep'range => '0');
      init_if.tuser  := (init_if.tuser'range => '0');
      init_if.tstrb  := (init_if.tstrb'range => '0');
      init_if.tid    := (init_if.tid'range => '0');
      init_if.tdest  := (init_if.tdest'range => '0');
      init_if.tlast  := '0';
    else
      -- from slave to master
      init_if.tready := config.ready_default_value;
      --init_if.tready := '0';
      -- from master to slave
      init_if.tvalid := 'Z';
      init_if.tdata  := (init_if.tdata'range => 'Z');
      init_if.tkeep  := (init_if.tkeep'range => 'Z');
      init_if.tuser  := (init_if.tuser'range => 'Z');
      init_if.tstrb  := (init_if.tstrb'range => 'Z');
      init_if.tid    := (init_if.tid'range => 'Z');
      init_if.tdest  := (init_if.tdest'range => 'Z');
      init_if.tlast  := 'Z';
    end if;
    return init_if;
  end function;


  --------------------------------------------------------
  --
  -- AXIStream Transmit
  --
  --------------------------------------------------------

  -- Send a packet on the AXI interface.
  -- Packet length and data is defined by data_array
  -- tuser is set based on user_array,
  -- tstrb is set based on strb_array, etc
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes (
    constant data_array   : in    t_byte_array;  -- Byte in index 0 is transmitted first
    constant user_array   : in    t_user_array;
    constant strb_array   : in    t_strb_array;
    constant id_array     : in    t_id_array;
    constant dest_array   : in    t_dest_array;
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is

    constant proc_name : string := "axistream_transmit";
    constant proc_call : string := "axistream_transmit(" & to_string(data_array'length) & "B)";

    constant c_num_bytes_per_word     : natural := axistream_if.tdata'length/8;
    constant c_num_user_bits_per_word : natural := axistream_if.tuser'length;
    constant c_num_strb_bits_per_word : natural := axistream_if.tstrb'length;
    constant c_num_id_bits_per_word   : natural := axistream_if.tid'length;
    constant c_num_dest_bits_per_word : natural := axistream_if.tdest'length;

    -- Helper variables
    variable v_byte_in_word                 : integer range 0 to c_num_bytes_per_word-1 := 0;  -- current byte within the data word
    variable v_byte_cnt                     : natural := 0;
    variable v_clk_cycles_waited            : natural := 0;
    variable v_wait_for_next_transfer_cycle : boolean;  -- When set, the BFM shall wait for at least one clock cycle, until tready='1' before continuing
    variable v_last_rising_edge  : time    := -1 ns;  -- time stamp for clk period checking

    -- Sampled tready for the current clock cycle
    variable v_tready : std_logic;

  begin
    -- DEPRECATE: data_array as t_byte_array will be removed in next major release
    deprecate(proc_name, "data_array as t_byte_array has been deprecated. Use data_array as t_slv_array.");

    check_value(axistream_if.tdata'length >= 8,      TB_ERROR, "Sanity check: Check that tdata is at least one byte wide. Narrower tdata is not supported.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(axistream_if.tdata'length mod 8 = 0, TB_ERROR, "Sanity check: Check that tdata is an integer number of bytes wide.",                         scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(axistream_if.tuser'length <= C_MAX_TUSER_BITS, TB_ERROR, "Sanity check: Check that C_MAX_TUSER_BITS is high enough for axistream_if.tuser.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(axistream_if.tid'length   <= C_MAX_TID_BITS, TB_ERROR,   "Sanity check: Check that C_MAX_TID_BITS is high enough for axistream_if.tid.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(axistream_if.tdest'length <= C_MAX_TDEST_BITS, TB_ERROR, "Sanity check: Check that C_MAX_TDEST_BITS is high enough for axistream_if.tdest.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(axistream_if.tkeep'length = (axistream_if.tdata'length/8), TB_ERROR, "Sanity check: Check that width of tkeep equals number of bytes in tdata.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(axistream_if.tstrb'length = (axistream_if.tdata'length/8), TB_ERROR, "Sanity check: Check that width of tstrb equals number of bytes in tdata.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(data_array'ascending,                TB_ERROR, "Sanity check: Check that data_array is ascending (defined with 'to'), for byte order clarity", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(user_array'ascending,                TB_ERROR, "Sanity check: Check that user_array is ascending (defined with 'to'), for word order clarity", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(strb_array'ascending,                TB_ERROR, "Sanity check: Check that strb_array is ascending (defined with 'to'), for word order clarity", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(id_array'ascending,                  TB_ERROR, "Sanity check: Check that   id_array is ascending (defined with 'to'), for word order clarity", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(dest_array'ascending,                TB_ERROR, "Sanity check: Check that dest_array is ascending (defined with 'to'), for word order clarity", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(config.clock_period /= 0 ns,         TB_ERROR, "Sanity check: Check that bfm_config.clock_period is set",                                    scope, ID_NEVER, msg_id_panel, proc_call);
    -- setup_time and hold_time checking
    check_value(config.setup_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(config.hold_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(config.setup_time > 0 ns, TB_FAILURE, "Sanity check: Check that setup_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(config.hold_time > 0 ns, TB_FAILURE, "Sanity check: Check that hold_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, proc_call);

    axistream_if <= init_axistream_if_signals(is_master  => true,  -- this BFM drives data signals
                                              data_width => axistream_if.tdata'length,
                                              user_width => axistream_if.tuser'length,
                                              id_width   => axistream_if.tid'length,
                                              dest_width => axistream_if.tdest'length);

    -- check if enough room for setup_time in low period
    if (clk = '0') and (config.setup_time > (config.clock_period/2 - clk'last_event))then
      await_value(clk, '1', 0 ns, config.clock_period/2, TB_FAILURE, proc_call & ": timeout waiting for clk low period for setup_time.");
    end if;
    -- Wait setup_time specified in config record
    wait_until_given_time_before_rising_edge(clk, config.setup_time, config.clock_period);

    log(ID_PACKET_INITIATE, proc_call & "=> " & add_msg_delimiter(msg), scope, msg_id_panel);

    for byte in 0 to data_array'high loop
      log(ID_PACKET_DATA, proc_call & "=> Tx " & to_string(data_array(byte), HEX, AS_IS, INCL_RADIX) &
      --     ", tuser=" & to_string(user_array(byte/c_num_bytes_per_word), HEX, AS_IS, INCL_RADIX) &
      --     ", tstrb=" & to_string(strb_array(byte/c_num_bytes_per_word), HEX, AS_IS, INCL_RADIX) &
      --     ", tid="   & to_string(id_array(byte/c_num_bytes_per_word),   HEX, AS_IS, INCL_RADIX) &
      --     ", tdest=" & to_string(dest_array(byte/c_num_bytes_per_word), HEX, AS_IS, INCL_RADIX) &
          ", byte# " & to_string(byte) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      axistream_if.tvalid <= '1';

      -- Byte locations within the data word is described in chapter 2.3 in "ARM IHI0051A"
      axistream_if.tdata(7+8*v_byte_in_word downto 8*v_byte_in_word) <= data_array(byte);

      -- Set sideband data for this transfer (i.e. this word)
      if v_byte_in_word = 0 then
        axistream_if.tuser(c_num_user_bits_per_word-1 downto 0) <= user_array(byte/c_num_bytes_per_word)(c_num_user_bits_per_word-1 downto 0);
        axistream_if.tstrb(c_num_strb_bits_per_word-1 downto 0) <= strb_array(byte/c_num_bytes_per_word)(c_num_strb_bits_per_word-1 downto 0);
        axistream_if.tid(c_num_id_bits_per_word-1 downto 0)     <= id_array(byte/c_num_bytes_per_word)(c_num_id_bits_per_word-1 downto 0);
        axistream_if.tdest(c_num_dest_bits_per_word-1 downto 0) <= dest_array(byte/c_num_bytes_per_word)(c_num_dest_bits_per_word-1 downto 0);
      end if;

      -- TKEEP[x] is associated with TDATA[(7+8*v_byte_in_word) : 8*v_byte_in_word].
      axistream_if.tkeep(v_byte_in_word) <= '1';

      -- Default: Go to next 'byte' iteration in zero time (when tdata is not completely fillled with bytes).
      v_wait_for_next_transfer_cycle := false;

      if byte = data_array'high then
        -- Packet done.
        axistream_if.tlast     <= '1';
        v_wait_for_next_transfer_cycle := true; -- No more bytes to fill in tdata
      else
        axistream_if.tlast <= '0';
      end if;

      if v_byte_in_word = c_num_bytes_per_word-1 then
        -- Next byte is in the next clk cycle
        v_byte_in_word                 := 0;
        v_wait_for_next_transfer_cycle := true; -- No more bytes to fill in tdata
      else
        -- Next byte is in the same clk cycle
        v_byte_in_word := v_byte_in_word + 1;
      end if;

      --
      -- If no more bytes to fill in tdata, wait until the transfer takes place (tvalid=1 and tready=1)
      --
      if v_wait_for_next_transfer_cycle then

        wait until rising_edge(clk);
        -- check if clk period since last rising edge is within specifications and take a new time stamp
        if v_last_rising_edge > -1 ns then
          check_value_in_range(now - v_last_rising_edge, config.clock_period - config.clock_period_margin, config.clock_period + config.clock_period_margin, config.clock_margin_severity, "clk period not within requirement.");
        end if;
        v_last_rising_edge := now; -- time stamp for clk period checking

        v_tready := axistream_if.tready;    -- Will this cycle be a transfer? (tvalid=1 and tready=1)

        -- Wait hold time specified in config record
        wait_until_given_time_after_rising_edge(clk, config.hold_time);

        -- reset wait cycles error counter
        v_clk_cycles_waited := 0;

        while v_tready = '0' loop
          wait until rising_edge(clk);
          -- check if clk period since last rising edge is within specifications and take a new time stamp
          if v_last_rising_edge > -1 ns then
            check_value_in_range(now - v_last_rising_edge, config.clock_period - config.clock_period_margin, config.clock_period + config.clock_period_margin, config.clock_margin_severity, "clk period not within requirement.");
          end if;
          v_last_rising_edge := now; -- time stamp for clk period checking

          v_tready := axistream_if.tready;  -- Will this cycle be a transfer? (tvalid=1 and tready=1)

          -- Wait hold time specified in config record
          wait_until_given_time_after_rising_edge(clk, config.hold_time);

          v_clk_cycles_waited := v_clk_cycles_waited + 1;
          check_value(v_clk_cycles_waited <= config.max_wait_cycles, config.max_wait_cycles_severity,
                      ": Timeout while waiting for tready " & add_msg_delimiter(msg), scope, ID_NEVER, msg_id_panel, proc_call);
        end loop;

        -- Default values for the next clk cycle
        axistream_if <= init_axistream_if_signals(is_master  => true,  -- this BFM drives data signals
                                                  data_width => axistream_if.tdata'length,
                                                  user_width => axistream_if.tuser'length,
                                                  id_width   => axistream_if.tid'length,
                                                  dest_width => axistream_if.tdest'length
                                                 );
      end if;

    end loop;

    -- Done.
    axistream_if.tvalid <= '0';

    log(ID_PACKET_COMPLETE, proc_call & "=> Tx DONE" &
        ". " & add_msg_delimiter(msg),
        scope, msg_id_panel);

  end procedure axistream_transmit_bytes;

  -----------------------
  -- t_slv_array overload
  -----------------------
  procedure axistream_transmit (
    constant data_array   : in    t_slv_array;  -- Byte in index 0 is transmitted first
    constant user_array   : in    t_user_array;
    constant strb_array   : in    t_strb_array;
    constant id_array     : in    t_id_array;
    constant dest_array   : in    t_dest_array;
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
    -- Helper variables
    variable v_bytes_in_word    : integer := (data_array(0)'length/8);
    variable v_num_bytes        : integer := (data_array'length) * v_bytes_in_word;
    variable v_data_array       : t_byte_array(0 to v_num_bytes-1);
    variable v_data_array_idx   : integer := 0;
    variable v_check_ok         : boolean := false;
    variable v_byte_endianness  : t_byte_endianness := config.byte_endianness;
  begin
    -- t_slv_array sanity check
    v_check_ok := check_value(data_array(0)'length mod 8 = 0, TB_ERROR, "Sanity check: Check that data_array word is N*byte");

    if v_check_ok then
      -- copy byte(s) from t_slv_array to t_byte_array
      v_data_array := convert_slv_array_to_byte_array(data_array, true, v_byte_endianness); -- data_array is ascending
      -- call t_byte_array overloaded procedure
      axistream_transmit_bytes(v_data_array, user_array, strb_array, id_array, dest_array, msg, clk, axistream_if, scope, msg_id_panel, config);
    end if;
  end procedure;
  -----------------------
  -- std_logic_vector overload
  -----------------------
  procedure axistream_transmit (
    constant data_array   : in    std_logic_vector;
    constant user_array   : in    t_user_array;
    constant strb_array   : in    t_strb_array;
    constant id_array     : in    t_id_array;
    constant dest_array   : in    t_dest_array;
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
    -- Helper variables
    variable v_check_ok   : boolean := false;
    variable v_data_array : t_slv_array(0 to 0)(data_array'length-1 downto 0);
  begin
    -- t_slv_array sanity check
    v_check_ok := check_value(data_array'length mod 8 = 0, TB_ERROR, "Sanity check: Check that data_array word is N*byte");
    if v_check_ok then
      v_data_array(0) := data_array;
      -- call t_slv_array overloaded procedure
      axistream_transmit(v_data_array, user_array, strb_array, id_array, dest_array, msg, clk, axistream_if, scope, msg_id_panel, config);
    end if;
  end procedure;


  -- Overload that doesn't use records for the AXI interface:
  -- (In turn calls the record version)
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes (
    constant data_array          : in    t_byte_array;
    constant user_array          : in    t_user_array;
    constant strb_array          : in    t_strb_array;
    constant id_array            : in    t_id_array;
    constant dest_array          : in    t_dest_array;
    constant msg                 : in    string                 := "";
    signal   clk                 : in    std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in    string                 := C_SCOPE;
    constant msg_id_panel        : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
  begin
    -- call overloading procedure
    axistream_transmit_bytes(
      data_array          => data_array,
      user_array          => user_array,
      strb_array          => strb_array,
      id_array            => id_array,
      dest_array          => dest_array,
      msg                 => msg,
      clk                 => clk,
      axistream_if.tdata  => axistream_if_tdata,
      axistream_if.tkeep  => axistream_if_tkeep,
      axistream_if.tuser  => axistream_if_tuser,
      axistream_if.tstrb  => axistream_if_tstrb,
      axistream_if.tid    => axistream_if_tid,
      axistream_if.tdest  => axistream_if_tdest,
      axistream_if.tvalid => axistream_if_tvalid,
      axistream_if.tlast  => axistream_if_tlast,
      axistream_if.tready => axistream_if_tready,
      scope               => scope,
      msg_id_panel        => msg_id_panel,
      config              => config);
  end procedure axistream_transmit_bytes;
  -----------------------
  -- t_slv_array overload
  -----------------------
  procedure axistream_transmit (
    constant data_array          : in    t_slv_array;
    constant user_array          : in    t_user_array;
    constant strb_array          : in    t_strb_array;
    constant id_array            : in    t_id_array;
    constant dest_array          : in    t_dest_array;
    constant msg                 : in    string                 := "";
    signal   clk                 : in    std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in    string                 := C_SCOPE;
    constant msg_id_panel        : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
  begin
    -- call overloading t_slv_array procedure
    axistream_transmit(
      data_array          => data_array,
      user_array          => user_array,
      strb_array          => strb_array,
      id_array            => id_array,
      dest_array          => dest_array,
      msg                 => msg,
      clk                 => clk,
      axistream_if.tdata  => axistream_if_tdata,
      axistream_if.tkeep  => axistream_if_tkeep,
      axistream_if.tuser  => axistream_if_tuser,
      axistream_if.tstrb  => axistream_if_tstrb,
      axistream_if.tid    => axistream_if_tid,
      axistream_if.tdest  => axistream_if_tdest,
      axistream_if.tvalid => axistream_if_tvalid,
      axistream_if.tlast  => axistream_if_tlast,
      axistream_if.tready => axistream_if_tready,
      scope               => scope,
      msg_id_panel        => msg_id_panel,
      config              => config);
  end procedure axistream_transmit;
  -----------------------
  -- std_logic_vector overload
  -----------------------
  procedure axistream_transmit (
    constant data_array          : in    std_logic_vector;
    constant user_array          : in    t_user_array;
    constant strb_array          : in    t_strb_array;
    constant id_array            : in    t_id_array;
    constant dest_array          : in    t_dest_array;
    constant msg                 : in    string                 := "";
    signal   clk                 : in    std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in    string                 := C_SCOPE;
    constant msg_id_panel        : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
  begin
    -- call overloading slv procedure
    axistream_transmit(
      data_array          => data_array,
      user_array          => user_array,
      strb_array          => strb_array,
      id_array            => id_array,
      dest_array          => dest_array,
      msg                 => msg,
      clk                 => clk,
      axistream_if.tdata  => axistream_if_tdata,
      axistream_if.tkeep  => axistream_if_tkeep,
      axistream_if.tuser  => axistream_if_tuser,
      axistream_if.tstrb  => axistream_if_tstrb,
      axistream_if.tid    => axistream_if_tid,
      axistream_if.tdest  => axistream_if_tdest,
      axistream_if.tvalid => axistream_if_tvalid,
      axistream_if.tlast  => axistream_if_tlast,
      axistream_if.tready => axistream_if_tready,
      scope               => scope,
      msg_id_panel        => msg_id_panel,
      config              => config);
  end procedure axistream_transmit;


  -- Overload with default value for  strb_array, id_array, dest_array
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes (
    constant data_array   : in    t_byte_array;  -- Byte in index 0 is transmitted first
    constant user_array   : in    t_user_array;
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
    -- One entry per word. Max words possible is the number of bytes in data_array
    constant c_strb_array_default : t_strb_array(0 to data_array'high) := (others => (others => '0'));
    constant c_id_array_default   : t_id_array(0 to data_array'high)   := (others => (others => '0'));
    constant c_dest_array_default : t_dest_array(0 to data_array'high) := (others => (others => '0'));
  begin
    axistream_transmit_bytes(
      data_array   => data_array,
      user_array   => user_array,
      strb_array   => c_strb_array_default,
      id_array     => c_id_array_default,
      dest_array   => c_dest_array_default,
      msg          => msg,
      clk          => clk,
      axistream_if => axistream_if,
      scope        => scope,
      msg_id_panel => msg_id_panel,
      config       => config);
  end procedure axistream_transmit_bytes;
  -----------------------
  -- t_slv_array overload
  -----------------------
  procedure axistream_transmit (
    constant data_array   : in    t_slv_array;  -- Byte in index 0 is transmitted first
    constant user_array   : in    t_user_array;
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
    -- One entry per word. Max words possible is the number of bytes in data_array
    constant c_strb_array_default : t_strb_array(0 to data_array'high) := (others => (others => '0'));
    constant c_id_array_default   : t_id_array(0 to data_array'high)   := (others => (others => '0'));
    constant c_dest_array_default : t_dest_array(0 to data_array'high) := (others => (others => '0'));
  begin
    -- call overloading t_slv_array procedure
    axistream_transmit(
      data_array   => data_array,
      user_array   => user_array,
      strb_array   => c_strb_array_default,
      id_array     => c_id_array_default,
      dest_array   => c_dest_array_default,
      msg          => msg,
      clk          => clk,
      axistream_if => axistream_if,
      scope        => scope,
      msg_id_panel => msg_id_panel,
      config       => config);
  end procedure axistream_transmit;
  -----------------------
  -- std_logic_vector overload
  -----------------------
  procedure axistream_transmit (
    constant data_array   : in    std_logic_vector;
    constant user_array   : in    t_user_array;
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
    -- One entry per word. Max words possible is the number of bytes in data_array
    constant c_strb_array_default : t_strb_array(0 to data_array'high) := (others => (others => '0'));
    constant c_id_array_default   : t_id_array(0 to data_array'high)   := (others => (others => '0'));
    constant c_dest_array_default : t_dest_array(0 to data_array'high) := (others => (others => '0'));
  begin
    -- call overloading slv procedure
    axistream_transmit(
      data_array   => data_array,
      user_array   => user_array,
      strb_array   => c_strb_array_default,
      id_array     => c_id_array_default,
      dest_array   => c_dest_array_default,
      msg          => msg,
      clk          => clk,
      axistream_if => axistream_if,
      scope        => scope,
      msg_id_panel => msg_id_panel,
      config       => config);
  end procedure axistream_transmit;


  -- Overload with default value for user_array, strb_array, id_array, dest_array
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes (
    constant data_array   : in    t_byte_array;  -- Byte in index 0 is transmitted first
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
    constant c_user_array_default : t_user_array(0 to data_array'high) := (others => (others => '0'));
  begin
    -- Calling another overload that fills in strb_array, id_array, dest_array
    axistream_transmit_bytes(
      data_array   => data_array,
      user_array   => c_user_array_default,
      msg          => msg,
      clk          => clk,
      axistream_if => axistream_if,
      scope        => scope,
      msg_id_panel => msg_id_panel,
      config       => config);
  end procedure axistream_transmit_bytes;
  -----------------------
  -- t_slv_array overload
  -----------------------
  procedure axistream_transmit (
    constant data_array   : in    t_slv_array;  -- Byte in index 0 is transmitted first
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
    constant c_user_array_default : t_user_array(0 to data_array'high) := (others => (others => '0'));
  begin
    -- Calling another t_slv_array overload that fills in strb_array, id_array, dest_array
    axistream_transmit(
      data_array   => data_array,
      user_array   => c_user_array_default,
      msg          => msg,
      clk          => clk,
      axistream_if => axistream_if,
      scope        => scope,
      msg_id_panel => msg_id_panel,
      config       => config);
  end procedure axistream_transmit;
  -----------------------
  -- std_logic_vector overload
  -----------------------
  procedure axistream_transmit (
    constant data_array   : in    std_logic_vector;
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
    constant c_user_array_default : t_user_array(0 to data_array'high) := (others => (others => '0'));
  begin
    -- Calling another slv overload that fills in strb_array, id_array, dest_array
    axistream_transmit(
      data_array   => data_array,
      user_array   => c_user_array_default,
      msg          => msg,
      clk          => clk,
      axistream_if => axistream_if,
      scope        => scope,
      msg_id_panel => msg_id_panel,
      config       => config);
  end procedure axistream_transmit;




  --------------------------------------------------------
  --
  -- AXIStream Receive
  --
  --------------------------------------------------------

  -- Receive a packet, store it in data_array
  -- data_array'length can be longer than the actual packet, so that you can call receive() without knowing the length to be expected.
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_receive_bytes (
    variable data_array   : inout t_byte_array;
    variable data_length  : inout natural;  -- Number of bytes received
    variable user_array   : inout t_user_array;
    variable strb_array   : inout t_strb_array;
    variable id_array     : inout t_id_array;
    variable dest_array   : inout t_dest_array;
    constant msg          : in    string;
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call: in    string                 := "" -- External proc_call; overwrite if called from other BFM procedure like axistream_expect
    ) is
    constant c_num_bytes_per_word     : natural := axistream_if.tdata'length/8;
    constant c_num_user_bits_per_word : natural := axistream_if.tuser'length;
    constant c_num_strb_bits_per_word : natural := axistream_if.tstrb'length;
    constant c_num_id_bits_per_word   : natural := axistream_if.tid'length;
    constant c_num_dest_bits_per_word : natural := axistream_if.tdest'length;
    constant local_proc_name          : string := "axistream_receive";  -- Internal proc_name; used if called from sequncer or VVC
    constant local_proc_call          : string := local_proc_name & "()"; -- Internal proc_call; used if called from sequncer or VVC

    -- Helper variables
    variable v_proc_call             : line;                           -- Current proc_call, external or local
    variable v_byte_in_word          : integer range 0 to c_num_bytes_per_word-1 := 0;  -- current Byte within the data word
    variable v_byte_cnt              : integer                                   := 0;  -- # bytes received
    variable v_timeout               : boolean                                   := false;
    variable v_done                  : boolean                                   := false;
    variable v_invalid_count         : integer                                   := 0;  -- # cycles without valid being asserted
    variable v_waited_this_iteration : boolean                                   := false;
    variable v_ready_low_done        : boolean                                   := false;
    variable v_byte_idx              : integer;
    variable v_word_idx              : integer;
    variable v_ready_low_duration    : integer                                   := config.ready_low_duration;

  begin
    -- If called from sequencer/VVC, show 'axistream_receive()...' in log
    if ext_proc_call = "" then
      write(v_proc_call, local_proc_call);
    else
      -- If called from other BFM procedure like axistream_expect, log 'axistream_expect() while executing axistream_receive()...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    -- DEPRECATE: data_array as t_byte_array will be removed in next major release
    deprecate(local_proc_call, "data_array as t_byte_array has been deprecated. Use data_array as t_slv_array.");

    check_value(config.clock_period /= 0 ns,                    TB_ERROR, "Sanity check: Check that bfm_config.clock_period is set", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(axistream_if.tuser'length <= C_MAX_TUSER_BITS,  TB_ERROR, "Sanity check: Check that C_MAX_TUSER_BITS is high enough for axistream_if.tuser.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(axistream_if.tdata'length >= 8,                 TB_ERROR, "Sanity check: Check that tdata is at least one byte wide. Narrower tdata is not supported.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(axistream_if.tdata'length mod 8 = 0,            TB_ERROR, "Sanity check: Check that tdata is an integer number of bytes wide.",                         scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(axistream_if.tid'length   <= C_MAX_TID_BITS,    TB_ERROR, "Sanity check: Check that C_MAX_TID_BITS is high enough for axistream_if.tid.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(axistream_if.tdest'length <= C_MAX_TDEST_BITS,  TB_ERROR, "Sanity check: Check that C_MAX_TDEST_BITS is high enough for axistream_if.tdest.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(axistream_if.tkeep'length = (axistream_if.tdata'length/8), TB_ERROR, "Sanity check: Check that width of tkeep equals number of bytes in tdata.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(axistream_if.tstrb'length = (axistream_if.tdata'length/8), TB_ERROR, "Sanity check: Check that width of tstrb equals number of bytes in tdata.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(data_array'ascending, TB_ERROR, "Sanity check: Check that data_array is ascending (defined with 'to'), for knowing which byte is sent first", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(user_array'ascending, TB_ERROR, "Sanity check: Check that data_array is ascending (defined with 'to'), for word order clarity", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(strb_array'ascending, TB_ERROR, "Sanity check: Check that strb_array is ascending (defined with 'to'), for word order clarity", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(id_array'ascending,   TB_ERROR, "Sanity check: Check that   id_array is ascending (defined with 'to'), for word order clarity", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(dest_array'ascending, TB_ERROR, "Sanity check: Check that dest_array is ascending (defined with 'to'), for word order clarity", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    -- setup_time and hold_time checking
    check_value(config.setup_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(config.hold_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(config.setup_time > 0 ns, TB_FAILURE, "Sanity check: Check that setup_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(config.hold_time > 0 ns, TB_FAILURE, "Sanity check: Check that hold_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);

    -- Avoid driving inputs
    axistream_if <= init_axistream_if_signals(
      is_master  => false,
      data_width => axistream_if.tdata'length,
      user_width => axistream_if.tuser'length,
      id_width   => axistream_if.tid'length,
      dest_width => axistream_if.tdest'length,
      config     => config );

    -- Ensure ready_default_value of '1' is used if specified.
    if config.ready_default_value = '1' then
      v_ready_low_duration := 0;
    end if;

    -- check if enough room for setup_time in low period
    if (clk = '0') and (config.setup_time > (config.clock_period/2 - clk'last_event))then
      await_value(clk, '1', 0 ns, config.clock_period/2, TB_FAILURE, v_proc_call.all & ": timeout waiting for clk low period for setup_time.");
    end if;
    -- Wait setup_time specified in config record
    wait_until_given_time_before_rising_edge(clk, config.setup_time, config.clock_period);

    log(ID_PACKET_INITIATE, v_proc_call.all & "=> Receive packet. " & add_msg_delimiter(msg), scope, msg_id_panel);

    ------------------------------------------------------------------------------------------------------------
    -- Sample byte by byte. There may be multiple bytes per clock cycle, depending on axistream_if'tdata width.
    ------------------------------------------------------------------------------------------------------------
    while not v_done loop
      v_waited_this_iteration := false;

      --
      -- Set tready low before given word
      --
      if (v_byte_in_word = 0) and
        (config.ready_low_at_word_num = v_byte_cnt/c_num_bytes_per_word) and
        (not v_ready_low_done) then
        axistream_if.tready <= '0';

        -- If we deassert ready before byte 0, keep it deasserted until valid goes high so that it matters
        if config.ready_low_at_word_num = 0 and axistream_if.tvalid = '0' then
          wait until axistream_if.tvalid = '1';

          -- Wait hold time specified in config record
          wait_until_given_time_after_rising_edge(clk, config.hold_time);
        end if;

        --wait for config.ready_low_duration * config.clock_period;
        wait for v_ready_low_duration * config.clock_period;
        v_ready_low_done := true;

      end if;

      axistream_if.tready <= '1';       -- In case it was '0'
      wait for 0 ns;                    -- Wait for signal to change value

      -- Wait until data is transferred: valid and ready
      if axistream_if.tvalid = '1' and axistream_if.tready = '1' then
        v_invalid_count := 0;

        -- Sample data.
        data_array(v_byte_cnt) := axistream_if.tdata(7+8*v_byte_in_word downto 8*v_byte_in_word);

        -- Sample tuser for this transfer (this word): There is one user_array entry per word
        if v_byte_in_word = 0 then
          v_word_idx     := v_byte_cnt/c_num_bytes_per_word;
          if (v_word_idx <= user_array'high) then  -- Include this 'if' to allow a shorter user_array if the caller doesn't care what tuser is
            user_array(v_byte_cnt/c_num_bytes_per_word)(c_num_user_bits_per_word-1 downto 0) := axistream_if.tuser(c_num_user_bits_per_word-1 downto 0);
          end if;
          if (v_word_idx <= strb_array'high) then  -- Include this 'if' to allow a shorter *_array if the caller doesn't care what tstrb is
            strb_array(v_byte_cnt/c_num_bytes_per_word)(c_num_strb_bits_per_word-1 downto 0) := axistream_if.tstrb(c_num_strb_bits_per_word-1 downto 0);
          end if;
          if (v_word_idx <= id_array'high) then  -- Include this 'if' to allow a shorter *_array if the caller doesn't care what tid is
            id_array(v_byte_cnt/c_num_bytes_per_word)(c_num_id_bits_per_word-1 downto 0) := axistream_if.tid(c_num_id_bits_per_word-1 downto 0);
          end if;
          if (v_word_idx <= dest_array'high) then  -- Include this 'if' to allow a shorter *_array if the caller doesn't care what tdest is
            dest_array(v_byte_cnt/c_num_bytes_per_word)(c_num_dest_bits_per_word-1 downto 0) := axistream_if.tdest(c_num_dest_bits_per_word-1 downto 0);
          end if;
        end if;

        log(ID_PACKET_DATA, v_proc_call.all & "=> Rx " & to_string(data_array(v_byte_cnt), HEX, AS_IS, INCL_RADIX) &
        --     ", tuser=" & to_string(user_array(v_byte_cnt/c_num_bytes_per_word), HEX, AS_IS, INCL_RADIX) &
        --     ", tstrb=" & to_string(strb_array(v_byte_cnt/c_num_bytes_per_word), HEX, AS_IS, INCL_RADIX) &
        --     ", tid="   & to_string(id_array(v_byte_cnt/c_num_bytes_per_word),   HEX, AS_IS, INCL_RADIX) &
        --     ", tdest=" & to_string(dest_array(v_byte_cnt/c_num_bytes_per_word), HEX, AS_IS, INCL_RADIX) &
            " (byte# " & to_string(v_byte_cnt) & "). " & add_msg_delimiter(msg), scope, msg_id_panel);

        -- Check tlast='1' at expected last byte
        if v_byte_cnt = data_array'high then
          check_value(axistream_if.tlast, '1', config.protocol_error_severity, "Check tlast at expected last byte = " & to_string(v_byte_cnt) & ". " & add_msg_delimiter(msg), scope);

          v_done := true;  -- Stop sampling data when we have filled the data_array
        end if;

        -- Allow that tlast arrives sooner than indicated by data_array'high
        -- if receive() is called without knowing the length to be expected.
        if axistream_if.tlast = '1' then
          if axistream_if.tkeep(v_byte_in_word) = '1' then
            if v_byte_in_word = c_num_bytes_per_word-1 then
              -- it's the last byte in word and tlast='1', thus the last in packet.
              v_done := true;
            else
              if axistream_if.tkeep(v_byte_in_word+1) = '0' then
                -- Next byte in word is invalid, so this is the last byte
                v_done := true;

                -- Check that tkeep for the remaining bytes in the last word are also '0'. (Only continous stream supported)
                v_byte_idx := v_byte_in_word+1;
                l_check_remaining_TKEEP: loop
                  check_value(axistream_if.tkeep(v_byte_idx), '0', ERROR, "Check that tkeep doesn't go from '1' to '0' to '1' again within this last word. (The BFM supports only continuous stream)", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
                  if v_byte_idx < (axistream_if.tkeep'length-1) then
                    v_byte_idx := v_byte_idx + 1;
                  else
                    exit l_check_remaining_TKEEP;
                  end if;
                end loop;

              end if;
            end if;
          end if;
        else

          -- tlast = 0
          if (v_byte_cnt = data_array'high) then
            alert(config.protocol_error_severity, v_proc_call.all & "=> Failed. tlast not received, expected at or before byte#" & to_string(v_byte_cnt) & ". " & add_msg_delimiter(msg), scope);
          end if;
          -- Check that all tkeep bits are '1'. (Only continous stream supported)
          check_value(axistream_if.tkeep(v_byte_in_word), '1', ERROR, "When tlast='0', check that all tkeep bits are '1'. (The BFM supports only continuous stream)" & add_msg_delimiter(msg), scope, ID_NEVER, msg_id_panel, v_proc_call.all);
        end if;

        if v_byte_in_word = c_num_bytes_per_word-1 then
          -- Next byte is in the next clk cycle
          wait for config.clock_period;
          v_waited_this_iteration := true;
          v_byte_in_word          := 0;
        else
          -- Next byte is in the same clk cycle
          v_byte_in_word := v_byte_in_word + 1;
        end if;

        -- Next byte
        v_byte_cnt := v_byte_cnt + 1;

      else
        -- (tvalid and tready) = '0'
        -- Check for timeout (also when max_wait_cycles_severity = NO_ALERT,
        --                    or else the VVC will wait forever, until the UVVM cmd times out)
        if (v_invalid_count >= config.max_wait_cycles) then
          v_timeout := true;
          v_done    := true;
        else
          v_invalid_count := v_invalid_count + 1;
        end if;

        wait for config.clock_period;
        v_waited_this_iteration := true;

      end if;

    end loop;  -- while not v_done

    data_length := v_byte_cnt;

    -- did we time out?
    if v_timeout then
      alert(config.max_wait_cycles_severity, v_proc_call.all & "=> Failed. Timeout while waiting for valid data. " & add_msg_delimiter(msg), scope);
    else
      log(ID_PACKET_COMPLETE, v_proc_call.all & "=> Rx DONE (" & to_string(v_byte_cnt) & "B)" &
          ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;

    if not v_waited_this_iteration then
      -- Avoid sampling the same word again if the BFM is called again immediately
      wait for config.clock_period;
    end if;

    -- Done, set axistream back to default
    axistream_if <= init_axistream_if_signals(
      is_master  => false,
      data_width => axistream_if.tdata'length,
      user_width => axistream_if.tuser'length,
      id_width   => axistream_if.tid'length,
      dest_width => axistream_if.tdest'length,
      config     => config );
  end procedure axistream_receive_bytes;
  -- Overloaded t_slv_array procedure
  procedure axistream_receive (
    variable data_array   : inout t_slv_array;
    variable data_length  : inout natural;  -- Number of bytes received
    variable user_array   : inout t_user_array;
    variable strb_array   : inout t_strb_array;
    variable id_array     : inout t_id_array;
    variable dest_array   : inout t_dest_array;
    constant msg          : in    string;
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call: in    string                 := "" -- External proc_call; overwrite if called from other BFM procedure like axistream_expect
    ) is    -- helper variables
    variable v_bytes_in_word        : integer := (data_array(0)'length/8);
    variable v_num_bytes            : integer := (data_array'length) * v_bytes_in_word;
    variable v_data_array_as_byte   : t_byte_array(0 to v_num_bytes-1);
    variable v_byte_endianness      : t_byte_endianness := config.byte_endianness;

    begin
      -- call overloaded t_byte_array procedure
      axistream_receive_bytes ( v_data_array_as_byte,
                                data_length, user_array, strb_array, id_array, dest_array, msg,
                                clk, axistream_if, scope, msg_id_panel, config, ext_proc_call  );

      data_array := convert_byte_array_to_slv_array(v_data_array_as_byte, v_bytes_in_word, v_byte_endianness);
    end procedure axistream_receive;


  -- Overloaded version without records
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_receive_bytes (
    variable data_array          : inout t_byte_array;
    variable data_length         : inout natural;  -- Number of bytes received
    variable user_array          : inout t_user_array;
    variable strb_array          : inout t_strb_array;
    variable id_array            : inout t_id_array;
    variable dest_array          : inout t_dest_array;
    constant msg                 : in    string;
    signal   clk                 : in    std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in    string                   := C_SCOPE;
    constant msg_id_panel        : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config              : in    t_axistream_bfm_config   := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call       : in    string                   := "" -- External proc_call; overwrite if called from other BFM procedure like axistream_expect
  ) is
  begin
    -- Simply call the record version
    axistream_receive_bytes(
      data_array          => data_array,
      data_length         => data_length,
      user_array          => user_array,
      strb_array          => strb_array,
      id_array            => id_array,
      dest_array          => dest_array,
      msg                 => msg,
      clk                 => clk,
      axistream_if.tdata  => axistream_if_tdata,
      axistream_if.tkeep  => axistream_if_tkeep,
      axistream_if.tuser  => axistream_if_tuser,
      axistream_if.tstrb  => axistream_if_tstrb,
      axistream_if.tid    => axistream_if_tid,
      axistream_if.tdest  => axistream_if_tdest,
      axistream_if.tvalid => axistream_if_tvalid,
      axistream_if.tlast  => axistream_if_tlast,
      axistream_if.tready => axistream_if_tready,
      scope               => scope,
      msg_id_panel        => msg_id_panel,
      config              => config,
      ext_proc_call       => ext_proc_call);
  end procedure axistream_receive_bytes;
  -- Overloading t_slv_array procedure
  procedure axistream_receive (
    variable data_array          : inout t_slv_array;
    variable data_length         : inout natural;  -- Number of bytes received
    variable user_array          : inout t_user_array;
    variable strb_array          : inout t_strb_array;
    variable id_array            : inout t_id_array;
    variable dest_array          : inout t_dest_array;
    constant msg                 : in    string;
    signal   clk                 : in    std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in    string                   := C_SCOPE;
    constant msg_id_panel        : in    t_msg_id_panel           := shared_msg_id_panel;
    constant config              : in    t_axistream_bfm_config   := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call       : in    string                   := "" -- External proc_call; overwrite if called from other BFM procedure like axistream_expect
  ) is
  begin
    -- Simply call the record version
    axistream_receive(
      data_array          => data_array,
      data_length         => data_length,
      user_array          => user_array,
      strb_array          => strb_array,
      id_array            => id_array,
      dest_array          => dest_array,
      msg                 => msg,
      clk                 => clk,
      axistream_if.tdata  => axistream_if_tdata,
      axistream_if.tkeep  => axistream_if_tkeep,
      axistream_if.tuser  => axistream_if_tuser,
      axistream_if.tstrb  => axistream_if_tstrb,
      axistream_if.tid    => axistream_if_tid,
      axistream_if.tdest  => axistream_if_tdest,
      axistream_if.tvalid => axistream_if_tvalid,
      axistream_if.tlast  => axistream_if_tlast,
      axistream_if.tready => axistream_if_tready,
      scope               => scope,
      msg_id_panel        => msg_id_panel,
      config              => config,
      ext_proc_call       => ext_proc_call);
  end procedure axistream_receive;



  --------------------------------------------------------
  --
  -- AXIStream Expect
  --
  --------------------------------------------------------

  -- Receive data, then compare the received data against exp_data_array
  -- - If the received data is inconsistent with the expected data, an alert with
  --   severity 'alert_level' is triggered.
  -- DEPRECATE: procedure with exp_data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes (
    constant exp_data_array : in    t_byte_array;  -- Expected data
    constant exp_user_array : in    t_user_array;  -- Expected tuser
    constant exp_strb_array : in    t_strb_array;  -- Expected tstrb
    constant exp_id_array   : in    t_id_array;    -- Expected tid
    constant exp_dest_array : in    t_dest_array;  -- Expected tdest
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in    t_alert_level          := error;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
    constant proc_name : string := "axistream_expect";
    constant proc_call : string := "axistream_expect(" & to_string(exp_data_array'length) & "B)";

    constant c_num_bytes_per_word     : natural := axistream_if.tdata'length/8;
    constant c_num_user_bits_per_word : natural := axistream_if.tuser'length;
    constant c_num_strb_bits_per_word : natural := axistream_if.tstrb'length;
    constant c_num_id_bits_per_word   : natural := axistream_if.tid'length;
    constant c_num_dest_bits_per_word : natural := axistream_if.tdest'length;

    -- Helper variables
    variable v_config             : t_axistream_bfm_config := config;
    variable v_rx_data_array      : t_byte_array(exp_data_array'range);  -- received data
    variable v_rx_user_array      : t_user_array(exp_user_array'range);  -- received tuser
    variable v_rx_strb_array      : t_strb_array(exp_strb_array'range);
    variable v_rx_id_array        : t_id_array(exp_id_array'range);
    variable v_rx_dest_array      : t_dest_array(exp_dest_array'range);
    variable v_rx_data_length     : natural;
    variable v_data_error_cnt     : natural                := 0;
    variable v_user_error_cnt     : natural                := 0;
    variable v_strb_error_cnt     : natural                := 0;
    variable v_id_error_cnt       : natural                := 0;
    variable v_dest_error_cnt     : natural                := 0;
    variable v_first_errored_byte : natural;
  begin
    -- Make the receive() procedure check tlast position is as expected
    v_config.check_packet_length := true;

    -- Receive and store data
    axistream_receive_bytes(data_array   => v_rx_data_array,
                      data_length  => v_rx_data_length,
                      user_array   => v_rx_user_array,
                      strb_array   => v_rx_strb_array,
                      id_array     => v_rx_id_array,
                      dest_array   => v_rx_dest_array,
                      msg          => msg,
                      clk          => clk,
                      axistream_if => axistream_if,
                      scope        => scope,
                      msg_id_panel => msg_id_panel,
                      config       => v_config,
                      ext_proc_call => proc_call);

    -- Check if each received bit matches the expected
    -- Find and report the first errored byte
    for byte in v_rx_data_array'high downto 0 loop
      for i in v_rx_data_array(byte)'range loop
        if (exp_data_array(byte)(i) = '-') or  -- Expected set to don't care, or
          (v_rx_data_array(byte)(i) = exp_data_array(byte)(i)) then  -- received value matches expected
          -- Check is OK
        else
          -- Received byte does not match the expected byte
          --log(config.id_for_bfm, proc_call & "=> NOK, checked " & to_string(v_rx_data_array(byte), HEX, AS_IS, INCL_RADIX) & "=" & to_string(exp_data_array(byte), HEX, AS_IS, INCL_RADIX) & msg, scope, msg_id_panel);
          v_data_error_cnt     := v_data_error_cnt + 1;
          v_first_errored_byte := byte;
        end if;
      end loop;
    end loop;

    -- Check tuser matches exp_user_array
    -- Check all bits the exp_user_array. If the caller (Test Sequencer or VVC) don't care, the length of exp_user_array input shall be only one
    for word in exp_user_array'high downto 0 loop
      for i in c_num_user_bits_per_word-1 downto 0 loop              -- i = bit
        if (exp_user_array(word)(i) = '-') or  -- Expected set to don't care, or
          (v_rx_user_array(word)(i) = exp_user_array(word)(i)) then  -- received value matches expected
          -- Check is OK
          -- log(ID_PACKET_COMPLETE, proc_call & "=> OK(word="&to_string(word)&"), checked " & to_string(v_rx_user_array(word), HEX, AS_IS, INCL_RADIX) & "=" & to_string(exp_user_array(word), HEX, AS_IS, INCL_RADIX) & msg, scope, msg_id_panel);
        else
          log(ID_PACKET_DATA, proc_call & "=> NOK(word="&to_string(word)&"), checked " & to_string(v_rx_user_array(word), HEX, AS_IS, INCL_RADIX) & "=" & to_string(exp_user_array(word), HEX, AS_IS, INCL_RADIX) & add_msg_delimiter(msg), scope, msg_id_panel);
          -- Received tuser word does not match the expected word
          v_user_error_cnt     := v_user_error_cnt + 1;
          v_first_errored_byte := word;
        end if;
      end loop;
    end loop;

    -- Check that all bits in exp_strb_array matches received tstrb
    for word in exp_strb_array'high downto 0 loop
      for i in c_num_strb_bits_per_word-1 downto 0 loop              -- i = bit
        if (exp_strb_array(word)(i) = '-') or  -- Expected set to don't care, or
          (v_rx_strb_array(word)(i) = exp_strb_array(word)(i)) then  -- received value matches expected
          -- Check is OK
          -- log(ID_PACKET_COMPLETE, proc_call & "=> OK(word="&to_string(word)&"), checked " & to_string(v_rx_strb_array(word), HEX, AS_IS, INCL_RADIX) & "=" & to_string(exp_strb_array(word), HEX, AS_IS, INCL_RADIX) & msg, scope, msg_id_panel);
        else
          log(ID_PACKET_DATA, proc_call & "=> NOK(word="&to_string(word)&"), checked " & to_string(v_rx_strb_array(word), HEX, AS_IS, INCL_RADIX) & "=" & to_string(exp_strb_array(word), HEX, AS_IS, INCL_RADIX) & add_msg_delimiter(msg), scope, msg_id_panel);
          -- Received tstrb word does not match the expected word
          v_strb_error_cnt     := v_strb_error_cnt + 1;
          v_first_errored_byte := word;
        end if;
      end loop;
    end loop;

    -- Check that all bits in exp_id_array matches received tid
    for word in exp_id_array'high downto 0 loop
      for i in c_num_id_bits_per_word-1 downto 0 loop              -- i = bit
        if (exp_id_array(word)(i) = '-') or  -- Expected set to don't care, or
          (v_rx_id_array(word)(i) = exp_id_array(word)(i)) then  -- received value matches expected
          -- Check is OK
          -- log(ID_PACKET_COMPLETE, proc_call & "=> OK(word="&to_string(word)&"), checked " & to_string(v_rx_id_array(word), HEX, AS_IS, INCL_RADIX) & "=" & to_string(exp_id_array(word), HEX, AS_IS, INCL_RADIX) & msg, scope, msg_id_panel);
        else
          log(ID_PACKET_DATA, proc_call & "=> NOK(word="&to_string(word)&"), checked " & to_string(v_rx_id_array(word), HEX, AS_IS, INCL_RADIX) & "=" & to_string(exp_id_array(word), HEX, AS_IS, INCL_RADIX) & add_msg_delimiter(msg), scope, msg_id_panel);
          -- Received tid word does not match the expected word
          v_id_error_cnt     := v_id_error_cnt + 1;
          v_first_errored_byte := word;
        end if;
      end loop;
    end loop;

    -- Check that all bits in exp_dest_array matches received tdest
    for word in exp_dest_array'high downto 0 loop
      for i in c_num_dest_bits_per_word-1 downto 0 loop              -- i = bit
        if (exp_dest_array(word)(i) = '-') or  -- Expected set to don't care, or
          (v_rx_dest_array(word)(i) = exp_dest_array(word)(i)) then  -- received value matches expected
          -- Check is OK
          -- log(ID_PACKET_COMPLETE, proc_call & "=> OK(word="&to_string(word)&"), checked " & to_string(v_rx_dest_array(word), HEX, AS_IS, INCL_RADIX) & "=" & to_string(exp_dest_array(word), HEX, AS_IS, INCL_RADIX) & msg, scope, msg_id_panel);
        else
          log(ID_PACKET_DATA, proc_call & "=> NOK(word="&to_string(word)&"), checked " & to_string(v_rx_dest_array(word), HEX, AS_IS, INCL_RADIX) & "=" & to_string(exp_dest_array(word), HEX, AS_IS, INCL_RADIX) & add_msg_delimiter(msg), scope, msg_id_panel);
          -- Received tdest word does not match the expected word
          v_dest_error_cnt     := v_dest_error_cnt + 1;
          v_first_errored_byte := word;
        end if;
      end loop;
    end loop;

    -- No more than one alert per packet
    if v_data_error_cnt /= 0 then
      alert(alert_level, proc_call & "=> Failed in "& to_string(v_data_error_cnt) & " data bits. First mismatch in byte# " & to_string(v_first_errored_byte) & ". Was " & to_string(v_rx_data_array(v_first_errored_byte), HEX, AS_IS, INCL_RADIX) & ". Expected " & to_string(exp_data_array(v_first_errored_byte), HEX, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
    elsif v_user_error_cnt /= 0 then
      alert(alert_level, proc_call & "=> Failed in "& to_string(v_user_error_cnt) & " tuser bits. First mismatch in word# " & to_string(v_first_errored_byte) & ". Was " & to_string(v_rx_user_array(v_first_errored_byte)(c_num_user_bits_per_word-1 downto 0), HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX) & ". Expected " & to_string(exp_user_array(v_first_errored_byte)(c_num_user_bits_per_word-1 downto 0), HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
    elsif v_strb_error_cnt /= 0 then
      alert(alert_level, proc_call & "=> Failed in "& to_string(v_strb_error_cnt) & " tstrb bits. First mismatch in word# " & to_string(v_first_errored_byte) & ". Was " & to_string(v_rx_strb_array(v_first_errored_byte)(c_num_strb_bits_per_word-1 downto 0), HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX) & ". Expected " & to_string(exp_strb_array(v_first_errored_byte)(c_num_strb_bits_per_word-1 downto 0), HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
    elsif v_id_error_cnt /= 0 then
      alert(alert_level, proc_call & "=> Failed in "& to_string(v_id_error_cnt)   & " tid bits. First mismatch in word# " & to_string(v_first_errored_byte)   & ". Was " & to_string(v_rx_id_array(v_first_errored_byte)(c_num_id_bits_per_word-1 downto 0), HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX) & ". Expected " & to_string(exp_id_array(v_first_errored_byte)(c_num_id_bits_per_word-1 downto 0), HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
    elsif v_dest_error_cnt /= 0 then
      alert(alert_level, proc_call & "=> Failed in "& to_string(v_dest_error_cnt) & " tdest bits. First mismatch in word# " & to_string(v_first_errored_byte) & ". Was " & to_string(v_rx_dest_array(v_first_errored_byte)(c_num_dest_bits_per_word-1 downto 0), HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX) & ". Expected " & to_string(exp_dest_array(v_first_errored_byte)(c_num_dest_bits_per_word-1 downto 0), HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
    else
      log(config.id_for_bfm, proc_call & "=> OK, received " & to_string(v_rx_data_array'length) & "B. " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;

  end procedure axistream_expect_bytes;
  -----------------------
  -- t_slv_array overload
  -----------------------
  procedure axistream_expect (
    constant exp_data_array : in    t_slv_array;  -- Expected data
    constant exp_user_array : in    t_user_array;  -- Expected tuser
    constant exp_strb_array : in    t_strb_array;  -- Expected tstrb
    constant exp_id_array   : in    t_id_array;    -- Expected tid
    constant exp_dest_array : in    t_dest_array;  -- Expected tdest
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in    t_alert_level          := error;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name    : string := "axistream_expect";  -- Internal proc_name; used if called from sequncer or VVC
    -- helper variables
    variable v_bytes_in_word        : integer := (exp_data_array(0)'length/8);
    variable v_num_bytes            : integer := (exp_data_array'length) * v_bytes_in_word;
    variable v_exp_data_array       : t_byte_array(0 to v_num_bytes-1);
    variable v_exp_data_array_idx   : integer := 0;
    variable v_check_ok             : boolean := false;
    variable v_dummy                : t_slv_array(0 to 0)(31 downto 0);
    variable v_byte_endianness      : t_byte_endianness := config.byte_endianness;

  begin
    -- t_slv_array sanity check
    v_check_ok := check_value(exp_data_array(0)'length mod 8 = 0, TB_ERROR, "Sanity check: Check that exp_data_array is N*byte");

    if v_check_ok then
      -- copy byte(s) from t_slv_array to t_byte_array
      v_exp_data_array := convert_slv_array_to_byte_array(exp_data_array, true, v_byte_endianness); -- exp_data_array is ascending

      -- call t_byte_array overloaded procedure
      axistream_expect_bytes(v_exp_data_array,
                      exp_user_array,
                      exp_strb_array,
                      exp_id_array,
                      exp_dest_array,
                      msg,
                      clk,
                      axistream_if,
                      alert_level,
                      scope,
                      msg_id_panel,
                      config);
    end if;
  end procedure;
  -----------------------
  -- std_logic_vector overload
  -----------------------
  procedure axistream_expect (
    constant exp_data_array : in    std_logic_vector;  -- Expected data
    constant exp_user_array : in    t_user_array;  -- Expected tuser
    constant exp_strb_array : in    t_strb_array;  -- Expected tstrb
    constant exp_id_array   : in    t_id_array;    -- Expected tid
    constant exp_dest_array : in    t_dest_array;  -- Expected tdest
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in    t_alert_level          := error;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
    constant local_proc_name  : string := "axistream_expect";  -- Internal proc_name; used if called from sequncer or VVC
    -- helper variables
    variable v_exp_data_array : t_slv_array(0 to 0)(exp_data_array'length-1 downto 0);
    variable v_check_ok       : boolean := false;
  begin
    -- t_slv_array sanity check
    v_check_ok := check_value(exp_data_array'length mod 8 = 0, TB_ERROR, "Sanity check: Check that exp_data_array word is N*byte");

    if v_check_ok then
      v_exp_data_array(0) := exp_data_array;
      -- call t_slv_array overloaded procedure
      axistream_expect(v_exp_data_array,
                      exp_user_array,
                      exp_strb_array,
                      exp_id_array,
                      exp_dest_array,
                      msg,
                      clk,
                      axistream_if,
                      alert_level,
                      scope,
                      msg_id_panel,
                      config);
    end if;
  end procedure;


  -- Overloaded version without records
  -- DEPRECATE: procedure with exp_data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes (
    constant exp_data_array      : in    t_byte_array;  -- Expected data
    constant exp_user_array      : in    t_user_array;  -- Expected tuser
    constant exp_strb_array      : in    t_strb_array;  -- Expected tstrb
    constant exp_id_array        : in    t_id_array;    -- Expected tid
    constant exp_dest_array      : in    t_dest_array;  -- Expected tdest
    constant msg                 : in    string;
    signal   clk                 : in    std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant alert_level         : in    t_alert_level           := error;
    constant scope               : in    string                  := C_SCOPE;
    constant msg_id_panel        : in    t_msg_id_panel          := shared_msg_id_panel;
    constant config              : in    t_axistream_bfm_config  := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
  begin
    -- Simply call the record version
    axistream_expect_bytes(
      exp_data_array      => exp_data_array,
      exp_user_array      => exp_user_array,
      exp_strb_array      => exp_strb_array,
      exp_id_array        => exp_id_array,
      exp_dest_array      => exp_dest_array,
      msg                 => msg,
      clk                 => clk,
      axistream_if.tdata  => axistream_if_tdata,
      axistream_if.tkeep  => axistream_if_tkeep,
      axistream_if.tuser  => axistream_if_tuser,
      axistream_if.tstrb  => axistream_if_tstrb,
      axistream_if.tid    => axistream_if_tid,
      axistream_if.tdest  => axistream_if_tdest,
      axistream_if.tvalid => axistream_if_tvalid,
      axistream_if.tlast  => axistream_if_tlast,
      axistream_if.tready => axistream_if_tready,
      alert_level         => alert_level,
      scope               => scope,
      msg_id_panel        => msg_id_panel,
      config              => config);
  end procedure;
  -----------------------
  -- t_slv_array overload
  -----------------------
  procedure axistream_expect (
    constant exp_data_array      : in    t_slv_array;  -- Expected data
    constant exp_user_array      : in    t_user_array;  -- Expected tuser
    constant exp_strb_array      : in    t_strb_array;  -- Expected tstrb
    constant exp_id_array        : in    t_id_array;    -- Expected tid
    constant exp_dest_array      : in    t_dest_array;  -- Expected tdest
    constant msg                 : in    string;
    signal   clk                 : in    std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant alert_level         : in    t_alert_level           := error;
    constant scope               : in    string                  := C_SCOPE;
    constant msg_id_panel        : in    t_msg_id_panel          := shared_msg_id_panel;
    constant config              : in    t_axistream_bfm_config  := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
  begin
    -- Simply call the t_slv_array record version
    axistream_expect(
      exp_data_array      => exp_data_array,
      exp_user_array      => exp_user_array,
      exp_strb_array      => exp_strb_array,
      exp_id_array        => exp_id_array,
      exp_dest_array      => exp_dest_array,
      msg                 => msg,
      clk                 => clk,
      axistream_if.tdata  => axistream_if_tdata,
      axistream_if.tkeep  => axistream_if_tkeep,
      axistream_if.tuser  => axistream_if_tuser,
      axistream_if.tstrb  => axistream_if_tstrb,
      axistream_if.tid    => axistream_if_tid,
      axistream_if.tdest  => axistream_if_tdest,
      axistream_if.tvalid => axistream_if_tvalid,
      axistream_if.tlast  => axistream_if_tlast,
      axistream_if.tready => axistream_if_tready,
      alert_level         => alert_level,
      scope               => scope,
      msg_id_panel        => msg_id_panel,
      config              => config);
  end procedure;
  -----------------------
  -- std_logic_vector overload
  -----------------------
  procedure axistream_expect (
    constant exp_data_array      : in    std_logic_vector;  -- Expected data
    constant exp_user_array      : in    t_user_array;  -- Expected tuser
    constant exp_strb_array      : in    t_strb_array;  -- Expected tstrb
    constant exp_id_array        : in    t_id_array;    -- Expected tid
    constant exp_dest_array      : in    t_dest_array;  -- Expected tdest
    constant msg                 : in    string;
    signal   clk                 : in    std_logic;
    signal   axistream_if_tdata  : inout std_logic_vector;
    signal   axistream_if_tkeep  : inout std_logic_vector;
    signal   axistream_if_tuser  : inout std_logic_vector;
    signal   axistream_if_tstrb  : inout std_logic_vector;
    signal   axistream_if_tid    : inout std_logic_vector;
    signal   axistream_if_tdest  : inout std_logic_vector;
    signal   axistream_if_tvalid : inout std_logic;
    signal   axistream_if_tlast  : inout std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant alert_level         : in    t_alert_level           := error;
    constant scope               : in    string                  := C_SCOPE;
    constant msg_id_panel        : in    t_msg_id_panel          := shared_msg_id_panel;
    constant config              : in    t_axistream_bfm_config  := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
  begin
    -- Simply call the slv record version
    axistream_expect(
      exp_data_array      => exp_data_array,
      exp_user_array      => exp_user_array,
      exp_strb_array      => exp_strb_array,
      exp_id_array        => exp_id_array,
      exp_dest_array      => exp_dest_array,
      msg                 => msg,
      clk                 => clk,
      axistream_if.tdata  => axistream_if_tdata,
      axistream_if.tkeep  => axistream_if_tkeep,
      axistream_if.tuser  => axistream_if_tuser,
      axistream_if.tstrb  => axistream_if_tstrb,
      axistream_if.tid    => axistream_if_tid,
      axistream_if.tdest  => axistream_if_tdest,
      axistream_if.tvalid => axistream_if_tvalid,
      axistream_if.tlast  => axistream_if_tlast,
      axistream_if.tready => axistream_if_tready,
      alert_level         => alert_level,
      scope               => scope,
      msg_id_panel        => msg_id_panel,
      config              => config);
  end procedure;



  -- Overload without exp_strb_array, exp_id_array, exp_dest_array arguments' argument
  -- DEPRECATE: procedure with exp_data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes (
    constant exp_data_array : in    t_byte_array;  -- Expected data
    constant exp_user_array : in    t_user_array;  -- Expected tuser
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in    t_alert_level          := error;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
    -- Default value: don't care
    variable v_exp_strb_array : t_strb_array(0 to 0) := (others => (others => '-'));
    variable v_exp_dest_array : t_dest_array(0 to 0) := (others => (others => '-'));
    variable v_exp_id_array   : t_id_array(0 to 0) := (others => (others => '-'));
  begin
    axistream_expect_bytes(exp_data_array,
                     exp_user_array,
                     v_exp_strb_array,
                     v_exp_id_array,
                     v_exp_dest_array,
                     msg,
                     clk,
                     axistream_if,
                     alert_level,
                     scope,
                     msg_id_panel,
                     config);
  end procedure;
  -----------------------
  -- t_slv_array overload
  -----------------------
  procedure axistream_expect (
    constant exp_data_array : in    t_slv_array;  -- Expected data
    constant exp_user_array : in    t_user_array;  -- Expected tuser
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in    t_alert_level          := error;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
    -- Default value: don't care
    variable v_exp_strb_array : t_strb_array(0 to 0) := (others => (others => '-'));
    variable v_exp_dest_array : t_dest_array(0 to 0) := (others => (others => '-'));
    variable v_exp_id_array   : t_id_array(0 to 0) := (others => (others => '-'));
  begin
    -- call overloaded t_slv_array procedure
    axistream_expect(exp_data_array,
                     exp_user_array,
                     v_exp_strb_array,
                     v_exp_id_array,
                     v_exp_dest_array,
                     msg,
                     clk,
                     axistream_if,
                     alert_level,
                     scope,
                     msg_id_panel,
                     config);
  end procedure;
  -----------------------
  -- std_logic_vector overload
  -----------------------
  procedure axistream_expect (
    constant exp_data_array : in    std_logic_vector;  -- Expected data
    constant exp_user_array : in    t_user_array;  -- Expected tuser
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in    t_alert_level          := error;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
    -- Default value: don't care
    variable v_exp_strb_array : t_strb_array(0 to 0) := (others => (others => '-'));
    variable v_exp_dest_array : t_dest_array(0 to 0) := (others => (others => '-'));
    variable v_exp_id_array   : t_id_array(0 to 0) := (others => (others => '-'));
  begin
    -- call overloaded slv procedure
    axistream_expect(exp_data_array,
                     exp_user_array,
                     v_exp_strb_array,
                     v_exp_id_array,
                     v_exp_dest_array,
                     msg,
                     clk,
                     axistream_if,
                     alert_level,
                     scope,
                     msg_id_panel,
                     config);
  end procedure;

  -- Overload without arguments exp_user_array, exp_strb_array, exp_id_array, exp_dest_array arguments
  -- DEPRECATE: procedure with exp_data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes (
    constant exp_data_array : in    t_byte_array;  -- Expected data
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in    t_alert_level          := error;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
    -- Default value: don't care
    variable v_exp_user_array : t_user_array(0 to 0) := (others => (others => '-'));
    variable v_exp_strb_array : t_strb_array(0 to 0) := (others => (others => '-'));
    variable v_exp_dest_array : t_dest_array(0 to 0) := (others => (others => '-'));
    variable v_exp_id_array   : t_id_array(0 to 0) := (others => (others => '-'));
  begin
    axistream_expect_bytes(exp_data_array,
                     v_exp_user_array,
                     v_exp_strb_array,
                     v_exp_id_array,
                     v_exp_dest_array,
                     msg,
                     clk,
                     axistream_if,
                     alert_level,
                     scope,
                     msg_id_panel,
                     config);
  end procedure;
  -----------------------
  -- t_slv_array overload
  -----------------------
  procedure axistream_expect (
    constant exp_data_array : in    t_slv_array;  -- Expected data
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in    t_alert_level          := error;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
    -- Default value: don't care
    variable v_exp_user_array : t_user_array(0 to 0) := (others => (others => '-'));
    variable v_exp_strb_array : t_strb_array(0 to 0) := (others => (others => '-'));
    variable v_exp_dest_array : t_dest_array(0 to 0) := (others => (others => '-'));
    variable v_exp_id_array   : t_id_array(0 to 0) := (others => (others => '-'));
  begin
    -- call overloaded t_slv_array procedure
    axistream_expect(exp_data_array,
                     v_exp_user_array,
                     v_exp_strb_array,
                     v_exp_id_array,
                     v_exp_dest_array,
                     msg,
                     clk,
                     axistream_if,
                     alert_level,
                     scope,
                     msg_id_panel,
                     config);
  end procedure;
  -----------------------
  -- std_logic_vector overload
  -----------------------
  procedure axistream_expect (
    constant exp_data_array : in    std_logic_vector;  -- Expected data
    constant msg            : in    string;
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant alert_level    : in    t_alert_level          := error;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is
    -- Default value: don't care
    variable v_exp_user_array : t_user_array(0 to 0) := (others => (others => '-'));
    variable v_exp_strb_array : t_strb_array(0 to 0) := (others => (others => '-'));
    variable v_exp_dest_array : t_dest_array(0 to 0) := (others => (others => '-'));
    variable v_exp_id_array   : t_id_array(0 to 0) := (others => (others => '-'));
  begin
    -- call overloaded slv procedure
    axistream_expect(exp_data_array,
                     v_exp_user_array,
                     v_exp_strb_array,
                     v_exp_id_array,
                     v_exp_dest_array,
                     msg,
                     clk,
                     axistream_if,
                     alert_level,
                     scope,
                     msg_id_panel,
                     config);
  end procedure;



end package body axistream_bfm_pkg;

