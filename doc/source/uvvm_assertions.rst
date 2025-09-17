.. Uvvm Assertions:

##################################################################################################################################
UVVM Assertions (BETA)
##################################################################################################################################

VHDL assertions are statements used to verify conditions or assumptions during simulation and synthesis. Normal VHDL assertions check signal values or system states at runtime, 
issuing messages or halting simulation upon violation of predefined constraints. UVVM Assertions is a collection of assertions that can be used inside the UVVM logging and methodology framework. 
Like pure VHDL assertions, UVVM assertions consist of a condition to check, a message to log if the condition fails, and a severity level to indicate the importance of the failure, 
and other features such as enable signal, positive acknowledge, and more. The simplest of them: `assert_value` can be used to log a simple VHDL assert statement within the UVVM log.

These assertions are designed to catch some of the fundamental features typically targeted by assertion libraries (such as PSL or OVL), 
and have been largely influenced by the assertions found in *Accellera Standard OVL V2*, and a substitution table can be found at the very bottom of this page.

**********************************************************************************************************************************
Usage examples:
**********************************************************************************************************************************

.. _simplest_assertion_usage:

Simplest usage
==================================================================================================================================

.. list-table:: 

    * - .. figure:: /images/uvvm_assertions/assertions_simple.png
           :alt: Most basic usage with assertion instantiated in the TB arch body
           :align: center

           Figure 1 - assert_value instantiated in the TB arch body

**Figure 1** shows the simplest usage of UVVM assertions, which can replace normal VHDL assertions is to use `assert_value` with boolean entries. 
Below is a code example of an UVVM testbench where `assert_value` is instantiated with some logic to assert a signal property of the DUT, 
as well as the pure VHDL code to do the same. 

Here we control the assertion from the DUT, using the `count_valid` signal as the enable signal. 
In this example the assertion is checking that the `count` signal is never equal to 13, by using an auxiliary signal `assert_count_not_13`.

::

    library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

    library uvvm_util;
    context uvvm_util.uvvm_util_context;

    entity simple_assertion_tb is
    end entity simple_assertion_tb;

    architecture func of simple_assertion_tb is
        constant C_CLK_PERIOD : time := 10 ns;

        signal clk         : std_logic := '0';
        signal rst         : std_logic := '0';
        signal count       : integer := 0;
        signal count_valid : std_logic := '0';

        signal assert_count_not_13 : boolean := false;
    begin

    -----------------------------------------------------------------------------
    -- The simplest clock generator
    -----------------------------------------------------------------------------
    clk <= not clk after C_CLK_PERIOD / 2;

    -----------------------------------------------------------------------------
    -- Instantiate DUT
    -----------------------------------------------------------------------------
    i_counter : entity work.lucky_counter
        port map(
        clk         => clk,
        rst         => rst,
        count       => count, -- will always skip 13 as this is an unlucky number
        count_valid => count_valid -- we will let the DUT control the assertion enable
        );

    -----------------------------------------------------------------------------
    -- Assertions
    -----------------------------------------------------------------------------
    p_assert_pure_vhdl : process
    begin
        wait until rising_edge(clk);
        if count_valid = '1' then
        -- Check if the count is not equal to 13
        assert count /= 13
            report "Pure VHDL assertion failed: count should not be 13"
            severity error;
        end if;
    end process p_assert_pure_vhdl;

    assert_count_not_13 <= count /= 13;
    p_uvvm_assertion : assert_value(clk, count_valid, assert_count_not_13, true, "count must never be 13");

    p_main : process
    begin
        log(ID_LOG_HDR, "STARTING SIMULATION", C_SCOPE);

        rst <= '1';  -- Assert reset
        wait for 10*C_CLK_PERIOD;  -- Wait for 10 clock cycles
        rst <= '0';  -- Deassert reset
        wait for 200*C_CLK_PERIOD;

        log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

        -- Finish the simulation
        std.env.stop;
        wait;                               -- to stop completely

    end process p_main;

    end func;

Normal usage
==================================================================================================================================

.. list-table:: 

    * - .. figure:: /images/uvvm_assertions/assertions.png
           :alt: Signal Monitors Placement in Testbench with VVCs
           :align: center

           Figure 2 - Signal Assertions Placement in Test-Harness (with VVCs)

**Figure 2** shows a typical usage of UVVM assertions inside a test-harness, with VCCs controlling the DUT. 
The assertion in the test-harness is controlled by both the testbench, and the DUT using an auxiliary signal `assertion_ena_combined`,
The user made VCCs is shown to contain an assertion (`assert_one_of_async`) placed concurrently inside it to check an assumption about the VCC output.
The code example below matches the figure, but without the optional VVCs. 
In this example the assertion (`assert_value_in_range`), placed concurrently in the test-harness is checking that 
the output of a simple counter is always within a certain range (0-250). ::

    entity tb is
    end entity tb;

    architecture sim of tb is
        -- signals
    begin

        i_test_harness : entity work.uvvm_assertion_demo_th
            port map(
                assert_value_in_range_ena => assert_value_in_range_ena,
                clock_ena => clock_ena
            );

        -- Test sequencer
        p_main : process
        begin
            -- continuously monitor the DUT output is in range (some time to allow for rst to be done)
            assert_value_in_range_ena <= '0';
            wait for 10 ns;
            assert_value_in_range_ena <= '1';
        end process p_main;
    end architecture rtl;

::

    entity th is
      port (
        assert_value_in_range_ena : in std_logic;
        clock_ena                 : in std_logic;
      );
    end entity th;

    architecture sim of th is
        signal dut_counter_value: integer;
        signal dut_counter_valid: std_logic := '0';
        signal assertion_ena_combined: std_logic := '0';
    begin
        -----------------------------------------------------------------------------
        -- DUT Instantiation - Simple Counter
        -----------------------------------------------------------------------------
        i_simple_counter : simple_counter
            port map(
                clk            => clk,
                enable         => '1',
                counter_val    => dut_counter_value,
                counter_valid  => dut_counter_valid
            );

        -----------------------------------------------------------------------------
        -- Assertion - Check counter value stays within range
        -----------------------------------------------------------------------------
        assertion_ena_combined <= assert_value_in_range_ena and dut_counter_valid;
        assert_value_in_range(
            clk             => clk,
            ena             => assertion_ena_combined,
            tracked_value   => dut_counter_value,
            lower_limit     => 0,     -- Minimum valid counter value
            upper_limit     => 250,   -- Maximum valid counter value (set by requirement)
            msg             => "DUT counter value valid range (0-250)",
            alert_level     => ERROR
        );

        -----------------------------------------------------------------------------
        -- Clock Generator
        -----------------------------------------------------------------------------
        clock_generator(clk, clock_ena, C_CLK_PERIOD, "DUT TB clock");

    end architecture sim;

.. note::

    More examples of uvvm assertions can be found in the `uvvm_assertions_demo` ( `_tb.vhd` / `_th.vhd` ) testbench and test-harness in the uvvm_util/tb/ directory.
 

