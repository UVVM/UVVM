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
use uvvm_vvc_framework.ti_protected_types_pkg.all;

-- Include Verification IPs
library p2l2_vip_mdio;
context p2l2_vip_mdio.vvc_context;
use p2l2_vip_mdio.vvc_sb_support_pkg.all;

--hdlregression:tb
-- Test case entity
-- VVC-to-VVC: one STA VVC against three PHY VVCs on one bus (mdio_th, architecture struct_vvc).
entity mdio_vvc_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity;

-- Test case architecture
architecture func of mdio_vvc_tb is

  constant C_SCOPE : string := C_TB_SCOPE_DEFAULT;

  -- VVC instances
  constant C_STA   : natural := 0;
  constant C_PHY_1 : natural := 1;
  constant C_PHY_2 : natural := 2;
  constant C_PHY_3 : natural := 3;

  -- PHY addresses of the PHY VVCs 1, 2 and 3
  constant C_PHY_ADDRESSES    : t_natural_array(0 to 2) := (1, 2, 3);
  constant C_PHY_1_ADDR       : unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0) := "00001";
  constant C_PHY_2_ADDR       : unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0) := "00010";
  constant C_PHY_3_ADDR       : unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0) := "00011";
  constant C_MISSING_PHY_ADDR : unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0) := "00100"; -- no PHY VVC answers

  constant C_NUM_RANDOM_FRAMES : positive := 50;
  constant C_AWAIT_TIMEOUT     : time     := 10 ms; -- enough for C_NUM_RANDOM_FRAMES frames of up to 51.2 us

  type t_data_array is array (natural range <>) of std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);

  signal mdc  : std_logic;
  signal mdio : std_logic;

  -- transaction info of the STA VVC and of PHY VVC 1, checked in p_main: the last one that started (IN_PROGRESS) and
  -- the last one that completed
  signal last_sta_start : t_base_transaction := C_BASE_TRANSACTION_SET_DEFAULT;
  signal last_sta_trans : t_base_transaction := C_BASE_TRANSACTION_SET_DEFAULT;
  signal last_phy_start : t_base_transaction := C_BASE_TRANSACTION_SET_DEFAULT;
  signal last_phy_trans : t_base_transaction := C_BASE_TRANSACTION_SET_DEFAULT;

begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing the VVCs
  -----------------------------------------------------------------------------
  i_test_harness : entity work.mdio_th(struct_vvc)
    generic map(
      GC_PHY_ADDRESSES => C_PHY_ADDRESSES
    )
    port map(
      mdc  => mdc,
      mdio => mdio
    );

  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  ------------------------------------------------
  -- Transaction info monitors of the STA VVC and of PHY VVC 1
  ------------------------------------------------
  p_sta_trans_monitor : process is
  begin
    wait on global_mdio_vvc_transaction_trigger(C_STA);
    if shared_mdio_vvc_transaction_info(C_STA).bt.transaction_status = IN_PROGRESS then
      last_sta_start <= shared_mdio_vvc_transaction_info(C_STA).bt;
    elsif shared_mdio_vvc_transaction_info(C_STA).bt.transaction_status = COMPLETED then
      last_sta_trans <= shared_mdio_vvc_transaction_info(C_STA).bt;
    end if;
  end process;

  p_phy_trans_monitor : process is
  begin
    wait on global_mdio_vvc_transaction_trigger(C_PHY_1);
    if shared_mdio_vvc_transaction_info(C_PHY_1).bt.transaction_status = IN_PROGRESS then
      last_phy_start <= shared_mdio_vvc_transaction_info(C_PHY_1).bt;
    elsif shared_mdio_vvc_transaction_info(C_PHY_1).bt.transaction_status = COMPLETED then
      last_phy_trans <= shared_mdio_vvc_transaction_info(C_PHY_1).bt;
    end if;
  end process;

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process is
    variable v_cmd_idx   : natural;
    variable v_data      : std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0); -- = t_vvc_result (vvc_cmd_pkg)
    variable v_is_ok     : boolean;
    variable v_start     : time;
    -- random frames: the commands whose result is fetched after the batch, and the expected data
    variable v_reg_addr  : unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0);
    variable v_dev_addr  : unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
    variable v_wdata     : std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    variable v_num_reads : natural;
    variable v_read_idx  : t_natural_array(1 to C_NUM_RANDOM_FRAMES);
    variable v_read_exp  : t_data_array(1 to C_NUM_RANDOM_FRAMES);
    -- framework test cases
    variable v_frame_time  : time; -- duration of one STA frame (preamble + 32 bits + IDLE), measured in the test case
    variable v_first_idx   : natural;
    variable v_vvc_list    : t_prot_vvc_list;
    variable v_alert_level : t_alert_level;
    variable v_num         : natural; -- expected number of alerts

    -- Fetch the results of the reads collected in v_read_idx / v_read_exp and compare them
    procedure fetch_and_check_reads(
      constant vvc_instance_idx : in natural;
      constant msg              : in string) is
    begin
      for i in 1 to v_num_reads loop
        fetch_result(MDIO_VVCT, vvc_instance_idx, v_read_idx(i), v_data, "Fetch " & msg & " " & to_string(i));
        check_value(v_data, v_read_exp(i), ERROR, msg & " " & to_string(i), C_SCOPE);
      end loop;
      v_num_reads := 0;
    end procedure fetch_and_check_reads;

    procedure add_read(
      constant vvc_instance_idx : in natural;
      constant data_exp         : in std_ulogic_vector) is
    begin
      v_num_reads             := v_num_reads + 1;
      v_read_idx(v_num_reads) := get_last_received_cmd_idx(MDIO_VVCT, vvc_instance_idx);
      v_read_exp(v_num_reads) := data_exp;
    end procedure add_read;

    -- One write of the STA to a PHY address nobody answers. Returns the duration of the frame.
    procedure measure_frame_time(variable frame_time : out time) is
      variable v_t0 : time;
    begin
      v_t0 := now;
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00000", x"0000", "STA write to measure the frame time");
      await_completion(MDIO_VVCT, C_STA, 1 ms, "frame time");
      frame_time := now - v_t0;
      log(ID_SEQUENCER, "One frame takes " & to_string(frame_time), C_SCOPE);
    end procedure measure_frame_time;

    -- Forces MDIO to 'value' for one bit of the next STA frame: from the falling MDC edge that starts bit 'bit_idx'
    -- (transmission order, the first preamble bit is 0) to the next falling edge. Called right after the command is queued.
    procedure force_frame_bit(
      constant bit_idx : in natural;
      constant value   : in std_logic) is
    begin
      for i in 1 to bit_idx loop
        wait until falling_edge(mdc);
      end loop;
      mdio <= force value;
      wait until falling_edge(mdc);
      mdio <= release;
    end procedure force_frame_bit;

    -- Unwanted activity on MDIO while the STA VVC is inactive (the STA mode check, see mdio_vvc.vhd).
    -- MDIO idles at 'H' (pull-up). Each forced change and its release is one alert, except the ignored transitions.
    procedure toggle_vvc_if(constant alert_level : in t_alert_level) is
      variable v_alerts : natural;
      procedure check_alerts(constant expected : in natural; constant msg : in string) is
      begin
        wait for 0 ns; -- the alert is raised a few delta cycles after the change
        wait for 0 ns;
        wait for 0 ns;
        if alert_level /= NO_ALERT then
          check_value(get_alert_counter(alert_level), expected, ERROR, msg, C_SCOPE, ID_NEVER);
        end if;
      end procedure check_alerts;
    begin
      if alert_level /= NO_ALERT then
        increment_expected_alerts_and_stop_limit(alert_level, 4);
        v_alerts := get_alert_counter(alert_level);
      end if;
      -- 'H' -> '0' and back: two alerts
      mdio <= force '0';
      wait for 100 ns;
      check_alerts(v_alerts + 1, "unwanted activity H -> 0");
      mdio <= release;
      wait for 100 ns;
      check_alerts(v_alerts + 2, "unwanted activity 0 -> H");
      -- ignored: 'H' <-> '1', 'U' -> 'L', 'L' <-> '0'. 'H' -> 'U' and 'L' -> 'H' are alerted.
      mdio <= force '1';
      wait for 100 ns;
      mdio <= release;
      wait for 100 ns;
      check_alerts(v_alerts + 2, "H <-> 1 is ignored");
      mdio <= force 'U';
      wait for 100 ns;
      check_alerts(v_alerts + 3, "unwanted activity H -> U");
      mdio <= force 'L';
      wait for 100 ns;
      mdio <= force '0';
      wait for 100 ns;
      mdio <= force 'L';
      wait for 100 ns;
      check_alerts(v_alerts + 3, "U -> L, L <-> 0 are ignored");
      mdio <= release;
      wait for 100 ns;
      check_alerts(v_alerts + 4, "unwanted activity L -> H");
    end procedure toggle_vvc_if;

    -- Number of MDIO changes after the first rising MDC edge of a frame: one per bit that differs from the bit
    -- before, plus the release of MDIO after the last bit. 'bits' starts with the bit that the first edge samples.
    function num_changes(constant bits : std_ulogic_vector) return natural is
      constant C_BITS : std_ulogic_vector(0 to bits'length-1) := bits;
      variable v_num  : natural := 1;
    begin
      for i in 1 to C_BITS'high loop
        if C_BITS(i) /= C_BITS(i-1) then
          v_num := v_num + 1;
        end if;
      end loop;
      return v_num;
    end function num_changes;

    -- The bits of a clause 22 write frame, with preamble
    function c22_write_bits(
      constant phy_addr : unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
      constant reg_addr : unsigned(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0);
      constant data     : std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0)) return std_ulogic_vector is
      constant C_PREAMBLE : std_ulogic_vector(1 to C_MDIO_PREAMBLE_LENGTH) := (others => '1');
    begin
      return C_PREAMBLE & C_MDIO_ST_CL22 & C_MDIO_OP_CL22_WRITE & std_ulogic_vector(phy_addr) & std_ulogic_vector(reg_addr) & "10" & data;
    end function c22_write_bits;

    -- Transaction info of the last command of the STA VVC (sta = true) or of PHY VVC 1: started with IN_PROGRESS,
    -- ended with COMPLETED, with the given fields. The instance is idle again: the transaction info is reset.
    procedure check_transaction(
      constant sta       : in boolean;
      constant operation : in t_operation;
      constant data      : in std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
      constant phy_addr  : in unsigned(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
      constant dev_addr  : in unsigned(C_MDIO_DEV_ADDR_WIDTH-1 downto 0);
      constant reg_addr  : in unsigned(C_MDIO_REG_ADDR_WIDTH_C45-1 downto 0)) is
      variable v_idx   : natural;
      variable v_start : t_base_transaction;
      variable v_trans : t_base_transaction;
    begin
      if sta then
        v_idx := C_STA;   v_start := last_sta_start; v_trans := last_sta_trans;
      else
        v_idx := C_PHY_1; v_start := last_phy_start; v_trans := last_phy_trans;
      end if;
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, v_idx);
      log(ID_SEQUENCER, "Transaction info of " & to_string(operation), C_SCOPE);
      check_value(v_start.operation = operation, ERROR, "started: operation " & to_string(v_start.operation), C_SCOPE);
      check_value(v_start.transaction_status = IN_PROGRESS, ERROR, "started: IN_PROGRESS", C_SCOPE);
      check_value(v_start.vvc_meta.cmd_idx, v_cmd_idx, ERROR, "started: cmd_idx", C_SCOPE);
      check_value(v_trans.operation = operation, ERROR, "completed: operation " & to_string(v_trans.operation), C_SCOPE);
      check_value(v_trans.transaction_status = COMPLETED, ERROR, "completed: COMPLETED", C_SCOPE);
      check_value(v_trans.vvc_meta.cmd_idx, v_cmd_idx, ERROR, "completed: cmd_idx", C_SCOPE);
      check_value(v_trans.data, data, ERROR, "completed: data", C_SCOPE);
      check_value(v_trans.phy_addr, phy_addr, ERROR, "completed: phy_addr", C_SCOPE);
      check_value(v_trans.dev_addr, dev_addr, ERROR, "completed: dev_addr", C_SCOPE);
      check_value(v_trans.reg_addr, reg_addr, ERROR, "completed: reg_addr", C_SCOPE);
      check_value(shared_mdio_vvc_transaction_info(v_idx).bt.transaction_status = INACTIVE, ERROR, "idle: INACTIVE", C_SCOPE);
    end procedure check_transaction;

    -- Back to the configuration of the test harness (STA 0, PHYs 1..3 with their addresses)
    procedure reset_vvc_configs is
    begin
      for i in C_STA to C_PHY_3 loop
        shared_mdio_vvc_config(i).bfm_config         := C_MDIO_BFM_CONFIG_DEFAULT;
        shared_mdio_vvc_config(i).bus_timing_checker := C_BUS_TIMING_CHECKER_DEFAULT;
      end loop;
      shared_mdio_vvc_config(C_PHY_1).bfm_config.phy.phy_address := C_PHY_1_ADDR;
      shared_mdio_vvc_config(C_PHY_2).bfm_config.phy.phy_address := C_PHY_2_ADDR;
      shared_mdio_vvc_config(C_PHY_3).bfm_config.phy.phy_address := C_PHY_3_ADDR;
    end procedure reset_vvc_configs;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    await_uvvm_initialization(VOID);

    -- Verbosity control
    disable_log_msg(ID_AWAIT_COMPLETION);
    disable_log_msg(ID_AWAIT_COMPLETION_LIST);
    disable_log_msg(ID_AWAIT_COMPLETION_WAIT);
    disable_log_msg(ID_AWAIT_COMPLETION_END);
    disable_log_msg(ID_UVVM_CMD_ACK);
    disable_log_msg(ID_POS_ACK);
    disable_log_msg(ID_UVVM_CMD_RESULT);

    disable_log_msg(VVC_BROADCAST, ID_CMD_EXECUTOR);
    disable_log_msg(VVC_BROADCAST, ID_CMD_EXECUTOR_WAIT);
    disable_log_msg(VVC_BROADCAST, ID_CMD_INTERPRETER);
    disable_log_msg(VVC_BROADCAST, ID_CMD_INTERPRETER_WAIT);
    disable_log_msg(VVC_BROADCAST, ID_IMMEDIATE_CMD);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    randomize(12, 34, "Set the random seeds", C_SCOPE);
    v_num_reads := 0;

    log(ID_LOG_HDR_LARGE, "Simulating " & GC_TESTCASE, C_SCOPE);

    --============================================================================================================================
    if GC_TESTCASE = "c22_sta_to_phy" then
      --============================================================================================================================
      log(ID_LOG_HDR, "Clause 22 write / read / check", C_SCOPE);
      ------------------------------------------------------------
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY expects a write");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"BEEF", "STA writes");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C22 write");
      check_value(last_sta_trans.operation = STA_C22_WRITE, ERROR, "transaction info: operation", C_SCOPE);
      check_value(last_sta_trans.data, std_ulogic_vector'(x"BEEF"), ERROR, "transaction info: data", C_SCOPE);

      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00110", x"1234", "PHY replies to a read");
      mdio_sta_c22_read(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00110", "STA reads");
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_STA);
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C22 read");
      fetch_result(MDIO_VVCT, C_STA, v_cmd_idx, v_data, v_is_ok, "Fetch the C22 read");
      check_value(v_is_ok, ERROR, "fetch accepted", C_SCOPE);
      check_value(v_data, x"1234", ERROR, "C22 read data", C_SCOPE);
      -- the transaction info of the read carries the data, the addresses and the operation
      check_value(last_sta_trans.data, std_ulogic_vector'(x"1234"), ERROR, "transaction info: data", C_SCOPE);
      check_value(last_sta_trans.phy_addr, C_PHY_1_ADDR, ERROR, "transaction info: phy_addr", C_SCOPE);
      check_value(last_sta_trans.reg_addr, unsigned'(x"0006"), ERROR, "transaction info: reg_addr (clause 22, zero-extended)", C_SCOPE);
      check_value(last_sta_trans.operation = STA_C22_READ, ERROR, "transaction info: operation", C_SCOPE);

      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00111", x"00FF", "PHY replies to a read");
      mdio_sta_c22_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00111", x"00FF", "STA checks, data as expected");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C22 check");

      log(ID_SEQUENCER, "C22 check with a wrong expected value: one ERROR is expected", C_SCOPE);
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00111", x"00FF", "PHY replies to a read");
      mdio_sta_c22_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00111", x"00FE", "STA checks, data differs");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C22 check mismatch");

      log(ID_LOG_HDR, "Random clause 22 frames, queued as one batch", C_SCOPE);
      ------------------------------------------------------------
      for i in 1 to C_NUM_RANDOM_FRAMES loop
        v_reg_addr := unsigned(random(C_MDIO_REG_ADDR_WIDTH_C22));
        v_wdata    := random(C_MDIO_DATA_WIDTH);
        case random(0, 2) is
          when 0 =>
            mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, v_reg_addr, v_wdata, "PHY expects a random write");
            mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, v_reg_addr, v_wdata, "STA writes random data");
          when 1 =>
            mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, v_reg_addr, v_wdata, "PHY replies random data");
            mdio_sta_c22_read(MDIO_VVCT, C_STA, C_PHY_1_ADDR, v_reg_addr, "STA reads");
            add_read(C_STA, v_wdata);
          when others =>
            mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, v_reg_addr, v_wdata, "PHY replies random data");
            mdio_sta_c22_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, v_reg_addr, v_wdata, "STA checks");
        end case;
      end loop;
      await_completion(MDIO_VVCT, ALL_INSTANCES, C_AWAIT_TIMEOUT, "random C22 frames");
      fetch_and_check_reads(C_STA, "random C22 read");

    --============================================================================================================================
    elsif GC_TESTCASE = "c45_sta_to_phy" then
      --============================================================================================================================
      log(ID_LOG_HDR, "Clause 45, single frames", C_SCOPE);
      ------------------------------------------------------------
      mdio_phy_c45_expect_address(MDIO_VVCT, C_PHY_1, "00011", x"8000", "PHY expects the address frame");
      mdio_sta_c45_address(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"8000", "STA sends the address frame");
      mdio_phy_c45_expect_write(MDIO_VVCT, C_PHY_1, "00011", x"CAFE", "PHY expects the write frame");
      mdio_sta_c45_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"CAFE", "STA sends the write frame");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C45 address + write");

      mdio_phy_c45_reply_read(MDIO_VVCT, C_PHY_1, "00011", x"7777", "PHY replies to a read");
      mdio_sta_c45_read(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", "STA sends a read frame");
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_STA);
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C45 read");
      fetch_result(MDIO_VVCT, C_STA, v_cmd_idx, v_data, "Fetch the C45 read");
      check_value(v_data, x"7777", ERROR, "C45 read data", C_SCOPE);
      check_value(last_sta_trans.operation = STA_C45_READ, ERROR, "transaction info: operation", C_SCOPE);
      check_value(last_sta_trans.dev_addr, unsigned'("00011"), ERROR, "transaction info: dev_addr", C_SCOPE);

      mdio_phy_c45_reply_post_read_increment(MDIO_VVCT, C_PHY_1, "00011", x"8888", "PHY replies to a post-read-increment");
      mdio_sta_c45_post_read_increment(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", "STA sends a post-read-increment frame");
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_STA);
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C45 post read inc");
      fetch_result(MDIO_VVCT, C_STA, v_cmd_idx, v_data, "Fetch the C45 post-read-increment");
      check_value(v_data, x"8888", ERROR, "C45 post read inc data", C_SCOPE);

      mdio_phy_c45_reply_read(MDIO_VVCT, C_PHY_1, "00011", x"7777", "PHY replies to a read");
      mdio_sta_c45_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"7777", "STA checks a read");
      mdio_phy_c45_reply_post_read_increment(MDIO_VVCT, C_PHY_1, "00011", x"8888", "PHY replies to a post-read-increment");
      mdio_sta_c45_check_post_read_increment(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"8888", "STA checks a post-read-increment");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C45 checks");

      log(ID_SEQUENCER, "C45 checks with a wrong expected value: one ERROR each is expected", C_SCOPE);
      increment_expected_alerts_and_stop_limit(ERROR, 2);
      mdio_phy_c45_reply_read(MDIO_VVCT, C_PHY_1, "00011", x"7777", "PHY replies to a read");
      mdio_sta_c45_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"7778", "STA checks a read, data differs");
      mdio_phy_c45_reply_post_read_increment(MDIO_VVCT, C_PHY_1, "00011", x"8888", "PHY replies to a post-read-increment");
      mdio_sta_c45_check_post_read_increment(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"8889", "STA checks a post-read-increment, data differs");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C45 check mismatch");

      log(ID_LOG_HDR, "Random clause 45 frames, queued as one batch", C_SCOPE);
      ------------------------------------------------------------
      for i in 1 to C_NUM_RANDOM_FRAMES loop
        v_dev_addr := unsigned(random(C_MDIO_DEV_ADDR_WIDTH));
        v_wdata    := random(C_MDIO_DATA_WIDTH);
        case random(0, 5) is
          when 0 =>
            mdio_phy_c45_expect_address(MDIO_VVCT, C_PHY_1, v_dev_addr, unsigned(v_wdata), "PHY expects a random address frame");
            mdio_sta_c45_address(MDIO_VVCT, C_STA, C_PHY_1_ADDR, v_dev_addr, unsigned(v_wdata), "STA sends a random address frame");
          when 1 =>
            mdio_phy_c45_expect_write(MDIO_VVCT, C_PHY_1, v_dev_addr, v_wdata, "PHY expects a random write");
            mdio_sta_c45_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, v_dev_addr, v_wdata, "STA writes random data");
          when 2 =>
            mdio_phy_c45_reply_read(MDIO_VVCT, C_PHY_1, v_dev_addr, v_wdata, "PHY replies random data");
            mdio_sta_c45_read(MDIO_VVCT, C_STA, C_PHY_1_ADDR, v_dev_addr, "STA reads");
            add_read(C_STA, v_wdata);
          when 3 =>
            mdio_phy_c45_reply_post_read_increment(MDIO_VVCT, C_PHY_1, v_dev_addr, v_wdata, "PHY replies random data");
            mdio_sta_c45_post_read_increment(MDIO_VVCT, C_STA, C_PHY_1_ADDR, v_dev_addr, "STA reads with post-read-increment");
            add_read(C_STA, v_wdata);
          when 4 =>
            mdio_phy_c45_reply_read(MDIO_VVCT, C_PHY_1, v_dev_addr, v_wdata, "PHY replies random data");
            mdio_sta_c45_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, v_dev_addr, v_wdata, "STA checks");
          when others =>
            mdio_phy_c45_reply_post_read_increment(MDIO_VVCT, C_PHY_1, v_dev_addr, v_wdata, "PHY replies random data");
            mdio_sta_c45_check_post_read_increment(MDIO_VVCT, C_STA, C_PHY_1_ADDR, v_dev_addr, v_wdata, "STA checks with post-read-increment");
        end case;
      end loop;
      await_completion(MDIO_VVCT, ALL_INSTANCES, C_AWAIT_TIMEOUT, "random C45 frames");
      fetch_and_check_reads(C_STA, "random C45 read");

    --============================================================================================================================
    elsif GC_TESTCASE = "c45_reg_access" then
      --============================================================================================================================
      log(ID_LOG_HDR, "Clause 45, complete register access (*_reg)", C_SCOPE);
      ------------------------------------------------------------
      mdio_phy_c45_expect_address(MDIO_VVCT, C_PHY_1, "00011", x"1234", "PHY expects the address frame");
      mdio_phy_c45_expect_write(MDIO_VVCT, C_PHY_1, "00011", x"CAFE", "PHY expects the write frame");
      mdio_sta_c45_write_reg(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"1234", x"CAFE", "STA writes a register");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C45 write_reg");
      check_value(last_sta_trans.operation = STA_C45_WRITE_REG, ERROR, "transaction info: operation of write_reg", C_SCOPE);
      check_value(last_sta_trans.reg_addr, unsigned'(x"1234"), ERROR, "transaction info: reg_addr", C_SCOPE);
      check_value(last_sta_trans.data, std_ulogic_vector'(x"CAFE"), ERROR, "transaction info: data", C_SCOPE);

      mdio_phy_c45_expect_address(MDIO_VVCT, C_PHY_1, "00011", x"4321", "PHY expects the address frame");
      mdio_phy_c45_reply_read(MDIO_VVCT, C_PHY_1, "00011", x"ABCD", "PHY replies to a read");
      mdio_sta_c45_read_reg(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"4321", "STA reads a register");
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_STA);
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C45 read_reg");
      fetch_result(MDIO_VVCT, C_STA, v_cmd_idx, v_data, "Fetch the C45 read_reg");
      check_value(v_data, x"ABCD", ERROR, "C45 read_reg data", C_SCOPE);
      check_value(last_sta_trans.operation = STA_C45_READ_REG, ERROR, "transaction info: operation of read_reg", C_SCOPE);
      check_value(last_sta_trans.reg_addr, unsigned'(x"4321"), ERROR, "transaction info: reg_addr", C_SCOPE);
      check_value(last_sta_trans.data, std_ulogic_vector'(x"ABCD"), ERROR, "transaction info: data", C_SCOPE);

      mdio_phy_c45_expect_address(MDIO_VVCT, C_PHY_1, "00011", x"4321", "PHY expects the address frame");
      mdio_phy_c45_reply_read(MDIO_VVCT, C_PHY_1, "00011", x"ABCD", "PHY replies to a read");
      mdio_sta_c45_check_reg(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"4321", x"ABCD", "STA checks a register");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C45 check_reg");
      check_value(last_sta_trans.operation = STA_C45_CHECK_REG, ERROR, "transaction info: operation of check_reg", C_SCOPE);

      log(ID_SEQUENCER, "check_reg with a wrong expected value: one ERROR is expected", C_SCOPE);
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      mdio_phy_c45_expect_address(MDIO_VVCT, C_PHY_1, "00011", x"4321", "PHY expects the address frame");
      mdio_phy_c45_reply_read(MDIO_VVCT, C_PHY_1, "00011", x"ABCD", "PHY replies to a read");
      mdio_sta_c45_check_reg(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"4321", x"ABCE", "STA checks a register, data differs", ERROR);
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C45 check_reg mismatch");

      log(ID_LOG_HDR, "Failed address frame: the access frame is not sent", C_SCOPE);
      ------------------------------------------------------------
      -- The first register address bit of the address frame is forced to '1' while the STA drives '0': bus contention,
      -- one ERROR per command. The command ends after the address frame. No PHY has the address, so only the STA alerts.
      measure_frame_time(v_frame_time);
      for i in 0 to 2 loop
        increment_expected_alerts_and_stop_limit(ERROR, 1);
        v_start := now;
        case i is
          when 0 =>
            mdio_sta_c45_write_reg(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00011", x"0000", x"CAFE", "STA writes a register, address frame fails");
          when 1 =>
            mdio_sta_c45_read_reg(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00011", x"0000", "STA reads a register, address frame fails");
          when others =>
            mdio_sta_c45_check_reg(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00011", x"0000", x"ABCD", "STA checks a register, address frame fails");
        end case;
        v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_STA);
        force_frame_bit(C_MDIO_PREAMBLE_LENGTH + C_MDIO_ST_WIDTH + C_MDIO_OP_WIDTH + 2*C_MDIO_PHY_ADDR_WIDTH + C_MDIO_TA_WIDTH, '1');
        await_completion(MDIO_VVCT, C_STA, 1 ms, "failed address frame");
        check_value(now - v_start, v_frame_time, ERROR, "only the address frame was sent", C_SCOPE);
        if i = 1 then
          fetch_result(MDIO_VVCT, C_STA, v_cmd_idx, v_data, "Fetch the read_reg");
          check_value(v_data, (v_data'range => 'X'), MATCH_EXACT, ERROR, "read_reg returns no data", C_SCOPE);
        end if;
      end loop;

      log(ID_LOG_HDR, "Random register accesses, queued as one batch", C_SCOPE);
      ------------------------------------------------------------
      for i in 1 to C_NUM_RANDOM_FRAMES / 2 loop -- two frames per access
        v_dev_addr := unsigned(random(C_MDIO_DEV_ADDR_WIDTH));
        v_wdata    := random(C_MDIO_DATA_WIDTH);
        v_data     := random(C_MDIO_DATA_WIDTH); -- register address
        mdio_phy_c45_expect_address(MDIO_VVCT, C_PHY_1, v_dev_addr, unsigned(v_data), "PHY expects the address frame");
        case random(0, 2) is
          when 0 =>
            mdio_phy_c45_expect_write(MDIO_VVCT, C_PHY_1, v_dev_addr, v_wdata, "PHY expects a random write");
            mdio_sta_c45_write_reg(MDIO_VVCT, C_STA, C_PHY_1_ADDR, v_dev_addr, unsigned(v_data), v_wdata, "STA writes a random register");
          when 1 =>
            mdio_phy_c45_reply_read(MDIO_VVCT, C_PHY_1, v_dev_addr, v_wdata, "PHY replies random data");
            mdio_sta_c45_read_reg(MDIO_VVCT, C_STA, C_PHY_1_ADDR, v_dev_addr, unsigned(v_data), "STA reads a random register");
            add_read(C_STA, v_wdata);
          when others =>
            mdio_phy_c45_reply_read(MDIO_VVCT, C_PHY_1, v_dev_addr, v_wdata, "PHY replies random data");
            mdio_sta_c45_check_reg(MDIO_VVCT, C_STA, C_PHY_1_ADDR, v_dev_addr, unsigned(v_data), v_wdata, "STA checks a random register");
        end case;
      end loop;
      await_completion(MDIO_VVCT, ALL_INSTANCES, C_AWAIT_TIMEOUT, "random register accesses");
      fetch_and_check_reads(C_STA, "random read_reg");

    --============================================================================================================================
    elsif GC_TESTCASE = "phy_receive_and_fetch_result" then
      --============================================================================================================================
      log(ID_LOG_HDR, "PHY receive_* methods and fetch_result()", C_SCOPE);
      ------------------------------------------------------------
      mdio_phy_c22_receive_write(MDIO_VVCT, C_PHY_1, "00101", "PHY receives a C22 write");
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_PHY_1);
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"A5A5", "STA writes");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C22 receive_write");
      fetch_result(MDIO_VVCT, C_PHY_1, v_cmd_idx, v_data, v_is_ok, "Fetch the C22 receive_write");
      check_value(v_is_ok, ERROR, "fetch accepted", C_SCOPE);
      check_value(v_data, x"A5A5", ERROR, "C22 received data", C_SCOPE);

      mdio_phy_c45_receive_address(MDIO_VVCT, C_PHY_1, "00011", "PHY receives a C45 address frame");
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_PHY_1);
      mdio_sta_c45_address(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"8001", "STA sends the address frame");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C45 receive_address");
      fetch_result(MDIO_VVCT, C_PHY_1, v_cmd_idx, v_data, "Fetch the C45 receive_address");
      check_value(v_data, x"8001", ERROR, "C45 received register address", C_SCOPE);

      mdio_phy_c45_receive_write(MDIO_VVCT, C_PHY_1, "00011", "PHY receives a C45 write");
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_PHY_1);
      mdio_sta_c45_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"5A5A", "STA sends the write frame");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C45 receive_write");
      fetch_result(MDIO_VVCT, C_PHY_1, v_cmd_idx, v_data, "Fetch the C45 receive_write");
      check_value(v_data, x"5A5A", ERROR, "C45 received data", C_SCOPE);

      log(ID_LOG_HDR, "Random receive_* commands, queued as one batch", C_SCOPE);
      ------------------------------------------------------------
      for i in 1 to C_NUM_RANDOM_FRAMES loop
        v_reg_addr := unsigned(random(C_MDIO_REG_ADDR_WIDTH_C22));
        v_wdata    := random(C_MDIO_DATA_WIDTH);
        case random(0, 2) is
          when 0 =>
            mdio_phy_c22_receive_write(MDIO_VVCT, C_PHY_1, v_reg_addr, "PHY receives a C22 write");
            mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, v_reg_addr, v_wdata, "STA writes random data");
          when 1 =>
            mdio_phy_c45_receive_address(MDIO_VVCT, C_PHY_1, v_reg_addr, "PHY receives a C45 address frame");
            mdio_sta_c45_address(MDIO_VVCT, C_STA, C_PHY_1_ADDR, v_reg_addr, unsigned(v_wdata), "STA sends a random address frame");
          when others =>
            mdio_phy_c45_receive_write(MDIO_VVCT, C_PHY_1, v_reg_addr, "PHY receives a C45 write");
            mdio_sta_c45_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, v_reg_addr, v_wdata, "STA writes random data");
        end case;
        add_read(C_PHY_1, v_wdata);
      end loop;
      await_completion(MDIO_VVCT, ALL_INSTANCES, C_AWAIT_TIMEOUT, "random receive_* commands");
      fetch_and_check_reads(C_PHY_1, "random PHY receive");

      log(ID_LOG_HDR, "fetch_result() of a command that has not been executed: one TB_WARNING is expected", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts(TB_WARNING, 1);
      fetch_result(MDIO_VVCT, C_PHY_1, v_cmd_idx + 100, v_data, v_is_ok, "Fetch a result that does not exist", TB_WARNING);
      check_value(not v_is_ok, ERROR, "fetch is not accepted", C_SCOPE);

    --============================================================================================================================
    elsif GC_TESTCASE = "multiple_phys" then
      --============================================================================================================================
      log(ID_LOG_HDR, "Clause 22: frames to other PHY addresses are ignored", C_SCOPE);
      ------------------------------------------------------------
      mdio_phy_c22_receive_write(MDIO_VVCT, C_PHY_2, "00101", "PHY 2 receives a write");
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_PHY_2);
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00101", x"1111", "STA writes to a PHY that does not exist");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_2_ADDR, "00101", x"2222", "STA writes to PHY 2");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C22 write to PHY 2");
      fetch_result(MDIO_VVCT, C_PHY_2, v_cmd_idx, v_data, "Fetch the write PHY 2 received");
      check_value(v_data, x"2222", ERROR, "PHY 2 took only the frame to its own address", C_SCOPE);

      -- every PHY waits while the PHYs read before it answer, then answers its own read
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00001", x"1111", "PHY 1 replies to a read");
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_2, "00001", x"2222", "PHY 2 replies to a read");
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_3, "00001", x"3333", "PHY 3 replies to a read");
      mdio_sta_c22_check(MDIO_VVCT, C_STA, C_PHY_3_ADDR, "00001", x"3333", "STA checks PHY 3");
      mdio_sta_c22_check(MDIO_VVCT, C_STA, C_PHY_2_ADDR, "00001", x"2222", "STA checks PHY 2");
      mdio_sta_c22_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00001", x"1111", "STA checks PHY 1");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C22 reads of three PHYs");

      log(ID_LOG_HDR, "Clause 45: the DEVAD selects the MMD within one PHY", C_SCOPE);
      ------------------------------------------------------------
      -- PHY 1 waits for DEVAD 3: the frame to DEVAD 7 of the same PHY address is not taken
      mdio_phy_c45_receive_address(MDIO_VVCT, C_PHY_1, "00011", "PHY 1 receives an address frame to DEVAD 3");
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_PHY_1);
      mdio_sta_c45_address(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00111", x"7000", "STA sends an address frame to DEVAD 7");
      mdio_sta_c45_address(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"3000", "STA sends an address frame to DEVAD 3");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C45 address frames to two DEVADs");
      fetch_result(MDIO_VVCT, C_PHY_1, v_cmd_idx, v_data, "Fetch the address frame PHY 1 received");
      check_value(v_data, x"3000", ERROR, "PHY 1 took only the frame to DEVAD 3", C_SCOPE);

      -- one PHY serves two MMDs, one command per MMD
      mdio_phy_c45_reply_read(MDIO_VVCT, C_PHY_1, "00111", x"7777", "PHY 1 replies to a read of DEVAD 7");
      mdio_phy_c45_reply_read(MDIO_VVCT, C_PHY_1, "00011", x"3333", "PHY 1 replies to a read of DEVAD 3");
      mdio_sta_c45_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00111", x"7777", "STA checks DEVAD 7");
      mdio_sta_c45_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"3333", "STA checks DEVAD 3");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C45 reads of two DEVADs");

      log(ID_LOG_HDR, "Clause 22 and clause 45 mixed on one PHY address", C_SCOPE);
      ------------------------------------------------------------
      -- a PHY that waits for a frame of one clause does not take a frame of the other clause
      mdio_phy_c45_receive_write(MDIO_VVCT, C_PHY_1, "00011", "PHY 1 receives a C45 write");
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_PHY_1);
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"1C22", "STA sends a C22 write");
      mdio_sta_c45_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"3C45", "STA sends a C45 write");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C22 frame while a C45 frame is expected");
      fetch_result(MDIO_VVCT, C_PHY_1, v_cmd_idx, v_data, "Fetch the C45 write PHY 1 received");
      check_value(v_data, x"3C45", ERROR, "PHY 1 took only the C45 frame", C_SCOPE);

      mdio_phy_c22_receive_write(MDIO_VVCT, C_PHY_1, "00011", "PHY 1 receives a C22 write");
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_PHY_1);
      mdio_sta_c45_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"3C45", "STA sends a C45 write");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"1C22", "STA sends a C22 write");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "C45 frame while a C22 frame is expected");
      fetch_result(MDIO_VVCT, C_PHY_1, v_cmd_idx, v_data, "Fetch the C22 write PHY 1 received");
      check_value(v_data, x"1C22", ERROR, "PHY 1 took only the C22 frame", C_SCOPE);

      log(ID_LOG_HDR, "STA scans the bus for PHYs while the PHYs wait: reads to an address without a PHY are no error", C_SCOPE);
      ------------------------------------------------------------
      -- the waiting PHYs consume the reads to the missing address as frames to another target, their undriven
      -- turnaround is not reported. The STA expects the missing PHY, its turnaround check is off.
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00001", x"1111", "PHY 1 replies to a read after the scan");
      mdio_phy_c45_reply_read(MDIO_VVCT, C_PHY_2, "00011", x"2222", "PHY 2 replies to a read after the scan");
      shared_mdio_vvc_config(C_STA).bfm_config.sta.turnaround_not_driven_severity := NO_ALERT;
      mdio_sta_c22_read(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", "STA scans an address without a PHY (clause 22)");
      mdio_sta_c45_read(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00011", "STA scans an address without a PHY (clause 45)");
      mdio_sta_c22_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00001", x"1111", "STA checks PHY 1 after the scan");
      mdio_sta_c45_check(MDIO_VVCT, C_STA, C_PHY_2_ADDR, "00011", x"2222", "STA checks PHY 2 after the scan");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "bus scan while the PHYs wait");
      shared_mdio_vvc_config(C_STA).bfm_config.sta.turnaround_not_driven_severity := ERROR;

      log(ID_LOG_HDR, "No PHY answers: TA alert, all-ones data", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      mdio_sta_c22_read(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", "STA reads a PHY that does not exist");
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_STA);
      await_completion(MDIO_VVCT, C_STA, 1 ms, "read of a missing PHY");
      fetch_result(MDIO_VVCT, C_STA, v_cmd_idx, v_data, "Fetch the read of a missing PHY");
      check_value(v_data, x"FFFF", ERROR, "a missing PHY reads all ones", C_SCOPE);

    --============================================================================================================================
    elsif GC_TESTCASE = "scoreboard_test" then
      --============================================================================================================================
      log(ID_LOG_HDR, "STA reads with data_routing TO_SB", C_SCOPE);
      ------------------------------------------------------------
      mdio_vvc_sb.add_expected(C_STA, pad_mdio_sb(x"1111"));
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00001", x"1111", "PHY replies to a C22 read");
      mdio_sta_c22_read(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00001", TO_SB, "STA reads to the scoreboard");

      mdio_vvc_sb.add_expected(C_STA, pad_mdio_sb(x"2222"));
      mdio_phy_c45_reply_read(MDIO_VVCT, C_PHY_1, "00011", x"2222", "PHY replies to a C45 read");
      mdio_sta_c45_read(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", TO_SB, "STA reads to the scoreboard");

      mdio_vvc_sb.add_expected(C_STA, pad_mdio_sb(x"3333"));
      mdio_phy_c45_reply_post_read_increment(MDIO_VVCT, C_PHY_1, "00011", x"3333", "PHY replies to a post-read-increment");
      mdio_sta_c45_post_read_increment(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", TO_SB, "STA reads to the scoreboard");

      mdio_vvc_sb.add_expected(C_STA, pad_mdio_sb(x"4444"));
      mdio_phy_c45_expect_address(MDIO_VVCT, C_PHY_1, "00011", x"0100", "PHY expects the address frame");
      mdio_phy_c45_reply_read(MDIO_VVCT, C_PHY_1, "00011", x"4444", "PHY replies to a C45 read");
      mdio_sta_c45_read_reg(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"0100", TO_SB, "STA reads a register to the scoreboard");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "STA reads to the scoreboard");
      check_value(mdio_vvc_sb.get_match_count(C_STA), 4, ERROR, "STA: every read matched", C_SCOPE);

      log(ID_LOG_HDR, "PHY receives with data_routing TO_SB", C_SCOPE);
      ------------------------------------------------------------
      mdio_vvc_sb.add_expected(C_PHY_1, pad_mdio_sb(x"5555"));
      mdio_phy_c22_receive_write(MDIO_VVCT, C_PHY_1, "00010", TO_SB, "PHY receives a C22 write to the scoreboard");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00010", x"5555", "STA writes");

      mdio_vvc_sb.add_expected(C_PHY_1, pad_mdio_sb(x"0200"));
      mdio_phy_c45_receive_address(MDIO_VVCT, C_PHY_1, "00011", TO_SB, "PHY receives an address frame to the scoreboard");
      mdio_sta_c45_address(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"0200", "STA sends the address frame");

      mdio_vvc_sb.add_expected(C_PHY_1, pad_mdio_sb(x"6666"));
      mdio_phy_c45_receive_write(MDIO_VVCT, C_PHY_1, "00011", TO_SB, "PHY receives a C45 write to the scoreboard");
      mdio_sta_c45_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"6666", "STA writes");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "PHY receives to the scoreboard");
      check_value(mdio_vvc_sb.get_match_count(C_PHY_1), 3, ERROR, "PHY 1: every receive matched", C_SCOPE);

      log(ID_LOG_HDR, "Mismatch in the scoreboard: one ERROR is expected", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      mdio_vvc_sb.add_expected(C_STA, pad_mdio_sb(x"AAAA"));
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00001", x"AAAB", "PHY replies other data");
      mdio_sta_c22_read(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00001", TO_SB, "STA reads to the scoreboard");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "scoreboard mismatch");
      check_value(mdio_vvc_sb.get_mismatch_count(C_STA), 1, ERROR, "STA: one mismatch", C_SCOPE);

      log(ID_LOG_HDR, "Receive terminated before a frame arrives: nothing is sent to the scoreboard", C_SCOPE);
      ------------------------------------------------------------
      enable_log_msg(MDIO_VVCT, C_PHY_2, ID_DATA, "show that the VVC logs the skipped scoreboard check");
      mdio_vvc_sb.add_expected(C_PHY_2, pad_mdio_sb(x"7777"));
      mdio_phy_c22_receive_write(MDIO_VVCT, C_PHY_2, "00010", TO_SB, "PHY receive that gets terminated");
      wait for 10 us;
      terminate_current_command(MDIO_VVCT, C_PHY_2);
      await_completion(MDIO_VVCT, C_PHY_2, 1 ms, "terminated receive");
      check_value(mdio_vvc_sb.get_mismatch_count(C_PHY_2), 0, ERROR, "PHY 2: no mismatch for the terminated receive", C_SCOPE);
      check_value(mdio_vvc_sb.get_pending_count(C_PHY_2), 1, ERROR, "PHY 2: the expected entry stays pending", C_SCOPE);
      mdio_vvc_sb.flush(C_PHY_2);
      disable_log_msg(MDIO_VVCT, C_PHY_2, ID_DATA);

      for i in C_STA to C_PHY_3 loop
        check_value(mdio_vvc_sb.get_pending_count(i), 0, ERROR, "no expected entry left in instance " & to_string(i), C_SCOPE);
        mdio_vvc_sb.report_counters(i);
      end loop;

    --============================================================================================================================
    elsif GC_TESTCASE = "argument_normalization" then
      --============================================================================================================================
      log(ID_LOG_HDR, "Width normalisation of the address and data parameters (PHY and STA methods)", C_SCOPE);
      ------------------------------------------------------------
      -- narrower than the field: padded with zeros ("101" = 5, x"F" = 000F, "1" = 1)
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "101", x"F", "PHY method with narrow arguments");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, "1", "101", x"000F", "STA sends the frame the PHY expects");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "narrow PHY arguments");

      -- wider than the field, the cut-off bits are zero: accepted (10 bit "0000000101" = 5, 32 bit x"0000BEEF" = BEEF)
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "0000000101", x"0000BEEF", "PHY method with wide arguments (leading zeros)");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, "0000000001", "0000000101", x"0000BEEF", "STA method with wide arguments (leading zeros)");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "wide PHY and STA arguments");

      -- wider than the field, cut-off bits contain a one: one TB_ERROR per call, the low bits are used ("1000101" -> 00101)
      increment_expected_alerts_and_stop_limit(TB_ERROR, 2);
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "1000101", x"BEEF", "PHY method, address too wide");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, "1000001", "00101", x"BEEF", "STA method, PHY address too wide");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "too wide arguments");

      log(ID_LOG_HDR, "Named association: reg_addr (C22 and C45) parameters of the PHY and STA methods", C_SCOPE);
      ------------------------------------------------------------
      mdio_phy_c22_expect_write(VVCT => MDIO_VVCT, vvc_instance_idx => C_PHY_1, reg_addr => "00101", data => x"BEEF", msg => "PHY expects a write");
      mdio_sta_c22_write(VVCT => MDIO_VVCT, vvc_instance_idx => C_STA, phy_addr => C_PHY_1_ADDR, reg_addr => "00101", data => x"BEEF", msg => "STA writes");
      mdio_phy_c22_reply_read(VVCT => MDIO_VVCT, vvc_instance_idx => C_PHY_1, reg_addr => "00110", data => x"1234", msg => "PHY replies to a read");
      mdio_sta_c22_check(VVCT => MDIO_VVCT, vvc_instance_idx => C_STA, phy_addr => C_PHY_1_ADDR, reg_addr => "00110", data_exp => x"1234", msg => "STA checks");
      mdio_phy_c45_expect_address(VVCT => MDIO_VVCT, vvc_instance_idx => C_PHY_1, dev_addr => "00011", reg_addr => x"8000", msg => "PHY expects the address frame");
      mdio_sta_c45_address(VVCT => MDIO_VVCT, vvc_instance_idx => C_STA, phy_addr => C_PHY_1_ADDR, dev_addr => "00011", reg_addr => x"8000", msg => "STA sends the address frame");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "named association");

    --============================================================================================================================
    elsif GC_TESTCASE = "distribution_of_vvc_commands" then
      --============================================================================================================================
      log(ID_LOG_HDR, "Commands reach only the addressed instance", C_SCOPE);
      ------------------------------------------------------------
      insert_delay(MDIO_VVCT, C_PHY_2, 1 us, "Delay in PHY 2 only");
      v_start := now;
      await_completion(MDIO_VVCT, C_PHY_1, 1 us, "PHY 1 has nothing to do");
      await_completion(MDIO_VVCT, C_PHY_3, 1 us, "PHY 3 has nothing to do");
      await_completion(MDIO_VVCT, C_STA, 1 us, "STA has nothing to do");
      check_value(now - v_start, 0 ns, ERROR, "the other instances are idle", C_SCOPE);
      await_completion(MDIO_VVCT, C_PHY_2, 2 us, "PHY 2 executes the delay");
      check_value(now - v_start, 1 us, ERROR, "PHY 2 executed the delay", C_SCOPE);

      log(ID_LOG_HDR, "Wrong role: two TB_ERRORs are expected, nothing is executed", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(TB_ERROR, 2);
      v_start := now;
      mdio_sta_c22_write(MDIO_VVCT, C_PHY_1, C_PHY_1_ADDR, "00101", x"0000", "STA method on the PHY instance");
      mdio_phy_c22_expect_write(MDIO_VVCT, C_STA, "00101", x"0000", "PHY method on the STA instance");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "wrong role");
      check_value(now - v_start, 0 ns, ERROR, "no frame was sent or awaited", C_SCOPE);

      log(ID_LOG_HDR, "Instance that does not exist: one TB_ERROR is expected (no acknowledge)", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      -- The timeout also gives a TB_WARNING: the next log time stamp has more decimals than displayed (as in SBI)
      increment_expected_alerts(TB_WARNING, 1);
      insert_delay(MDIO_VVCT, 42, 1 us, "Delay in MDIO VVC 42, which does not exist");

    --============================================================================================================================
    elsif GC_TESTCASE = "protocol_errors_vvc" then
      --============================================================================================================================
      log(ID_LOG_HDR, "PHY methods with alert_level: one WARNING each is expected instead of an ERROR", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts(WARNING, 2);
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY expects a write, data differs", alert_level => WARNING);
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"BEEE", "STA writes other data");
      -- a wrong clause 22 register address is alerted, the PHY still replies
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00110", x"1234", "PHY replies, register address differs", alert_level => WARNING);
      mdio_sta_c22_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00111", x"1234", "STA reads another register");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "PHY alert_level");

      log(ID_LOG_HDR, "Undefined bit in a received address: one ERROR, the frame is not taken as the PHY's own", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY expects one valid write");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, "0X001", "00101", x"BEEF", "STA sends a PHY address with an undefined bit");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"BEEF", "STA sends the valid write afterwards");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "undefined address bit");

      log(ID_LOG_HDR, "Data mismatch with alert_level ERROR, WARNING and NO_ALERT (STA check and PHY expect), wrong c45 register address", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 3);
      increment_expected_alerts(WARNING, 1);
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00110", x"1234", "PHY replies to a read");
      mdio_sta_c22_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00110", x"1235", "STA checks, data differs: ERROR", ERROR);
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00110", x"1234", "PHY replies to a read");
      mdio_sta_c22_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00110", x"1235", "STA checks, data differs: WARNING", WARNING);
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00110", x"1234", "PHY replies to a read");
      mdio_sta_c22_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00110", x"1235", "STA checks, data differs: no alert", NO_ALERT);
      mdio_phy_c45_expect_write(MDIO_VVCT, C_PHY_1, "00011", x"BEEF", "PHY expects a write, data differs: ERROR");
      mdio_sta_c45_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"BEEE", "STA writes other data");
      mdio_phy_c45_expect_write(MDIO_VVCT, C_PHY_1, "00011", x"BEEF", "PHY expects a write, data differs: no alert", alert_level => NO_ALERT);
      mdio_sta_c45_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"BEEE", "STA writes other data");
      mdio_phy_c45_expect_address(MDIO_VVCT, C_PHY_1, "00011", x"8000", "PHY expects an address frame, address differs: ERROR");
      mdio_sta_c45_address(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"8001", "STA sets another register address");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "data mismatch");

      log(ID_LOG_HDR, "Wrong opcode: the PHY expects a write, the STA reads", C_SCOPE);
      ------------------------------------------------------------
      -- The PHY reports the opcode and does not drive the bus, so the STA reports the turnaround and reads the pull-up
      increment_expected_alerts_and_stop_limit(ERROR, 2);
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY expects a write");
      mdio_sta_c22_read(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", "STA reads");
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_STA);
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "wrong opcode");
      fetch_result(MDIO_VVCT, C_STA, v_cmd_idx, v_data, "Fetch the read nobody answered");
      check_value(v_data, x"FFFF", ERROR, "the STA read the pull-up", C_SCOPE);

      -- the PHY with alert_level NO_ALERT, the STA with turnaround_not_driven_severity WARNING
      increment_expected_alerts(WARNING, 1);
      shared_mdio_vvc_config(C_STA).bfm_config.sta.turnaround_not_driven_severity := WARNING;
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY expects a write, no alert", alert_level => NO_ALERT);
      mdio_sta_c22_read(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", "STA reads, turnaround WARNING");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "wrong opcode, other alert levels");
      shared_mdio_vvc_config(C_STA).bfm_config.sta.turnaround_not_driven_severity := NO_ALERT;
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY expects a write, no alert", alert_level => NO_ALERT);
      mdio_sta_c22_read(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", "STA reads, no turnaround alert");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "wrong opcode, no alerts");
      shared_mdio_vvc_config(C_STA).bfm_config.sta.turnaround_not_driven_severity := ERROR;

      log(ID_LOG_HDR, "Wrong opcode: the PHY replies to a read, the STA writes", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00101", x"1234", "PHY replies to a read");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"BEEF", "STA writes");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "wrong opcode");

      log(ID_LOG_HDR, "Undefined bit in the data the STA writes: protocol_error_severity", C_SCOPE);
      ------------------------------------------------------------
      -- one ERROR, the data is not compared
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY expects a write");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", "10111110X1101111", "STA writes an undefined bit");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "undefined data bit");
      -- protocol_error_severity NO_ALERT: received as it is
      shared_mdio_vvc_config(C_PHY_1).bfm_config.protocol_error_severity := NO_ALERT;
      mdio_phy_c22_receive_write(MDIO_VVCT, C_PHY_1, "00101", "PHY receives a write, no protocol alert");
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_PHY_1);
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", "10111110X1101111", "STA writes an undefined bit");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "undefined data bit, no alert");
      fetch_result(MDIO_VVCT, C_PHY_1, v_cmd_idx, v_data, "Fetch the received write");
      check_value(v_data, "10111110X1101111", MATCH_EXACT, ERROR, "the PHY received the undefined bit", C_SCOPE);
      shared_mdio_vvc_config(C_PHY_1).bfm_config.protocol_error_severity := ERROR;

      log(ID_LOG_HDR, "Two PHYs on one address: bus contention", C_SCOPE);
      ------------------------------------------------------------
      -- PHY 2 gets the address of PHY 1 for this test. Both reply to the read, the data differs in bit 0: each PHY
      -- reports the contention on that bit, the STA reads an undefined bit (protocol_error_severity).
      shared_mdio_vvc_config(C_PHY_2).bfm_config.phy.phy_address := C_PHY_1_ADDR;
      increment_expected_alerts_and_stop_limit(ERROR, 3);
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00001", x"1234", "PHY 1 replies to a read");
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_2, "00001", x"1235", "PHY 2 replies to the same read");
      mdio_sta_c22_read(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00001", "STA reads");
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_STA);
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "bus contention");
      fetch_result(MDIO_VVCT, C_STA, v_cmd_idx, v_data, "Fetch the read");
      check_value(v_data, "000100100011010X", MATCH_EXACT, ERROR, "bit 0 is undefined", C_SCOPE);

      -- bus_contention_severity (PHYs) and protocol_error_severity (STA) NO_ALERT: the same read without alerts
      shared_mdio_vvc_config(C_PHY_1).bfm_config.bus_contention_severity := NO_ALERT;
      shared_mdio_vvc_config(C_PHY_2).bfm_config.bus_contention_severity := NO_ALERT;
      shared_mdio_vvc_config(C_STA).bfm_config.protocol_error_severity   := NO_ALERT;
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00001", x"1234", "PHY 1 replies to a read");
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_2, "00001", x"1235", "PHY 2 replies to the same read");
      mdio_sta_c22_read(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00001", "STA reads");
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_STA);
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "bus contention, no alerts");
      fetch_result(MDIO_VVCT, C_STA, v_cmd_idx, v_data, "Fetch the read");
      check_value(v_data, "000100100011010X", MATCH_EXACT, ERROR, "bit 0 is undefined", C_SCOPE);
      reset_vvc_configs;

    --============================================================================================================================
    elsif GC_TESTCASE = "bfm_config" then
      --============================================================================================================================
      log(ID_LOG_HDR, "Config through the shared VVC config: mdc_period", C_SCOPE);
      ------------------------------------------------------------
      shared_mdio_vvc_config(C_STA).bfm_config.sta.mdc_period := 500 ns;
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY expects a write");
      v_start := now;
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"BEEF", "STA writes with a slower clock");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "slower clock");
      -- 65 bits (32 preamble + 32 frame + 1 IDLE) at 500 ns plus one low phase
      check_value(now - v_start >= 65 * 500 ns, ERROR, "the write takes at least 65 MDC cycles of 500 ns", C_SCOPE);
      check_value(now - v_start < 65 * 500 ns + 2 us, ERROR, "and not much more than that", C_SCOPE);
      shared_mdio_vvc_config(C_STA).bfm_config.sta.mdc_period := 400 ns;

      log(ID_LOG_HDR, "idle_cycles: each IDLE bit is one MDC period with MDIO released", C_SCOPE);
      ------------------------------------------------------------
      measure_frame_time(v_frame_time);
      for i in 0 to 1 loop
        if i = 0 then
          shared_mdio_vvc_config(C_STA).bfm_config.sta.idle_cycles := 0;
        else
          shared_mdio_vvc_config(C_STA).bfm_config.sta.idle_cycles := 4;
        end if;
        mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY expects a write");
        v_start := now;
        mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"BEEF", "STA write with " &
                           to_string(shared_mdio_vvc_config(C_STA).bfm_config.sta.idle_cycles) & " IDLE bits");
        await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "IDLE bits");
        check_value(now - v_start, v_frame_time + (shared_mdio_vvc_config(C_STA).bfm_config.sta.idle_cycles - 1) * 400 ns,
                    ERROR, "the call takes one MDC period per IDLE bit", C_SCOPE);
      end loop;
      shared_mdio_vvc_config(C_STA).bfm_config.sta.idle_cycles := 1;

      log(ID_LOG_HDR, "preamble_length: the PHY ignores a frame with 31 preamble bits, takes 33 and 64", C_SCOPE);
      ------------------------------------------------------------
      -- A '1' sampled right before the preamble counts as well (IDLE is pulled up), so this part runs without IDLE bits
      -- and the frame before the short preamble ends with a '0'. The configuration is read when a command is executed.
      shared_mdio_vvc_config(C_STA).bfm_config.sta.idle_cycles := 0;
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00000", x"0000", "STA write that ends with a '0'");
      await_completion(MDIO_VVCT, C_STA, 1 ms, "write that ends with a '0'");
      shared_mdio_vvc_config(C_STA).bfm_config.sta.preamble_length := 31;
      mdio_phy_c22_receive_write(MDIO_VVCT, C_PHY_1, "00101", "PHY receives a write");
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_PHY_1);
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"1111", "STA write with 31 preamble bits");
      await_completion(MDIO_VVCT, C_STA, 1 ms, "31 preamble bits");
      for i in 0 to 1 loop
        if i = 0 then
          shared_mdio_vvc_config(C_STA).bfm_config.sta.preamble_length := 33;
        else
          shared_mdio_vvc_config(C_STA).bfm_config.sta.preamble_length := 64;
          mdio_phy_c22_receive_write(MDIO_VVCT, C_PHY_1, "00101", "PHY receives a write");
          v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_PHY_1);
        end if;
        mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"2222", "STA write with a longer preamble");
        await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "longer preamble");
        fetch_result(MDIO_VVCT, C_PHY_1, v_cmd_idx, v_data, "Fetch the received write");
        check_value(v_data, x"2222", ERROR, "the PHY took the frame with " &
                    to_string(shared_mdio_vvc_config(C_STA).bfm_config.sta.preamble_length) & " preamble bits", C_SCOPE);
      end loop;
      shared_mdio_vvc_config(C_STA).bfm_config.sta.preamble_length := C_MDIO_PREAMBLE_LENGTH;
      shared_mdio_vvc_config(C_STA).bfm_config.sta.idle_cycles     := 1;

      log(ID_LOG_HDR, "suppress_preamble: the frames start with ST", C_SCOPE);
      ------------------------------------------------------------
      measure_frame_time(v_frame_time);
      -- every VVC: the PHYs and the bus timing checkers find the frame start with it
      for i in C_STA to C_PHY_3 loop
        shared_mdio_vvc_config(i).bfm_config.suppress_preamble := true;
      end loop;
      v_start := now;
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY expects a write");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"BEEF", "STA writes without preamble");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "write without preamble");
      check_value(now - v_start, v_frame_time - C_MDIO_PREAMBLE_LENGTH * 400 ns, ERROR, "the frame is 32 MDC periods shorter", C_SCOPE);
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00110", x"1234", "PHY replies to a read");
      mdio_sta_c22_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00110", x"1234", "STA reads without preamble");
      mdio_phy_c45_expect_address(MDIO_VVCT, C_PHY_1, "00011", x"8000", "PHY expects an address frame");
      mdio_sta_c45_address(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"8000", "STA sends an address frame without preamble");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "frames without preamble");

      log(ID_LOG_HDR, "sync_to_frame_start = false: the frame must start at the next rising MDC edge", C_SCOPE);
      ------------------------------------------------------------
      -- without preamble: the first bit is the '0' of ST
      shared_mdio_vvc_config(C_PHY_1).bfm_config.sync_to_frame_start := false;
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY expects a write at the next edge");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"BEEF", "STA writes without preamble");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "write at the next edge");

      -- the PHY expects no preamble, the STA sends one: one ERROR, the call ends. The frame then reaches PHY 1 with no
      -- command waiting: a second ERROR (unwanted activity)
      increment_expected_alerts_and_stop_limit(ERROR, 2);
      shared_mdio_vvc_config(C_STA).bfm_config.suppress_preamble := false;
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY expects ST at the next edge");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"BEEF", "STA writes with preamble");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "frame does not start with ST");

      -- with preamble: a shorter preamble is one ERROR, the frame is still received
      for i in C_STA to C_PHY_3 loop
        shared_mdio_vvc_config(i).bfm_config.suppress_preamble := false;
      end loop;
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      shared_mdio_vvc_config(C_STA).bfm_config.sta.preamble_length := 16;
      mdio_phy_c22_receive_write(MDIO_VVCT, C_PHY_1, "00101", "PHY receives a write at the next edge");
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_PHY_1);
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"3333", "STA writes with 16 preamble bits");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "short preamble");
      fetch_result(MDIO_VVCT, C_PHY_1, v_cmd_idx, v_data, "Fetch the received write");
      check_value(v_data, x"3333", ERROR, "the PHY took the frame", C_SCOPE);
      reset_vvc_configs;

      log(ID_LOG_HDR, "output_delay of the PHY (0 to 300 ns) and of the STA (min_hold_time to mdc_period - min_setup_time)", C_SCOPE);
      ------------------------------------------------------------
      for i in 0 to 2 loop
        case i is
          when 0 =>
            shared_mdio_vvc_config(C_PHY_1).bfm_config.output_delay := 0 ns;
            shared_mdio_vvc_config(C_STA).bfm_config.output_delay   := 10 ns;
          when 1 =>
            shared_mdio_vvc_config(C_PHY_1).bfm_config.output_delay := 150 ns;
            shared_mdio_vvc_config(C_STA).bfm_config.output_delay   := 150 ns;
          when others =>
            shared_mdio_vvc_config(C_PHY_1).bfm_config.output_delay := 290 ns;
            shared_mdio_vvc_config(C_STA).bfm_config.output_delay   := 390 ns;
        end case;
        log(ID_SEQUENCER, "PHY output_delay " & to_string(shared_mdio_vvc_config(C_PHY_1).bfm_config.output_delay) &
            ", STA output_delay " & to_string(shared_mdio_vvc_config(C_STA).bfm_config.output_delay), C_SCOPE);
        mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00110", x"A5A5", "PHY replies to a read");
        mdio_sta_c22_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00110", x"A5A5", "STA checks");
        mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"5A5A", "PHY expects a write");
        mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"5A5A", "STA writes");
        await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "output_delay");
      end loop;
      reset_vvc_configs;

      log(ID_LOG_HDR, "id_for_bfm and id_for_bfm_wait: the BFM logs with other message IDs (see the log)", C_SCOPE);
      ------------------------------------------------------------
      enable_log_msg(MDIO_VVCT, C_PHY_1, ID_BFM_POLL);
      enable_log_msg(MDIO_VVCT, C_PHY_1, ID_BFM_POLL_SUMMARY);
      shared_mdio_vvc_config(C_PHY_1).bfm_config.id_for_bfm      := ID_BFM_POLL_SUMMARY;
      shared_mdio_vvc_config(C_PHY_1).bfm_config.id_for_bfm_wait := ID_BFM_POLL;
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY logs with ID_BFM_POLL / ID_BFM_POLL_SUMMARY");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"BEEF", "STA writes");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "id_for_bfm");
      reset_vvc_configs;

    --============================================================================================================================
    elsif GC_TESTCASE = "phy_timeouts" then
      --============================================================================================================================
      log(ID_LOG_HDR, "Timeout as call parameter: one ERROR after 10 us", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      v_start := now;
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY waits for a frame that does not come", timeout => 10 us);
      await_completion(MDIO_VVCT, C_PHY_1, 1 ms, "PHY timeout");
      check_value(now - v_start, 10 us, ERROR, "the PHY call ended after the timeout", C_SCOPE);

      log(ID_LOG_HDR, "Timeout from bfm_config.phy.timeout with timeout_severity WARNING", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts(WARNING, 1);
      shared_mdio_vvc_config(C_PHY_1).bfm_config.phy.timeout          := 20 us;
      shared_mdio_vvc_config(C_PHY_1).bfm_config.phy.timeout_severity := WARNING;
      v_start := now;
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00101", x"1234", "PHY waits for a read that does not come");
      await_completion(MDIO_VVCT, C_PHY_1, 1 ms, "PHY timeout from the config");
      check_value(now - v_start, 20 us, ERROR, "the PHY call ended after the configured timeout", C_SCOPE);
      shared_mdio_vvc_config(C_PHY_1).bfm_config.phy.timeout_severity := ERROR;

      log(ID_LOG_HDR, "The timeout ends when the frame starts: a started frame is always received", C_SCOPE);
      ------------------------------------------------------------
      -- The timeout lasts until ST, after the preamble: the STA starts 5 us later, ST comes at 18 us (200 ns low phase,
      -- 32 preamble bits of 400 ns), the frame ends after the 20 us of the timeout
      v_start := now;
      mdio_phy_c22_receive_write(MDIO_VVCT, C_PHY_1, "00101", "PHY receives a write", timeout => 20 us);
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_PHY_1);
      insert_delay(MDIO_VVCT, C_STA, 5 us, "STA starts the frame later");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"1234", "STA writes");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "frame within the timeout");
      check_value(now - v_start > 20 us, ERROR, "the frame ended after the timeout", C_SCOPE);
      fetch_result(MDIO_VVCT, C_PHY_1, v_cmd_idx, v_data, "Fetch the received write");
      check_value(v_data, x"1234", ERROR, "the PHY received the frame", C_SCOPE);

      log(ID_LOG_HDR, "Frames to other PHYs do not stop the timeout: one ERROR", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      -- to an address without a PHY VVC: the idle PHY 2 would report the frames to its address as unwanted activity
      mdio_phy_c22_receive_write(MDIO_VVCT, C_PHY_1, "00101", "PHY 1 waits for its frame", timeout => 10 us);
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00101", x"1234", "STA writes to another PHY");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00101", x"1234", "STA writes to another PHY");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "frames to another PHY");

      log(ID_LOG_HDR, "timeout = 0 ns: the PHY waits without a time limit", C_SCOPE);
      ------------------------------------------------------------
      -- as call parameter: the configured 20 us do not apply
      mdio_phy_c22_receive_write(MDIO_VVCT, C_PHY_1, "00101", "PHY waits without timeout", timeout => 0 ns);
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_PHY_1);
      wait for 100 us;
      check_value(shared_mdio_vvc_status(C_PHY_1).current_cmd_idx, v_cmd_idx, ERROR, "the PHY call still waits", C_SCOPE);
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"5678", "STA writes");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "frame after 100 us");
      fetch_result(MDIO_VVCT, C_PHY_1, v_cmd_idx, v_data, "Fetch the received write");
      check_value(v_data, x"5678", ERROR, "the PHY received the frame", C_SCOPE);
      -- in the config: the call only ends by terminate
      shared_mdio_vvc_config(C_PHY_1).bfm_config.phy.timeout := 0 ns;
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY waits without timeout");
      wait for 100 us;
      check_value(shared_mdio_vvc_status(C_PHY_1).pending_cmd_cnt = 0 and shared_mdio_vvc_status(C_PHY_1).current_cmd_idx /= 0,
                  ERROR, "the PHY call still waits", C_SCOPE);
      terminate_current_command(MDIO_VVCT, C_PHY_1);
      await_completion(MDIO_VVCT, C_PHY_1, 1 us, "terminated PHY call");
      shared_mdio_vvc_config(C_PHY_1).bfm_config.phy.timeout := C_MDIO_PHY_BFM_CONFIG_DEFAULT.timeout;

      log(ID_LOG_HDR, "Negative timeout: TB_FAILURE", C_SCOPE);
      ------------------------------------------------------------
      -- the call then ends at once, without a timeout ERROR
      increment_expected_alerts_and_stop_limit(TB_FAILURE, 1);
      v_start := now;
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY call with a negative timeout", timeout => -1 us);
      await_completion(MDIO_VVCT, C_PHY_1, 1 us, "negative timeout");
      check_value(now - v_start, 0 ns, ERROR, "the call ended at once", C_SCOPE);

      log(ID_LOG_HDR, "MDC stops in the middle of a frame: max_wait_mdc_change with its severity", C_SCOPE);
      ------------------------------------------------------------
      -- The STA write is terminated after the PHY was addressed (bit 46 at 18.2 us), in the low phase of MDC. The PHY
      -- reports the stall 10 us after the last rising MDC edge.
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      shared_mdio_vvc_config(C_PHY_1).bfm_config.phy.max_wait_mdc_change          := 10 us;
      shared_mdio_vvc_config(C_PHY_1).bfm_config.phy.max_wait_mdc_change_severity := ERROR;
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY expects a write");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"BEEF", "STA write that gets terminated");
      wait for 20.1 us;
      terminate_current_command(MDIO_VVCT, C_STA);
      v_start := now;
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "MDC stall");
      check_value(now - v_start > 9 us and now - v_start <= 10 us, ERROR, "the PHY reported the stall after 10 us without an MDC edge", C_SCOPE);
      reset_vvc_configs;

    --============================================================================================================================
    elsif GC_TESTCASE = "bus_timing_checker" then
      --============================================================================================================================
      -- The writes go to a PHY address nobody answers, so only the bus timing checkers see the frames
      log(ID_LOG_HDR, "STA output_delay below min_hold_time: the STA config check and the checkers of the PHYs", C_SCOPE);
      ------------------------------------------------------------
      -- Every MDIO change of the STA comes 5 ns after a rising MDC edge, a hold time violation for each checker in
      -- PHY mode. PHY 1 reports it as ERROR, PHY 2 as WARNING, PHY 3 has its checker disabled.
      v_num := num_changes(c22_write_bits(C_MISSING_PHY_ADDR, "00101", x"BEEF"));
      increment_expected_alerts_and_stop_limit(ERROR, 1 + v_num);
      increment_expected_alerts(WARNING, v_num);
      shared_mdio_vvc_config(C_STA).bfm_config.output_delay          := 5 ns;
      shared_mdio_vvc_config(C_PHY_2).bus_timing_checker.alert_level := WARNING;
      shared_mdio_vvc_config(C_PHY_3).bus_timing_checker.enable      := false;
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00101", x"BEEF", "STA write with 5 ns hold time");
      await_completion(MDIO_VVCT, C_STA, 1 ms, "hold time violations");

      log(ID_LOG_HDR, "timing_violation_severity NO_ALERT: out-of-spec timing on purpose, only the checkers report it", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, v_num);
      shared_mdio_vvc_config(C_STA).bfm_config.timing_violation_severity := NO_ALERT;
      shared_mdio_vvc_config(C_PHY_2).bus_timing_checker.enable          := false;
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00101", x"BEEF", "STA write with 5 ns hold time");
      await_completion(MDIO_VVCT, C_STA, 1 ms, "hold time violations, no STA config alert");
      reset_vvc_configs;

      log(ID_LOG_HDR, "mdc_period 300 ns: MDC period, high and low time below the minimum", C_SCOPE);
      ------------------------------------------------------------
      -- STA config: period, high and low time (3 ERRORs). The checker of PHY 1 (WARNING) reports each MDC edge of the
      -- 64 bit frame and the IDLE bit: the period and the low time at the rising edges 2 to 65, the period at the falling
      -- edges 2 to 65 and the high time at all 65 falling edges.
      increment_expected_alerts_and_stop_limit(ERROR, 3);
      increment_expected_alerts(WARNING, 64 + 64 + 64 + 65);
      shared_mdio_vvc_config(C_STA).bfm_config.sta.mdc_period       := 300 ns;
      shared_mdio_vvc_config(C_PHY_1).bus_timing_checker.alert_level := WARNING;
      shared_mdio_vvc_config(C_PHY_2).bus_timing_checker.enable      := false;
      shared_mdio_vvc_config(C_PHY_3).bus_timing_checker.enable      := false;
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00101", x"BEEF", "STA write with a 300 ns MDC period");
      await_completion(MDIO_VVCT, C_STA, 1 ms, "MDC timing violations");
      reset_vvc_configs;

      log(ID_LOG_HDR, "PHY output_delay above 300 ns: the PHY config check and the checker of the STA", C_SCOPE);
      ------------------------------------------------------------
      -- PHY config: one ERROR. The checker of the STA (WARNING) reports every change of the PHY 310 ns after the
      -- rising MDC edge: the '0' of the turnaround, the changes in the data and the release after the last bit.
      v_num := num_changes('0' & x"A5A5") + 1;
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      increment_expected_alerts(WARNING, v_num);
      shared_mdio_vvc_config(C_PHY_1).bfm_config.output_delay      := 310 ns;
      shared_mdio_vvc_config(C_STA).bus_timing_checker.alert_level := WARNING;
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00110", x"A5A5", "PHY replies 310 ns after the MDC edges");
      mdio_sta_c22_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00110", x"A5A5", "STA checks");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "PHY output delay violations");

      log(ID_LOG_HDR, "bus_timing_checker.enable = false and timing_violation_severity NO_ALERT: nothing is reported", C_SCOPE);
      ------------------------------------------------------------
      shared_mdio_vvc_config(C_PHY_1).bfm_config.timing_violation_severity := NO_ALERT;
      shared_mdio_vvc_config(C_STA).bus_timing_checker.enable              := false;
      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00110", x"A5A5", "PHY replies 310 ns after the MDC edges");
      mdio_sta_c22_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00110", x"A5A5", "STA checks");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "no alerts");
      reset_vvc_configs;

    --============================================================================================================================
    elsif GC_TESTCASE = "read_of_executor_status_and_inter_bfm_delay" then
      --============================================================================================================================
      log(ID_LOG_HDR, "Executor status", C_SCOPE);
      ------------------------------------------------------------
      check_value(shared_mdio_vvc_status(C_STA).pending_cmd_cnt, 0, ERROR, "no command pending", C_SCOPE);
      for i in 1 to 3 loop
        mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", x"0000", "STA write " & to_string(i));
        if i = 1 then
          v_first_idx := get_last_received_cmd_idx(MDIO_VVCT, C_STA);
        end if;
      end loop;
      v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_STA);
      check_value(shared_mdio_vvc_status(C_STA).current_cmd_idx, v_first_idx, ERROR, "the first write is executed", C_SCOPE);
      check_value(shared_mdio_vvc_status(C_STA).pending_cmd_cnt, 2, ERROR, "two writes are pending", C_SCOPE);
      await_completion(MDIO_VVCT, C_STA, 1 ms, "three writes");
      check_value(shared_mdio_vvc_status(C_STA).pending_cmd_cnt, 0, ERROR, "no command pending after completion", C_SCOPE);
      check_value(shared_mdio_vvc_status(C_STA).current_cmd_idx, 0, ERROR, "no command executed after completion", C_SCOPE);
      check_value(shared_mdio_vvc_status(C_STA).previous_cmd_idx, v_cmd_idx, ERROR, "the last write was executed last", C_SCOPE);

      log(ID_LOG_HDR, "Inter-BFM delay", C_SCOPE);
      ------------------------------------------------------------
      measure_frame_time(v_frame_time);

      -- The inter-BFM delay counts from the previous BFM access, also across await_completion(). Each part waits
      -- long enough first, so its first write is not delayed.
      log(ID_SEQUENCER, "TIME_START2START", C_SCOPE);
      wait for 2 * v_frame_time;
      shared_mdio_vvc_config(C_STA).inter_bfm_delay.delay_type    := TIME_START2START;
      shared_mdio_vvc_config(C_STA).inter_bfm_delay.delay_in_time := 2 * v_frame_time;
      v_start := now;
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", x"0001", "First write");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", x"0002", "Second write");
      await_completion(MDIO_VVCT, C_STA, 1 ms, "TIME_START2START");
      check_value(now - v_start, 3 * v_frame_time, ERROR, "the second write starts 2 frame times after the first", C_SCOPE);

      log(ID_SEQUENCER, "insert_delay() (time and MDC periods) adds to the inter-BFM delay", C_SCOPE);
      wait for 2 * v_frame_time;
      v_start := now;
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", x"0001", "First write");
      insert_delay(MDIO_VVCT, C_STA, 1 us, "Delay of 1 us");
      insert_delay(MDIO_VVCT, C_STA, 1 us, "Delay of 1 us");
      insert_delay(MDIO_VVCT, C_STA, 5, "Delay of 5 MDC periods");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", x"0002", "Second write");
      await_completion(MDIO_VVCT, C_STA, 1 ms, "TIME_START2START with insert_delay");
      check_value(now - v_start, 3 * v_frame_time + 2 us + 5 * 400 ns, ERROR, "the delays add to the inter-BFM delay", C_SCOPE);

      log(ID_SEQUENCER, "TIME_FINISH2START", C_SCOPE);
      wait for 10 us;
      shared_mdio_vvc_config(C_STA).inter_bfm_delay.delay_type    := TIME_FINISH2START;
      shared_mdio_vvc_config(C_STA).inter_bfm_delay.delay_in_time := 10 us;
      v_start := now;
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", x"0001", "First write");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", x"0002", "Second write");
      await_completion(MDIO_VVCT, C_STA, 1 ms, "TIME_FINISH2START");
      check_value(now - v_start, 2 * v_frame_time + 10 us, ERROR, "the second write starts 10 us after the end of the first", C_SCOPE);

      log(ID_SEQUENCER, "TIME_START2START shorter than a frame: one TB_WARNING per write", C_SCOPE);
      wait for 10 us;
      increment_expected_alerts(TB_WARNING, 2);
      shared_mdio_vvc_config(C_STA).inter_bfm_delay.inter_bfm_delay_violation_severity := TB_WARNING;
      shared_mdio_vvc_config(C_STA).inter_bfm_delay.delay_type                         := TIME_START2START;
      shared_mdio_vvc_config(C_STA).inter_bfm_delay.delay_in_time                      := 1 us;
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", x"0001", "First write");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", x"0002", "Second write");
      await_completion(MDIO_VVCT, C_STA, 1 ms, "TIME_START2START violation");

      log(ID_SEQUENCER, "A *_reg command is one BFM access: one TB_WARNING, no delay between its two frames", C_SCOPE);
      -- longer than one frame, shorter than the two frames of write_reg
      increment_expected_alerts(TB_WARNING, 1);
      shared_mdio_vvc_config(C_STA).inter_bfm_delay.delay_in_time := v_frame_time + 1 us;
      wait for v_frame_time + 1 us;
      v_start := now;
      mdio_sta_c45_write_reg(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", x"0001", x"0001", "write_reg");
      await_completion(MDIO_VVCT, C_STA, 1 ms, "write_reg");
      check_value(now - v_start, 2 * v_frame_time, ERROR, "write_reg sends its two frames back to back", C_SCOPE);

      shared_mdio_vvc_config(C_STA).inter_bfm_delay := C_MDIO_INTER_BFM_DELAY_DEFAULT;

      log(ID_LOG_HDR, "insert_delay() with a number of MDC periods", C_SCOPE);
      ------------------------------------------------------------
      -- STA mode: n * bfm_config.sta.mdc_period
      v_start := now;
      insert_delay(MDIO_VVCT, C_STA, 10, "STA waits 10 MDC periods");
      await_completion(MDIO_VVCT, C_STA, 1 ms, "STA insert_delay");
      check_value(now - v_start, 10 * 400 ns, ERROR, "STA: 10 MDC periods of 400 ns", C_SCOPE);

      -- PHY mode: counts the rising MDC edges of the STA. The STA starts its write 10 us later, the first edge comes
      -- one low phase (200 ns) after that, the 64th (last data bit, the IDLE bit follows) 63 periods later
      v_start := now;
      insert_delay(MDIO_VVCT, C_STA, 10 us, "STA starts the frame later");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00101", x"BEEF", "STA writes to a PHY that does not exist");
      insert_delay(MDIO_VVCT, C_PHY_1, 64, "PHY waits for the 64 MDC edges of one frame");
      await_completion(MDIO_VVCT, C_PHY_1, 1 ms, "PHY insert_delay");
      check_value(now - v_start, 10 us + 200 ns + 63 * 400 ns, ERROR, "PHY: delay ends at the 64th rising MDC edge", C_SCOPE);
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "frame done");

      -- PHY mode without MDC activity: the delay only ends by terminate
      insert_delay(MDIO_VVCT, C_PHY_1, 1, "PHY waits for an MDC edge that does not come");
      wait for 10 us;
      terminate_current_command(MDIO_VVCT, C_PHY_1);
      await_completion(MDIO_VVCT, C_PHY_1, 1 us, "terminated PHY insert_delay");

      -- STA mode with an mdc_period that is not positive: TB_ERROR, no delay
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      shared_mdio_vvc_config(C_STA).bfm_config.sta.mdc_period := 0 ns;
      v_start := now;
      insert_delay(MDIO_VVCT, C_STA, 10, "STA insert_delay with mdc_period 0 ns");
      await_completion(MDIO_VVCT, C_STA, 1 us, "STA insert_delay without mdc_period");
      check_value(now - v_start, 0 ns, ERROR, "no delay without a valid mdc_period", C_SCOPE);
      shared_mdio_vvc_config(C_STA).bfm_config.sta.mdc_period := 400 ns;

    --============================================================================================================================
    elsif GC_TESTCASE = "vvc_broadcast_test" then
      --============================================================================================================================
      -- An MDIO command queued with ALL_INSTANCES reaches the STA and the PHY instances, one role always rejects it.
      -- Broadcast is therefore used for the common methods, and once for an STA method to show the rejection.
      enable_log_msg(VVC_BROADCAST, ALL_MESSAGES);
      measure_frame_time(v_frame_time);

      -- await_completion(VVC_BROADCAST) is the old method without the VVC activity register, no current VVC supports
      -- it. await_completion(MDIO_VVCT, ALL_INSTANCES) is used instead.
      log(ID_LOG_HDR, "await_completion() of all instances", C_SCOPE);
      ------------------------------------------------------------
      insert_delay(MDIO_VVCT, C_PHY_1, 1 us, "Delay of 1 us");
      insert_delay(MDIO_VVCT, C_PHY_2, 2 us, "Delay of 2 us");
      insert_delay(MDIO_VVCT, C_PHY_3, 3 us, "Delay of 3 us");
      insert_delay(MDIO_VVCT, C_STA, 4 us, "Delay of 4 us");
      v_start := now;
      await_completion(MDIO_VVCT, ALL_INSTANCES, 10 us, "Await all VVCs");
      check_value(now - v_start, 4 us, ERROR, "await_completion(VVC_BROADCAST) waits for the slowest VVC", C_SCOPE);

      log(ID_LOG_HDR, "insert_delay(VVC_BROADCAST) with a time", C_SCOPE);
      ------------------------------------------------------------
      v_start := now;
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", x"0001", "First write");
      for i in 1 to 4 loop
        insert_delay(VVC_BROADCAST, 1 us, "Delay of 1 us in all VVCs");
      end loop;
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", x"0002", "Second write");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "Await all VVCs");
      check_value(now - v_start, 2 * v_frame_time + 4 us, ERROR, "the STA waited 4 us between the writes", C_SCOPE);

      -- insert_delay(VVC_BROADCAST, <number of cycles>) is not tested: UVVM transmits it as FLUSH_COMMAND_QUEUE
      -- (ti_vvc_framework_support_pkg). The MDC period variant is tested per instance in
      -- read_of_executor_status_and_inter_bfm_delay.

      log(ID_LOG_HDR, "flush_command_queue(VVC_BROADCAST)", C_SCOPE);
      ------------------------------------------------------------
      -- only the commands that already run are completed (the STA write takes longer than the PHY delays)
      v_start := now;
      for i in 1 to 3 loop
        mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", x"0001", "Write " & to_string(i));
        for phy in C_PHY_1 to C_PHY_3 loop
          insert_delay(MDIO_VVCT, phy, 5 us, "Delay " & to_string(i));
        end loop;
      end loop;
      flush_command_queue(VVC_BROADCAST, "Flush all VVCs");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "Await all VVCs");
      check_value(now - v_start, v_frame_time, ERROR, "only the first write was sent", C_SCOPE);

      log(ID_LOG_HDR, "terminate_current_command(VVC_BROADCAST)", C_SCOPE);
      ------------------------------------------------------------
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", x"0001", "Write that gets terminated");
      for phy in C_PHY_1 to C_PHY_3 loop
        mdio_phy_c22_expect_write(MDIO_VVCT, phy, "00001", x"0001", "PHY waits for a frame that does not come");
      end loop;
      wait for 5 us;
      terminate_current_command(VVC_BROADCAST, "Terminate all VVCs");
      v_start := now;
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 us, "Await all VVCs");
      check_value(now - v_start <= 200 ns, ERROR, "every VVC stopped within half an MDC period", C_SCOPE);

      log(ID_LOG_HDR, "await_completion(ANY_OF, list)", C_SCOPE);
      ------------------------------------------------------------
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", x"0001", "Write");
      insert_delay(MDIO_VVCT, C_PHY_2, 5 us, "Delay of 5 us");
      v_start := now;
      add_to_vvc_list(MDIO_VVCT, C_STA, v_vvc_list);
      add_to_vvc_list(MDIO_VVCT, C_PHY_2, v_vvc_list);
      await_completion(ANY_OF, v_vvc_list, 1 ms);
      check_value(now - v_start, 5 us, ERROR, "ANY_OF returns when PHY 2 is done", C_SCOPE);
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "Await the write");

      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", x"0001", "Write");
      v_start := now;
      add_to_vvc_list(MDIO_VVCT, C_STA, v_vvc_list);
      add_to_vvc_list(MDIO_VVCT, C_PHY_3, v_vvc_list);
      await_completion(ANY_OF, v_vvc_list, 1 ms);
      check_value(now - v_start, 0 ns, ERROR, "ANY_OF returns at once, PHY 3 is idle", C_SCOPE);
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "Await the write");

      log(ID_LOG_HDR, "STA method to ALL_INSTANCES: the three PHY instances reject it (one TB_ERROR each)", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(TB_ERROR, 3);
      v_start := now;
      mdio_sta_c22_write(MDIO_VVCT, ALL_INSTANCES, C_MISSING_PHY_ADDR, "00001", x"0001", "Write to all instances");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "Await the write");
      check_value(now - v_start, v_frame_time, ERROR, "the STA sent the write", C_SCOPE);

    --============================================================================================================================
    elsif GC_TESTCASE = "terminate_and_flush" then
      --============================================================================================================================
      log(ID_LOG_HDR, "Terminate an STA command while it is running", C_SCOPE);
      ------------------------------------------------------------
      -- A terminated call ends without an alert, nothing is expected here. The read starts with a 200 ns low phase, then
      -- a rising edge every 400 ns: 5 us is exactly a rising edge, 5 us + 5 ns lies within the hold time, 5.1 us in the
      -- high phase and 5.3 us in the low phase. The bus timing checker of the PHY VVCs reports a truncated MDC pulse or
      -- MDIO released within the hold time, also at the start of the write that directly follows. After these four
      -- points the read is terminated at random times before its turnaround (bit 47 starts at 18.2 us), the missing
      -- PHY would be alerted there.
      for i in 0 to 9 loop
        mdio_sta_c22_read(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", "STA read that gets terminated");
        v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_STA);
        case i is
          when 0      => wait for 5 us;
          when 1      => wait for 5 us + 5 ns;
          when 2      => wait for 5.1 us;
          when 3      => wait for 5.3 us;
          when others => wait for random(300 ns, 17 us);
        end case;
        terminate_current_command(MDIO_VVCT, C_STA);
        v_start := now;
        await_completion(MDIO_VVCT, C_STA, 1 ms, "terminated read");
        check_value(now - v_start <= 200 ns, ERROR, "a terminate takes effect within half an MDC period", C_SCOPE);
        fetch_result(MDIO_VVCT, C_STA, v_cmd_idx, v_data, "Fetch the terminated read");
        check_value(is_x(v_data), ERROR, "a terminated read leaves the data undefined", C_SCOPE);

        mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY expects a write");
        mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"BEEF", "STA writes directly after the terminated read");
        await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "write after terminate");
      end loop;

      log(ID_LOG_HDR, "Terminate a PHY command that waits for its frame", C_SCOPE);
      ------------------------------------------------------------
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY waits for a frame that does not come");
      wait for 10 us;
      terminate_current_command(MDIO_VVCT, C_PHY_1);
      v_start := now;
      await_completion(MDIO_VVCT, C_PHY_1, 1 us, "terminated PHY command");
      check_value(now - v_start, 0 ns, ERROR, "a waiting PHY command ends at once", C_SCOPE);
      -- the PHY takes the next frame again
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY expects a write");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"BEEF", "STA writes");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "write after the terminated PHY command");

      log(ID_LOG_HDR, "flush_command_queue() of one instance", C_SCOPE);
      ------------------------------------------------------------
      measure_frame_time(v_frame_time);
      v_start := now;
      for i in 1 to 3 loop
        mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", x"0001", "Write " & to_string(i));
      end loop;
      insert_delay(MDIO_VVCT, C_PHY_1, 1 us, "PHY 1 is not flushed");
      insert_delay(MDIO_VVCT, C_PHY_1, 1 us, "PHY 1 is not flushed");
      flush_command_queue(MDIO_VVCT, C_STA, "Flush the STA");
      await_completion(MDIO_VVCT, C_PHY_1, 1 ms, "PHY 1");
      check_value(now - v_start, 2 us, ERROR, "PHY 1 executed both delays", C_SCOPE);
      await_completion(MDIO_VVCT, C_STA, 1 ms, "STA");
      check_value(now - v_start, v_frame_time, ERROR, "the STA sent only the first write", C_SCOPE);

      log(ID_LOG_HDR, "terminate_all_commands()", C_SCOPE);
      ------------------------------------------------------------
      -- one instance: the running command is terminated and the queue flushed
      for i in 1 to 3 loop
        mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", x"0001", "Write " & to_string(i));
      end loop;
      wait for 5 us;
      terminate_all_commands(MDIO_VVCT, C_STA, "Terminate the STA");
      v_start := now;
      await_completion(MDIO_VVCT, C_STA, 1 ms, "STA");
      check_value(now - v_start <= 200 ns, ERROR, "the STA stopped within half an MDC period", C_SCOPE);

      -- broadcast: every VVC
      for i in 1 to 3 loop
        mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", x"0001", "Write " & to_string(i));
        for phy in C_PHY_1 to C_PHY_3 loop
          mdio_phy_c22_receive_write(MDIO_VVCT, phy, "00001", "PHY waits for a frame that does not come");
        end loop;
      end loop;
      wait for 5 us;
      terminate_all_commands(VVC_BROADCAST, "Terminate all VVCs");
      v_start := now;
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "Await all VVCs");
      check_value(now - v_start <= 200 ns, ERROR, "every VVC stopped within half an MDC period", C_SCOPE);

      log(ID_LOG_HDR, "A terminated read with TO_SB leaves the expected entry pending", C_SCOPE);
      ------------------------------------------------------------
      mdio_vvc_sb.add_expected(C_STA, pad_mdio_sb(x"1234"));
      mdio_sta_c22_read(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00001", TO_SB, "STA read to the scoreboard that gets terminated");
      wait for 5 us;
      terminate_current_command(MDIO_VVCT, C_STA);
      await_completion(MDIO_VVCT, C_STA, 1 ms, "terminated read");
      check_value(mdio_vvc_sb.get_pending_count(C_STA), 1, ERROR, "the expected entry is still pending", C_SCOPE);
      check_value(mdio_vvc_sb.get_mismatch_count(C_STA), 0, ERROR, "and nothing was compared", C_SCOPE);
      mdio_vvc_sb.flush(C_STA, "Remove the pending entry");

    --============================================================================================================================
    elsif GC_TESTCASE = "test_unwanted_activity" then
      --============================================================================================================================
      -- STA mode: any MDIO change while the STA VVC is inactive. PHY mode: a frame to the PHY's address that no PHY
      -- command was waiting for, frames to other addresses are normal bus traffic.
      for i in 0 to 2 loop
        -- Test different alert severity configurations
        if i = 0 then
          v_alert_level := C_MDIO_VVC_CONFIG_DEFAULT.unwanted_activity_severity;
        elsif i = 1 then
          v_alert_level := FAILURE;
        else
          v_alert_level := NO_ALERT;
        end if;
        log(ID_LOG_HDR, "Unwanted activity with unwanted_activity_severity " & to_upper(to_string(v_alert_level)), C_SCOPE);
        shared_mdio_vvc_config(C_STA).unwanted_activity_severity   := v_alert_level;
        shared_mdio_vvc_config(C_PHY_1).unwanted_activity_severity := v_alert_level;

        -- The last frame is a write: after a read the bus timing checker of the STA would also report the forced
        -- MDIO changes, as a PHY that releases MDIO too late.
        log(ID_SEQUENCER, "Normal frames: the PHY drives MDIO while the STA is active", C_SCOPE);
        mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00110", x"0000", "PHY replies to a read");
        mdio_sta_c22_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00110", x"0000", "STA checks");
        mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY expects a write");
        mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"BEEF", "STA writes");
        await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "normal frames");

        -- Test with and without a time gap between await_completion and the unwanted activity
        if i = 0 then
          wait for 1 us;
        end if;

        log(ID_SEQUENCER, "Unwanted activity on MDIO", C_SCOPE);
        toggle_vvc_if(v_alert_level);

        log(ID_SEQUENCER, "PHY mode: frames to the address of an idle PHY VVC", C_SCOPE);
        if v_alert_level /= NO_ALERT then
          increment_expected_alerts_and_stop_limit(v_alert_level, 3);
          v_num := get_alert_counter(v_alert_level);
        end if;
        mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"BEEF", "STA writes to the idle PHY 1");
        mdio_sta_c45_address(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"8000", "STA sends an address frame to the idle PHY 1");
        mdio_sta_c22_write(MDIO_VVCT, C_STA, C_MISSING_PHY_ADDR, "00101", x"BEEF", "STA writes to another PHY: no alert");
        await_completion(MDIO_VVCT, C_STA, 1 ms, "frames to an idle PHY");
        if v_alert_level /= NO_ALERT then
          check_value(get_alert_counter(v_alert_level), v_num + 2, ERROR, "one alert per frame to the idle PHY 1", C_SCOPE);
        end if;

        log(ID_SEQUENCER, "PHY mode: a PHY command queued after the preamble has started misses that frame", C_SCOPE);
        mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"1111", "STA writes, the PHY command comes too late");
        mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"2222", "STA writes again");
        wait for 5 us;
        mdio_phy_c22_receive_write(MDIO_VVCT, C_PHY_1, "00101", "PHY receives a write, queued within the preamble");
        v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, C_PHY_1);
        await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "PHY command within the preamble");
        fetch_result(MDIO_VVCT, C_PHY_1, v_cmd_idx, v_data, "Fetch the received write");
        check_value(v_data, x"2222", ERROR, "the PHY received the second frame", C_SCOPE);
        if v_alert_level /= NO_ALERT then
          check_value(get_alert_counter(v_alert_level), v_num + 3, ERROR, "one alert for the missed frame", C_SCOPE);
        end if;
      end loop;

    --============================================================================================================================
    elsif GC_TESTCASE = "transaction_info" then
      --============================================================================================================================
      -- Every operation of the STA and of the PHY shows up in shared_mdio_vvc_transaction_info: IN_PROGRESS when it
      -- starts, COMPLETED with its fields when it ends, reset when the instance is idle. Reads and receives show the
      -- data that was read / received. A PHY command has no phy_addr (its own address is in the config).
      log(ID_LOG_HDR, "Clause 22", C_SCOPE);
      ------------------------------------------------------------
      mdio_phy_c22_expect_write(MDIO_VVCT, C_PHY_1, "00101", x"BEEF", "PHY expects a write");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"BEEF", "STA writes");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "c22 write");
      check_transaction(true, STA_C22_WRITE, x"BEEF", C_PHY_1_ADDR, "00000", x"0005");
      check_transaction(false, PHY_C22_EXPECT_WRITE, x"BEEF", "00000", "00000", x"0005");

      mdio_phy_c22_receive_write(MDIO_VVCT, C_PHY_1, "00101", "PHY receives a write");
      mdio_sta_c22_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00101", x"A5A5", "STA writes");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "c22 receive");
      check_transaction(false, PHY_C22_RECEIVE_WRITE, x"A5A5", "00000", "00000", x"0005");

      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00110", x"1234", "PHY replies to a read");
      mdio_sta_c22_read(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00110", "STA reads");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "c22 read");
      check_transaction(true, STA_C22_READ, x"1234", C_PHY_1_ADDR, "00000", x"0006");
      check_transaction(false, PHY_C22_REPLY_READ, x"1234", "00000", "00000", x"0006");

      mdio_phy_c22_reply_read(MDIO_VVCT, C_PHY_1, "00111", x"00FF", "PHY replies to a read");
      mdio_sta_c22_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00111", x"00FF", "STA checks");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "c22 check");
      check_transaction(true, STA_C22_CHECK, x"00FF", C_PHY_1_ADDR, "00000", x"0007");

      log(ID_LOG_HDR, "Clause 45", C_SCOPE);
      ------------------------------------------------------------
      mdio_phy_c45_expect_address(MDIO_VVCT, C_PHY_1, "00011", x"8000", "PHY expects an address frame");
      mdio_sta_c45_address(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"8000", "STA sends an address frame");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "c45 address");
      check_transaction(true, STA_C45_ADDRESS, x"0000", C_PHY_1_ADDR, "00011", x"8000");
      check_transaction(false, PHY_C45_EXPECT_ADDRESS, x"0000", "00000", "00011", x"8000");

      mdio_phy_c45_receive_address(MDIO_VVCT, C_PHY_1, "00011", "PHY receives an address frame");
      mdio_sta_c45_address(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"8001", "STA sends an address frame");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "c45 receive address");
      check_transaction(false, PHY_C45_RECEIVE_ADDRESS, x"0000", "00000", "00011", x"8001");

      mdio_phy_c45_expect_write(MDIO_VVCT, C_PHY_1, "00011", x"CAFE", "PHY expects a write");
      mdio_sta_c45_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"CAFE", "STA writes");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "c45 write");
      check_transaction(true, STA_C45_WRITE, x"CAFE", C_PHY_1_ADDR, "00011", x"0000");
      check_transaction(false, PHY_C45_EXPECT_WRITE, x"CAFE", "00000", "00011", x"0000");

      mdio_phy_c45_receive_write(MDIO_VVCT, C_PHY_1, "00011", "PHY receives a write");
      mdio_sta_c45_write(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"5A5A", "STA writes");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "c45 receive write");
      check_transaction(false, PHY_C45_RECEIVE_WRITE, x"5A5A", "00000", "00011", x"0000");

      mdio_phy_c45_reply_read(MDIO_VVCT, C_PHY_1, "00011", x"7777", "PHY replies to a read");
      mdio_sta_c45_read(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", "STA reads");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "c45 read");
      check_transaction(true, STA_C45_READ, x"7777", C_PHY_1_ADDR, "00011", x"0000");
      check_transaction(false, PHY_C45_REPLY_READ, x"7777", "00000", "00011", x"0000");

      mdio_phy_c45_reply_post_read_increment(MDIO_VVCT, C_PHY_1, "00011", x"8888", "PHY replies to a post-read-increment");
      mdio_sta_c45_post_read_increment(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", "STA reads with post-read-increment");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "c45 post-read-increment");
      check_transaction(true, STA_C45_POST_READ_INCREMENT, x"8888", C_PHY_1_ADDR, "00011", x"0000");
      check_transaction(false, PHY_C45_REPLY_POST_READ_INCREMENT, x"8888", "00000", "00011", x"0000");

      mdio_phy_c45_reply_read(MDIO_VVCT, C_PHY_1, "00011", x"7777", "PHY replies to a read");
      mdio_sta_c45_check(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"7777", "STA checks");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "c45 check");
      check_transaction(true, STA_C45_CHECK, x"7777", C_PHY_1_ADDR, "00011", x"0000");

      mdio_phy_c45_reply_post_read_increment(MDIO_VVCT, C_PHY_1, "00011", x"8888", "PHY replies to a post-read-increment");
      mdio_sta_c45_check_post_read_increment(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"8888", "STA checks with post-read-increment");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "c45 check post-read-increment");
      check_transaction(true, STA_C45_CHECK_POST_READ_INCREMENT, x"8888", C_PHY_1_ADDR, "00011", x"0000");

      log(ID_LOG_HDR, "Clause 45 register access: one transaction for both frames", C_SCOPE);
      ------------------------------------------------------------
      mdio_phy_c45_expect_address(MDIO_VVCT, C_PHY_1, "00011", x"1234", "PHY expects the address frame");
      mdio_phy_c45_expect_write(MDIO_VVCT, C_PHY_1, "00011", x"CAFE", "PHY expects the write frame");
      mdio_sta_c45_write_reg(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"1234", x"CAFE", "STA writes a register");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "c45 write_reg");
      check_transaction(true, STA_C45_WRITE_REG, x"CAFE", C_PHY_1_ADDR, "00011", x"1234");

      mdio_phy_c45_expect_address(MDIO_VVCT, C_PHY_1, "00011", x"4321", "PHY expects the address frame");
      mdio_phy_c45_reply_read(MDIO_VVCT, C_PHY_1, "00011", x"ABCD", "PHY replies to a read");
      mdio_sta_c45_read_reg(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"4321", "STA reads a register");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "c45 read_reg");
      check_transaction(true, STA_C45_READ_REG, x"ABCD", C_PHY_1_ADDR, "00011", x"4321");

      mdio_phy_c45_expect_address(MDIO_VVCT, C_PHY_1, "00011", x"4321", "PHY expects the address frame");
      mdio_phy_c45_reply_read(MDIO_VVCT, C_PHY_1, "00011", x"ABCD", "PHY replies to a read");
      mdio_sta_c45_check_reg(MDIO_VVCT, C_STA, C_PHY_1_ADDR, "00011", x"4321", x"ABCD", "STA checks a register");
      await_completion(MDIO_VVCT, ALL_INSTANCES, 1 ms, "c45 check_reg");
      check_transaction(true, STA_C45_CHECK_REG, x"ABCD", C_PHY_1_ADDR, "00011", x"4321");

    --============================================================================================================================
    else
      alert(TB_ERROR, "Unsupported test case: " & GC_TESTCASE, C_SCOPE);
    end if;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    await_uvvm_completion(1000 ns, print_alert_counters => REPORT_ALERT_COUNTERS_FINAL, scope => C_SCOPE);
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely
  end process p_main;

end architecture func;
