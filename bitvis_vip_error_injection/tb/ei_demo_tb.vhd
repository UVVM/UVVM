library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_error_injection;
use bitvis_vip_error_injection.error_injection_pkg.all;

entity ei_demo_tb is
end entity ei_demo_tb;


architecture func of ei_demo_tb is

  constant C_SCOPE              : string  := "EI_DEMO_TB";
  constant C_SL_EI_IDX          : natural := 1;
  constant C_SLV_EI_IDX         : natural := 2;
  constant C_DATA_WIDTH         : natural := 8;
  constant C_SL_SIGNAL_DEFAULT  : std_logic := '0';
  constant C_SLV_SIGNAL_DEFAULT : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
  constant C_PULSE_WIDTH        : time := 20 ns;

  -- Error Injection VIPs input/output signals
  -- std_logic
  signal output_sl              : std_logic := C_SL_SIGNAL_DEFAULT;
  signal input_sl               : std_logic := '0';
  -- vector
  signal input_slv              : std_logic_vector(C_DATA_WIDTH-1 downto 0) := x"00";
  signal output_slv             : std_logic_vector(C_DATA_WIDTH-1 downto 0) := C_SLV_SIGNAL_DEFAULT;


  begin

  -----------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;


  -----------------------------------------------------------------------------
  -- Error injector
  -----------------------------------------------------------------------------
  error_injector_sl: entity work.error_injection_sl
    generic map (
      GC_INSTANCE_IDX   => 1
    )
    port map (
      ei_in   => input_sl,
      ei_out  => output_sl
    );

  error_injector_slv: entity work.error_injection_slv
    generic map (
      GC_INSTANCE_IDX   => 2
    )
    port map (
      ei_in   => input_slv,
      ei_out  => output_slv
    );



  -----------------------------------------------------------------------------
  -- Testbench sequencer
  -----------------------------------------------------------------------------
  p_sequencer : process
    variable v_timestamp_sl       : time;
    variable v_timestamp_slv      : time;
    variable v_valid_interval     : boolean := true;



    procedure run_test(slv_value : integer) is
    begin
      input_slv <= std_logic_vector(to_unsigned(slv_value, C_DATA_WIDTH));
      gen_pulse(input_sl, C_PULSE_WIDTH, NON_BLOCKING, "pulsing SL");
    end procedure run_test;

    procedure reset_config is
    begin
      shared_ei_config(C_SL_EI_IDX)   := C_EI_CONFIG_DEFAULT;
      shared_ei_config(C_SLV_EI_IDX)  := C_EI_CONFIG_DEFAULT;
      run_test(0);
      wait for 100 ns;
    end procedure reset_config;


    ------------------------------------------------------------------
    -- Test declarations
    ------------------------------------------------------------------

    --
    -- Test case for DELAY error innjection
    --
    procedure delay_test(void : t_void) is
      variable v_init_delay   : time := 7 ns;
    begin
      log(ID_LOG_HDR, "Delay error injection tests");

      -----------------------------------------------------------------
      -- Delay and interval  tests
      -----------------------------------------------------------------
      log(ID_SEQUENCER, "Delay test, interval = 1", C_SCOPE);
      shared_ei_config(C_SL_EI_IDX).error_type        := DELAY;
      shared_ei_config(C_SL_EI_IDX).initial_delay_min := v_init_delay;
      shared_ei_config(C_SL_EI_IDX).interval          := 1;

      shared_ei_config(C_SLV_EI_IDX).error_type        := DELAY;
      shared_ei_config(C_SLV_EI_IDX).initial_delay_min := v_init_delay;
      shared_ei_config(C_SLV_EI_IDX).interval          := 1;

      for idx in 1 to 2 loop
        log(ID_SEQUENCER_SUB, "Delay test, idx="&to_string(idx), C_SCOPE);

        check_value(output_sl = '0', TB_ERROR, "verify SL output");
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8) - 1), TB_ERROR, "verify SLV output");

        run_test(idx);

        wait until output_sl = '1';
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV delayed output");

        check_value(input_sl'last_event - output_sl'last_event = v_init_delay, TB_ERROR, "check SL initial delay time");
        check_value(input_slv'last_event - output_slv'last_event = v_init_delay, TB_ERROR, "check SLV initial delay time");

        -- SL only part
        wait until output_sl = '0';
        check_value(input_sl'last_event - output_sl'last_event = v_init_delay, TB_ERROR, "verify SL return delay time");
        wait for C_PULSE_WIDTH - v_init_delay; -- SL low period
      end loop;


      log(ID_SEQUENCER, "Reconfigure, interval=2, signal_periods=5", C_SCOPE);
      shared_ei_config(C_SL_EI_IDX).interval  := 2;
      shared_ei_config(C_SLV_EI_IDX).interval := 2;


      for idx in 3 to 8 loop
        log(ID_SEQUENCER_SUB, "Delay interval test, idx="&to_string(idx)&", valid interval=" & to_string(v_valid_interval), C_SCOPE);

        run_test(idx);

        wait until output_sl = '1';
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV output");

        if v_valid_interval then
          check_value(input_sl'last_event - output_sl'last_event = v_init_delay, TB_ERROR, "check SL delay time");
          check_value(input_slv'last_event - output_slv'last_event = v_init_delay, TB_ERROR, "check SLV delay time");
        else
          check_value(input_sl'last_event - output_sl'last_event = 0 ns, TB_ERROR, "check SL no delay time");
          check_value(input_slv'last_event - output_slv'last_event = 0 ns, TB_ERROR, "check SLV delay time");
        end if;

        -- SL only part
        v_timestamp_sl := now;
        wait until output_sl = '0';
        check_value(output_sl = '0', TB_ERROR, "verify SL low");
        check_value( (now - v_timestamp_sl) = C_PULSE_WIDTH, TB_ERROR, "verify SL high period");

        if v_valid_interval then
          check_value(input_sl'last_event - output_sl'last_event = v_init_delay, TB_ERROR, "check SL delay time");
          wait for C_PULSE_WIDTH - v_init_delay;
        else
          check_value(input_sl'last_event - output_sl'last_event = 0 ns, TB_ERROR, "check SL no delay time");
          wait for C_PULSE_WIDTH; -- low period
        end if;

        v_valid_interval := not(v_valid_interval);
      end loop;
      reset_config;

      -----------------------------------------------------------------
      -- Random delay tests
      -----------------------------------------------------------------
      log(ID_SEQUENCER, "SL random delay test", C_SCOPE);
      wait for 10 ns;

      shared_ei_config(C_SL_EI_IDX).error_type        := DELAY;
      shared_ei_config(C_SL_EI_IDX).initial_delay_min := 1 ns;
      shared_ei_config(C_SL_EI_IDX).initial_delay_max := 10 ns;
      shared_ei_config(C_SL_EI_IDX).interval          := 1;

      for idx in 1 to 2 loop
        log(ID_SEQUENCER, "Setting pulse " & to_string(idx), C_SCOPE);
        check_value(output_sl = '0', TB_ERROR, "check SL delayed output");

        run_test(idx);

        wait until output_sl = '1';
        check_value(input_sl'last_event - output_sl'last_event < 11 ns, TB_ERROR, "check SL delay time");

        wait until output_sl = '0';
        check_value(input_sl'last_event - output_sl'last_event < 11 ns, TB_ERROR, "verify SL delay time");
        wait for 20 ns; -- low period
      end loop;

      reset_config;
    end procedure delay_test;



    --
    -- Test cases for JITTER error injections
    --
    procedure jitter_test(void : t_void) is
      variable v_init_delay   : time := 7 ns;
      variable v_return_delay : time := 3 ns;

    begin
      log(ID_LOG_HDR, "Jitter error injection tests");

      -- Testing with interval=1, 2 signal periods
      log(ID_SEQUENCER, "QR example testing SL/SLV JITTER, 7 ns - 3 ns. Interval=1, signal periods=2", C_SCOPE);
      shared_ei_config(C_SL_EI_IDX).error_type          := JITTER;
      shared_ei_config(C_SL_EI_IDX).initial_delay_min   := v_init_delay;
      shared_ei_config(C_SL_EI_IDX).return_delay_min    := v_return_delay;
      shared_ei_config(C_SLV_EI_IDX).error_type         := JITTER; -- SLV jitter not supported!
      shared_ei_config(C_SLV_EI_IDX).initial_delay_min  := v_init_delay;

      for idx in 1 to 2 loop
        log(ID_SEQUENCER_SUB, "Jitter test, idx="&to_string(idx), C_SCOPE);

        check_value(output_sl = '0', TB_ERROR, "verify SL output");
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8) - 1), TB_ERROR, "verify SLV output");

        run_test(idx);

        wait until output_sl = '1';
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV output");
        check_value(input_sl'last_event - output_sl'last_event = v_init_delay, TB_ERROR, "check SL initial delay time");
        check_value(output_slv'last_event = input_slv'last_event, TB_ERROR, "check SLV static");

        -- SL only part
        wait until output_sl = '0';
        check_value(input_sl'last_event - output_sl'last_event = v_return_delay, TB_ERROR, "verify SL return delay time");
        wait for C_PULSE_WIDTH; -- SL low period
      end loop;


      log(ID_SEQUENCER, "Reconfigure, interval=2, signal_periods=5", C_SCOPE);
      shared_ei_config(C_SL_EI_IDX).interval  := 2;
      shared_ei_config(C_SLV_EI_IDX).interval := 2;


      for idx in 3 to 8 loop
        log(ID_SEQUENCER_SUB, "Jitter interval test, idx="&to_string(idx)&", valid interval=" & to_string(v_valid_interval), C_SCOPE);

        run_test(idx);

        wait until output_sl = '1';
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV output");

        if v_valid_interval then
          check_value(input_sl'last_event - output_sl'last_event = v_init_delay, TB_ERROR, "check SL delay time");
          check_value(output_slv'last_event - input_slv'last_event = 0 ns, TB_ERROR, "check SLV static");
        else
          check_value(input_sl'last_event - output_sl'last_event = 0 ns, TB_ERROR, "check SL no delay time");
          check_value(input_slv'last_event - output_slv'last_event = 0 ns, TB_ERROR, "check SLV delay time");
        end if;

        -- SL only part
        v_timestamp_sl := now;
        wait until output_sl = '0';
        check_value(output_sl = '0', TB_ERROR, "verify SL low");


        if v_valid_interval then
          check_value( (now - v_timestamp_sl) = (C_PULSE_WIDTH - v_init_delay + v_return_delay), TB_ERROR, "verify SL high period");
          check_value(input_sl'last_event - output_sl'last_event = v_return_delay, TB_ERROR, "check SL delay time");
          wait for C_PULSE_WIDTH - v_return_delay;
        else
          check_value( (now - v_timestamp_sl) = C_PULSE_WIDTH, TB_ERROR, "verify SL high period");
          check_value(input_sl'last_event - output_sl'last_event = 0 ns, TB_ERROR, "check SL no delay time");
          wait for C_PULSE_WIDTH; -- low period
        end if;

        v_valid_interval := not(v_valid_interval);
      end loop;
      reset_config;
    end procedure jitter_test;



    --
    -- Test case for INVERT error injection
    --
    procedure invert_test(void : t_void) is
    begin
      log(ID_LOG_HDR, "Invert error injection tests");

      -- Testing with interval=1, 2 signal periods
      log(ID_SEQUENCER, "QR example testing SL/SLV INVERT. Interval=1, signal periods=2", C_SCOPE);
      shared_ei_config(C_SL_EI_IDX).error_type  := INVERT;
      shared_ei_config(C_SLV_EI_IDX).error_type := INVERT;

      for idx in 1 to 2 loop
        log(ID_SEQUENCER_SUB, "Invert test, idx="&to_string(idx), C_SCOPE);

        run_test(idx);

        wait on output_sl;
        check_value(input_sl = not(output_sl), TB_ERROR, "verify SL invert");
        check_value(input_slv = not(output_slv), TB_ERROR, "verify SLV invert");
        wait for C_PULSE_WIDTH; -- SL low period
      end loop;



      log(ID_SEQUENCER, "Reconfigure, interval=2, signal_periods=5", C_SCOPE);
      shared_ei_config(C_SL_EI_IDX).interval  := 2;
      shared_ei_config(C_SLV_EI_IDX).interval := 2;
      wait for C_PULSE_WIDTH;

      for idx in 3 to 8 loop
        log(ID_SEQUENCER_SUB, "Invert test, idx="&to_string(idx), C_SCOPE);

        run_test(idx);
        wait for 0 ns;

        if v_valid_interval then
          check_value(input_sl = not(output_sl), TB_ERROR, "verify SL invert, high period");
          check_value(input_slv = not(output_slv), TB_ERROR, "verify SLV invert");
        else
          check_value(input_sl = output_sl, TB_ERROR, "verify SL no invert, high period");
          check_value(input_slv = output_slv, TB_ERROR, "verify SLV no invert");
        end if;

        wait for C_PULSE_WIDTH; -- SL high period
        wait for 0 ns;

        if v_valid_interval then
          check_value(input_sl = not(output_sl), TB_ERROR, "verify SL invert, low period");
          check_value(input_slv = not(output_slv), TB_ERROR, "verify SLV invert");
        else
          check_value(input_sl = output_sl, TB_ERROR, "verify SL no invert, low period");
          check_value(input_slv = output_slv, TB_ERROR, "verify SLV no invert");
        end if;

        wait for C_PULSE_WIDTH; -- SL low period

        v_valid_interval := not(v_valid_interval);
      end loop;

      reset_config;
    end procedure invert_test;



    --
    -- Test case for PULSE error injection
    --
    procedure pulse_test(void : t_void) is
      variable v_init_delay   : time := 7 ns;
      variable v_width        : time := 6 ns;
    begin
      log(ID_LOG_HDR, "Pulse error injection tests");

      -- Testing with interval=1, 2 signal periods
      log(ID_SEQUENCER, "QR example testing SL/SLV PULSE. Interval=1", C_SCOPE);
      shared_ei_config(C_SL_EI_IDX).error_type          := PULSE;
      shared_ei_config(C_SL_EI_IDX).initial_delay_min   := v_init_delay;
      shared_ei_config(C_SL_EI_IDX).width_min           := v_width;
      shared_ei_config(C_SLV_EI_IDX).error_type         := PULSE;
      shared_ei_config(C_SLV_EI_IDX).initial_delay_min  := v_init_delay;
      shared_ei_config(C_SLV_EI_IDX).width_min          := v_width;

      for idx in 1 to 2 loop
        log(ID_SEQUENCER_SUB, "Pulse test, idx="&to_string(idx), C_SCOPE);

        check_value(output_sl = '0', TB_ERROR, "verify SL output");
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8) - 1), TB_ERROR, "verify SLV output");

        run_test(idx);

        v_timestamp_sl := now;
        -- SL high period start
        wait until output_sl = '1';
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV pre pulse");

        v_timestamp_slv := now;
        wait for v_init_delay;
        check_value(output_sl = '0', TB_ERROR, "verify SL pulse set");
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)-1), TB_ERROR, "verify SLV pulse set");
        check_value( (now - v_timestamp_slv) = v_init_delay, TB_ERROR, "verify pulse init_delay");

        v_timestamp_slv := now;
        wait for v_width;
        check_value(output_sl = '1', TB_ERROR, "verify SL pulse done");
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV pulse done");
        check_value( (now - v_timestamp_slv) = v_width, TB_ERROR, "verify pulse width");

        wait until output_sl = '0';
        check_value( (now - v_timestamp_sl) = C_PULSE_WIDTH, TB_ERROR, "verify SL high period");

        wait for C_PULSE_WIDTH; -- SL low period
      end loop;



      log(ID_SEQUENCER, "Reconfigure, interval=2, signal_periods=5", C_SCOPE);
      shared_ei_config(C_SL_EI_IDX).interval  := 2;
      shared_ei_config(C_SLV_EI_IDX).interval := 2;
      wait for C_PULSE_WIDTH;

      for idx in 3 to 8 loop
        log(ID_SEQUENCER_SUB, "Pulse test, idx="&to_string(idx), C_SCOPE);

        run_test(idx);
        v_timestamp_sl := now;
        wait for 0 ns;
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV pre pulse");

        if v_valid_interval then
          v_timestamp_slv := now;
          wait for v_init_delay;
          check_value(output_sl = '0', TB_ERROR, "verify SL pulse set");
          check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)-1), TB_ERROR, "verify SLV pulse set");
          check_value((now - v_timestamp_slv) = v_init_delay, TB_ERROR, "verify pulse init_delay");

          v_timestamp_slv := now;
          wait for v_width;
          check_value(output_sl = '1', TB_ERROR, "verify SL pulse done");
          check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV pulse done");
          check_value((now - v_timestamp_slv) = v_width, TB_ERROR, "verify pulse width");
        else
          check_value(input_sl = output_sl, TB_ERROR, "verify SL no invert, high period");
          check_value(input_slv = output_slv, TB_ERROR, "verify SLV no invert");
        end if;

        wait until output_sl = '0';
        check_value( (now - v_timestamp_sl) = C_PULSE_WIDTH, TB_ERROR, "verify SL high period");

        wait for C_PULSE_WIDTH; -- SL low period

        v_valid_interval := not(v_valid_interval);
      end loop;

      reset_config;
    end procedure pulse_test;


    procedure stuck_at_old_test(void : t_void) is
      variable v_width : time := 13 ns;
    begin
      log(ID_LOG_HDR, "Stuck at old error injection tests");

      -- Testing with interval=1, 2 signal periods
      log(ID_SEQUENCER, "QR example testing SL/SLV STUCK_AT_OLD, 13 ns. Interval=1, signal periods=2", C_SCOPE);
      shared_ei_config(C_SL_EI_IDX).error_type  := STUCK_AT_OLD;
      shared_ei_config(C_SL_EI_IDX).width_min   := v_width;
      shared_ei_config(C_SLV_EI_IDX).error_type := STUCK_AT_OLD;
      shared_ei_config(C_SLV_EI_IDX).width_min  := v_width;

      for idx in 1 to 2 loop
        log(ID_SEQUENCER_SUB, "Stuck_at_old test, idx="&to_string(idx), C_SCOPE);

        check_value(output_sl = '0', TB_ERROR, "verify SL output");
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8) - 1), TB_ERROR, "verify SLV output");

        run_test(idx);

        v_timestamp_sl := now;
        wait until output_sl = '1';
        check_value((now-v_timestamp_sl) = v_width, TB_ERROR, "verify stuck period");
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV new value");
        check_value(output_slv'last_event = 0 ns, TB_ERROR, "verify SLV updated");

        v_timestamp_sl := now;
        wait until output_sl = '0';
        check_value((now-v_timestamp_sl) = (C_PULSE_WIDTH - v_width), TB_ERROR, "verify stuck period");

        wait for C_PULSE_WIDTH; -- SL low period
      end loop;


      log(ID_SEQUENCER, "Reconfigure, interval=2, signal_periods=5", C_SCOPE);
      shared_ei_config(C_SL_EI_IDX).interval  := 2;
      shared_ei_config(C_SLV_EI_IDX).interval := 2;

      for idx in 3 to 8 loop
        log(ID_SEQUENCER_SUB, "Stuck_at_old test, idx="&to_string(idx), C_SCOPE);

        check_value(output_sl = '0', TB_ERROR, "verify SL output");
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8) - 1), TB_ERROR, "verify SLV output");

        run_test(idx);

        v_timestamp_sl := now;
        wait until output_sl = '1';

        if v_valid_interval then
          check_value((now-v_timestamp_sl) = v_width, TB_ERROR, "verify stuck period");
          check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV new value");
          check_value(output_slv'last_event = 0 ns, TB_ERROR, "verify SLV updated");
        else
          check_value((now-v_timestamp_sl) = 0 ns, TB_ERROR, "verify update period");
          check_value(output_slv'last_event = 0 ns, TB_ERROR, "verify SLV updated");
          check_value(input_sl = output_sl, TB_ERROR, "verify SL no invert, high period");
          check_value(input_slv = output_slv, TB_ERROR, "verify SLV no invert");
        end if;

        wait until output_sl = '0';

        wait for C_PULSE_WIDTH; -- SL low period

        v_valid_interval := not(v_valid_interval);
      end loop;
      reset_config;
    end procedure stuck_at_old_test;



    procedure stuck_at_new_test(void : t_void) is
      variable v_slv_stuck_width  : time := 45 ns;
      variable v_sl_stuck_width   : time := 35 ns;
      variable v_input            : integer := 0;
    begin
      log(ID_LOG_HDR, "Pulse error injection tests");

      -- Testing with interval=1, 2 signal periods
      log(ID_SEQUENCER, "QR example testing SL/SLV STUCK_AT_NEW. Interval=1, signal periods=2", C_SCOPE);
      shared_ei_config(C_SL_EI_IDX).error_type  := STUCK_AT_NEW;
      shared_ei_config(C_SL_EI_IDX).width_min   := v_sl_stuck_width;
      shared_ei_config(C_SLV_EI_IDX).error_type := STUCK_AT_NEW;
      shared_ei_config(C_SLV_EI_IDX).width_min  := v_slv_stuck_width;


      check_value(output_sl, '0', TB_ERROR, "verify SL initial value");
      check_value(output_slv, x"00", TB_ERROR, "verify SLV initial value");

      --------
      -- # 1
      --   SL valid interval
      --   SLV valid interval
      --------
      run_test(1);
      wait until output_sl = '1';
      v_timestamp_sl  := now;
      v_timestamp_slv := now;

      check_value(output_slv, x"01", TB_ERROR, "verify SLV value 1");
      wait until output_sl = '0';
      check_value((now - v_timestamp_sl), v_sl_stuck_width, TB_ERROR, "verify SL stuck width");
      check_value(output_slv, x"01", TB_ERROR, "verify SLV value 1");

      wait for 2*C_PULSE_WIDTH - v_sl_stuck_width; -- SL low period

      --------
      -- # 2:
      --   SL valid interval
      --   SLV initial event is during stuck period and ont detected for this run
      --------
      run_test(2);
      v_timestamp_sl := now;
      wait until output_sl = '1';
      check_value(output_slv, x"01", TB_ERROR, "verify SLV value 1");

      wait until output_slv = x"02";
      check_value((now-v_timestamp_slv), v_slv_stuck_width, TB_ERROR, "verify SLV stuck period 1");
      v_timestamp_slv := now;

      wait until output_sl = '0';
      check_value((now - v_timestamp_sl), v_sl_stuck_width, TB_ERROR, "verify SL stuck width");
      check_value(output_slv, x"02", TB_ERROR, "verify SLV value 1");

      -- Reconfigure
      log(ID_SEQUENCER, "Reconfigure interval=2", C_SCOPE);
      shared_ei_config(C_SL_EI_IDX).interval  := 2;
      shared_ei_config(C_SLV_EI_IDX).interval := 2;

      -- wait remaining SL low period
      wait for (2*C_PULSE_WIDTH) - v_sl_stuck_width;

      --------
      -- # 3
      --   SL valid interval
      --   SLV valid interval
      --------
      run_test(3);
      v_timestamp_sl := now;
      v_timestamp_slv := now;
      wait until output_sl = '1';
      check_value(output_slv, x"03", TB_ERROR, "verify SLV value 3");

      wait until output_sl = '0';
      check_value(now-v_timestamp_sl, v_sl_stuck_width,  TB_ERROR, "verify SL stuck width");
      check_value(output_slv, x"03", TB_ERROR, "verify SLV value 3");

      -- wait remaining SL low period
      wait for (2*C_PULSE_WIDTH) - v_sl_stuck_width;

      --------
      -- # 4
      --   SL not valid interval
      --   SLV initial event is during stuck period and ont detected for this run
      --------
      run_test(4);
      v_timestamp_sl  := now;
      wait until output_sl = '1';
      check_value(output_slv, x"03", TB_ERROR, "verify SLV value 3");
      wait until output_slv = x"04";
      check_value(now - v_timestamp_slv, v_slv_stuck_width, TB_ERROR, "verify SLV stuck width");
      v_timestamp_slv := now;
      wait until output_sl = '0';
      check_value(now-v_timestamp_sl, C_PULSE_WIDTH, TB_ERROR, "verify SL high period");

      -- wait SL low period
      wait for C_PULSE_WIDTH;

      --------
      -- # 5
      --   SL valid interval
      --   SLV not valid interval
      --------
      run_test(5);
      v_timestamp_sl  := now;
      v_timestamp_slv := now;
      wait until output_sl = '1';
      check_value(output_slv, x"05", TB_ERROR, "verify SLV value 5");

      wait until output_sl = '0';
      check_value(output_slv, x"05", TB_ERROR, "verify SLV value 5");
      check_value(now-v_timestamp_sl, v_sl_stuck_width, TB_ERROR, "verify SL stuck width");

      -- wait remaining SL low period
      wait for (2*C_PULSE_WIDTH) - v_sl_stuck_width;

      --------
      -- # 6
      --   SL not valid interval
      --   SLV valid interval
      --------
      run_test(6);
      v_timestamp_sl := now;
      v_timestamp_slv := now;
      wait until output_sl = '1';
      check_value(output_slv, x"06", TB_ERROR, "verify SLV value 6");

      wait until output_sl = '0';
      check_value(now-v_timestamp_sl, C_PULSE_WIDTH,  TB_ERROR, "verify SL high period");
      check_value(output_slv, x"06", TB_ERROR, "verify SLV value 6");

      -- wait remaining SL low period
      wait for C_PULSE_WIDTH;


      --------
      -- # 7
      --   SL valid interval
      --   SLV initial event is during stuck period and ont detected for this run
      --------
      run_test(7);
      v_timestamp_sl  := now;
      wait until output_sl = '1';
      check_value(output_slv, x"06", TB_ERROR, "verify SLV value 6");

      wait until output_slv = x"07";
      check_value(now-v_timestamp_slv, v_slv_stuck_width, TB_ERROR, "verify SLV stuck width");
      v_timestamp_slv := now;

      wait until output_sl = '0';
      check_value(now-v_timestamp_sl, v_sl_stuck_width, TB_ERROR, "verify SL stuck width");

      -- wait remaining SL low period
      wait for (2*C_PULSE_WIDTH) - v_sl_stuck_width;


      --------
      -- # 8
      --   SL not valid interval
      --   SLV valid interval
      --------
      run_test(8);
      v_timestamp_sl  := now;
      wait until output_sl = '1';

      wait until output_sl = '0';

      -- wait remaining SL low period
      wait for C_PULSE_WIDTH;


      reset_config;
    end procedure stuck_at_new_test;



    procedure bypass_test(void : t_void) is
    begin
      log(ID_SEQUENCER, "QR example testing SL/SLV BYPASS", C_SCOPE);
      shared_ei_config(C_SL_EI_IDX)   := C_EI_CONFIG_DEFAULT;
      shared_ei_config(C_SLV_EI_IDX)  := C_EI_CONFIG_DEFAULT;


      for idx in 1 to 8 loop
        log(ID_SEQUENCER_SUB, "Bypass test, idx="&to_string(idx), C_SCOPE);

        check_value(output_sl = '0', TB_ERROR, "verify SL output");
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8) - 1), TB_ERROR, "verify SLV output");

        run_test(idx);
        v_timestamp_sl := now;
        wait until output_sl = '1';
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV output");

        wait until output_sl = '0';
        check_value(output_slv, std_logic_vector(to_unsigned(idx, 8)), TB_ERROR, "verify SLV output");
        check_value((now-v_timestamp_sl) = C_PULSE_WIDTH, TB_ERROR, "verify pulse width");

        wait for C_PULSE_WIDTH; -- SL low period
      end loop;

      reset_config;
    end procedure bypass_test;




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
    enable_log_msg(ID_SEQUENCER_SUB);


    log(ID_LOG_HDR, "Starting simulation of Error Injection TB.", C_SCOPE);
    --============================================================================================================

    --wait for 10 ns;

    delay_test(VOID);
    jitter_test(VOID);
    invert_test(VOID);
    pulse_test(VOID);
    stuck_at_old_test(VOID);
    stuck_at_new_test(VOID);
    bypass_test(VOID);


    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;             -- to allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely
  end process p_sequencer;


end func;