**********************************************************************************************************************************
Basic concepts:
**********************************************************************************************************************************

Clocked and async
==================================================================================================================================

Most UVVM assertions are provided in two variants: a clocked version, which checks on the rising edge of a clock, 
and a non-clocked version, which checks whenever any signal parameter has an `’event`. (assuming the enable signal is active).
Note that for the clocked assertions, the `tracked_value` will be checked at the same delta cycle as the rising edge of the clock, 
meaning that any changes to the tracked signal after this will be checked on the next rising edge of the clock.

Configuring the assertion
==================================================================================================================================
All UVVM assertions have parameters defined as constants that can be used to configure the behavior of the assertion. 
These configuration parameters will be locked to their set value when the assertion is activated by the enable signal. 
If the configuration parameters need to be changed, the enable signal must be set low before changing the parameters to the desired value.

pos_ack and pos_ack_kind
==================================================================================================================================

All UVVM assertions will log on the :code:`msg_id := ID_UVVM_ASSERTION` (can be changed by setting the `msg_id` constant in the procedure call) 
A positive acknowledgment will be logged when the assertion is sure that the assertion has passed. 
The default behavior is to only log the first time. By setting :code:`pos_ack_kind <= EVERY`, the positive acknowledgment will come each time. 

**********************************************************************************************************************************
Assertions
**********************************************************************************************************************************

All UVVM assertions have some common traits which are useful to know before using them. All assertions require 
that the enable signal is set to '1' (called active) for the assertion to be considered. 
If the assertion fails, UVVM will raise an alert with the severity set by the `alert_level` parameter, and 
as stated above, using the non-clocked version of the assertion will consider the assertion on any signal change. 
Most of this behavioral info is also written on each assertion procedure header.

.. note::
    **Optional parameters**
    "[]" in port map mean the parameter is optional

    **Legend**
    bool=boolean, sl=std_logic, slv=std_logic_vector, u=unsigned, s=signed, int=integer, exp=expected, ena=enable


Basic assertions
==================================================================================================================================

assert_value()
----------------------------------------------------------------------------------------------------------------------------------

