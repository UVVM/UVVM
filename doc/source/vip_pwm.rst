##################################################################################################################################
P2L2 VIP PWM
##################################################################################################################################

**Quick Access**

* `BFM`_

  * :ref:`pwm_generate_bfm`
  * :ref:`pwm_drive_period_bfm`
  * :ref:`pwm_drive_idle_bfm`
  * :ref:`pwm_measure_bfm`
  * :ref:`pwm_expect_bfm`
  * :ref:`pwm_duty_to_active_time_bfm`
  * :ref:`pwm_count_to_active_time_bfm`
  * :ref:`pwm_idle_value_bfm`
  * :ref:`pwm_generation_is_valid_bfm`

* `VVC`_

  * :ref:`pwm_generate_vvc`
  * :ref:`pwm_start_vvc`
  * :ref:`pwm_update_vvc`
  * :ref:`pwm_stop_vvc`
  * :ref:`pwm_abort_vvc`
  * :ref:`pwm_drive_idle_vvc`
  * :ref:`pwm_measure_vvc`
  * :ref:`pwm_expect_vvc`

**********************************************************************************************************************************
BFM
**********************************************************************************************************************************
BFM functionality is implemented in pwm_bfm_pkg.vhd

.. _t_pwm_bfm_config:

Configuration Record
==================================================================================================================================
**t_pwm_bfm_config**

Default value for the record is C_PWM_BFM_CONFIG_DEFAULT.

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| polarity                     | :ref:`t_pwm_polarity         | ACTIVE_HIGH     | Active level of the line. Generation and        |
|                              | <t_pwm_polarity>`            |                 | observation.                                    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| alignment                    | :ref:`t_pwm_alignment        | LEFT_ALIGNED    | Position of the pulse within the period.        |
|                              | <t_pwm_alignment>`           |                 | Generation only.                                |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| idle_level                   | :ref:`t_pwm_idle_level       | IDLE_INACTIVE   | Line level when no waveform is generated. With  |
|                              | <t_pwm_idle_level>`          |                 | IDLE_HIGH_Z, an observer tolerates 'Z' before   |
|                              |                              |                 | the first active-going edge.                    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| jitter                       | time                         | 0 ns            | Maximum random delay of each generated edge,    |
|                              |                              |                 | see :ref:`pwm_jitter`. 0 ns disables jitter, <  |
|                              |                              |                 | 0 ns gives a TB_ERROR. Generation only.         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| jitter_seed1                 | positive                     | C_RAND_INIT_SE\ | Seed of the jitter randomization, 1 to          |
|                              |                              | ED_1            | 2147483562 (range of ieee.math_real.uniform).   |
|                              |                              |                 | Every pwm_generate() call and every VVC run     |
|                              |                              |                 | starts from the seeds, so a run is              |
|                              |                              |                 | reproducible. The VVC shifts it by              |
|                              |                              |                 | GC_INSTANCE_IDX, see :ref:`pwm_jitter`.         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| jitter_seed2                 | positive                     | C_RAND_INIT_SE\ | Second seed of the jitter randomization, 1 to   |
|                              |                              | ED_2            | 2147483398 (range of ieee.math_real.uniform).   |
|                              |                              |                 | Out-of-range seeds are not checked by the BFM;  |
|                              |                              |                 | uniform() then reports an assertion error and   |
|                              |                              |                 | the jitter is no longer random.                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| period_tolerance             | time                         | 0 ns            | Absolute tolerance on the checked period        |
|                              |                              |                 | (inclusive), >= 0 ns, else a TB_ERROR.          |
|                              |                              |                 | Observation.                                    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| active_time_tolerance        | time                         | 0 ns            | Absolute tolerance on the checked active time   |
|                              |                              |                 | (inclusive), >= 0 ns, else a TB_ERROR.          |
|                              |                              |                 | Observation.                                    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| duty_tolerance               | real                         | 0.0             | Absolute tolerance on the checked duty cycle    |
|                              |                              |                 | (inclusive), 0.0 to 1.0. Observation.           |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| min_pulse_width              | time                         | 0 ns            | Pulses or gaps shorter than this raise an alert |
|                              |                              |                 | (glitch). 0 ns disables the check, < 0 ns gives |
|                              |                              |                 | a TB_ERROR. Observation.                        |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| timeout                      | time                         | C_UNDEFINED_TI\ | Maximum time of an observation, see             |
|                              |                              | ME              | :ref:`pwm_timeout`. C_UNDEFINED_TIME = not set, |
|                              |                              |                 | 0 ns = no timeout. Must be set for              |
|                              |                              |                 | pwm_measure() and pwm_expect() with duty        |
|                              |                              |                 | (else a TB_ERROR). Observation.                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| timeout_severity             | :ref:`t_alert_level`         | ERROR           | Alert level of missing activity: periods not    |
|                              |                              |                 | complete at the timeout. Observation.           |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| constant_level_severity      | :ref:`t_alert_level`         | NO_ALERT        | Alert level when pwm_measure() reports a        |
|                              |                              |                 | constant level. Observation.                    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| id_for_bfm                   | :ref:`t_msg_id               | ID_BFM          | Message ID used for logging general messages in |
|                              | <message_ids>`               |                 | the BFM                                         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

Methods
==================================================================================================================================
* All signals are active high unless config.polarity is ACTIVE_LOW.
* All parameters in brackets are optional.

.. note::

    * Invalid parameters raise a TB_ERROR alert. The procedure then returns without using time or changing the line.
    * The signal parameters are of type std_ulogic. A std_logic signal can be passed as well, because std_logic is a
      subtype of std_ulogic. Use std_logic where the line has several drivers, e.g. a generator and an observer VVC.

.. _pwm_generate_bfm:

pwm_generate()
----------------------------------------------------------------------------------------------------------------------------------
Generates num_periods complete periods on the line, then drives the idle level. The procedure returns at the end of the
last period. The first period starts at the call. 0 ns and period as active time give a constant level without edges
(0 % and 100 %). A duty cycle given as ratio or counter value is converted with :ref:`pwm_duty_to_active_time_bfm` or
:ref:`pwm_count_to_active_time_bfm`.

