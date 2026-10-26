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

-- Include Verification IPs
library p2l2_vip_mdio;
use p2l2_vip_mdio.mdio_bfm_pkg.all;

--hdlregression:tb
-- Test case entity
-- BFM TB without VVCs (mdio_th, architecture struct_bfm): p_sta plays the STA, p_phy the PHY. Each of them either
-- calls the BFM procedures or drives raw bits, so the other side sees frames and bus behaviour a VVC never produces.
-- The two processes are synchronised with await_barrier, one barrier per step.
entity mdio_bfm_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity;

-- Test case architecture
architecture func of mdio_bfm_tb is

  constant C_SCOPE : string := C_TB_SCOPE_DEFAULT;

  constant C_BARRIER_TIMEOUT : time := 10 ms;

  constant C_PHY_ADDR   : std_ulogic_vector(C_MDIO_PHY_ADDR_WIDTH-1 downto 0) := "00001"; -- = phy.phy_address default
  constant C_OTHER_ADDR : std_ulogic_vector(C_MDIO_PHY_ADDR_WIDTH-1 downto 0) := "00010"; -- nobody answers
  constant C_REG        : std_ulogic_vector(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0) := "00101";

  -- STA timing used by the raw frames, the same as the STA BFM defaults
  constant C_MDC_PERIOD   : time := C_MDIO_STA_BFM_CONFIG_DEFAULT.mdc_period;
  constant C_OUTPUT_DELAY : time := C_MDIO_BFM_CONFIG_DEFAULT.output_delay;

  -- Rising MDC edges of a frame with 32 preamble bits up to the last header bit (preamble + ST OP PHYAD REGAD):
  -- after this edge the turnaround starts
  constant C_HEADER_EDGES : natural := C_MDIO_PREAMBLE_LENGTH + 14;

  constant C_NUM_RANDOM_FRAMES : positive := 20;

  type t_data_array is array (natural range <>) of std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);

  -- check_bit_timing: one bit time of raw stimulus (p_sta) and how mdio_check_bit_timing() checks it (p_phy).
  -- The bit time starts with a rising MDC edge, MDIO changes to 'value' as given by 'change':
  type t_change is (
    NO_CHANGE,          -- MDIO keeps its value
    SAME_DELTA_AS_EDGE, -- together with the rising edge: belongs to the setup of the bit time before
    DELTA_AFTER_EDGE,   -- in the time step of the rising edge, but after it: 0 ns hold time
    AFTER_DELAY         -- 'delay' after the rising edge
  );
  type t_bit_stim is record
    value     : std_ulogic;          -- '0' / '1' driven, 'Z' released (the bus reads 'H')
    change    : t_change;
    delay     : time;
    period    : time;                -- of this bit time
    high      : time;                -- MDC high phase
    driver    : t_mdio_bit_driver;   -- how the checker treats this bit time
    side      : t_mdio_timing_check;
    alert_lvl : t_alert_level;
  end record t_bit_stim;
  type t_bit_stim_array is array (natural range <>) of t_bit_stim;

  constant C_P : time := 400 ns;
  constant C_H : time := 200 ns;
  -- Expected alerts per entry in the comments, 11 in total. The MDC alerts of the short bit time (period 300 ns, high
  -- 150 ns): high time and falling-edge period at its falling edge, period and low time at the next rising edge, and
  -- the falling-edge period once more at the falling edge of the following bit time.
  constant C_BIT_STIM : t_bit_stim_array := (
    ('1', AFTER_DELAY,         150 ns, C_P,    C_H,    STA_DRIVES,   CHECK_BOTH, ERROR),    --  0: ok
    ('0', DELTA_AFTER_EDGE,      0 ns, C_P,    C_H,    STA_DRIVES,   CHECK_BOTH, ERROR),    --  1: 0 ns hold time
    ('1', AFTER_DELAY,           5 ns, C_P,    C_H,    STA_DRIVES,   CHECK_BOTH, ERROR),    --  2: hold time 5 ns
    ('0', AFTER_DELAY,         395 ns, C_P,    C_H,    STA_DRIVES,   CHECK_BOTH, ERROR),    --  3: setup time 5 ns
    ('0', NO_CHANGE,             0 ns, C_P,    C_H,    STA_DRIVES,   CHECK_BOTH, ERROR),    --  4: 0 ns setup (change of 5)
    ('1', SAME_DELTA_AS_EDGE,    0 ns, C_P,    C_H,    STA_DRIVES,   CHECK_BOTH, ERROR),    --  5: (counted in 4)
    ('Z', AFTER_DELAY,         150 ns, C_P,    C_H,    STA_RELEASES, CHECK_BOTH, ERROR),    --  6: ok
    ('0', AFTER_DELAY,         250 ns, C_P,    C_H,    PHY_DRIVES,   CHECK_BOTH, ERROR),    --  7: ok
    ('1', AFTER_DELAY,         310 ns, C_P,    C_H,    PHY_DRIVES,   CHECK_BOTH, ERROR),    --  8: PHY output delay
    ('0', DELTA_AFTER_EDGE,      0 ns, C_P,    C_H,    PHY_DRIVES,   CHECK_BOTH, ERROR),    --  9: ok, 0 ns is allowed
    ('Z', AFTER_DELAY,         310 ns, C_P,    C_H,    PHY_RELEASES, CHECK_BOTH, ERROR),    -- 10: late release
    ('1', AFTER_DELAY,         150 ns, C_P,    C_H,    STA_DRIVES,   CHECK_BOTH, ERROR),    -- 11: ok
    ('0', AFTER_DELAY,           5 ns, C_P,    C_H,    STA_DRIVES,   CHECK_PHY,  ERROR),    -- 12: STA side not checked
    ('1', AFTER_DELAY,         310 ns, C_P,    C_H,    PHY_DRIVES,   CHECK_STA,  ERROR),    -- 13: PHY side not checked
    ('0', AFTER_DELAY,           5 ns, C_P,    C_H,    STA_DRIVES,   CHECK_BOTH, NO_ALERT), -- 14: not reported
    ('1', AFTER_DELAY,         100 ns, 300 ns, 150 ns, STA_DRIVES,   CHECK_BOTH, ERROR),    -- 15: 4 MDC alerts
    ('0', AFTER_DELAY,         150 ns, C_P,    C_H,    STA_DRIVES,   CHECK_BOTH, ERROR),    -- 16: falling-edge period
    ('1', AFTER_DELAY,         150 ns, C_P,    C_H,    STA_DRIVES,   CHECK_BOTH, ERROR)     -- 17: ok
  );
  constant C_BIT_STIM_ALERTS : natural := 11;

  -- the bus: written by both processes, the harness adds the pull-up. Every driver starts released.
  signal mdio_if        : t_mdio_if := init_mdio_if_signals;
  signal terminate_loop : std_logic := '0'; -- driven by p_sta only
  signal data_array     : t_data_array(0 to C_NUM_RANDOM_FRAMES-1);

  --------------------------------------------------------------------------------
  -- Frame bits (transmission order, left first) for the raw frames
  --------------------------------------------------------------------------------
  function bits(
    constant num   : natural;
    constant value : std_ulogic := '1') return std_ulogic_vector is
    constant C_BITS : std_ulogic_vector(1 to num) := (others => value);
  begin
    return C_BITS;
  end function bits;

  constant C_PREAMBLE : std_ulogic_vector := bits(C_MDIO_PREAMBLE_LENGTH);

  -- ST OP PHYAD REGAD TA DATA of a clause 22 frame. Any std_ulogic value can be given, e.g. 'X' or 'Z' (released).
  function c22_frame(
    constant op       : std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0);
    constant phy_addr : std_ulogic_vector(C_MDIO_PHY_ADDR_WIDTH-1 downto 0);
    constant reg_addr : std_ulogic_vector(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0);
    constant ta       : std_ulogic_vector(C_MDIO_TA_WIDTH-1 downto 0);
    constant data     : std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0)) return std_ulogic_vector is
    -- constrained: the concatenation alone would get the range of C_MDIO_ST_CL22, 1 downto -30
    constant C_FRAME : std_ulogic_vector(31 downto 0) := C_MDIO_ST_CL22 & op & phy_addr & reg_addr & ta & data;
  begin
    return C_FRAME;
  end function c22_frame;

  -- A correct clause 22 write to this PHY, with preamble
  function c22_write(
    constant data : std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0)) return std_ulogic_vector is
  begin
    return C_PREAMBLE & c22_frame(C_MDIO_OP_CL22_WRITE, C_PHY_ADDR, C_REG, "10", data);
  end function c22_write;

begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness: only the pull-up of MDIO
  -----------------------------------------------------------------------------
  i_test_harness : entity work.mdio_th(struct_bfm)
    port map(
      mdc  => mdio_if.mdc,
      mdio => mdio_if.mdio
    );

  --------------------------------------------------------------------------------------------------------------------------------
  -- PROCESS: p_sta
  -- The STA: STA BFM procedures or raw frames. Runs the test case and reports the result.
  --------------------------------------------------------------------------------------------------------------------------------
  p_sta : process is
    variable v_config : t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT;
    variable v_data   : std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);

    -- The wait lets the '1' that await_barrier assigns on leaving reach the bus first. Without it, two barriers in one
    -- time step leave global_barrier at '0': no event, both processes would wait for the timeout (without an alert).
    procedure barrier(constant msg : in string) is
    begin
      wait for 0 ns;
      await_barrier(global_barrier, C_BARRIER_TIMEOUT, msg, ERROR, C_SCOPE);
    end procedure barrier;

    -- Every alert so far was expected: the counters match after each step, not only at the end
    procedure check_alerts(constant msg : in string) is
      type t_alert_level_array is array (natural range <>) of t_alert_level;
      constant C_LEVELS : t_alert_level_array := (NOTE, TB_NOTE, WARNING, TB_WARNING, ERROR, TB_ERROR, FAILURE, TB_FAILURE);
    begin
      for i in C_LEVELS'range loop
        check_value(get_alert_counter(C_LEVELS(i), REGARD), get_alert_counter(C_LEVELS(i), EXPECT), ERROR,
                    msg & ": " & to_upper(t_alert_level'image(C_LEVELS(i))) & " alerts as expected", C_SCOPE, ID_NEVER);
      end loop;
    end procedure check_alerts;

    -- Raw STA: MDC with C_MDC_PERIOD, each bit driven C_OUTPUT_DELAY after the rising edge that samples the bit before
    -- (the first one a low phase before its edge), as the STA BFM does. MDIO is released after the last bit, MDC stays
    -- low. A bit 'Z' releases MDIO (the pull-up makes it 'H').
    procedure sta_drive_raw(constant frame_bits : in std_ulogic_vector) is
      constant C_BITS : std_ulogic_vector(0 to frame_bits'length-1) := frame_bits;
    begin
      mdio_if.mdc  <= '0';
      mdio_if.mdio <= C_BITS(0);
      wait for C_MDC_PERIOD / 2;
      for k in C_BITS'range loop
        mdio_if.mdc <= '1';
        if k < C_BITS'high then
          mdio_if.mdio <= C_BITS(k+1) after C_OUTPUT_DELAY;
        else
          mdio_if.mdio <= 'Z' after C_OUTPUT_DELAY;
        end if;
        wait for C_MDC_PERIOD / 2;
        mdio_if.mdc <= '0';
        wait for C_MDC_PERIOD / 2;
      end loop;
    end procedure sta_drive_raw;

    -- check_bit_timing: one bit time as described by stim
    procedure drive_bit_time(constant stim : in t_bit_stim) is
    begin
      if stim.change = SAME_DELTA_AS_EDGE then
        mdio_if.mdio <= stim.value;
      end if;
      mdio_if.mdc <= '1';
      if stim.change = DELTA_AFTER_EDGE then
        wait for 0 ns;
        mdio_if.mdio <= stim.value;
      end if;
      if stim.change = AFTER_DELAY and stim.delay < stim.high then
        wait for stim.delay;
        mdio_if.mdio <= stim.value;
        wait for stim.high - stim.delay;
      else
        wait for stim.high;
      end if;
      mdio_if.mdc <= '0';
      if stim.change = AFTER_DELAY and stim.delay >= stim.high then
        wait for stim.delay - stim.high;
        mdio_if.mdio <= stim.value;
        wait for stim.period - stim.delay;
      else
        wait for stim.period - stim.high;
      end if;
    end procedure drive_bit_time;

  begin
    -- To avoid that log files from different test cases (run in separate simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    -- Verbosity control
    enable_log_msg(ALL_MESSAGES);
    disable_log_msg(ID_BLOCKING); -- the barriers

    randomize(12, 34, "Set the random seeds", C_SCOPE);
    for i in data_array'range loop
      data_array(i) <= random(C_MDIO_DATA_WIDTH);
    end loop;

    log(ID_LOG_HDR_LARGE, "Simulating " & GC_TESTCASE, C_SCOPE);

    --============================================================================================================================
    if GC_TESTCASE = "bfm_sta_to_phy" then
      --============================================================================================================================
      -- p_phy calls the matching PHY procedure for every STA procedure
      log(ID_LOG_HDR, "Clause 22: write, read, check", C_SCOPE);
      ------------------------------------------------------------
      barrier("c22 write / expect_write");
      mdio_sta_c22_write(unsigned(C_PHY_ADDR), unsigned(C_REG), x"BEEF", "c22 write", mdio_if, terminate_loop, config => v_config);
      barrier("c22 write / receive_write");
      mdio_sta_c22_write(unsigned(C_PHY_ADDR), unsigned(C_REG), x"CAFE", "c22 write", mdio_if, terminate_loop, config => v_config);
      barrier("c22 read / reply_read");
      mdio_sta_c22_read(unsigned(C_PHY_ADDR), "00110", v_data, "c22 read", mdio_if, terminate_loop, config => v_config);
      check_value(v_data, x"1234", ERROR, "c22 read data", C_SCOPE);
      barrier("c22 check / reply_read");
      mdio_sta_c22_check(unsigned(C_PHY_ADDR), "00110", x"5678", "c22 check", mdio_if, terminate_loop, config => v_config);

      log(ID_LOG_HDR, "Clause 45: address, write, read, post-read-increment, check", C_SCOPE);
      ------------------------------------------------------------
      barrier("c45 address / expect_address");
      mdio_sta_c45_address(unsigned(C_PHY_ADDR), "00011", x"8000", "c45 address", mdio_if, terminate_loop, config => v_config);
      barrier("c45 address / receive_address");
      mdio_sta_c45_address(unsigned(C_PHY_ADDR), "00011", x"8001", "c45 address", mdio_if, terminate_loop, config => v_config);
      barrier("c45 write / expect_write");
      mdio_sta_c45_write(unsigned(C_PHY_ADDR), "00011", x"1111", "c45 write", mdio_if, terminate_loop, config => v_config);
      barrier("c45 write / receive_write");
      mdio_sta_c45_write(unsigned(C_PHY_ADDR), "00011", x"2222", "c45 write", mdio_if, terminate_loop, config => v_config);
      barrier("c45 read / reply_read");
      mdio_sta_c45_read(unsigned(C_PHY_ADDR), "00011", v_data, "c45 read", mdio_if, terminate_loop, config => v_config);
      check_value(v_data, x"3333", ERROR, "c45 read data", C_SCOPE);
      barrier("c45 check / reply_read");
      mdio_sta_c45_check(unsigned(C_PHY_ADDR), "00011", x"4444", "c45 check", mdio_if, terminate_loop, config => v_config);
      barrier("c45 post_read_increment / reply_post_read_increment");
      mdio_sta_c45_post_read_increment(unsigned(C_PHY_ADDR), "00011", v_data, "c45 post-read-increment", mdio_if, terminate_loop,
                                       config => v_config);
      check_value(v_data, x"5555", ERROR, "c45 post-read-increment data", C_SCOPE);
      barrier("c45 check_post_read_increment / reply_post_read_increment");
      mdio_sta_c45_check_post_read_increment(unsigned(C_PHY_ADDR), "00011", x"6666", "c45 check post-read-increment", mdio_if,
                                             terminate_loop, config => v_config);

      log(ID_LOG_HDR, "Frames to other targets are consumed: another PHY address, another DEVAD", C_SCOPE);
      ------------------------------------------------------------
      barrier("other targets");
      mdio_sta_c22_write(unsigned(C_OTHER_ADDR), unsigned(C_REG), x"0BAD", "c22 write to another PHY", mdio_if, terminate_loop,
                         config => v_config);
      mdio_sta_c45_write(unsigned(C_PHY_ADDR), "00100", x"0BAD", "c45 write to another DEVAD", mdio_if, terminate_loop,
                         config => v_config);
      mdio_sta_c45_write(unsigned(C_PHY_ADDR), "00011", x"7777", "c45 write to this PHY and DEVAD", mdio_if, terminate_loop,
                         config => v_config);

      log(ID_LOG_HDR, "Random data: " & to_string(C_NUM_RANDOM_FRAMES) & " c22 writes and reads", C_SCOPE);
      ------------------------------------------------------------
      for i in data_array'range loop
        barrier("random frame " & to_string(i));
        mdio_sta_c22_write(unsigned(C_PHY_ADDR), unsigned(data_array(i)(4 downto 0)), data_array(i), "random write", mdio_if,
                           terminate_loop, config => v_config);
        mdio_sta_c22_check(unsigned(C_PHY_ADDR), unsigned(data_array(i)(4 downto 0)), not data_array(i), "random read", mdio_if,
                           terminate_loop, config => v_config);
      end loop;
      barrier("done");
      check_alerts("bfm_sta_to_phy");

    --============================================================================================================================
    elsif GC_TESTCASE = "phy_frame_errors" then
      --============================================================================================================================
      -- p_sta drives raw frames, p_phy receives them with the PHY BFM
      log(ID_LOG_HDR, "Preamble of 31 bits: the frame is ignored, the next one is taken", C_SCOPE);
      ------------------------------------------------------------
      barrier("preamble 31");
      sta_drive_raw(bits(31) & c22_frame(C_MDIO_OP_CL22_WRITE, C_PHY_ADDR, C_REG, "10", x"1111") & c22_write(x"2222"));
      barrier("preamble 31 done");
      check_alerts("preamble 31");

      log(ID_LOG_HDR, "sync_to_frame_start = false, preamble of 16 bits: one ERROR, the frame is received", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      barrier("preamble 16");
      sta_drive_raw(bits(16) & c22_frame(C_MDIO_OP_CL22_WRITE, C_PHY_ADDR, C_REG, "10", x"3333"));
      barrier("preamble 16 done");
      check_alerts("preamble 16");

      log(ID_LOG_HDR, "Preamble partly only pulled up: one ERROR, the frame is received", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      barrier("preamble not driven");
      sta_drive_raw(bits(16, 'Z') & bits(16) & c22_frame(C_MDIO_OP_CL22_WRITE, C_PHY_ADDR, C_REG, "10", x"4444"));
      barrier("preamble not driven done");
      check_alerts("preamble not driven");

      log(ID_LOG_HDR, "Undefined PHYAD bit: one ERROR, the frame is not addressed, the next one is taken", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      barrier("undefined PHYAD");
      sta_drive_raw(C_PREAMBLE & c22_frame(C_MDIO_OP_CL22_WRITE, "0X001", C_REG, "10", x"0000") & c22_write(x"5555"));
      barrier("undefined PHYAD done");
      check_alerts("undefined PHYAD");

      log(ID_LOG_HDR, "Undefined OP bit (frame to another PHY): one ERROR, the frame is skipped, the next one is taken", C_SCOPE);
      ------------------------------------------------------------
      -- to this PHY the frame would be addressed: a wrong opcode, the call would end with it
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      barrier("undefined OP");
      sta_drive_raw(C_PREAMBLE & c22_frame("X1", C_OTHER_ADDR, C_REG, "10", x"0000") & c22_write(x"6666"));
      barrier("undefined OP done");
      check_alerts("undefined OP");

      log(ID_LOG_HDR, "Undefined bit in the written data: one ERROR instead of a data mismatch", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      barrier("undefined data");
      sta_drive_raw(C_PREAMBLE & c22_frame(C_MDIO_OP_CL22_WRITE, C_PHY_ADDR, C_REG, "10", "01110111011101X1"));
      barrier("undefined data done");
      check_alerts("undefined data");

      log(ID_LOG_HDR, "Turnaround of a write not ""10"": one ERROR, the data is still checked", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      barrier("write turnaround");
      sta_drive_raw(C_PREAMBLE & c22_frame(C_MDIO_OP_CL22_WRITE, C_PHY_ADDR, C_REG, "11", x"8888"));
      barrier("write turnaround done");
      check_alerts("write turnaround");

      log(ID_LOG_HDR, "Read to another PHY: turnaround bit 1 driven, bit 0 driven '1' (two ERRORs), then a frame to this PHY", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 2);
      barrier("other target turnaround");
      sta_drive_raw(C_PREAMBLE & c22_frame(C_MDIO_OP_CL22_READ, C_OTHER_ADDR, C_REG, "11", bits(16, 'Z')) & c22_write(x"9999"));
      barrier("other target turnaround done");
      check_alerts("other target turnaround");

      log(ID_LOG_HDR, "Read to an address without a PHY (STA scans the bus): no alert, then a frame to this PHY", C_SCOPE);
      ------------------------------------------------------------
      -- nobody drives the turnaround or the data: the bus stays at the pull-up
      barrier("absent PHY");
      sta_drive_raw(C_PREAMBLE & c22_frame(C_MDIO_OP_CL22_READ, C_OTHER_ADDR, C_REG, "ZZ", bits(16, 'Z')) &
                    C_PREAMBLE & C_MDIO_ST_CL45 & C_MDIO_OP_CL45_READ & C_OTHER_ADDR & "00011" & "ZZ" & bits(16, 'Z') & c22_write(x"9A9A"));
      barrier("absent PHY done");
      check_alerts("absent PHY");

      log(ID_LOG_HDR, "suppress_preamble, sync_to_frame_start = false: ST at the next edge, then a '1' first (one ERROR)", C_SCOPE);
      ------------------------------------------------------------
      barrier("start with ST");
      sta_drive_raw(c22_frame(C_MDIO_OP_CL22_WRITE, C_PHY_ADDR, C_REG, "10", x"AAAA"));
      barrier("start with ST done");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      barrier("bad start");
      sta_drive_raw('1' & c22_frame(C_MDIO_OP_CL22_WRITE, C_PHY_ADDR, C_REG, "10", x"BBBB"));
      barrier("bad start done");
      check_alerts("bad start");

      log(ID_LOG_HDR, "MDC stops in the middle of a frame: one ERROR after max_wait_mdc_change", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      barrier("MDC stall");
      sta_drive_raw(C_PREAMBLE & c22_frame(C_MDIO_OP_CL22_WRITE, C_PHY_ADDR, C_REG, "10", x"CCCC")(31 downto 22));
      barrier("MDC stall done");
      check_alerts("MDC stall");

      log(ID_LOG_HDR, "Reply to a read: the STA drives turnaround bit 1 and data bit 15 (two ERRORs)", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 2);
      barrier("reply contention");
      sta_drive_raw(C_PREAMBLE & c22_frame(C_MDIO_OP_CL22_READ, C_PHY_ADDR, C_REG, "1Z", '0' & bits(15, 'Z')));
      barrier("reply contention done");
      check_alerts("reply contention");

      log(ID_LOG_HDR, "Reply to a read: the STA drives turnaround bit 0 '1' while the PHY drives '0' (one ERROR)", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      barrier("turnaround bit 0 contention");
      sta_drive_raw(C_PREAMBLE & c22_frame(C_MDIO_OP_CL22_READ, C_PHY_ADDR, C_REG, "Z1", bits(16, 'Z')));
      barrier("turnaround bit 0 contention done");
      check_alerts("turnaround bit 0 contention");

    --============================================================================================================================
    elsif GC_TESTCASE = "sta_frame_errors" then
      --============================================================================================================================
      -- p_sta calls the STA BFM, p_phy drives the PHY's bits raw
      log(ID_LOG_HDR, "No PHY: turnaround bit 0 not driven, one ERROR, the data reads all ones", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      barrier("no PHY");
      mdio_sta_c22_read(unsigned(C_PHY_ADDR), unsigned(C_REG), v_data, "read without PHY", mdio_if, terminate_loop, config => v_config);
      check_value(v_data, x"FFFF", ERROR, "read without PHY", C_SCOPE);
      -- turnaround_not_driven_severity NO_ALERT: test for an absent PHY
      v_config.sta.turnaround_not_driven_severity := NO_ALERT;
      mdio_sta_c22_read(unsigned(C_PHY_ADDR), unsigned(C_REG), v_data, "read without PHY, no alert", mdio_if, terminate_loop,
                        config => v_config);
      check_value(v_data, x"FFFF", ERROR, "read without PHY, no alert", C_SCOPE);
      v_config := C_MDIO_BFM_CONFIG_DEFAULT;
      barrier("no PHY done");
      check_alerts("no PHY");

      log(ID_LOG_HDR, "The PHY drives turnaround bit 1: one ERROR, no data compare", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      barrier("turnaround bit 1");
      mdio_sta_c22_check(unsigned(C_PHY_ADDR), unsigned(C_REG), x"0000", "check, data not compared", mdio_if, terminate_loop,
                         config => v_config);
      barrier("turnaround bit 1 done");
      check_alerts("turnaround bit 1");

      log(ID_LOG_HDR, "Undefined bit in the read data: one ERROR, no data compare", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      barrier("undefined read data");
      mdio_sta_c22_check(unsigned(C_PHY_ADDR), unsigned(C_REG), x"0000", "check, data not compared", mdio_if, terminate_loop,
                         config => v_config);
      barrier("undefined read data done");
      check_alerts("undefined read data");

      log(ID_LOG_HDR, "The PHY does not release MDIO after the frame: one ERROR (IDLE check), with 1 and with 0 IDLE bits", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 2);
      for i in 1 downto 0 loop
        v_config.sta.idle_cycles := i;
        barrier("no release, " & to_string(i) & " IDLE bits");
        mdio_sta_c22_read(unsigned(C_PHY_ADDR), unsigned(C_REG), v_data, "read, PHY keeps MDIO", mdio_if, terminate_loop,
                          config => v_config);
        check_value(v_data, x"0001", ERROR, "read data", C_SCOPE);
        barrier("no release done"); -- p_phy releases MDIO
      end loop;
      v_config := C_MDIO_BFM_CONFIG_DEFAULT;
      check_alerts("no release");

      log(ID_LOG_HDR, "The PHY drives a data bit of a write: one ERROR (bus contention)", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      barrier("write contention");
      mdio_sta_c22_write(unsigned(C_PHY_ADDR), unsigned(C_REG), x"FFFF", "write, PHY drives data bit 15", mdio_if, terminate_loop,
                         config => v_config);
      barrier("write contention done");
      check_alerts("write contention");

    --============================================================================================================================
    elsif GC_TESTCASE = "config_errors" then
      --============================================================================================================================
      -- Config checks only: terminate_loop is set, so every call ends before it drives the bus with the broken config
      -- (a negative output_delay would stop the simulator in "after output_delay").
      terminate_loop <= '1';
      wait for 0 ns;

      log(ID_LOG_HDR, "STA mdc_period 0 ns: two TB_FAILUREs, five timing ERRORs", C_SCOPE);
      ------------------------------------------------------------
      -- TB_FAILURE: not positive, output_delay not shorter. ERROR: period, high, low, setup before the next edge, first bit
      increment_expected_alerts_and_stop_limit(TB_FAILURE, 2);
      increment_expected_alerts_and_stop_limit(ERROR, 5);
      v_config.sta.mdc_period := 0 ns;
      mdio_sta_c22_write(unsigned(C_PHY_ADDR), unsigned(C_REG), x"0000", "mdc_period 0 ns", mdio_if, terminate_loop, config => v_config);
      v_config := C_MDIO_BFM_CONFIG_DEFAULT;
      check_alerts("mdc_period 0 ns");

      log(ID_LOG_HDR, "STA output_delay -1 ns: one TB_FAILURE, one ERROR (below min_hold_time)", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(TB_FAILURE, 1);
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      v_config.output_delay := -1 ns;
      mdio_sta_c22_write(unsigned(C_PHY_ADDR), unsigned(C_REG), x"0000", "output_delay -1 ns", mdio_if, terminate_loop, config => v_config);
      v_config := C_MDIO_BFM_CONFIG_DEFAULT;
      check_alerts("STA output_delay -1 ns");

      log(ID_LOG_HDR, "STA output_delay = mdc_period: one TB_FAILURE, one ERROR (no setup time left)", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(TB_FAILURE, 1);
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      v_config.output_delay := C_MDC_PERIOD;
      mdio_sta_c22_write(unsigned(C_PHY_ADDR), unsigned(C_REG), x"0000", "output_delay = mdc_period", mdio_if, terminate_loop,
                         config => v_config);
      v_config := C_MDIO_BFM_CONFIG_DEFAULT;
      check_alerts("STA output_delay = mdc_period");

      log(ID_LOG_HDR, "STA read with mdc_period 300 ns: four ERRORs, none with timing_violation_severity NO_ALERT", C_SCOPE);
      ------------------------------------------------------------
      -- period, high and low time below the minimum, too short for a PHY driving 300 ns after the edge
      increment_expected_alerts_and_stop_limit(ERROR, 4);
      v_config.sta.mdc_period := 300 ns;
      mdio_sta_c22_read(unsigned(C_PHY_ADDR), unsigned(C_REG), v_data, "read, mdc_period 300 ns", mdio_if, terminate_loop,
                        config => v_config);
      check_value(v_data, "XXXXXXXXXXXXXXXX", MATCH_EXACT, ERROR, "a terminated read returns 'X'", C_SCOPE);
      v_config.timing_violation_severity := NO_ALERT;
      mdio_sta_c22_read(unsigned(C_PHY_ADDR), unsigned(C_REG), v_data, "read, mdc_period 300 ns, NO_ALERT", mdio_if, terminate_loop,
                        config => v_config);
      v_config := C_MDIO_BFM_CONFIG_DEFAULT;
      check_alerts("STA read timing");

      log(ID_LOG_HDR, "PHY negative timeout: one TB_FAILURE, no timeout ERROR", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(TB_FAILURE, 1);
      mdio_phy_c22_expect_write(unsigned(C_REG), x"0000", "negative timeout", mdio_if, terminate_loop, timeout => -1 us,
                                config                                                                         => v_config);
      check_alerts("PHY negative timeout");

      -- The PHY calls wait 1 us for a frame, then see terminate_loop: no timeout alert, nothing driven
      log(ID_LOG_HDR, "PHY output_delay -1 ns: one TB_FAILURE", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(TB_FAILURE, 1);
      v_config.output_delay := -1 ns;
      mdio_phy_c22_reply_read(unsigned(C_REG), x"0000", "output_delay -1 ns", mdio_if, terminate_loop, timeout => 1 us, config => v_config);
      v_config := C_MDIO_BFM_CONFIG_DEFAULT;
      check_alerts("PHY output_delay -1 ns");

      log(ID_LOG_HDR, "PHY output_delay = min_mdc_period: one TB_FAILURE, one ERROR (above 300 ns)", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(TB_FAILURE, 1);
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      v_config.output_delay := v_config.min_mdc_period;
      mdio_phy_c45_reply_read("00011", x"0000", "output_delay = min_mdc_period", mdio_if, terminate_loop, timeout => 1 us,
                              config                                                                              => v_config);
      v_config := C_MDIO_BFM_CONFIG_DEFAULT;
      check_alerts("PHY output_delay = min_mdc_period");

      log(ID_LOG_HDR, "PHY output_delay 310 ns: one ERROR, none with timing_violation_severity NO_ALERT", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      v_config.output_delay := 310 ns;
      mdio_phy_c45_reply_post_read_increment("00011", x"0000", "output_delay 310 ns", mdio_if, terminate_loop, timeout => 1 us,
                                             config                                                                    => v_config);
      v_config.timing_violation_severity := NO_ALERT;
      mdio_phy_c45_reply_post_read_increment("00011", x"0000", "output_delay 310 ns, NO_ALERT", mdio_if, terminate_loop,
                                             timeout => 1 us, config => v_config);
      v_config := C_MDIO_BFM_CONFIG_DEFAULT;
      check_alerts("PHY output_delay 310 ns");

      terminate_loop <= '0';

    --============================================================================================================================
    elsif GC_TESTCASE = "check_bit_timing" then
      --============================================================================================================================
      -- p_sta drives C_BIT_STIM, p_phy checks it with mdio_check_bit_timing()
      log(ID_LOG_HDR, "mdio_check_bit_timing() per bit driver: " & to_string(C_BIT_STIM_ALERTS) & " ERRORs expected", C_SCOPE);
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(ERROR, C_BIT_STIM_ALERTS);
      mdio_if.mdc  <= '0';
      mdio_if.mdio <= '0';
      barrier("bit timing");
      wait for C_MDC_PERIOD / 2;
      for i in C_BIT_STIM'range loop
        drive_bit_time(C_BIT_STIM(i));
      end loop;
      -- the rising edge that ends the last bit time
      mdio_if.mdc <= '1';
      wait for C_MDC_PERIOD / 2;
      mdio_if.mdc  <= '0';
      mdio_if.mdio <= 'Z';
      barrier("bit timing done");
      check_alerts("bit timing");

    else
      alert(TB_ERROR, "Unsupported test case: " & GC_TESTCASE, C_SCOPE);
    end if;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;             -- to allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                         -- to stop completely
  end process p_sta;

  --------------------------------------------------------------------------------------------------------------------------------
  -- PROCESS: p_phy
  -- The PHY at address C_PHY_ADDR: PHY BFM procedures, raw PHY bits or the passive timing check.
  --------------------------------------------------------------------------------------------------------------------------------
  p_phy : process is
    variable v_config    : t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT;
    variable v_data      : std_ulogic_vector(C_MDIO_DATA_WIDTH-1 downto 0);
    variable v_reg_addr  : unsigned(C_MDIO_REG_ADDR_WIDTH_C45-1 downto 0);
    variable v_mdc_edges : t_mdio_mdc_edges;
    variable v_driver    : t_mdio_bit_driver;
    variable v_side      : t_mdio_timing_check;
    variable v_level     : t_alert_level;
    variable v_sampled   : std_ulogic;
    variable v_bus       : std_ulogic;

    -- The wait lets the '1' that await_barrier assigns on leaving reach the bus first. Without it, two barriers in one
    -- time step leave global_barrier at '0': no event, both processes would wait for the timeout (without an alert).
    procedure barrier(constant msg : in string) is
    begin
      wait for 0 ns;
      await_barrier(global_barrier, C_BARRIER_TIMEOUT, msg, ERROR, C_SCOPE);
    end procedure barrier;

    -- Raw PHY: skip 'edges' rising MDC edges, then drive one bit per bit time, each 'output_delay' after its rising
    -- edge, as the PHY BFM does. release_bus: let MDIO go after the last bit.
    procedure phy_drive_raw(
      constant edges        : in natural;
      constant phy_bits     : in std_ulogic_vector;
      constant release_bus  : in boolean := true;
      constant output_delay : in time    := 100 ns) is
      constant C_BITS : std_ulogic_vector(0 to phy_bits'length-1) := phy_bits;
    begin
      for i in 1 to edges loop
        wait until rising_edge(mdio_if.mdc);
      end loop;
      for i in C_BITS'range loop
        mdio_if.mdio <= C_BITS(i) after output_delay;
        wait until rising_edge(mdio_if.mdc);
      end loop;
      if release_bus then
        mdio_if.mdio <= 'Z' after output_delay;
      end if;
    end procedure phy_drive_raw;

  begin
    --============================================================================================================================
    if GC_TESTCASE = "bfm_sta_to_phy" then
      --============================================================================================================================
      barrier("c22 write / expect_write");
      mdio_phy_c22_expect_write(unsigned(C_REG), x"BEEF", "c22 expect_write", mdio_if, terminate_loop, config => v_config);
      barrier("c22 write / receive_write");
      mdio_phy_c22_receive_write(unsigned(C_REG), v_data, "c22 receive_write", mdio_if, terminate_loop, config => v_config);
      check_value(v_data, x"CAFE", ERROR, "c22 received data", C_SCOPE);
      barrier("c22 read / reply_read");
      mdio_phy_c22_reply_read("00110", x"1234", "c22 reply_read", mdio_if, terminate_loop, config => v_config);
      barrier("c22 check / reply_read");
      mdio_phy_c22_reply_read("00110", x"5678", "c22 reply_read", mdio_if, terminate_loop, config => v_config);

      barrier("c45 address / expect_address");
      mdio_phy_c45_expect_address("00011", x"8000", "c45 expect_address", mdio_if, terminate_loop, config => v_config);
      barrier("c45 address / receive_address");
      mdio_phy_c45_receive_address("00011", v_reg_addr, "c45 receive_address", mdio_if, terminate_loop, config => v_config);
      check_value(v_reg_addr, x"8001", ERROR, "c45 received address", C_SCOPE);
      barrier("c45 write / expect_write");
      mdio_phy_c45_expect_write("00011", x"1111", "c45 expect_write", mdio_if, terminate_loop, config => v_config);
      barrier("c45 write / receive_write");
      mdio_phy_c45_receive_write("00011", v_data, "c45 receive_write", mdio_if, terminate_loop, config => v_config);
      check_value(v_data, x"2222", ERROR, "c45 received data", C_SCOPE);
      barrier("c45 read / reply_read");
      mdio_phy_c45_reply_read("00011", x"3333", "c45 reply_read", mdio_if, terminate_loop, config => v_config);
      barrier("c45 check / reply_read");
      mdio_phy_c45_reply_read("00011", x"4444", "c45 reply_read", mdio_if, terminate_loop, config => v_config);
      barrier("c45 post_read_increment / reply_post_read_increment");
      mdio_phy_c45_reply_post_read_increment("00011", x"5555", "c45 reply_post_read_increment", mdio_if, terminate_loop,
                                             config => v_config);
      barrier("c45 check_post_read_increment / reply_post_read_increment");
      mdio_phy_c45_reply_post_read_increment("00011", x"6666", "c45 reply_post_read_increment", mdio_if, terminate_loop,
                                             config => v_config);

      barrier("other targets");
      mdio_phy_c45_expect_write("00011", x"7777", "c45 expect_write after frames to other targets", mdio_if, terminate_loop,
                                config => v_config);

      for i in data_array'range loop
        barrier("random frame " & to_string(i));
        mdio_phy_c22_expect_write(unsigned(data_array(i)(4 downto 0)), data_array(i), "random expect_write", mdio_if, terminate_loop,
                                  config => v_config);
        mdio_phy_c22_reply_read(unsigned(data_array(i)(4 downto 0)), not data_array(i), "random reply_read", mdio_if, terminate_loop,
                                config => v_config);
      end loop;
      barrier("done");

    --============================================================================================================================
    elsif GC_TESTCASE = "phy_frame_errors" then
      --============================================================================================================================
      barrier("preamble 31");
      mdio_phy_c22_expect_write(unsigned(C_REG), x"2222", "the frame after the short preamble", mdio_if, terminate_loop,
                                config => v_config);
      barrier("preamble 31 done");

      v_config.sync_to_frame_start := false;
      barrier("preamble 16");
      mdio_phy_c22_receive_write(unsigned(C_REG), v_data, "short preamble", mdio_if, terminate_loop, config => v_config);
      check_value(v_data, x"3333", ERROR, "the frame is received", C_SCOPE);
      v_config := C_MDIO_BFM_CONFIG_DEFAULT;
      barrier("preamble 16 done");

      barrier("preamble not driven");
      mdio_phy_c22_receive_write(unsigned(C_REG), v_data, "preamble not driven", mdio_if, terminate_loop, config => v_config);
      check_value(v_data, x"4444", ERROR, "the frame is received", C_SCOPE);
      barrier("preamble not driven done");

      barrier("undefined PHYAD");
      mdio_phy_c22_expect_write(unsigned(C_REG), x"5555", "the frame after the undefined PHYAD", mdio_if, terminate_loop,
                                config => v_config);
      barrier("undefined PHYAD done");

      barrier("undefined OP");
      mdio_phy_c22_expect_write(unsigned(C_REG), x"6666", "the frame after the undefined OP", mdio_if, terminate_loop,
                                config => v_config);
      barrier("undefined OP done");

      barrier("undefined data");
      mdio_phy_c22_expect_write(unsigned(C_REG), x"7771", "undefined data", mdio_if, terminate_loop, config => v_config);
      barrier("undefined data done");

      barrier("write turnaround");
      mdio_phy_c22_expect_write(unsigned(C_REG), x"8888", "wrong turnaround", mdio_if, terminate_loop, config => v_config);
      barrier("write turnaround done");

      barrier("other target turnaround");
      mdio_phy_c22_expect_write(unsigned(C_REG), x"9999", "the frame after the read to another PHY", mdio_if, terminate_loop,
                                config => v_config);
      barrier("other target turnaround done");

      barrier("absent PHY");
      mdio_phy_c22_expect_write(unsigned(C_REG), x"9A9A", "the frame after the reads to an address without a PHY", mdio_if,
                                terminate_loop, config => v_config);
      barrier("absent PHY done");

      v_config.suppress_preamble   := true;
      v_config.sync_to_frame_start := false;
      barrier("start with ST");
      mdio_phy_c22_expect_write(unsigned(C_REG), x"AAAA", "ST at the next edge", mdio_if, terminate_loop, config => v_config);
      barrier("start with ST done");
      barrier("bad start");
      mdio_phy_c22_expect_write(unsigned(C_REG), x"BBBB", "a '1' at the next edge", mdio_if, terminate_loop, config => v_config);
      barrier("bad start done");
      v_config := C_MDIO_BFM_CONFIG_DEFAULT;

      v_config.phy.max_wait_mdc_change          := 5 us;
      v_config.phy.max_wait_mdc_change_severity := ERROR;
      barrier("MDC stall");
      mdio_phy_c22_expect_write(unsigned(C_REG), x"CCCC", "MDC stops", mdio_if, terminate_loop, config => v_config);
      barrier("MDC stall done");
      v_config := C_MDIO_BFM_CONFIG_DEFAULT;

      barrier("reply contention");
      mdio_phy_c22_reply_read(unsigned(C_REG), x"8000", "the STA drives as well", mdio_if, terminate_loop, config => v_config);
      barrier("reply contention done");

      barrier("turnaround bit 0 contention");
      mdio_phy_c22_reply_read(unsigned(C_REG), x"1234", "the STA drives turnaround bit 0", mdio_if, terminate_loop, config => v_config);
      barrier("turnaround bit 0 contention done");

    --============================================================================================================================
    elsif GC_TESTCASE = "sta_frame_errors" then
      --============================================================================================================================
      -- The PHY's part of a read: turnaround bit 1, turnaround bit 0, 16 data bits after the header edges
      barrier("no PHY");
      barrier("no PHY done");

      barrier("turnaround bit 1");
      phy_drive_raw(C_HEADER_EDGES, "00" & x"1234");
      barrier("turnaround bit 1 done");

      barrier("undefined read data");
      phy_drive_raw(C_HEADER_EDGES, "Z0" & "00010010001101X0");
      barrier("undefined read data done");

      for i in 1 downto 0 loop
        barrier("no release, " & to_string(i) & " IDLE bits");
        phy_drive_raw(C_HEADER_EDGES, "Z0" & x"0001", release_bus => false);
        barrier("no release done");
        mdio_if.mdio <= 'Z';
      end loop;

      -- data bit 15 of a write is driven after the turnaround edges
      barrier("write contention");
      phy_drive_raw(C_HEADER_EDGES + C_MDIO_TA_WIDTH, "0");
      barrier("write contention done");

    --============================================================================================================================
    elsif GC_TESTCASE = "check_bit_timing" then
      --============================================================================================================================
      -- Call i returns at rising edge i. Call 0 waits for the first edge, call i > 0 checks the bit time C_BIT_STIM(i-1).
      barrier("bit timing");
      v_bus := '0';
      for i in 0 to C_BIT_STIM'length loop
        if i = 0 then
          v_driver := NOT_CHECKED;
          v_side   := CHECK_BOTH;
          v_level  := ERROR;
        else
          v_driver := C_BIT_STIM(i-1).driver;
          v_side   := C_BIT_STIM(i-1).side;
          v_level  := C_BIT_STIM(i-1).alert_lvl;
          if C_BIT_STIM(i-1).change /= NO_CHANGE then
            v_bus := C_BIT_STIM(i-1).value;
            if v_bus = 'Z' then
              v_bus := 'H'; -- the pull-up
            end if;
          end if;
        end if;
        mdio_check_bit_timing(mdio_if, v_driver, v_mdc_edges, v_sampled, v_side, v_level, C_SCOPE, shared_msg_id_panel, v_config);
        if i > 0 then
          check_value(v_sampled, v_bus, ERROR, "sampled bit of bit time " & to_string(i-1), C_SCOPE, ID_SEQUENCER);
        end if;
      end loop;
      barrier("bit timing done");

    end if;
    wait; -- to stop completely
  end process p_phy;

end architecture func;