The `assert_value()` assertions will check if the signal given in the `tracked_value` is equal to `exp_value`. 
If the assertion fails, UVVM will raise an alert with the severity `alert_level`. For `assert_value()` using :code:`clk(sl)`, the check is done at the rising edge of the clock, and 
for the non-clocked version, the check is done on any signal change. (both assertions require the enable to be active). The input map is: ::

    assert_value([clk(sl)], ena(sl), tracked_value(bool),             exp_value(bool),             msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
    assert_value([clk(sl)], ena(sl), tracked_value(slv),              exp_value(slv),              msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
    assert_value([clk(sl)], ena(sl), tracked_value(sl),               exp_value(sl),               msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
    assert_value([clk(sl)], ena(sl), tracked_value(t_slv_array),      exp_value(t_slv_array),      msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
    assert_value([clk(sl)], ena(sl), tracked_value(t_unsigned_array), exp_value(t_unsigned_array), msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
    assert_value([clk(sl)], ena(sl), tracked_value(t_signed_array),   exp_value(t_signed_array),   msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
    assert_value([clk(sl)], ena(sl), tracked_value(u),                exp_value(u),                msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
    assert_value([clk(sl)], ena(sl), tracked_value(s),                exp_value(s),                msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
    assert_value([clk(sl)], ena(sl), tracked_value(int),              exp_value(int),              msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
    assert_value([clk(sl)], ena(sl), tracked_value(real),             exp_value(real),             msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
    assert_value([clk(sl)], ena(sl), tracked_value(time),             exp_value(time),             msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])

+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| Object   | Name               | Dir    | Type                         | Description                                                                                                          |
+==========+====================+========+==============================+======================================================================================================================+
| signal   | clk                | in     | std_logic                    | Clock signal. When used, the check will only be performed on rising edge,                                            |
|          |                    |        |                              | when omitted any signal 'event will activate the assertion                                                           |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| signal   | ena                | in     | std_logic                    | Enable signal. must be '1' for the assertion to be considered                                                        |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| signal   | tracked_value      | in     | *see overloads*              | Test expression value, alert when not equal to exp_value on check                                                    |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | exp_value          | in     | *see overloads*              | Expected value for the tracked_value (default: bool:true, other types has no default)                                |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | msg                | in     | string                       | Assertion log message                                                                                                |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default is ERROR.                                                                   |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | scope              | in     | string                       | Scope of the assertion. Default is C_SCOPE                                                                           |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | pos_ack_kind       | in     | :ref:`t_pos_ack_kind`        | How often the pos ack should come. Default is FIRST                                                                  |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID for the assertion. Default is ID_UVVM_ASSERTION                                                           |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Message ID panel for the assertion. Default is shared_msg_id_panel                                                   |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+

Example of usage:

.. code-block::

    assert_value(clk, '1', dut_output, '1', "DUT signal must be '1' at rising edge of clk:200MHz");

    assert_value(
    clk             => clk,
    ena             => assertion_enable,
    tracked_value   => dut_output,
    exp_value       => '1',
    msg             => "DUT signal must be '1' at rising edge of clk:200MHz"
    );

.. note::

    If you wish to use the `assert_value` to assert if a signal is *never equal* to a certain value, 
    you must use the `assert_value(bool)` variant and supply the `tracked_value` as an auxiliary boolean signal with the value of `tracked_value /= exp_value`. 
    (see simple example at the top of this page)


assert_one_of()
----------------------------------------------------------------------------------------------------------------------------------
The `assert_one_of()` assertion will check if the signal given in the `assert_one_of` is equal to any of the values in `allowed_values`. 
If the assertion fails, UVVM will raise an alert with the severity `alert_level`. For `assert_one_of()` using :code:`clk(sl)`, the check is done at the rising edge of the clock, 
and for the non-clocked version, the check is done on any signal change. (both assertions require the enable to be active).
The input map is: ::
    
        assert_one_of([clk(sl)], ena(sl), tracked_value(slv),  allowed_values(t_slv_array),      msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
        assert_one_of([clk(sl)], ena(sl), tracked_value(sl),   allowed_values(slv),              msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
        assert_one_of([clk(sl)], ena(sl), tracked_value(u),    allowed_values(t_unsigned_array), msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
        assert_one_of([clk(sl)], ena(sl), tracked_value(s),    allowed_values(t_signed_array),   msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
        assert_one_of([clk(sl)], ena(sl), tracked_value(int),  allowed_values(t_integer_array),  msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
        assert_one_of([clk(sl)], ena(sl), tracked_value(real), allowed_values(real_vector),      msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
        assert_one_of([clk(sl)], ena(sl), tracked_value(time), allowed_values(time_vector),      msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])


+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| Object   | Name               | Dir    | Type                         | Description                                                                                                          |
+==========+====================+========+==============================+======================================================================================================================+
| signal   | clk                | in     | std_logic                    | Clock signal. When used, the check will only be performed on rising edge,                                            |
|          |                    |        |                              | when omitted any signal 'event will activate the assertion                                                           |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| signal   | ena                | in     | std_logic                    | Enable signal. must be '1' for the assertion to be considered                                                        |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| signal   | tracked_value      | in     | *see overloads*              | Test expression value, alert when not equal to one of the allowed_values on clock rising edge                        |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | allowed_values     | in     | *see overloads*              | A set of allowed values in the tracked_value                                                                         |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | msg                | in     | string                       | Assertion log message                                                                                                |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default is ERROR                                                                    |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | scope              | in     | string                       | Scope of the assertion. Default is C_SCOPE                                                                           |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | pos_ack_kind       | in     | :ref:`t_pos_ack_kind`        | How often the pos ack should come. Default is FIRST                                                                  |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID for the assertion. Default is ID_UVVM_ASSERTION                                                           |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Message ID panel for the assertion. Default is shared_msg_id_panel                                                   |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+

Example of usage:

.. code-block::

    -- This will check that "dut_output" is always within valid digital values (L, H, 0, 1)
    -- avoiding non-valid logic states (X, Z, U, W, -) in the std_logic signal.
    -- The assertion will be tested on the rising edge of clk:200MHz
    assert_one_of(
    clk             => clk,
    ena             => enable,
    tracked_value   => dut_output,
    allowed_values  => "LH01",
    alert_level     => ERROR,
    msg             => "Only DUT signal std_logic values constrained to: L, H, 0, and 1 are allowed at clk:200MHz"
    );

    assert_one_of(clk, assertion_ena, dut_output, "LH01", "Only DUT signal std_logic values constrained to: L, H, 0, and 1 are allowed at clk:200MHz");


assert_one_hot()
----------------------------------------------------------------------------------------------------------------------------------
The `assert_one_hot()` assertion will check if the signal given in the `tracked_value` is a one-hot signal (e.i that only one bit is set to '1' and all others are '0'). 
If the assertion fails, UVVM will raise an alert with the severity `alert_level`. For the `assert_one_hot()` using :code:`clk(sl)`, the check is done at the rising edge of the clock, 
and for the non-clocked version, the check is done on any signal change. (both assertions require the enable to be active).

**NOTE:** this assertion may be used to also cover all zeros as a one-hot signal by setting `accept_all_zero` to `ALL_ZERO_ALLOWED`. 
The input map is: ::
    
        assert_one_hot([clk(sl)], ena(sl), tracked_value(slv), msg, [alert_level, [accept_all_zero, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]]])

+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| Object   | Name               | Dir    | Type                         | Description                                                                                                          |
+==========+====================+========+==============================+======================================================================================================================+
| signal   | clk                | in     | std_logic                    | Clock signal. When used, the check will only be performed on rising edge,                                            |
|          |                    |        |                              | when omitted any signal 'event will activate the assertion                                                           |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| signal   | ena                | in     | std_logic                    | Enable signal. must be '1' for the assertion to be considered                                                        |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| signal   | tracked_value      | in     | std_logic_vector             | Test expression value, alert when not a one hot signal                                                               |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | msg                | in     | string                       | Assertion log message                                                                                                |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default is ERROR                                                                    |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | accept_all_zero    | in     | :ref:`t_accept_all_zeros`    | Accept all zeros as a one-hot signal. Default is ALL_ZERO_NOT_ALLOWED                                                |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | scope              | in     | string                       | Scope of the assertion. Default is C_SCOPE                                                                           |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | pos_ack_kind       | in     | :ref:`t_pos_ack_kind`        | How often the positive acknowledge should come. Default is FIRST                                                     |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID for the assertion. Default is ID_UVVM_ASSERTION                                                           |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Message ID panel for the assertion. Default is shared_msg_id_panel                                                   |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+

Example of usage:

.. code-block::

    -- This will check that "dut_output" is a one-hot signal at the rising edge of clk:200MHz
    assert_one_hot(
    clk             => clk,
    ena             => assertion_enable,
    tracked_value   => dut_output,
    msg             => "DUT signal must be a one-hot signal at rising edge of clk:200MHz"
    alert_level     => WARNING,
    accept_all_zero => ALL_ZERO_ALLOWED,  -- Also accept all zeros as valid state
    );

    assert_one_hot(clk, assertion_ena, dut_output, "DUT signal must be a one-hot signal at rising edge of clk:200MHz");

assert_value_in_range()
----------------------------------------------------------------------------------------------------------------------------------
The `assert_value_in_range()` assertion will check if the signal given in the `tracked_value` is within the range (inclusive) of `lower_limit` and `upper_limit`. 
If the assertion fails, UVVM will raise an alert with the severity `alert_level`. For `assert_value_in_range()` using :code:`clk(sl)`, the check is done at the rising edge of the clock, 
and for the non-clocked version, the check is done on any signal change. (both assertions require the enable to be active). 
The input map is: ::
    
        assert_value_in_range([clk(sl)], ena(sl), tracked_value(u),    lower_limit(u),    upper_limit(u),    msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
        assert_value_in_range([clk(sl)], ena(sl), tracked_value(s),    lower_limit(s),    upper_limit(s),    msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
        assert_value_in_range([clk(sl)], ena(sl), tracked_value(int),  lower_limit(int),  upper_limit(int),  msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
        assert_value_in_range([clk(sl)], ena(sl), tracked_value(real), lower_limit(real), upper_limit(real), msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
        assert_value_in_range([clk(sl)], ena(sl), tracked_value(time), lower_limit(time), upper_limit(time), msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])

+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| Object   | Name               | Dir    | Type                         | Description                                                                                                          |
+==========+====================+========+==============================+======================================================================================================================+
| signal   | clk                | in     | std_logic                    | Clock signal. When used, the check will only be performed on rising edge,                                            |
|          |                    |        |                              | when omitted any signal 'event will activate the assertion                                                           |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| signal   | ena                | in     | std_logic                    | Enable signal. must be '1' for the assertion to be considered                                                        |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| signal   | tracked_value      | in     | *see overloads*              | Test expression value, alert when not in range                                                                       |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | lower_limit        | in     | *see overloads*              | Lower bound of the allowed range (inclusive)                                                                         |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | upper_limit        | in     | *see overloads*              | Upper bound of the allowed range (inclusive)                                                                         |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | msg                | in     | string                       | Assertion log message                                                                                                |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default is ERROR                                                                    |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | scope              | in     | string                       | Scope of the assertion. Default is C_SCOPE                                                                           |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | pos_ack_kind       | in     | :ref:`t_pos_ack_kind`        | How often the pos ack should come. Default is FIRST                                                                  |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID for the assertion. Default is ID_UVVM_ASSERTION                                                           |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Message ID panel for the assertion. Default is shared_msg_id_panel                                                   |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+

Example of usage:

.. code-block::

    -- This will check that the motor PWM duty cycle always remains within the safe operating range
    -- at the rising edge of clk:100MHz
    assert_value_in_range(
    clk             => clk_100mhz,
    ena             => tb_asserts_enable,
    tracked_value   => motor_pwm_duty_cycle,
    -- ** CONFIG **
    lower_limit     => 5,    -- Min 5% duty cycle to ensure motor startup
    upper_limit     => 95,   -- Max 95% duty cycle to prevent overheating
    alert_level     => TB_ERROR,
    msg             => "Motor PWM duty cycle must be in operating range (5-95%) @ clk:100MHz"
    );

    assert_value_in_range(clk_100mhz, assertion_ena, motor_pwm_duty_cycle, 5, 95, "Motor PWM duty cycle must be in operating range (5-95%) @ clk:100MHz");


assert_shift_one_from_left()
----------------------------------------------------------------------------------------------------------------------------------
The `assert_shift_one_from_left()` assertion will verify that the `tracked_value` signal follows the `srl` pattern from left to right. 
If the assertion fails, UVVM will raise an alert with the severity `alert_level`. The input map is: ::

        assert_shift_one_from_left(clk(sl), ena(sl), tracked_value(slv), [necessary_condition], msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])

When enabled, the assertion checks that a '1' shifts from the leftmost bit to the rightmost bit, one position at each clock cycle. 
The assertion will give out an positive acknowledgement on the final bit (rightmost) being set to '1'. 
An alert will be raised if the sequence is broken based on the `necessary_condition` configuration.

When using `necessary_condition` set as :code:`ANY_BIT_ALERT` or :code:`LAST_BIT_ALERT`, the assertion will allow for pipelined sequences, 
meaning that any new leftmost `'1'` will start a new sequence, being tracked independently of the previous sequence. 
If the `necessary_condition` is set as :code:`ANY_BIT_ALERT_NO_PIPE` or :code:`LAST_BIT_ALERT_NO_PIPE`, the assertion will not allow for pipelined sequences, 
and any new leftmost `'1'` while in an ongoing sequence will be ignored. 
If the sequence is broken, the assertion will drop all ongoing sequences, and give out an alert based on which `necessary_condition` is set, and which bit broke the sequence.

Example of sequences:

.. code-block::

    -- NOTE: "b" is a placeholder for any bit (0 or 1)
    1bbb -> b1bb -> bb1b -> bbb1 -- a sequence of 4 bits with no errors
    1bbb -> 11bb -> b11b -> bb11 -> bbb1 -- two sequences of 4 bits with no errors (pipelined)

    -- Examples of sequences with errors:
    1bbb -> b1bb -> bb1b -> bbb0 -- All necessary_conditions will give an alert
    1bbb -> b1bb -> bb0b -> bbb0 -- Only necessary_condition ANY_BIT_ALERT and ANY_BIT_ALERT_NO_PIPE will give an alert
    1bbb -> 11bb -> b11b -> bb11 -> bbb0 -- (pipelined) necessary_condition ANY_BIT_ALERT and LAST_BIT_ALERT will give an alert
    1bbb -> 11bb -> b11b -> bb01 -> bbb1 -- (pipelined) Only necessary_condition ANY_BIT_ALERT will give an alert

+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| Object   | Name               | Dir    | Type                         | Description                                                                                                          |
+==========+====================+========+==============================+======================================================================================================================+
| signal   | clk                | in     | std_logic                    | Clock signal                                                                                                         |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| signal   | ena                | in     | std_logic                    | Enable signal, must be '1' for the assertion to be considered                                                        |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| signal   | tracked_value      | in     | std_logic_vector             | Test expression value, will alert if the shift pattern from left to right is broken                                  |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | necessary_condition| in     | :ref:`t_necessary_condition` | Sets when to alert. Default is ANY_BIT_ALERT                                                                         |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | msg                | in     | string                       | Assertion log message                                                                                                |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default is ERROR                                                                    |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | scope              | in     | string                       | Scope of the assertion. Default is C_SCOPE                                                                           |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | pos_ack_kind       | in     | :ref:`t_pos_ack_kind`        | How often the pos ack should come. Default is FIRST                                                                  |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID for the assertion. Default is ID_UVVM_ASSERTION                                                           |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Message ID panel for the assertion. Default is shared_msg_id_panel                                                   |
+----------+--------------------+--------+------------------------------+----------------------------------------------------------------------------------------------------------------------+


Example of usage:

.. code-block::

    -- Pipeline Stage Valid Signal Tracking
    -- This assertion monitors the "valid" signal as it propagates through a 4-stage
    -- image processing pipeline (each bit represents a valid flag in one stage)
    assert_shift_one_from_left(
    clk                 => pixel_clock,
    ena                 => pipeline_active,       -- Enable signal for the pipeline
    tracked_value       => pipeline_stage_valid,  -- 4-bit signal, one per pipeline stage
    necessary_condition => ANY_BIT_ALERT,         -- Alert on any stage that drops the valid flag
    msg                 => "Image processing pipeline stage valid signal must shift one-hot from left to right",
    alert_level         => WARNING,
    );

    assert_shift_one_from_left(clk, pipeline_active, pipeline_stage_valid, ANY_BIT_ALERT, "Image processing pipeline stage valid signal must shift one-hot from left to right", WARNING);


Window assertions
==================================================================================================================================

Window assertions are a collection of assertions to check signal properties within a defined window, either set by a number of cycles after a trigger signal or between two trigger signals.
The window assertions which exist for both cycle-bound and end-trigger bound are:

+--------------------------------------------------------------+----------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Name                                                         | Bound by | asserts                                                                                                                                                               |
+==============================================================+==========+=======================================================================================================================================================================+
| assert_value_from_min_to_max_cycles_after_trigger            | Cycles   | Checks that the `tracked_value` signal is equal to `exp_value` on each rising edge in window.                                                                         |
+--------------------------------------------------------------+----------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| assert_change_to_value_from_min_to_max_cycles_after_trigger  | Cycles   | Checks that the `tracked_value` signal is equal to a non-`exp_value` at any rising edge in window, and then later is equal to `exp_value` on a rising edge in window. |
+--------------------------------------------------------------+----------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| assert_change_from_min_to_max_cycles_after_trigger           | Cycles   | Checks that the `tracked_value` has two different values on two rising edges in window.                                                                               |
+--------------------------------------------------------------+----------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| assert_stable_from_min_to_max_cycles_after_trigger           | Cycles   | Checks that the `tracked_value` signal is stable (the same value) on all rising edges in window.                                                                      |
+--------------------------------------------------------------+----------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| assert_value_from_start_to_end_trigger                       | Trigger  | Checks that the `tracked_value` signal is equal to `exp_value` on each rising edge in window.                                                                         |
+--------------------------------------------------------------+----------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| assert_change_to_value_from_start_to_end_trigger             | Trigger  | Checks that the `tracked_value` signal is equal to a non-`exp_value` at any rising edge in window, and then later is equal to `exp_value` on a rising edge in window. |
+--------------------------------------------------------------+----------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| assert_change_from_start_to_end_trigger                      | Trigger  | Checks that the `tracked_value` has two different values on two rising edges in window.                                                                               |
+--------------------------------------------------------------+----------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| assert_stable_from_start_to_end_trigger                      | Trigger  | Checks that the `tracked_value` signal is stable (the same value) on all rising edges in window.                                                                      |
+--------------------------------------------------------------+----------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+

.. Note::

    * The number of cycles is **0** at the first `rising_edge(clk)` where trigger = '1'. 
    * Setting `min_cycles = 0` and `max_cycles = 0` will result in the first and last check on the first `rising_edge(clk)` where trigger = '1'.
    * After the first assertion OK event, the assertion will be dropped and give a positive acknowledge (unless using *_stable_* where the entire window must be checked).
    * The number of cycles and start/end triggers are inclusive, with the exception of the "change" assertions not considering a change on the -1 to 0 cycle transition (as the tracked_value is first stored on trigger rising edge).

.. Hint::

    All window assertions can be pipelined (if `trigger`/`start_trigger` is '1' while another window assertion is in progress). The assertion will check each window independently, giving an positive acknowledge or alert for each pipe independently.
    
    toggling `ena <= '0'` will stop the assertion from checking all pipes and resets all internal saved values (as with the other assertions).

    Pipe numbering start on zero at the first trigger, and will be printed out as `pipe: (N)` for all non zero pipes in the assertion log message.

Example:

.. list-table:: 

    * - .. figure:: /images/uvvm_assertions/wavedrom_change_to_equal_example.png
           :alt: Simple example of `assert_change_to_value_from_min_to_max_cycles_after_trigger` using `min_cycles = 1` and `max_cycles = 3`, where `exp_value = '1'`
           :align: center

           Figure 3 - Simple example of `assert_change_to_value_from_min_to_max_cycles_after_trigger`

**Figure 3** shows a simple example of `assert_change_to_value_from_min_to_max_cycles_after_trigger` using `min_cycles = 1` and `max_cycles = 3`, where `exp_value = '1'`. 
**Note-1:** That the number 1-cycle (0 on the trigger rising edge) rising edge is the first time `tracked_value` is considered, and the 3-cycle rising edge is the last time `tracked_value` is considered. 
**Note-2:** The "signal" `valid window` is used to illustrate when the window is active in the assertion, and is not a signal in the assertion itself.


assert_value_from_min_to_max_cycles_after_trigger()
----------------------------------------------------------------------------------------------------------------------------------
The `assert_value_from_min_to_max_cycles_after_trigger` assertion checks if the `tracked_value` signal is equal to `exp_value` (on rising edge of clock) within a range of cycles after the `trigger` signal is '1'. The range is defined by the `min_cycles` and `max_cycles` constants.
**NOTE**: If the min_cycles is set to 0, the assertion will check if the `tracked_value` signal is equal to `exp_value` at the same cycle as the `trigger` signal is '1'.

::

    assert_value_from_min_to_max_cycles_after_trigger(clk(sl), ena(sl), tracked_value(sl),  trigger(sl), min_cycles(int), max_cycles(int), exp_value(sl),  msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
    assert_value_from_min_to_max_cycles_after_trigger(clk(sl), ena(sl), tracked_value(slv), trigger(sl), min_cycles(int), max_cycles(int), exp_value(slv), msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| Object   | Name               | Dir    | Type                         | Description                                                               |
+==========+====================+========+==============================+===========================================================================+
| signal   | clk                | in     | std_logic                    | Clock signal                                                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| signal   | ena                | in     | std_logic                    | Enable signal, must be '1' for the assertion to be considered             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| signal   | tracked_value      | in     | *see overloads*              | Test expression to assert                                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| signal   | trigger            | in     | std_logic                    | Start event signal                                                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| constant | min_cycles         | in     | integer                      | Minimum number of cycles after trigger signal to check (inclusive)        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| constant | max_cycles         | in     | integer                      | Maximum number of cycles after trigger signal to check (inclusive)        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| constant | exp_value          | in     | *see overloads*              | Expected value of the tracked signal to check for                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| constant | msg                | in     | string                       | Assertion log message                                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default is ERROR                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| constant | scope              | in     | string                       | Scope of the assertion. Default is C_SCOPE                                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| constant | pos_ack_kind       | in     | :ref:`t_pos_ack_kind`        | How often the pos ack should come. Default is FIRST                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID for the assertion. Default is ID_UVVM_ASSERTION                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Message ID panel for the assertion. Default is shared_msg_id_panel        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+

Example of usage:

.. code-block::
    
    -- This will check that the data_valid_flag remains high for the entire duration of a data transfer
    -- (from cycle 0 when transfer starts through cycle 3, covering all 4 cycles of the transfer window)
    assert_value_from_min_to_max_cycles_after_trigger(
    clk             => system_clk,
    ena             => interface_active,
    tracked_value   => data_valid_flag,
    trigger         => start_transfer,
    min_cycles      => 0,     -- Start checking immediately when transfer begins
    max_cycles      => 3,     -- Check through the entire 4-cycle transfer window (cycles 0,1,2,3)
    exp_value       => '1',   -- Data valid must remain high throughout the entire transfer
    msg             => "Data valid flag must remain asserted for the entire 4-cycle transfer window"
    alert_level     => TB_ERROR,
    );

    assert_value_from_min_to_max_cycles_after_trigger(clk, assertion_ena, data_valid_flag, start_transfer, 0, 3, '1', "Data valid flag must remain asserted for the entire 4-cycle transfer window");


assert_change_to_value_from_min_to_max_cycles_after_trigger()
----------------------------------------------------------------------------------------------------------------------------------
The `assert_change_to_value_from_min_to_max_cycles_after_trigger` assertion checks if the `tracked_value` signal is **different** from `exp_value` 
at any rising edge within the window, and then later changes to `exp_value` on a subsequent rising edge within the window. 
The range is defined by the `min_cycles` and `max_cycles` constants. If the assertion fails, UVVM will raise an alert with the severity `alert_level`. 
The input map is::

    assert_change_to_value_from_min_to_max_cycles_after_trigger(clk(sl), ena(sl), tracked_value(sl),  trigger(sl), min_cycles(int), max_cycles(int), exp_value(sl),  msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
    assert_change_to_value_from_min_to_max_cycles_after_trigger(clk(sl), ena(sl), tracked_value(slv), trigger(sl), min_cycles(int), max_cycles(int), exp_value(slv), msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| Object   | Name               | Dir    | Type                         | Description                                                               |
+==========+====================+========+==============================+===========================================================================+
| signal   | clk                | in     | std_logic                    | Clock signal                                                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| signal   | ena                | in     | std_logic                    | Enable signal, must be '1' for the assertion to be considered             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| signal   | tracked_value      | in     | **see overloads**            | Test expression to assert, must change to exp_value within window         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| signal   | trigger            | in     | std_logic                    | Start event signal                                                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| constant | min_cycles         | in     | integer                      | Minimum number of cycles after trigger signal to check (inclusive)        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| constant | max_cycles         | in     | integer                      | Maximum number of cycles after trigger signal to check (inclusive)        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| constant | exp_value          | in     | **see overloads**            | Expected value the tracked signal must change to                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| constant | msg                | in     | string                       | Assertion log message                                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default is ERROR                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| constant | scope              | in     | string                       | Scope of the assertion. Default is C_SCOPE                                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| constant | pos_ack_kind       | in     | :ref:`t_pos_ack_kind`        | How often the pos ack should come. Default is FIRST                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID for the assertion. Default is ID_UVVM_ASSERTION                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Message ID panel for the assertion. Default is shared_msg_id_panel        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------------------+

Example of usage:

.. code-block::

    -- This will check that the acknowledge signal changes to high within 2-5 cycles after request
    assert_change_to_value_from_min_to_max_cycles_after_trigger(
    clk             => clk,
    ena             => protocol_active,
    tracked_value   => acknowledge_signal,
    trigger         => request_signal,
    min_cycles      => 2,     -- Allow 2 cycles minimum response time
    max_cycles      => 5,     -- Require response within 5 cycles maximum
    exp_value       => '1',   -- Expected value is acknowledge high
    msg             => "Acknowledge signal must change to active within required timing window (2-5 cycles) after request"
    alert_level     => ERROR,
    );

    assert_change_to_value_from_min_to_max_cycles_after_trigger(clk, assertion_ena, acknowledge_signal, request_signal, 2, 5, '1', "Acknowledge signal must change to active within required timing window (2-5 cycles) after request");


assert_change_from_min_to_max_cycles_after_trigger()
----------------------------------------------------------------------------------------------------------------------------------
The `assert_change_from_min_to_max_cycles_after_trigger` assertion checks if the `tracked_value` signal is two different values on two rising edges within the window. 
**Note:** This assertion requires the `max_cycles` to be greater than `min_cycles` to allow for at least one change to be detected (window consisting of at least two rising edges). 
If the assertion fails, UVVM will raise an alert with the severity `alert_level`. 
The input map is::

    assert_change_from_min_to_max_cycles_after_trigger(clk(sl), ena(sl), tracked_value(sl),  trigger(sl), min_cycles(int), max_cycles(int), msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
    assert_change_from_min_to_max_cycles_after_trigger(clk(sl), ena(sl), tracked_value(slv), trigger(sl), min_cycles(int), max_cycles(int), msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])

+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| Object   | Name               | Dir    | Type                         | Description                                                                 |
+==========+====================+========+==============================+=============================================================================+
| signal   | clk                | in     | std_logic                    | Clock signal                                                                |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | ena                | in     | std_logic                    | Enable signal, must be '1' for the assertion to be considered               |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | tracked_value      | in     | **see overloads**            | Test expression to assert, must change within window                        |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | trigger            | in     | std_logic                    | Start event signal                                                          |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | min_cycles         | in     | integer                      | Minimum number of cycles after trigger signal to check (inclusive)          |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | max_cycles         | in     | integer                      | Maximum number of cycles after trigger signal to check (inclusive)          |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | msg                | in     | string                       | Assertion log message                                                       |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default is ERROR                           |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | scope              | in     | string                       | Scope of the assertion. Default is C_SCOPE                                  |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | pos_ack_kind       | in     | :ref:`t_pos_ack_kind`        | How often the pos ack should come. Default is FIRST                         |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID for the assertion. Default is ID_UVVM_ASSERTION                  |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Message ID panel for the assertion. Default is shared_msg_id_panel          |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+

Example of usage:

.. code-block::

    -- This will check that the interrupt line toggles (changes state) within a window
    -- after a peripheral operation starts, indicating the operation completed
    assert_change_from_min_to_max_cycles_after_trigger(
    clk             => system_clk,
    ena             => tb_assertions_enabled,
    tracked_value   => interrupt_line,
    trigger         => start_peripheral_operation,
    min_cycles      => 5,     -- Earliest expected response (operation takes minimum 5 cycles)
    max_cycles      => 20,    -- Latest allowed response (operation timeout at 20 cycles)
    msg             => "Peripheral interrupt line must toggle within expected operation window (5-20 cycles)",
    alert_level     => WARNING
    );

    assert_change_from_min_to_max_cycles_after_trigger(clk, tb_assertions_enabled, interrupt_line, start_peripheral_operation, 5, 20, "Peripheral interrupt line must toggle within expected operation window (5-20 cycles)", WARNING);


assert_stable_from_min_to_max_cycles_after_trigger()
----------------------------------------------------------------------------------------------------------------------------------
The `assert_stable_from_min_to_max_cycles_after_trigger` assertion checks if the `tracked_value` signal is the same value on all rising edges of the `clk` signal within the window. 
**Note:** Setting `min_cycles = 0` and `max_cycles = 0` will result in the assertion to always pass (as the value is always the same value on "all" rising edges of the `clk` signal in the window).
The input map is::

    assert_stable_from_min_to_max_cycles_after_trigger(clk(sl), ena(sl), tracked_value(sl),  trigger(sl), min_cycles(int), max_cycles(int), msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
    assert_stable_from_min_to_max_cycles_after_trigger(clk(sl), ena(sl), tracked_value(slv), trigger(sl), min_cycles(int), max_cycles(int), msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])

+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| Object   | Name               | Dir    | Type                         | Description                                                                 |
+==========+====================+========+==============================+=============================================================================+
| signal   | clk                | in     | std_logic                    | Clock signal                                                                |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | ena                | in     | std_logic                    | Enable signal, must be '1' for the assertion to be considered               |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | tracked_value      | in     | **see overloads**            | Test expression value, must remain stable throughout the window             |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | trigger            | in     | std_logic                    | Start event signal                                                          |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | min_cycles         | in     | integer                      | Minimum number of cycles after trigger signal to check (inclusive)          |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | max_cycles         | in     | integer                      | Maximum number of cycles after trigger signal to check (inclusive)          |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | msg                | in     | string                       | Assertion log message                                                       |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default is ERROR                           |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | scope              | in     | string                       | Scope of the assertion. Default is C_SCOPE                                  |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | pos_ack_kind       | in     | :ref:`t_pos_ack_kind`        | How often the pos ack should come. Default is FIRST                         |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID for the assertion. Default is ID_UVVM_ASSERTION                  |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Message ID panel for the assertion. Default is shared_msg_id_panel          |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+

Example of usage:

.. code-block::

    -- This will check that the memory data bus remains stable during a read operation
    -- after the data_ready signal is asserted until the transaction completes
    assert_stable_from_min_to_max_cycles_after_trigger(
    clk             => system_clk,
    ena             => memory_interface_active,
    tracked_value   => memory_data_bus,
    trigger         => data_ready,
    min_cycles      => 0,     -- Start checking immediately when data is ready
    max_cycles      => 3,     -- Check stability for 4 cycles (cycles 0,1,2,3)
    msg             => "Memory data bus must remain stable after data_ready until transfer completes"
    alert_level     => ERROR,
    );

    assert_stable_from_min_to_max_cycles_after_trigger(clk, memory_interface_active, memory_data_bus, data_ready, 0, 3, "Memory data bus must remain stable after data_ready until transfer completes");


assert_value_from_start_to_end_trigger()
----------------------------------------------------------------------------------------------------------------------------------
The `assert_value_from_start_to_end_trigger` assertion checks if the `tracked_value` signal is equal to `exp_value` on each rising edge of the `clk` signal in the window defined by the start and end trigger signals.
If the assertion fails, UVVM will raise an alert with the severity `alert_level`. The input map is::

    assert_value_from_start_to_end_trigger(clk(sl), ena(sl), tracked_value(sl),  start_trigger(sl), end_trigger(sl), exp_value(sl),  msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
    assert_value_from_start_to_end_trigger(clk(sl), ena(sl), tracked_value(slv), start_trigger(sl), end_trigger(sl), exp_value(slv), msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])

+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| Object   | Name               | Dir    | Type                         | Description                                                                 |
+==========+====================+========+==============================+=============================================================================+
| signal   | clk                | in     | std_logic                    | Clock signal                                                                |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | ena                | in     | std_logic                    | Enable signal, must be '1' for the assertion to be considered               |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | tracked_value      | in     | **see overloads**            | Test expression value, must equal exp_value between the trigger signals     |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | start_trigger      | in     | std_logic                    | Start event signal that begins the assertion window                         |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | end_trigger        | in     | std_logic                    | End event signal that closes the assertion window                           |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | exp_value          | in     | **see overloads**            | Expected value the tracked signal must maintain between triggers            |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | msg                | in     | string                       | Assertion log message                                                       |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR                     |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | scope              | in     | string                       | Scope of the assertion. Default value is C_SCOPE                            |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | pos_ack_kind       | in     | :ref:`t_pos_ack_kind`        | How often the pos ack should come. Default value is FIRST                   |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID for the assertion. Default value is ID_UVVM_ASSERTION            |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Message ID panel for the assertion. Default value is shared_msg_id_panel    |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+

Example of usage:

.. code-block::

    -- This will check that the bus data remains valid (equal to '1') during an entire 
    -- bus transaction from the request signal until the acknowledge signal
    assert_value_from_start_to_end_trigger(
    clk             => system_clk,
    ena             => tb_assertions_enabled,
    tracked_value   => data_valid,
    start_trigger   => bus_request,
    end_trigger     => bus_acknowledge,
    exp_value       => '1',   -- Data must remain valid (1) during entire transaction
    msg             => "Data valid signal must remain high during entire bus transaction (from request to acknowledge)"
    alert_level     => ERROR,
    );

    assert_value_from_start_to_end_trigger(clk, tb_assertions_enabled, data_valid, bus_request, bus_acknowledge, '1', "Data valid signal must remain high during entire bus transaction (from request to acknowledge)");

assert_change_to_value_from_start_to_end_trigger()
----------------------------------------------------------------------------------------------------------------------------------
The `assert_change_to_value_from_start_to_end_trigger` assertion checks if the `tracked_value` is a different value than `exp_value` at any rising edge within the window, and then later changes to `exp_value` on a subsequent rising edge within the window. 
**Note:** `end_trigger` must come at least one clock cycle after `start_trigger` to allow for at least one change to be detected (window consisting of at least two rising edges).
If the assertion fails, UVVM will raise an alert with the severity `alert_level`. The input map is::

    assert_change_to_value_from_start_to_end_trigger(clk(sl), ena(sl), tracked_value(sl),  start_trigger(sl), end_trigger(sl), exp_value(sl),  msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
    assert_change_to_value_from_start_to_end_trigger(clk(sl), ena(sl), tracked_value(slv), start_trigger(sl), end_trigger(sl), exp_value(slv), msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])

+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| Object   | Name               | Dir    | Type                         | Description                                                                 |
+==========+====================+========+==============================+=============================================================================+
| signal   | clk                | in     | std_logic                    | Clock signal                                                                |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | ena                | in     | std_logic                    | Enable signal, must be '1' for the assertion to be considered               |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | tracked_value      | in     | **see overloads**            | Test expression value, must change to exp_value between trigger signals     |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | start_trigger      | in     | std_logic                    | Start event signal that begins the assertion window                         |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | end_trigger        | in     | std_logic                    | End event signal that closes the assertion window                           |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | exp_value          | in     | **see overloads**            | Expected value the tracked signal must change to between triggers           |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | msg                | in     | string                       | Assertion log message                                                       |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default is ERROR                           |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | scope              | in     | string                       | Scope of the assertion. Default is C_SCOPE                                  |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | pos_ack_kind       | in     | :ref:`t_pos_ack_kind`        | How often the pos ack should come. Default is FIRST                         |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID for the assertion. Default is ID_UVVM_ASSERTION                  |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Message ID panel for the assertion. Default is shared_msg_id_panel          |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+

Example of usage:

.. code-block::

    -- This will check that the acknowledge signal changes to high between request and completion
    assert_change_to_value_from_start_to_end_trigger(
    clk             => system_clk,
    ena             => tb_assertions_enabled,
    tracked_value   => acknowledge_signal,
    start_trigger   => request_signal,
    end_trigger     => operation_complete,
    exp_value       => '1',   -- Expected value is acknowledge high
    msg             => "Acknowledge signal must change to active during protocol transaction",
    alert_level     => TB_ERROR
    );

    assert_change_to_value_from_start_to_end_trigger(clk, tb_assertions_enabled, acknowledge_signal, request_signal, operation_complete, '1', "Acknowledge signal must change to active during protocol transaction", TB_ERROR);


assert_change_from_start_to_end_trigger()
----------------------------------------------------------------------------------------------------------------------------------
The `assert_change_from_start_to_end_trigger` assertion checks if the `tracked_value` signal has two different values on two rising edges within the window defined by the start and end trigger signals.
**Note:** `end_trigger` must come at least one clock cycle after `start_trigger` to allow for at least one change to be detected (window consisting of at least two rising edges).
If the assertion fails, UVVM will raise an alert with the severity `alert_level`. The input map is::

    assert_change_from_start_to_end_trigger(clk(sl), ena(sl), tracked_value(sl),  start_trigger(sl), end_trigger(sl), msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
    assert_change_from_start_to_end_trigger(clk(sl), ena(sl), tracked_value(slv), start_trigger(sl), end_trigger(sl), msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])

+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| Object   | Name               | Dir    | Type                         | Description                                                                 |
+==========+====================+========+==============================+=============================================================================+
| signal   | clk                | in     | std_logic                    | Clock signal                                                                |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | ena                | in     | std_logic                    | Enable signal, must be '1' for the assertion to be considered               |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | tracked_value      | in     | **see overloads**            | Test expression value, must change at least once between trigger signals    |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | start_trigger      | in     | std_logic                    | Start event signal that begins the assertion window                         |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | end_trigger        | in     | std_logic                    | End event signal that closes the assertion window                           |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | msg                | in     | string                       | Assertion log message                                                       |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default is ERROR                           |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | scope              | in     | string                       | Scope of the assertion. Default is C_SCOPE                                  |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | pos_ack_kind       | in     | :ref:`t_pos_ack_kind`        | How often the pos ack should come. Default is FIRST                         |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID for the assertion. Default is ID_UVVM_ASSERTION                  |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Message ID panel for the assertion. Default is shared_msg_id_panel          |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+

Example of usage:

.. code-block::

    -- This will check that the response signal changes state at least once between
    -- the start of a command and its completion
    assert_change_from_start_to_end_trigger(
    clk             => system_clk,
    ena             => device_active,
    tracked_value   => device_response,
    start_trigger   => command_start,
    end_trigger     => command_complete,
    msg             => "Device must produce a response signal transition during command execution",
    alert_level     => ERROR
    );

    assert_change_from_start_to_end_trigger(clk, device_active, device_response, command_start, command_complete, "Device must produce a response signal transition during command execution");


assert_stable_from_start_to_end_trigger()
----------------------------------------------------------------------------------------------------------------------------------
The `assert_stable_from_start_to_end_trigger` assertion checks if the `tracked_value` signal is the same value on all rising edges of the `clk` signal in the window defined by the start and end trigger signals.
If the assertion fails, UVVM will raise an alert with the severity `alert_level`. The input map is::

    assert_stable_from_start_to_end_trigger(clk(sl), ena(sl), tracked_value(sl),  start_trigger(sl), end_trigger(sl), msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])
    assert_stable_from_start_to_end_trigger(clk(sl), ena(sl), tracked_value(slv), start_trigger(sl), end_trigger(sl), msg, [alert_level, [scope, [pos_ack_kind, [msg_id, [msg_id_panel]]]]])

+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| Object   | Name               | Dir    | Type                         | Description                                                                 |
+==========+====================+========+==============================+=============================================================================+
| signal   | clk                | in     | std_logic                    | Clock signal                                                                |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | ena                | in     | std_logic                    | Enable signal, must be '1' for the assertion to be considered               |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | tracked_value      | in     | **see overloads**            | Test expression value, must remain stable between trigger signals           |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | start_trigger      | in     | std_logic                    | Start event signal that begins the assertion window                         |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| signal   | end_trigger        | in     | std_logic                    | End event signal that closes the assertion window                           |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | msg                | in     | string                       | Assertion log message                                                       |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default is ERROR                           |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | scope              | in     | string                       | Scope of the assertion. Default is C_SCOPE                                  |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | pos_ack_kind       | in     | :ref:`t_pos_ack_kind`        | How often the pos ack should come. Default is FIRST                         |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID for the assertion. Default is ID_UVVM_ASSERTION                  |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Message ID panel for the assertion. Default is shared_msg_id_panel          |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------------+

Example of usage:

.. code-block::

    -- This will check that the configuration register remains stable 
    -- during the entire data transfer operation (from start to complete signals)
    assert_stable_from_start_to_end_trigger(
    clk             => system_clk,
    ena             => tb_assertions_enabled,
    tracked_value   => configuration_register,
    start_trigger   => transfer_start,
    end_trigger     => transfer_complete,
    msg             => "Configuration register must remain stable during the entire transfer operation",
    alert_level     => ERROR
    );

    assert_stable_from_start_to_end_trigger(clk, tb_assertions_enabled, configuration_register, transfer_start, transfer_complete, "Configuration register must remain stable during the entire transfer operation");


Accellera OVL comparison functions
==================================================================================================================================
The Accellera Standard OVL V2 has been an inspiration for the UVVM assertion library, therefore under we have a list of the Assertions that are similar to the OVL V2 assertions.

+------------------------------+--------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
| OVL assertion name           | UVVM assertion equivalent                                    | Comments                                                                                               |
+==============================+==============================================================+========================================================================================================+
| ovl_always & ovl_never       | assert_value                                                 | The `exp_value` constant allows checking for a specific `tracked_value`, covering both OVL assertions  |
+------------------------------+--------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
| ovl_always_on_edge           | assert_value                                                 | Same as `ovl_always`, but checks `tracked_value` on the rising edge of `sampling_event` signal         |
+------------------------------+--------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
| ovl_cycle_sequence           | assert_shift_one_from_left                                   | Minor edge case differences; OVL `necessary_condition` is represented as a constant                    |
+------------------------------+--------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
| ovl_implication              | assert_value                                                 | OVLs new trigger signal must be covered by an auxiliary signal (:code:`c <= a and b`)                  |
+------------------------------+--------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
| ovl_never_unknown            | assert_one_of                                                | `allowed_values` constant defines allowed `tracked_value` values (e.g., "01H")                         |
+------------------------------+--------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
| ovl_never_unknown_async      | assert_one_of                                                | See `assert_always_one_of`, but use without `clk` in parameter map                                     |
+------------------------------+--------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
| ovl_one_hot                  | assert_one_hot                                               | Direct equivalent assertion                                                                            |
+------------------------------+--------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
| ovl_range                    | assert_value_in_range                                        | Name emphasizes checking a value within a range (e.g `int`)                                            |
+------------------------------+--------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
| ovl_zero_one_hot             | assert_one_hot                                               | There is a constant `accept_all_zero` which allows all zeros to count as a one-hot signal              |
+------------------------------+--------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
| ovl_next                     | assert_value_from_min_to_max_cycles_after_trigger            | Uses `min_cycles` and `max_cycles` to define the range of cycles to check                              |
+------------------------------+--------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
| ovl_req_ack_unique           | assert_change_to_value_from_min_to_max_cycles_after_trigger  | Ensures unique `tracked_value = exp_value` event within a cycle range after `trigger`                  |
+------------------------------+--------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
| ovl_time                     | assert_value_from_min_to_max_cycles_after_trigger            | Uses both `min_cycles` and `max_cycles`, unlike OVL which only uses `max_cycles`                       |
+------------------------------+--------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
| ovl_unchange                 | assert_stable_from_min_to_max_cycles_after_trigger           | Ensures `tracked_value` remains stable over a defined cycle range                                      |
+------------------------------+--------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
| ovl_win_change               | assert_change_from_start_to_end_trigger                      | Checks for changes within the start-to-end trigger window                                              |
+------------------------------+--------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
| ovl_win_unchange             | assert_stable_from_start_to_end_trigger                      | Ensures stability within the start-to-end trigger window                                               |
+------------------------------+--------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
| ovl_window                   | assert_value_from_start_to_end_trigger                       | Ensures activation within the start-to-end trigger window                                              |
+------------------------------+--------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+

