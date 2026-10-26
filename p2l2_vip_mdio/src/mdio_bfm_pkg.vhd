--================================================================================================================================
-- Copyright 2026 UVVM
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

library uvvm_util;
context uvvm_util.uvvm_util_context;

--==========================================================================================
--==========================================================================================
package mdio_bfm_pkg is

  --==========================================================================================
  -- Types and constants for MDIO BFM
  --==========================================================================================
  constant C_BFM_SCOPE : string := "MDIO BFM";

  -- =========================================================================
  -- MDIO Protocol Constants
  -- =========================================================================
  constant C_MDIO_DATA_WIDTH         : natural := 16;
  constant C_MDIO_PHY_ADDR_WIDTH     : natural := 5;  -- Port/PHY Address (Clause 22 & 45)
  constant C_MDIO_DEV_ADDR_WIDTH     : natural := 5;  -- Device Address (Clause 45)
  constant C_MDIO_REG_ADDR_WIDTH_C22 : natural := 5;  -- Register Address (Clause 22)
  constant C_MDIO_REG_ADDR_WIDTH_C45 : natural := 16; -- Register Address (Clause 45)

  constant C_MDIO_PREAMBLE_LENGTH : natural := 32;

  constant C_MDIO_MAX_OUTPUT_DELAY : time := 300 ns; -- IEEE 802.3 22.3.4: PHY drives MDIO 0 to 300 ns after the MDC rising edge

  constant C_MDIO_ST_WIDTH     : natural := 2;
  constant C_MDIO_OP_WIDTH     : natural := 2;
  constant C_MDIO_TA_WIDTH     : natural := 2;
  -- ST OP PHYAD/PRTAD REGAD/DEVAD: the part of a frame that tells who drives the rest
  constant C_MDIO_HEADER_WIDTH : natural := C_MDIO_ST_WIDTH + C_MDIO_OP_WIDTH + 2*C_MDIO_PHY_ADDR_WIDTH;

  constant C_MDIO_ST_CL22           : std_ulogic_vector(C_MDIO_ST_WIDTH-1 downto 0) := "01";
  constant C_MDIO_ST_CL45           : std_ulogic_vector(C_MDIO_ST_WIDTH-1 downto 0) := "00";

  constant C_MDIO_OP_CL22_WRITE     : std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0) := "01";
  constant C_MDIO_OP_CL22_READ      : std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0) := "10";

  constant C_MDIO_OP_CL45_ADDR      : std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0) := "00";
  constant C_MDIO_OP_CL45_WRITE     : std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0) := "01";
  constant C_MDIO_OP_CL45_READ_INC  : std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0) := "10";
  constant C_MDIO_OP_CL45_READ      : std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0) := "11";

  -- Optional interface record for BFM signals
  -- std_logic (resolved) on purpose: MDIO is a tri-state bus with several drivers (STA, PHY, pull-up), and both VVC
  -- roles assign this record. UVVM's check_unwanted_activity() also only takes std_logic signals.
  type t_mdio_if is record
    mdc  : std_logic; -- clock
    mdio : std_logic; -- data
  end record t_mdio_if;

  -- PHY-role identity: the bus address this emulated device responds to.
  -- Used as PHYAD for clause 22 access and as PRTAD for clause 45 access -
  -- both name the same physical device, so a single field covers both.
  -- DEVAD is NOT here: a complete PHY implements several MMDs (each with
  -- its own DEVAD), so DEVAD is a per-call target, not a fixed identity -
  -- see the "dev_addr" parameter on the clause 45 procedures below.
  -- Only relevant when this BFM/VVC instance plays the PHY (target) role.
  type t_mdio_phy_bfm_config is record
    phy_address                  : unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);         -- own address: PHYAD (clause 22) / PRTAD (clause 45)
    -- max time between MDC edges within a frame ("bus is dead"
    -- watchdog - MDC has no minimum frequency, keep it generous)
    max_wait_mdc_change          : time;
    max_wait_mdc_change_severity : t_alert_level; -- the above timeout will have this severity
    -- default max time an mdio_phy_* call waits for its frame to
    -- start, overridable per call. 0 ns = no timeout.
    timeout                      : time;
    timeout_severity             : t_alert_level; -- the above timeout will have this severity
  end record t_mdio_phy_bfm_config;

  constant C_MDIO_PHY_BFM_CONFIG_DEFAULT : t_mdio_phy_bfm_config := (
    phy_address                  => 5x"1",
    max_wait_mdc_change          => 1 ms,
    max_wait_mdc_change_severity => FAILURE, -- bus is dead
    timeout                      => 10 ms,
    timeout_severity             => ERROR
  );

  -- STA-role settings. Only relevant when this BFM/VVC instance plays the STA (bus master) role.
  -- The STA drives MDC and the frame timing from the shared min_mdc_* settings of t_mdio_bfm_config.
  type t_mdio_sta_bfm_config is record
    mdc_period                     : time;          -- period of the MDC the STA generates (50 % duty cycle)
    -- '1' bits (one MDC cycle each) sent before ST, ignored with suppress_preamble.
    -- IEEE 802.3 22.2.4.5.2 requires 32. Other values are for negative tests: a PHY
    -- must not respond to a frame preceded by fewer than 32 contiguous ones (more
    -- must be accepted). A '1' right before the preamble counts as well: the IDLE
    -- bits of the previous frame (pulled up) or, with idle_cycles = 0, its last data bit.
    preamble_length                : natural;
    -- IDLE bits after every frame: MDC keeps running for this many periods with MDIO
    -- released (IEEE 802.3 22.2.4.5: IDLE is high-impedance, the pull-up holds '1').
    -- At least one is needed between frames without preamble, so that a PHY sees a '1'
    -- between the last data bit and ST. 0 ends the call one low phase after the last
    -- data bit, for negative tests (back-to-back frames without IDLE).
    idle_cycles                    : natural;
    -- PHY did not drive '0' in the second turnaround bit of a read.
    -- NO_ALERT disables the check.
    turnaround_not_driven_severity : t_alert_level;
  end record t_mdio_sta_bfm_config;

  constant C_MDIO_STA_BFM_CONFIG_DEFAULT : t_mdio_sta_bfm_config := (
    mdc_period                     => 400 ns, -- = min_mdc_period default
    preamble_length                => C_MDIO_PREAMBLE_LENGTH,
    idle_cycles                    => 1,
    turnaround_not_driven_severity => ERROR
  );

  -- Configuration record to be assigned in the test harness.
  type t_mdio_bfm_config is record
    min_setup_time            : time;     -- minimum time the mdio line needs to be stable before a rising clock edge
    min_hold_time             : time;     -- minimum time the mdio line needs to be stable after a rising edge on clock
    min_mdc_period            : time;     -- minimum time between 2 rising edges on the clock line
    min_mdc_high_time         : time;     -- minimum time the clock line has to be high in a clock period
    min_mdc_low_time          : time;     -- minimum time the clock line has to be low in a clock period
    output_delay              : time;     -- time between rising edge of clock and output of data (must be between 0 ns and 300 ns!)
    id_for_bfm                : t_msg_id; -- To replace default log msg IDs
    id_for_bfm_wait           : t_msg_id; -- To replace default log msg IDs
    suppress_preamble         : boolean;  -- the STA sends no preamble (frame starts directly with ST)
    -- true: a call started during other bus activity waits for the next frame start
    --      (32 ones + ST, or just ST if suppress_preamble).
    -- false: the frame is expected to start at the next rising edge: the ones
    --      up to the first '0' are the preamble (must be 32), or ST itself if
    --      suppress_preamble. Only applies to the first frame of a call.
    sync_to_frame_start       : boolean;
    -- the frame breaks the MDIO protocol. PHY role: preamble only pulled up (not driven by
    -- the STA), turnaround not "10" in a write / address frame or second turnaround bit
    -- of a read to another target driven to anything but '0' (undriven = no PHY at that
    -- address, not reported), undefined bits ('X', 'U', 'Z', ...) in the
    -- ST / OP / address fields of any frame or in the data written by the STA, and with
    -- sync_to_frame_start = false a preamble shorter than 32 bits (the frame is still
    -- received) or, with suppress_preamble, a frame not starting at the next rising edge
    -- (the call is aborted). STA role: undefined bits in the data read from the PHY.
    -- NO_ALERT disables the checks, e.g. when frames are broken on purpose.
    protocol_error_severity   : t_alert_level;
    -- the bus does not show what this role drives, or is driven where it must be released.
    -- PHY role: reply bits, first turnaround bit of a read not released by the STA.
    -- STA role: frame bits, first turnaround bit of a read, IDLE after the frame.
    -- NO_ALERT disables the check.
    bus_contention_severity   : t_alert_level;
    -- the configured timing of this role is out of spec. STA role: mdc_period (or one of
    -- its halves) below min_mdc_period / min_mdc_high_time / min_mdc_low_time, output_delay
    -- below min_hold_time or leaving less than min_setup_time before the next MDC edge,
    -- for reads an mdc_period below 300 ns + min_setup_time. PHY role (reply procedures):
    -- output_delay above 300 ns (IEEE 802.3 22.3.4). NO_ALERT allows out-of-spec timing
    -- on purpose, e.g. to test how the other side reacts.
    timing_violation_severity : t_alert_level;
    phy                       : t_mdio_phy_bfm_config; -- PHY-role identity, only used when acting as PHY
    sta                       : t_mdio_sta_bfm_config; -- STA-role settings, only used when acting as STA
  end record t_mdio_bfm_config;

  -- Define the default value for the BFM config
  constant C_MDIO_BFM_CONFIG_DEFAULT : t_mdio_bfm_config := (
    min_setup_time            => 10 ns,
    min_hold_time             => 10 ns,
    min_mdc_period            => 400 ns,
    min_mdc_high_time         => 160 ns,
    min_mdc_low_time          => 160 ns,
    output_delay              => 150 ns,
    id_for_bfm                => ID_BFM,
    id_for_bfm_wait           => ID_BFM_WAIT,
    suppress_preamble         => false,
    sync_to_frame_start       => true,
    protocol_error_severity   => ERROR,
    bus_contention_severity   => ERROR,
    timing_violation_severity => ERROR,
    phy                       => C_MDIO_PHY_BFM_CONFIG_DEFAULT,
    sta                       => C_MDIO_STA_BFM_CONFIG_DEFAULT
  );

  -- Which side of the bus mdio_check_bit_timing() checks. Each role checks the other side, its own timing is
  -- validated from its config by the BFM procedures.
  type t_mdio_timing_check is (
    CHECK_STA,  -- MDC and the bits the STA drives (VVC in PHY mode)
    CHECK_PHY,  -- the bits a PHY drives (VVC in STA mode)
    CHECK_BOTH  -- everything, e.g. a passive check of a bus between two DUTs
  );

  -- Who drives MDIO in a bit time (from one rising MDC edge to the next), i.e. how mdio_check_bit_timing() checks it
  type t_mdio_bit_driver is (
    NOT_CHECKED,   -- before the first MDC edge
    STA_DRIVES,    -- hold after the edge, setup before the next one
    STA_RELEASES,  -- the STA releases MDIO for the first turnaround bit of a read: hold only
    PHY_DRIVES,    -- MDIO settles at most 300 ns after the edge
    PHY_RELEASES   -- the bit after a read: the PHY releases MDIO at most 300 ns after the edge, then it is the STA's (setup)
  );

  -- MDC edges seen by mdio_check_bit_timing(), kept by the caller between the calls. The default value of a variable of
  -- this type (no edge seen yet) needs no initialisation.
  type t_mdio_mdc_edges is record
    rise_seen : boolean;
    last_rise : time;    -- start of the current bit time
    fall_seen : boolean;
    last_fall : time;
  end record t_mdio_mdc_edges;

  -- Who drives turnaround and data of a frame, given by its own ST and OP fields
  type t_mdio_frame_kind is (
    FRAME_STA_DRIVEN, -- write / address-set: the STA drives TA "10" and the data
    FRAME_PHY_DRIVEN, -- read / post-read-increment: the PHY drives TA 'Z','0' and the data
    FRAME_INVALID     -- undefined ST/OP combination
  );

  -- Kind of a frame from its ST and OP fields
  function mdio_get_frame_kind(
    constant st : in std_ulogic_vector(C_MDIO_ST_WIDTH-1 downto 0);
    constant op : in std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0)) return t_mdio_frame_kind;

  -- Fields of a received frame header (ST OP PHYAD/PRTAD REGAD/DEVAD, C_MDIO_HEADER_WIDTH bits, first bit left)
  subtype t_mdio_header is std_ulogic_vector(C_MDIO_HEADER_WIDTH-1 downto 0);
  function mdio_header_st(constant header : in t_mdio_header) return std_ulogic_vector;
  function mdio_header_op(constant header : in t_mdio_header) return std_ulogic_vector;
  function mdio_header_phy_addr(constant header : in t_mdio_header) return std_ulogic_vector;        -- PHYAD (clause 22) / PRTAD (clause 45)
  function mdio_header_reg_or_dev_addr(constant header : in t_mdio_header) return std_ulogic_vector; -- REGAD (clause 22) / DEVAD (clause 45)

  --==========================================================================================
  -- BFM procedures
  --==========================================================================================

  -- Returns a t_mdio_if with MDC and MDIO released ('Z')
  function init_mdio_if_signals return t_mdio_if;

  -- Passive timing check of one bit time: waits for the next rising MDC edge and returns the bit it samples, checking
  -- the bit time according to who drives MDIO in it. The caller follows the frames (see the bus timing check in
  -- mdio_vvc.vhd) and keeps mdc_edges between the calls.
  procedure mdio_check_bit_timing(
    signal   mdio_if      : in t_mdio_if;
    constant driver       : in t_mdio_bit_driver;
    variable mdc_edges    : inout t_mdio_mdc_edges;
    variable sampled      : out std_ulogic;
    constant checked_side : in t_mdio_timing_check;
    constant alert_level  : in t_alert_level     := ERROR;
    constant scope        : in string            := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

  ------------------------------------------------------------------------------------------
  -- PHY-role procedures (mdio_phy_*)
  -- - Each call waits for a frame addressing this PHY (and DEVAD for clause 45), then checks
  --   it (expect_*), answers it (reply_*) or returns what the STA sent (receive_*).
  -- - receive_*: same checks as the matching expect_*, but the 16 bits the STA sends (the data of a
  --   write frame, the register address of an address frame) are returned instead of compared.
  --   The output is set to all 'X' at the start and only assigned once the payload was received
  --   with the right opcode, so a terminated / timed-out call or a frame with a wrong opcode leaves 'X'.
  -- - Frames to other targets are consumed according to their own opcode, and their turnaround
  --   is checked (config.protocol_error_severity). A read to an address without a PHY (second turnaround bit
  --   undriven, e.g. the STA scans the bus) is not reported. Frames with an undefined ST/OP combination are skipped.
  -- - An addressed frame with the wrong opcode is alerted and consumed without driving the bus.
  -- - alert_level: severity when the addressed frame differs from what the call expects: wrong opcode,
  --   wrong register address (clause 22) and, for expect_*, wrong data / register address written by the STA.
  -- - A frame starts with >= 32 preamble '1' bits followed by the ST field. The BFM searches
  --   for this pattern, so a call may start at any time, also in the middle of other traffic.
  --   Frames with a shorter preamble are ignored. Preamble bits the STA does not drive
  --   (only pulled up, 'H') are reported with config.protocol_error_severity.
  -- - Bus checks: undefined bits (not a clear 0/1, 'H'/'L' count as 1/0) in the ST / OP / address fields of
  --   any frame and in STA-written data are reported with config.protocol_error_severity. While replying
  --   to a read, the bus must show what the PHY drives and be released by the STA in the first turnaround
  --   bit, otherwise config.bus_contention_severity applies (part of the call result).
  -- - config.suppress_preamble: the STA sends no preamble, a frame starts directly with ST.
  -- - config.sync_to_frame_start: true (default) waits for the next frame start (see above). false expects
  --   the first frame to start at the next rising edge: a preamble shorter than 32 bits is reported with
  --   config.protocol_error_severity but the frame is still received; with suppress_preamble a first bit
  --   other than '0' aborts the call (same severity). Frames following a consumed
  --   (other-target) frame are synced if suppress_preamble, as their start time is unknown.
  -- - timeout: max wait until the addressed frame starts; a started frame is always completed.
  --   C_UNDEFINED_TIME (default) = config.phy.timeout, 0 ns = no timeout.
  -- - terminate_loop: '1' aborts the call immediately (also mid-frame), releases the bus and
  --   logs ID_TERMINATE_CMD - no alert. The VVC connects its terminate_current_cmd flag here.
  -- - Logging: start of the wait with id_for_bfm_wait, success with id_for_bfm. An MDC stall / timeout
  --   alerts with max_wait_mdc_change_severity / timeout_severity.
  ------------------------------------------------------------------------------------------

  -- PHY: expects a write to 'reg_addr' and compares the data with 'data' (IEEE 802.3 Clause 22)
  procedure mdio_phy_c22_expect_write(
    constant reg_addr       : in unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0);
    constant data           : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : in t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant timeout        : in time              := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

  -- PHY: receives a write to 'reg_addr' and returns the data in 'data' (IEEE 802.3 Clause 22)
  procedure mdio_phy_c22_receive_write(
    constant reg_addr       : in unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0);
    variable data           : out std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : in t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant timeout        : in time              := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

  -- PHY: replies to a read of 'reg_addr' with 'data' (IEEE 802.3 Clause 22)
  procedure mdio_phy_c22_reply_read(
    constant reg_addr       : in unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0);
    constant data           : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant timeout        : in time              := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

  -- PHY: expects an address frame to MMD 'dev_addr' and compares the address with 'reg_addr' (IEEE 802.3 Clause 45)
  procedure mdio_phy_c45_expect_address(
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0); -- target MMD within this PHY
    constant reg_addr       : in unsigned(C_MDIO_REG_ADDR_WIDTH_C45-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : in t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant timeout        : in time              := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

  -- PHY: receives an address frame to MMD 'dev_addr' and returns the address in 'reg_addr' (IEEE 802.3 Clause 45)
  procedure mdio_phy_c45_receive_address(
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0); -- target MMD within this PHY
    variable reg_addr       : out unsigned(C_MDIO_REG_ADDR_WIDTH_C45-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : in t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant timeout        : in time              := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

  -- PHY: expects a write to MMD 'dev_addr' and compares the data with 'data' (IEEE 802.3 Clause 45)
  procedure mdio_phy_c45_expect_write(
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0); -- target MMD within this PHY
    constant data           : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : in t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant timeout        : in time              := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

  -- PHY: receives a write to MMD 'dev_addr' and returns the data in 'data' (IEEE 802.3 Clause 45)
  procedure mdio_phy_c45_receive_write(
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0); -- target MMD within this PHY
    variable data           : out std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : in t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant timeout        : in time              := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

  -- PHY: replies to a read of MMD 'dev_addr' with 'data' (IEEE 802.3 Clause 45)
  procedure mdio_phy_c45_reply_read(
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0); -- target MMD within this PHY
    constant data           : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant timeout        : in time              := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

  -- PHY: replies to a post-read-increment read of MMD 'dev_addr' with 'data' (IEEE 802.3 Clause 45)
  procedure mdio_phy_c45_reply_post_read_increment(
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0); -- target MMD within this PHY
    constant data           : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0); -- data of the current register address, the address is incremented by the PHY afterwards
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant timeout        : in time              := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

  ------------------------------------------------------------------------------------------
  -- STA-role procedures (mdio_sta_*)
  -- - The STA drives MDC and the whole frame, so mdio_if is inout in every procedure. The frame starts
  --   with config.sta.preamble_length '1' bits (32 as required, unless config.suppress_preamble), MDC
  --   runs with config.sta.mdc_period.
  -- - The target is a per-call parameter (phy_addr for clause 22, phy_addr + dev_addr for clause 45),
  --   not config: an STA talks to many PHYs / MMDs, unlike the PHY role (config.phy.phy_address).
  -- - Reads come in two flavours: mdio_sta_*_read returns the data in the output 'data',
  --   mdio_sta_*_check compares it with 'data_exp' and alerts with 'alert_level' on mismatch.
  -- - 'data' is set to all 'X' at the start of a read and only assigned after a complete frame,
  --   so a terminated or timed-out read leaves 'X' (no valid flag - same as e.g. uart_receive).
  -- - No timeout: a read has a fixed length and the STA generates MDC itself, so it never waits for
  --   the PHY. A missing PHY shows as an undriven turnaround (config.sta.turnaround_not_driven_severity).
  -- - MDC: generated by the STA with config.sta.mdc_period, idle low between calls. MDIO is driven
  --   after config.output_delay (shared with the PHY role). Timing that violates the min_* settings
  --   is reported with config.timing_violation_severity.
  -- - terminate_loop: '1' aborts the call, releases the bus and logs ID_TERMINATE_CMD - no alert. In an MDC high
  --   phase the abort waits for the falling edge (at most half an MDC period), so MDC never gets a short high pulse.
  -- - Bus checks: a mismatch is reported with config.bus_contention_severity.
  --   IDLE: after every frame the STA clocks config.sta.idle_cycles IDLE bits with MDIO released. At the end of the
  --   call (one low phase after the last sampling edge) the bus must be undriven ('H' or 'Z'),
  --   i.e. the PHY released it after a read, and nobody drives it after the STA released it after a write.
  --   The PHY BFM has no such check: it doesn't know when to sample, MDC may stop after the last data bit.
  --   Every bit the STA drives must show exactly that on the bus (strong '0' / '1').
  --   Reads: the STA releases MDIO in the first turnaround bit, nobody may drive it there: only 'H' (pull-up) or
  --   'Z' is accepted, anything else is bus contention (config.bus_contention_severity). The PHY must
  --   drive a strong '0' in the second one (config.sta.turnaround_not_driven_severity, e.g. no PHY at that address - the
  --   data is still returned, typically all ones, so this check can be turned off to test for an absent PHY).
  --   Read data: 'H'/'L' count as 1/0, undefined bits are reported with config.protocol_error_severity.
  -- - *_check: compares the read data with 'data_exp' only if turnaround and data were fine, otherwise that
  --   alert is reported instead of a (misleading) data mismatch.
  -- - Reads sample the PHY's bits at the next MDC edge, the PHY may take up to 300 ns to drive them
  --   (IEEE 802.3 22.3.4): a shorter mdc_period is reported with config.timing_violation_severity.
  ------------------------------------------------------------------------------------------

  -- STA: writes 'data' to register 'reg_addr' of PHY 'phy_addr' (IEEE 802.3 Clause 22)
  procedure mdio_sta_c22_write(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant reg_addr       : in unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0);
    constant data           : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

  -- STA: reads register 'reg_addr' of PHY 'phy_addr', returns the data in 'data' (IEEE 802.3 Clause 22)
  procedure mdio_sta_c22_read(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant reg_addr       : in unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0);
    variable data           : out std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

  -- STA: reads register 'reg_addr' of PHY 'phy_addr' and compares the data with 'data_exp' (IEEE 802.3 Clause 22)
  procedure mdio_sta_c22_check(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant reg_addr       : in unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0);
    constant data_exp       : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

  -- STA: address frame, sets register address 'reg_addr' of MMD 'dev_addr' at port 'phy_addr' (IEEE 802.3 Clause 45)
  procedure mdio_sta_c45_address(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    constant reg_addr       : in unsigned(C_MDIO_REG_ADDR_WIDTH_C45-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

  -- STA: address frame as above, 'success' is false if the frame was terminated or an alert was raised for it
  -- (e.g. bus contention). Used to skip the access frame that would follow, see the VVC's *_REG commands.
  procedure mdio_sta_c45_address(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    constant reg_addr       : in unsigned(C_MDIO_REG_ADDR_WIDTH_C45-1 downto 0);
    variable success        : out boolean;
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

  -- STA: writes 'data' to the current register address of MMD 'dev_addr' (IEEE 802.3 Clause 45)
  procedure mdio_sta_c45_write(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    constant data           : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

  -- STA: reads the current register address of MMD 'dev_addr', returns the data in 'data' (IEEE 802.3 Clause 45)
  procedure mdio_sta_c45_read(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    variable data           : out std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

  -- STA: post-read-increment read of MMD 'dev_addr', returns the data in 'data' (IEEE 802.3 Clause 45)
  procedure mdio_sta_c45_post_read_increment(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    variable data           : out std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

  -- STA: reads the current register address of MMD 'dev_addr' and compares the data with 'data_exp' (IEEE 802.3 Clause 45)
  procedure mdio_sta_c45_check(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    constant data_exp       : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

  -- STA: post-read-increment read of MMD 'dev_addr', compares the data with 'data_exp' (IEEE 802.3 Clause 45)
  procedure mdio_sta_c45_check_post_read_increment(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    constant data_exp       : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT);

end package mdio_bfm_pkg;

package body mdio_bfm_pkg is

  -- Result of the bus waits in an mdio_phy_* / mdio_sta_* call - anything but WAIT_OK ends the call.
  -- WAIT_BAD_TIMEOUT, WAIT_TIMEOUT, WAIT_BAD_START and WAIT_STALL only occur in the PHY role (the STA generates MDC itself).
  type t_mdio_wait_status is (
    WAIT_OK,
    WAIT_BAD_TIMEOUT, -- negative timeout, the call does not wait (TB_FAILURE reported by resolve_phy_timeout)
    WAIT_TIMEOUT,     -- no frame started in time
    WAIT_BAD_START,   -- no ST at the next rising edge (suppress_preamble, sync_to_frame_start = false)
    WAIT_STALL,       -- MDC stopped mid-frame
    WAIT_TERMINATED   -- terminate_loop was set
  );

  -- Nobody drives the bus: only the pull-up ('H') or nothing ('Z') is left. A strong '0' / '1', 'X', ... means
  -- somebody drives it. Not normalised with to_X01, that would turn the pull-up into a driven '1'.
  function is_undriven(constant value : in std_ulogic) return boolean is
  begin
    return value = 'H' or value = 'Z';
  end function is_undriven;

  -- Wait for the next MDC rising edge within a frame (watchdog: config.phy.max_wait_mdc_change).
  -- No alert here - the caller reports once at the end (report_phy_access_end).
  procedure await_mdc_rising_edge(
    signal   mdio_if        : in t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant config         : in t_mdio_bfm_config;
    variable status         : out t_mdio_wait_status) is
  begin
    wait until rising_edge(mdio_if.mdc) or terminate_loop = '1' for config.phy.max_wait_mdc_change;
    if terminate_loop = '1' then
      status := WAIT_TERMINATED;
    elsif rising_edge(mdio_if.mdc) then
      status := WAIT_OK;
    else
      status := WAIT_STALL;
    end if;
  end procedure await_mdc_rising_edge;

  -- Find the start of a frame. Returns on the MDC edge of the first ST bit ('0' / 'L').
  -- Edges are bounded by the call deadline, not by max_wait_mdc_change (MDC may idle between frames).
  --
  -- sync_to_frame_start = true: skip bus activity until the next frame start:
  --   - preamble: >= 32 '1' bits ('H' counts, as for a real PHY) followed by '0'. Works from any bus
  --     position, as 32 '1' cannot occur inside a frame (ST and TA contain a '0').
  --   - suppress_preamble: the next '0'. Only reliable if the call starts between frames.
  -- sync_to_frame_start = false: the frame starts at the next rising edge:
  --   - preamble: the '1' bits up to the first '0' are the preamble. Fewer than 32 are not an error
  --     here, preamble_bits reports how many there were (checked by the caller).
  --   - suppress_preamble: the first bit must be '0', otherwise status = WAIT_BAD_START.
  -- preamble_bits: number of '1'/'H' bits directly before ST (saturating at C_MDIO_PREAMBLE_LENGTH).
  -- driven_preamble_bits: how many of those the STA actually drove '1' (only the trailing run counts).
  procedure await_start_of_frame(
    signal   mdio_if              : in t_mdio_if;
    signal   terminate_loop       : in std_logic;
    constant start_time           : in time;
    constant timeout              : in time;
    constant suppress_preamble    : in boolean;
    constant sync_to_frame_start  : in boolean;
    variable preamble_bits        : out natural;
    variable driven_preamble_bits : out natural;
    variable status               : out t_mdio_wait_status)
  is
    variable v_remaining : time;
    variable v_ones      : natural := 0; -- consecutive '1'/'H' bits (saturating)
    variable v_driven    : natural := 0; -- consecutive driven '1' bits (saturating)
    variable v_first_bit : boolean := true;
  begin
    preamble_bits        := 0;
    driven_preamble_bits := 0;
    if timeout < 0 ns then
      status := WAIT_BAD_TIMEOUT;
      return;
    end if;
    loop

      -- wait for rising_edge of mdc, a timeout, or if the user requested to terminate the current uvvm command
      if timeout = 0 ns then
        wait until rising_edge(mdio_if.mdc) or terminate_loop = '1';
      else
        -- difference instead of start_time + timeout: no overflow for huge timeouts
        v_remaining := timeout - (now - start_time);
        if v_remaining <= 0 ns then
          status := WAIT_TIMEOUT;
          return;
        end if;
        wait until rising_edge(mdio_if.mdc) or terminate_loop = '1' for v_remaining;
      end if;

      if terminate_loop = '1' then
        status := WAIT_TERMINATED;
        return;
      elsif not rising_edge(mdio_if.mdc) then
        status := WAIT_TIMEOUT;
        return;
      end if;

      -- "the station management entity shall send a sequence of 32 contiguous
      -- logic one bits on MDIO", so it must actively drive the line.
      case mdio_if.mdio is
        when '1' => -- actively driven
          if v_ones < C_MDIO_PREAMBLE_LENGTH then
            v_ones := v_ones + 1;
          end if;
          if v_driven < C_MDIO_PREAMBLE_LENGTH then
            v_driven := v_driven + 1;
          end if;
        when 'H' => -- just pull-up
          if v_ones < C_MDIO_PREAMBLE_LENGTH then
            v_ones := v_ones + 1;
          end if;
          v_driven := 0;
        when '0' | 'L' => -- could be start bit
          if not sync_to_frame_start or suppress_preamble or v_ones = C_MDIO_PREAMBLE_LENGTH then
            preamble_bits        := v_ones;
            driven_preamble_bits := v_driven;
            status := WAIT_OK; -- first ST bit
            return;
          end if;
          v_ones   := 0;
          v_driven := 0;
        when others =>
          v_ones   := 0;
          v_driven := 0;
      end case;

      -- a suppressed preamble expected right now: anything but '0' as first bit is no ST
      if suppress_preamble and not sync_to_frame_start and v_first_bit then
        status := WAIT_BAD_START;
        return;
      end if;
      v_first_bit := false;
    end loop;
  end procedure await_start_of_frame;

  -- Only with sync_to_frame_start = false: the frame start was taken at face value, so the preamble
  -- length still needs checking (with syncing it is always 32). Not applicable to suppress_preamble.
  -- Returns true if the preamble was complete or the check is disabled (NO_ALERT).
  impure function check_preamble_length(
    constant preamble_bits : in natural;
    constant proc_call     : in string;
    constant msg           : in string;
    constant scope         : in string;
    constant msg_id_panel  : in t_msg_id_panel;
    constant config        : in t_mdio_bfm_config) return boolean is
  begin
    if config.suppress_preamble then
      return true;
    end if;

    return check_value(
      value        => preamble_bits >= C_MDIO_PREAMBLE_LENGTH,
      alert_level  => config.protocol_error_severity,
      msg          => "Preamble too short: " & to_string(preamble_bits) & " of " & to_string(C_MDIO_PREAMBLE_LENGTH) &
                      " bits before ST." & add_msg_delimiter(msg),
      scope        => scope,
      msg_id       => ID_NEVER,
      msg_id_panel => msg_id_panel,
      caller_name  => proc_call)
      or config.protocol_error_severity = NO_ALERT;
  end function check_preamble_length;

  -- The STA "shall send" the preamble (22.2.4.5.2), bits only pulled up ('H') violate this.
  -- Returns true if all preamble bits were driven or the check is disabled (NO_ALERT).
  -- Not applicable to suppress_preamble (a driven last data bit of the previous frame can precede ST).
  impure function check_preamble_driven(
    constant preamble_bits        : in natural;
    constant driven_preamble_bits : in natural;
    constant proc_call            : in string;
    constant msg                  : in string;
    constant scope                : in string;
    constant msg_id_panel         : in t_msg_id_panel;
    constant config               : in t_mdio_bfm_config) return boolean is
  begin
    if config.suppress_preamble then
      return true;
    end if;

    return check_value(
      value        => driven_preamble_bits >= preamble_bits,
      alert_level  => config.protocol_error_severity,
      msg          => "Preamble not driven by STA: only the last " & to_string(driven_preamble_bits) & " of " &
                      to_string(preamble_bits) & " bits before ST were driven '1', the others were only pulled up ('H')." &
                      add_msg_delimiter(msg),
      scope        => scope,
      msg_id       => ID_NEVER,
      msg_id_panel => msg_id_panel,
      caller_name  => proc_call)
      or config.protocol_error_severity = NO_ALERT;
  end function check_preamble_driven;

  -- Fields sampled from the bus are normalized with to_X01, so anything not a clear 0/1 ('X', 'U',
  -- 'Z', 'W', '-') shows up as 'X'. Returns true if all bits are defined or the check is disabled (NO_ALERT).
  impure function check_defined(
    constant value        : in std_ulogic_vector;
    constant field        : in string;
    constant proc_call    : in string;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel;
    constant config       : in t_mdio_bfm_config) return boolean is
  begin
    return check_value(
      value        => not is_x(value),
      alert_level  => config.protocol_error_severity,
      msg          => "Undefined bit(s) in " & field & ": " & to_string(value) & "." & add_msg_delimiter(msg),
      scope        => scope,
      msg_id       => ID_NEVER,
      msg_id_panel => msg_id_panel,
      caller_name  => proc_call)
      or config.protocol_error_severity = NO_ALERT;
  end function check_defined;

  -- The bus must show what the PHY drives, otherwise someone else drives it as well.
  -- Returns true if it matches or the check is disabled (NO_ALERT).
  impure function phy_check_bus_matches_driven(
    constant actual       : in std_ulogic; -- as sampled on the bus
    constant expected     : in std_ulogic; -- '0' or '1'
    constant what         : in string;
    constant proc_call    : in string;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel;
    constant config       : in t_mdio_bfm_config) return boolean is
  begin
    return check_value(
      value        => to_X01(actual) = expected,
      alert_level  => config.bus_contention_severity,
      msg          => "Bus contention: " & what & " driven '" & to_string(expected) & "' by PHY, bus was '" &
                      to_string(actual) & "'." & add_msg_delimiter(msg),
      scope        => scope,
      msg_id       => ID_NEVER,
      msg_id_panel => msg_id_panel,
      caller_name  => proc_call)
      or config.bus_contention_severity = NO_ALERT;
  end function phy_check_bus_matches_driven;

  -- Per-call timeout if given, else config.phy.timeout (0 ns = none, negative not allowed)
  impure function resolve_phy_timeout(
    constant timeout      : in time;
    constant proc_call    : in string;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel;
    constant config       : in t_mdio_bfm_config) return time
  is
    variable v_timeout : time;
  begin
    if timeout = C_UNDEFINED_TIME then
      v_timeout := config.phy.timeout;
    else
      v_timeout := timeout;
    end if;
    check_value(v_timeout >= 0 ns, TB_FAILURE, "Negative timeout " & to_string(v_timeout, ns) & " (not allowed)." & add_msg_delimiter(msg),
      scope, ID_NEVER, msg_id_panel, proc_call);
    return v_timeout;
  end function resolve_phy_timeout;

  -- Config the reply procedures (PHY drives the bus) depend on. A negative delay or one that doesn't
  -- settle within an MDC period breaks the BFM (TB_FAILURE), one above 300 ns only violates the spec.
  procedure phy_check_output_delay_config(
    constant proc_call    : in string;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel;
    constant config       : in t_mdio_bfm_config) is
  begin
    check_value(
      value        => config.output_delay >= 0 ns,
      alert_level  => TB_FAILURE,
      msg          => "Negative output_delay " & to_string(config.output_delay, ns) & " (not allowed)." & add_msg_delimiter(msg),
      scope        => scope,
      msg_id       => ID_NEVER,
      msg_id_panel => msg_id_panel,
      caller_name  => proc_call);
    check_value(
      value        => config.output_delay < config.min_mdc_period,
      alert_level  => TB_FAILURE,
      msg          => "output_delay " & to_string(config.output_delay, ns) & " must be shorter than min_mdc_period " &
                      to_string(config.min_mdc_period, ns) & ", the driven bit would not settle before the next edge." &
                      add_msg_delimiter(msg),
      scope        => scope,
      msg_id       => ID_NEVER,
      msg_id_panel => msg_id_panel,
      caller_name  => proc_call);
    check_value(
      value        => config.output_delay <= C_MDIO_MAX_OUTPUT_DELAY,
      alert_level  => config.timing_violation_severity,
      msg          => "output_delay " & to_string(config.output_delay, ns) & " exceeds the " &
                      to_string(C_MDIO_MAX_OUTPUT_DELAY, ns) & " allowed by IEEE 802.3 22.3.4." & add_msg_delimiter(msg),
      scope        => scope,
      msg_id       => ID_NEVER,
      msg_id_panel => msg_id_panel,
      caller_name  => proc_call);
  end procedure phy_check_output_delay_config;

  -- Log the start of an mdio_phy_* call (id_for_bfm_wait)
  procedure log_phy_access_start(
    constant timeout      : in time;
    constant proc_call    : in string;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel;
    constant config       : in t_mdio_bfm_config) is
    constant C_PHY : string := "PHY " & to_string(config.phy.phy_address, HEX, AS_IS, INCL_RADIX);
  begin
    if timeout < 0 ns then
      null; -- the call does not wait, see WAIT_BAD_TIMEOUT
    elsif timeout = 0 ns then
      log(config.id_for_bfm_wait, proc_call & "=> Waiting to be addressed as " & C_PHY & " (no timeout). " &
        add_msg_delimiter(msg), scope, msg_id_panel);
    else
      log(config.id_for_bfm_wait, proc_call & "=> Waiting to be addressed as " & C_PHY & " within " &
        to_string(timeout, ns) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure log_phy_access_start;

  -- Report the end of an mdio_phy_* call once: log OK (if all checks passed) / terminated,
  -- or alert stall / timeout
  procedure report_phy_access_end(
    constant status       : in t_mdio_wait_status;
    constant check_ok     : in boolean;
    constant timeout      : in time;
    constant target_name  : in string; -- "PHY" or "PHY/DEVAD", for the message
    constant proc_call    : in string;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel;
    constant config       : in t_mdio_bfm_config;
    constant result       : in string := "OK") is -- logged as the outcome, e.g. the data of a read
  begin
    case status is
      when WAIT_OK =>
        if check_ok then
          log(config.id_for_bfm, proc_call & "=> " & result & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        end if;
      when WAIT_TERMINATED =>
        log(ID_TERMINATE_CMD, proc_call & "=> Terminated. " & add_msg_delimiter(msg), scope, msg_id_panel);
      when WAIT_BAD_TIMEOUT =>
        null; -- already reported by resolve_phy_timeout
      when WAIT_BAD_START =>
        alert(config.protocol_error_severity, proc_call & "=> Failed. Frame did not start with ST at the next rising edge " &
          "(suppress_preamble, sync_to_frame_start = false)." & add_msg_delimiter(msg), scope);
      when WAIT_STALL =>
        alert(config.phy.max_wait_mdc_change_severity, proc_call & "=> Failed. MDC stalled mid-frame (no rising edge for " &
          to_string(config.phy.max_wait_mdc_change, ns) & ")." & add_msg_delimiter(msg), scope);
      when WAIT_TIMEOUT =>
        alert(config.phy.timeout_severity, proc_call & "=> Failed. Timeout after " & to_string(timeout, ns) &
          " - no frame addressing this " & target_name & " started." & add_msg_delimiter(msg), scope);
    end case;
  end procedure report_phy_access_end;

  procedure receive_data(
    variable bits           : out std_ulogic_vector;
    signal   mdio_if        : in t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant config         : in t_mdio_bfm_config;
    variable status         : out t_mdio_wait_status) is
    variable v_status : t_mdio_wait_status;
  begin
    for i in bits'high downto bits'low loop
      await_mdc_rising_edge(mdio_if, terminate_loop, config, v_status);
      status := v_status;
      if v_status /= WAIT_OK then
        return;
      end if;
      -- weak values count as their strong counterpart ('H' = '1'), anything undefined becomes 'X'
      bits(i) := to_X01(mdio_if.mdio);
    end loop;
  end procedure receive_data;

  -- Call right after await_start_of_frame(): takes the already sampled first ST bit, then
  -- receives the rest of ST, OP and both address fields
  procedure receive_frame_header(
    variable st              : out std_ulogic_vector(C_MDIO_ST_WIDTH-1 downto 0);
    variable op              : out std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0);
    variable phy_addr        : out std_ulogic_vector(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    variable reg_or_dev_addr : out std_ulogic_vector(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    signal   mdio_if         : in t_mdio_if;
    signal   terminate_loop  : in std_logic;
    constant config          : in t_mdio_bfm_config;
    variable status          : out t_mdio_wait_status)
  is
    variable v_data   : t_mdio_header;
    variable v_status : t_mdio_wait_status;
  begin
    v_data(v_data'high) := to_X01(mdio_if.mdio);
    receive_data(v_data(v_data'high-1 downto 0), mdio_if, terminate_loop, config, v_status);
    status := v_status;
    if v_status /= WAIT_OK then
      return;
    end if;

    st              := mdio_header_st(v_data);
    op              := mdio_header_op(v_data);
    phy_addr        := mdio_header_phy_addr(v_data);
    reg_or_dev_addr := mdio_header_reg_or_dev_addr(v_data);
  end procedure receive_frame_header;

  -- verify a turnaround fully driven by the STA, i.e. "10" (write and address-set frames,
  -- where the master owns both TA bits)
  procedure expect_sta_turnaround(
    signal   mdio_if        : in t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant proc_call      : in string;
    constant msg            : in string;
    constant scope          : in string;
    constant msg_id_panel   : in t_msg_id_panel;
    constant config         : in t_mdio_bfm_config;
    variable check_ok       : inout boolean;
    variable status         : out t_mdio_wait_status)
  is
    variable v_ta     : std_ulogic_vector(C_MDIO_TA_WIDTH-1 downto 0);
    variable v_status : t_mdio_wait_status;
  begin
    receive_data(v_ta, mdio_if, terminate_loop, config, v_status);
    status := v_status;
    if v_status /= WAIT_OK then
      return;
    end if;
    check_ok := (check_value(value        => v_ta,
                             exp          => "10",
                             alert_level  => config.protocol_error_severity,
                             msg          => "Turnaround driven by STA is not ""10""." & add_msg_delimiter(msg),
                             scope        => scope,
                             radix        => BIN,
                             format       => KEEP_LEADING_0,
                             msg_id       => ID_NEVER,
                             msg_id_panel => msg_id_panel,
                             caller_name  => proc_call)
                 or config.protocol_error_severity = NO_ALERT) and check_ok;
  end procedure expect_sta_turnaround;

  -- passively consume the turnaround of a read frame addressed to another target and
  -- check it: in TA bit 1 both the STA and the addressed PHY stay high-impedance, so nobody may drive the bus
  -- (only 'H' or 'Z', config.bus_contention_severity), in TA bit 0 the addressed PHY drives '0'.
  -- An undriven TA bit 0 ('H' / 'Z') is no error: there is no PHY at that address, e.g. while the STA scans the
  -- bus for PHYs. Reporting a missing PHY is the job of the STA (config.sta.turnaround_not_driven_severity).
  procedure check_other_target_read_turnaround(
    signal   mdio_if        : in t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant proc_call      : in string;
    constant msg            : in string;
    constant scope          : in string;
    constant msg_id_panel   : in t_msg_id_panel;
    constant config         : in t_mdio_bfm_config;
    variable status         : out t_mdio_wait_status)
  is
    variable v_ta_msb : std_ulogic;
    variable v_ta_lsb : std_ulogic;
    variable v_status : t_mdio_wait_status;
  begin
    await_mdc_rising_edge(mdio_if, terminate_loop, config, v_status);
    status := v_status;
    if v_status /= WAIT_OK then
      return;
    end if;
    v_ta_msb := mdio_if.mdio;
    await_mdc_rising_edge(mdio_if, terminate_loop, config, v_status);
    status := v_status;
    if v_status /= WAIT_OK then
      return;
    end if;
    v_ta_lsb := mdio_if.mdio;

    check_value(value        => is_undriven(v_ta_msb),
                exp          => true,
                alert_level  => config.bus_contention_severity,
                msg          => "Bus contention: turnaround bit 1 of a read to another target is driven, the STA and the PHY must release the bus (expected 'H' or 'Z'), bus was '" &
                                to_string(v_ta_msb) & "'." & add_msg_delimiter(msg),
                scope        => scope,
                msg_id       => ID_NEVER,
                msg_id_panel => msg_id_panel,
                caller_name  => proc_call);
    check_value(value        => to_X01(v_ta_lsb) = '0' or is_undriven(v_ta_lsb),
                exp          => true,
                alert_level  => config.protocol_error_severity,
                msg          => "Turnaround bit 0 of a read to another target is neither '0' nor undriven (no PHY), bus was '" &
                                to_string(v_ta_lsb) & "'." & add_msg_delimiter(msg),
                scope        => scope,
                msg_id       => ID_NEVER,
                msg_id_panel => msg_id_panel,
                caller_name  => proc_call);
  end procedure check_other_target_read_turnaround;

  -- Drives the read turnaround: releases the bus for the first bit (the STA must do the same, checked),
  -- then drives the '0' of the next bit (checked on the bus)
  procedure drive_phy_read_turnaround(
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant proc_call      : in string;
    constant msg            : in string;
    constant scope          : in string;
    constant msg_id_panel   : in t_msg_id_panel;
    constant config         : in t_mdio_bfm_config;
    variable check_ok       : inout boolean;
    variable status         : out t_mdio_wait_status) is
    variable v_status : t_mdio_wait_status;
  begin
    mdio_if.mdio <= 'Z' after config.output_delay;
    await_mdc_rising_edge(mdio_if, terminate_loop, config, v_status);
    status := v_status;
    if v_status /= WAIT_OK then
      return;
    end if;
    -- nobody drives the bus in TA bit 1: only the pull-up ('H') or nothing ('Z') is left
    check_ok := check_value(
      value        => is_undriven(mdio_if.mdio),
      alert_level  => config.bus_contention_severity,
      msg          => "Bus contention: STA did not release the bus in turnaround bit 1 of a read, bus was '" &
                      to_string(mdio_if.mdio) & "'." & add_msg_delimiter(msg),
      scope        => scope,
      msg_id       => ID_NEVER,
      msg_id_panel => msg_id_panel,
      caller_name  => proc_call)
      and check_ok;

    mdio_if.mdio <= '0' after config.output_delay;
    await_mdc_rising_edge(mdio_if, terminate_loop, config, v_status);
    status := v_status;
    if v_status /= WAIT_OK then
      return;
    end if;
    check_ok := phy_check_bus_matches_driven(mdio_if.mdio, '0', "turnaround bit 0", proc_call, msg, scope, msg_id_panel, config)
                and check_ok;
  end procedure drive_phy_read_turnaround;

  procedure drive_data(
    constant data           : in std_ulogic_vector;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant proc_call      : in string;
    constant msg            : in string;
    constant scope          : in string;
    constant msg_id_panel   : in t_msg_id_panel;
    constant config         : in t_mdio_bfm_config;
    variable check_ok       : inout boolean;
    variable status         : out t_mdio_wait_status) is
    variable v_status : t_mdio_wait_status;
  begin
    for i in data'high downto data'low loop
      mdio_if.mdio <= data(i) after config.output_delay;
      await_mdc_rising_edge(mdio_if, terminate_loop, config, v_status);
      status := v_status;
      if v_status /= WAIT_OK then
        return;
      end if;
      check_ok := phy_check_bus_matches_driven(mdio_if.mdio, data(i), "data bit " & to_string(i), proc_call, msg, scope,
                                           msg_id_panel, config) and check_ok;
    end loop;
  end procedure drive_data;

  procedure release_mdio(
    signal   mdio_if : inout t_mdio_if;
    constant config  : in t_mdio_bfm_config) is
  begin
    mdio_if.mdio <= 'Z' after config.output_delay;
  end procedure release_mdio;

  -- Skip the rest of a frame (turnaround + data) without driving or checking it
  procedure skip_frame_rest(
    signal   mdio_if        : in t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant config         : in t_mdio_bfm_config;
    variable status         : out t_mdio_wait_status) is
    variable v_rest : std_ulogic_vector(C_MDIO_TA_WIDTH+C_MDIO_DATA_WIDTH-1 downto 0);
  begin
    receive_data(v_rest, mdio_if, terminate_loop, config, status);
  end procedure skip_frame_rest;

  function mdio_get_frame_kind(
    constant st : in std_ulogic_vector(C_MDIO_ST_WIDTH-1 downto 0);
    constant op : in std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0)) return t_mdio_frame_kind is
  begin
    if st = C_MDIO_ST_CL22 then
      if op = C_MDIO_OP_CL22_WRITE then
        return FRAME_STA_DRIVEN;
      elsif op = C_MDIO_OP_CL22_READ then
        return FRAME_PHY_DRIVEN;
      end if;
    elsif st = C_MDIO_ST_CL45 then
      if op = C_MDIO_OP_CL45_ADDR or op = C_MDIO_OP_CL45_WRITE then
        return FRAME_STA_DRIVEN;
      elsif op = C_MDIO_OP_CL45_READ or op = C_MDIO_OP_CL45_READ_INC then
        return FRAME_PHY_DRIVEN;
      end if;
    end if;
    return FRAME_INVALID;
  end function mdio_get_frame_kind;

  function mdio_header_st(constant header : in t_mdio_header) return std_ulogic_vector is
    constant C_ST : std_ulogic_vector(C_MDIO_ST_WIDTH-1 downto 0) := header(C_MDIO_HEADER_WIDTH-1 downto C_MDIO_HEADER_WIDTH-C_MDIO_ST_WIDTH);
  begin
    return C_ST;
  end function mdio_header_st;

  function mdio_header_op(constant header : in t_mdio_header) return std_ulogic_vector is
    constant C_OP : std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0) := header(2*C_MDIO_PHY_ADDR_WIDTH+C_MDIO_OP_WIDTH-1 downto 2*C_MDIO_PHY_ADDR_WIDTH);
  begin
    return C_OP;
  end function mdio_header_op;

  function mdio_header_phy_addr(constant header : in t_mdio_header) return std_ulogic_vector is
    constant C_PHY_ADDR : std_ulogic_vector(C_MDIO_PHY_ADDR_WIDTH-1 downto 0) := header(2*C_MDIO_PHY_ADDR_WIDTH-1 downto C_MDIO_PHY_ADDR_WIDTH);
  begin
    return C_PHY_ADDR;
  end function mdio_header_phy_addr;

  function mdio_header_reg_or_dev_addr(constant header : in t_mdio_header) return std_ulogic_vector is
    constant C_ADDR : std_ulogic_vector(C_MDIO_PHY_ADDR_WIDTH-1 downto 0) := header(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
  begin
    return C_ADDR;
  end function mdio_header_reg_or_dev_addr;

  -- Consume the rest of a frame addressed to another target according to its own opcode and
  -- check the turnaround driven by the other nodes. Invalid frames are not consumed - the
  -- preamble search resynchronizes on the next frame anyway.
  procedure consume_other_target_frame(
    constant st             : in std_ulogic_vector(C_MDIO_ST_WIDTH-1 downto 0);
    constant op             : in std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0);
    signal   mdio_if        : in t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant proc_call      : in string;
    constant msg            : in string;
    constant scope          : in string;
    constant msg_id_panel   : in t_msg_id_panel;
    constant config         : in t_mdio_bfm_config;
    variable status         : out t_mdio_wait_status)
  is
    variable v_data     : std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    variable v_check_ok : boolean := true; -- frames to other targets don't affect the call result
    variable v_status   : t_mdio_wait_status;
  begin
    case mdio_get_frame_kind(st, op) is
      when FRAME_STA_DRIVEN =>
        expect_sta_turnaround(mdio_if, terminate_loop, proc_call, msg, scope, msg_id_panel, config, v_check_ok, v_status);
      when FRAME_PHY_DRIVEN =>
        check_other_target_read_turnaround(mdio_if, terminate_loop, proc_call, msg, scope, msg_id_panel, config, v_status);
      when FRAME_INVALID =>
        status := WAIT_OK;
        return;
    end case;
    status := v_status;
    if v_status /= WAIT_OK then
      return;
    end if;
    receive_data(v_data, mdio_if, terminate_loop, config, status);
  end procedure consume_other_target_frame;

  -- Core of all mdio_phy_* calls: searches frames until one addresses this PHY and consumes
  -- the frames to other targets on the way. Returns right after the address fields, the
  -- caller handles turnaround and data.
  -- Addressed: clause 22 = ST + PHYAD, clause 45 = ST + PRTAD + DEVAD.
  -- preamble_ok: result of the preamble check of the addressed frame.
  procedure await_addressed_frame(
    constant st              : in std_ulogic_vector(C_MDIO_ST_WIDTH-1 downto 0);
    constant dev_addr        : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0); -- ignored for clause 22
    constant timeout         : in time;
    signal   mdio_if         : in t_mdio_if;
    signal   terminate_loop  : in std_logic;
    constant proc_call       : in string;
    constant msg             : in string;
    constant scope           : in string;
    constant msg_id_panel    : in t_msg_id_panel;
    constant config          : in t_mdio_bfm_config;
    variable op              : out std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0);
    variable reg_or_dev_addr : out std_ulogic_vector(C_MDIO_PHY_ADDR_WIDTH-1 downto 0); -- REGAD (clause 22) / DEVAD (clause 45)
    variable preamble_ok     : out boolean;
    variable status          : out t_mdio_wait_status)
  is
    constant C_START_TIME : time := now;

    variable v_st                   : std_ulogic_vector(C_MDIO_ST_WIDTH-1 downto 0);
    variable v_op                   : std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0);
    variable v_phy_addr             : std_ulogic_vector(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    variable v_reg_or_dev_addr      : std_ulogic_vector(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    variable v_preamble_bits        : natural;
    variable v_driven_preamble_bits : natural;
    variable v_preamble_ok          : boolean := true;
    variable v_sync                 : boolean := config.sync_to_frame_start;
    variable v_defined              : boolean;
  begin
    loop
      -- the timeout only applies until a frame starts, a started frame is always completed
      await_start_of_frame(mdio_if, terminate_loop, C_START_TIME, timeout, config.suppress_preamble, v_sync,
                           v_preamble_bits, v_driven_preamble_bits, status);
      exit when status /= WAIT_OK;
      v_preamble_ok := check_preamble_length(v_preamble_bits, proc_call, msg, scope, msg_id_panel, config);
      v_preamble_ok := check_preamble_driven(v_preamble_bits, v_driven_preamble_bits, proc_call, msg, scope, msg_id_panel, config)
                       and v_preamble_ok;
      receive_frame_header(v_st, v_op, v_phy_addr, v_reg_or_dev_addr, mdio_if, terminate_loop, config, status);
      exit when status /= WAIT_OK;
      -- checked for every frame on the bus, not only addressed ones (an undefined frame is never addressed)
      v_defined := check_defined(v_st & v_op & v_phy_addr & v_reg_or_dev_addr, "ST / OP / address fields", proc_call, msg, scope,
                                 msg_id_panel, config);
      -- compared as bit vectors: the received fields may hold 'X' (checked above), numeric_std's "=" is not meant for that
      exit when v_st = st and v_phy_addr = std_ulogic_vector(config.phy.phy_address) and (st = C_MDIO_ST_CL22 or v_reg_or_dev_addr = std_ulogic_vector(dev_addr));
      consume_other_target_frame(v_st, v_op, mdio_if, terminate_loop, proc_call, msg, scope, msg_id_panel, config, status);
      exit when status /= WAIT_OK;

      -- after a consumed frame the timing of the next one is unknown: a suppressed preamble needs syncing
      v_sync := config.sync_to_frame_start or config.suppress_preamble;
    end loop;

    op          := v_op;
    reg_or_dev_addr      := v_reg_or_dev_addr;
    preamble_ok := v_preamble_ok;
  end procedure await_addressed_frame;

  impure function check_opcode(
    constant op           : in std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0);
    constant exp_op       : in std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0);
    constant op_name      : in string;
    constant alert_level  : in t_alert_level;
    constant proc_call    : in string;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel) return boolean is
  begin
    return check_value(value        => op,
                       exp          => exp_op,
                       alert_level  => alert_level,
                       msg          => "Wrong OP code (expected " & op_name & ")." & add_msg_delimiter(msg),
                       scope        => scope,
                       radix        => BIN,
                       format       => KEEP_LEADING_0,
                       msg_id       => ID_NEVER,
                       msg_id_panel => msg_id_panel,
                       caller_name  => proc_call);
  end function check_opcode;

  -- Clause 22: the register address is part of the header, compare it with the one the call expects
  impure function check_c22_reg_addr(
    constant reg_addr     : in std_ulogic_vector(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0); -- as received
    constant exp_reg_addr : in unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0);
    constant alert_level  : in t_alert_level;
    constant proc_call    : in string;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel) return boolean is
  begin
    return check_value(value        => reg_addr,
                       exp          => std_ulogic_vector(exp_reg_addr),
                       alert_level  => alert_level,
                       msg          => "Wrong register address." & add_msg_delimiter(msg),
                       scope        => scope,
                       radix        => HEX,
                       format       => KEEP_LEADING_0,
                       msg_id       => ID_NEVER,
                       msg_id_panel => msg_id_panel,
                       caller_name  => proc_call);
  end function check_c22_reg_addr;

  -- Rest of an addressed STA-driven frame (write / address-set): check the turnaround and receive the 16 bits
  -- the STA sends (the data of a write frame, the address of an address frame). payload is only assigned once
  -- all bits were received, payload_defined is false if one of them is undefined (reported).
  -- With a wrong opcode (op_ok false) the frame is only consumed.
  procedure receive_payload(
    constant op_ok           : in boolean;
    variable payload         : out std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    variable payload_defined : out boolean;
    signal   mdio_if         : in t_mdio_if;
    signal   terminate_loop  : in std_logic;
    constant proc_call       : in string;
    constant msg             : in string;
    constant scope           : in string;
    constant msg_id_panel    : in t_msg_id_panel;
    constant config          : in t_mdio_bfm_config;
    variable check_ok        : inout boolean;
    variable status          : out t_mdio_wait_status)
  is
    variable v_data   : std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    variable v_status : t_mdio_wait_status;
  begin
    payload         := (others => 'X'); -- an out parameter that is not assigned would return 'U'
    payload_defined := false;
    if not op_ok then
      skip_frame_rest(mdio_if, terminate_loop, config, status);
      return;
    end if;

    expect_sta_turnaround(mdio_if, terminate_loop, proc_call, msg, scope, msg_id_panel, config, check_ok, v_status);
    status := v_status;
    if v_status /= WAIT_OK then
      return;
    end if;

    receive_data(v_data, mdio_if, terminate_loop, config, v_status);
    status := v_status;
    if v_status /= WAIT_OK then
      return;
    end if;

    payload         := v_data;
    payload_defined := check_defined(v_data, "data written by STA", proc_call, msg, scope, msg_id_panel, config);
    check_ok        := payload_defined and check_ok;
  end procedure receive_payload;

  -- Rest of an addressed STA-driven frame (write / address-set): receive_payload, then compare the 16 bits
  -- the STA sent with exp_payload (the data of a write frame, the address of an address frame).
  -- With a wrong opcode (op_ok false) the frame is only consumed.
  procedure expect_payload(
    constant op_ok          : in boolean;
    constant exp_payload    : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant data_error_msg : in string;
    constant alert_level    : in t_alert_level;
    signal   mdio_if        : in t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant proc_call      : in string;
    constant msg            : in string;
    constant scope          : in string;
    constant msg_id_panel   : in t_msg_id_panel;
    constant config         : in t_mdio_bfm_config;
    variable check_ok       : inout boolean;
    variable status         : out t_mdio_wait_status)
  is
    variable v_data    : std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    variable v_defined : boolean;
    variable v_status  : t_mdio_wait_status;
  begin
    receive_payload(op_ok, v_data, v_defined, mdio_if, terminate_loop, proc_call, msg, scope, msg_id_panel, config, check_ok, v_status);
    status := v_status;
    -- undefined data: that was reported instead of a (misleading) data mismatch
    if v_status /= WAIT_OK or not v_defined then
      return;
    end if;

    check_ok := check_value(value        => v_data,
                            exp          => exp_payload,
                            alert_level  => alert_level,
                            msg          => data_error_msg & add_msg_delimiter(msg),
                            scope        => scope,
                            radix        => HEX,
                            format       => KEEP_LEADING_0,
                            msg_id       => ID_NEVER,
                            msg_id_panel => msg_id_panel,
                            caller_name  => proc_call) and check_ok;
  end procedure expect_payload;

  -- Rest of an addressed PHY-driven frame (read / post-read-increment): drive turnaround and
  -- data, then release the bus. With a wrong opcode (op_ok false) nothing is driven, the frame
  -- is only consumed.
  procedure drive_payload(
    constant op_ok          : in boolean;
    constant data           : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant proc_call      : in string;
    constant msg            : in string;
    constant scope          : in string;
    constant msg_id_panel   : in t_msg_id_panel;
    constant config         : in t_mdio_bfm_config;
    variable check_ok       : inout boolean;
    variable status         : out t_mdio_wait_status)
  is
    variable v_status : t_mdio_wait_status;
  begin
    if not op_ok then
      skip_frame_rest(mdio_if, terminate_loop, config, status);
      return;
    end if;

    drive_phy_read_turnaround(mdio_if, terminate_loop, proc_call, msg, scope, msg_id_panel, config, check_ok, v_status);
    if v_status = WAIT_OK then
      drive_data(data, mdio_if, terminate_loop, proc_call, msg, scope, msg_id_panel, config, check_ok, v_status);
    end if;
    -- always release the bus, also after an abort
    release_mdio(mdio_if, config);
    status := v_status;
  end procedure drive_payload;

  --==========================================================================================
  -- STA-role helpers
  --==========================================================================================
  -- MDC is generated by the STA procedures (config.sta.mdc_period, 50 % duty, idle low between
  -- calls). Bit k of a frame is driven config.output_delay after the rising edge that samples
  -- bit k-1 and is itself sampled by the next rising edge; the very first bit is driven one MDC
  -- low phase before its edge. MDIO is released config.output_delay after the last sampling edge.

  constant C_TA_STA_DRIVEN : std_ulogic_vector(C_MDIO_TA_WIDTH-1 downto 0) := "10";

  -- Wait for the given time, ending early when terminate_loop is set
  procedure sta_wait(
    constant time_to_wait   : in time;
    signal   terminate_loop : in std_logic;
    variable status         : out t_mdio_wait_status) is
  begin
    if terminate_loop = '1' then
      status := WAIT_TERMINATED;
      return;
    end if;
    wait until terminate_loop = '1' for time_to_wait;
    if terminate_loop = '1' then
      status := WAIT_TERMINATED;
    else
      status := WAIT_OK;
    end if;
  end procedure sta_wait;

  procedure sta_check_condition(
    constant condition    : in boolean;
    constant alert_level  : in t_alert_level;
    constant text         : in string;
    constant proc_call    : in string;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel) is
  begin
    check_value(
      value        => condition,
      alert_level  => alert_level,
      msg          => text & add_msg_delimiter(msg),
      scope        => scope,
      msg_id       => ID_NEVER,
      msg_id_panel => msg_id_panel,
      caller_name  => proc_call);
  end procedure sta_check_condition;

  -- Config every mdio_sta_* call depends on. mdc_period / output_delay values that cannot work at all
  -- break the BFM (TB_FAILURE). Values that only violate the min_* settings are reported with
  -- config.timing_violation_severity, so out-of-spec timing can be driven on purpose (NO_ALERT).
  procedure sta_check_timing_config(
    constant proc_call    : in string;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel;
    constant config       : in t_mdio_bfm_config) is
    constant C_PERIOD : time := config.sta.mdc_period;
    constant C_HIGH   : time := C_PERIOD / 2;        -- MDC high phase
    constant C_LOW    : time := C_PERIOD - C_HIGH;   -- MDC low phase
    constant C_SEV    : t_alert_level := config.timing_violation_severity;
  begin
    sta_check_condition(C_PERIOD > 0 ns, TB_FAILURE,
      "mdc_period " & to_string(C_PERIOD, ns) & " must be positive.", proc_call, msg, scope, msg_id_panel);
    sta_check_condition(config.output_delay >= 0 ns, TB_FAILURE,
      "Negative output_delay " & to_string(config.output_delay, ns) & " (not allowed).", proc_call, msg, scope, msg_id_panel);
    sta_check_condition(config.output_delay < C_PERIOD, TB_FAILURE,
      "output_delay " & to_string(config.output_delay, ns) & " must be shorter than mdc_period " & to_string(C_PERIOD, ns) &
      ", the driven bit would not settle before the next edge.", proc_call, msg, scope, msg_id_panel);

    sta_check_condition(C_PERIOD >= config.min_mdc_period, C_SEV,
      "mdc_period " & to_string(C_PERIOD, ns) & " below min_mdc_period " & to_string(config.min_mdc_period, ns) & ".",
      proc_call, msg, scope, msg_id_panel);
    sta_check_condition(C_HIGH >= config.min_mdc_high_time, C_SEV,
      "MDC high phase " & to_string(C_HIGH, ns) & " below min_mdc_high_time " & to_string(config.min_mdc_high_time, ns) & ".",
      proc_call, msg, scope, msg_id_panel);
    sta_check_condition(C_LOW >= config.min_mdc_low_time, C_SEV,
      "MDC low phase " & to_string(C_LOW, ns) & " below min_mdc_low_time " & to_string(config.min_mdc_low_time, ns) & ".",
      proc_call, msg, scope, msg_id_panel);
    sta_check_condition(config.output_delay >= config.min_hold_time, C_SEV,
      "output_delay " & to_string(config.output_delay, ns) & " below min_hold_time " & to_string(config.min_hold_time, ns) & ".",
      proc_call, msg, scope, msg_id_panel);
    sta_check_condition(C_PERIOD - config.output_delay >= config.min_setup_time, C_SEV,
      "Only " & to_string(C_PERIOD - config.output_delay, ns) & " between MDIO change and next MDC edge, min_setup_time is " &
      to_string(config.min_setup_time, ns) & ".", proc_call, msg, scope, msg_id_panel);
    sta_check_condition(C_LOW >= config.min_setup_time, C_SEV,
      "First frame bit driven only " & to_string(C_LOW, ns) & " before its MDC edge, min_setup_time is " &
      to_string(config.min_setup_time, ns) & ".", proc_call, msg, scope, msg_id_panel);
  end procedure sta_check_timing_config;

  -- Extra config check for reads: the PHY may take up to 300 ns after an MDC edge to drive a bit (IEEE 802.3 22.3.4),
  -- the STA samples it at the next edge and still needs the setup time.
  procedure sta_check_read_timing_config(
    constant proc_call    : in string;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel;
    constant config       : in t_mdio_bfm_config) is
  begin
    sta_check_condition(config.sta.mdc_period >= C_MDIO_MAX_OUTPUT_DELAY + config.min_setup_time, config.timing_violation_severity,
      "mdc_period " & to_string(config.sta.mdc_period, ns) & " too short for a PHY driving read data up to " &
      to_string(C_MDIO_MAX_OUTPUT_DELAY, ns) & " after an MDC edge plus min_setup_time " & to_string(config.min_setup_time, ns) & ".",
      proc_call, msg, scope, msg_id_panel);
  end procedure sta_check_read_timing_config;

  -- The bus must show what the STA drives, otherwise someone else drives it as well. The STA drives
  -- strongly ('0' / '1'), so the bus must show exactly that: no normalisation, 'X' = contention.
  -- Returns true if it matches or the check is disabled (NO_ALERT).
  impure function sta_check_bus_matches_driven(
    constant actual       : in std_ulogic; -- as sampled on the bus
    constant expected     : in std_ulogic;
    constant what         : in string;
    constant proc_call    : in string;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel;
    constant config       : in t_mdio_bfm_config) return boolean is
  begin
    return check_value(
      value        => actual = expected,
      alert_level  => config.bus_contention_severity,
      msg          => "Bus contention: " & what & " driven '" & to_string(expected) & "' by STA, bus was '" &
                      to_string(actual) & "'." & add_msg_delimiter(msg),
      scope        => scope,
      msg_id       => ID_NEVER,
      msg_id_panel => msg_id_panel,
      caller_name  => proc_call)
      or config.bus_contention_severity = NO_ALERT;
  end function sta_check_bus_matches_driven;

  -- IDLE (IEEE 802.3 22.2.4.5.1): after the frame all drivers are disabled and only the pull-up holds the bus.
  -- Called one bit time after the last sampling edge of a frame, when the PHY (after a read) and the STA
  -- (after a write) must have released it. Returns true if the bus is idle or the check is disabled (NO_ALERT).
  impure function sta_check_bus_idle(
    constant actual       : in std_ulogic; -- as sampled on the bus
    constant proc_call    : in string;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel;
    constant config       : in t_mdio_bfm_config) return boolean is
  begin
    return check_value(
      value        => is_undriven(actual),
      alert_level  => config.bus_contention_severity,
      msg          => "Bus contention: MDIO is still driven after the frame (IDLE must be high-impedance), bus was '" &
                      to_string(actual) & "'. PHY not released after the last data bit?" & add_msg_delimiter(msg),
      scope        => scope,
      msg_id       => ID_NEVER,
      msg_id_panel => msg_id_panel,
      caller_name  => proc_call)
      or config.bus_contention_severity = NO_ALERT;
  end function sta_check_bus_idle;

  -- Clock out bits (left to right) with one MDC period per bit: '0' / '1' are driven, 'Z' releases MDIO.
  -- The bus is sampled at every rising edge into 'sampled' (raw value: a released bus reads 'H', a driven one
  -- '0' / '1', 'X' for bits never reached) and driven bits are checked on the bus. Terminating releases MDIO, leaves MDC low and ends the call.
  -- A terminate in an MDC high phase only takes effect at the following falling edge, so MDC and MDIO timing stay valid.
  procedure sta_clock_bits(
    constant bits           : in std_ulogic_vector;
    variable sampled        : out std_ulogic_vector;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant proc_call      : in string;
    constant msg            : in string;
    constant scope          : in string;
    constant msg_id_panel   : in t_msg_id_panel;
    constant config         : in t_mdio_bfm_config;
    variable check_ok       : inout boolean;
    variable status         : out t_mdio_wait_status)
  is
    constant C_HIGH : time := config.sta.mdc_period / 2;
    constant C_LOW  : time := config.sta.mdc_period - C_HIGH;
    variable v_bits    : std_ulogic_vector(0 to bits'length-1) := bits; -- transmission order, index = bit number
    variable v_sampled : std_ulogic_vector(0 to bits'length-1) := (others => 'X');
    variable v_status  : t_mdio_wait_status;
  begin
    mdio_if.mdc  <= '0';
    mdio_if.mdio <= v_bits(0);
    sta_wait(C_LOW, terminate_loop, v_status);

    for k in v_bits'range loop
      exit when v_status /= WAIT_OK;

      mdio_if.mdc <= '1'; -- sampling edge of bit k
      v_sampled(k) := mdio_if.mdio;
      if v_bits(k) = '0' or v_bits(k) = '1' then
        check_ok := sta_check_bus_matches_driven(mdio_if.mdio, v_bits(k), "frame bit " & to_string(k), proc_call, msg, scope,
                                                 msg_id_panel, config) and check_ok;
      end if;
      if k < v_bits'right then
        mdio_if.mdio <= v_bits(k+1) after config.output_delay;
      else
        mdio_if.mdio <= 'Z' after config.output_delay;
      end if;

      -- the high phase is always completed, a terminate is only taken at the falling edge: aborting here would
      -- leave a high pulse shorter than min_mdc_high_time, and release MDIO within the hold time of the edge
      wait for C_HIGH;
      mdio_if.mdc <= '0';
      sta_wait(C_LOW, terminate_loop, v_status);
    end loop;

    if v_status /= WAIT_OK then -- aborted in a low phase: release the bus, no pending drive may survive
      mdio_if.mdc  <= '0';
      mdio_if.mdio <= 'Z';
    end if;
    -- IDLE: the loop ends one low phase after the last sampling edge (of the last IDLE bit, or of the last data bit with
    -- idle_cycles = 0). The PHY has released the bus by then (up to 300 ns after the edge of the last data bit, see
    -- sta_check_read_timing_config), the STA itself after output_delay.
    if v_status = WAIT_OK then
      check_ok := sta_check_bus_idle(mdio_if.mdio, proc_call, msg, scope, msg_id_panel, config) and check_ok;
    end if;
    sampled := v_sampled;
    status  := v_status;
  end procedure sta_clock_bits;

  -- Bits of a frame from ST to the last data bit: ST OP PHYAD/PRTAD REGAD/DEVAD TA DATA
  constant C_STA_FRAME_LENGTH : natural := C_MDIO_ST_WIDTH + C_MDIO_OP_WIDTH + 2*C_MDIO_PHY_ADDR_WIDTH + C_MDIO_TA_WIDTH + C_MDIO_DATA_WIDTH;

  -- One complete frame: [preamble] + 'frame' + IDLE. 'frame' is what the STA drives ('Z' = released, for the
  -- PHY-driven part of a read), 'sampled' what was on the bus at each of its sampling edges. IDLE: config.sta.idle_cycles
  -- bits with MDIO released ('Z'). A terminate during IDLE ends the call as terminated, like anywhere else in the frame.
  procedure sta_clock_frame(
    constant frame          : in std_ulogic_vector(C_STA_FRAME_LENGTH-1 downto 0);
    variable sampled        : out std_ulogic_vector(C_STA_FRAME_LENGTH-1 downto 0);
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant proc_call      : in string;
    constant msg            : in string;
    constant scope          : in string;
    constant msg_id_panel   : in t_msg_id_panel;
    constant config         : in t_mdio_bfm_config;
    variable check_ok       : inout boolean;
    variable status         : out t_mdio_wait_status)
  is
    function preamble_length return natural is
    begin
      if config.suppress_preamble then
        return 0;
      end if;
      return config.sta.preamble_length;
    end function preamble_length;
    constant C_PRE  : natural := preamble_length;
    constant C_IDLE : natural := config.sta.idle_cycles;

    variable v_bits    : std_ulogic_vector(0 to C_PRE + C_STA_FRAME_LENGTH + C_IDLE - 1) := (others => 'Z'); -- IDLE
    variable v_sampled : std_ulogic_vector(0 to C_PRE + C_STA_FRAME_LENGTH + C_IDLE - 1);
  begin
    v_bits(0 to C_PRE - 1) := (others => '1'); -- preamble
    v_bits(C_PRE to C_PRE + C_STA_FRAME_LENGTH - 1) := frame;
    sta_clock_bits(v_bits, v_sampled, mdio_if, terminate_loop, proc_call, msg, scope, msg_id_panel, config, check_ok, status);
    sampled := v_sampled(C_PRE to C_PRE + C_STA_FRAME_LENGTH - 1);
  end procedure sta_clock_frame;

  -- Core of the STA-driven frames (clause 22 write, clause 45 address / write):
  -- ST OP PHYAD/PRTAD REGAD/DEVAD TA("10", driven by STA) DATA
  procedure sta_write_frame(
    constant st              : in std_ulogic_vector(C_MDIO_ST_WIDTH-1 downto 0);
    constant op              : in std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0);
    constant phy_addr        : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0); -- PHYAD (clause 22) / PRTAD (clause 45)
    constant reg_or_dev_addr : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0); -- REGAD (clause 22) / DEVAD (clause 45)
    constant data            : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);  -- data / register address (clause 45 address)
    signal   mdio_if         : inout t_mdio_if;
    signal   terminate_loop  : in std_logic;
    constant proc_call       : in string;
    constant msg             : in string;
    constant scope           : in string;
    constant msg_id_panel    : in t_msg_id_panel;
    constant config          : in t_mdio_bfm_config;
    variable check_ok        : inout boolean;
    variable status          : out t_mdio_wait_status)
  is
    constant C_FRAME : std_ulogic_vector(C_STA_FRAME_LENGTH-1 downto 0) :=
                                                                           st & op & std_ulogic_vector(phy_addr) & std_ulogic_vector(reg_or_dev_addr) & C_TA_STA_DRIVEN & data;
    variable v_sampled : std_ulogic_vector(C_STA_FRAME_LENGTH-1 downto 0); -- not needed for a write
  begin
    sta_clock_frame(C_FRAME, v_sampled, mdio_if, terminate_loop, proc_call, msg, scope, msg_id_panel, config, check_ok, status);
  end procedure sta_write_frame;

  -- Core of the PHY-driven frames (clause 22 read, clause 45 read / post-read-increment):
  -- ST OP PHYAD/PRTAD REGAD/DEVAD TA(STA releases the bus, PHY drives '0') DATA(driven by PHY)
  -- data: what was sampled, 'X' if the call was terminated. Returned also after a failed turnaround
  --       (typically all ones without a PHY), the alert for that is raised here.
  -- payload_ok: turnaround and data were fine, so the data can be compared
  procedure sta_read_frame(
    constant st              : in std_ulogic_vector(C_MDIO_ST_WIDTH-1 downto 0);
    constant op              : in std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0);
    constant phy_addr        : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0); -- PHYAD (clause 22) / PRTAD (clause 45)
    constant reg_or_dev_addr : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0); -- REGAD (clause 22) / DEVAD (clause 45)
    variable data            : out std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    variable payload_ok      : out boolean;
    signal   mdio_if         : inout t_mdio_if;
    signal   terminate_loop  : in std_logic;
    constant proc_call       : in string;
    constant msg             : in string;
    constant scope           : in string;
    constant msg_id_panel    : in t_msg_id_panel;
    constant config          : in t_mdio_bfm_config;
    variable check_ok        : inout boolean;
    variable status          : out t_mdio_wait_status)
  is
    constant C_RELEASED : std_ulogic_vector(C_MDIO_TA_WIDTH + C_MDIO_DATA_WIDTH - 1 downto 0) := (others => 'Z');
    constant C_FRAME    : std_ulogic_vector(C_STA_FRAME_LENGTH-1 downto 0) :=
                                                                              st & op & std_ulogic_vector(phy_addr) & std_ulogic_vector(reg_or_dev_addr) & C_RELEASED;

    variable v_sampled : std_ulogic_vector(C_STA_FRAME_LENGTH-1 downto 0);
    variable v_status  : t_mdio_wait_status;
    variable v_ta1_ok  : boolean;
    variable v_ta2_ok  : boolean;
    variable v_defined : boolean;
  begin
    data       := (others => 'X');
    payload_ok := false;
    sta_clock_frame(C_FRAME, v_sampled, mdio_if, terminate_loop, proc_call, msg, scope, msg_id_panel, config, check_ok, v_status);
    status := v_status;
    if v_status /= WAIT_OK then
      return;
    end if;

    -- sampled (raw bus values): ... TA(1) TA(0) DATA(15 downto 0)
    -- TA bit 1: the STA released the bus, so nobody may drive it: only the pull-up ('H') or nothing ('Z') is left.
    -- Anything else ('1', '0', 'X', ...) means the PHY (or someone else) drives it.
    v_ta1_ok := check_value(
      value        => is_undriven(v_sampled(C_MDIO_DATA_WIDTH + 1)),
      alert_level  => config.bus_contention_severity,
      msg          => "Bus contention: turnaround bit 1 of a read is driven, the STA had released the bus (expected 'H' or 'Z'), " &
                      "bus was '" & to_string(v_sampled(C_MDIO_DATA_WIDTH + 1)) & "'." & add_msg_delimiter(msg),
      scope        => scope,
      msg_id       => ID_NEVER,
      msg_id_panel => msg_id_panel,
      caller_name  => proc_call)
      or config.bus_contention_severity = NO_ALERT;
    -- TA bit 2: the PHY drives '0' (strong), without a PHY the bus stays at the pull-up 'H'
    v_ta2_ok := check_value(
      value        => v_sampled(C_MDIO_DATA_WIDTH) = '0',
      alert_level  => config.sta.turnaround_not_driven_severity,
      msg          => "PHY did not drive '0' in turnaround bit 2 of a read, bus was '" & to_string(v_sampled(C_MDIO_DATA_WIDTH)) &
                      "'. No PHY at this address?" & add_msg_delimiter(msg),
      scope        => scope,
      msg_id       => ID_NEVER,
      msg_id_panel => msg_id_panel,
      caller_name  => proc_call)
      or config.sta.turnaround_not_driven_severity = NO_ALERT;

    -- read data: weak values count as their strong counterpart ('H' = '1', as for data on the PHY side), anything
    -- undefined ('X', 'U', 'Z', ...) becomes 'X' and is reported
    data      := to_X01(v_sampled(C_MDIO_DATA_WIDTH-1 downto 0));
    v_defined := check_defined(to_X01(v_sampled(C_MDIO_DATA_WIDTH-1 downto 0)), "data read from PHY", proc_call, msg, scope,
                               msg_id_panel, config);

    payload_ok := v_ta1_ok and v_ta2_ok and v_defined;
    check_ok   := payload_ok and check_ok;
  -- NO_ALERT'ed checks count as ok for the compare, but not for the OK log
  end procedure sta_read_frame;

  -- Compare data read by an mdio_sta_*_check procedure with the expected data
  impure function sta_compare_read_data(
    constant data         : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant data_exp     : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant alert_level  : in t_alert_level;
    constant proc_call    : in string;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel) return boolean is
  begin
    return check_value(value        => data,
                       exp          => data_exp,
                       alert_level  => alert_level,
                       msg          => "Wrong data read." & add_msg_delimiter(msg),
                       scope        => scope,
                       radix        => HEX,
                       format       => KEEP_LEADING_0,
                       msg_id       => ID_NEVER,
                       msg_id_panel => msg_id_panel,
                       caller_name  => proc_call);
  end function sta_compare_read_data;

  -- Report the end of an mdio_sta_* call once: log OK (if all checks passed) / terminated
  procedure report_sta_access_end(
    constant status       : in t_mdio_wait_status;
    constant check_ok     : in boolean;
    constant proc_call    : in string;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel;
    constant config       : in t_mdio_bfm_config;
    constant result       : in string := "OK") is -- logged as the outcome, e.g. the data of a read
  begin
    case status is
      when WAIT_OK =>
        if check_ok then
          log(config.id_for_bfm, proc_call & "=> " & result & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        end if;
      when WAIT_TERMINATED =>
        log(ID_TERMINATE_CMD, proc_call & "=> Terminated. " & add_msg_delimiter(msg), scope, msg_id_panel);
      when others => -- the STA generates MDC and never waits for the PHY: no timeout / stall / bad start possible
        alert(TB_FAILURE, proc_call & "=> Unexpected status " & t_mdio_wait_status'image(status) & "." & add_msg_delimiter(msg), scope);
    end case;
  end procedure report_sta_access_end;

  function init_mdio_if_signals return t_mdio_if is
  begin
    return (mdc => 'Z', mdio => 'Z');
  end function init_mdio_if_signals;

  -- Passive timing check of one bit time: waits for the next rising MDC edge and returns the bit it samples. On the way
  -- it checks the timing of this bit time, depending on who drives MDIO in it (only for the checked side):
  --   STA_DRIVES:   MDIO does not change in the time step of the previous rising edge (0 ns hold time), nor within
  --                 min_hold_time after it, nor within min_setup_time before the next one
  --   STA_RELEASES: hold only, nobody drives the next bit
  --   PHY_DRIVES:   MDIO has settled 300 ns after the previous rising edge (0 ns is allowed, IEEE 802.3 22.3.4)
  --   PHY_RELEASES: the PHY releases MDIO at most 300 ns after the previous rising edge, the next bit is the STA's (setup)
  -- With the STA side checked, also the MDC period, high and low time. A violation is reported with alert_level
  -- (NO_ALERT: none, e.g. to keep following the frames while the check is disabled).
  procedure mdio_check_bit_timing(
    signal   mdio_if      : in t_mdio_if;
    constant driver       : in t_mdio_bit_driver;
    variable mdc_edges    : inout t_mdio_mdc_edges;
    variable sampled      : out std_ulogic;
    constant checked_side : in t_mdio_timing_check;
    constant alert_level  : in t_alert_level     := ERROR;
    constant scope        : in string            := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    constant C_PROC_NAME    : string  := "mdio_check_bit_timing()";
    constant C_CHECK_STA    : boolean := checked_side /= CHECK_PHY;
    constant C_CHECK_PHY    : boolean := checked_side /= CHECK_STA;
    constant C_STA_BIT      : boolean := C_CHECK_STA and (driver = STA_DRIVES or driver = STA_RELEASES);
    constant C_PHY_BIT      : boolean := C_CHECK_PHY and (driver = PHY_DRIVES or driver = PHY_RELEASES);
    constant C_EDGE         : time    := mdc_edges.last_rise; -- start of this bit time
    variable v_last_change  : time    := C_EDGE;              -- last MDIO change in this bit time
    variable v_hold_alerted : boolean := false;               -- one hold alert per bit time

    procedure timing_alert(constant text : in string) is
    begin
      alert(alert_level, C_PROC_NAME & " => " & text, scope);
    end procedure timing_alert;

    -- MDIO changed 'delay' after the rising MDC edge that started this bit time
    procedure check_mdio_change(constant delay : in time) is
    begin
      if C_STA_BIT and not v_hold_alerted then
        if delay = 0 ns then
          v_hold_alerted := true;
          timing_alert("MDIO changed from " & to_string(mdio_if.mdio'last_value) & " to " & to_string(mdio_if.mdio) &
            " at the same time as the rising MDC edge (0 ns hold time).");
        elsif delay < config.min_hold_time then
          v_hold_alerted := true;
          timing_alert("Hold time violation: MDIO changed " & to_string(delay, ns) & " after the rising MDC edge, min_hold_time is " &
            to_string(config.min_hold_time, ns) & ".");
        end if;
      end if;
      if C_PHY_BIT and driver = PHY_RELEASES and is_undriven(mdio_if.mdio) and delay > C_MDIO_MAX_OUTPUT_DELAY then
        timing_alert("PHY released MDIO " & to_string(delay, ns) & " after the rising MDC edge of the last data bit of a read, " &
          "IEEE 802.3 22.3.4 allows at most " & to_string(C_MDIO_MAX_OUTPUT_DELAY, ns) & ".");
      end if;
    end procedure check_mdio_change;

    -- the rising MDC edge that ends this bit time
    procedure check_mdio_at_edge is
    begin
      -- a bit from the STA must be stable min_setup_time before the edge
      if C_CHECK_STA and (driver = STA_DRIVES or driver = PHY_RELEASES) then
        if mdio_if.mdio'last_event = 0 ns then
          timing_alert("MDIO changed from " & to_string(mdio_if.mdio'last_value) & " to " & to_string(mdio_if.mdio) &
            " at the same time as the rising MDC edge (0 ns setup time).");
        elsif mdio_if.mdio'last_event < config.min_setup_time then
          timing_alert("Setup time violation: MDIO changed " & to_string(mdio_if.mdio'last_event, ns) &
            " before the rising MDC edge, min_setup_time is " & to_string(config.min_setup_time, ns) & ".");
        end if;
      end if;
      -- a bit from the PHY must have settled 300 ns after the previous edge. A change in the time step of this edge is
      -- not counted: it is the next bit, driven 0 ns after an edge the PHY saw some deltas earlier.
      if C_PHY_BIT and driver = PHY_DRIVES and v_last_change < now and v_last_change - C_EDGE > C_MDIO_MAX_OUTPUT_DELAY then
        timing_alert("PHY output delay violation: MDIO changed " & to_string(v_last_change - C_EDGE, ns) & " after the rising MDC edge, " &
          "IEEE 802.3 22.3.4 allows at most " & to_string(C_MDIO_MAX_OUTPUT_DELAY, ns) & ".");
      end if;
    end procedure check_mdio_at_edge;

    procedure check_mdc_rising_edge is
    begin
      if C_CHECK_STA and mdc_edges.rise_seen and now - mdc_edges.last_rise < config.min_mdc_period then
        timing_alert("MDC period violation: " & to_string(now - mdc_edges.last_rise, ns) & " between rising edges, min_mdc_period is " &
          to_string(config.min_mdc_period, ns) & ".");
      end if;
      if C_CHECK_STA and mdc_edges.fall_seen and now - mdc_edges.last_fall < config.min_mdc_low_time then
        timing_alert("MDC low time violation: " & to_string(now - mdc_edges.last_fall, ns) & ", min_mdc_low_time is " &
          to_string(config.min_mdc_low_time, ns) & ".");
      end if;
      mdc_edges.rise_seen := true;
      mdc_edges.last_rise := now;
    end procedure check_mdc_rising_edge;

    procedure check_mdc_falling_edge is
    begin
      if C_CHECK_STA and mdc_edges.fall_seen and now - mdc_edges.last_fall < config.min_mdc_period then
        timing_alert("MDC period violation: " & to_string(now - mdc_edges.last_fall, ns) & " between falling edges, min_mdc_period is " &
          to_string(config.min_mdc_period, ns) & ".");
      end if;
      if C_CHECK_STA and mdc_edges.rise_seen and now - mdc_edges.last_rise < config.min_mdc_high_time then
        timing_alert("MDC high time violation: " & to_string(now - mdc_edges.last_rise, ns) & ", min_mdc_high_time is " &
          to_string(config.min_mdc_high_time, ns) & ".");
      end if;
      mdc_edges.fall_seen := true;
      mdc_edges.last_fall := now;
    end procedure check_mdc_falling_edge;
  begin
    loop
      wait on mdio_if.mdc, mdio_if.mdio;

      if rising_edge(mdio_if.mdc) then
        -- end of the bit time. If MDIO changed in this time step, the bit is the value before the change.
        if mdio_if.mdio'last_event = 0 ns then
          sampled := mdio_if.mdio'last_value;
        else
          sampled := mdio_if.mdio;
        end if;
        if driver /= NOT_CHECKED then
          check_mdio_at_edge;
        end if;
        check_mdc_rising_edge;
        return;
      elsif falling_edge(mdio_if.mdc) then
        check_mdc_falling_edge;
      end if;

      if mdio_if.mdio'event and driver /= NOT_CHECKED then
        v_last_change := now;
        check_mdio_change(now - C_EDGE);
      end if;
    end loop;
  end procedure mdio_check_bit_timing;

  -- PHY: expects a write to 'reg_addr' and compares the data with 'data' (IEEE 802.3 Clause 22)
  procedure mdio_phy_c22_expect_write(
    constant reg_addr       : in unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0);
    constant data           : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : in t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant timeout        : in time              := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    constant C_PROC_NAME : string := "mdio_phy_c22_expect_write";
    constant C_PROC_CALL : string := C_PROC_NAME & "(REG:" & to_string(reg_addr, HEX, AS_IS, INCL_RADIX) & ", " &
                                     to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
    constant C_TIMEOUT   : time   := resolve_phy_timeout(timeout, C_PROC_CALL, msg, scope, msg_id_panel, config);

    variable v_op       : std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0);
    variable v_reg_addr : std_ulogic_vector(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0);
    variable v_op_ok    : boolean;
    variable v_check_ok : boolean;
    variable v_status   : t_mdio_wait_status;
  begin
    log_phy_access_start(C_TIMEOUT, C_PROC_CALL, msg, scope, msg_id_panel, config);
    await_addressed_frame(C_MDIO_ST_CL22, (others => '-'), C_TIMEOUT, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                          v_op, v_reg_addr, v_check_ok, v_status);
    if v_status = WAIT_OK then
      v_op_ok    := check_opcode(v_op, C_MDIO_OP_CL22_WRITE, "write", alert_level, C_PROC_CALL, msg, scope, msg_id_panel);
      v_check_ok := check_c22_reg_addr(v_reg_addr, reg_addr, alert_level, C_PROC_CALL, msg, scope, msg_id_panel)
                    and v_op_ok and v_check_ok;
      expect_payload(v_op_ok, data, "Wrong data written.", alert_level, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                      v_check_ok, v_status);
    end if;
    report_phy_access_end(v_status, v_check_ok, C_TIMEOUT, "PHY", C_PROC_CALL, msg, scope, msg_id_panel, config);
  end procedure mdio_phy_c22_expect_write;

  -- PHY: receives a write to 'reg_addr' and returns the data in 'data' (IEEE 802.3 Clause 22)
  procedure mdio_phy_c22_receive_write(
    constant reg_addr       : in unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0);
    variable data           : out std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : in t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant timeout        : in time              := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    constant C_PROC_NAME : string := "mdio_phy_c22_receive_write";
    constant C_PROC_CALL : string := C_PROC_NAME & "(REG:" & to_string(reg_addr, HEX, AS_IS, INCL_RADIX) & ")";
    constant C_TIMEOUT   : time   := resolve_phy_timeout(timeout, C_PROC_CALL, msg, scope, msg_id_panel, config);

    variable v_op       : std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0);
    variable v_reg_addr : std_ulogic_vector(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0);
    variable v_data     : std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0) := (others => 'X');
    variable v_defined  : boolean;
    variable v_op_ok    : boolean;
    variable v_check_ok : boolean;
    variable v_status   : t_mdio_wait_status;
  begin
    data := (others => 'X');
    log_phy_access_start(C_TIMEOUT, C_PROC_CALL, msg, scope, msg_id_panel, config);
    await_addressed_frame(C_MDIO_ST_CL22, (others => '-'), C_TIMEOUT, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                          v_op, v_reg_addr, v_check_ok, v_status);
    if v_status = WAIT_OK then
      v_op_ok    := check_opcode(v_op, C_MDIO_OP_CL22_WRITE, "write", alert_level, C_PROC_CALL, msg, scope, msg_id_panel);
      v_check_ok := check_c22_reg_addr(v_reg_addr, reg_addr, alert_level, C_PROC_CALL, msg, scope, msg_id_panel)
                    and v_op_ok and v_check_ok;
      receive_payload(v_op_ok, v_data, v_defined, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                      v_check_ok, v_status);
      if v_status = WAIT_OK then
        data := v_data;
      end if;
    end if;
    report_phy_access_end(v_status, v_check_ok, C_TIMEOUT, "PHY", C_PROC_CALL, msg, scope, msg_id_panel, config,
                          to_string(v_data, HEX, AS_IS, INCL_RADIX));
  end procedure mdio_phy_c22_receive_write;

  -- PHY: replies to a read of 'reg_addr' with 'data' (IEEE 802.3 Clause 22)
  procedure mdio_phy_c22_reply_read(
    constant reg_addr       : in unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0);
    constant data           : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant timeout        : in time              := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    constant C_PROC_NAME : string := "mdio_phy_c22_reply_read";
    constant C_PROC_CALL : string := C_PROC_NAME & "(REG:" & to_string(reg_addr, HEX, AS_IS, INCL_RADIX) & ", " &
                                     to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
    constant C_TIMEOUT   : time   := resolve_phy_timeout(timeout, C_PROC_CALL, msg, scope, msg_id_panel, config);

    variable v_op       : std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0);
    variable v_reg_addr : std_ulogic_vector(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0);
    variable v_op_ok    : boolean;
    variable v_check_ok : boolean;
    variable v_status   : t_mdio_wait_status;
  begin
    phy_check_output_delay_config(C_PROC_CALL, msg, scope, msg_id_panel, config);
    log_phy_access_start(C_TIMEOUT, C_PROC_CALL, msg, scope, msg_id_panel, config);
    await_addressed_frame(C_MDIO_ST_CL22, (others => '-'), C_TIMEOUT, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                          v_op, v_reg_addr, v_check_ok, v_status);
    if v_status = WAIT_OK then
      v_op_ok    := check_opcode(v_op, C_MDIO_OP_CL22_READ, "read", alert_level, C_PROC_CALL, msg, scope, msg_id_panel);
      v_check_ok := check_c22_reg_addr(v_reg_addr, reg_addr, alert_level, C_PROC_CALL, msg, scope, msg_id_panel)
                    and v_op_ok and v_check_ok;
      drive_payload(v_op_ok, data, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config, v_check_ok, v_status);
    end if;
    report_phy_access_end(v_status, v_check_ok, C_TIMEOUT, "PHY", C_PROC_CALL, msg, scope, msg_id_panel, config);
  end procedure mdio_phy_c22_reply_read;

  -- PHY: expects an address frame to MMD 'dev_addr' and compares the address with 'reg_addr' (IEEE 802.3 Clause 45)
  procedure mdio_phy_c45_expect_address(
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    constant reg_addr       : in unsigned(C_MDIO_REG_ADDR_WIDTH_C45-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : in t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant timeout        : in time              := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    constant C_PROC_NAME : string := "mdio_phy_c45_expect_address";
    constant C_PROC_CALL : string := C_PROC_NAME & "(DEV:" & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ", A:" &
                                     to_string(reg_addr, HEX, AS_IS, INCL_RADIX) & ")";
    constant C_TIMEOUT   : time   := resolve_phy_timeout(timeout, C_PROC_CALL, msg, scope, msg_id_panel, config);

    variable v_op       : std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0);
    variable v_dev_addr : std_ulogic_vector(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    variable v_op_ok    : boolean;
    variable v_check_ok : boolean;
    variable v_status   : t_mdio_wait_status;
  begin
    log_phy_access_start(C_TIMEOUT, C_PROC_CALL, msg, scope, msg_id_panel, config);
    await_addressed_frame(C_MDIO_ST_CL45, dev_addr, C_TIMEOUT, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                          v_op, v_dev_addr, v_check_ok, v_status);
    if v_status = WAIT_OK then
      v_op_ok    := check_opcode(v_op, C_MDIO_OP_CL45_ADDR, "address", alert_level, C_PROC_CALL, msg, scope, msg_id_panel);
      v_check_ok := v_op_ok and v_check_ok;
      expect_payload(v_op_ok, std_ulogic_vector(reg_addr), "Wrong register address set.", alert_level, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                      v_check_ok, v_status);
    end if;
    report_phy_access_end(v_status, v_check_ok, C_TIMEOUT, "PHY/DEVAD", C_PROC_CALL, msg, scope, msg_id_panel, config);
  end procedure mdio_phy_c45_expect_address;

  -- PHY: receives an address frame to MMD 'dev_addr' and returns the address in 'reg_addr' (IEEE 802.3 Clause 45)
  procedure mdio_phy_c45_receive_address(
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    variable reg_addr       : out unsigned(C_MDIO_REG_ADDR_WIDTH_C45-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : in t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant timeout        : in time              := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    constant C_PROC_NAME : string := "mdio_phy_c45_receive_address";
    constant C_PROC_CALL : string := C_PROC_NAME & "(DEV:" & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ")";
    constant C_TIMEOUT   : time   := resolve_phy_timeout(timeout, C_PROC_CALL, msg, scope, msg_id_panel, config);

    variable v_op       : std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0);
    variable v_dev_addr : std_ulogic_vector(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    variable v_reg_addr : std_ulogic_vector(C_MDIO_REG_ADDR_WIDTH_C45-1 downto 0) := (others => 'X');
    variable v_defined  : boolean;
    variable v_op_ok    : boolean;
    variable v_check_ok : boolean;
    variable v_status   : t_mdio_wait_status;
  begin
    reg_addr := (others => 'X');
    log_phy_access_start(C_TIMEOUT, C_PROC_CALL, msg, scope, msg_id_panel, config);
    await_addressed_frame(C_MDIO_ST_CL45, dev_addr, C_TIMEOUT, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                          v_op, v_dev_addr, v_check_ok, v_status);
    if v_status = WAIT_OK then
      v_op_ok    := check_opcode(v_op, C_MDIO_OP_CL45_ADDR, "address", alert_level, C_PROC_CALL, msg, scope, msg_id_panel);
      v_check_ok := v_op_ok and v_check_ok;
      receive_payload(v_op_ok, v_reg_addr, v_defined, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                      v_check_ok, v_status);
      if v_status = WAIT_OK then
        reg_addr := unsigned(v_reg_addr);
      end if;
    end if;
    report_phy_access_end(v_status, v_check_ok, C_TIMEOUT, "PHY/DEVAD", C_PROC_CALL, msg, scope, msg_id_panel, config,
                          "A:" & to_string(v_reg_addr, HEX, AS_IS, INCL_RADIX));
  end procedure mdio_phy_c45_receive_address;

  -- PHY: expects a write to MMD 'dev_addr' and compares the data with 'data' (IEEE 802.3 Clause 45)
  procedure mdio_phy_c45_expect_write(
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    constant data           : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : in t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant timeout        : in time              := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    constant C_PROC_NAME : string := "mdio_phy_c45_expect_write";
    constant C_PROC_CALL : string := C_PROC_NAME & "(DEV:" & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ", " &
                                     to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
    constant C_TIMEOUT   : time   := resolve_phy_timeout(timeout, C_PROC_CALL, msg, scope, msg_id_panel, config);

    variable v_op       : std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0);
    variable v_dev_addr : std_ulogic_vector(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    variable v_op_ok    : boolean;
    variable v_check_ok : boolean;
    variable v_status   : t_mdio_wait_status;
  begin
    log_phy_access_start(C_TIMEOUT, C_PROC_CALL, msg, scope, msg_id_panel, config);
    await_addressed_frame(C_MDIO_ST_CL45, dev_addr, C_TIMEOUT, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                          v_op, v_dev_addr, v_check_ok, v_status);
    if v_status = WAIT_OK then
      v_op_ok    := check_opcode(v_op, C_MDIO_OP_CL45_WRITE, "write", alert_level, C_PROC_CALL, msg, scope, msg_id_panel);
      v_check_ok := v_op_ok and v_check_ok;
      expect_payload(v_op_ok, data, "Wrong data written.", alert_level, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                      v_check_ok, v_status);
    end if;
    report_phy_access_end(v_status, v_check_ok, C_TIMEOUT, "PHY/DEVAD", C_PROC_CALL, msg, scope, msg_id_panel, config);
  end procedure mdio_phy_c45_expect_write;

  -- PHY: receives a write to MMD 'dev_addr' and returns the data in 'data' (IEEE 802.3 Clause 45)
  procedure mdio_phy_c45_receive_write(
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    variable data           : out std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : in t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant timeout        : in time              := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    constant C_PROC_NAME : string := "mdio_phy_c45_receive_write";
    constant C_PROC_CALL : string := C_PROC_NAME & "(DEV:" & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ")";
    constant C_TIMEOUT   : time   := resolve_phy_timeout(timeout, C_PROC_CALL, msg, scope, msg_id_panel, config);

    variable v_op       : std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0);
    variable v_dev_addr : std_ulogic_vector(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    variable v_data     : std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0) := (others => 'X');
    variable v_defined  : boolean;
    variable v_op_ok    : boolean;
    variable v_check_ok : boolean;
    variable v_status   : t_mdio_wait_status;
  begin
    data := (others => 'X');
    log_phy_access_start(C_TIMEOUT, C_PROC_CALL, msg, scope, msg_id_panel, config);
    await_addressed_frame(C_MDIO_ST_CL45, dev_addr, C_TIMEOUT, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                          v_op, v_dev_addr, v_check_ok, v_status);
    if v_status = WAIT_OK then
      v_op_ok    := check_opcode(v_op, C_MDIO_OP_CL45_WRITE, "write", alert_level, C_PROC_CALL, msg, scope, msg_id_panel);
      v_check_ok := v_op_ok and v_check_ok;
      receive_payload(v_op_ok, v_data, v_defined, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                      v_check_ok, v_status);
      if v_status = WAIT_OK then
        data := v_data;
      end if;
    end if;
    report_phy_access_end(v_status, v_check_ok, C_TIMEOUT, "PHY/DEVAD", C_PROC_CALL, msg, scope, msg_id_panel, config,
                          to_string(v_data, HEX, AS_IS, INCL_RADIX));
  end procedure mdio_phy_c45_receive_write;

  -- PHY: replies to a read of MMD 'dev_addr' with 'data' (IEEE 802.3 Clause 45)
  procedure mdio_phy_c45_reply_read(
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    constant data           : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant timeout        : in time              := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    constant C_PROC_NAME : string := "mdio_phy_c45_reply_read";
    constant C_PROC_CALL : string := C_PROC_NAME & "(DEV:" & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ", " &
                                     to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
    constant C_TIMEOUT   : time   := resolve_phy_timeout(timeout, C_PROC_CALL, msg, scope, msg_id_panel, config);

    variable v_op       : std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0);
    variable v_dev_addr : std_ulogic_vector(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    variable v_op_ok    : boolean;
    variable v_check_ok : boolean;
    variable v_status   : t_mdio_wait_status;
  begin
    phy_check_output_delay_config(C_PROC_CALL, msg, scope, msg_id_panel, config);
    log_phy_access_start(C_TIMEOUT, C_PROC_CALL, msg, scope, msg_id_panel, config);
    await_addressed_frame(C_MDIO_ST_CL45, dev_addr, C_TIMEOUT, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                          v_op, v_dev_addr, v_check_ok, v_status);
    if v_status = WAIT_OK then
      v_op_ok    := check_opcode(v_op, C_MDIO_OP_CL45_READ, "read", alert_level, C_PROC_CALL, msg, scope, msg_id_panel);
      v_check_ok := v_op_ok and v_check_ok;
      drive_payload(v_op_ok, data, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config, v_check_ok, v_status);
    end if;
    report_phy_access_end(v_status, v_check_ok, C_TIMEOUT, "PHY/DEVAD", C_PROC_CALL, msg, scope, msg_id_panel, config);
  end procedure mdio_phy_c45_reply_read;

  -- PHY: replies to a post-read-increment read of MMD 'dev_addr' with 'data' (IEEE 802.3 Clause 45)
  procedure mdio_phy_c45_reply_post_read_increment(
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    constant data           : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0); -- data of the current register address, the address is incremented by the PHY afterwards
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant timeout        : in time              := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    constant C_PROC_NAME : string := "mdio_phy_c45_reply_post_read_increment";
    constant C_PROC_CALL : string := C_PROC_NAME & "(DEV:" & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ", " &
                                     to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
    constant C_TIMEOUT   : time   := resolve_phy_timeout(timeout, C_PROC_CALL, msg, scope, msg_id_panel, config);

    variable v_op       : std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0);
    variable v_dev_addr : std_ulogic_vector(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    variable v_op_ok    : boolean;
    variable v_check_ok : boolean;
    variable v_status   : t_mdio_wait_status;
  begin
    phy_check_output_delay_config(C_PROC_CALL, msg, scope, msg_id_panel, config);
    log_phy_access_start(C_TIMEOUT, C_PROC_CALL, msg, scope, msg_id_panel, config);
    await_addressed_frame(C_MDIO_ST_CL45, dev_addr, C_TIMEOUT, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                          v_op, v_dev_addr, v_check_ok, v_status);
    if v_status = WAIT_OK then
      v_op_ok    := check_opcode(v_op, C_MDIO_OP_CL45_READ_INC, "post-read-increment-address", alert_level, C_PROC_CALL, msg, scope, msg_id_panel);
      v_check_ok := v_op_ok and v_check_ok;
      drive_payload(v_op_ok, data, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config, v_check_ok, v_status);
    end if;
    report_phy_access_end(v_status, v_check_ok, C_TIMEOUT, "PHY/DEVAD", C_PROC_CALL, msg, scope, msg_id_panel, config);
  end procedure mdio_phy_c45_reply_post_read_increment;

  procedure mdio_sta_c22_write(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant reg_addr       : in unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0);
    constant data           : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    constant C_PROC_NAME : string := "mdio_sta_c22_write";
    constant C_PROC_CALL : string := C_PROC_NAME & "(PHY:" & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", REG:" & to_string(reg_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";

    variable v_check_ok : boolean := true;
    variable v_status   : t_mdio_wait_status;
  begin
    sta_check_timing_config(C_PROC_CALL, msg, scope, msg_id_panel, config);
    sta_write_frame(C_MDIO_ST_CL22, C_MDIO_OP_CL22_WRITE, phy_addr, reg_addr, data, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                    v_check_ok, v_status);
    report_sta_access_end(v_status, v_check_ok, C_PROC_CALL, msg, scope, msg_id_panel, config);
  end procedure mdio_sta_c22_write;

  procedure mdio_sta_c22_read(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant reg_addr       : in unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0);
    variable data           : out std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    constant C_PROC_NAME : string := "mdio_sta_c22_read";
    constant C_PROC_CALL : string := C_PROC_NAME & "(PHY:" & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", REG:" & to_string(reg_addr, HEX, AS_IS, INCL_RADIX) & ")";

    variable v_payload_ok : boolean;
    variable v_check_ok   : boolean := true;
    variable v_status     : t_mdio_wait_status;
  begin
    sta_check_timing_config(C_PROC_CALL, msg, scope, msg_id_panel, config);
    sta_check_read_timing_config(C_PROC_CALL, msg, scope, msg_id_panel, config);
    sta_read_frame(C_MDIO_ST_CL22, C_MDIO_OP_CL22_READ, phy_addr, reg_addr, data, v_payload_ok, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                   v_check_ok, v_status);
    report_sta_access_end(v_status, v_check_ok, C_PROC_CALL, msg, scope, msg_id_panel, config, to_string(data, HEX, AS_IS, INCL_RADIX));
  end procedure mdio_sta_c22_read;

  procedure mdio_sta_c22_check(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant reg_addr       : in unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0);
    constant data_exp       : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    constant C_PROC_NAME : string := "mdio_sta_c22_check";
    constant C_PROC_CALL : string := C_PROC_NAME & "(PHY:" & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", REG:" & to_string(reg_addr, HEX, AS_IS, INCL_RADIX) & ", EXP:" & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";

    variable v_data       : std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    variable v_payload_ok : boolean;
    variable v_check_ok   : boolean := true;
    variable v_status     : t_mdio_wait_status;
  begin
    sta_check_timing_config(C_PROC_CALL, msg, scope, msg_id_panel, config);
    sta_check_read_timing_config(C_PROC_CALL, msg, scope, msg_id_panel, config);
    sta_read_frame(C_MDIO_ST_CL22, C_MDIO_OP_CL22_READ, phy_addr, reg_addr, v_data, v_payload_ok, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                   v_check_ok, v_status);
    -- with a bad turnaround / undefined data that alert is reported instead of a (misleading) data mismatch
    if v_status = WAIT_OK and v_payload_ok then
      v_check_ok := sta_compare_read_data(v_data, data_exp, alert_level, C_PROC_CALL, msg, scope, msg_id_panel) and v_check_ok;
    end if;
    report_sta_access_end(v_status, v_check_ok, C_PROC_CALL, msg, scope, msg_id_panel, config);
  end procedure mdio_sta_c22_check;

  procedure mdio_sta_c45_address(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    constant reg_addr       : in unsigned(C_MDIO_REG_ADDR_WIDTH_C45-1 downto 0);
    variable success        : out boolean;
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    constant C_PROC_NAME : string := "mdio_sta_c45_address";
    constant C_PROC_CALL : string := C_PROC_NAME & "(PRT:" & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", DEV:" & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ", A:" & to_string(reg_addr, HEX, AS_IS, INCL_RADIX) & ")";

    variable v_check_ok : boolean := true;
    variable v_status   : t_mdio_wait_status;
  begin
    sta_check_timing_config(C_PROC_CALL, msg, scope, msg_id_panel, config);
    sta_write_frame(C_MDIO_ST_CL45, C_MDIO_OP_CL45_ADDR, phy_addr, dev_addr, std_ulogic_vector(reg_addr), mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                    v_check_ok, v_status);
    report_sta_access_end(v_status, v_check_ok, C_PROC_CALL, msg, scope, msg_id_panel, config);
    success := v_status = WAIT_OK and v_check_ok;
  end procedure mdio_sta_c45_address;

  procedure mdio_sta_c45_address(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    constant reg_addr       : in unsigned(C_MDIO_REG_ADDR_WIDTH_C45-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    variable v_success : boolean; -- not needed, the alerts are raised in the procedure
  begin
    mdio_sta_c45_address(phy_addr, dev_addr, reg_addr, v_success, msg, mdio_if, terminate_loop, scope, msg_id_panel, config);
  end procedure mdio_sta_c45_address;

  procedure mdio_sta_c45_write(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    constant data           : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    constant C_PROC_NAME : string := "mdio_sta_c45_write";
    constant C_PROC_CALL : string := C_PROC_NAME & "(PRT:" & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", DEV:" & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";

    variable v_check_ok : boolean := true;
    variable v_status   : t_mdio_wait_status;
  begin
    sta_check_timing_config(C_PROC_CALL, msg, scope, msg_id_panel, config);
    sta_write_frame(C_MDIO_ST_CL45, C_MDIO_OP_CL45_WRITE, phy_addr, dev_addr, data, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                    v_check_ok, v_status);
    report_sta_access_end(v_status, v_check_ok, C_PROC_CALL, msg, scope, msg_id_panel, config);
  end procedure mdio_sta_c45_write;

  procedure mdio_sta_c45_read(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    variable data           : out std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    constant C_PROC_NAME : string := "mdio_sta_c45_read";
    constant C_PROC_CALL : string := C_PROC_NAME & "(PRT:" & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", DEV:" & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ")";

    variable v_payload_ok : boolean;
    variable v_check_ok   : boolean := true;
    variable v_status     : t_mdio_wait_status;
  begin
    sta_check_timing_config(C_PROC_CALL, msg, scope, msg_id_panel, config);
    sta_check_read_timing_config(C_PROC_CALL, msg, scope, msg_id_panel, config);
    sta_read_frame(C_MDIO_ST_CL45, C_MDIO_OP_CL45_READ, phy_addr, dev_addr, data, v_payload_ok, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                   v_check_ok, v_status);
    report_sta_access_end(v_status, v_check_ok, C_PROC_CALL, msg, scope, msg_id_panel, config, to_string(data, HEX, AS_IS, INCL_RADIX));
  end procedure mdio_sta_c45_read;

  procedure mdio_sta_c45_post_read_increment(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    variable data           : out std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    constant C_PROC_NAME : string := "mdio_sta_c45_post_read_increment";
    constant C_PROC_CALL : string := C_PROC_NAME & "(PRT:" & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", DEV:" & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ")";

    variable v_payload_ok : boolean;
    variable v_check_ok   : boolean := true;
    variable v_status     : t_mdio_wait_status;
  begin
    sta_check_timing_config(C_PROC_CALL, msg, scope, msg_id_panel, config);
    sta_check_read_timing_config(C_PROC_CALL, msg, scope, msg_id_panel, config);
    sta_read_frame(C_MDIO_ST_CL45, C_MDIO_OP_CL45_READ_INC, phy_addr, dev_addr, data, v_payload_ok, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                   v_check_ok, v_status);
    report_sta_access_end(v_status, v_check_ok, C_PROC_CALL, msg, scope, msg_id_panel, config, to_string(data, HEX, AS_IS, INCL_RADIX));
  end procedure mdio_sta_c45_post_read_increment;

  procedure mdio_sta_c45_check(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    constant data_exp       : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    constant C_PROC_NAME : string := "mdio_sta_c45_check";
    constant C_PROC_CALL : string := C_PROC_NAME & "(PRT:" & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", DEV:" & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ", EXP:" & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";

    variable v_data       : std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    variable v_payload_ok : boolean;
    variable v_check_ok   : boolean := true;
    variable v_status     : t_mdio_wait_status;
  begin
    sta_check_timing_config(C_PROC_CALL, msg, scope, msg_id_panel, config);
    sta_check_read_timing_config(C_PROC_CALL, msg, scope, msg_id_panel, config);
    sta_read_frame(C_MDIO_ST_CL45, C_MDIO_OP_CL45_READ, phy_addr, dev_addr, v_data, v_payload_ok, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                   v_check_ok, v_status);
    -- with a bad turnaround / undefined data that alert is reported instead of a (misleading) data mismatch
    if v_status = WAIT_OK and v_payload_ok then
      v_check_ok := sta_compare_read_data(v_data, data_exp, alert_level, C_PROC_CALL, msg, scope, msg_id_panel) and v_check_ok;
    end if;
    report_sta_access_end(v_status, v_check_ok, C_PROC_CALL, msg, scope, msg_id_panel, config);
  end procedure mdio_sta_c45_check;

  procedure mdio_sta_c45_check_post_read_increment(
    constant phy_addr       : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant dev_addr       : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    constant data_exp       : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    constant msg            : in string;
    signal   mdio_if        : inout t_mdio_if;
    signal   terminate_loop : in std_logic;
    constant alert_level    : in t_alert_level     := ERROR;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant config         : in t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT)
  is
    constant C_PROC_NAME : string := "mdio_sta_c45_check_post_read_increment";
    constant C_PROC_CALL : string := C_PROC_NAME & "(PRT:" & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", DEV:" & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ", EXP:" & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";

    variable v_data       : std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    variable v_payload_ok : boolean;
    variable v_check_ok   : boolean := true;
    variable v_status     : t_mdio_wait_status;
  begin
    sta_check_timing_config(C_PROC_CALL, msg, scope, msg_id_panel, config);
    sta_check_read_timing_config(C_PROC_CALL, msg, scope, msg_id_panel, config);
    sta_read_frame(C_MDIO_ST_CL45, C_MDIO_OP_CL45_READ_INC, phy_addr, dev_addr, v_data, v_payload_ok, mdio_if, terminate_loop, C_PROC_CALL, msg, scope, msg_id_panel, config,
                   v_check_ok, v_status);
    -- with a bad turnaround / undefined data that alert is reported instead of a (misleading) data mismatch
    if v_status = WAIT_OK and v_payload_ok then
      v_check_ok := sta_compare_read_data(v_data, data_exp, alert_level, C_PROC_CALL, msg, scope, msg_id_panel) and v_check_ok;
    end if;
    report_sta_access_end(v_status, v_check_ok, C_PROC_CALL, msg, scope, msg_id_panel, config);
  end procedure mdio_sta_c45_check_post_read_increment;

end package body mdio_bfm_pkg;
-- vim:ts=2:shiftwidth=2:
