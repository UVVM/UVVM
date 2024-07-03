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

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_error_injection;
use bitvis_vip_error_injection.error_injection_pkg.all;

--hdlregression:tb
entity ei_demo_tb is
  generic(GC_TESTCASE : natural := 0);
end entity ei_demo_tb;

architecture func of ei_demo_tb is

  constant C_SCOPE              : string                                      := "EI_DEMO_TB";
  constant C_SL_EI_IDX          : natural                                     := 1;
  constant C_SLV_EI_IDX         : natural                                     := 2;
  constant C_DATA_WIDTH         : natural                                     := 8;
  constant C_SL_SIGNAL_DEFAULT  : std_logic                                   := '0';
  constant C_SLV_SIGNAL_DEFAULT : std_logic_vector(C_DATA_WIDTH - 1 downto 0) := (others => '0');
  constant C_PULSE_WIDTH        : time                                        := 20 ns;

  -- Error Injection VIPs input/output signals
  -- std_logic
  signal output_sl  : std_logic                                   := C_SL_SIGNAL_DEFAULT;
  signal input_sl   : std_logic                                   := '0';
  -- vector
  signal input_slv  : std_logic_vector(C_DATA_WIDTH - 1 downto 0) := x"00";
  signal output_slv : std_logic_vector(C_DATA_WIDTH - 1 downto 0) := C_SLV_SIGNAL_DEFAULT;

