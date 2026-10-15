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

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

use work.mdio_bfm_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;
use work.transaction_pkg.all;
use work.vvc_sb_pkg.all;

--==========================================================================================
--==========================================================================================
package vvc_methods_pkg is

  --==========================================================================================
  -- Types and constants for the MDIO VVC
  --==========================================================================================
  constant C_VVC_NAME     : string := "MDIO_VVC";

  signal MDIO_VVCT         : t_vvc_target_record := set_vvc_target_defaults(C_VVC_NAME);
  alias  THIS_VVCT         : t_vvc_target_record is MDIO_VVCT;
  alias  t_bfm_config is t_mdio_bfm_config;

  -- Type found in UVVM-Util types_pkg
  constant C_MDIO_INTER_BFM_DELAY_DEFAULT : t_inter_bfm_delay := (
    delay_type                         => NO_DELAY,
    delay_in_time                      => 0 ns,
    inter_bfm_delay_violation_severity => WARNING
  );

  -- Property checker of the bus timing, see p_bus_timing_checker in mdio_vvc.vhd
  type t_bus_timing_checker is record
    enable      : boolean;       -- Enables or disables the bus timing checker (the frames are still followed)
    alert_level : t_alert_level; -- Alert generated if the timing is violated
  end record t_bus_timing_checker;

  constant C_BUS_TIMING_CHECKER_DEFAULT : t_bus_timing_checker := (
    enable      => true,
    alert_level => ERROR
  );

  type t_vvc_config is record
    inter_bfm_delay                       : t_inter_bfm_delay; -- Minimum delay between BFM accesses from the VVC. If parameter delay_type is set to NO_DELAY, BFM accesses will be back to back, i.e. no delay.
    cmd_queue_count_max                   : natural;           -- Maximum pending number in command executor before executor is full. Adding additional commands will result in an ERROR.
    cmd_queue_count_threshold             : natural;           -- An alert with severity 'cmd_queue_count_threshold_severity' will be issued if command executor exceeds this count. Used for early warning if command executor is almost full. Will be ignored if set to 0.
    cmd_queue_count_threshold_severity    : t_alert_level;     -- Severity of alert to be initiated if exceeding cmd_queue_count_threshold.
    result_queue_count_max                : natural;
    result_queue_count_threshold          : natural;
    result_queue_count_threshold_severity : t_alert_level;
    bfm_config                            : t_bfm_config;      -- Configuration for the BFM. See BFM quick reference.
    msg_id_panel                          : t_msg_id_panel;    -- VVC dedicated message ID panel.
    unwanted_activity_severity            : t_alert_level;     -- Severity of alert to be initiated if unwanted activity on the DUT outputs is detected.
    bus_timing_checker                    : t_bus_timing_checker; -- Property checker of the DUT's bus timing (PHY mode: the STA's bits and MDC, STA mode: the PHY's bits).
  end record t_vvc_config;

  type t_vvc_config_array is array (natural range <>) of t_vvc_config;

  constant C_MDIO_VVC_CONFIG_DEFAULT : t_vvc_config := (
    inter_bfm_delay                       => C_MDIO_INTER_BFM_DELAY_DEFAULT,
    cmd_queue_count_max                   => C_CMD_QUEUE_COUNT_MAX, --  from adaptation package
    cmd_queue_count_threshold             => C_CMD_QUEUE_COUNT_THRESHOLD,
    cmd_queue_count_threshold_severity    => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_max                => C_RESULT_QUEUE_COUNT_MAX,
    result_queue_count_threshold          => C_RESULT_QUEUE_COUNT_THRESHOLD,
    result_queue_count_threshold_severity => C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,
    bfm_config                            => C_MDIO_BFM_CONFIG_DEFAULT,
    msg_id_panel                          => C_VVC_MSG_ID_PANEL_DEFAULT,
    unwanted_activity_severity            => C_UNWANTED_ACTIVITY_SEVERITY,
    bus_timing_checker                    => C_BUS_TIMING_CHECKER_DEFAULT
  );

  type t_vvc_status is record
    current_cmd_idx  : natural;
    previous_cmd_idx : natural;
    pending_cmd_cnt  : natural;
  end record t_vvc_status;

  type t_vvc_status_array is array (natural range <>) of t_vvc_status;

  constant C_VVC_STATUS_DEFAULT : t_vvc_status := (
    current_cmd_idx  => 0,
    previous_cmd_idx => 0,
    pending_cmd_cnt  => 0
  );

  shared variable shared_mdio_vvc_config : t_vvc_config_array(0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => C_MDIO_VVC_CONFIG_DEFAULT);
  shared variable shared_mdio_vvc_status : t_vvc_status_array(0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => C_VVC_STATUS_DEFAULT);

  -- Built-in scoreboard, shared by all MDIO VVC instances (one scoreboard instance per GC_INSTANCE_IDX).
  -- STA reads and PHY receives called with data_routing = TO_SB are checked against the data added with add_expected().
  shared variable mdio_vvc_sb            : t_generic_sb;

  --==========================================================================================
  -- Methods dedicated to this VVC
  -- - These procedures are called from the testbench in order for the VVC to execute
  --   BFM calls towards the given interface. The VVC interpreter will queue these calls
  --   and then the VVC executor will fetch the commands from the queue and handle the
  --   actual BFM execution.
  --==========================================================================================

  procedure mdio_phy_c22_expect_write (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant reg_addr            : in    unsigned;
    constant data                : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Receive a write frame to register 'reg_addr' of this PHY. The written data is stored in the result queue: await_completion() + fetch_result().
  procedure mdio_phy_c22_receive_write (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant reg_addr            : in    unsigned;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- As above, data_routing = TO_SB: the received value is sent to the VVC scoreboard (mdio_vvc_sb) instead of the result queue
  procedure mdio_phy_c22_receive_write (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant reg_addr            : in    unsigned;
    constant data_routing        : in    t_data_routing;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure mdio_phy_c22_reply_read (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant reg_addr            : in    unsigned;
    constant data                : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure mdio_phy_c45_expect_address (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant dev_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Receive an address frame to MMD 'dev_addr' of this PHY. The register address (16 bit) is stored in the result queue: await_completion() + fetch_result().
  procedure mdio_phy_c45_receive_address (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant dev_addr            : in    unsigned;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- As above, data_routing = TO_SB: the received value is sent to the VVC scoreboard (mdio_vvc_sb) instead of the result queue
  procedure mdio_phy_c45_receive_address (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant dev_addr            : in    unsigned;
    constant data_routing        : in    t_data_routing;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure mdio_phy_c45_expect_write (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant dev_addr            : in    unsigned;
    constant data                : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Receive a write frame to MMD 'dev_addr' of this PHY. The written data is stored in the result queue: await_completion() + fetch_result().
  procedure mdio_phy_c45_receive_write (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant dev_addr            : in    unsigned;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- As above, data_routing = TO_SB: the received value is sent to the VVC scoreboard (mdio_vvc_sb) instead of the result queue
  procedure mdio_phy_c45_receive_write (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant dev_addr            : in    unsigned;
    constant data_routing        : in    t_data_routing;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure mdio_phy_c45_reply_read (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant dev_addr            : in    unsigned;
    constant data                : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure mdio_phy_c45_reply_post_read_increment (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant dev_addr            : in    unsigned;
    constant data                : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  --------------------------------------------------------------------------------------
  -- STA methods (VVC with GC_STA_MODE = true)
  -- - The STA drives MDC and the frames, the PHY (DUT) answers. There is no timeout parameter:
  --   a read has a fixed length and nothing waits for the PHY.
  -- - *_read: the data is stored in the result queue (16 bit), get it with
  --   await_completion() + fetch_result(). With data_routing = TO_SB it is checked
  --   by the scoreboard mdio_vvc_sb instead (add the expected data with add_expected()).
  -- - *_check: reads and compares, alert_level is used on a mismatch.
  -- - *_reg: one command for a complete clause 45 access (address frame + access).
  --------------------------------------------------------------------------------------
  -- Write 'data' to register 'reg_addr' of the PHY 'phy_addr' (one management frame)
  procedure mdio_sta_c22_write (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant data                : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Read register 'reg_addr' of the PHY 'phy_addr'. The data is stored in the result queue: await_completion() + fetch_result().
  procedure mdio_sta_c22_read (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- As above, data_routing = TO_SB: the read data is sent to the VVC scoreboard (mdio_vvc_sb) instead of the result queue
  procedure mdio_sta_c22_read (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant data_routing        : in    t_data_routing; -- TO_SB: the read data is checked by the scoreboard mdio_vvc_sb
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Read register 'reg_addr' of the PHY 'phy_addr' and compare it with 'data_exp'
  procedure mdio_sta_c22_check (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant data_exp            : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant alert_level         : in    t_alert_level  := ERROR;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Address frame: sets the address pointer of MMD 'dev_addr' in PHY 'phy_addr' to 'reg_addr' (16 bit)
  procedure mdio_sta_c45_address (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Write frame to the address the pointer currently holds
  procedure mdio_sta_c45_write (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant data                : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Read frame (result queue)
  procedure mdio_sta_c45_read (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- As above, data_routing = TO_SB: the read data is sent to the VVC scoreboard (mdio_vvc_sb) instead of the result queue
  procedure mdio_sta_c45_read (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant data_routing        : in    t_data_routing; -- TO_SB: the read data is checked by the scoreboard mdio_vvc_sb
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Post-read-increment frame (result queue)
  procedure mdio_sta_c45_post_read_increment (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- As above, data_routing = TO_SB: the read data is sent to the VVC scoreboard (mdio_vvc_sb) instead of the result queue
  procedure mdio_sta_c45_post_read_increment (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant data_routing        : in    t_data_routing; -- TO_SB: the read data is checked by the scoreboard mdio_vvc_sb
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Read frame and compare it with 'data_exp'
  procedure mdio_sta_c45_check (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant data_exp            : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant alert_level         : in    t_alert_level  := ERROR;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Post-read-increment frame and compare it with 'data_exp'
  procedure mdio_sta_c45_check_post_read_increment (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant data_exp            : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant alert_level         : in    t_alert_level  := ERROR;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Complete register access as one command: address frame followed by a write frame
  procedure mdio_sta_c45_write_reg (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant data                : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Complete register access as one command: address frame followed by a read frame (result queue)
  procedure mdio_sta_c45_read_reg (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- As above, data_routing = TO_SB: the read data is sent to the VVC scoreboard (mdio_vvc_sb) instead of the result queue
  procedure mdio_sta_c45_read_reg (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant data_routing        : in    t_data_routing; -- TO_SB: the read data is checked by the scoreboard mdio_vvc_sb
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Complete register access as one command: address frame, read frame, compare with 'data_exp'
  procedure mdio_sta_c45_check_reg (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant data_exp            : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant alert_level         : in    t_alert_level  := ERROR;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure set_global_vvc_transaction_info (
    signal   vvc_transaction_info_trigger : inout std_logic;
    variable vvc_transaction_info_group   : inout t_transaction_group;
    constant vvc_cmd                      : in t_vvc_cmd_record;
    constant vvc_config                   : in t_vvc_config;
    constant transaction_status           : in t_transaction_status;
    constant scope                        : in string := C_VVC_CMD_SCOPE_DEFAULT
  );

  procedure set_global_vvc_transaction_info (
    signal   vvc_transaction_info_trigger : inout std_logic;
    variable vvc_transaction_info_group   : inout t_transaction_group;
    constant vvc_cmd                      : in t_vvc_cmd_record;
    constant vvc_result                   : in t_vvc_result;
    constant transaction_status           : in t_transaction_status;
    constant scope                        : in string := C_VVC_CMD_SCOPE_DEFAULT
  );

  procedure reset_vvc_transaction_info (
    variable vvc_transaction_info_group : inout t_transaction_group;
    constant vvc_cmd                    : in t_vvc_cmd_record
  );

end package vvc_methods_pkg;

package body vvc_methods_pkg is

  --==========================================================================================
  -- Methods dedicated to this VVC
  --==========================================================================================

  procedure mdio_phy_c22_expect_write(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant reg_addr            : in    unsigned;
    constant data                : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_phy_c22_expect_write";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(reg_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_reg_addr : unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0) := -- clause 22: 5 bits
             normalize_and_check(reg_addr, shared_vvc_cmd.reg_addr(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0), ALLOW_WIDER_NARROWER, "reg_addr", "shared_vvc_cmd.reg_addr", C_PROC_CALL & " called with too wide reg_addr. " & msg);
    variable v_normalised_data    : std_ulogic_vector(C_VVC_CMD_DATA_LENGTH-1 downto 0) :=
             normalize_and_check(data, shared_vvc_cmd.data, ALLOW_WIDER_NARROWER, "data", "shared_vvc_cmd.data", C_PROC_CALL & " called with too wide data. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, PHY_C22_EXPECT_WRITE);
    shared_vvc_cmd.reg_addr            := resize(v_normalised_reg_addr, shared_vvc_cmd.reg_addr'length);
    shared_vvc_cmd.data                := v_normalised_data;
    shared_vvc_cmd.timeout             := timeout;
    shared_vvc_cmd.alert_level         := alert_level;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure mdio_phy_c22_receive_write (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant reg_addr            : in    unsigned;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
  begin
    mdio_phy_c22_receive_write(VVCT, vvc_instance_idx, reg_addr, NA, msg, timeout, alert_level, scope, parent_msg_id_panel);
  end procedure;

  procedure mdio_phy_c22_receive_write (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant reg_addr            : in    unsigned;
    constant data_routing        : in    t_data_routing;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_phy_c22_receive_write";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(reg_addr, HEX, AS_IS, INCL_RADIX)
                                     & return_string1_if_true_otherwise_string2(", " & to_upper(to_string(data_routing)), "", data_routing /= NA) & ")";
    variable v_normalised_reg_addr : unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0) := -- clause 22: 5 bits
             normalize_and_check(reg_addr, shared_vvc_cmd.reg_addr(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0), ALLOW_WIDER_NARROWER, "reg_addr", "shared_vvc_cmd.reg_addr", C_PROC_CALL & " called with too wide reg_addr. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, PHY_C22_RECEIVE_WRITE);
    shared_vvc_cmd.reg_addr            := resize(v_normalised_reg_addr, shared_vvc_cmd.reg_addr'length);
    shared_vvc_cmd.timeout             := timeout;
    shared_vvc_cmd.alert_level         := alert_level;
    shared_vvc_cmd.data_routing        := data_routing;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure mdio_phy_c22_reply_read (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant reg_addr            : in    unsigned;
    constant data                : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_phy_c22_reply_read";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(reg_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_reg_addr : unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0) := -- clause 22: 5 bits
             normalize_and_check(reg_addr, shared_vvc_cmd.reg_addr(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0), ALLOW_WIDER_NARROWER, "reg_addr", "shared_vvc_cmd.reg_addr", C_PROC_CALL & " called with too wide reg_addr. " & msg);
    variable v_normalised_data    : std_ulogic_vector(C_VVC_CMD_DATA_LENGTH-1 downto 0) :=
             normalize_and_check(data, shared_vvc_cmd.data, ALLOW_WIDER_NARROWER, "data", "shared_vvc_cmd.data", C_PROC_CALL & " called with too wide data. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, PHY_C22_REPLY_READ);
    shared_vvc_cmd.reg_addr            := resize(v_normalised_reg_addr, shared_vvc_cmd.reg_addr'length);
    shared_vvc_cmd.data                := v_normalised_data;
    shared_vvc_cmd.timeout             := timeout;
    shared_vvc_cmd.alert_level         := alert_level;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure mdio_phy_c45_expect_address (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant dev_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_phy_c45_expect_address";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(reg_addr, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_dev_addr : unsigned(C_VVC_CMD_DEV_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(dev_addr, shared_vvc_cmd.dev_addr, ALLOW_WIDER_NARROWER, "dev_addr", "shared_vvc_cmd.dev_addr", C_PROC_CALL & " called with too wide dev_addr. " & msg);
    variable v_normalised_address  : unsigned(C_VVC_CMD_REG_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(reg_addr, shared_vvc_cmd.reg_addr, ALLOW_WIDER_NARROWER, "reg_addr", "shared_vvc_cmd.reg_addr", C_PROC_CALL & " called with too wide reg_addr. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, PHY_C45_EXPECT_ADDRESS);
    shared_vvc_cmd.dev_addr            := v_normalised_dev_addr;
    shared_vvc_cmd.reg_addr            := v_normalised_address;
    shared_vvc_cmd.timeout             := timeout;
    shared_vvc_cmd.alert_level         := alert_level;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure mdio_phy_c45_receive_address (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant dev_addr            : in    unsigned;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
  begin
    mdio_phy_c45_receive_address(VVCT, vvc_instance_idx, dev_addr, NA, msg, timeout, alert_level, scope, parent_msg_id_panel);
  end procedure;

  procedure mdio_phy_c45_receive_address (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant dev_addr            : in    unsigned;
    constant data_routing        : in    t_data_routing;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_phy_c45_receive_address";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(dev_addr, HEX, AS_IS, INCL_RADIX)
                                     & return_string1_if_true_otherwise_string2(", " & to_upper(to_string(data_routing)), "", data_routing /= NA) & ")";
    variable v_normalised_dev_addr : unsigned(C_VVC_CMD_DEV_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(dev_addr, shared_vvc_cmd.dev_addr, ALLOW_WIDER_NARROWER, "dev_addr", "shared_vvc_cmd.dev_addr", C_PROC_CALL & " called with too wide dev_addr. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, PHY_C45_RECEIVE_ADDRESS);
    shared_vvc_cmd.dev_addr            := v_normalised_dev_addr;
    shared_vvc_cmd.timeout             := timeout;
    shared_vvc_cmd.alert_level         := alert_level;
    shared_vvc_cmd.data_routing        := data_routing;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure mdio_phy_c45_expect_write (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant dev_addr            : in    unsigned;
    constant data                : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_phy_c45_expect_write";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_dev_addr : unsigned(C_VVC_CMD_DEV_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(dev_addr, shared_vvc_cmd.dev_addr, ALLOW_WIDER_NARROWER, "dev_addr", "shared_vvc_cmd.dev_addr", C_PROC_CALL & " called with too wide dev_addr. " & msg);
    variable v_normalised_data    : std_ulogic_vector(C_VVC_CMD_DATA_LENGTH-1 downto 0) :=
             normalize_and_check(data, shared_vvc_cmd.data, ALLOW_WIDER_NARROWER, "data", "shared_vvc_cmd.data", C_PROC_CALL & " called with too wide data. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, PHY_C45_EXPECT_WRITE);
    shared_vvc_cmd.dev_addr            := v_normalised_dev_addr;
    shared_vvc_cmd.data                := v_normalised_data;
    shared_vvc_cmd.timeout             := timeout;
    shared_vvc_cmd.alert_level         := alert_level;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure mdio_phy_c45_receive_write (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant dev_addr            : in    unsigned;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
  begin
    mdio_phy_c45_receive_write(VVCT, vvc_instance_idx, dev_addr, NA, msg, timeout, alert_level, scope, parent_msg_id_panel);
  end procedure;

  procedure mdio_phy_c45_receive_write (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant dev_addr            : in    unsigned;
    constant data_routing        : in    t_data_routing;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_phy_c45_receive_write";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(dev_addr, HEX, AS_IS, INCL_RADIX)
                                     & return_string1_if_true_otherwise_string2(", " & to_upper(to_string(data_routing)), "", data_routing /= NA) & ")";
    variable v_normalised_dev_addr : unsigned(C_VVC_CMD_DEV_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(dev_addr, shared_vvc_cmd.dev_addr, ALLOW_WIDER_NARROWER, "dev_addr", "shared_vvc_cmd.dev_addr", C_PROC_CALL & " called with too wide dev_addr. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, PHY_C45_RECEIVE_WRITE);
    shared_vvc_cmd.dev_addr            := v_normalised_dev_addr;
    shared_vvc_cmd.timeout             := timeout;
    shared_vvc_cmd.alert_level         := alert_level;
    shared_vvc_cmd.data_routing        := data_routing;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure mdio_phy_c45_reply_read (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant dev_addr            : in    unsigned;
    constant data                : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_phy_c45_reply_read";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_dev_addr : unsigned(C_VVC_CMD_DEV_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(dev_addr, shared_vvc_cmd.dev_addr, ALLOW_WIDER_NARROWER, "dev_addr", "shared_vvc_cmd.dev_addr", C_PROC_CALL & " called with too wide dev_addr. " & msg);
    variable v_normalised_data    : std_ulogic_vector(C_VVC_CMD_DATA_LENGTH-1 downto 0) :=
             normalize_and_check(data, shared_vvc_cmd.data, ALLOW_WIDER_NARROWER, "data", "shared_vvc_cmd.data", C_PROC_CALL & " called with too wide data. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, PHY_C45_REPLY_READ);
    shared_vvc_cmd.dev_addr            := v_normalised_dev_addr;
    shared_vvc_cmd.data                := v_normalised_data;
    shared_vvc_cmd.timeout             := timeout;
    shared_vvc_cmd.alert_level         := alert_level;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure mdio_phy_c45_reply_post_read_increment (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant dev_addr            : in    unsigned;
    constant data                : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant timeout             : in    time           := C_UNDEFINED_TIME; -- default: bfm_config.phy.timeout, 0 ns: none
    constant alert_level         : in    t_alert_level  := ERROR; -- wrong OP code, register address (clause 22) or data (expect_*)
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_phy_c45_reply_post_read_increment";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_dev_addr : unsigned(C_VVC_CMD_DEV_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(dev_addr, shared_vvc_cmd.dev_addr, ALLOW_WIDER_NARROWER, "dev_addr", "shared_vvc_cmd.dev_addr", C_PROC_CALL & " called with too wide dev_addr. " & msg);
    variable v_normalised_data    : std_ulogic_vector(C_VVC_CMD_DATA_LENGTH-1 downto 0) :=
             normalize_and_check(data, shared_vvc_cmd.data, ALLOW_WIDER_NARROWER, "data", "shared_vvc_cmd.data", C_PROC_CALL & " called with too wide data. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, PHY_C45_REPLY_POST_READ_INCREMENT);
    shared_vvc_cmd.dev_addr            := v_normalised_dev_addr;
    shared_vvc_cmd.data                := v_normalised_data;
    shared_vvc_cmd.timeout             := timeout;
    shared_vvc_cmd.alert_level         := alert_level;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  --==========================================================================================
  -- STA methods
  --==========================================================================================

  procedure mdio_sta_c22_write (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant data                : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_sta_c22_write";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(reg_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_phy_addr : unsigned(C_VVC_CMD_PHY_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(phy_addr, shared_vvc_cmd.phy_addr, ALLOW_WIDER_NARROWER, "phy_addr", "shared_vvc_cmd.phy_addr", C_PROC_CALL & " called with too wide phy_addr. " & msg);
    variable v_normalised_reg_addr : unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0) := -- clause 22: 5 bits
             normalize_and_check(reg_addr, shared_vvc_cmd.reg_addr(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0), ALLOW_WIDER_NARROWER, "reg_addr", "shared_vvc_cmd.reg_addr", C_PROC_CALL & " called with too wide reg_addr. " & msg);
    variable v_normalised_data : std_ulogic_vector(C_VVC_CMD_DATA_LENGTH-1 downto 0) :=
             normalize_and_check(data, shared_vvc_cmd.data, ALLOW_WIDER_NARROWER, "data", "shared_vvc_cmd.data", C_PROC_CALL & " called with too wide data. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, STA_C22_WRITE);
    shared_vvc_cmd.phy_addr           := v_normalised_phy_addr;
    shared_vvc_cmd.reg_addr           := resize(v_normalised_reg_addr, shared_vvc_cmd.reg_addr'length);
    shared_vvc_cmd.data               := v_normalised_data;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure mdio_sta_c22_read (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
  begin
    mdio_sta_c22_read(VVCT, vvc_instance_idx, phy_addr, reg_addr, NA, msg, scope, parent_msg_id_panel);
  end procedure;

  procedure mdio_sta_c22_read (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant data_routing        : in    t_data_routing;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_sta_c22_read";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(reg_addr, HEX, AS_IS, INCL_RADIX)
                                     & return_string1_if_true_otherwise_string2(", " & to_upper(to_string(data_routing)), "", data_routing /= NA) & ")";
    variable v_normalised_phy_addr : unsigned(C_VVC_CMD_PHY_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(phy_addr, shared_vvc_cmd.phy_addr, ALLOW_WIDER_NARROWER, "phy_addr", "shared_vvc_cmd.phy_addr", C_PROC_CALL & " called with too wide phy_addr. " & msg);
    variable v_normalised_reg_addr : unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0) := -- clause 22: 5 bits
             normalize_and_check(reg_addr, shared_vvc_cmd.reg_addr(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0), ALLOW_WIDER_NARROWER, "reg_addr", "shared_vvc_cmd.reg_addr", C_PROC_CALL & " called with too wide reg_addr. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, STA_C22_READ);
    shared_vvc_cmd.phy_addr           := v_normalised_phy_addr;
    shared_vvc_cmd.reg_addr           := resize(v_normalised_reg_addr, shared_vvc_cmd.reg_addr'length);
    shared_vvc_cmd.data_routing       := data_routing;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure mdio_sta_c22_check (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant data_exp            : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant alert_level         : in    t_alert_level  := ERROR;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_sta_c22_check";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(reg_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_phy_addr : unsigned(C_VVC_CMD_PHY_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(phy_addr, shared_vvc_cmd.phy_addr, ALLOW_WIDER_NARROWER, "phy_addr", "shared_vvc_cmd.phy_addr", C_PROC_CALL & " called with too wide phy_addr. " & msg);
    variable v_normalised_reg_addr : unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0) := -- clause 22: 5 bits
             normalize_and_check(reg_addr, shared_vvc_cmd.reg_addr(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0), ALLOW_WIDER_NARROWER, "reg_addr", "shared_vvc_cmd.reg_addr", C_PROC_CALL & " called with too wide reg_addr. " & msg);
    variable v_normalised_data_exp : std_ulogic_vector(C_VVC_CMD_DATA_LENGTH-1 downto 0) :=
             normalize_and_check(data_exp, shared_vvc_cmd.data, ALLOW_WIDER_NARROWER, "data_exp", "shared_vvc_cmd.data", C_PROC_CALL & " called with too wide data_exp. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, STA_C22_CHECK);
    shared_vvc_cmd.phy_addr           := v_normalised_phy_addr;
    shared_vvc_cmd.reg_addr           := resize(v_normalised_reg_addr, shared_vvc_cmd.reg_addr'length);
    shared_vvc_cmd.data               := v_normalised_data_exp;
    shared_vvc_cmd.alert_level        := alert_level;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure mdio_sta_c45_address (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_sta_c45_address";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(reg_addr, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_phy_addr : unsigned(C_VVC_CMD_PHY_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(phy_addr, shared_vvc_cmd.phy_addr, ALLOW_WIDER_NARROWER, "phy_addr", "shared_vvc_cmd.phy_addr", C_PROC_CALL & " called with too wide phy_addr. " & msg);
    variable v_normalised_dev_addr : unsigned(C_VVC_CMD_DEV_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(dev_addr, shared_vvc_cmd.dev_addr, ALLOW_WIDER_NARROWER, "dev_addr", "shared_vvc_cmd.dev_addr", C_PROC_CALL & " called with too wide dev_addr. " & msg);
    variable v_normalised_address : unsigned(C_VVC_CMD_REG_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(reg_addr, shared_vvc_cmd.reg_addr, ALLOW_WIDER_NARROWER, "reg_addr", "shared_vvc_cmd.reg_addr", C_PROC_CALL & " called with too wide reg_addr. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, STA_C45_ADDRESS);
    shared_vvc_cmd.phy_addr           := v_normalised_phy_addr;
    shared_vvc_cmd.dev_addr           := v_normalised_dev_addr;
    shared_vvc_cmd.reg_addr           := v_normalised_address;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure mdio_sta_c45_write (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant data                : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_sta_c45_write";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_phy_addr : unsigned(C_VVC_CMD_PHY_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(phy_addr, shared_vvc_cmd.phy_addr, ALLOW_WIDER_NARROWER, "phy_addr", "shared_vvc_cmd.phy_addr", C_PROC_CALL & " called with too wide phy_addr. " & msg);
    variable v_normalised_dev_addr : unsigned(C_VVC_CMD_DEV_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(dev_addr, shared_vvc_cmd.dev_addr, ALLOW_WIDER_NARROWER, "dev_addr", "shared_vvc_cmd.dev_addr", C_PROC_CALL & " called with too wide dev_addr. " & msg);
    variable v_normalised_data : std_ulogic_vector(C_VVC_CMD_DATA_LENGTH-1 downto 0) :=
             normalize_and_check(data, shared_vvc_cmd.data, ALLOW_WIDER_NARROWER, "data", "shared_vvc_cmd.data", C_PROC_CALL & " called with too wide data. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, STA_C45_WRITE);
    shared_vvc_cmd.phy_addr           := v_normalised_phy_addr;
    shared_vvc_cmd.dev_addr           := v_normalised_dev_addr;
    shared_vvc_cmd.data               := v_normalised_data;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure mdio_sta_c45_read (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
  begin
    mdio_sta_c45_read(VVCT, vvc_instance_idx, phy_addr, dev_addr, NA, msg, scope, parent_msg_id_panel);
  end procedure;

  procedure mdio_sta_c45_read (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant data_routing        : in    t_data_routing;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_sta_c45_read";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(dev_addr, HEX, AS_IS, INCL_RADIX)
                                     & return_string1_if_true_otherwise_string2(", " & to_upper(to_string(data_routing)), "", data_routing /= NA) & ")";
    variable v_normalised_phy_addr : unsigned(C_VVC_CMD_PHY_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(phy_addr, shared_vvc_cmd.phy_addr, ALLOW_WIDER_NARROWER, "phy_addr", "shared_vvc_cmd.phy_addr", C_PROC_CALL & " called with too wide phy_addr. " & msg);
    variable v_normalised_dev_addr : unsigned(C_VVC_CMD_DEV_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(dev_addr, shared_vvc_cmd.dev_addr, ALLOW_WIDER_NARROWER, "dev_addr", "shared_vvc_cmd.dev_addr", C_PROC_CALL & " called with too wide dev_addr. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, STA_C45_READ);
    shared_vvc_cmd.phy_addr           := v_normalised_phy_addr;
    shared_vvc_cmd.dev_addr           := v_normalised_dev_addr;
    shared_vvc_cmd.data_routing       := data_routing;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure mdio_sta_c45_post_read_increment (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
  begin
    mdio_sta_c45_post_read_increment(VVCT, vvc_instance_idx, phy_addr, dev_addr, NA, msg, scope, parent_msg_id_panel);
  end procedure;

  procedure mdio_sta_c45_post_read_increment (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant data_routing        : in    t_data_routing;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_sta_c45_post_read_increment";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(dev_addr, HEX, AS_IS, INCL_RADIX)
                                     & return_string1_if_true_otherwise_string2(", " & to_upper(to_string(data_routing)), "", data_routing /= NA) & ")";
    variable v_normalised_phy_addr : unsigned(C_VVC_CMD_PHY_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(phy_addr, shared_vvc_cmd.phy_addr, ALLOW_WIDER_NARROWER, "phy_addr", "shared_vvc_cmd.phy_addr", C_PROC_CALL & " called with too wide phy_addr. " & msg);
    variable v_normalised_dev_addr : unsigned(C_VVC_CMD_DEV_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(dev_addr, shared_vvc_cmd.dev_addr, ALLOW_WIDER_NARROWER, "dev_addr", "shared_vvc_cmd.dev_addr", C_PROC_CALL & " called with too wide dev_addr. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, STA_C45_POST_READ_INCREMENT);
    shared_vvc_cmd.phy_addr           := v_normalised_phy_addr;
    shared_vvc_cmd.dev_addr           := v_normalised_dev_addr;
    shared_vvc_cmd.data_routing       := data_routing;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure mdio_sta_c45_check (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant data_exp            : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant alert_level         : in    t_alert_level  := ERROR;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_sta_c45_check";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_phy_addr : unsigned(C_VVC_CMD_PHY_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(phy_addr, shared_vvc_cmd.phy_addr, ALLOW_WIDER_NARROWER, "phy_addr", "shared_vvc_cmd.phy_addr", C_PROC_CALL & " called with too wide phy_addr. " & msg);
    variable v_normalised_dev_addr : unsigned(C_VVC_CMD_DEV_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(dev_addr, shared_vvc_cmd.dev_addr, ALLOW_WIDER_NARROWER, "dev_addr", "shared_vvc_cmd.dev_addr", C_PROC_CALL & " called with too wide dev_addr. " & msg);
    variable v_normalised_data_exp : std_ulogic_vector(C_VVC_CMD_DATA_LENGTH-1 downto 0) :=
             normalize_and_check(data_exp, shared_vvc_cmd.data, ALLOW_WIDER_NARROWER, "data_exp", "shared_vvc_cmd.data", C_PROC_CALL & " called with too wide data_exp. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, STA_C45_CHECK);
    shared_vvc_cmd.phy_addr           := v_normalised_phy_addr;
    shared_vvc_cmd.dev_addr           := v_normalised_dev_addr;
    shared_vvc_cmd.data               := v_normalised_data_exp;
    shared_vvc_cmd.alert_level        := alert_level;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure mdio_sta_c45_check_post_read_increment (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant data_exp            : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant alert_level         : in    t_alert_level  := ERROR;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_sta_c45_check_post_read_increment";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_phy_addr : unsigned(C_VVC_CMD_PHY_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(phy_addr, shared_vvc_cmd.phy_addr, ALLOW_WIDER_NARROWER, "phy_addr", "shared_vvc_cmd.phy_addr", C_PROC_CALL & " called with too wide phy_addr. " & msg);
    variable v_normalised_dev_addr : unsigned(C_VVC_CMD_DEV_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(dev_addr, shared_vvc_cmd.dev_addr, ALLOW_WIDER_NARROWER, "dev_addr", "shared_vvc_cmd.dev_addr", C_PROC_CALL & " called with too wide dev_addr. " & msg);
    variable v_normalised_data_exp : std_ulogic_vector(C_VVC_CMD_DATA_LENGTH-1 downto 0) :=
             normalize_and_check(data_exp, shared_vvc_cmd.data, ALLOW_WIDER_NARROWER, "data_exp", "shared_vvc_cmd.data", C_PROC_CALL & " called with too wide data_exp. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, STA_C45_CHECK_POST_READ_INCREMENT);
    shared_vvc_cmd.phy_addr           := v_normalised_phy_addr;
    shared_vvc_cmd.dev_addr           := v_normalised_dev_addr;
    shared_vvc_cmd.data               := v_normalised_data_exp;
    shared_vvc_cmd.alert_level        := alert_level;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure mdio_sta_c45_write_reg (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant data                : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_sta_c45_write_reg";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(reg_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_phy_addr : unsigned(C_VVC_CMD_PHY_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(phy_addr, shared_vvc_cmd.phy_addr, ALLOW_WIDER_NARROWER, "phy_addr", "shared_vvc_cmd.phy_addr", C_PROC_CALL & " called with too wide phy_addr. " & msg);
    variable v_normalised_dev_addr : unsigned(C_VVC_CMD_DEV_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(dev_addr, shared_vvc_cmd.dev_addr, ALLOW_WIDER_NARROWER, "dev_addr", "shared_vvc_cmd.dev_addr", C_PROC_CALL & " called with too wide dev_addr. " & msg);
    variable v_normalised_address : unsigned(C_VVC_CMD_REG_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(reg_addr, shared_vvc_cmd.reg_addr, ALLOW_WIDER_NARROWER, "reg_addr", "shared_vvc_cmd.reg_addr", C_PROC_CALL & " called with too wide reg_addr. " & msg);
    variable v_normalised_data : std_ulogic_vector(C_VVC_CMD_DATA_LENGTH-1 downto 0) :=
             normalize_and_check(data, shared_vvc_cmd.data, ALLOW_WIDER_NARROWER, "data", "shared_vvc_cmd.data", C_PROC_CALL & " called with too wide data. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, STA_C45_WRITE_REG);
    shared_vvc_cmd.phy_addr           := v_normalised_phy_addr;
    shared_vvc_cmd.dev_addr           := v_normalised_dev_addr;
    shared_vvc_cmd.reg_addr           := v_normalised_address;
    shared_vvc_cmd.data               := v_normalised_data;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure mdio_sta_c45_read_reg (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
  begin
    mdio_sta_c45_read_reg(VVCT, vvc_instance_idx, phy_addr, dev_addr, reg_addr, NA, msg, scope, parent_msg_id_panel);
  end procedure;

  procedure mdio_sta_c45_read_reg (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant data_routing        : in    t_data_routing;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_sta_c45_read_reg";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(reg_addr, HEX, AS_IS, INCL_RADIX)
                                     & return_string1_if_true_otherwise_string2(", " & to_upper(to_string(data_routing)), "", data_routing /= NA) & ")";
    variable v_normalised_phy_addr : unsigned(C_VVC_CMD_PHY_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(phy_addr, shared_vvc_cmd.phy_addr, ALLOW_WIDER_NARROWER, "phy_addr", "shared_vvc_cmd.phy_addr", C_PROC_CALL & " called with too wide phy_addr. " & msg);
    variable v_normalised_dev_addr : unsigned(C_VVC_CMD_DEV_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(dev_addr, shared_vvc_cmd.dev_addr, ALLOW_WIDER_NARROWER, "dev_addr", "shared_vvc_cmd.dev_addr", C_PROC_CALL & " called with too wide dev_addr. " & msg);
    variable v_normalised_address : unsigned(C_VVC_CMD_REG_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(reg_addr, shared_vvc_cmd.reg_addr, ALLOW_WIDER_NARROWER, "reg_addr", "shared_vvc_cmd.reg_addr", C_PROC_CALL & " called with too wide reg_addr. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, STA_C45_READ_REG);
    shared_vvc_cmd.phy_addr           := v_normalised_phy_addr;
    shared_vvc_cmd.dev_addr           := v_normalised_dev_addr;
    shared_vvc_cmd.reg_addr           := v_normalised_address;
    shared_vvc_cmd.data_routing       := data_routing;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure mdio_sta_c45_check_reg (
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant phy_addr            : in    unsigned;
    constant dev_addr            : in    unsigned;
    constant reg_addr            : in    unsigned;
    constant data_exp            : in    std_ulogic_vector;
    constant msg                 : in    string;
    constant alert_level         : in    t_alert_level  := ERROR;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "mdio_sta_c45_check_reg";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                     & ", " & to_string(phy_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(dev_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(reg_addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_phy_addr : unsigned(C_VVC_CMD_PHY_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(phy_addr, shared_vvc_cmd.phy_addr, ALLOW_WIDER_NARROWER, "phy_addr", "shared_vvc_cmd.phy_addr", C_PROC_CALL & " called with too wide phy_addr. " & msg);
    variable v_normalised_dev_addr : unsigned(C_VVC_CMD_DEV_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(dev_addr, shared_vvc_cmd.dev_addr, ALLOW_WIDER_NARROWER, "dev_addr", "shared_vvc_cmd.dev_addr", C_PROC_CALL & " called with too wide dev_addr. " & msg);
    variable v_normalised_address : unsigned(C_VVC_CMD_REG_ADDR_LENGTH-1 downto 0) :=
             normalize_and_check(reg_addr, shared_vvc_cmd.reg_addr, ALLOW_WIDER_NARROWER, "reg_addr", "shared_vvc_cmd.reg_addr", C_PROC_CALL & " called with too wide reg_addr. " & msg);
    variable v_normalised_data_exp : std_ulogic_vector(C_VVC_CMD_DATA_LENGTH-1 downto 0) :=
             normalize_and_check(data_exp, shared_vvc_cmd.data, ALLOW_WIDER_NARROWER, "data_exp", "shared_vvc_cmd.data", C_PROC_CALL & " called with too wide data_exp. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, STA_C45_CHECK_REG);
    shared_vvc_cmd.phy_addr           := v_normalised_phy_addr;
    shared_vvc_cmd.dev_addr           := v_normalised_dev_addr;
    shared_vvc_cmd.reg_addr           := v_normalised_address;
    shared_vvc_cmd.data               := v_normalised_data_exp;
    shared_vvc_cmd.alert_level        := alert_level;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  --==========================================================================================
  -- Transaction info methods
  --==========================================================================================
  procedure set_global_vvc_transaction_info (
    signal   vvc_transaction_info_trigger : inout std_logic;
    variable vvc_transaction_info_group   : inout t_transaction_group;
    constant vvc_cmd                      : in t_vvc_cmd_record;
    constant vvc_config                   : in t_vvc_config;
    constant transaction_status           : in t_transaction_status;
    constant scope                        : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) is
  begin
    if is_phy_operation(vvc_cmd.operation) or is_sta_operation(vvc_cmd.operation) then
      vvc_transaction_info_group.bt.operation          := vvc_cmd.operation;
      vvc_transaction_info_group.bt.data               := vvc_cmd.data;
      vvc_transaction_info_group.bt.dev_addr           := vvc_cmd.dev_addr;
      vvc_transaction_info_group.bt.phy_addr           := vvc_cmd.phy_addr;
      vvc_transaction_info_group.bt.reg_addr           := vvc_cmd.reg_addr;
      vvc_transaction_info_group.bt.vvc_meta.msg       := vvc_cmd.msg;
      vvc_transaction_info_group.bt.vvc_meta.cmd_idx   := vvc_cmd.cmd_idx;
      vvc_transaction_info_group.bt.transaction_status := transaction_status;
      gen_pulse(vvc_transaction_info_trigger, 0 ns, "pulsing global vvc transaction info trigger", scope, ID_NEVER);
    else
      alert(TB_ERROR, "VVC operation not recognized", scope);
    end if;

    wait for 0 ns;
  end procedure set_global_vvc_transaction_info;

  procedure set_global_vvc_transaction_info (
    signal   vvc_transaction_info_trigger : inout std_logic;
    variable vvc_transaction_info_group   : inout t_transaction_group;
    constant vvc_cmd                      : in t_vvc_cmd_record;
    constant vvc_result                   : in t_vvc_result;
    constant transaction_status           : in t_transaction_status;
    constant scope                        : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) is
  begin
    if is_sta_read_operation(vvc_cmd.operation) or is_phy_receive_operation(vvc_cmd.operation) then
      vvc_transaction_info_group.bt.operation          := vvc_cmd.operation;
      vvc_transaction_info_group.bt.data               := vvc_result; -- the data that was read / received
      vvc_transaction_info_group.bt.dev_addr           := vvc_cmd.dev_addr;
      vvc_transaction_info_group.bt.phy_addr           := vvc_cmd.phy_addr;
      vvc_transaction_info_group.bt.reg_addr           := vvc_cmd.reg_addr;
      if vvc_cmd.operation = PHY_C45_RECEIVE_ADDRESS then
        -- the payload of an address frame is the register address, not data
        vvc_transaction_info_group.bt.data     := vvc_cmd.data;
        vvc_transaction_info_group.bt.reg_addr := unsigned(vvc_result);
      end if;
      vvc_transaction_info_group.bt.vvc_meta.msg       := vvc_cmd.msg;
      vvc_transaction_info_group.bt.vvc_meta.cmd_idx   := vvc_cmd.cmd_idx;
      vvc_transaction_info_group.bt.transaction_status := transaction_status;
      gen_pulse(vvc_transaction_info_trigger, 0 ns, "pulsing global vvc transaction info trigger", scope, ID_NEVER);
    else
      alert(TB_ERROR, "VVC operation does not update vvc_result ", scope);
    end if;

    wait for 0 ns;
  end procedure set_global_vvc_transaction_info;

  procedure reset_vvc_transaction_info (
    variable vvc_transaction_info_group : inout t_transaction_group;
    constant vvc_cmd                    : in t_vvc_cmd_record
  ) is
  begin
    if is_phy_operation(vvc_cmd.operation) or is_sta_operation(vvc_cmd.operation) then
      vvc_transaction_info_group.bt := C_BASE_TRANSACTION_SET_DEFAULT;
    end if;

    wait for 0 ns;
  end procedure reset_vvc_transaction_info;

end package body vvc_methods_pkg;