.. code-block::

    pwm_generate(period, active_time, num_periods, msg, pwm, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | period             | in     | time                         | The PWM period T. Must be > 0 ns.                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | active_time        | in     | time                         | The active time t_on. Must be within 0 ns to period.    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | num_periods        | in     | integer                      | Number of complete periods to generate, >= 1            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | pwm                | inout  | std_ulogic                   | The PWM line driven by the BFM                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("PWM BFM").   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_pwm_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_pwm_bfm_config>`          | value is C_PWM_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    pwm_generate(1 us, 250 ns, 10, "10 periods with 25 % duty", pwm, C_SCOPE, shared_msg_id_panel, C_PWM_BFM_CONFIG_DEFAULT);
    pwm_generate(1 us, pwm_count_to_active_time(64, 256, 1 us), 10, "10 periods with 64/256 duty", pwm, C_SCOPE, shared_msg_id_panel, C_PWM_BFM_CONFIG_DEFAULT);

    -- With the default values of the optional parameters:
    pwm_generate(1 us, pwm_duty_to_active_time(0.25, 1 us), 10, "10 periods with 25 % duty", pwm);


.. _pwm_drive_period_bfm:

pwm_drive_period()
----------------------------------------------------------------------------------------------------------------------------------
Drives one complete period according to config.polarity, config.alignment and config.jitter and returns at the end of
the period. Unlike pwm_generate(), the line is not returned to the idle level, so consecutive calls give a continuous
waveform, e.g. with parameters that change from period to period. The jitter seeds are passed as variables, so
consecutive calls continue the random sequence. A log message is written with ID config.id_for_bfm after each period.

The procedure returns at once with aborted = true when 'abort' has an event during the period. The line then keeps its
level; the caller drives the idle level, e.g. with pwm_drive_idle(). The VVC uses this for pwm_abort(); without a VVC,
pass a signal that is never toggled.

.. code-block::

    pwm_drive_period(period, active_time, seed1, seed2, aborted, msg, pwm, abort, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | period             | in     | time                         | The PWM period T. Must be > 0 ns.                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | active_time        | in     | time                         | The active time t_on. Must be within 0 ns to period.    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | seed1              | inout  | positive                     | Jitter seed, updated by the call. 1 to 2147483562,      |
|          |                    |        |                              | see config.jitter_seed1                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | seed2              | inout  | positive                     | Jitter seed, updated by the call. 1 to 2147483398,      |
|          |                    |        |                              | see config.jitter_seed2                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | aborted            | out    | boolean                      | True if the period was ended by 'abort'                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | pwm                | inout  | std_ulogic                   | The PWM line driven by the BFM                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | abort              | in     | boolean                      | An event ends the period at once                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("PWM BFM").   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_pwm_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_pwm_bfm_config>`          | value is C_PWM_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_seed1 := v_config.jitter_seed1;
    v_seed2 := v_config.jitter_seed2;
    pwm_drive_period(1 us, 250 ns, v_seed1, v_seed2, v_aborted, "25 % duty", pwm, abort, C_SCOPE, shared_msg_id_panel, v_config);
    pwm_drive_period(1 us, 500 ns, v_seed1, v_seed2, v_aborted, "50 % duty", pwm, abort, C_SCOPE, shared_msg_id_panel, v_config);
    pwm_drive_idle("End of the waveform", pwm, C_SCOPE, shared_msg_id_panel, v_config);

    -- With the default values of the optional parameters:
    pwm_drive_period(1 us, 500 ns, v_seed1, v_seed2, v_aborted, "50 % duty", pwm, abort);


.. _pwm_drive_idle_bfm:

pwm_drive_idle()
----------------------------------------------------------------------------------------------------------------------------------
Drives the idle level given by config.idle_level and config.polarity and writes a log message with ID config.id_for_bfm.
Use it at time 0 in a BFM-only testbench, as pwm_generate() only drives the idle level after the last period, and after
pwm_drive_period().

.. code-block::

    pwm_drive_idle(msg, pwm, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | pwm                | inout  | std_ulogic                   | The PWM line driven by the BFM                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("PWM BFM").   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_pwm_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_pwm_bfm_config>`          | value is C_PWM_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    pwm_drive_idle("Idle at start", pwm, C_SCOPE, shared_msg_id_panel, C_PWM_BFM_CONFIG_DEFAULT);

    -- With the default values of the optional parameters:
    pwm_drive_idle("Idle at start", pwm);


.. _pwm_measure_bfm:

pwm_measure()
----------------------------------------------------------------------------------------------------------------------------------
Measures num_periods complete periods and returns their mean values in a :ref:`t_pwm_measurement <t_pwm_measurement>`
record: the mean period and the mean active time, each rounded to the nearest simulator resolution unit (half a unit is
rounded up), the duty cycle of the sums, and the exact minimum and maximum of the period, the active time and the duty
cycle of the single periods. The measurement starts at the first active-going edge after the call; a period in progress
is ignored.

* If the line has no edge before the timeout, i.e. it holds one level for the whole measurement, the result is the
  constant level (is_constant = true, duty_cycle 0.0 or 1.0), with an alert of severity config.constant_level_severity (default NO_ALERT, i.e. a result, not an
  alert). Check is_constant before using the values, or set config.constant_level_severity to ERROR if a constant line is
  a failure in the test.
* If the periods are not complete at the timeout, a missing-activity alert with severity config.timeout_severity is
  raised and C_PWM_MEASUREMENT_DEFAULT is returned. This includes a line that goes to the inactive level during the
  measurement and then stays there: it is not constant, but no period began.
* A timeout must be set, per call or in config.timeout; else a TB_ERROR is raised and C_PWM_MEASUREMENT_DEFAULT is
  returned. With 0 ns, pwm_measure() waits until the periods are complete, on a constant line for ever. See
  :ref:`pwm_timeout`.
* Invalid levels and pulses or gaps shorter than config.min_pulse_width raise an ERROR alert.

.. code-block::

    pwm_measure(result, msg, pwm, terminate_loop, [num_periods, [timeout, [scope, [msg_id_panel, [config]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| variable | result             | out    | :ref:`t_pwm_measurement      | The measured period, active time and duty cycle         |
|          |                    |        | <t_pwm_measurement>`         |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | pwm                | in     | std_ulogic                   | The PWM line observed by the BFM                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_ulogic                   | '1' ends the observation at once, without an alert      |
|          |                    |        |                              | (logged with ID_TERMINATE_CMD). Used by the VVC for     |
|          |                    |        |                              | terminate_current_command(); without a VVC, pass a      |
|          |                    |        |                              | signal that stays '0'.                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | num_periods        | in     | integer                      | Number of periods to measure, >= 1. Default value is 1. |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time of the observation, from the call. Default |
|          |                    |        |                              | value is C_UNDEFINED_TIME, which leads to using         |
|          |                    |        |                              | config.timeout. 0 ns means no timeout. See              |
|          |                    |        |                              | :ref:`pwm_timeout`.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("PWM BFM").   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_pwm_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_pwm_bfm_config>`          | value is C_PWM_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    pwm_measure(v_result, "Measure the PWM output", pwm, terminate_loop, 1, 3 us, C_SCOPE, shared_msg_id_panel, C_PWM_BFM_CONFIG_DEFAULT);
    pwm_measure(v_result, "Mean of 8 periods", pwm, terminate_loop, 8, 10 us, C_SCOPE, shared_msg_id_panel, C_PWM_BFM_CONFIG_DEFAULT);

    -- With the default values of the optional parameters (one period, the timeout from config.timeout, which must then be set):
    pwm_measure(v_result, "Measure the PWM output", pwm, terminate_loop);


.. _pwm_expect_bfm:

pwm_expect()
----------------------------------------------------------------------------------------------------------------------------------
Checks num_periods consecutive periods. The expected waveform is given as period and active time, or as duty cycle:

* With period and active_time, each period is checked within config.period_tolerance and config.active_time_tolerance
  (inclusive). An active time given as counter value is converted with :ref:`pwm_count_to_active_time_bfm`.
* With duty, the duty cycle of each period is checked within config.duty_tolerance (inclusive; a margin of 1.0e-12 is
  added against real rounding), independent of the period.

For all overloads:

* If all periods match, a log message is written with ID config.id_for_bfm.
* Each failing period raises one alert with severity 'alert_level', naming the period index and the measured and expected
  values with the tolerance.
* active_time = 0 ns or = period checks that the line holds the inactive or active level for num_periods * period; the
  timeout is not used. duty = 0.0 or 1.0 checks the same for the timeout, which must then be > 0 ns (else a
  TB_ERROR). A wrong level or a change in the window raises one alert.
* With duty, a timeout must be set, per call or in config.timeout (else a TB_ERROR), see :ref:`pwm_timeout`.
* If the periods are not complete at the timeout, a missing-activity alert with severity config.timeout_severity is
  raised and the check ends. With a period and no timeout set, the timeout is
  (num_periods + 2) * (period + config.period_tolerance), see :ref:`pwm_timeout`.

.. code-block::

    pwm_expect(period, active_time, msg, pwm, terminate_loop, [num_periods, [timeout, [alert_level, [scope, [msg_id_panel, [config]]]]]])
    pwm_expect(duty, msg, pwm, terminate_loop, [num_periods, [timeout, [alert_level, [scope, [msg_id_panel, [config]]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | period             | in     | time                         | The expected period. Must be > 0 ns.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | active_time        | in     | time                         | The expected active time, 0 ns to period                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | duty               | in     | real                         | The expected duty cycle, 0.0 to 1.0                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | pwm                | in     | std_ulogic                   | The PWM line observed by the BFM                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_ulogic                   | '1' ends the observation at once, without an alert      |
|          |                    |        |                              | (logged with ID_TERMINATE_CMD). Used by the VVC for     |
|          |                    |        |                              | terminate_current_command(); without a VVC, pass a      |
|          |                    |        |                              | signal that stays '0'.                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | num_periods        | in     | integer                      | Number of consecutive periods to check, >= 1. Default   |
|          |                    |        |                              | value is 1.                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time of the observation, from the call. Default |
|          |                    |        |                              | value is C_UNDEFINED_TIME, which leads to using         |
|          |                    |        |                              | config.timeout. 0 ns means no timeout. See              |
|          |                    |        |                              | :ref:`pwm_timeout`.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is       |
|          |                    |        |                              | ERROR.                                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("PWM BFM").   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_pwm_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_pwm_bfm_config>`          | value is C_PWM_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    pwm_expect(1 us, 250 ns, "Check 5 periods", pwm, terminate_loop, 5, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, C_PWM_BFM_CONFIG_DEFAULT);
    pwm_expect(1 us, pwm_count_to_active_time(64, 256, 1 us), "Check 5 periods with 64/256 duty", pwm, terminate_loop, 5, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
    pwm_expect(0.25, "Check 25 % duty", pwm, terminate_loop, 10, 15 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);

    -- With the default values of the optional parameters:
    pwm_expect(1 us, 250 ns, "Check 5 periods", pwm, terminate_loop, 5);


.. _pwm_duty_to_active_time_bfm:

pwm_duty_to_active_time()
----------------------------------------------------------------------------------------------------------------------------------
Returns duty * period as active time, rounded to the nearest simulator resolution unit (half a unit is rounded up). A duty
outside 0.0 to 1.0 gives an active time that the generation and check procedures reject with a TB_ERROR.

.. code-block::

    time := pwm_duty_to_active_time(duty, period)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | duty               | in     | real                         | Duty cycle, 0.0 to 1.0                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | period             | in     | time                         | The PWM period T. Must be > 0 ns.                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    pwm_generate(1 us, pwm_duty_to_active_time(0.25, 1 us), 10, "10 periods with 25 % duty", pwm);


.. _pwm_count_to_active_time_bfm:

pwm_count_to_active_time()
----------------------------------------------------------------------------------------------------------------------------------
Returns (count / resolution) * period as active time, rounded as :ref:`pwm_duty_to_active_time_bfm`, e.g. for the compare
value of a PWM counter. A count above resolution gives an active time that the generation and check procedures reject
with a TB_ERROR.

.. code-block::

    time := pwm_count_to_active_time(count, resolution, period)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | count              | in     | natural                      | Counter value of the active time, 0 to resolution       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | resolution         | in     | positive                     | Counter value of the period                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | period             | in     | time                         | The PWM period T. Must be > 0 ns.                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    pwm_generate(1 us, pwm_count_to_active_time(64, 256, 1 us), 10, "10 periods with 64/256 duty", pwm);


.. _pwm_idle_value_bfm:

pwm_idle_value()
----------------------------------------------------------------------------------------------------------------------------------
Returns the value driven on the line when idle, given by config.idle_level and config.polarity ('Z' for IDLE_HIGH_Z).

.. code-block::

    std_ulogic := pwm_idle_value(config)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | config             | in     | :ref:`t_pwm_bfm_config       | Configuration of BFM behavior and restrictions          |
|          |                    |        | <t_pwm_bfm_config>`          |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    check_value(pwm, pwm_idle_value(C_PWM_BFM_CONFIG_DEFAULT), ERROR, "Line is idle", C_SCOPE);


.. _pwm_generation_is_valid_bfm:

pwm_generation_is_valid()
----------------------------------------------------------------------------------------------------------------------------------
Returns true if period > 0 ns, 0 ns <= active_time <= period, num_periods >= 1 and jitter >= 0 ns. Otherwise it raises
one TB_ERROR naming proc_call and returns false. This is the parameter check of the BFM procedures and the VVC.

.. code-block::

    boolean := pwm_generation_is_valid(period, active_time, proc_call, msg, [scope, [num_periods, [jitter]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | period             | in     | time                         | The PWM period T                                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | active_time        | in     | time                         | The active time t_on                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | proc_call          | in     | string                       | Name of the calling procedure, used in the alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("PWM BFM").   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | num_periods        | in     | integer                      | Number of periods. Default value is 1.                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | jitter             | in     | time                         | Maximum jitter. Default value is 0 ns.                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    -- In a procedure that drives its own PWM waveform:
    if not pwm_generation_is_valid(period, active_time, "my_pwm_procedure()", msg, C_SCOPE, num_periods) then
      return;
    end if;


Local types
==================================================================================================================================
.. _t_pwm_role:

t_pwm_role
----------------------------------------------------------------------------------------------------------------------------------
Role of a VVC instance, see :ref:`pwm_roles`.

.. code-block::

    GENERATOR, OBSERVER

.. _t_pwm_polarity:

t_pwm_polarity
----------------------------------------------------------------------------------------------------------------------------------
Level of the active part of the period.

.. code-block::

    ACTIVE_HIGH, ACTIVE_LOW

.. _t_pwm_alignment:

t_pwm_alignment
----------------------------------------------------------------------------------------------------------------------------------
Position of the pulse within the period, see :ref:`pwm_waveform`.

.. code-block::

    LEFT_ALIGNED, RIGHT_ALIGNED, CENTER_ALIGNED

.. _t_pwm_idle_level:

t_pwm_idle_level
----------------------------------------------------------------------------------------------------------------------------------
Line level when no waveform is generated.

.. code-block::

    IDLE_INACTIVE, IDLE_ACTIVE, IDLE_HIGH_Z

.. _t_pwm_measurement:

t_pwm_measurement
----------------------------------------------------------------------------------------------------------------------------------
Result of :ref:`pwm_measure_bfm`. Default value (also the result after a missing-activity alert or a terminate) is
C_PWM_MEASUREMENT_DEFAULT.

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| period                       | time                         | 0 ns            | Active-going edge to active-going edge, mean    |
|                              |                              |                 | over the measured periods. 0 ns when            |
|                              |                              |                 | is_constant.                                    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| active_time                  | time                         | 0 ns            | Active-going edge to inactive-going edge, mean  |
|                              |                              |                 | over the measured periods. 0 ns when            |
|                              |                              |                 | is_constant.                                    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| duty_cycle                   | real                         | 0.0             | Sum of the active times / sum of the periods.   |
|                              |                              |                 | When is_constant: 1.0 for the active level,     |
|                              |                              |                 | else 0.0 (inactive level or 'Z').               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| min_period                   | time                         | 0 ns            | Shortest measured period. 0 ns when             |
|                              |                              |                 | is_constant.                                    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| max_period                   | time                         | 0 ns            | Longest measured period. 0 ns when is_constant. |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| min_active_time              | time                         | 0 ns            | Shortest measured active time. 0 ns when        |
|                              |                              |                 | is_constant.                                    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| max_active_time              | time                         | 0 ns            | Longest measured active time. 0 ns when         |
|                              |                              |                 | is_constant.                                    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| min_duty_cycle               | real                         | 0.0             | Smallest duty cycle of a single period. As      |
|                              |                              |                 | duty_cycle when is_constant. A period of 0 ns   |
|                              |                              |                 | (zero-width glitch) counts as 0.0.              |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| max_duty_cycle               | real                         | 0.0             | Largest duty cycle of a single period. As       |
|                              |                              |                 | duty_cycle when is_constant.                    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| is_constant                  | boolean                      | false           | No edge within the timeout: the line held       |
|                              |                              |                 | constant_level for the whole measurement (0 %   |
|                              |                              |                 | or 100 %).                                      |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| constant_level               | std_ulogic                   | 'U'             | Line level when is_constant ('0', '1', or 'Z'   |
|                              |                              |                 | with IDLE_HIGH_Z; 'L'/'H' as '0'/'1'), else 'U'.|
|                              |                              |                 | Any other value is reported as it is, after an  |
|                              |                              |                 | ERROR alert for the invalid level.              |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+


Local BFM overloads
==================================================================================================================================
All optional parameters of the PWM BFM procedures have default values, so a call with the key parameters only uses
C_BFM_SCOPE, shared_msg_id_panel and C_PWM_BFM_CONFIG_DEFAULT, e.g. ::

    pwm_expect(1 us, 250 ns, "Check 5 periods", pwm, terminate_loop, 5);

A good approach for better readability and maintainability, when the testbench uses its own configuration or scope, is to
make simple, local overloads for the BFM procedures in the TB process. A local overload with the same parameters as the
call above would be ambiguous, because the BFM procedure matches the call through its default values. Leave out the
signals instead, which the local procedure can read directly, e.g. ::

    pwm_expect(1 us, 250 ns, "Check 5 periods", 5);

rather than ::

    pwm_expect(1 us, 250 ns, "Check 5 periods", pwm, terminate_loop, 5, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, C_PWM_CONFIG_LOCAL);

By defining the local overload as e.g. ::

    procedure pwm_expect(
      constant period      : in time;
      constant active_time : in time;
      constant msg         : in string;
      constant num_periods : in integer := 1) is
    begin
      pwm_expect(period,               -- Keep as is
                active_time,          -- Keep as is
                msg,                  -- Keep as is
                pwm,                  -- The TB signal
                terminate_loop,       -- A TB signal that stays '0'
                num_periods,          -- Keep as is
                C_UNDEFINED_TIME,     -- Use the timeout from the config
                ERROR,                -- Use the default
                C_SCOPE,              -- Use the TB scope
                shared_msg_id_panel,  -- Use global, shared msg_id_panel
                C_PWM_CONFIG_LOCAL);  -- Use locally defined configuration
    end procedure;

Using a local overload like this also allows the following – if wanted:

* Set up defaults for constants. May be different for two overloads of the same BFM
* Apply dedicated message ID panel to allow dedicated verbosity control

.. note::

    The generation procedures drive the signal, so a local overload of pwm_generate() without the signal parameter must be
    declared in the process that drives the signal.


Compilation
==================================================================================================================================
.. include:: rst_snippets/bfm_compilation.rst

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst

.. _pwm_additional_doc:

Additional Documentation
==================================================================================================================================
PWM has no formal protocol specification. The waveform, the jitter and the observation rules this BFM follows are
described below.

.. important::

    * This BFM generates, measures and checks a single PWM line as described below.
    * The BFM is not a complete PWM protocol checker, only the listed checks are made.
    * Out of scope: complementary outputs and dead time, multi-phase PWM, mid-period updates, phase-correct counter modes,
      randomised PWM as a protocol mode (only the bounded jitter), analogue effects and PDM.


.. _pwm_waveform:

Waveform
----------------------------------------------------------------------------------------------------------------------------------
A pulse-width modulated (PWM) line is a periodic signal with period T and active time t_on (duty cycle D = t_on/T). A
period of length T contains one active pulse of length t_on and one inactive interval t_off = T - t_on. The alignment
sets where the pulse sits within the period:


+------------------------------+--------------------------------------------------------------------------------------------------+
| Alignment                    | Waveform within one period [0, T)                                                                |
+==============================+==================================================================================================+
| LEFT_ALIGNED (default)       | Active during [0, t_on), inactive during [t_on, T)                                               |
+------------------------------+--------------------------------------------------------------------------------------------------+
| RIGHT_ALIGNED                | Inactive during [0, t_off), active during [t_off, T)                                             |
+------------------------------+--------------------------------------------------------------------------------------------------+
| CENTER_ALIGNED               | Inactive during [0, t_off/2), active for t_on, then inactive for the rest. If t_off is odd in    |
|                              | resolution units, the extra unit goes to the second inactive interval.                           |
+------------------------------+--------------------------------------------------------------------------------------------------+

* t_on = 0 ns (0 %) and t_on = T (100 %) give a constant inactive or active level without edges. Switching between these
  and other duty cycles gives no glitches.
* Active times converted from a duty or count/resolution are rounded to the nearest simulator resolution unit, half a
  unit up.
* Edge times are computed in simulator resolution units (std.env.resolution_limit). Waveforms with sub-ns times need a
  finer resolution than the Questa default of 1 ns, e.g. ``vsim -t ps``.
* An observer measures T from active-going edge to active-going edge and t_on from the active-going to the inactive-going
  edge. It cannot tell alignments apart from a constant waveform.
* An observer sees one complete period fewer than a pwm_generate() of num_periods produces: a period ends with the next
  active-going edge, and after the last period the line stays at the idle level, so the last period has no closing edge.
  With IDLE_ACTIVE and left alignment, the first period has no active-going edge instead, because the line is already
  at the active level, and the return to the idle level closes the last period. To check every generated period, check
  num_periods - 1 periods, or generate one period more than checked.
* An observer that starts in the same time step as the generator can miss the first active-going edge, because the
  edge may come a few delta cycles before the observer waits for it. Start the observer earlier, e.g. before the
  generator in the sequencer with some time in between, or check one period fewer.
* An observer reads the weak levels 'L' and 'H' as '0' and '1', e.g. on a line with a pull resistor. A change between a
  strong and a weak value of the same level (e.g. '1' to 'H') is no edge. Any other value than '0', '1', 'L' and 'H'
  raises an alert, except 'Z' before the first active-going edge with IDLE_HIGH_Z.
* An observer cannot detect a wrong polarity either: with the opposite config.polarity, it measures the same T, but
  T - t_on as active time and 1 - d as duty cycle, so a 50 % signal passes every check. Set config.polarity of the
  observer to the polarity of the signal.


.. _pwm_jitter:

Jitter
----------------------------------------------------------------------------------------------------------------------------------
With config.jitter = j > 0 ns, every generated edge is delayed by a random offset in [0, j] (uniform distribution) from
its ideal time. Edges are only delayed, never moved earlier. A period and an active time each lie between two edges,
so they vary by up to +/- j. The offsets do not accumulate and every edge gets the same distribution,
so the mean period stays T and the mean active time stays t_on. On average, the waveform is j/2 later than without
jitter, including the first edge after a start.

Edges are never reordered, every pulse and gap stays at least one resolution unit long, and every edge stays within its
period; offsets that would break this are clamped, but an edge always stays within [0, j] of its ideal time. Clamping
only happens with a pulse or gap not longer than j, and only then can the mean active time differ from t_on. A period
start without an edge, e.g. center-aligned when the line is already inactive, is not moved and does not delay the
following edge. The randomization starts from config.jitter_seed1/2 in every pwm_generate() call and every VVC run, so
a run with the same seeds is reproducible. 0 % and 100 % are not affected.

In the VVC, seed 1 is shifted by the instance index (GC_INSTANCE_IDX, wrapped within the seed range of
ieee.math_real.uniform), so VVC instances with the same configuration jitter independently. Instance 0 uses the
configured seeds unchanged and generates the same waveform as the BFM. For identical jitter on two instances, lower
config.jitter_seed1 of the instance with the higher index by the index difference.


.. _pwm_timeout:

Observation rules and timeout
----------------------------------------------------------------------------------------------------------------------------------
* The timeout is the maximum time of the whole observation, counted from the call (from the start of the command in the
  VVC).
* A per-call timeout overrides config.timeout. If neither is set, pwm_expect() with a period uses
  (num_periods + 2) * (period + config.period_tolerance): one period to reach the first active-going edge, the periods
  themselves and one period of margin. pwm_measure() and pwm_expect() with duty have no period to derive a timeout
  from, so they raise a TB_ERROR and return at once (as gpio_expect()): set config.timeout once, e.g. in
  GC_PWM_BFM_CONFIG, or give a timeout per call.
* 0 ns means no timeout, i.e. waiting without limit; a negative timeout gives a TB_ERROR.
* With timeout 0 ns, an observation on a constant line never ends. In the VVC, the command then blocks all later
  commands of that VVC instance: the timeout of await_completion() raises an alert in the sequencer but does not end the
  command. terminate_current_command() ends it at once, without an alert.
* An edge exactly at the end of the timeout is counted only if it happens in the first delta cycle of that time, e.g.
  when driven earlier with 'after'; an edge in a later delta cycle is not. Leave some margin, e.g. (num_periods + 2)
  periods.
* An edge is a change between '0' and '1'. Any other value raises an alert each time the line changes to it; an invalid
  value that returns to the same level is no edge. Before the first active-going edge, 'Z' is tolerated with
  IDLE_HIGH_Z.
* Alert levels: invalid levels and pulses or gaps shorter than config.min_pulse_width raise ERROR in pwm_measure() and
  'alert_level' in the checks; missing activity at the timeout uses config.timeout_severity; a constant level reported
  by pwm_measure() uses config.constant_level_severity.


**********************************************************************************************************************************
VVC
**********************************************************************************************************************************
* VVC functionality is implemented in pwm_vvc.vhd
* For general information see :ref:`vvc_framework_vvc_mechanisms_and_features`.

Entity
==================================================================================================================================

Generics
----------------------------------------------------------------------------------------------------------------------------------

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Name                         | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| GC_INSTANCE_IDX              | natural                      | 1               | Instance number to assign the VVC. Maximum      |
|                              |                              |                 | value is defined by C_PWM_VVC_MAX_INSTANCE_NUM  |
|                              |                              |                 | in adaptations_pkg.                             |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_ROLE                      | :ref:`t_pwm_role             | GENERATOR       | Role of the VVC instance, fixed at elaboration. |
|                              | <t_pwm_role>`                |                 | See :ref:`pwm_roles`.                           |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_PWM_BFM_CONFIG            | :ref:`t_pwm_bfm_config       | C_PWM_BFM_CONF\ | Configuration for the PWM BFM. A generator      |
|                              | <t_pwm_bfm_config>`          | IG_DEFAULT      | drives the idle level given by this             |
|                              |                              |                 | configuration from time 0.                      |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_CMD_QUEUE_COUNT_MAX       | natural                      | C_CMD_QUEUE_CO\ | Absolute maximum number of commands in the VVC  |
|                              |                              | UNT_MAX         | command queue                                   |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_CMD_QUEUE_COUNT_THRESHOLD | natural                      | C_CMD_QUEUE_CO\ | An alert will be generated when reaching this   |
|                              |                              | UNT_THRESHOLD   | threshold to indicate that the command queue is |
|                              |                              |                 | almost full. The queue will still accept new    |
|                              |                              |                 | commands until it reaches                       |
|                              |                              |                 | GC_CMD_QUEUE_COUNT_MAX.                         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_CMD_QUEUE_COUNT_THRESHOL\ | :ref:`t_alert_level`         | C_CMD_QUEUE_CO\ | Alert severity which will be used when command  |
| D_SEVERITY                   |                              | UNT_THRESHOLD\  | queue reaches GC_CMD_QUEUE_COUNT_THRESHOLD      |
|                              |                              | _SEVERITY       |                                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_RESULT_QUEUE_COUNT_MAX    | natural                      | C_RESULT_QUEUE\ | Maximum number of unfetched results before      |
|                              |                              | _COUNT_MAX      | result_queue is full                            |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_RESULT_QUEUE_COUNT_THRES\ | natural                      | C_RESULT_QUEUE\ | An alert will be issued if result queue exceeds |
| HOLD                         |                              | _COUNT_THRESHO\ | this count. Used for early warning if result    |
|                              |                              | LD              | queue is almost full. Will be ignored if set to |
|                              |                              |                 | 0.                                              |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_RESULT_QUEUE_COUNT_THRES\ | :ref:`t_alert_level`         | C_RESULT_QUEUE\ | Severity of alert to be initiated if exceeding  |
| HOLD_SEVERITY                |                              | _COUNT_THRESHO\ | GC_RESULT_QUEUE_COUNT_THRESHOLD                 |
|                              |                              | LD_SEVERITY     |                                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

.. note::

    Default values for the cmd/result queue generics are defined in adaptations_pkg.

Signals
----------------------------------------------------------------------------------------------------------------------------------

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | pwm_vvc_if         | inout  | std_logic                    | The PWM line. Default value 'Z'.                        |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | GENERATOR: driven with the idle level from time 0 and   |
|          |                    |        |                              | with the waveform.                                      |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | OBSERVER: always driven 'Z' and only read, so a         |
|          |                    |        |                              | generator and observers can share one line.             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The connected TB signal must be of the resolved type    |
|          |                    |        |                              | std_logic, also for an OBSERVER on a DUT output: the    |
|          |                    |        |                              | inout port is a source of the signal, so an unresolved  |
|          |                    |        |                              | std_ulogic signal gives an elaboration error (multiple  |
|          |                    |        |                              | sources).                                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

Configuration Record
==================================================================================================================================
**vvc_config** accessible via **shared_pwm_vvc_config**

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| inter_bfm_delay              | :ref:`t_inter_bfm_delay`     | C_PWM_INTER_BF\ | Delay between any requested BFM accesses        |
|                              |                              | M_DELAY_DEFAULT | towards the DUT. Applies to pwm_generate(),     |
|                              |                              |                 | pwm_start() and the observer commands.          |
|                              |                              |                 |                                                 |
|                              |                              |                 | TIME_START2START: Time from a BFM start to the  |
|                              |                              |                 | next BFM start (a TB_WARNING will be issued if  |
|                              |                              |                 | access takes longer than TIME_START2START).     |
|                              |                              |                 |                                                 |
|                              |                              |                 | TIME_FINISH2START: Time from a BFM end to the   |
|                              |                              |                 | next BFM start.                                 |
|                              |                              |                 |                                                 |
|                              |                              |                 | Any insert_delay() command will add to the      |
|                              |                              |                 | above minimum delays, giving for instance the   |
|                              |                              |                 | ability to skew the BFM starting time.          |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| cmd_queue_count_max          | natural                      | C_CMD_QUEUE_CO\ | Maximum pending number in command queue before  |
|                              |                              | UNT_MAX         | queue is full. Adding additional commands will  |
|                              |                              |                 | result in an ERROR.                             |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| cmd_queue_count_threshold    | natural                      | C_CMD_QUEUE_CO\ | An alert will be issued if command queue        |
|                              |                              | UNT_THRESHOLD   | exceeds this count. Used for early warning if   |
|                              |                              |                 | command queue is almost full. Will be ignored   |
|                              |                              |                 | if set to 0.                                    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| cmd_queue_count_threshold_s\ | :ref:`t_alert_level`         | C_CMD_QUEUE_CO\ | Severity of alert to be initiated if exceeding  |
| everity                      |                              | UNT_THRESHOLD\  | cmd_queue_count_threshold                       |
|                              |                              | _SEVERITY       |                                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| result_queue_count_max       | natural                      | C_RESULT_QUEUE\ | Maximum number of unfetched results before      |
|                              |                              | _COUNT_MAX      | result_queue is full                            |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| result_queue_count_threshold | natural                      | C_RESULT_QUEUE\ | An alert will be issued if result queue exceeds |
|                              |                              | _COUNT_THRESHO\ | this count. Used for early warning if result    |
|                              |                              | LD              | queue is almost full. Will be ignored if set to |
|                              |                              |                 | 0.                                              |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| result_queue_count_threshol\ | :ref:`t_alert_level`         | C_RESULT_QUEUE\ | Severity of alert to be initiated if exceeding  |
| d_severity                   |                              | _COUNT_THRESHO\ | result_queue_count_threshold                    |
|                              |                              | LD_SEVERITY     |                                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| bfm_config                   | :ref:`t_pwm_bfm_config       | C_PWM_BFM_CONF\ | Configuration for the PWM BFM. A generator      |
|                              | <t_pwm_bfm_config>`          | IG_DEFAULT      | takes changes at the next period boundary, an   |
|                              |                              |                 | observer at the next command.                   |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| msg_id_panel                 | t_msg_id_panel               | C_VVC_MSG_ID_P\ | VVC dedicated message ID panel. See             |
|                              |                              | ANEL_DEFAULT    | :ref:`vvc_framework_verbosity_ctrl` for how to  |
|                              |                              |                 | use verbosity control.                          |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

.. note::

    cmd/result queue parameters in the configuration record are unused and will be removed in v3.0, use instead the entity generic constants.

The configuration record can be accessed from the Central Testbench Sequencer through the shared variable array, e.g. ::

    shared_pwm_vvc_config(C_VVC_IDX).bfm_config.alignment := CENTER_ALIGNED;

Set a polarity and idle level that stay fixed for the whole test in the generic GC_PWM_BFM_CONFIG: the generator then
drives the right idle level from time 0. When config.polarity or config.idle_level is changed in shared_pwm_vvc_config,
call pwm_drive_idle() before the next run (see :ref:`pwm_drive_idle_vvc`).

Status Record
==================================================================================================================================
**vvc_status** accessible via **shared_pwm_vvc_status**

.. include:: rst_snippets/vip_vvc_status.rst

Methods
==================================================================================================================================
* All VVC procedures are defined in vvc_methods_pkg.vhd (dedicated to this VVC).
* See :ref:`vvc_framework_methods` for procedures which are common to all VVCs.
* It is also possible to send a multicast to all instances of a VVC with ALL_INSTANCES as parameter for vvc_instance_idx.
* All parameters in brackets are optional.

.. note::

    Generator methods are only accepted by a GENERATOR instance, observer methods only by an OBSERVER instance, see
    :ref:`pwm_roles`. A multicast with ALL_INSTANCES reaches every instance, whatever its role. If the testbench has both
    GENERATOR and OBSERVER instances, each instance of the other role raises an ERROR and skips the command. Use
    ALL_INSTANCES only for methods that all instances accept, e.g. the common VVC methods, or when all instances have the
    same role.

.. note::

    Some parameters in the VVC procedures are unconstrained for flexibility. However, the maximum sizes of such parameters need to
    be defined for the VVC framework. For this VVC, the following maximum values can be configured from adaptations_pkg:

      +--------------------------------------------+--------------------------------------+
      | C_PWM_VVC_CMD_STRING_MAX_LENGTH            | Maximum **msg** length               |
      +--------------------------------------------+--------------------------------------+

.. _pwm_generate_vvc:

pwm_generate()
----------------------------------------------------------------------------------------------------------------------------------
Adds a generate command to the PWM VVC executor queue, which will run as soon as all preceding commands have completed.
The VVC generates num_periods complete periods, as the BFM :ref:`pwm_generate_bfm`, then drives the idle level. The
command completes at the end of the last period. GENERATOR role only. A TB_ERROR is raised if a continuous run is active.

.. code-block::

    pwm_generate(VVCT, vvc_instance_idx, period, active_time, num_periods, msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | period             | in     | time                         | The PWM period T. Must be > 0 ns.                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | active_time        | in     | time                         | The active time t_on. Must be within 0 ns to period.    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | num_periods        | in     | integer                      | Number of complete periods to generate, >= 1            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    pwm_generate(PWM_VVCT, 1, 1 us, 250 ns, 10, "10 periods with 25 % duty", C_SCOPE);
    pwm_generate(PWM_VVCT, 1, 1 us, pwm_duty_to_active_time(0.25, 1 us), 10, "10 periods with 25 % duty", C_SCOPE);
    pwm_generate(PWM_VVCT, 1, 1 us, pwm_count_to_active_time(64, 256, 1 us), 10, "10 periods with 64/256 duty", C_SCOPE);


.. _pwm_start_vvc:

pwm_start()
----------------------------------------------------------------------------------------------------------------------------------
Adds a start command to the PWM VVC executor queue. The VVC starts continuous generation, which runs until
:ref:`pwm_stop_vvc` or :ref:`pwm_abort_vvc`. The command completes when the first period begins, so the executor is free
for further commands while the waveform runs. GENERATOR role only. A TB_ERROR is raised if a run is already active.

.. code-block::

    pwm_start(VVCT, vvc_instance_idx, period, active_time, msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | period             | in     | time                         | The PWM period T. Must be > 0 ns.                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | active_time        | in     | time                         | The active time t_on. Must be within 0 ns to period.    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    pwm_start(PWM_VVCT, 1, 1 us, pwm_duty_to_active_time(0.5, 1 us), "Start 1 MHz, 50 %", C_SCOPE);


.. _pwm_update_vvc:

pwm_update()
----------------------------------------------------------------------------------------------------------------------------------
Adds an update command to the PWM VVC executor queue. The new period and duty cycle of the continuous generation
take effect at the next period boundary; the current period is completed with the old values. The command completes when
the new values took effect. GENERATOR role only. A TB_ERROR is raised if no continuous run is active.
terminate_current_command() withdraws an update that has not taken effect yet.

.. code-block::

    pwm_update(VVCT, vvc_instance_idx, period, active_time, msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | period             | in     | time                         | The PWM period T. Must be > 0 ns.                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | active_time        | in     | time                         | The active time t_on. Must be within 0 ns to period.    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    pwm_update(PWM_VVCT, 1, 1 us, pwm_duty_to_active_time(0.75, 1 us), "Change to 75 %", C_SCOPE);


.. _pwm_stop_vvc:

pwm_stop()
----------------------------------------------------------------------------------------------------------------------------------
Adds a stop command to the PWM VVC executor queue. The continuous generation ends at the next period boundary
(the current period is completed), then the VVC drives the idle level. The command completes when the line is idle.
GENERATOR role only. A TB_ERROR is raised if no continuous run is active. terminate_current_command() withdraws a stop that
has not taken effect yet; the continuous generation then continues.

.. code-block::

    pwm_stop(VVCT, vvc_instance_idx, msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    pwm_stop(PWM_VVCT, 1, "Stop at the next period boundary", C_SCOPE);


.. _pwm_abort_vvc:

pwm_abort()
----------------------------------------------------------------------------------------------------------------------------------
Adds an abort command to the PWM VVC executor queue, which will run as soon as all preceding commands have completed. It
ends a continuous run (:ref:`pwm_start_vvc`) at once, possibly cutting the current period short, and the VVC drives the
idle level. GENERATOR role only. A TB_ERROR is raised if no continuous run is active.

The abort cuts the waveform at once only if no command is queued before it: behind a pwm_update() it waits for the next
period boundary, behind a pwm_stop() the run has already ended. To end a pwm_generate() burst early, use
terminate_current_command().

.. code-block::

    pwm_abort(VVCT, vvc_instance_idx, msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    pwm_abort(PWM_VVCT, 1, "Abort now", C_SCOPE);


.. _pwm_drive_idle_vvc:

pwm_drive_idle()
----------------------------------------------------------------------------------------------------------------------------------
Adds a drive-idle command to the PWM VVC executor queue. The VVC drives the idle level of the current configuration
(config.idle_level and config.polarity) at once. GENERATOR role only. A TB_ERROR is raised if a continuous run is active.

The VVC drives the idle level by itself only at time 0 (from GC_PWM_BFM_CONFIG) and at the end of each run. Call
pwm_drive_idle() after changing config.polarity or config.idle_level in shared_pwm_vvc_config, before the next run.
Otherwise the line stays at the old idle level, which can be the new active level, so the first edge of the next run may
be missing. pwm_generate() and pwm_start() raise a WARNING in this case.

.. code-block::

    pwm_drive_idle(VVCT, vvc_instance_idx, msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    shared_pwm_vvc_config(1).bfm_config.polarity := ACTIVE_LOW;
    pwm_drive_idle(PWM_VVCT, 1, "Idle level of the active-low config", C_SCOPE);


.. _pwm_measure_vvc:

pwm_measure()
----------------------------------------------------------------------------------------------------------------------------------
Adds a measure command to the PWM VVC executor queue, which will run as soon as all preceding commands have completed. When
the command is scheduled to run, the executor calls the BFM :ref:`pwm_measure_bfm` procedure with the VVC configuration:
it measures num_periods periods and returns their mean values. OBSERVER role only.

The measurement will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but it will
be stored in the VVC for a potential future fetch (see example with fetch_result below).

.. code-block::

    pwm_measure(VVCT, vvc_instance_idx, msg, [num_periods, [timeout, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | num_periods        | in     | integer                      | Number of periods to measure, >= 1. Default value is 1. |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time of the observation, from the call. Default |
|          |                    |        |                              | value is C_UNDEFINED_TIME, which leads to using         |
|          |                    |        |                              | config.timeout. 0 ns means no timeout. See              |
|          |                    |        |                              | :ref:`pwm_timeout`.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    pwm_measure(PWM_VVCT, 2, "Measure the PWM output", 1, 3 us, C_SCOPE);
    pwm_measure(PWM_VVCT, 2, "Mean of 8 periods", 8, 10 us, C_SCOPE);

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;           -- Command index for the last measurement
    variable v_result  : t_pwm_measurement; -- Result of the measurement (t_vvc_result is a subtype of it)
    ...
    pwm_measure(PWM_VVCT, 2, "Measure the PWM output", 1, 3 us);
    v_cmd_idx := get_last_received_cmd_idx(PWM_VVCT, 2);
    await_completion(PWM_VVCT, 2, v_cmd_idx, 10 us, "Wait for the measurement to finish");
    fetch_result(PWM_VVCT, 2, v_cmd_idx, v_result, "Fetching the measurement");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP, as a subtype of
    :ref:`t_pwm_measurement <t_pwm_measurement>`. vvc_context does not include vvc_cmd_pkg, so use t_pwm_measurement in the
    testbench.


.. _pwm_expect_vvc:

pwm_expect()
----------------------------------------------------------------------------------------------------------------------------------
Adds a check command to the PWM VVC executor queue, which will run as soon as all preceding commands have completed.
When the command is scheduled to run, the executor calls the BFM :ref:`pwm_expect_bfm` procedure with the VVC
configuration. The expected waveform is given as period and active time, or as duty cycle (the transaction info
operation is then EXPECT_DUTY). OBSERVER role only.

.. code-block::

    pwm_expect(VVCT, vvc_instance_idx, period, active_time, msg, [num_periods, [timeout, [alert_level, [scope]]]])
    pwm_expect(VVCT, vvc_instance_idx, duty, msg, [num_periods, [timeout, [alert_level, [scope]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | period             | in     | time                         | The expected period. Must be > 0 ns.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | active_time        | in     | time                         | The expected active time, 0 ns to period                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | duty               | in     | real                         | The expected duty cycle, 0.0 to 1.0                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | num_periods        | in     | integer                      | Number of consecutive periods to check, >= 1. Default   |
|          |                    |        |                              | value is 1.                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time of the observation, from the call. Default |
|          |                    |        |                              | value is C_UNDEFINED_TIME, which leads to using         |
|          |                    |        |                              | config.timeout. 0 ns means no timeout. See              |
|          |                    |        |                              | :ref:`pwm_timeout`.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is       |
|          |                    |        |                              | ERROR.                                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    pwm_expect(PWM_VVCT, 2, 1 us, 250 ns, "Check one period");
    pwm_expect(PWM_VVCT, 2, 1 us, 250 ns, "Check 5 periods", 5, 10 us, ERROR, C_SCOPE);
    pwm_expect(PWM_VVCT, 2, 1 us, pwm_count_to_active_time(64, 256, 1 us), "Check 64/256 duty", 5, 10 us, ERROR, C_SCOPE);
    pwm_expect(PWM_VVCT, 2, 0.25, "Check 25 % duty over 10 periods", 10, 15 us, ERROR, C_SCOPE);


Activity Watchdog
==================================================================================================================================
.. include:: rst_snippets/vip_activity_watchdog.rst


Transaction Info
==================================================================================================================================
.. include:: rst_snippets/vip_transaction_info.rst

.. table:: PWM transaction info record fields. Transaction Type: t_base_transaction (BT) - accessible via **shared_pwm_vvc_transaction_info.bt**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. GENERATE_PERIODS,   |
    |                              |                              |                 | START, UPDATE, STOP, ABORT, DRIVE_IDLE,         |
    |                              |                              |                 | MEASURE, EXPECT, EXPECT_DUTY                    |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | period                       | time                         | 0 ns            | GENERATE_PERIODS, START, UPDATE: the generated  |
    |                              |                              |                 | period. EXPECT: the expected period. 0 ns       |
    |                              |                              |                 | otherwise.                                      |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | active_time                  | time                         | 0 ns            | GENERATE_PERIODS, START, UPDATE: the generated  |
    |                              |                              |                 | active time. EXPECT: the expected active time.  |
    |                              |                              |                 | 0 ns otherwise.                                 |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | duty                         | real                         | 0.0             | EXPECT_DUTY: the expected duty cycle            |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | num_periods                  | integer                      | 0               | GENERATE_PERIODS, MEASURE, EXPECT, EXPECT_DUTY: |
    |                              |                              |                 | number of periods. 0 otherwise.                 |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | vvc_meta                     | t_vvc_meta                   | C_VVC_META_DEF\ | VVC meta data of the executing VVC command      |
    |                              |                              | AULT            |                                                 |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    |  -> msg                      | string                       | ""              | Message of executing VVC command                |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    |  -> cmd_idx                  | integer                      | -1              | Command index of executing VVC command          |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | transaction_status           | :ref:`t_transaction_status`  | INACTIVE        | Set to INACTIVE, IN_PROGRESS or COMPLETED       |
    |                              |                              |                 | during a transaction                            |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+

.. note::

    * The operation GENERATE_PERIODS is used for pwm_generate(), because 'generate' is a VHDL reserved word.
    * The transaction info of MEASURE carries no result; the measurement is fetched with fetch_result().
    * Commands rejected for the wrong role, the run state or invalid parameters leave the transaction info unchanged.

More information can be found in :ref:`Essential Mechanisms - Distribution of Transaction Info <vvc_framework_transaction_info>`.


Scoreboard
==================================================================================================================================
This VVC has no Scoreboard functionality. Measurements are fetched with fetch_result(), see :ref:`pwm_measure_vvc`.


Unwanted Transaction Detection
==================================================================================================================================
This VVC has no unwanted transaction detection.


Compilation
==================================================================================================================================
The PWM VVC must be compiled with VHDL-2008 or newer. It is dependent on the following libraries:

    * UVVM Utility Library (UVVM-Util)
    * UVVM VVC Framework
    * PWM BFM

Before compiling the PWM VVC, assure that uvvm_util and uvvm_vvc_framework have been compiled.

See :ref:`Essential Mechanisms - Compile Scripts <vvc_framework_compile_scripts>` for information about compile scripts.

.. table:: Compile order for the PWM VVC

    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | Compile to library           | File                                           | Comment                                         |
    +==============================+================================================+=================================================+
    | p2l2_vip_pwm                 | pwm_bfm_pkg.vhd                                | PWM BFM                                         |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | p2l2_vip_pwm                 | transaction_pkg.vhd                            | PWM transaction package with DTT types,         |
    |                              |                                                | constants, etc.                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | p2l2_vip_pwm                 | vvc_cmd_pkg.vhd                                | PWM VVC command types and operations            |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | p2l2_vip_pwm                 | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC target support package, compiled into  |
    |                              | _target_support_pkg.vhd                        | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | p2l2_vip_pwm                 | ../uvvm_vvc_framework/src_target_dependent/td\ | Common UVVM framework methods compiled into the |
    |                              | _vvc_framework_common_methods_pkg.vhd          | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | p2l2_vip_pwm                 | vvc_methods_pkg.vhd                            | PWM VVC methods                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | p2l2_vip_pwm                 | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM queue package for this VVC                 |
    |                              | _queue_pkg.vhd                                 |                                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | p2l2_vip_pwm                 | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC entity support compiled into this VVC  |
    |                              | _vvc_entity_support_pkg.vhd                    | library                                         |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | p2l2_vip_pwm                 | pwm_vvc.vhd                                    | PWM VVC                                         |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | p2l2_vip_pwm                 | vvc_context.vhd                                | PWM VVC context file                            |
    +------------------------------+------------------------------------------------+-------------------------------------------------+

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


Additional Documentation
==================================================================================================================================
For additional documentation on PWM, please see :ref:`pwm_additional_doc`.

.. important::

    * This VIP generates, measures and checks a single PWM line as described in :ref:`pwm_additional_doc`.
    * This VIP is not a complete PWM protocol checker, only the listed checks are made.

.. _pwm_roles:

Roles and generator run state
----------------------------------------------------------------------------------------------------------------------------------
* A VVC instance is either a GENERATOR or an OBSERVER (generic GC_ROLE). To drive and measure the same line, use two
  instances on one signal: the observer always drives 'Z'.
* A command for the other role raises an ERROR alert and is skipped.
* The generator waveform runs in its own process, so pwm_update(), pwm_stop() and pwm_abort() are accepted while a
  continuous run started by pwm_start() is active. After pwm_start() has completed, the VVC executor is inactive although
  the waveform keeps running (this matters for :ref:`vvc_framework_activity_watchdog` and await_uvvm_completion()).
* Run-state errors raise a TB_ERROR and leave the line unchanged: pwm_start() while a run is active, pwm_update(),
  pwm_stop() or pwm_abort() without a run, pwm_generate() or pwm_drive_idle() during a continuous run.
* Invalid period, active_time, num_periods and config.jitter values raise a TB_ERROR in the executor and the command is
  skipped. A duty or counter value outside its range arrives as an invalid active_time.
* Changes of shared_pwm_vvc_config(idx).bfm_config take effect at the next period boundary. A negative config.jitter set
  during a run raises one TB_ERROR, and the run keeps the previous configuration.
* "Next period boundary" means the next boundary after the request reaches the VVC. A pwm_update(), pwm_stop() or
  configuration change issued at the same simulation time as a period boundary may take effect only at the following
  boundary, e.g. pwm_stop() issued exactly N periods after pwm_start() can give N+1 periods. Issue such requests before the
  boundary time.
* The idle level is driven from GC_PWM_BFM_CONFIG at time 0, from the current configuration at the end of each run and
  by pwm_drive_idle(). See :ref:`pwm_drive_idle_vvc`.
* terminate_current_command() during pwm_generate() aborts the generation. During pwm_update() or pwm_stop() it
  withdraws the request, unless the period boundary has taken it in the same delta cycle (then the command completed).
  During an observer command it ends the observation at once, without an alert. A terminated command is logged with
  ID_TERMINATE_CMD.
* insert_delay() with a number of clock cycles raises a TB_ERROR, as the VVC has no clock. Use a time.


.. include:: rst_snippets/ip_disclaimer.rst