begin

  -----------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  -----------------------------------------------------------------------------
  -- Error injector
  -----------------------------------------------------------------------------
  error_injector_sl : entity work.error_injection_sl
    generic map(
      GC_INSTANCE_IDX => 1
    )
    port map(
      ei_in  => input_sl,
      ei_out => output_sl
    );

  error_injector_slv : entity work.error_injection_slv
    generic map(
      GC_INSTANCE_IDX => 2
    )
    port map(
      ei_in  => input_slv,
      ei_out => output_slv
    );

  -----------------------------------------------------------------------------
  -- Testbench sequencer
  -----------------------------------------------------------------------------
  p_sequencer : process
    variable v_timestamp_sl   : time;
    variable v_timestamp_slv  : time;
    variable v_valid_interval : boolean := true;

    -- Generate EI VIP input signals.
    procedure run_test(slv_value : integer; msg : string := "Setting EI VIPs input signal") is
    begin
      log(ID_SEQUENCER_SUB, msg, C_SCOPE);
      input_slv <= std_logic_vector(to_unsigned(slv_value, C_DATA_WIDTH));
      gen_pulse(input_sl, C_PULSE_WIDTH, NON_BLOCKING, "pulsing SL");
    end procedure run_test;

    -- Set EI VIP configurations back to default values.
    procedure reset_config is
    begin
      -- Set default config.
      shared_ei_config(C_SL_EI_IDX)  := C_EI_CONFIG_DEFAULT;
      shared_ei_config(C_SLV_EI_IDX) := C_EI_CONFIG_DEFAULT;
      -- Set inputs to '0' and 0x0.
      run_test(0, "Resetting EI VIP inputs");
      -- Add small delay for next test.
      wait for 100 ns;
    end procedure reset_config;

    --==================================================================
    -- Test declarations
    --==================================================================

    --------------------------------------------------------------------
    -- Test case for DELAY error innjection
    --
    --    This test will test delay error injection on a SL and a SLV signal
    --    with defined delay values, random delay values, and with
    --    interval settings set to 1 and 2.
    --
    --    Note: test is self checking.
    --------------------------------------------------------------------
    procedure test_delay_error_injection(void : t_void) is
      variable v_init_delay : time := 7 ns;
    begin
      log(ID_LOG_HDR_XL, "Delay error injection tests");

      -----------------------------------------------------------------
      -- Delay test
      -----------------------------------------------------------------
      log(ID_LOG_HDR, "Delay test with delay = 7 ns and interval = 1.", C_SCOPE);
      -- Configure SL Error Injection VIP
      shared_ei_config(C_SL_EI_IDX).error_type         := DELAY;
      shared_ei_config(C_SL_EI_IDX).initial_delay_min  := v_init_delay;
      shared_ei_config(C_SL_EI_IDX).interval           := 1;
      -- Configure SLV Error Injection VIP
      shared_ei_config(C_SLV_EI_IDX).error_type        := DELAY;
      shared_ei_config(C_SLV_EI_IDX).initial_delay_min := v_init_delay;
      shared_ei_config(C_SLV_EI_IDX).interval          := 1;

      -- Create 2 EI input events and verify outputs
      for idx in 1 to 2 loop
        -- Verify initial values
        check_value(output_sl = '0', TB_ERROR, "verify SL output");
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8) - 1), TB_ERROR, "verify SLV output");

        -- Activate SL pulse and set SLV input value on EI VIPs
        run_test(idx);

        -- Verify output values
        wait until output_sl = '1';
        log(ID_SEQUENCER, "Verify delayed initial edge " & to_string(idx) & ".", C_SCOPE);
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV delayed output");

        -- Verify correct delay
        check_value(input_sl'last_event - output_sl'last_event = v_init_delay, TB_ERROR, "check SL initial delay time");
        check_value(input_slv'last_event - output_slv'last_event = v_init_delay, TB_ERROR, "check SLV initial delay time");

        -- For SL signal: verify output return value and timing
        wait until output_sl = '0';
        log(ID_SEQUENCER, "Verify delayed final edge " & to_string(idx) & ".\n", C_SCOPE);
        check_value(input_sl'last_event - output_sl'last_event = v_init_delay, TB_ERROR, "verify SL return delay time");
        -- For SL signal: wait low period
        wait for C_PULSE_WIDTH - v_init_delay;
      end loop;

      -----------------------------------------------------------------
      -- Interval  tests
      -----------------------------------------------------------------
      log(ID_LOG_HDR, "Delay test with delay = 7 ns and interval = 2.", C_SCOPE);

      -- Reconfigure EI VIPs error injection interval
      shared_ei_config(C_SL_EI_IDX).interval  := 2;
      shared_ei_config(C_SLV_EI_IDX).interval := 2;

      -- Create 5 EI input events and verify outputs
      for idx in 3 to 8 loop
        -- Activate SL pulse and set SLV input value on EI VIPs
        run_test(idx);

        -- Verify output values
        wait until output_sl = '1';
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV output");

        -- Verify correct delay
        if v_valid_interval = true then
          log(ID_SEQUENCER, "Verify delayed initial edge " & to_string(idx - 2) & ".", C_SCOPE);
          check_value(input_sl'last_event - output_sl'last_event = v_init_delay, TB_ERROR, "check SL delay time");
          check_value(input_slv'last_event - output_slv'last_event = v_init_delay, TB_ERROR, "check SLV delay time");
        else
          log(ID_SEQUENCER, "Verify non delayed initial edge " & to_string(idx - 2) & ".", C_SCOPE);
          check_value(input_sl'last_event - output_sl'last_event = 0 ns, TB_ERROR, "check SL no delay time");
          check_value(input_slv'last_event - output_slv'last_event = 0 ns, TB_ERROR, "check SLV delay time");
        end if;

        -- For SL signal: verify output return value and timing
        v_timestamp_sl := now;
        wait until output_sl = '0';
        check_value(output_sl = '0', TB_ERROR, "verify SL low");
        check_value((now - v_timestamp_sl) = C_PULSE_WIDTH, TB_ERROR, "verify SL high period");

        if v_valid_interval then
          log(ID_SEQUENCER, "Verify delayed final edge " & to_string(idx - 2) & ".\n", C_SCOPE);
          check_value(input_sl'last_event - output_sl'last_event = v_init_delay, TB_ERROR, "check SL delay time");
          wait for C_PULSE_WIDTH - v_init_delay;
        else
          log(ID_SEQUENCER, "Verify non delayed final edge " & to_string(idx - 2) & ".\n", C_SCOPE);
          check_value(input_sl'last_event - output_sl'last_event = 0 ns, TB_ERROR, "check SL no delay time");
          wait for C_PULSE_WIDTH;       -- low period
        end if;

        -- Flip next expected interval validity
        v_valid_interval := not (v_valid_interval);
      end loop;

      -- Reset VIPs for next test
      reset_config;

      -----------------------------------------------------------------
      -- Random delay tests
      -----------------------------------------------------------------
      log(ID_LOG_HDR, "Delay test with randomised delay = 1-10 ns and interval = 1.", C_SCOPE);

      -- Reconfigure SL EI VIP with randomised interval
      shared_ei_config(C_SL_EI_IDX).error_type        := DELAY;
      shared_ei_config(C_SL_EI_IDX).initial_delay_min := 1 ns;
      shared_ei_config(C_SL_EI_IDX).initial_delay_max := 10 ns; -- setting max = randomisation
      shared_ei_config(C_SL_EI_IDX).interval          := 1;

      for idx in 1 to 2 loop
        -- Verify initial value
        check_value(output_sl = '0', TB_ERROR, "check SL delayed output");

        -- Activate SL pulse on EI VIP
        run_test(idx);

        -- Verify correct initial delay range
        wait until output_sl = '1';
        log(ID_SEQUENCER, "Verify delayed initial edge " & to_string(idx) & ".", C_SCOPE);
        check_value(input_sl'last_event - output_sl'last_event < 11 ns, TB_ERROR, "check SL delay time");

        -- Verify correct final delay range
        wait until output_sl = '0';
        log(ID_SEQUENCER, "Verify delayed final edge " & to_string(idx) & ".\n", C_SCOPE);
        check_value(input_sl'last_event - output_sl'last_event < 11 ns, TB_ERROR, "verify SL delay time");
        wait for 20 ns;                 -- low period
      end loop;

      -- Reset VIPs for next test
      reset_config;
    end procedure test_delay_error_injection;

    --------------------------------------------------------------------
    -- Test cases for JITTER error injections
    --
    --    This test will test jitter error injection on a SL signal
    --    with defined jitter values and with interval settings set
    --    to 1 and 2.
    --
    --    Note: test is self checking.
    --------------------------------------------------------------------
    procedure test_jitter_error_injection(void : t_void) is
      variable v_init_delay   : time := 7 ns;
      variable v_return_delay : time := 3 ns;
    begin
      log(ID_LOG_HDR_XL, "Jitter error injection tests");

      -----------------------------------------------------------------
      -- Jitter test
      -----------------------------------------------------------------
      log(ID_LOG_HDR, "Jitter test with jitter = 7 ns - 3 ns and interval = 1.", C_SCOPE);

      -- Configure SL EI VIP
      shared_ei_config(C_SL_EI_IDX).error_type         := JITTER;
      shared_ei_config(C_SL_EI_IDX).initial_delay_min  := v_init_delay;
      shared_ei_config(C_SL_EI_IDX).return_delay_min   := v_return_delay;
      -- Jitter for SLV EI VIP is not supported
      shared_ei_config(C_SLV_EI_IDX).error_type        := JITTER; -- SLV jitter not supported!
      shared_ei_config(C_SLV_EI_IDX).initial_delay_min := v_init_delay;

      for idx in 1 to 2 loop
        -- Verify initial values
        check_value(output_sl = '0', TB_ERROR, "verify SL output");
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8) - 1), TB_ERROR, "verify SLV output");

        -- Activate SL pulse and set SLV input value on EI VIPs
        run_test(idx);

        -- Verify output values and timing
        wait until output_sl = '1';
        log(ID_SEQUENCER, "Verify jittered initial edge " & to_string(idx) & ".", C_SCOPE);
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV output");
        check_value(input_sl'last_event - output_sl'last_event = v_init_delay, TB_ERROR, "check SL initial delay time");
        check_value(output_slv'last_event = input_slv'last_event, TB_ERROR, "check SLV static");

        -- For SL signal: verify output return value and timing
        wait until output_sl = '0';
        log(ID_SEQUENCER, "Verify jittered final edge " & to_string(idx) & ".\n", C_SCOPE);
        check_value(input_sl'last_event - output_sl'last_event = v_return_delay, TB_ERROR, "verify SL return delay time");

        wait for C_PULSE_WIDTH;         -- SL low period
      end loop;

      -----------------------------------------------------------------
      -- Interval tests
      -----------------------------------------------------------------
      log(ID_LOG_HDR, "Jitter test with delay = 7 ns and interval = 2.", C_SCOPE);

      -- Reconfigure EI VIPs error injection interval
      shared_ei_config(C_SL_EI_IDX).interval  := 2;
      shared_ei_config(C_SLV_EI_IDX).interval := 2;

      for idx in 3 to 8 loop
        -- Activate SL pulse and set SLV input value on EI VIPs
        run_test(idx);

        -- Verify output values
        wait until output_sl = '1';
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV output");

        if v_valid_interval then
          log(ID_SEQUENCER, "Verify jittered initial edge " & to_string(idx - 2) & ".", C_SCOPE);
          check_value(input_sl'last_event - output_sl'last_event = v_init_delay, TB_ERROR, "check SL delay time");
          check_value(output_slv'last_event - input_slv'last_event = 0 ns, TB_ERROR, "check SLV static");
        else
          log(ID_SEQUENCER, "Verify non jittered initial edge " & to_string(idx - 2) & ".", C_SCOPE);
          check_value(input_sl'last_event - output_sl'last_event = 0 ns, TB_ERROR, "check SL no delay time");
          check_value(input_slv'last_event - output_slv'last_event = 0 ns, TB_ERROR, "check SLV delay time");
        end if;

        -- For SL signal: verify output return value and timing
        v_timestamp_sl := now;
        wait until output_sl = '0';
        check_value(output_sl = '0', TB_ERROR, "verify SL low");

        if v_valid_interval then
          log(ID_SEQUENCER, "Verify jittered final edge " & to_string(idx - 2) & ".\n", C_SCOPE);
          check_value((now - v_timestamp_sl) = (C_PULSE_WIDTH - v_init_delay + v_return_delay), TB_ERROR, "verify SL high period");
          check_value(input_sl'last_event - output_sl'last_event = v_return_delay, TB_ERROR, "check SL delay time");
          wait for C_PULSE_WIDTH - v_return_delay;
        else
          log(ID_SEQUENCER, "Verify non jittered final edge " & to_string(idx - 2) & ".\n", C_SCOPE);
          check_value((now - v_timestamp_sl) = C_PULSE_WIDTH, TB_ERROR, "verify SL high period");
          check_value(input_sl'last_event - output_sl'last_event = 0 ns, TB_ERROR, "check SL no delay time");
          wait for C_PULSE_WIDTH;       -- low period
        end if;

        -- Flip next expected interval validity
        v_valid_interval := not (v_valid_interval);
      end loop;

      -- Reset VIPs for next test
      reset_config;
    end procedure test_jitter_error_injection;

    --------------------------------------------------------------------
    -- Test cases for INVERT error injections
    --
    --    This test will test inverting error injection on a SL and SLV
    --    signal, with interval settings set to 1 and 2.
    --
    --    Note: test is self checking.
    --------------------------------------------------------------------
    procedure test_invert_error_injection(void : t_void) is
    begin
      log(ID_LOG_HDR_XL, "Invert error injection tests");

      -----------------------------------------------------------------
      -- Invert test
      ----------------------------------------------------------------
      log(ID_LOG_HDR, "Invert test with interval = 1.", C_SCOPE);

      -- Configure SL and SLV EI VIPs
      shared_ei_config(C_SL_EI_IDX).error_type  := INVERT;
      shared_ei_config(C_SLV_EI_IDX).error_type := INVERT;

      for idx in 1 to 2 loop
        -- Activate SL pulse and set SLV input value on EI VIPs
        run_test(idx);

        -- Verify output values
        wait on output_sl;
        log(ID_SEQUENCER, "Verify inverted signal " & to_string(idx - 2) & ".\n", C_SCOPE);
        check_value(input_sl = not (output_sl), TB_ERROR, "verify SL invert");
        check_value(input_slv = not (output_slv), TB_ERROR, "verify SLV invert");

        wait for C_PULSE_WIDTH;         -- SL low period
      end loop;

      -----------------------------------------------------------------
      -- Interval tests
      -----------------------------------------------------------------
      log(ID_LOG_HDR, "Invert test with interval = 2.", C_SCOPE);

      -- Reconfigure EI VIPs error injection interval
      shared_ei_config(C_SL_EI_IDX).interval  := 2;
      shared_ei_config(C_SLV_EI_IDX).interval := 2;

      for idx in 3 to 8 loop
        -- Activate SL pulse and set SLV input value on EI VIPs
        run_test(idx);
        wait for 0 ns;                  -- add delta cycle for signal update

        -- Verify output values
        if v_valid_interval then
          log(ID_SEQUENCER, "Verify inverted signal " & to_string(idx - 2) & ".", C_SCOPE);
          check_value(input_sl = not (output_sl), TB_ERROR, "verify SL invert, high period");
          check_value(input_slv = not (output_slv), TB_ERROR, "verify SLV invert");
        else
          log(ID_SEQUENCER, "Verify non inverted signal " & to_string(idx - 2) & ".", C_SCOPE);
          check_value(input_sl = output_sl, TB_ERROR, "verify SL no invert, high period");
          check_value(input_slv = output_slv, TB_ERROR, "verify SLV no invert");
        end if;

        -- wait for SL high period
        wait for C_PULSE_WIDTH;         -- SL high period
        wait for 0 ns;                  -- add delta cycle for signal update

        -- Verify output values
        if v_valid_interval then
          log(ID_SEQUENCER, "Verify inverted signal " & to_string(idx - 2) & ".\n", C_SCOPE);
          check_value(input_sl = not (output_sl), TB_ERROR, "verify SL invert, low period");
          check_value(input_slv = not (output_slv), TB_ERROR, "verify SLV invert");
        else
          log(ID_SEQUENCER, "Verify non inverted signal " & to_string(idx - 2) & ".\n", C_SCOPE);
          check_value(input_sl = output_sl, TB_ERROR, "verify SL no invert, low period");
          check_value(input_slv = output_slv, TB_ERROR, "verify SLV no invert");
        end if;

        wait for C_PULSE_WIDTH;         -- SL low period

        -- Flip next expected interval validity
        v_valid_interval := not (v_valid_interval);
      end loop;

      -- Reset VIPs for next test
      reset_config;
    end procedure test_invert_error_injection;

    --------------------------------------------------------------------
    -- Test case for PULSE error injection
    --
    --    This test will test pulse error injection on a SL and a SLV signal
    --    with defined pulse values and interval settings set to 1 and 2.
    --
    --    Note: test is self checking.
    --------------------------------------------------------------------
    procedure test_pulse_error_injection(void : t_void) is
      variable v_init_delay : time := 7 ns;
      variable v_width      : time := 6 ns;
    begin
      log(ID_LOG_HDR_XL, "Pulse error injection tests");

      -----------------------------------------------------------------
      -- Pulse test
      ----------------------------------------------------------------
      log(ID_LOG_HDR, "Pulse test with pulse start = 7 ns, pulse width = 6 ns, and interval = 1.", C_SCOPE);

      -- Configure SL and SLV EI VIPs
      shared_ei_config(C_SL_EI_IDX).error_type         := PULSE;
      shared_ei_config(C_SL_EI_IDX).initial_delay_min  := v_init_delay;
      shared_ei_config(C_SL_EI_IDX).width_min          := v_width;
      shared_ei_config(C_SLV_EI_IDX).error_type        := PULSE;
      shared_ei_config(C_SLV_EI_IDX).initial_delay_min := v_init_delay;
      shared_ei_config(C_SLV_EI_IDX).width_min         := v_width;

      for idx in 1 to 2 loop
        -- Verify initial values
        check_value(output_sl = '0', TB_ERROR, "verify SL output");
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8) - 1), TB_ERROR, "verify SLV output");

        -- Activate SL pulse and set SLV input value on EI VIPs
        run_test(idx);

        -- Verify output values
        v_timestamp_sl := now;
        wait until output_sl = '1';
        log(ID_SEQUENCER, "Verify normal signal start " & to_string(idx) & ".", C_SCOPE);
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV pre pulse");

        -- Verify output values
        v_timestamp_slv := now;
        wait for v_init_delay;
        log(ID_SEQUENCER, "Verify pulse start " & to_string(idx) & ".", C_SCOPE);
        check_value(output_sl = '0', TB_ERROR, "verify SL pulse set");
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8) - 1), TB_ERROR, "verify SLV pulse set");
        check_value((now - v_timestamp_slv) = v_init_delay, TB_ERROR, "verify pulse init_delay");

        -- Verify output values
        v_timestamp_slv := now;
        wait for v_width;
        log(ID_SEQUENCER, "Verify pulse end " & to_string(idx) & ".", C_SCOPE);
        check_value(output_sl = '1', TB_ERROR, "verify SL pulse done");
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV pulse done");
        check_value((now - v_timestamp_slv) = v_width, TB_ERROR, "verify pulse width");

        -- Verify output values
        wait until output_sl = '0';
        log(ID_SEQUENCER, "Verify signal end " & to_string(idx) & ".\n", C_SCOPE);
        check_value((now - v_timestamp_sl) = C_PULSE_WIDTH, TB_ERROR, "verify SL high period");

        wait for C_PULSE_WIDTH;         -- SL low period
      end loop;

      -----------------------------------------------------------------
      -- Interval tests
      -----------------------------------------------------------------
      log(ID_LOG_HDR, "Pulse test with interval = 2.", C_SCOPE);

      -- Reconfigure EI VIPs error injection interval
      shared_ei_config(C_SL_EI_IDX).interval  := 2;
      shared_ei_config(C_SLV_EI_IDX).interval := 2;

      for idx in 3 to 8 loop
        -- Activate SL pulse and set SLV input value on EI VIPs
        run_test(idx);

        -- Verify output values
        v_timestamp_sl := now;
        wait for 0 ns;
        log(ID_SEQUENCER, "Verify normal signal start " & to_string(idx - 2) & ".", C_SCOPE);
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV pre pulse");

        if v_valid_interval then
          -- Verify output values
          v_timestamp_slv := now;
          wait for v_init_delay;
          log(ID_SEQUENCER, "Verify pulse start " & to_string(idx - 2) & ".", C_SCOPE);
          check_value(output_sl = '0', TB_ERROR, "verify SL pulse set");
          check_value(output_slv, std_logic_vector(to_unsigned(idx, 8) - 1), TB_ERROR, "verify SLV pulse set");
          check_value((now - v_timestamp_slv) = v_init_delay, TB_ERROR, "verify pulse init_delay");

          -- Verify output values
          v_timestamp_slv := now;
          wait for v_width;
          log(ID_SEQUENCER, "Verify pulse end " & to_string(idx - 2) & ".", C_SCOPE);
          check_value(output_sl = '1', TB_ERROR, "verify SL pulse done");
          check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV pulse done");
          check_value((now - v_timestamp_slv) = v_width, TB_ERROR, "verify pulse width");

        else
          log(ID_SEQUENCER, "Verify non pulsed signal " & to_string(idx - 2) & ".", C_SCOPE);
          check_value(input_sl = output_sl, TB_ERROR, "verify SL no pulse, high period");
          check_value(input_slv = output_slv, TB_ERROR, "verify SLV no pulse");
        end if;

        -- Verify output values
        wait until output_sl = '0';
        log(ID_SEQUENCER, "Verify signal end " & to_string(idx - 2) & ".\n", C_SCOPE);
        check_value((now - v_timestamp_sl) = C_PULSE_WIDTH, TB_ERROR, "verify SL high period");

        wait for C_PULSE_WIDTH;         -- SL low period

        -- Flip next expected interval validity
        v_valid_interval := not (v_valid_interval);
      end loop;

      -- Reset VIPs for next test
      reset_config;
    end procedure test_pulse_error_injection;

    --------------------------------------------------------------------
    -- Test case for STUCK_AT_OLD error injection
    --
    --    This test will test stuck at old value error injection on a SL
    --    and a SLV signal, with interval settings set to 1 and 2.
    --
    --    Note: test is self checking.
    --------------------------------------------------------------------
    procedure test_stuck_at_old_error_injection(void : t_void) is
      variable v_width : time := 13 ns;
    begin
      log(ID_LOG_HDR_XL, "Stuck at old error injection test.", C_SCOPE);

      -----------------------------------------------------------------
      -- Stuck at old test
      ----------------------------------------------------------------
      log(ID_LOG_HDR, "Stuck at old test with stuck = 13 ns and interval = 1.", C_SCOPE);

      -- Configure SL and SLV EI VIPs
      shared_ei_config(C_SL_EI_IDX).error_type  := STUCK_AT_OLD;
      shared_ei_config(C_SL_EI_IDX).width_min   := v_width;
      shared_ei_config(C_SLV_EI_IDX).error_type := STUCK_AT_OLD;
      shared_ei_config(C_SLV_EI_IDX).width_min  := v_width;

      for idx in 1 to 2 loop
        -- Verify initial values
        check_value(output_sl = '0', TB_ERROR, "verify SL output");
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8) - 1), TB_ERROR, "verify SLV output");

        -- Activate SL pulse and set SLV input value on EI VIPs
        run_test(idx);

        -- Verify output values
        v_timestamp_sl := now;
        wait until output_sl = '1';
        log(ID_SEQUENCER, "Verify stuck period " & to_string(idx) & ".\n", C_SCOPE);
        check_value((now - v_timestamp_sl) = v_width, TB_ERROR, "verify stuck period");
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV new value");
        check_value(output_slv'last_event = 0 ns, TB_ERROR, "verify SLV updated");

        -- Verify output values
        v_timestamp_sl := now;
        wait until output_sl = '0';
        log(ID_SEQUENCER, "Verify signal duration " & to_string(idx) & ".\n", C_SCOPE);
        check_value((now - v_timestamp_sl) = (C_PULSE_WIDTH - v_width), TB_ERROR, "verify stuck period");

        wait for C_PULSE_WIDTH;         -- SL low period
      end loop;

      -----------------------------------------------------------------
      -- Interval tests
      -----------------------------------------------------------------
      log(ID_LOG_HDR, "Stuck at old test with interval = 2.", C_SCOPE);

      -- Reconfigure EI VIPs error injection interval
      shared_ei_config(C_SL_EI_IDX).interval  := 2;
      shared_ei_config(C_SLV_EI_IDX).interval := 2;

      for idx in 3 to 8 loop
        -- Verify initial values
        check_value(output_sl = '0', TB_ERROR, "verify SL output");
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8) - 1), TB_ERROR, "verify SLV output");

        -- Activate SL pulse and set SLV input value on EI VIPs
        run_test(idx);

        -- Verify output values
        v_timestamp_sl := now;
        wait until output_sl = '1';

        if v_valid_interval then
          log(ID_SEQUENCER, "Verify stuck at old period " & to_string(idx - 2) & ".\n", C_SCOPE);
          check_value((now - v_timestamp_sl) = v_width, TB_ERROR, "verify stuck period");
          check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV new value");
          check_value(output_slv'last_event = 0 ns, TB_ERROR, "verify SLV updated");

        else
          log(ID_SEQUENCER, "Verify not stuck at old " & to_string(idx - 2) & ".\n", C_SCOPE);
          check_value((now - v_timestamp_sl) = 0 ns, TB_ERROR, "verify update period");
          check_value(output_slv'last_event = 0 ns, TB_ERROR, "verify SLV updated");
          check_value(input_sl = output_sl, TB_ERROR, "verify SL no invert, high period");
          check_value(input_slv = output_slv, TB_ERROR, "verify SLV no invert");
        end if;

        -- Verify output values
        wait until output_sl = '0';

        wait for C_PULSE_WIDTH;         -- SL low period

        -- Flip next expected interval validity
        v_valid_interval := not (v_valid_interval);
      end loop;

      -- Reset VIPs for next test
      reset_config;
    end procedure test_stuck_at_old_error_injection;

    --------------------------------------------------------------------
    -- Test case for STUCK_AT_NEW error injection
    --
    --    This test will test stuck at new value error injection on a SL
    --    and a SLV signal, with interval settings set to 1 and 2.
    --
    --    Note: test is self checking.
    --------------------------------------------------------------------
    procedure test_stuck_at_new_error_injection(void : t_void) is
      variable v_slv_stuck_width : time    := 45 ns;
      variable v_sl_stuck_width  : time    := 35 ns;
      variable v_idx             : natural := 0;
    begin
      log(ID_LOG_HDR_XL, "Stuck at new error injection tests");

      -----------------------------------------------------------------
      -- Stuck at new test
      ----------------------------------------------------------------
      log(ID_LOG_HDR, "Stuck at new test with stuck = 35 ns (SL) / 45 ns (SLV) and interval = 1.", C_SCOPE);

      -- Configure SL and SLV EI VIPs
      shared_ei_config(C_SL_EI_IDX).error_type  := STUCK_AT_NEW;
      shared_ei_config(C_SL_EI_IDX).width_min   := v_sl_stuck_width;
      shared_ei_config(C_SLV_EI_IDX).error_type := STUCK_AT_NEW;
      shared_ei_config(C_SLV_EI_IDX).width_min  := v_slv_stuck_width;

      -- Verify initial values
      check_value(output_sl, '0', TB_ERROR, "verify SL initial value");
      check_value(output_slv, x"00", TB_ERROR, "verify SLV initial value");

      --------
      -- # 1
      --   SL valid interval
      --   SLV valid interval
      --------
      -- Activate SL pulse and set SLV input value on EI VIPs
      v_idx := 1;
      run_test(v_idx);
      log(ID_SEQUENCER, "Verify stuck periods, valid interval for SL and SLV " & to_string(v_idx) & ".\n", C_SCOPE);

      -- Verify output values
      wait until output_sl = '1';
      v_timestamp_sl  := now;
      v_timestamp_slv := now;
      check_value(output_slv, std_logic_vector(to_unsigned(v_idx, 8)), TB_ERROR, "verify SLV value " & to_string(v_idx));

      -- Verify output values
      wait until output_sl = '0';
      check_value((now - v_timestamp_sl), v_sl_stuck_width, TB_ERROR, "verify SL stuck width");
      check_value(output_slv, std_logic_vector(to_unsigned(v_idx, 8)), TB_ERROR, "verify SLV value " & to_string(v_idx));

      wait for 2 * C_PULSE_WIDTH - v_sl_stuck_width; -- SL low period

      --------
      -- # 2:
      --   SL valid interval
      --   SLV initial event is during stuck period and not detected for this run
      --------
      v_idx := 2;
      -- Activate SL pulse and set SLV input value on EI VIPs
      run_test(v_idx);
      log(ID_SEQUENCER, "Verify stuck periods, valid interval for SL " & to_string(v_idx) & ".\n", C_SCOPE);

      -- Verify output values
      v_timestamp_sl := now;
      wait until output_sl = '1';
      check_value(output_slv, std_logic_vector(to_unsigned(v_idx - 1, 8)), TB_ERROR, "verify SLV value still at previous");

      -- Verify SLV output value
      wait until output_slv = std_logic_vector(to_unsigned(v_idx, 8));
      check_value((now - v_timestamp_slv), v_slv_stuck_width, TB_ERROR, "verify SLV stuck period " & to_string(v_idx));

      -- Verify output values
      v_timestamp_slv := now;
      wait until output_sl = '0';
      check_value((now - v_timestamp_sl), v_sl_stuck_width, TB_ERROR, "verify SL stuck width");
      check_value(output_slv, std_logic_vector(to_unsigned(v_idx, 8)), TB_ERROR, "verify SLV value " & to_string(v_idx));

      -----------------------------------------------------------------
      -- Interval tests
      -----------------------------------------------------------------
      log(ID_LOG_HDR, "Stuck at new test with interval = 2.", C_SCOPE);

      -- Reconfigure EI VIPs error injection interval
      shared_ei_config(C_SL_EI_IDX).interval  := 2;
      shared_ei_config(C_SLV_EI_IDX).interval := 2;

      -- wait remaining SL low period
      wait for (2 * C_PULSE_WIDTH) - v_sl_stuck_width;

      --------
      -- # 3
      --   SL valid interval
      --   SLV valid interval
      --------
      v_idx           := 3;
      -- Activate SL pulse and set SLV input value on EI VIPs
      run_test(v_idx);
      log(ID_SEQUENCER, "Verify stuck periods, valid interval for SL and SLV " & to_string(v_idx) & ".\n", C_SCOPE);
      -- Verify output values
      v_timestamp_sl  := now;
      v_timestamp_slv := now;
      wait until output_sl = '1';
      check_value(output_slv, std_logic_vector(to_unsigned(v_idx, 8)), TB_ERROR, "verify SLV value " & to_string(v_idx));

      wait until output_sl = '0';
      check_value(now - v_timestamp_sl, v_sl_stuck_width, TB_ERROR, "verify SL stuck width");
      check_value(output_slv, std_logic_vector(to_unsigned(v_idx, 8)), TB_ERROR, "verify SLV value " & to_string(v_idx));

      -- wait remaining SL low period
      wait for (2 * C_PULSE_WIDTH) - v_sl_stuck_width;

      --------
      -- # 4
      --   SL not valid interval
      --   SLV initial event is during stuck period and not detected for this run
      --------
      v_idx := 4;
      -- Activate SL pulse and set SLV input value on EI VIPs
      run_test(v_idx);
      log(ID_SEQUENCER, "Verify stuck periods, valid interval for SL " & to_string(v_idx) & ".\n", C_SCOPE);

      -- Verify output values
      v_timestamp_sl := now;
      wait until output_sl = '1';
      check_value(output_slv, std_logic_vector(to_unsigned(v_idx - 1, 8)), TB_ERROR, "verify SLV value still at previous");

      -- Verify output values
      wait until output_slv = std_logic_vector(to_unsigned(v_idx, 8));
      check_value(now - v_timestamp_slv, v_slv_stuck_width, TB_ERROR, "verify SLV stuck width");
      v_timestamp_slv := now;

      -- Verify output values
      wait until output_sl = '0';
      check_value(now - v_timestamp_sl, C_PULSE_WIDTH, TB_ERROR, "verify SL high period");

      -- wait SL low period
      wait for C_PULSE_WIDTH;

      --------
      -- # 5
      --   SL valid interval
      --   SLV not valid interval
      --------
      v_idx := 5;
      -- Activate SL pulse and set SLV input value on EI VIPs
      run_test(v_idx);
      log(ID_SEQUENCER, "Verify stuck periods, valid interval for SL " & to_string(v_idx) & ".\n", C_SCOPE);

      -- Timing timestamps
      v_timestamp_sl  := now;
      v_timestamp_slv := now;

      -- Verify output values
      wait until output_sl = '1';
      check_value(output_slv, std_logic_vector(to_unsigned(v_idx, 8)), TB_ERROR, "verify SLV value " & to_string(v_idx));

      -- Verify output values
      wait until output_sl = '0';
      check_value(output_slv, std_logic_vector(to_unsigned(v_idx, 8)), TB_ERROR, "verify SLV value " & to_string(v_idx));
      check_value(now - v_timestamp_sl, v_sl_stuck_width, TB_ERROR, "verify SL stuck width");

      -- wait remaining SL low period
      wait for (2 * C_PULSE_WIDTH) - v_sl_stuck_width;

      --------
      -- # 6
      --   SL not valid interval
      --   SLV valid interval
      --------
      v_idx := 6;
      -- Activate SL pulse and set SLV input value on EI VIPs
      run_test(v_idx);
      log(ID_SEQUENCER, "Verify stuck periods, valid interval for SLV " & to_string(v_idx) & ".\n", C_SCOPE);

      -- Timing timestamps
      v_timestamp_sl  := now;
      v_timestamp_slv := now;
      wait until output_sl = '1';
      check_value(output_slv, std_logic_vector(to_unsigned(v_idx, 8)), TB_ERROR, "verify SLV value " & to_string(v_idx));

      wait until output_sl = '0';
      check_value(now - v_timestamp_sl, C_PULSE_WIDTH, TB_ERROR, "verify SL high period");
      check_value(output_slv, std_logic_vector(to_unsigned(v_idx, 8)), TB_ERROR, "verify SLV value " & to_string(v_idx));

      -- wait remaining SL low period
      wait for C_PULSE_WIDTH;

      --------
      -- # 7
      --   SL valid interval
      --   SLV initial event is during stuck period and not detected for this run
      --------
      v_idx := 7;
      -- Activate SL pulse and set SLV input value on EI VIPs
      run_test(v_idx);
      log(ID_SEQUENCER, "Verify stuck periods, valid interval for SL " & to_string(v_idx) & ".\n", C_SCOPE);

      -- Timing timestamps
      v_timestamp_sl := now;
      wait until output_sl = '1';
      check_value(output_slv, std_logic_vector(to_unsigned(v_idx - 1, 8)), TB_ERROR, "verify SLV value still at previous");

      wait until output_slv = std_logic_vector(to_unsigned(v_idx, 8));
      check_value(now - v_timestamp_slv, v_slv_stuck_width, TB_ERROR, "verify SLV stuck width");
      v_timestamp_slv := now;

      wait until output_sl = '0';
      check_value(now - v_timestamp_sl, v_sl_stuck_width, TB_ERROR, "verify SL stuck width");

      -- wait remaining SL low period
      wait for (2 * C_PULSE_WIDTH) - v_sl_stuck_width;

      -- Reset VIPs for next test
      reset_config;
    end procedure test_stuck_at_new_error_injection;

    --------------------------------------------------------------------
    -- Test case for BYPASS error injection
    --
    --    This test will test bypass setting for error injection on a SL
    --    and a SLV signal, i.e. no error is injected.
    --
    --    Note: test is self checking.
    --------------------------------------------------------------------
    procedure test_bypass_error_injection(void : t_void) is
    begin
      log(ID_LOG_HDR_XL, "Bypass error injection tests");

      -----------------------------------------------------------------
      -- Stuck at new test
      ----------------------------------------------------------------
      log(ID_LOG_HDR, "Bypass test and interval = 1.", C_SCOPE);

      -- Configure SL and SLV EI VIPs
      shared_ei_config(C_SL_EI_IDX)  := C_EI_CONFIG_DEFAULT;
      shared_ei_config(C_SLV_EI_IDX) := C_EI_CONFIG_DEFAULT;

      for idx in 1 to 8 loop
        -- Verify initial values
        check_value(output_sl = '0', TB_ERROR, "verify SL output");
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8) - 1), TB_ERROR, "verify SLV output");

        -- Activate SL pulse and set SLV input value on EI VIPs
        run_test(idx);

        -- Timing timestamps
        v_timestamp_sl := now;

        wait until output_sl = '1';
        log(ID_SEQUENCER, "Verify SLV on SL high period " & to_string(idx) & ".\n", C_SCOPE);
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV output");

        wait until output_sl = '0';
        log(ID_SEQUENCER, "Verify SLV on SL low period and width " & to_string(idx) & ".\n", C_SCOPE);
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV output");
        check_value((now - v_timestamp_sl) = C_PULSE_WIDTH, TB_ERROR, "verify pulse width");

        wait for C_PULSE_WIDTH;         -- SL low period
      end loop;

      -- Reset VIPs for next test
      reset_config;
    end procedure test_bypass_error_injection;

  begin
    -- Wait for UVVM to finish initialization
    await_uvvm_initialization(VOID);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    set_alert_stop_limit(TB_ERROR, 1);
    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_LOG_HDR_XL);
    enable_log_msg(ID_SEQUENCER_SUB);

    log(ID_LOG_HDR, "Starting simulation of Error Injection VIP TB.", C_SCOPE);
    --============================================================================================================
    --
    -- Note!
    --
    -- 1. Tests can be commented out to run single tests
    --
    -- 2. Tests are run with 8 signal events, and error injection with interval set to 1 on
    --    the two first signal events, then reconfigured with interval set to 2 on the remaining
    --    sixs signal events.
    --
    -- 3. Randomisation setting is tested in test_delay_error_injection().
    --

    test_delay_error_injection(VOID);   -- with randomisation
    test_jitter_error_injection(VOID);
    test_invert_error_injection(VOID);
    test_pulse_error_injection(VOID);
    test_stuck_at_old_error_injection(VOID);
    test_stuck_at_new_error_injection(VOID);
    test_bypass_error_injection(VOID);

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;                   -- to allow some time for completion
    report_alert_counters(FINAL);       -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely
  end process p_sequencer;

end func;
