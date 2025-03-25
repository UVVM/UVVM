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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_axi;
context bitvis_vip_axi.vvc_context;

library bitvis_vip_scoreboard;
use bitvis_vip_scoreboard.generic_sb_support_pkg.all;

--hdlregression:tb
-- Test case entity
entity axi_vvc_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity axi_vvc_tb;

-- Test case architecture
architecture sim of axi_vvc_tb is

  constant C_SCOPE        : string  := C_TB_SCOPE_DEFAULT;
  constant C_ADDR_WIDTH_1 : natural := 32;
  constant C_DATA_WIDTH_1 : natural := 32;
  constant C_ID_WIDTH_1   : natural := 8;
  constant C_USER_WIDTH_1 : natural := 8;
  constant C_ADDR_WIDTH_2 : natural := 32;
  constant C_DATA_WIDTH_2 : natural := 32;
  constant C_ID_WIDTH_2   : natural := 0;
  constant C_USER_WIDTH_2 : natural := 0;

  signal clk       : std_logic := '0';
  signal areset    : std_logic := '0';
  signal clock_ena : boolean   := false;

begin

  -----------------------------
  -- Instantiate Test harness
  -----------------------------
  i_test_harness : entity work.axi_th
    generic map(
      GC_ADDR_WIDTH_1 => C_ADDR_WIDTH_1,
      GC_DATA_WIDTH_1 => C_DATA_WIDTH_1,
      GC_ID_WIDTH_1   => C_ID_WIDTH_1,
      GC_USER_WIDTH_1 => C_USER_WIDTH_1,
      GC_ADDR_WIDTH_2 => C_ADDR_WIDTH_2,
      GC_DATA_WIDTH_2 => C_DATA_WIDTH_2,
      GC_ID_WIDTH_2   => C_ID_WIDTH_2,
      GC_USER_WIDTH_2 => C_USER_WIDTH_2
    );

  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    variable v_cmd_idx           : integer;
    variable v_result            : t_vvc_result;
    variable v_expected_result   : t_vvc_result                       := C_EMPTY_VVC_RESULT;
    variable v_write_data        : t_slv_array(0 to 3)(31 downto 0)   := (x"12345678", x"33333333", x"55555555", x"AAAAAAAA");
    variable v_max_write_data    : t_slv_array(0 to 255)(31 downto 0) := (others => (others => '0'));
    variable v_write_data_narrow : t_slv_array(0 to 1)(7 downto 0)    := (x"12", x"34");
    variable v_wstrb_narrow      : t_slv_array(0 to 1)(0 downto 0)    := ("1", "1");
    variable v_wuser_narrow      : t_slv_array(0 to 1)(0 downto 0)    := ("1", "1");
    variable v_ruser_narrow      : t_slv_array(0 to 1)(0 downto 0)    := ("0", "0");
    variable v_write_data_wide   : t_slv_array(0 to 1)(39 downto 0)   := (x"0087654321", x"009ABCDEF0");
    variable v_wstrb_wide        : t_slv_array(0 to 1)(7 downto 0)    := (x"0F", x"0F");
    variable v_wuser_wide        : t_slv_array(0 to 1)(15 downto 0)   := (x"0001", x"0001");
    variable v_ruser_wide        : t_slv_array(0 to 1)(15 downto 0)   := (x"0000", x"0000");
    variable v_timestamp         : time;
    variable v_measured_time     : time;
    variable v_alert_level       : t_alert_level;

    -- DUT ports towards VVC interface
    constant C_NUM_VVC_SIGNALS : natural := 10;
    alias dut_bid    is << signal i_test_harness.axi_if_1_bid    : std_logic_vector >>;
    alias dut_bresp  is << signal i_test_harness.axi_if_1_bresp  : std_logic_vector >>;
    alias dut_buser  is << signal i_test_harness.axi_if_1_buser  : std_logic_vector >>;
    alias dut_bvalid is << signal i_test_harness.axi_if_1_bvalid : std_logic >>;
    alias dut_rid    is << signal i_test_harness.axi_if_1_rid    : std_logic_vector >>;
    alias dut_rdata  is << signal i_test_harness.axi_if_1_rdata  : std_logic_vector >>;
    alias dut_rresp  is << signal i_test_harness.axi_if_1_rresp  : std_logic_vector >>;
    alias dut_rlast  is << signal i_test_harness.axi_if_1_rlast  : std_logic >>;
    alias dut_ruser  is << signal i_test_harness.axi_if_1_ruser  : std_logic_vector >>;
    alias dut_rvalid is << signal i_test_harness.axi_if_1_rvalid : std_logic >>;

    -- Toggles all the signals in the VVC interface and checks that the expected alerts are generated
    procedure toggle_vvc_if (
      constant alert_level : in t_alert_level
    ) is
      variable v_num_expected_alerts : natural;
      variable v_rand                : t_rand;
    begin
      -- Number of total expected alerts: (number of signals tested individually + number of signals tested together) x 1 toggle
      if alert_level /= NO_ALERT then
        increment_expected_alerts_and_stop_limit(alert_level, (C_NUM_VVC_SIGNALS + C_NUM_VVC_SIGNALS) * 2);
      end if;
      for i in 0 to C_NUM_VVC_SIGNALS loop
        -- Force new value
        v_num_expected_alerts := get_alert_counter(alert_level);
        case i is
          when 0 => dut_bid     <= force not dut_bid;
                    dut_bresp   <= force not dut_bresp;
                    dut_buser   <= force not dut_buser;
                    dut_bvalid  <= force not dut_bvalid;
                    dut_rid     <= force not dut_rid;
                    dut_rdata   <= force not dut_rdata;
                    dut_rresp   <= force not dut_rresp;
                    dut_rlast   <= force not dut_rlast;
                    dut_ruser   <= force not dut_ruser;
                    dut_rvalid  <= force not dut_rvalid;
          when 1 => dut_bid     <= force not dut_bid;
          when 2 => dut_bresp   <= force not dut_bresp;
          when 3 => dut_buser   <= force not dut_buser;
          when 4 => dut_bvalid  <= force not dut_bvalid;
          when 5 => dut_rid     <= force not dut_rid;
          when 6 => dut_rdata   <= force not dut_rdata;
          when 7 => dut_rresp   <= force not dut_rresp;
          when 8 => dut_rlast   <= force not dut_rlast;
          when 9 => dut_ruser   <= force not dut_ruser;
          when 10 => dut_rvalid <= force not dut_rvalid;
        end case;
        wait for v_rand.rand(ONLY, (C_LOG_TIME_BASE, C_LOG_TIME_BASE * 5, C_LOG_TIME_BASE * 10)); -- Hold the value a random time
        v_num_expected_alerts := 0 when alert_level = NO_ALERT else
                                 v_num_expected_alerts + C_NUM_VVC_SIGNALS when i = 0 else
                                 v_num_expected_alerts + 1;
        check_value(get_alert_counter(alert_level), v_num_expected_alerts, TB_NOTE, "Unwanted activity alert was expected", C_SCOPE, ID_NEVER);
        -- Set back original value
        v_num_expected_alerts := get_alert_counter(alert_level);
        case i is
          when 0 => dut_bid     <= release;
                    dut_bresp   <= release;
                    dut_buser   <= release;
                    dut_bvalid  <= release;
                    dut_rid     <= release;
                    dut_rdata   <= release;
                    dut_rresp   <= release;
                    dut_rlast   <= release;
                    dut_ruser   <= release;
                    dut_rvalid  <= release;
          when 1 => dut_bid     <= release;
          when 2 => dut_bresp   <= release;
          when 3 => dut_buser   <= release;
          when 4 => dut_bvalid  <= release;
          when 5 => dut_rid     <= release;
          when 6 => dut_rdata   <= release;
          when 7 => dut_rresp   <= release;
          when 8 => dut_rlast   <= release;
          when 9 => dut_ruser   <= release;
          when 10 => dut_rvalid <= release;
        end case;
        wait for 0 ns; -- Wait two delta cycles so that the alert is triggered
        wait for 0 ns;
        wait for 0 ns; -- Wait an extra delta cycle so that the value is propagated from the non-record to the record signals
        v_num_expected_alerts := 0 when alert_level = NO_ALERT else
                                 v_num_expected_alerts + C_NUM_VVC_SIGNALS when i = 0 else
                                 v_num_expected_alerts + 1;
        wait for 0 ns; -- Wait another cycle to allow signals to propagate before checking them - Needed for Riviera Pro
        check_value(get_alert_counter(alert_level), v_num_expected_alerts, TB_NOTE, "Unwanted activity alert was expected", C_SCOPE, ID_NEVER);
      end loop;
    end procedure;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    await_uvvm_initialization(VOID);

    disable_log_msg(ID_POS_ACK);
    disable_log_msg(ID_UVVM_SEND_CMD);
    disable_log_msg(ID_UVVM_CMD_ACK);
    disable_log_msg(ID_UVVM_CMD_RESULT);
    disable_log_msg(ID_AWAIT_COMPLETION_WAIT);
    disable_log_msg(ID_AWAIT_COMPLETION_END);
    disable_log_msg(AXI_VVCT, 1, ID_POS_ACK);
    disable_log_msg(AXI_VVCT, 1, ID_CMD_INTERPRETER);
    disable_log_msg(AXI_VVCT, 1, ID_CMD_INTERPRETER_WAIT);
    disable_log_msg(AXI_VVCT, 1, ID_CMD_EXECUTOR_WAIT);
    disable_log_msg(AXI_VVCT, 2, ID_POS_ACK);
    disable_log_msg(AXI_VVCT, 2, ID_CMD_INTERPRETER);
    disable_log_msg(AXI_VVCT, 2, ID_CMD_INTERPRETER_WAIT);
    disable_log_msg(AXI_VVCT, 2, ID_CMD_EXECUTOR_WAIT);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    wait for 40 ns;                     -- Waiting until reset is done

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing write/read/check procedures");
    ------------------------------------------------------------------------------------------------------------------------------
    axi_write(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      awaddr           => x"00000000",
      awlen            => x"03",
      awsize           => 4,
      wdata            => v_write_data,
      msg              => "Testing AXI write"
    );
    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");
    axi_check(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      araddr           => x"00000000",
      arlen            => x"03",
      arsize           => 4,
      rdata_exp        => t_slv_array'(x"12345678", x"33333333", x"55555555", x"AAAAAAAA"),
      msg              => "Testing AXI check"
    );
    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");
    axi_read(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      araddr           => x"00000000",
      arlen            => x"03",
      arsize           => 4,
      data_routing     => TO_BUFFER,
      msg              => "Testing AXI read"
    );
    v_cmd_idx := get_last_received_cmd_idx(AXI_VVCT, 1); -- Retrieve the command index
    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");
    fetch_result(AXI_VVCT, 1, v_cmd_idx, v_result, "Fetching read result");
    check_value(v_result.rid, x"00", "Checking RID", C_SCOPE);
    for i in 0 to 3 loop
      check_value(v_result.rdata(i), v_write_data(i), "Checking RDATA, index " & to_string(i), C_SCOPE);
      check_value(v_result.ruser(i), x"00", "Checking RUSER, index " & to_string(i), C_SCOPE);
    end loop;

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing scoreboard");
    ------------------------------------------------------------------------------------------------------------------------------
    v_expected_result.len                   := 1;
    v_expected_result.rid(7 downto 0)       := x"12";
    v_expected_result.rdata(0)(31 downto 0) := x"33333333";
    v_expected_result.rdata(1)(31 downto 0) := x"55555555";
    v_expected_result.ruser(0)(7 downto 0)  := x"00";
    v_expected_result.ruser(1)(7 downto 0)  := x"00";
    AXI_VVC_SB.add_expected(1, v_expected_result);
    axi_read(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      arid             => x"12",
      araddr           => x"00000004",
      arlen            => x"01",
      arsize           => 4,
      data_routing     => TO_SB,
      msg              => "Testing AXI read"
    );
    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing out-of-order write responses");
    ------------------------------------------------------------------------------------------------------------------------------
    axi_write(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      awid             => x"00",
      awaddr           => x"00000010",
      awlen            => x"03",
      awsize           => 4,
      wdata            => v_write_data,
      msg              => "Testing AXI write"
    );
    axi_write(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      awid             => x"01",
      awaddr           => x"00000020",
      awlen            => x"03",
      awsize           => 4,
      wdata            => t_slv_array'(x"BBBBBBBB", x"CCCCCCCC", x"DDDDDDDD", x"EEEEEEEE"),
      msg              => "Testing AXI write"
    );
    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing read data response coming out-of-order");
    ------------------------------------------------------------------------------------------------------------------------------
    axi_write(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      awid             => x"00",
      awaddr           => x"00000030",
      awlen            => x"08",
      awsize           => 4,
      wdata            => t_slv_array'(x"77777777", x"88888888", x"99999999", x"AAAAAAAA", x"BBBBBBBB", x"CCCCCCCC", x"DDDDDDDD", x"EEEEEEEE", x"FFFFFFFF"),
      msg              => "Testing AXI write"
    );
    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");
    axi_check(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      arid             => x"01",
      araddr           => x"00000030",
      arlen            => x"02",
      arsize           => 4,
      rdata_exp        => t_slv_array'(x"77777777", x"88888888", x"99999999"),
      msg              => "Testing AXI check"
    );
    axi_check(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      arid             => x"02",
      araddr           => x"0000003C",
      arlen            => x"02",
      arsize           => 4,
      rdata_exp        => t_slv_array'(x"AAAAAAAA", x"BBBBBBBB", x"CCCCCCCC"),
      msg              => "Testing AXI check"
    );
    axi_check(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      arid             => x"03",
      araddr           => x"00000048",
      arlen            => x"02",
      arsize           => 4,
      rdata_exp        => t_slv_array'(x"DDDDDDDD", x"EEEEEEEE", x"FFFFFFFF"),
      msg              => "Testing AXI check"
    );
    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test fetch_result with cmd_idx lower than the last_cmd_idx_executed. Read data response comes out-of-order");
    ------------------------------------------------------------------------------------------------------------------------------
    axi_write(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      awid             => x"00",
      awaddr           => x"00000030",
      awlen            => x"08",
      awsize           => 4,
      wdata            => t_slv_array'(x"77777777", x"88888888", x"99999999", x"AAAAAAAA", x"BBBBBBBB", x"CCCCCCCC", x"DDDDDDDD", x"EEEEEEEE", x"FFFFFFFF"),
      msg              => "Testing AXI write"
    );
    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");
    axi_read(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      arid             => x"01",
      araddr           => x"00000030",
      arlen            => x"02",
      arsize           => 4,
      data_routing     => TO_BUFFER,
      msg              => "Testing AXI check"
    );
    v_cmd_idx := get_last_received_cmd_idx(AXI_VVCT, 1); -- Retrieve the command index for the first read request
    axi_read(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      arid             => x"02",
      araddr           => x"0000003C",
      arlen            => x"02",
      arsize           => 4,
      data_routing     => TO_BUFFER,
      msg              => "Testing AXI check"
    );
    axi_read(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      arid             => x"03",
      araddr           => x"00000048",
      arlen            => x"02",
      arsize           => 4,
      data_routing     => TO_BUFFER,
      msg              => "Testing AXI check"
    );

    await_completion(AXI_VVCT, 1, v_cmd_idx, 1 us, "Waiting for first command to finish");
    fetch_result(AXI_VVCT, 1, v_cmd_idx, v_result, "Fetching read result");
    check_value(v_result.rid, x"01", "Checking RID", C_SCOPE);

    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing minimum burst length");
    ------------------------------------------------------------------------------------------------------------------------------
    axi_write(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      awaddr           => x"00000060",
      awlen            => x"00",
      awsize           => 4,
      wdata            => v_write_data(0 to 0),
      msg              => "Writing with a minimum burst length"
    );
    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");
    -- Checking that only this word has been written
    axi_check(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      araddr           => x"00000060",
      arlen            => x"00",
      arsize           => 4,
      rdata_exp        => v_write_data(0 to 0),
      msg              => "Reading with a minumum burst length"
    );
    axi_check(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      araddr           => x"00000064",
      arlen            => x"00",
      arsize           => 4,
      rdata_exp        => t_slv_array'(x"00000000", x"00000000"),
      msg              => "Reading from the next address to see that it hasn't been written to"
    );
    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing maximum burst length");
    ------------------------------------------------------------------------------------------------------------------------------
    -- Filling the write data variable
    for i in 0 to 255 loop
      v_max_write_data(i) := random(32);
    end loop;
    axi_write(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      awaddr           => x"00000070",
      awlen            => x"FF",
      awsize           => 4,
      wdata            => v_max_write_data,
      msg              => "Writing with a maximum burst length"
    );
    await_completion(AXI_VVCT, 1, 10 us, "Waiting for commands to finish");
    -- Checking that the data has been written correctly
    axi_read(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      araddr           => x"00000070",
      arlen            => x"FF",
      arsize           => 4,
      data_routing     => TO_BUFFER,
      msg              => "Testing AXI read"
    );
    v_cmd_idx := get_last_received_cmd_idx(AXI_VVCT, 1); -- Retrieve the command index
    await_completion(AXI_VVCT, 1, 10 us, "Waiting for commands to finish");
    fetch_result(AXI_VVCT, 1, v_cmd_idx, v_result, "Fetching read result");
    for i in 0 to 255 loop
      check_value(v_result.rdata(i), v_max_write_data(i), "Checking RDATA, index " & to_string(i), C_SCOPE);
      -- check_value(v_result.ruser(i), x"00", "Checking RUSER, index " & to_string(i), C_SCOPE);
    end loop;

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing that unconstrained command parameters are normalized correctly");
    ------------------------------------------------------------------------------------------------------------------------------
    -- Testing smaller parameter widths on all unconstrained inputs
    axi_write(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      awid             => "1",
      awaddr           => x"500",
      awlen            => x"01",
      awsize           => 4,
      awuser           => "1",
      wdata            => v_write_data_narrow,
      wstrb            => v_wstrb_narrow,
      wuser            => v_wuser_narrow,
      buser_exp        => "0",
      msg              => "Testing smaller parameter widths on all unconstrained inputs"
    );
    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");
    -- Checking that the data was written correctly
    axi_check(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      araddr           => x"00000500",
      arlen            => x"01",
      arsize           => 4,
      rdata_exp        => t_slv_array'(x"00000012", x"00000034"),
      msg              => "Checking that the data was written correctly"
    );
    -- Testing smaller parameter widths on axi_check
    axi_check(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      arid             => "1",
      araddr           => x"500",
      arlen            => x"01",
      arsize           => 4,
      aruser           => "1",
      rdata_exp        => v_write_data_narrow,
      ruser_exp        => v_ruser_narrow,
      msg              => "Testing smaller parameter widths on axi_check"
    );
    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");
    -- Testing smaller parameter widths on axi_read
    axi_read(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      arid             => "1",
      araddr           => x"500",
      arlen            => x"01",
      arsize           => 4,
      aruser           => "1",
      data_routing     => TO_BUFFER,
      msg              => "Testing smaller parameter widths on axi_read"
    );
    v_cmd_idx := get_last_received_cmd_idx(AXI_VVCT, 1); -- Retrieve the command index
    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");
    fetch_result(AXI_VVCT, 1, v_cmd_idx, v_result, "Fetching read result");
    check_value(v_result.rid, x"01", "Checking RID", C_SCOPE);
    for i in 0 to 1 loop
      check_value(v_result.rdata(i), v_write_data_narrow(i), "Checking RDATA, index " & to_string(i), C_SCOPE);
      check_value(v_result.ruser(i), x"00", "Checking RUSER, index " & to_string(i), C_SCOPE);
    end loop;
    -- Testing larger parameter widths on all unconstrained inputs
    axi_write(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      awid             => x"001",
      awaddr           => x"000000510",
      awlen            => x"01",
      awsize           => 4,
      awuser           => x"001",
      wdata            => v_write_data_wide,
      wstrb            => v_wstrb_wide,
      wuser            => v_wuser_wide,
      buser_exp        => x"000",
      msg              => "Testing larger parameter widths on all unconstrained inputs"
    );
    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");
    -- Checking that the data was written correctly
    axi_check(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      araddr           => x"00000510",
      arlen            => x"01",
      arsize           => 4,
      rdata_exp        => t_slv_array'(x"87654321", x"9ABCDEF0"),
      msg              => "Checking that the data was written correctly"
    );
    -- Testing larger parameter widths on axi_check
    axi_check(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      arid             => x"001",
      araddr           => x"0000000510",
      arlen            => x"01",
      arsize           => 4,
      aruser           => x"001",
      rdata_exp        => v_write_data_wide,
      ruser_exp        => v_ruser_wide,
      msg              => "Testing larger parameter widths on axi_check"
    );
    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");
    -- Testing larger parameter widths on axi_read
    axi_read(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      arid             => x"001",
      araddr           => x"0000000510",
      arlen            => x"01",
      arsize           => 4,
      aruser           => x"001",
      data_routing     => TO_BUFFER,
      msg              => "Testing smaller parameter widths on axi_read"
    );
    v_cmd_idx := get_last_received_cmd_idx(AXI_VVCT, 1); -- Retrieve the command index
    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");
    fetch_result(AXI_VVCT, 1, v_cmd_idx, v_result, "Fetching read result");
    check_value(v_result.rid, x"01", "Checking RID", C_SCOPE);
    for i in 0 to 1 loop
      check_value(v_result.rdata(i), v_write_data_wide(i), "Checking RDATA, index " & to_string(i), C_SCOPE);
      check_value(v_result.ruser(i), x"00", "Checking RUSER, index " & to_string(i), C_SCOPE);
    end loop;

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing that ID and user of size 0 is allowed");
    ------------------------------------------------------------------------------------------------------------------------------
    axi_write(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 2,
      awaddr           => x"00000000",
      awlen            => x"03",
      awsize           => 4,
      wdata            => v_write_data,
      msg              => "Testing AXI write"
    );
    await_completion(AXI_VVCT, 2, 1 us, "Waiting for commands to finish");
    axi_check(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 2,
      araddr           => x"00000000",
      arlen            => x"03",
      arsize           => 4,
      rdata_exp        => t_slv_array'(x"12345678", x"33333333", x"55555555", x"AAAAAAAA"),
      msg              => "Testing AXI check"
    );
    await_completion(AXI_VVCT, 2, 1 us, "Waiting for commands to finish");
    axi_read(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 2,
      araddr           => x"00000000",
      arlen            => x"03",
      arsize           => 4,
      data_routing     => TO_BUFFER,
      msg              => "Testing AXI read"
    );
    v_cmd_idx := get_last_received_cmd_idx(AXI_VVCT, 2); -- Retrieve the command index
    await_completion(AXI_VVCT, 2, 1 us, "Waiting for commands to finish");
    fetch_result(AXI_VVCT, 2, v_cmd_idx, v_result, "Fetching read result");
    -- check_value(v_result.rid, x"00", "Checking RID", C_SCOPE);
    for i in 0 to 3 loop
      check_value(v_result.rdata(i), v_write_data(i), "Checking RDATA, index " & to_string(i), C_SCOPE);
      -- check_value(v_result.ruser(i), x"00", "Checking RUSER, index " & to_string(i), C_SCOPE);
    end loop;

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing TIME_START2START");
    ------------------------------------------------------------------------------------------------------------------------------
    axi_write(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      awaddr           => x"00000000",
      awlen            => x"03",
      awsize           => 4,
      wdata            => v_write_data,
      msg              => "Testing AXI write"
    );
    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");
    v_timestamp                                            := now;
    shared_axi_vvc_config(1).inter_bfm_delay.delay_type    := TIME_START2START;
    shared_axi_vvc_config(1).inter_bfm_delay.delay_in_time := 10 us;
    axi_write(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      awaddr           => x"00000000",
      awlen            => x"03",
      awsize           => 4,
      wdata            => v_write_data,
      msg              => "Testing AXI write"
    );
    await_completion(AXI_VVCT, 1, 100 us, "Waiting for commands to finish");
    check_value(now - v_timestamp, 10 us, ERROR, "Checking that inter-bfm delay was upheld");

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing TIME_FINISH2START");
    ------------------------------------------------------------------------------------------------------------------------------
    increment_expected_alerts(TB_WARNING, 1, "Expecting warning because TIME_FINISH2START is not supported", C_SCOPE);
    v_timestamp                                            := now;
    shared_axi_vvc_config(1).inter_bfm_delay.delay_type    := TIME_FINISH2START;
    axi_write(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      awaddr           => x"00000000",
      awlen            => x"03",
      awsize           => 4,
      wdata            => v_write_data,
      msg              => "Testing AXI write"
    );
    await_completion(AXI_VVCT, 1, 100 us, "Waiting for commands to finish");
    shared_axi_vvc_config(1).inter_bfm_delay.delay_type    := NO_DELAY;
    shared_axi_vvc_config(1).inter_bfm_delay.delay_in_time := 0 ns;

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing to force single pending transactions");
    ------------------------------------------------------------------------------------------------------------------------------
    -- First we measure the time it takes to perform a read and write simultaneously
    v_timestamp                                               := now;
    axi_write(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      awaddr           => x"00000000",
      awlen            => x"03",
      awsize           => 4,
      wdata            => v_write_data,
      msg              => "Testing AXI write"
    );
    axi_read(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      araddr           => x"00000004",
      arlen            => x"03",
      arsize           => 4,
      data_routing     => TO_BUFFER,
      msg              => "Testing AXI read"
    );
    await_completion(AXI_VVCT, 1, 100 us, "Waiting for commands to finish");
    v_measured_time                                           := now - v_timestamp;
    -- Then, we turn on the force_single_penging_transaction setting, and see that it takes about twice as long
    shared_axi_vvc_config(1).force_single_pending_transaction := true;
    v_timestamp                                               := now;
    axi_write(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      awaddr           => x"00000000",
      awlen            => x"03",
      awsize           => 4,
      wdata            => v_write_data,
      msg              => "Testing AXI write"
    );
    axi_read(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 1,
      araddr           => x"00000004",
      arlen            => x"03",
      arsize           => 4,
      data_routing     => TO_BUFFER,
      msg              => "Testing AXI read"
    );
    await_completion(AXI_VVCT, 1, 100 us, "Waiting for commands to finish");
    -- Checking that it takes twice as long (+- 20 %)
    check_value_in_range(now - v_timestamp, v_measured_time * 1.8, v_measured_time * 2.2, ERROR, "Checking that it takes longer time to force a single pending transaction");

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing severity level configuration");
    ------------------------------------------------------------------------------------------------------------------------------
    -- Set general_severity in bfm config to WARNING
    -- Test with unexpected BRESP
    shared_axi_vvc_config(1).bfm_config.general_severity := WARNING;
    increment_expected_alerts(WARNING, 1, "Expecting warning due to triggering of unexpected BRESP value", C_SCOPE);
    axi_write(
        VVCT             => AXI_VVCT,
        vvc_instance_idx => 1,
        awid             => x"001",
        awaddr           => x"000000510",
        awlen            => x"01",
        awsize           => 4,
        awuser           => x"001",
        wdata            => v_write_data_wide,
        wstrb            => v_wstrb_wide,
        wuser            => v_wuser_wide,
        buser_exp        => x"000",
        bresp_exp        => SLVERR,
        msg              => "Testing axi_write with unexpected BRESP response value"
      );
    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");


    -- Set general_severity in bfm config to NOTE
    -- Test with unexpected BUSER
    shared_axi_vvc_config(1).bfm_config.general_severity := NOTE;
    increment_expected_alerts(NOTE, 1, "Expecting note due to triggering of unexpected BUSER value", C_SCOPE);
    axi_write(
        VVCT             => AXI_VVCT,
        vvc_instance_idx => 1,
        awid             => x"001",
        awaddr           => x"000000510",
        awlen            => x"01",
        awsize           => 4,
        awuser           => x"001",
        wdata            => v_write_data_wide,
        wstrb            => v_wstrb_wide,
        wuser            => v_wuser_wide,
        buser_exp        => x"010",
        msg              => "Testing axi_write with unexpected BUSER response value"
      );
    await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");

    -- Set severity level back to default (ERROR) in case more tests are added below
    shared_axi_vvc_config(1).bfm_config.general_severity := ERROR;

    --------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing Unwanted Activity Detection in VVC", C_SCOPE);
    --------------------------------------------------------------------------------------------------------------------
    for i in 0 to 2 loop
      -- Test different alert severity configurations
      if i = 0 then
        v_alert_level := C_AXI_VVC_CONFIG_DEFAULT.unwanted_activity_severity;
      elsif i = 1 then
        v_alert_level := FAILURE;
      else
        v_alert_level := NO_ALERT;
      end if;
      log(ID_SEQUENCER, "Setting unwanted_activity_severity to " & to_upper(to_string(v_alert_level)), C_SCOPE);
      shared_axi_vvc_config(1).unwanted_activity_severity := v_alert_level;

      log(ID_SEQUENCER, "Testing normal data transmission", C_SCOPE);
      axi_write(
        VVCT             => AXI_VVCT,
        vvc_instance_idx => 1,
        awaddr           => x"00000000",
        awlen            => x"03",
        awsize           => 4,
        wdata            => v_write_data,
        msg              => "Testing AXI write"
      );
      await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");
      axi_check(
        VVCT             => AXI_VVCT,
        vvc_instance_idx => 1,
        araddr           => x"00000000",
        arlen            => x"03",
        arsize           => 4,
        rdata_exp        => t_slv_array'(x"12345678", x"33333333", x"55555555", x"AAAAAAAA"),
        msg              => "Testing AXI check"
      );
      await_completion(AXI_VVCT, 1, 1 us, "Waiting for commands to finish");

      -- Test with and without a time gap between await_completion and unexpected data transmission
      if i = 0 then
        log(ID_SEQUENCER, "Wait 100 ns", C_SCOPE);
        wait for 100 ns;
      end if;

      log(ID_SEQUENCER, "Testing unexpected data transmission", C_SCOPE);
      toggle_vvc_if(v_alert_level);
    end loop;

    report_alert_counters(FINAL);       -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely
  end process p_main;
end architecture sim;
