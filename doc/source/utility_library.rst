.. _utility_library:

##################################################################################################################################
Utility Library
##################################################################################################################################

**********************************************************************************************************************************
Methods
**********************************************************************************************************************************
* All methods are defined in methods_pkg.vhd, unless otherwise noted.
* All parameters in brackets are optional.
* **Legend**: bool=boolean, sl=std_logic, slv=std_logic_vector, u=unsigned, s=signed, int=integer

Checks and awaits
==================================================================================================================================

.. hint::

    Although all check and await methods have optional [alert_level], it is best practice to always evaluate and assign the most 
    fitting alert_level for any given check or await.


check_value()
----------------------------------------------------------------------------------------------------------------------------------

.. hint::

    Checking that a value is not equal to another value is possible by using a boolean expression as the [value] parameter. ::

        --Example:
        check_value((value_1 /= value_2), ERROR, "Checking that value_1 is not equal value_2");
        
Checks if value equals exp, and alerts with severity alert_level if the values do not match. The result of the check is returned as 
a boolean if the method is called as a function. ::

    [boolean :=] check_value(value(bool), [exp(bool)], [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    [boolean :=] check_value(value(sl), exp(sl), [match_strictness], [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    [boolean :=] check_value(value(slv), exp(slv), [match_strictness], [alert_level], msg, [scope, [radix, [format, [msg_id, [msg_id_panel]]]]])
    [boolean :=] check_value(value(t_slv_array), exp(t_slv_array), [match_strictness], [alert_level], msg, [scope, [radix, [format, [msg_id, [msg_id_panel]]]]])
    [boolean :=] check_value(value(t_unsigned_array), exp(t_unsigned_array), [match_strictness], alert_level, msg, [scope, [radix, [format, [msg_id, [msg_id_panel]]]]])
    [boolean :=] check_value(value(t_signed_array), exp(t_signed_array), [match_strictness], alert_level, msg, [scope, [radix, [format, [msg_id, [msg_id_panel]]]]])
    [boolean :=] check_value(value(u), exp(u), [alert_level], msg, [scope, [radix, [format, [msg_id, [msg_id_panel]]]]] )
    [boolean :=] check_value(value(s), exp(s), [alert_level], msg, [scope, [radix, [format, [msg_id, [msg_id_panel]]]]])
    [boolean :=] check_value(value(int), exp(int), [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    [boolean :=] check_value(value(real), exp(real), [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    [boolean :=] check_value(value(time), exp(time), [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | value              | in     | *see overloads*              | Value to be checked                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | exp                | in     | *see overloads*              | Expected value                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | match_strictness   | in     | :ref:`t_match_strictness`    | Specifies if match needs to be exact or std_match, e.g. |
|          |                    |        |                              | 'H' = '1'. Default value is MATCH_STD.                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | radix              | in     | :ref:`t_radix`               | Controls how the vector is represented in the log.      |
|          |                    |        |                              | Default value is HEX_BIN_IF_INVALID.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | format             | in     | :ref:`t_format_zeros`        | Controls how the vector is formatted in the log. Default|
|          |                    |        |                              | value is KEEP_LEADING_0.                                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID used in the log, defined in adaptations_pkg. |
|          |                    |        |                              | Default value is ID_POS_ACK.                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    check_value(v_int_a, 42, WARNING, "Checking the integer");
    v_check := check_value(v_slv5_a, "11100", MATCH_EXACT, "Checking the SLV", "My Scope", HEX, SKIP_LEADING_0, ID_SEQUENCER, shared_msg_id_panel);

.. note::

    Vectors are checked with MSB as left most and that the range is converted from "0 to N" to "N downto 0". A WARNING is given if 
    arrays are of defined with opposite directions. Different ranges in any dimension will not match.


check_value_in_range()
----------------------------------------------------------------------------------------------------------------------------------
Checks if min_value ≤ val ≤ max_value, and alerts with severity alert_level if val is outside the range. The result of the check 
is returned as a boolean if the method is called as a function. ::

    [boolean :=] check_value_in_range(value(u), min_value(u), max_value(u), [alert_level], msg, [scope, [msg_id, [msg_id_panel, [radix, [prefix]]]]])
    [boolean :=] check_value_in_range(value(s), min_value(s), max_value(s), [alert_level], msg, [scope, [msg_id, [msg_id_panel, [radix, [prefix]]]]])
    [boolean :=] check_value_in_range(value(int), min_value(int), max_value(int), [alert_level], msg, [scope, [msg_id, [msg_id_panel, [radix, [prefix]]]]])
    [boolean :=] check_value_in_range(value(time), min_value(time), max_value(time), [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    [boolean :=] check_value_in_range(value(real), min_value(real), max_value(real), [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | value              | in     | *see overloads*              | Value to be checked                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | min_value          | in     | *see overloads*              | Minimum value in the expected range                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | max_value          | in     | *see overloads*              | Maximum value in the expected range                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID used in the log, defined in adaptations_pkg. |
|          |                    |        |                              | Default value is ID_POS_ACK.                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | radix              | in     | t_radix                      | Radix used in the log.                                  |
|          |                    |        |                              | Default is DEC for integer and HEX_BIN_IF_INVALID for   |
|          |                    |        |                              | signed and unsigned.                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | prefix             | in     | t_radix_prefix               | Include/exclude radix prefix in the log.                |
|          |                    |        |                              | Default is EXCL_RADIX for integer and INCL_RADIX for    |
|          |                    |        |                              | signed and unsigned.                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    check_value_in_range(v_int_a, 10, 100, "Checking that integer is in range");


check_stable()
----------------------------------------------------------------------------------------------------------------------------------
Checks if the target signal has been stable in stable_req time. If not, an alert is asserted. ::

    check_stable(target(bool), stable_req, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    check_stable(target(sl), stable_req, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    check_stable(target(slv), stable_req, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    check_stable(target(u), stable_req, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    check_stable(target(s), stable_req, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    check_stable(target(int), stable_req, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    check_stable(target(real), stable_req, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | target             | in     | *see overloads*              | Signal to be checked                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | stable_req         | in     | time                         | Period of time to check if the signal is stable         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID used in the log, defined in adaptations_pkg. |
|          |                    |        |                              | Default value is ID_POS_ACK.                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    check_stable(slv8, 9 ns, "Checking if SLV is stable");


check_sb_completion()
----------------------------------------------------------------------------------------------------------------------------------
This procedure checks that all the enabled scoreboards are empty, i.e. all expected values checked. The result of the check is 
returned as a boolean if the method is called as a function.

If an enabled scoreboard has expected values to be checked, an alert will be generated. Otherwise, a successful completion message 
and the optional reports will be printed in the log.

.. code-block::

    [boolean :=] check_sb_completion(VOID)
    [boolean :=] check_sb_completion(alert_level, [print_alert_counters, [print_sbs, [scope, [msg_id_panel]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is       |
|          |                    |        |                              | TB_ERROR.                                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | print_alert_counte\| in     | :ref:`t_report_alert_counter\| Whether to print a report of alert counters. Default    |
|          | rs                 |        | s`                           | value is NO_REPORT.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | print_sbs          | in     | :ref:`t_report_sb`           | Whether to print a report with all the scoreboards in   |
|          |                    |        |                              | the testbench. Default value is NO_REPORT.              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_check := check_sb_completion(VOID);
    check_sb_completion(TB_WARNING, REPORT_ALERT_COUNTERS, REPORT_SCOREBOARDS, C_SCOPE);


await_change()
----------------------------------------------------------------------------------------------------------------------------------
Waits until the target signal changes, or times out after max_time. An alert is asserted if the signal does not change between 
min_time and max_time. *Note* that if the value changes at exactly max_time, the timeout gets precedence. ::

    await_change(target(bool), min_time, max_time, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    await_change(target(sl), min_time, max_time, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    await_change(target(slv), min_time, max_time, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    await_change(target(u), min_time, max_time, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    await_change(target(s), min_time, max_time, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    await_change(target(int), min_time, max_time, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    await_change(target(real), min_time, max_time, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | target             | in     | *see overloads*              | Signal to be checked                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | min_time           | in     | time                         | Minimum time that must pass before the signal changes   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | max_time           | in     | time                         | Maximum time for the signal to change                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID used in the log, defined in adaptations_pkg. |
|          |                    |        |                              | Default value is ID_POS_ACK.                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    await_change(bool, 3 ns, 5 ns, "Awaiting change on bool signal");


await_value()
----------------------------------------------------------------------------------------------------------------------------------
Waits until the target signal equals the exp signal, or times out after max_time. An alert is asserted if the signal does not 
equal the expected value between min_time and max_time, or if the target equals exp before min_time. 
*Note* that if the value changes to the expected value at exactly max_time, the timeout gets precedence. 
This procedure is a fall-through procedure when ``min_time = 0 ns``, and will not require a change. For a change to be required. 
see await_change_to_value() under. ::

    await_value(target(sl), exp(sl), [match_strictness], min_time, max_time, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    await_value(target(slv), exp(slv), [match_strictness], min_time, max_time, [alert_level], msg, [scope, [radix, [format, [msg_id, [msg_id_panel]]]]])
    await_value(target(bool), exp(bool), min_time, max_time, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    await_value(target(u), exp(u), min_time, max_time, [alert_level], msg, [scope, [radix, [format, [msg_id, [msg_id_panel]]]]])
    await_value(target(s), exp(s), min_time, max_time, [alert_level], msg, [scope, [radix, [format, [msg_id, [msg_id_panel]]]]])
    await_value(target(int), exp(int), min_time, max_time, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    await_value(target(real), exp(real), min_time, max_time, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | target             | in     | *see overloads*              | Signal to be checked                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | exp                | in     | *see overloads*              | Expected value                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | match_strictness   | in     | :ref:`t_match_strictness`    | Specifies if match needs to be exact or std_match, e.g. |
|          |                    |        |                              | 'H' = '1'. Default value is MATCH_STD.                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | min_time           | in     | time                         | Minimum time that must pass while target /= exp         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | max_time           | in     | time                         | Maximum time for the signal to change                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | radix              | in     | :ref:`t_radix`               | Controls how the vector is represented in the log.      |
|          |                    |        |                              | Default value is HEX_BIN_IF_INVALID.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | format             | in     | :ref:`t_format_zeros`        | Controls how the vector is formatted in the log. Default|
|          |                    |        |                              | value is KEEP_LEADING_0.                                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID used in the log, defined in adaptations_pkg. |
|          |                    |        |                              | Default value is ID_POS_ACK.                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    await_value(bool, true, 10 ns, 20 ns, "Waiting for bool to become true");
    await_value(slv8, "10101010", MATCH_STD, 3 ns, 7 ns, WARNING, "Waiting for slv8 value");

await_change_to_value()
----------------------------------------------------------------------------------------------------------------------------------
Waits until the target signal changes to the exp signal, or times out after max_time. 
If the signal changes to the expected value before min_time, or the signal does not change to the expected value between min_time and max_time, an alert is asserted. 

.. note::

    * If the target changes before min_time, but not to the expected value, nothing happens (check will continue until timeout or target changes to expected value)
    * If the value changes to the expected value at exactly max_time, the timeout gets precedence.

.. code-block::

    await_change_to_value(target(sl), exp(sl), [match_strictness], min_time, max_time, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    await_change_to_value(target(slv), exp(slv), [match_strictness], min_time, max_time, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    await_change_to_value(target(bool), exp(bool), min_time, max_time, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    await_change_to_value(target(u), exp(u), min_time, max_time, [alert_level], msg, [scope, [msg_id, [msg_id_panel, [radix, [prefix]]]]])
    await_change_to_value(target(s), exp(s), min_time, max_time, [alert_level], msg, [scope, [msg_id, [msg_id_panel, [radix, [prefix]]]]])
    await_change_to_value(target(int), exp(int), min_time, max_time, [alert_level], msg, [scope, [msg_id, [msg_id_panel, [radix, [prefix]]]]])
    await_change_to_value(target(real), exp(real), min_time, max_time, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])

+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                           |
+==========+====================+========+==============================+=======================================================================+
| signal   | target             | in     | *see overloads*              | Signal to be checked                                                  |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------+
| constant | exp                | in     | *see overloads*              | Expected value                                                        |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------+
| constant | match_strictness   | in     | :ref:`t_match_strictness`    | Specifies if match needs to be exact or std_match, e.g.               |
|          |                    |        |                              | 'H' = '1'. Default value is MATCH_STD. (only in sl, and slv versions) |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------+
| constant | min_time           | in     | time                         | Minimum time that must pass before the target signal changes to exp   |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------+
| constant | max_time           | in     | time                         | Maximum time for the target signal to change to exp                   |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.              |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert                      |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.              |
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                                  |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID used in the log, defined in adaptations_pkg.               |
|          |                    |        |                              | Default value is ID_POS_ACK.                                          |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default                  |
|          |                    |        |                              | value is shared_msg_id_panel.                                         |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------+
| constant | radix              | in     | t_radix                      | Radix used in the log.                                                |
|          |                    |        |                              | Default is DEC for integer and HEX_BIN_IF_INVALID for signed and      |
|          |                    |        |                              | unsigned.                                                             |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------+
| constant | prefix             | in     | t_radix_prefix               | Include/exclude radix prefix in the log.                              |
|          |                    |        |                              | Default is EXCL_RADIX for integer and INCL_RADIX for signed and       |
|          |                    |        |                              | unsigned.                                                             |
+----------+--------------------+--------+------------------------------+-----------------------------------------------------------------------+

.. code-block::

    -- Examples:
    await_change_to_value(bool, true, 10 ns, 20 ns, "Waiting for bool to change to true for min 10 ns and max 20 ns");
    await_change_to_value(slv8, "10101010", MATCH_STD, 3 ns, 7 ns, WARNING, "Waiting for slv8 to change to value");

await_stable()
----------------------------------------------------------------------------------------------------------------------------------
Wait until the target signal has been stable for at least stable_req. Report an error if this does not occur within the time 
specified by timeout. *Note* that **stable** refers to that the signal has not had an event (i.e. not changed value). ::

    await_stable(target(bool), stable_req, stable_req_from, timeout, timeout_from, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    await_stable(target(sl), stable_req, stable_req_from, timeout, timeout_from, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    await_stable(target(slv), stable_req, stable_req_from, timeout, timeout_from, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    await_stable(target(u), stable_req, stable_req_from, timeout, timeout_from, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    await_stable(target(s), stable_req, stable_req_from, timeout, timeout_from, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    await_stable(target(int), stable_req, stable_req_from, timeout, timeout_from, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])
    await_stable(target(real), stable_req, stable_req_from, timeout, timeout_from, [alert_level], msg, [scope, [msg_id, [msg_id_panel]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | target             | in     | *see overloads*              | Signal to be checked                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | stable_req         | in     | time                         | Period of time to check if the signal is stable         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | stable_req_from    | in     | :ref:`t_from_point_in_time`  | Point in time to start checking stability of the signal |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Timeout for the signal to be stable during the required |
|          |                    |        |                              | time                                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout_from       | in     | :ref:`t_from_point_in_time`  | Point in time when the timeout starts counting          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID used in the log, defined in adaptations_pkg. |
|          |                    |        |                              | Default value is ID_POS_ACK.                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    await_stable(u8, 20 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, ERROR, "Waiting for u8 to stabilize");


.. _await_sb_completion:

await_sb_completion()
----------------------------------------------------------------------------------------------------------------------------------
This procedure waits for all the enabled scoreboards to be empty, i.e. all expected values checked.

If an enabled scoreboard still has expected values to be checked when the timeout occurs, an alert will be generated. Otherwise, a 
successful completion message and the optional reports will be printed in the log.

.. code-block::

    await_sb_completion(timeout, [alert_level, [sb_poll_time, [print_alert_counters, [print_sbs, [scope, [msg_id_panel]]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | timeout            | in     | time                         | Timeout for the VVCs to be inactive and the scoreboards |
|          |                    |        |                              | to be empty. Must be greater than 0.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is       |
|          |                    |        |                              | TB_ERROR.                                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | sb_poll_time       | in     | time                         | Time to wait until checking again whether the           |
|          |                    |        |                              | scoreboards have been emptied. Must be greater than 0.  |
|          |                    |        |                              | Default value is 100 us.                                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | print_alert_counte\| in     | :ref:`t_report_alert_counter\| Whether to print a report of alert counters. Default    |
|          | rs                 |        | s`                           | value is NO_REPORT.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | print_sbs          | in     | :ref:`t_report_sb`           | Whether to print a report with all the scoreboards in   |
|          |                    |        |                              | the testbench. Default value is NO_REPORT.              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Example: Wait for all Scoreboards to be empty
    await_sb_completion(1 ms);

    -- Example: Wait for all Scoreboards to be empty and report the alert counters and scoreboards
    await_sb_completion(1 ms, TB_WARNING, 1 us, REPORT_ALERT_COUNTERS, REPORT_SCOREBOARDS, C_SCOPE);

.. note::

    This procedure is called within :ref:`await_uvvm_completion`, which is recommended to use when there are VVCs in the testbench.


Logging and verbosity control
==================================================================================================================================

set_log_file_name()
----------------------------------------------------------------------------------------------------------------------------------
Sets the log file name. To ensure that the entire log transcript is written to a single file, this should be called prior to any 
other procedures (except set_alert_file_name()). If file name is set after a log message has been written to the log file, a 
warning will be reported. This warning can be disabled by setting C_WARNING_ON_LOG_ALERT_FILE_RUNTIME_RENAME false in the 
adaptations_pkg. ::

    set_log_file_name([file_name])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | file_name          | in     | string                       | Name of the log file. Default value is C_LOG_FILE_NAME. |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    set_log_file_name("new_log_file_name.txt");


log()
----------------------------------------------------------------------------------------------------------------------------------
Writes a message to the log. *Note* that if the msg_id is disabled in the msg_id_panel, the message will not be shown. Some general 
string handling features are:

* All log messages will be given using the user defined layout in adaptations_pkg.vhd
* \\n may be used to force line shifts. Line shift will occur after scope column, before message column
* \\r may be used to force line shift at start of log message. The result will be a blank line apart from prefix 
  (message ID, timestamp and scope will be omitted on the first line)

.. code-block::

    log([msg_id], msg, [scope, [msg_id_panel, [log_destination, [log_file_name, [open_mode]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | msg_id             | in     | t_msg_id                     | Message ID used in the log, defined in adaptations_pkg. |
|          |                    |        |                              | Default value is C_TB_MSG_ID_DEFAULT.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | log_destination    | in     | :ref:`t_log_destination`     | Defines where the message will be written to. Default   |
|          |                    |        |                              | value is shared_default_log_destination.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | log_file_name      | in     | string                       | Defines the log file where message shall be written to. |
|          |                    |        |                              | Default value is C_LOG_FILE_NAME.                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | open_mode          | in     | file_open_kind               | Indicates how the log file shall be opened (write_mode, |
|          |                    |        |                              | append_mode). Default value is append_mode.             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    log(ID_SEQUENCER, "message to log");
    log(ID_BFM, "Msg", "MyScope", local_msg_id_panel, LOG_ONLY, "new_log.txt", write_mode);


log_text_block()
----------------------------------------------------------------------------------------------------------------------------------
Writes a text block from a VHDL line to the log. ::

    log_text_block(msg_id, text_block, formatting, [msg_header, [scope, [msg_id_panel, [log_if_block_empty, [log_destination, [log_file_name, [open_mode]]]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | msg_id             | in     | t_msg_id                     | Message ID used in the log, defined in adaptations_pkg  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | text_block         | inout  | line                         | Line where the text block is stored                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | formatting         | in     | :ref:`t_log_format`          | Whether the text is formatted or not                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_header         | in     | string                       | Header message for the text_block. Default value is "". |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | log_if_block_empty | in     | :ref:`t_log_if_block_empty`  | Defines how an empty text block is handled. Default     |
|          |                    |        |                              | value is WRITE_HDR_IF_BLOCK_EMPTY.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | log_destination    | in     | :ref:`t_log_destination`     | Defines where the text block will be written to. Default|
|          |                    |        |                              | value is shared_default_log_destination.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | log_file_name      | in     | string                       | Defines the log file where text block shall be written  |
|          |                    |        |                              | to. Default value is C_LOG_FILE_NAME.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | open_mode          | in     | file_open_kind               | Indicates how the log file shall be opened (write_mode, |
|          |                    |        |                              | append_mode). Default value is append_mode.             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    log_text_block(ID_SEQUENCER, v_line, UNFORMATTED);
    log_text_block(ID_BFM, v_line, FORMATTED, "Header", "MyScope");


.. _util_enable_log_msg:

enable_log_msg()
----------------------------------------------------------------------------------------------------------------------------------
Enables logging for the given msg_id. (See :ref:`message_ids` for examples of different IDs). ::

    enable_log_msg(msg_id, [quietness, [scope]])
    enable_log_msg(msg_id, msg, [quietness, [scope]])
    enable_log_msg(msg_id, msg_id_panel, [msg, [scope, [quietness]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | msg_id             | in     | t_msg_id                     | Message ID used in the log, defined in adaptations_pkg  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | quietness          | in     | :ref:`t_quietness`           | Logging of this procedure can be turned off by setting  |
|          |                    |        |                              | quietness=QUIET. Default value is NON_QUIET.            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert.       |
|          |                    |        |                              | Default value is "".                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | msg_id_panel       | inout  | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    enable_log_msg(ID_SEQUENCER);


.. _util_disable_log_msg:

disable_log_msg()
----------------------------------------------------------------------------------------------------------------------------------
Disables logging for the given msg_id. (See :ref:`message_ids` for examples of different IDs). ::

    disable_log_msg(msg_id, [quietness, [scope]])
    disable_log_msg(msg_id, msg, [quietness, [scope]])
    disable_log_msg(msg_id, msg_id_panel, [msg, [scope, [quietness]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | msg_id             | in     | t_msg_id                     | Message ID used in the log, defined in adaptations_pkg  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | quietness          | in     | :ref:`t_quietness`           | Logging of this procedure can be turned off by setting  |
|          |                    |        |                              | quietness=QUIET. Default value is NON_QUIET.            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert.       |
|          |                    |        |                              | Default value is "".                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | msg_id_panel       | inout  | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    disable_log_msg(ID_LOG_HDR);


is_log_msg_enabled()
----------------------------------------------------------------------------------------------------------------------------------
Returns true if the given message ID is enabled, otherwise false. ::

    boolean := is_log_msg_enabled(msg_id, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | msg_id             | in     | t_msg_id                     | Message ID used in the log, defined in adaptations_pkg  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_is_enabled := is_log_msg_enabled(ID_SEQUENCER);


set_log_destination()
----------------------------------------------------------------------------------------------------------------------------------
Sets the default log destination for all log procedures. The destination specified in this log_destination will be used unless the 
log_destination argument in the log procedure is specified. A log message is written to log ID ID_LOG_MSG_CTRL if quietness is set 
to NON_QUIET.

    set_log_destination(log_destination, [quietness])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | log_destination    | in     | :ref:`t_log_destination`     | Defines where all the log procedures will be written to |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | quietness          | in     | :ref:`t_quietness`           | Logging of this procedure can be turned off by setting  |
|          |                    |        |                              | quietness=QUIET. Default value is NON_QUIET.            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    set_log_destination(CONSOLE_ONLY);


Alert handling
==================================================================================================================================

The available alert levels are defined in the type :ref:`t_alert_level`. The behavior for each type of alert can be configured in
adaptations_pkg.vhd. The simulation will be stopped when the occurences of an alert type reaches the number configured in
C_DEFAULT_STOP_LIMIT. By default, the simulation will be stopped after one occurence of either ERROR, TB_ERROR, FAILURE or TB_FAILURE.
Alert levels with the prefix TB\_ are intended to be used in cases where the cause of the alert is known to be a testbench issue.

The MANUAL_CHECK alert type is intended for cases where a manual check, e.g. a waveform inspection, is required. When an alert of this
type is encountered, the simulation will be stopped and the user will be prompted to carry out a manual check before resuming the
simulation.

set_alert_file_name()
----------------------------------------------------------------------------------------------------------------------------------
Sets the alert file name. To ensure that the entire log transcript is written to a single file, this should be called prior to any 
other procedures (except set_alert_file_name()). If file name is set after a log message has been written to the log file, a 
warning will be reported. This warning can be disabled by setting C_WARNING_ON_LOG_ALERT_FILE_RUNTIME_RENAME false in the 
adaptations_pkg. ::

    set_alert_file_name(file_name)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | file_name          | in     | string                       | Name of the alert file. Default value is                |
|          |                    |        |                              | C_ALERT_FILE_NAME.                                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    set_alert_file_name("new_alert_log_file.txt");


alert()
----------------------------------------------------------------------------------------------------------------------------------
* Asserts an alert with severity given by alert_level.
* Increment the counters for the given alert_level.
* If the stop_limit for the given alert_level is reached, stop the simulation.

.. code-block::

    alert(alert_level, msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    alert(TB_WARNING, "This is a TB warning");


alert() overloads
----------------------------------------------------------------------------------------------------------------------------------
Overloads for alert(). *Note* that: ``warning(msg, [scope]) = alert(warning, msg, [scope])``. ::

    note(msg, [scope])          tb_note(msg, [scope]) 
    warning(msg, [scope])       tb_warning(msg, [scope]) 
    error(msg, [scope])         tb_error(msg, [scope]) 
    failure(msg, [scope])       tb_failure(msg, [scope])
    manual_check(msg, [scope]) 
        
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    note("This is a note");
    tb_failure("This is a TB failure", "tb_scope");


increment_expected_alerts()
----------------------------------------------------------------------------------------------------------------------------------
Increments the expected alert counter for the given alert_level. ::

    increment_expected_alerts(alert_level, [number, [msg, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | number             | in     | natural                      | Number to increment the counter. Default value is 1.    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert.       |
|          |                    |        |                              | Default value is "".                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    increment_expected_alerts_and_stop_limit(WARNING, 2, "Expecting two more warnings");


set_alert_stop_limit()
----------------------------------------------------------------------------------------------------------------------------------
Simulator will stop when hitting a number of specified alert type (0 means never stop). ::

    set_alert_stop_limit(alert_level, value)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | value              | in     | natural                      | Number to set the stop limit                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    set_alert_stop_limit(ERROR, 2);


increment_expected_alerts_and_stop_limit()
----------------------------------------------------------------------------------------------------------------------------------
Increments the expected alert counter and stop limit for the given alert_level. ::

    increment_expected_alerts_and_stop_limit(alert_level, [number, [msg, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | number             | in     | natural                      | Number to set the stop limit. Default value is 1.       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert.       |
|          |                    |        |                              | Default value is "".                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    increment_expected_alerts_and_stop_limit(WARNING, 2, "Expecting two more warnings");


get_alert_stop_limit()
----------------------------------------------------------------------------------------------------------------------------------
Returns current stop limit for given alert type. ::

    natural := get_alert_stop_limit(alert_level)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_int := get_alert_stop_limit(FAILURE);


set_alert_attention()
----------------------------------------------------------------------------------------------------------------------------------
Set given alert type to t_attention: IGNORE or REGARD. ::

    set_alert_attention(alert_level, attention, [msg])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | attention          | in     | :ref:`t_attention`           | Sets the attention for the alert                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert.       |
|          |                    |        |                              | Default value is "".                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    set_alert_attention(NOTE, IGNORE, "Ignoring all note-alerts");


get_alert_attention()
----------------------------------------------------------------------------------------------------------------------------------
Returns current attention (IGNORE or REGARD) for given alert type. ::

    t_attention := get_alert_attention(alert_level)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_attention := get_alert_attention(WARNING)


Reporting
==================================================================================================================================

report_global_ctrl()
----------------------------------------------------------------------------------------------------------------------------------
Logs the values in the global_ctrl signal, which is described in :ref:`util_hierarchical_report`. ::

    report_global_ctrl(VOID)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+


report_msg_id_panel()
----------------------------------------------------------------------------------------------------------------------------------
Logs the values in the msg_id_panel, which is described in :ref:`util_hierarchical_report`. ::

    report_msg_id_panel(VOID)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+


report_alert_counters()
----------------------------------------------------------------------------------------------------------------------------------
Logs the status of all alert counters, typically at the end of simulation. For each alert_level, the alert counter is compared 
with the expected counter. If parameter is FINAL, an additional summary concluding success or failure is logged. VOID parameter 
gives same result as FINAL. ::

    report_alert_counters(order)
    report_alert_counters(VOID)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | order              | in     | :ref:`t_order`               | Whether the report is to be printed during simulation or|
|          |                    |        |                              | at the end                                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    report_alert_counters(VOID); 
    report_alert_counters(FINAL); 
    report_alert_counters(INTERMEDIATE);


report_check_counters()
----------------------------------------------------------------------------------------------------------------------------------
Logs the number of all check counters in the testbench, typically to be used at the end of simulation. Note that this functionality 
is disabled by default to avoid possible decreased performance, set C_ENABLE_CHECK_COUNTER to true in adaptations_pkg to enable it. 
The VOID parameter gives same result as FINAL. ::

    report_check_counters(order)
    report_check_counters(VOID)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | order              | in     | :ref:`t_order`               | Whether the report is to be printed during simulation or|
|          |                    |        |                              | at the end                                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    report_check_counters(VOID); 
    report_check_counters(FINAL); 
    report_check_counters(INTERMEDIATE);


.. _util_shared_variables:

Shared variables
----------------------------------------------------------------------------------------------------------------------------------
These shared variables are natural, read only types.

* shared_uvvm_status.found_unexpected_simulation_warnings_or_worse
    | Status is ‘0’ on success and ‘1’ on failure.
    | The variable is set when actual > expected for WARNING, ERROR or FAILURE alerts.

* shared_uvvm_status.found_unexpected_simulation_errors_or_worse
    | Status is ‘0’ on success and ‘1’ on failure.
    | The variable is set when actual > expected for ERROR or FAILURE alerts.

* shared_uvvm_status.mismatch_on_expected_simulation_warnings_or_worse
    | Status is ‘0’ on success and ‘1’ on failure.
    | The variable is set when there is a mismatch between the expected and the actual WARNING, ERROR or FAILURE alerts.

* shared_uvvm_status.mismatch_on_expected_simulation_errors_or_worse
    | Status is ‘0’ on success and ‘1’ on failure.
    | The variable is set when there is a mismatch between the expected and the actual ERROR or FAILURE alerts.


.. _basic_randomization:

Basic Randomization
==================================================================================================================================

random() - function
----------------------------------------------------------------------------------------------------------------------------------
Returns a random value. The function uses and updates a global seed. ::

    std_logic        := random(VOID)
    std_logic_vector := random(length)
    integer          := random(min_value(int), max_value(int))
    real             := random(min_value(real), max_value(real))
    time             := random(min_value(time), max_value(time), [time_resolution(time)])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | length             | in     | integer                      | Length of the random vector to return                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | min_value          | in     | *see overloads*              | Minimum value in the range to generate the random number|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | max_value          | in     | *see overloads*              | Maximum value in the range to generate the random number|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | time_resolution    | in     | time                         | Defines how many values can be generated between        |
|          |                    |        |                              | min_value and max_value. If the given resolution is too |
|          |                    |        |                              | small for the range, a TB_WARNING will be printed once. |
|          |                    |        |                              | Default value is the smallest time unit between the min |
|          |                    |        |                              | and max parameters.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_sl   := random(VOID);
    v_slv  := random(v_slv'length);
    v_int  := random(1, 10);
    v_real := random(0.01, 0.03);
    v_time := random(25 us, 50 us);         -- Generates random values with a resolution of 1 us
    v_time := random(25 us, 50 us, ns);     -- Generates random values with a resolution of 1 ns
    v_time := random(25 us, 50 us, 100 ns); -- Generates random values with a resolution of 100 ns


random() - procedure
----------------------------------------------------------------------------------------------------------------------------------
Sets v_target to a random value. The procedure uses and updates v_seed1 and v_seed2. ::

    random(v_seed1, v_seed2, v_target(sl))
    random(v_seed1, v_seed2, v_target(slv))
    random(min_value(int), max_value(int), v_seed1, v_seed2, v_target(int))
    random(min_value(real), max_value(real), v_seed1, v_seed2, v_target(real))
    random(min_value(time), max_value(time), [time_resolution(time)], v_seed1, v_seed2, v_target(time))

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | min_value          | in     | *see overloads*              | Minimum value in the range to generate the random number|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | max_value          | in     | *see overloads*              | Maximum value in the range to generate the random number|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | time_resolution    | in     | time                         | Defines how many values can be generated between        |
|          |                    |        |                              | min_value and max_value. If the given resolution is too |
|          |                    |        |                              | small for the range, a TB_WARNING will be printed once. |
|          |                    |        |                              | Default value is the smallest time unit between the min |
|          |                    |        |                              | and max parameters.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | v_seed1            | inout  | positive                     | Randomization seed 1                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | v_seed2            | inout  | positive                     | Randomization seed 2                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | v_target           | inout  | *see overloads*              | Variable where the random value is placed               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    random(v_seed1, v_seed2, v_sl);
    random(v_seed1, v_seed2, v_slv);
    random(1, 10, v_seed1, v_seed2, v_int);
    random(0.01, 0.03, v_seed1, v_seed2, v_real);
    random(25 us, 50 us, v_seed1, v_seed2, v_time);         -- Generates random values with a resolution of 1 us
    random(25 us, 50 us, ns, v_seed1, v_seed2, v_time);     -- Generates random values with a resolution of 1 ns
    random(25 us, 50 us, 100 ns, v_seed1, v_seed2, v_time); -- Generates random values with a resolution of 100 ns


randomize()
----------------------------------------------------------------------------------------------------------------------------------
Sets the global seeds to seed1 and seed2. ::

    randomize(seed1, seed2, [msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | seed1              | in     | positive                     | Randomization seed 1                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | seed2              | in     | positive                     | Randomization seed 2                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert.       |
|          |                    |        |                              | Default value is "randomizing seeds".                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    randomize(12, 14, "Setting global seeds");


.. _util_string_handling:

String handling
==================================================================================================================================
Methods are defined in string_methods_pkg.vhd

to_string() - IEEE [#f1]_
----------------------------------------------------------------------------------------------------------------------------------
IEEE defined to_string functions. Return a string with the value of the argument 'value'. ::

    string := to_string(value(ANY_SCALAR_TYPE))
    string := to_string(value(slv))
    string := to_string(value(time), unit(time))
    string := to_string(value(real), digits(natural))
    string := to_string(value(real), format(string)) -- C-style formatting

to_string()
----------------------------------------------------------------------------------------------------------------------------------
Additions to the IEEE defined to_string functions. Return a string with the value of the argument 'val'. ::

    string := to_string(val(bool), width, justified, format_spaces, [truncate])
    string := to_string(val(int), width, justified, format_spaces, [truncate, [radix, [prefix, [format]]]])
    string := to_string(val(int), radix, prefix, [format])
    string := to_string(val(slv), radix, [format, [prefix]])
    string := to_string(val(u), radix, [format, [prefix]])
    string := to_string(val(s), radix, [format, [prefix]])
    string := to_string(val(t_slv_array), [radix, [format, [prefix]]])
    string := to_string(val(t_signed_array), [radix, [format, [prefix]]])
    string := to_string(val(t_unsigned_array), [radix, [format, [prefix]]])
    string := to_string(val(integer_vector), [radix, [format, [prefix]]])
    string := to_string(val(t_natural_vector), [radix, [format, [prefix]]])
    string := to_string(val(real_vector))
    string := to_string(val(time_vector))
    string := to_string(val(string)) -- Removes non printable ASCII characters

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | val                | in     | *see overloads*              | Value to be converted into string                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | width              | in     | natural                      | Width of the returned string                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | justified          | in     | side                         | Which side to justify the text (RIGHT, LEFT)            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | format_spaces      | in     | :ref:`t_format_spaces`       | Whether to keep or skip the leading spaces              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | truncate           | in     | :ref:`t_truncate_string`     | Whether to truncate the string or not. Default value is |
|          |                    |        |                              | DISALLOW_TRUNCATE.                                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | radix              | in     | :ref:`t_radix`               | Radix of the string value. Default value is different   |
|          |                    |        |                              | depending on the overload.                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | prefix             | in     | :ref:`t_radix_prefix`        | Whether to include the radix or not. Default value is   |
|          |                    |        |                              | EXCL_RADIX.                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | format             | in     | :ref:`t_format_zeros`        | Whether to keep or skip the leading zeros. Default value|
|          |                    |        |                              | is different depending on the overload.                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_string := to_string(v_u8, DEC);
    v_string := to_string(v_slv8, HEX, AS_IS, INCL_RADIX);


ascii_to_char()
----------------------------------------------------------------------------------------------------------------------------------
Returns the character for the ASCII value. ::

    character := ascii_to_char(ascii_pos, [ascii_allow])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | ascii_pos          | in     | integer                      | ASCII number input                                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | ascii_allow        | in     | :ref:`t_ascii_allow`         | Decide what to do with invisible control characters.    |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | If ALLOW_ALL: return the character for any ascii_pos.   |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | If ALLOW_PRINTABLE_ONLY: return the character only if   |
|          |                    |        |                              | it is printable.                                        |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Default value is ALLOW_ALL.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_char := ascii_to_char(65); -- ASCII 'A'


char_to_ascii()
----------------------------------------------------------------------------------------------------------------------------------
Returns the ASCII value for the character. ::

    integer := char_to_ascii(char)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | char               | in     | character                    | Character to be converted to ASCII                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_int := char_to_ascii('A'); -- Returns 65


to_upper()
----------------------------------------------------------------------------------------------------------------------------------
Returns a string containing an uppercase version of the argument 'val'. ::

    string := to_upper(val)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | val                | in     | string                       | Value to be converted into uppercase                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_string := to_upper("lowercase string");


justify() - IEEE [#f1]_
----------------------------------------------------------------------------------------------------------------------------------
IEEE implementation of justify. Returns a string where 'value' is justified to the side given by 'justified'. ::

    string := justify(value, [justified], [field])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | value              | in     | string                       | Value to be converted into uppercase                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | justified          | in     | side                         | Which side to justify the text (RIGHT, LEFT). Default   |
|          |                    |        |                              | value is RIGHT.                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | field              | in     | width                        | Default value is 0                                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+


justify()
----------------------------------------------------------------------------------------------------------------------------------
Addition to the IEEE implementation of justify(). Returns a string where 'val' is justified to the side given by 'justified'. In 
addition to right and left, center is also an option. The string can be truncated with the 'truncate' parameter or leading spaces 
can be removed with 'format_spaces'. ::

    string := justify(val, justified, width, format_spaces, truncate)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | val                | in     | string                       | Value to be justified                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | justified          | in     | side                         | Which side to justify the text (RIGHT, LEFT, CENTER)    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | width              | in     | natural                      | Width of the returned string                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | format_spaces      | in     | :ref:`t_format_spaces`       | Whether to keep or skip the leading spaces              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | truncate           | in     | :ref:`t_truncate_string`     | Whether to truncate the string or not                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_string := justify("string", RIGHT, C_STRING_LENGTH, ALLOW_TRUNCATE, KEEP_LEADING_SPACE);


fill_string()
----------------------------------------------------------------------------------------------------------------------------------
Returns a string filled with the given character. ::

    string := fill_string(val, width)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | val                | in     | character                    | Character to fill the string with                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | width              | in     | natural                      | Width of the returned string                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_string := fill_string('X', 10);


pad_string()
----------------------------------------------------------------------------------------------------------------------------------
Returns a string of a certain width with the string 'val' on the side of the string given in 'side'. The remaining width is padded 
with 'char'. ::

    string := pad_string(val, char, width, [side])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | val                | in     | string                       | Input string                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | char               | in     | character                    | Character to use as padding                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | width              | in     | natural                      | Width of the returned string                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | side               | in     | side                         | Which side to justify the text (RIGHT, LEFT). Default   |
|          |                    |        |                              | value is LEFT.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_string := pad_string("abcde", '-', 10, LEFT); -- Returns "abcde-----"


remove_initial_chars()
----------------------------------------------------------------------------------------------------------------------------------
Returns the input string minus the 'num' first characters. ::

    string := remove_initial_chars(source, num)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | source             | in     | string                       | Input string                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | num                | in     | natural                      | Number of characters to remove                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_string := remove_initial_chars("abcde", 1); -- Returns "bcde"


replace() - function
----------------------------------------------------------------------------------------------------------------------------------
Returns a string where the target character has been replaced by the exchange character. ::

    string := replace(val, target_char, exchange_char)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | val                | in     | string                       | Input string                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | target_char        | in     | character                    | Character to be replaced                                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | exchange_char      | in     | character                    | Replacement character                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_string := replace("string_x", 'x', 'y'); -- Returns "string_y"


replace() - procedure
----------------------------------------------------------------------------------------------------------------------------------
Similar to function version of replace(). Line procedure replaces the input with a line where the target character has been 
replaced by the exchange character. ::

    replace(text_line, target_char, exchange_char)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| variable | text_line          | inout  | line                         | Text line                                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | target_char        | in     | character                    | Character to be replaced                                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | exchange_char      | in     | character                    | Replacement character                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    replace(str, 'a', 'b');


pos_of_leftmost()
----------------------------------------------------------------------------------------------------------------------------------
Returns the position of the leftmost character in the string. If not found, returns 'result_if_not_found'. ::

    natural := pos_of_leftmost(target, vector, [result_if_not_found])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | target             | in     | character                    | Character to search for                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vector             | in     | string                       | String where to look for the character                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | result_if_not_found| in     | natural                      | Return value if character not found. Default value is 1.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_natural := pos_of_leftmost('x', v_string);


pos_of_leftmost_non_zero()
----------------------------------------------------------------------------------------------------------------------------------
Returns the position of the leftmost character, which is not zero or white-space, in the string. If not found, returns 
'result_if_not_found'. ::

    natural := pos_of_leftmost_non_zero(vector, [result_if_not_found])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | vector             | in     | string                       | String where to look for the character                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | result_if_not_found| in     | natural                      | Return value if character not found. Default value is 1.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_natural := pos_of_leftmost_non_zero(v_string);


pos_of_rightmost()
----------------------------------------------------------------------------------------------------------------------------------
Returns the position of the rightmost character in the string. If not found, returns 'result_if_not_found'. ::

    natural := pos_of_rightmost(target, vector, [result_if_not_found])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | target             | in     | character                    | Character to search for                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vector             | in     | string                       | String where to look for the character                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | result_if_not_found| in     | natural                      | Return value if character not found. Default value is 1.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_natural := pos_of_rightmost('A', v_string);


pos_of_rightmost_non_whitespace()
----------------------------------------------------------------------------------------------------------------------------------
Returns the position of the rightmost character, which is not white-space, in the string. If not found, returns 'result_if_not_found'. ::

    natural := pos_of_rightmost_non_whitespace(vector, [result_if_not_found])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | vector             | in     | string                       | String where to look for the character                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | result_if_not_found| in     | natural                      | Return value if character not found. Default value is 1.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_natural := pos_of_rightmost_non_whitespace(v_string);


get_[procedure|process|entity]_name from_instance_name()
----------------------------------------------------------------------------------------------------------------------------------
Returns the procedure, process or entity name from the given instance name as a string. The instance name must be 
<object>'instance_name, where object is a signal, variable or constant defined in the procedure, process or entity respectively. ::

    string := get_procedure_name_from_instance_name(val)
    string := get_process_name_from_instance_name(val)
    string := get_entity_name_from_instance_name(val)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | val                | in     | string                       | Instance name                                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_string := get_procedure_name_from_instance_name(C_INT'instance_name);
    v_string := get_process_name_from_instance_name(C_INT'instance_name);
    v_string := get_entity_name_from_instance_name(C_INT'instance_name);


return_string_if_true()
----------------------------------------------------------------------------------------------------------------------------------
Returns the val string if the condition is true, otherwise it returns an empty string. ::

    string := return_string_if_true(val, return_val)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | val                | in     | string                       | String to return if condition is true                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | return_val         | in     | boolean                      | Condition to decide which string to return              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_string := return_string_if_true("abcde", v_print_txt);


return_string1_if_true_otherwise_string2()
----------------------------------------------------------------------------------------------------------------------------------
Returns the val1 string if the condition is true, otherwise it returns the val2 string. ::

    string := return_string1_if_true_otherwise_string2(val1, val2, return_val)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | val1               | in     | string                       | String to return if condition is true                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | val2               | in     | string                       | String to return if condition is false                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | return_val         | in     | boolean                      | Condition to decide which string to return              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_string := return_string1_if_true_otherwise_string2("abcde", "fghij", v_print_first);


Signal generators
==================================================================================================================================

clock_generator()
----------------------------------------------------------------------------------------------------------------------------------
Generates a clock signal. **Usage:** Include the clock_generator as a concurrent procedure from your testbench. ::

    clock_generator(clock_signal, [clock_count], clock_period, [clock_high_percentage])
    clock_generator(clock_signal, [clock_count], clock_period, clock_high_time)
    clock_generator(clock_signal, clock_ena, [clock_count], clock_period, clock_name, [clock_high_percentage])
    clock_generator(clock_signal, clock_ena, [clock_count], clock_period, clock_name, clock_high_time)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | clock_signal       | inout  | std_logic                    | Clock signal                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clock_ena          | in     | boolean                      | Start or stop the clock during simulation. Each start / |
|          |                    |        |                              | stop is logged (if msg_id ID_CLOCK_GEN is enabled).     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clock_count        | out    | natural                      | Counts the number of clock cycles. Starts at 0 and wraps|
|          |                    |        |                              | when reaching max value of natural type.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | clock_period       | in     | time                         | Clock period                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | clock_high_percent\| in     | natural                      | Duty cycle in percentage (1 to 99). Default value is 50.|
|          | age                |        |                              |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | clock_high_time    | in     | time                         | Duty cycle in time                                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | clock_name         | in     | string                       | Name of the clock                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    clock_generator(clk50M, 20 ns);
    clock_generator(clk100M, clk100M_ena, 10 ns, "100 MHz with 60% duty cycle", 60);
    clock_generator(clk100M, clk100M_ena, clk100M_cnt, 10 ns, "100 MHz with 60% duty cycle", 6 ns);


adjustable_clock_generator()
----------------------------------------------------------------------------------------------------------------------------------
Generates a clock with adjustable duty cycle. **Usage:** Include the adjustable_clock_generator as a concurrent procedure from 
your testbench. ::

    adjustable_clock_generator(clock_signal, clock_ena, clock_period, [clock_name], clock_high_percentage)
    adjustable_clock_generator(clock_signal, clock_ena, clock_count, clock_period, clock_name, clock_high_percentage)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | clock_signal       | inout  | std_logic                    | Clock signal                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clock_ena          | in     | boolean                      | Start or stop the clock during simulation. Each start / |
|          |                    |        |                              | stop is logged (if msg_id ID_CLOCK_GEN is enabled).     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clock_count        | out    | natural                      | Counts the number of clock cycles. Starts at 0 and wraps|
|          |                    |        |                              | when reaching max value of natural type.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | clock_period       | in     | time                         | Clock period                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clock_high_percent\| in     | natural                      | Duty cycle in percentage (1 to 99).                     |
|          | age                |        |                              |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | clock_name         | in     | string                       | Name of the clock                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    adjustable_clock_generator(clk50M, clk50M_ena, 20 ns, 50); 
    adjustable_clock_generator(clk50M, clk50M_ena, 20 ns, "100MHz clock with 50% duty cycle", 50);
    adjustable_clock_generator(clk50M, clk50M_ena, clk50M_cnt, 20 ns, "100MHz clock with 60% duty cycle", 60);


gen_pulse()
----------------------------------------------------------------------------------------------------------------------------------
Generates a pulse on the target signal for a certain amount of time or a number of clock cycles. *Note* that the clock_signal 
version will synchronize the pulse to clock_signal and begin the pulse on the falling edge and end the pulse on a succeeding 
falling edge. ::

    gen_pulse(target(sl), [pulse_value(sl)], pulse_duration, [blocking_mode], msg, [scope, [msg_id, [msg_id_panel]]])
    gen_pulse(target(sl), [pulse_value(sl)], clock_signal, num_periods, msg, [scope, [msg_id, [msg_id_panel]]])
    gen_pulse(target(bool), [pulse_value(bool)], pulse_duration, [blocking_mode], msg, [scope, [msg_id, [msg_id_panel]]])
    gen_pulse(target(bool), [pulse_value(bool)], clock_signal, num_periods, msg, [scope, [msg_id, [msg_id_panel]]])
    gen_pulse(target(slv), [pulse_value(slv)], pulse_duration, [blocking_mode], msg, [scope, [msg_id, [msg_id_panel]]])
    gen_pulse(target(slv), [pulse_value(slv)], clock_signal, num_periods, msg, [scope, [msg_id, [msg_id_panel]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | target             | inout  | *see overloads*              | Signal where to generate the pulse                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | pulse_value        | in     | *see overloads*              | Pulse value. Default is '1' | true | (others=>'1')      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clock_signal       | in     | std_logic                    | Clock signal to synchronize the pulse with              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | num_periods        | in     | integer                      | Duration of the pulse in clock periods                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | pulse_duration     | in     | time                         | Duration of the pulse in time                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | blocking_mode      | in     | :ref:`t_blocking_mode`       | When BLOCKING, the procedure blocks the caller until    |
|          |                    |        |                              | the pulse is done.                                      |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | When NON_BLOCKING, the procedure starts the pulse and   |
|          |                    |        |                              | schedules the end of the pulse so that the caller can   |
|          |                    |        |                              | continue immediately.                                   |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Default value is BLOCKING.                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID used in the log, defined in adaptations_pkg. |
|          |                    |        |                              | Default value is ID_GEN_PULSE.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    gen_pulse(sl_1, 50 ns, BLOCKING, "Pulsing for 50 ns");
    gen_pulse(sl_1, '1', 50 ns, BLOCKING, "Pulsing for 50 ns");
    gen_pulse(slv8, x"AB", clk100M, 2, "Pulsing SLV for 2 clock periods");


Synchronization
==================================================================================================================================

.. note::

    It is recommended to use a constant for flag_name to avoid typing errors in methods block_flag(), unblock_flag() and 
    await_unblock_flag().


block_flag()
----------------------------------------------------------------------------------------------------------------------------------
Blocks a flag to allow synchronization between processes. Adds a new blocked flag if it does not already exist. Maximum number of 
flags can be modified in adaptations_pkg. Generates an alert with already_blocked_severity if the flag is already blocked. ::

    block_flag(flag_name, msg, [already_blocked_severity, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | flag_name          | in     | string                       | Name of the flag. Recommended to use a constant.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | already_blocked_se\| in     | :ref:`t_alert_level`         | Sets the severity for the alert when a flag is already  |
|          | verity             |        |                              | blocked. Default value is WARNING.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    block_flag("my_flag", "blocking my flag");
    block_flag(C_MY_FLAG_1, "blocking " & C_MY_FLAG_1, WARNING, "My Scope");


unblock_flag()
----------------------------------------------------------------------------------------------------------------------------------
Unblocks a flag to allow a process that is waiting on that flag to continue. Adds a new unblocked flag if it does not already 
exist. ::

    unblock_flag(flag_name, msg, trigger, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | flag_name          | in     | string                       | Name of the flag. Recommended to use a constant.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | trigger            | inout  | std_logic                    | Must use the global signal **global_trigger** which     |
|          |                    |        |                              | allows await_unblock_flag() to detect unblocking        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    unblock_flag("my_flag", "unblocking my flag", global_trigger);
    unblock_flag(C_MY_FLAG_1, "unblocking " & C_MY_FLAG_1, global_trigger, "My Scope");


await_unblock_flag()
----------------------------------------------------------------------------------------------------------------------------------
Waits for a flag to be unblocked. Continues immediately if the flag already is unblocked. Adds a new blocked flag if it does not 
already exist and waits for the flag to be unblocked. Generates an alert with timeout_severity if the flag is not unblocked within 
the timeout. The flag can be re-blocked when leaving the process by setting flag_returning=RETURN_TO_BLOCK. ::

    await_unblock_flag(flag_name, timeout, msg, [flag_returning, [timeout_severity, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | flag_name          | in     | string                       | Name of the flag. Recommended to use a constant.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Timeout for the flag to be unblocked. A value of 0 ns   |
|          |                    |        |                              | means wait forever.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout_severity   | in     | :ref:`t_alert_level`         | Sets the severity for the alert when a flag is not      |
|          |                    |        |                              | unblocked within the timeout. Default value is ERROR.   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | flag_returning     | in     | :ref:`t_flag_returning`      | Status of the flag after exiting the procedure. Default |
|          |                    |        |                              | value is KEEP_UNBLOCKED.                                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    await_unblock_flag("my_flag", 0 ns, "waiting for my_flag to be unblocked");
    await_unblock_flag("my_flag", 10 us, "waiting for my_flag to be unblocked", RETURN_TO_BLOCK, WARNING);
    await_unblock_flag(C_MY_FLAG_1, 10 us, "waiting for " & C_MY_FLAG_1 & " to be unblocked", RETURN_TO_BLOCK, WARNING, "My Scope");


.. _await_barrier:

await_barrier()
----------------------------------------------------------------------------------------------------------------------------------
The procedure can be used to synchronize between several sequencers. When the procedure is called, it waits for all sequencers 
using the same barrier_signal to reach their call of await_barrier(). ::

    await_barrier(barrier_signal, timeout, msg, [timeout_severity, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | barrier_signal     | inout  | std_logic                    | Name of the barrier signal. You may use the predefined  |
|          |                    |        |                              | **global_barrier** or define your own barrier_signal of |
|          |                    |        |                              | type std_logic.                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Timeout for all the sequencers to reach the same barrier|
|          |                    |        |                              | signal. A value of 0 ns means wait forever.             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout_severity   | in     | :ref:`t_alert_level`         | Sets the severity for the alert when the barrier is not |
|          |                    |        |                              | reached within the timeout. Default value is ERROR.     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    await_barrier(global_barrier, 100 us, "waiting for global barrier", ERROR, "My Scope");


BFM Common package
==================================================================================================================================
Methods are defined in bfm_common_pkg.vhd

normalize_and_check()
----------------------------------------------------------------------------------------------------------------------------------
Normalize 'value' to the width given by 'target'.

* If value'length > target'length, remove leading zeros (or sign bits) from value.
* If value'length < target'length, add padding (leading zeros, or sign bits) to value.

.. code-block::

    std_logic_vector := normalize_and_check(value(slv), target(slv), mode, value_name, target_name, msg)
    unsigned         := normalize_and_check(value(u), target (u), mode, value_name, target_name, msg)
    signed           := normalize_and_check(value(s), target (s), mode, value_name, target_name, msg)
    t_slv_array      := normalize_and_check(value(t_slv_array), target(t_slv_array), mode, value_name, target_name, msg)
    t_unsigned_array := normalize_and_check(value(t_unsigned_array), target(t_unsigned_array), mode, value_name, target_name, msg)
    t_signed_array   := normalize_and_check(value(t_signed_array), target(t_signed_array), mode, value_name, target_name, msg)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | value              | in     | *see overloads*              | Value to be normalized                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | target             | in     | *see overloads*              | Parameter used to normalize the value                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | mode               | in     | :ref:`t_normalization_mode`  | Used for sanity checks, it can be one of:               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | ALLOW_WIDER : Allow only value'length >= target'length  |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | ALLOW_NARROWER : Allow only value'length <= target'le\  |
|          |                    |        |                              | gth                                                     |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | ALLOW_WIDER_NARROWER : Allow both of the above          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | ALLOW_EXACT_ONLY: Allow only value'length = target'le\  |
|          |                    |        |                              | gth                                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | value_name         | in     | string                       | Name of the value for logging purposes                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | target_name        | in     | string                       | Name of the target for logging purposes                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_slv8 := normalize_and_check(v_slv5, v_slv8, ALLOW_NARROWER, "8bit slv", "5bit slv", "Normalizing and checking slv");


wait_until_given_time_after_rising_edge()
----------------------------------------------------------------------------------------------------------------------------------
Wait until a certain time has passed after the rising edge of the clock. If the time passed since the previous rising_edge is less 
than wait_time, don't wait until the next rising_edge, just wait_time after the previous rising_edge. ::

    wait_until_given_time_after_rising_edge(clk, wait_time)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | clk                | in     | std_logic                    | Clock signal                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | wait_time          | in     | time                         | Time to wait after the rising edge of the clock         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    wait_until_given_time_after_rising_edge(clk50M, 5 ns);



wait_until_given_time_before_rising_edge()
----------------------------------------------------------------------------------------------------------------------------------
Wait until a certain time before the rising edge of the clock. If the time until rising_edge is less than time_to_edge, wait until 
the next rising_edge and afterwards until time_to_edge before rising_edge. ::

    wait_until_given_time_before_rising_edge(clk, time_to_edge, clk_period)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | clk                | in     | std_logic                    | Clock signal                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | time_to_edge       | in     | time                         | Time to wait before the rising edge of the clock        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | clk_period         | in     | time                         | Clock period                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    wait_until_given_time_before_rising_edge(clk50M, 2 ns, 10 ns);


wait_num_rising_edge()
----------------------------------------------------------------------------------------------------------------------------------
Waits for a number of rising edges of the clk signal. ::

    wait_num_rising_edge(clk, num_rising_edge)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | clk                | in     | std_logic                    | Clock signal                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | num_rising_edge    | in     | natural                      | Number of rising edges of the clock to wait for         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    wait_num_rising_edge(clk50M, 5);


wait_num_rising_edge_plus_margin()
----------------------------------------------------------------------------------------------------------------------------------
Waits for a number of rising edges of the clk signal, and then waits for a margin. ::

    wait_num_rising_edge_plus_margin(clk, num_rising_edge, margin)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | clk                | in     | std_logic                    | Clock signal                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | num_rising_edge    | in     | natural                      | Number of rising edges of the clock to wait for         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | margin             | in     | time                         | Time to wait after the rising edges of the clock        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    wait_num_rising_edge_plus_margin(clk50M, 3, 4 ns);


wait_on_bfm_sync_start()
----------------------------------------------------------------------------------------------------------------------------------
Synchronizes the start of a BFM procedure depending on the clock and bfm_sync. ::

    wait_on_bfm_sync_start(clk, bfm_sync, setup_time, config_clock_period, time_of_falling_edge, time_of_rising_edge)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | clk                | in     | std_logic                    | Clock signal                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | bfm_sync           | in     | :ref:`t_bfm_sync`            | SYNC_ON_CLOCK_ONLY: waits until the falling edge of     |
|          |                    |        |                              | the clk signal.                                         |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | SYNC_WITH_SETUP_AND_HOLD: waits until the setup time    |
|          |                    |        |                              | before the clock's rising_edge                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | setup_time         | in     | time                         | Setup time before the rising edge                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config_clock_period| in     | time                         | Clock period                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable |time_of_falling_edge| out    | time                         | Time of last the falling edge                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | time_of_rising_edge| out    | time                         | Time of last the rising edge. When not found, returns   |
|          |                    |        |                              | -1 ns.                                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    wait_on_bfm_sync_start(clk, config.bfm_sync, 2.5 ns, 10 ns, v_time_of_falling_edge, v_time_of_rising_edge);


wait_on_bfm_exit()
----------------------------------------------------------------------------------------------------------------------------------
Synchronizes the exit of a BFM procedure depending on the clock and bfm_sync. The times of falling and rising edges must be 
consecutive to be able to calculate the correct clock period. ::

    wait_on_bfm_exit(clk, bfm_sync, hold_time, time_of_falling_edge, time_of_rising_edge)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | clk                | in     | std_logic                    | Clock signal                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | bfm_sync           | in     | :ref:`t_bfm_sync`            | SYNC_ON_CLOCK_ONLY: waits until one quarter of the      |
|          |                    |        |                              | clock period (measured with the falling and rising      |
|          |                    |        |                              | edges) after the clock's rising_edge.                   |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | SYNC_WITH_SETUP_AND_HOLD: waits until the hold time     |
|          |                    |        |                              | after the clock's rising_edge.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | hold_time          | in     | time                         | Hold time after the rising edge                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant |time_of_falling_edge| in     | time                         | Time of the last falling edge                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | time_of_rising_edge| in     | time                         | Time of the last rising edge                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    wait_on_bfm_exit(clk, config.bfm_sync, 2.5 ns, v_time_of_falling_edge, v_time_of_rising_edge);


check_clock_period_margin()
----------------------------------------------------------------------------------------------------------------------------------
Checks that the clock signal behaves according to configured specifications. Only when bfm_sync = SYNC_WITH_SETUP_AND_HOLD. The 
procedure must be called after the clock's rising_edge. ::

    check_clock_period_margin(clock, bfm_sync, time_of_falling_edge, time_of_rising_edge, config_clock_period, config_clock_period_margin, config_clock_margin_severity)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | clock              | in     | std_logic                    | Clock signal                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | bfm_sync           | in     | :ref:`t_bfm_sync`            | Only SYNC_WITH_SETUP_AND_HOLD supported                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant |time_of_falling_edge| in     | time                         | Time of the last falling edge                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | time_of_rising_edge| in     | time                         | Time of the last rising edge                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config_clock_period| in     | time                         | Expected clock period                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config_clock_perio\| in     | time                         | Expected clock period margin                            |
|          | d_margin           |        |                              |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config_clock_margi\| in     | :ref:`t_alert_level`         | Sets the severity for the alert when the clock period   |
|          | n_severity         |        |                              | plus the margin is not followed. Default value is       |
|          |                    |        |                              | TB_ERROR.                                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge, 10 ns, 2 ns, TB_ERROR);


General Watchdog
==================================================================================================================================
* The general watchdog will terminate with the alert_level when timeout expires.
* The VVCs support an activity watchdog. See :ref:`Essential Mechanisms - Activity Watchdog <vvc_framework_activity_watchdog>` for 
  more details.

watchdog_timer()
----------------------------------------------------------------------------------------------------------------------------------
Initializes the watchdog timer as a concurrent procedure that will run until the timeout expires. A signal of the type 
t_watchdog_ctrl must be defined in the testbench, this is needed to call the other procedures on the watchdog.

.. note::

    This procedure has to be instantiated as a concurrent procedure in the testbench or test harness.

.. code-block::

    watchdog_timer(watchdog_ctrl, timeout, [alert_level, [msg]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | watchdog_ctrl      | in     | :ref:`t_watchdog_ctrl`       | Signal controlling the watchdog timer                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Watchdog timeout                                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert when the watchdog timer |
|          |                    |        |                              | expires. Default value is ERROR.                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert.       |
|          |                    |        |                              | Default value is "".                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    watchdog_timer(watchdog_ctrl, 500 us, ERROR, "Watchdog timer");


extend_watchdog()
----------------------------------------------------------------------------------------------------------------------------------
Extends the timeout of the watchdog timer by the specified time. If no time is given, the original timeout will be used as the 
time extension. ::

    extend_watchdog(extend_watchdog, [time_extend])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | watchdog_ctrl      | inout  | :ref:`t_watchdog_ctrl`       | Signal controlling the watchdog timer                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | time_extend        | in     | time                         | Time to extend the watchdog timer. Default value is     |
|          |                    |        |                              | original timeout.                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    extend_watchdog(watchdog_ctrl, 100 us);


reinitialize_watchdog()
----------------------------------------------------------------------------------------------------------------------------------
Re-initializes the watchdog timer with a new timeout. ::

    reinitialize_watchdog(watchdog_ctrl, timeout)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | watchdog_ctrl      | inout  | :ref:`t_watchdog_ctrl`       | Signal controlling the watchdog timer                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | New watchdog timeout                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    reinitialize_watchdog(watchdog_ctrl, 1 ms);


terminate_watchdog()
----------------------------------------------------------------------------------------------------------------------------------
Terminates the concurrent procedure where the watchdog timer is running. Once this is done the watchdog can't be started again. 
This should normally be called at the end of the simulation. ::

    terminate_watchdog(watchdog_ctrl)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | watchdog_ctrl      | inout  | :ref:`t_watchdog_ctrl`       | Signal controlling the watchdog timer                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    terminate_watchdog(watchdog_ctrl);


**********************************************************************************************************************************
Types
**********************************************************************************************************************************
.. toctree::
   :maxdepth: 1

   types_pkg.rst

.. _message_ids:

**********************************************************************************************************************************
Message IDs
**********************************************************************************************************************************
The predefined message IDs are listed in the table below. All the message IDs are defined in adaptations_pkg.vhd

+--------------------------+-----------------------------------------------------------------------------------------------------+
| Message ID               | Description                                                                                         |
+==========================+=====================================================================================================+
| -- **Bitvis utility methods**                                                                                                  |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| NO_ID                    | Used as default prior to setting actual ID when transferring ID as a field in a record              |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_UTIL_BURIED           | Used for buried log messages where msg and scope cannot be modified from outside                    |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_BITVIS_DEBUG          | Bitvis internal ID used for UVVM debugging                                                          |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_UTIL_SETUP            | Used for Utility setup                                                                              |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_LOG_MSG_CTRL          | Dedicated ID for enable/disable_log_msg.                                                            |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_ALERT_CTRL            | Used inside Utility library only - when setting IGNORE or REGARD on various alerts.                 |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_NEVER                 | Used for avoiding log entry. Cannot be enabled.                                                     |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_FINISH_OR_STOP        | Used when terminating the complete simulation - independent of why                                  |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_CLOCK_GEN             | Used for logging when clock generators are enabled or disabled.                                     |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_GEN_PULSE             | Used for logging when a gen_pulse procedure starts pulsing a signal.                                |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_BLOCKING              | Used for logging when using synchronization flags                                                   |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_WATCHDOG              | Used for logging the activity of the watchdog                                                       |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_RAND_GEN              | Used for logging "Enhanced Randomization" values returned by rand()\randm()                         |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_RAND_CONF             | Used for logging "Enhanced Randomization" configuration changes, except from name and scope         |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_FUNC_COV_BINS         | Used for logging functional coverage add_bins() and add_cross() methods                             |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_FUNC_COV_BINS_INFO    | Used for logging functional coverage add_bins() and add_cross() methods detailed information        |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_FUNC_COV_RAND         | Used for logging functional coverage "Optimized Randomization" values returned by rand()            |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_FUNC_COV_SAMPLE       | Used for logging functional coverage sampling                                                       |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_FUNC_COV_CONFIG       | Used for logging functional coverage configuration changes                                          |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| -- **General**                                                                                                                 |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_POS_ACK               | To write a positive acknowledge on a check                                                          |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| -- **Directly inside test sequencers**                                                                                         |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_LOG_HDR               | For all test sequencer log headers. Special format with preceding empty line and underlined message |
|                          | (also applies to ID_LOG_HDR_LARGE and ID_LOG_HDR_XL).                                               |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_LOG_HDR_LARGE         | For all test sequencer large log headers.                                                           |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_LOG_HDR_XL            | For all test sequencer extra large log headers.                                                     |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_SEQUENCER             | For all other test sequencer messages.                                                              |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_SEQUENCER_SUB         | For general purpose procedures defined inside TB and called from test sequencer.                    |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| -- **BFMs**                                                                                                                    |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_BFM                   | BFM operation (e.g. message that a write operation is completed) (BFM: Bus Functional Model,        |
|                          | basically a procedure to handle a physical interface).                                              |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_BFM_WAIT              | Typically BFM is waiting for response (e.g. waiting for ready, or predefined number of wait states).|
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_BFM_POLL              | Used inside a BFM when polling until reading a given value, i.e., to show all reads until expected  |
|                          | value found.                                                                                        |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_BFM_POLL_SUMMARY      | Used inside a BFM when showing the summary of data that has been received while waiting for expected|
|                          | data.                                                                                               |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_CHANNEL_BFM           | Used inside a BFM when the protocol is split into separate channels                                 |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_TERMINATE_CMD         | Typically used inside a loop in a procedure to end the loop (e.g. for sbi_poll_until() or any looped|
|                          | generation of random stimuli                                                                        |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| -- **Segment Ids, finest granularity of packet data**                                                                          |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_SEGMENT_INITIATE      | Notify that a segment is about to be transmitted or received                                        |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_SEGMENT_COMPLETE      | Notify that a segment has been transmitted or received                                              |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_SEGMENT_HDR           | Notify that a segment header has been transmitted or received. It also writes header info           |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_SEGMENT_DATA          | Notify that a segment data has been transmitted or received. It also writes segment data            |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| -- **Packet Ids, medium granularity of packet data**                                                                           |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_PACKET_INITIATE       | Notify that a packet is about to be transmitted or received                                         |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_PACKET_PREAMBLE       | Notify that a packet preamble has been transmitted or received                                      |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_PACKET_COMPLETE       | Notify that a packet has been transmitted or received                                               |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_PACKET_HDR            | Notify that a packet header has been transmitted or received. It also writes header info            |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_PACKET_DATA           | Notify that a packet data has been transmitted or received. It also writes packet data              |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_PACKET_CHECKSUM       | Notify that a packet checksum has been transmitted or received                                      |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_PACKET_GAP            | Notify that an inter-packet gap is in process                                                       |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_PACKET_PAYLOAD        | Notify that a packet payload has been transmitted or received                                       |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| -- **Frame Ids, roughest granularity of packet data**                                                                          |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_FRAME_INITIATE        | Notify that a frame is about to be transmitted or received                                          |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_FRAME_COMPLETE        | Notify that a frame has been transmitted or received                                                |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_FRAME_HDR             | Notify that a frame header has been transmitted or received. It also writes header info             |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_FRAME_DATA            | Notify that a frame data has been transmitted or received. It also writes frame data                |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| -- **Distributed command systems**                                                                                             |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_UVVM_SEND_CMD         | Logs the commands sent to the VVC                                                                   |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_UVVM_CMD_ACK          | Logs the command's ACKs or timeouts from the VVC                                                    |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_UVVM_CMD_RESULT       | Logs the fetched results from the VVC                                                               |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_CMD_INTERPRETER       | Message from VVC interpreter about correctly received and queued/issued command                     |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_CMD_INTERPRETER_WAIT  | Message from VVC interpreter that it is actively waiting for a command                              |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_IMMEDIATE_CMD         | Message from VVC interpreter that an IMMEDIATE command has been executed                            |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_IMMEDIATE_CMD_WAIT    | Message from VVC interpreter that an IMMEDIATE command is waiting for command to complete           |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_CMD_EXECUTOR          | Message from VVC executor about correctly received command - prior to actual execution              |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_CMD_EXECUTOR_WAIT     | Message from VVC executor that it is actively waiting for a command                                 |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_CHANNEL_EXECUTOR      | Message from a channel specific VVC executor process                                                |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_CHANNEL_EXECUTOR_WAIT | Message from a channel specific VVC executor process that it is actively waiting for a command      |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_NEW_HVVC_CMD_SEQ      | Message from a lower level VVC which receives a new command sequence from an HVVC                   |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_INSERTED_DELAY        | Message from VVC executor that it is waiting a given delay                                          |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| -- **Await completion**                                                                                                        |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_OLD_AWAIT_COMPLETION  | Temporary log messages related to old await_completion mechanism. Will be removed in v3.0           |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_AWAIT_COMPLETION      | Used for logging the procedure call waiting for completion                                          |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_AWAIT_COMPLETION_LIST | Used for logging modifications to the list of VVCs waiting for completion                           |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_AWAIT_COMPLETION_WAIT | Used for logging when the procedure starts waiting for completion                                   |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_AWAIT_COMPLETION_END  | Used for logging when the procedure has finished waiting for completion                             |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| -- **Distributed data**                                                                                                        |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_UVVM_DATA_QUEUE       | Information about UVVM data FIFO/stack (initialization, put, get, etc)                              |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| -- **VVC system**                                                                                                              |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_CONSTRUCTOR           | Constructor message from VVCs (or other components/process when needed)                             |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_CONSTRUCTOR_SUB       | Constructor message for lower level constructor messages (like Queue-information and other          |
|                          | limitations)                                                                                        |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_VVC_ACTIVITY          |                                                                                                     |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| -- **Monitors**                                                                                                                |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_MONITOR               | General monitor information                                                                         |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_MONITOR_ERROR         | General monitor errors                                                                              |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| -- **SB package**                                                                                                              |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_DATA                  | To write general handling of data                                                                   |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_CTRL                  | To write general control/config information                                                         |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| -- **Specification requirement coverage**                                                                                      |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_SPEC_COV_INIT         | Used for logging specification requirement coverage initialization                                  |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_SPEC_COV_REQS         | Used for logging the specification requirement list                                                 |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_SPEC_COV              | Used for logging general specification requirement coverage methods                                 |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| -- **File handling**                                                                                                           |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_FILE_OPEN_CLOSE       | Id used when opening / closing file                                                                 |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ID_FILE_PARSER           | Id used in file parsers                                                                             |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| -- **Special purpose - Not really IDs**                                                                                        |
+--------------------------+-----------------------------------------------------------------------------------------------------+
| ALL_MESSAGES             | Not an ID. Applies to all IDs (apart from ID_NEVER).                                                |
+--------------------------+-----------------------------------------------------------------------------------------------------+

Message IDs are used for verbosity control in many of the procedures and functions in UVVM-Util, and are toggled by using the 
procedures :ref:`util_enable_log_msg` and :ref:`util_disable_log_msg`.

**Example:** A check is performed each clock cycle ::

    check_value(my_boolean_condition, error, "Verifying condition", C_SCOPE, ID_POS_ACK, my_msg_id_panel);

The message ID 'ID_POS_ACK' is enabled by default, and will report a positive acknowledge if the check passes. Since the check is 
performed each clock cycle, the positive acknowledge will be printed each clock cycle. There are two possibilities if you wish to 
turn off the positive acknowledge message:

* Disable 'ID_POS_ACK' in my_msg_id_panel (or use another msg_id_panel) by calling ``disable_log_msg(ID_POS_ACK, my_msg_id_panel)``.
  This will disable positive acknowledge messages for any procedure call that uses this msg_id_panel.
* Call ``check_value()`` with 'ID_NEVER' instead of 'ID_POS_ACK'. This will disable the positive acknowledge for this particular 
  call of ``check_value()``, but all other calls to ``check_value()`` will report a positive acknowledge.

.. _util_hierarchical_report:

**********************************************************************************************************************************
Using Hierarchical Alert Reporting
**********************************************************************************************************************************
* Methods are defined in alert_hierarchy_pkg.vhd
* Enable hierarchical alerts via the constant C_ENABLE_HIERARCHICAL_ALERTS in the adaptations package.
* By default, there is only one level in the hierarchy tree, and one scope with name given by C_BASE_HIERARCHY_LEVEL in 
  the adaptations package. This scope has a stop limit of 0 by default.
* To add a scope to the hierarchy, call add_to_alert_hierarchy().
* Any scope that is not registered in the hierarchy will be automatically registered if an alert is triggered in that scope. 
  The parent scope will then be C_BASE_HIERARCHY_LEVEL. Changing the parent is possible by calling add_to_alert_hierarchy() 
  with another scope as parent. This is only allowed if the parent is C_BASE_HIERARCHY_LEVEL and may cause an odd-looking 
  summary (total summary will be correct).

| **Intended use**:
| In UVVM mostly use the scope to describe components, e.g. VVCs. It can also be smaller structures, but it has to have its own 
  sequencer. A good way to set up the hierarchy is to let every scope register themselves with the default parent scope, and then 
  in addition make every parent register each of its children. This is because the child scope doesn't have to have the same 
  parent scope in all testbenches/test-harnesses, i.e. the child doesn't know its parent.

* In the child, call add_to_alert_hierarchy(<child scope>). This will add the scope of the child to the hierarchy with the default 
  (base) parent.
* In the parent, first call add_to_alert_hierarchy(<parent scope>). Then call immediately add_to_alert_hierarchy(<child scope>, 
  <parent scope>) for each of the scopes that shall be children of this parent scope. This will re-register the children to the 
  correct parent.

**Example output**

.. figure:: /images/hierarchical_alerts.png
   :alt: Example output

Methods
==================================================================================================================================

TODO:
procedure initialize_hierarchy(
constant base_scope : string := C_BASE_HIERARCHY_LEVEL;
constant stop_limit : t_alert_counters := (others => 0)
);


add_to_alert_hierarchy()
----------------------------------------------------------------------------------------------------------------------------------
Add a scope in the alert hierarchy tree. ::

    add_to_alert_hierarchy(scope, [parent_scope, [stop_limit]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | scope              | in     | string                       |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | parent_scope       | in     | string                       | Default value is C_BASE_HIERARCHY_LEVEL.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | stop_limit         | in     | :ref:`t_alert_counters`      | Default value is (others => ‘0’).                       |
|          |                    |        |                              |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    add_to_alert_hierarchy("tier_2", "tier_1");


TODO:
procedure set_hierarchical_alert_top_level_stop_limit(
constant alert_level : t_alert_level;
constant value : natural
);

TODO:
impure function get_hierarchical_alert_top_level_stop_limit(
constant alert_level : t_alert_level
) return natural;

TODO:
procedure hierarchical_alert(
constant alert_level: t_alert_level;
constant msg : string;
constant scope : string;
constant attention : t_attention
);


increment_expected_alerts()
----------------------------------------------------------------------------------------------------------------------------------
Increment the expected alert counter for a scope. ::

    increment_expected_alerts(scope, alert_level, [amount])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | scope              | in     | string                       |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | amount             | in     | natural                      | Default value is 1.                                     |
|          |                    |        |                              |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    increment_expected_alerts("tier_2", ERROR, 2);

+-----------------------+-------------------------------+
| amount                | 1                             |
+-----------------------+-------------------------------+


set_expected_alerts()
----------------------------------------------------------------------------------------------------------------------------------
Set the expected alert counter for a scope. ::

    set_expected_alerts(scope, alert_level, expected_alerts)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | scope              | in     | string                       |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | expected_alerts    | in     | natural                      |                                                         |
|          |                    |        |                              |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    set_expected_alerts("tier_2", WARNING, 5);


increment_stop_limit()
----------------------------------------------------------------------------------------------------------------------------------
Increment the stop limit for a scope. ::

    increment_stop_limit(scope, alert_level, [amount])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | scope              | in     | string                       |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | amount             | in     | natural                      | Default value is 1.                                     |
|          |                    |        |                              |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    increment_stop_limit("tier_1", ERROR);


set_stop_limit()
----------------------------------------------------------------------------------------------------------------------------------
Set the stop limit for a scope. ::

    increment_stop_limit(scope, alert_level, stop_limit)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | scope              | in     | string                       |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | stop_limit         | in     | natural                      |                                                         |
|          |                    |        |                              |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    set_stop_limit("tier_1", ERROR, 5);


TODO:
procedure print_hierarchical_log(
constant order : t_order := FINAL
);

TODO:
procedure clear_hierarchy(
constant VOID : t_void
);

.. _adaptations_pkg:

**********************************************************************************************************************************
Adaptations package
**********************************************************************************************************************************
The adaptations_pkg.vhd is intended for local modifications to library behavior and log layout. This way only one file needs to 
merge when a new version of the library is released. This package may of course also be used to set up a company or project 
specific behavior and layout.

The package has constants for customizing functionality such as:

    * setting the alert and log files names
    * removing UVVM initial and release info printed in simulation
    * log format, e.g.: log prefix, log widths, scope default value
    * :ref:`message ids <message_ids>`
    * verbosity control, e.g.: default log msg ID, default message ID panel, default message ID indentation
    * alert counters, e.g.: default alert attention, default stop limit
    * hierarchical alerts, e.g.: enabling hierarchical alerts
    * synchronization, e.g.: maximum sync flags
    * enhanced randomization, e.g.: initial randomization seeds
    * functional coverage, e.g.: maximum number of coverpoints
    * VVC framework, e.g.: maximum number of VVC instances
    * scoreboard, e.g.: maximum number of SB instances
    * hierarchical VVCs, e.g.: supported interfaces
    * CRC

+-----------------------------------+-------------------+-----------------------------------------------------------+
| Global signal                     | Type              | Description                                               |
+===================================+===================+===========================================================+
| global_show_msg_for_uvvm_cmd      | boolean           | If true, the msg parameter for the commands using the     |
|                                   |                   | msg_id ID_UVVM_SEND_CMD will be shown                     |
+-----------------------------------+-------------------+-----------------------------------------------------------+

+-----------------------------------+-------------------+-----------------------------------------------------------+
| Global variable                   | Type              | Description                                               |
+===================================+===================+===========================================================+
| shared_default_log_destination    | t_log_destination | The default destination for the log messages              |
|                                   |                   | (Default: CONSOLE_AND_LOG)                                |
+-----------------------------------+-------------------+-----------------------------------------------------------+

**********************************************************************************************************************************
Additional Documentation
**********************************************************************************************************************************
There are two other main documents for the UVVM Utility Library:

    * Making a simple, structured and efficient VHDL testbench – Step-by-step (PPT)
    * UVVM Utility Library – Concepts and Usage (PPT)

There is also a webinar available on 'Making a simple, structured and efficient VHDL testbench – Step-by-step' (via Aldec [#f2]_)

**********************************************************************************************************************************
Compilation
**********************************************************************************************************************************
The UVVM Utility Library must be compiled with VHDL-2008 or newer.

.. table:: Compile order for the UVVM Utility Library

    +------------------------------+------------------------------------------------+
    | Compile to library           | File                                           |
    +==============================+================================================+
    | uvvm_util                    | uvvm_util/src/types_pkg.vhd                    |
    +------------------------------+------------------------------------------------+
    | uvvm_util                    | uvvm_util/src/adaptations_pkg.vhd              |
    +------------------------------+------------------------------------------------+
    | uvvm_util                    | uvvm_util/src/string_methods_pkg.vhd           |
    +------------------------------+------------------------------------------------+
    | uvvm_util                    | uvvm_util/src/protected_types_pkg.vhd          |
    +------------------------------+------------------------------------------------+
    | uvvm_util                    | uvvm_util/src/global_signals_and_shared_variab\|
    |                              | les_pkg.vhd                                    |
    +------------------------------+------------------------------------------------+
    | uvvm_util                    | uvvm_util/src/hierarchy_linked_list_pkg.vhd    |
    +------------------------------+------------------------------------------------+
    | uvvm_util                    | uvvm_util/src/alert_hierarchy_pkg.vhd          |
    +------------------------------+------------------------------------------------+
    | uvvm_util                    | uvvm_util/src/license_pkg.vhd                  |
    +------------------------------+------------------------------------------------+
    | uvvm_util                    | uvvm_util/src/methods_pkg.vhd                  |
    +------------------------------+------------------------------------------------+
    | uvvm_util                    | uvvm_util/src/bfm_common_pkg.vhd               |
    +------------------------------+------------------------------------------------+
    | uvvm_util                    | uvvm_util/src/generic_queue_pkg.vhd            |
    +------------------------------+------------------------------------------------+
    | uvvm_util                    | uvvm_util/src/data_queue_pkg.vhd               |
    +------------------------------+------------------------------------------------+
    | uvvm_util                    | uvvm_util/src/data_fifo_pkg.vhd                |
    +------------------------------+------------------------------------------------+
    | uvvm_util                    | uvvm_util/src/data_stack_pkg.vhd               |
    +------------------------------+------------------------------------------------+
    | uvvm_util                    | uvvm_util/src/rand_pkg.vhd                     |
    +------------------------------+------------------------------------------------+
    | uvvm_util                    | uvvm_util/src/func_cov_pkg.vhd                 |
    +------------------------------+------------------------------------------------+
    | uvvm_util                    | uvvm_util/src/uvvm_util_context.vhd            |
    +------------------------------+------------------------------------------------+

.. note::

    Modelsim and Riviera-PRO users can compile the library by sourcing the following file: ``script/compile_src.do``.

Suppressed warnings
==================================================================================================================================
The compile script compiles the Utility Library with the following directives for the vcom command to suppress warnings about the 
use of protected types and interface objects not being globally static. **These can be ignored.**

    * Modelsim: -suppress 1346,1236
    * Riviera-PRO: -nowarn COMP96_0564 -nowarn COMP96_0048

.. _util_simulator_compatibility:

**********************************************************************************************************************************
Simulator compatibility and setup
**********************************************************************************************************************************
* See :ref:`uvvm_prerequisites` for a list of supported simulators.

Required setup:

    * Textio buffering should be removed or reduced. (Modelsim.ini: Set UnbufferedOutput to 1)
    * Simulator transcript (and log file viewer) should be set to a fixed width font type for proper alignment (e.g. Courier New 8)
    * Simulator must be set up to break the simulation on failure (or lower severity)

.. include:: rst_snippets/ip_disclaimer.rst


.. rubric:: Footnotes

.. [#f1] IEEE = Method is native for VHDL-2008 (method is listed here for completeness).
.. [#f2] https://www.aldec.com/en/support/resources/multimedia/webinars/1673
