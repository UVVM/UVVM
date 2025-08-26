.. _vip_scoreboard:

##################################################################################################################################
Bitvis VIP Scoreboard
##################################################################################################################################

**********************************************************************************************************************************
Introduction
**********************************************************************************************************************************
All Scoreboard functions and procedures commonly referred to as methods are defined in the UVVM Scoreboard package, generic_sb_pkg.vhd

The scoreboard can be used with a single instance or with multiple instances. An instance is a separate queue with its own statistics. 
When multiple instances are used, the methods are called with the instance parameter. When only using a single scoreboard instance, 
the instance parameter may be omitted if that instance index is 1. Multiple instances are typically used when multiple scoreboards 
with the same data types are needed. Note that scoreboard instance numbering is in the range of 0 to N, with 1 as default.

All parameters in brackets are optional. No optional parameter can be used without using the preceding optional parameter, with the 
exception of the instance parameter.

Each entry in the scoreboard instance consists of an expected element, source element and tag. Each entry also has an entry number, 
which is specific for each entry. The entry number is used as an identifier for a specific entry in some of the advanced methods.

A message parameter can be used for print to transcript for all methods that affect the data or the functionality of the scoreboard.


**********************************************************************************************************************************
Simple usage
**********************************************************************************************************************************
In the predefined_sb.vhd file there is a slv and an integer predefined scoreboard, and setting up a scoreboard is fast and has only 
a few mandatory steps:

#. Declare the scoreboard package and the generics
#. Define the scoreboard as a shared variable
#. Set the configuration, scope and enable the scoreboard
#. Start using the scoreboard

Scoreboard declaration: ::

   package slv_sb_pkg is new bitvis_vip_scoreboard.generic_sb_pkg
   generic map(t_element         => std_logic_vector(7 downto 0),
               element_match     => std_match,
               to_string_element => to_string,
               sb_config_default => C_SLV_SB_CONFIG_DEFAULT);

   use slv_sb_pkg.all;
   shared variable slv_sb : slv_sb_pkg.t_generic_sb;

In sequencer: ::

   library bitvis_vip_scoreboard;
   use bitvis_vip_scoreboard.generic_sb_support_pkg.all;
   ...
   slv_sb.config(C_SB_CONFIG_DEFAULT); -- initialize scoreboard
   slv_sb.enable(VOID);                -- enable scoreboard
   slv_sb.set_scope("SLV SB");         -- set name of scoreboard
   ...
   slv_sb.add_expected(v_expected, "Adding expected");
   ...
   slv_sb.check_received(v_output, "Checking DUT output");
   ...
   check_value(slv_sb.is_empty(VOID), ERROR, "Check that scoreboard is empty");
   ...
   slv_sb.report_counters(VOID);

For more advanced examples see VHDL example code file.


.. _t_sb_config:

**********************************************************************************************************************************
Configuration Record
**********************************************************************************************************************************
**t_sb_config**

Default value for the record is C_SB_CONFIG_DEFAULT.

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| mismatch_alert_level         | :ref:`t_alert_level`         | ERROR           | The severity level of alert if mismatch between |
|                              |                              |                 | expected and received                           |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| allow_lossy                  | boolean                      | false           | If TRUE, all entries are searched until a       |
|                              |                              |                 | matching entry is found, all entries before the |
|                              |                              |                 | match are dropped. If no matching entry is found|
|                              |                              |                 | a mismatch is registered.                       |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| allow_out_of_order           | boolean                      | false           | If TRUE, all entries are searched until match.  |
|                              |                              |                 | If no matching entry is found, a mismatch is    |
|                              |                              |                 | registered                                      |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| overdue_check_alert_level    | :ref:`t_alert_level`         | ERROR           | The severity level of alert if the time between |
|                              |                              |                 | entry and check is more than limit              |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| overdue_check_time_limit     | time                         | 0 ns            | The time limit of which the entries should be in|
|                              |                              |                 | scoreboard. 0 ns indicates no time limit.       |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| ignore_initial_garbage       | boolean                      | false           | If TRUE, all mismatches before first match are  |
|                              |                              |                 | ignored and increment the initial drop count.   |
|                              |                              |                 | Typically used if garbage data is expected at   |
|                              |                              |                 | start-up.                                       |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

.. note::

    * The configuration cannot be set with true for both allow_lossy and allow_out_of_order.
    * This will raise a TB_ERROR when running the config method.


**********************************************************************************************************************************
Generics
**********************************************************************************************************************************

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Name                         | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| N/A                          | t_element                    | N/A             | Type used for the scoreboard elements           |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| element_match                | function                     | N/A             | Function for comparing two t_element values. For|
|                              |                              |                 | std_logic_vector one can use std_match.         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| to_string_element            | function                     | N/A             | Function for printing the t_element value. If it|
|                              |                              |                 | is a VHDL type, one can use to_string, otherwise|
|                              |                              |                 | create a dedicated function.                    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| sb_config_default            | :ref:`t_sb_config            | C_SB_CONFIG_DEF\| Default configuration of the scoreboard         |
|                              | <t_sb_config>`               | AULT            |                                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_QUEUE_COUNT_MAX           | natural                      | 1000            | Absolute maximum number of elements in the      |
|                              |                              |                 | Scoreboard queue                                |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_QUEUE_COUNT_THRESHOLD     | natural                      | 950             | An alert will be generated when reaching this   |
|                              |                              |                 | threshold to indicate that the scoreboard queue |
|                              |                              |                 | is almost full. The queue will still accept new |
|                              |                              |                 | commands until it reaches GC_QUEUE_COUNT_MAX.   |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+


**********************************************************************************************************************************
Basic methods
**********************************************************************************************************************************
* All parameters in brackets are optional.


config()
==================================================================================================================================
This method updates the scoreboard instance with the configuration input. The method with sb_config parameter can be called with 
an instance parameter, and the sb_config is then applied to the specified instance. If there is no instance parameter, the config 
is applied to instance 1. If the parameter is an array, the config at index n is applied to instance n.
This method uses the ID_CTRL message ID.

.. code-block::

    config([instance], sb_config, [msg])
    config(sb_config_array, [msg])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | sb_config          | in     | :ref:`t_sb_config            | Configuration of the scoreboard                         |
|          |                    |        | <t_sb_config>`               |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | sb_config_array    | in     | t_sb_config_array            | Array of configurations for several instances of the    |
|          |                    |        |                              | scoreboard                                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    uart_sb.config(C_UART_SB_CONFIG);
    uart_sb.config(2, C_UART_SB_CONFIG, "Initialize config on instance 2");
    uart_sb.config(C_UART_SB_CONFIG_ARRAY, "Initialize config on instances 1-5");


enable()
==================================================================================================================================
Enables the specified instance and must be called before any other method is called, except config(). This method can be called 
with ALL_INSTANCES as parameter. If there is no instance parameter, instance 1 is enabled.
This method uses the ID_CTRL message ID.

.. code-block::

    enable(VOID)
    enable([instance], [msg])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    uart_sb.enable(VOID);
    uart_sb.enable(2, "Enable instance 2");
    uart_sb.enable(ALL_INSTANCES, "Enable all instances");


disable()
==================================================================================================================================
Disables the specified instance. This method can be called with ALL_INSTANCES as parameter. If there is no instance parameter, 
instance 1 is disabled.
This method uses the ID_CTRL message ID.

.. code-block::

    disable(VOID)
    disable([instance], [msg])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    uart_sb.disable(VOID);
    uart_sb.disable(2, "Disable instance 2");
    uart_sb.disable(ALL_INSTANCES, "Disable all instances");


add_expected()
==================================================================================================================================
Inserts expected element at the end of scoreboard. If there is no instance parameter, instance 1 is used.
This method uses the ID_DATA message ID.

.. code-block::

    add_expected([instance], expected_element, [msg, [source]])
    add_expected([instance], expected_element, tag_usage, tag, [msg, [source]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | expected_element   | in     | t_element                    | The element that shall be pushed to the queue           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | tag_usage          | in     | t_tag_usage                  | Enumerated type used before every tag is entered. Only  |
|          |                    |        |                              | 'TAG' can be used.                                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | tag                | in     | string                       | Tag of the scoreboard element                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | source             | in     | string                       | The element that is the raw-input to the DUT, before    |
|          |                    |        |                              | DUT-processing. For debugging and logging only.         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    uart_sb.add_expected(x"AA"); 
    uart_sb.add_expected(1, x"AA", "Insert byte 1", x"A");
    uart_sb.add_expected(1, x"AA", TAG, "byte1", "Insert byte 1", x"A");


check_received()
==================================================================================================================================
Checks received data against oldest element in the scoreboard. If the element is found, it is removed from the scoreboard and the 
matched-counter is incremented. If the element is not found, an alert is triggered and the mismatch-counter is incremented. If 
out-of-order is allowed, the scoreboard is searched from front to back. The mismatch-counter is incremented if no match is found. 
If lossy is allowed, the scoreboard is searched from front to back. If a match occurs, the match counter is incremented and the 
preceding entries dropped. If no match occurs, the mismatch counter is incremented. If there is no instance parameter, instance 1 
is used.
This method uses the ID_DATA message ID.

.. code-block::

    check_received([instance], received_element, [msg])
    check_received([instance], received_element, tag_usage, tag, [msg])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | received_element   | in     | t_element                    | The element that shall be checked in scoreboard         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | tag_usage          | in     | t_tag_usage                  | Enumerated type used before every tag is entered. Only  |
|          |                    |        |                              | 'TAG' can be used.                                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | tag                | in     | string                       | Tag of the scoreboard element                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    uart_sb.check_received(v_received_byte);
    uart_sb.check_received(2, v_received_byte, "Check byte1");                -- Check received data against scoreboard elements in instance 2
    uart_sb.check_received(3, v_received_byte, TAG, "byte1", "Check byte 1"); -- Check received data against scoreboard elements with the TAG "byte1" in instance 3


flush()
==================================================================================================================================
Deletes all entries in the specified instance. Can also be called with parameter ALL_INSTANCES. If there is no instance parameter, 
instance 1 is used.
This method uses the ID_DATA message ID.

.. code-block::

    flush(VOID)
    flush([instance], [msg])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    uart_sb.flush(VOID); 
    uart_sb.flush(2);
    uart_sb.flush(ALL_INSTANCES, "Flushing all instances");


reset()
==================================================================================================================================
Deletes all entries and resets the statistics in the specified instance. Config is not affected. Can also be called with parameter 
ALL_INSTANCES. If there is no instance parameter, instance 1 is used.
This method uses the ID_CTRL message ID.

.. code-block::

    reset(VOID)
    reset([instance], [msg])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    uart_sb.reset(VOID); 
    uart_sb.reset(2);
    uart_sb.reset(ALL_INSTANCES, "Resetting all instances");


is_empty()
==================================================================================================================================
Returns true if the scoreboard instance is empty. If there is no instance parameter, instance 1 is used.

.. code-block::

    boolean := is_empty(VOID)
    boolean := is_empty(instance)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    if uart_sb.is_empty(2) then ...


get_entered_count()
==================================================================================================================================
Returns the total number of entries that have been added or inserted into the scoreboard. If there is no instance parameter, 
instance 1 is used.

.. code-block::

    integer := get_entered_count(VOID)
    integer := get_entered_count(instance)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_entered_count := uart_sb.get_entered_count(0);


get_pending_count()
==================================================================================================================================
Returns the number of remaining entries in scoreboard. If there is no instance parameter, instance 1 is used.

.. code-block::

    integer := get_pending_count(VOID)
    integer := get_pending_count(instance)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_pending_count := uart_sb.get_pending_count(0);


get_match_count()
==================================================================================================================================
Returns the number of checks with match in scoreboard. If there is no instance parameter, instance 1 is used.

.. code-block::

    integer := get_match_count(VOID)
    integer := get_match_count(instance)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_match_count := uart_sb.get_match_count(0);


get_mismatch_count()
==================================================================================================================================
Returns the number of checks without match in scoreboard. If there is no instance parameter, instance 1 is used.

.. code-block::

    integer := get_mismatch_count(VOID)
    integer := get_mismatch_count(instance)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_mismatch_count := uart_sb.get_mismatch_count(0);


get_drop_count()
==================================================================================================================================
Returns the number of dropped items during lossy mode. Initial drop count is not included. If there is no instance parameter, 
instance 1 is used.

.. code-block::

    integer := get_drop_count(VOID)
    integer := get_drop_count(instance)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_drop_count := uart_sb.get_drop_count(0);


get_initial_garbage_count()
==================================================================================================================================
Returns the number of dropped items before first match when ignore_initial_mismatch in config is TRUE. If there is no instance 
parameter, instance 1 is used.

.. code-block::

    integer := get_initial_garbage_count(VOID)
    integer := get_initial_garbage_count(instance)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_initial_garbage_count := uart_sb.get_initial_garbage_count(0);


get_delete_count()
==================================================================================================================================
Returns the number of explicitly deleted items by delete and flush methods. If there is no instance parameter, instance 1 is used.

.. code-block::

    integer := get_delete_count(VOID)
    integer := get_delete_count(instance)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_delete_count := uart_sb.get_delete_count(0);


set_scope()
==================================================================================================================================
Sets the scope of the scoreboard.

.. code-block::

    set_scope(scope)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | scope              | in     | string                       | Describes the scope from which the logs/alerts of the   |
|          |                    |        |                              | scoreboard originate                                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    uart_sb.set_scope("UART_SB");


get_scope()
==================================================================================================================================
Returns the scope of the scoreboard.

.. code-block::

    string := get_scope(VOID)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_scope := uart_sb.get_scope(VOID);


enable_log_msg()
==================================================================================================================================
Enables the message id for the specified instance. If there is no instance parameter, instance 1 is used.

.. code-block::

    enable_log_msg([instance], msg_id)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID used in the log, defined in adaptations_pkg. |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    uart_sb.enable_log_msg(ID_CTRL); 
    uart_sb.enable_log_msg(2, ID_DATA);
    uart_sb.enable_log_msg(ALL_INSTANCES, ID_CTRL);


disable_log_msg()
==================================================================================================================================
Disables the message id for the specified instance. If there is no instance parameter, instance 1 is used.

.. code-block::

    disable_log_msg([instance], msg_id)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | Message ID used in the log, defined in adaptations_pkg. |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    uart_sb.disable_log_msg(ID_CTRL); 
    uart_sb.disable_log_msg(2, ID_DATA);
    uart_sb.disable_log_msg(ALL_INSTANCES, ID_CTRL);


report_counters()
==================================================================================================================================
Prints the scoreboard results. If there is no instance parameter, instance 1 is reported.

.. code-block::

    report_counters(VOID)
    report_counters(instance)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    uart_sb.report_counters(VOID); 
    uart_sb.report_counters(4);
    uart_sb.report_counters(ALL_INSTANCES);


**********************************************************************************************************************************
Advanced methods
**********************************************************************************************************************************
* All parameters in brackets are optional.


insert_expected()
==================================================================================================================================
Inserts an expected element into the scoreboard in the specified position or after the entry specified by the entry number, depending 
on whether the parameter identifier is POSITION or ENTRY_NUM respectively. If there is no instance parameter, instance 1 is used.
This method uses the ID_DATA message ID.

.. code-block::

  insert_expected([instance], identifier_option, identifier, expected_element, [msg, [source]])
  insert_expected([instance], identifier_option, identifier, expected_element, tag_usage, tag, [msg, [source]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | identifier_option  | in     | t_identifier_option          | Option for type of identifier used. Can only be POSITION|
|          |                    |        |                              | or ENTRY_NUM.                                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | identifier         | in     | positive                     | Describes the position or entry number, depending on    |
|          |                    |        |                              | identifier_option                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | expected_element   | in     | t_element                    | The element that shall be pushed to the queue           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | tag_usage          | in     | t_tag_usage                  | Enumerated type used before every tag is entered. Only  |
|          |                    |        |                              | 'TAG' can be used.                                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | tag                | in     | string                       | Tag of the scoreboard element                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | source             | in     | string                       | The element that is the raw-input to the DUT, before    |
|          |                    |        |                              | DUT-processing. For debugging and logging only.         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    uart_sb.insert_expected(POSITION, 5, x"AA");                                           -- Insert element with value x"AA" at position 5
    uart_sb.insert_expected(2, ENTRY_NUM, 23, x"AA", TAG, "byte3", "Insert byte 4", x"A"); -- Insert element with value x"AA", tag "byte3" and source element x"A" after element with entry number 23                                                                                                


delete_expected()
==================================================================================================================================
Deletes the foremost matching entry from the scoreboard queue. When both tag and element parameters are specified, both have to 
match. If identifier parameter is used, the specified entry is deleted. Identifier can be used with range_option set as SINGLE, 
AND_HIGHER and AND_LOWER. A range between identifier_min and identifier_max can also be defined, entries between and including 
these values are deleted. A TB_ERROR alert is reported if identifier is not found. If there is no instance parameter, instance 1 
is used.
This method uses the ID_DATA message ID.

.. code-block::

  delete_expected([instance], expected_element, [msg])                       *NOTE: tag_usage can only be TAG
  delete_expected([instance], expected_element, tag_usage, tag, [msg])
  delete_expected([instance], tag_usage, tag, [msg])
  delete_expected([instance], identifier_option, identifier_min, identifier_max, [msg])
  delete_expected([instance], identifier_option, identifier, range_option, [msg])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | expected_element   | in     | t_element                    | The element that shall be pushed to the queue           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | tag_usage          | in     | t_tag_usage                  | Enumerated type used before every tag is entered. Only  |
|          |                    |        |                              | 'TAG' can be used.                                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | tag                | in     | string                       | Tag of the scoreboard element                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | identifier_option  | in     | t_identifier_option          | Option for type of identifier used. Can only be POSITION|
|          |                    |        |                              | or ENTRY_NUM.                                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | identifier,        | in     | positive                     | Describes the position or entry number, depending on    |
|          |                    |        |                              | identifier_option                                       |
|          | identifier_min,    |        |                              |                                                         |
|          |                    |        |                              |                                                         |
|          | identifier_max     |        |                              |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | range_option       | in     | t_range_option               | Enumerated type used to describe the range. Possible    |
|          |                    |        |                              | options: SINGLE, AND_HIGHER, AND_LOWER.                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    uart_sb.delete_expected(v_received_data); 
    uart_sb.delete_expected(TAG, "byte1");
    uart_sb.delete_expected(1, ENTRY_NUM, v_entry_num, v_entry_num); 
    uart_sb.delete_expected(1, POSITION, v_position, AND_LOWER, "Delete entry in specified position and positions lower");


find_expected_entry_num()
==================================================================================================================================
Returns the entry number of the element and/or tag specified, if nothing is found returns -1. The search parameter can be tag, 
element or both. If there is no instance parameter, instance 1 is used.

.. code-block::

  integer := find_expected_entry_num([instance], expected_element)
  integer := find_expected_entry_num([instance], tag_usage, tag)
  integer := find_expected_entry_num([instance], expected_element, tag_usage, tag)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | expected_element   | in     | t_element                    | The element that shall be pushed to the queue           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | tag_usage          | in     | t_tag_usage                  | Enumerated type used before every tag is entered. Only  |
|          |                    |        |                              | 'TAG' can be used.                                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | tag                | in     | string                       | Tag of the scoreboard element                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_entry_num := uart_sb.find_expected_entry_num(1, x"AA");
    v_entry_num := uart_sb.find_expected_entry_num(1, TAG, "byte1");
    v_entry_num := uart_sb.find_expected_entry_num(x"AA", TAG, "byte1");


find_expected_position()
==================================================================================================================================
Returns the position of the element and/or tag specified, if nothing is found returns -1. The search parameter can be tag, 
element or both. If there is no instance parameter, instance 1 is used.

.. code-block::

  integer := find_expected_position([instance], expected_element)
  integer := find_expected_position([instance], tag_usage, tag)
  integer := find_expected_position([instance], expected_element, tag_usage, tag)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | expected_element   | in     | t_element                    | The element that shall be pushed to the queue           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | tag_usage          | in     | t_tag_usage                  | Enumerated type used before every tag is entered. Only  |
|          |                    |        |                              | 'TAG' can be used.                                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | tag                | in     | string                       | Tag of the scoreboard element                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_position := uart_sb.find_expected_position(1, x"AA");
    v_position := uart_sb.find_expected_position(1, TAG, "byte1");
    v_position := uart_sb.find_expected_position(x"AA", TAG, "byte1");


peek_expected()
==================================================================================================================================
Returns the expected element of the specified entry in the scoreboard without deleting the entry. Returns the front entry 
expected element in the scoreboard queue if no identifier specified. If the identifier is not found, TB_ERROR alert is reported and 
'undefined' is returned. If there is no instance parameter, instance 1 is used.

.. code-block::

  t_element := peek_expected(VOID)
  t_element := peek_expected(instance)
  t_element := peek_expected([instance], identifier_option, identifier)


+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | identifier_option  | in     | t_identifier_option          | Option for type of identifier used. Can only be POSITION|
|          |                    |        |                              | or ENTRY_NUM.                                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | identifier         | in     | positive                     | Describes the position or entry number, depending on    |
|          |                    |        |                              | identifier_option                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_expected_element := uart_sb.peek_expected(VOID);
    v_expected_element := uart_sb.peek_expected(1, POSITION, v_position);
    v_expected_element := uart_sb.peek_expected(1, ENTRY_NUM, v_entry_num);


peek_source()
==================================================================================================================================
Returns the source element of the specified entry in the scoreboard without deleting the entry. Returns the front entry 
source element in the scoreboard queue if no identifier specified. If the identifier is not found, TB_ERROR alert is reported and 
'undefined' is returned. If there is no instance parameter, instance 1 is used.

.. code-block::

  string := peek_source(VOID)
  string := peek_source(instance)
  string := peek_source([instance], identifier_option, identifier)


+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | identifier_option  | in     | t_identifier_option          | Option for type of identifier used. Can only be POSITION|
|          |                    |        |                              | or ENTRY_NUM.                                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | identifier         | in     | positive                     | Describes the position or entry number, depending on    |
|          |                    |        |                              | identifier_option                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_source_element := uart_sb.peek_source(VOID);
    v_source_element := uart_sb.peek_source(1, POSITION, v_position);
    v_source_element := uart_sb.peek_source(1, ENTRY_NUM, v_entry_num);


peek_tag()
==================================================================================================================================
Returns the tag of the specified entry in the scoreboard without deleting the entry. Returns the front entry 
tag in the scoreboard queue if no identifier specified. If the identifier is not found, TB_ERROR alert is reported and 
'undefined' is returned. If there is no instance parameter, instance 1 is used.

.. code-block::

  string := peek_tag(VOID)
  string := peek_tag(instance)
  string := peek_tag([instance], identifier_option, identifier)


+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | identifier_option  | in     | t_identifier_option          | Option for type of identifier used. Can only be POSITION|
|          |                    |        |                              | or ENTRY_NUM.                                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | identifier         | in     | positive                     | Describes the position or entry number, depending on    |
|          |                    |        |                              | identifier_option                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_tag := uart_sb.peek_tag(VOID);
    v_tag := uart_sb.peek_tag(1, POSITION, v_position);
    v_tag := uart_sb.peek_tag(1, ENTRY_NUM, v_entry_num);


fetch_expected()
==================================================================================================================================
Returns the expected element of the specified entry in the scoreboard and deletes the entry. Returns the front entry expected element 
in the scoreboard queue if no identifier specified. If the identifier is not found, TB_ERROR alert is reported and 
'undefined' is returned. This method deletes the entry. If all information from an entry shall be retrieved, peek must be used for 
the first two entry elements. If there is no instance parameter, instance 1 is used.
This method uses the ID_DATA message ID.

.. code-block::

  t_element := fetch_expected(VOID)
  t_element := fetch_expected(instance, [msg])
  t_element := fetch_expected([instance], identifier_option, identifier, [msg])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | identifier_option  | in     | t_identifier_option          | Option for type of identifier used. Can only be POSITION|
|          |                    |        |                              | or ENTRY_NUM.                                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | identifier         | in     | positive                     | Describes the position or entry number, depending on    |
|          |                    |        |                              | identifier_option                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_expected_element := uart_sb.fetch_expected(VOID);
    v_expected_element := uart_sb.fetch_expected(1, POSITION, v_position);
    v_expected_element := uart_sb.fetch_expected(1, ENTRY_NUM, v_entry_num, "Fetch expected");


fetch_source()
==================================================================================================================================
Returns the source element of the specified entry in the scoreboard and deletes the entry. Returns the front entry source element 
in the scoreboard queue if no identifier specified. If the identifier is not found, TB_ERROR alert is reported and 
'undefined' is returned. This method deletes the entry. If all information from an entry shall be retrieved, peek must be used for 
the first two entry elements. If there is no instance parameter, instance 1 is used.
This method uses the ID_DATA message ID.

.. code-block::

  string := fetch_source(VOID)
  string := fetch_source(instance, [msg])
  string := fetch_source([instance], identifier_option, identifier, [msg])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | identifier_option  | in     | t_identifier_option          | Option for type of identifier used. Can only be POSITION|
|          |                    |        |                              | or ENTRY_NUM.                                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | identifier         | in     | positive                     | Describes the position or entry number, depending on    |
|          |                    |        |                              | identifier_option                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_source_element := uart_sb.fetch_source(VOID);
    v_source_element := uart_sb.fetch_source(1, POSITION, v_position);
    v_source_element := uart_sb.fetch_source(1, ENTRY_NUM, v_entry_num, "Fetch source");


fetch_tag()
==================================================================================================================================
Returns the tag of the specified entry in the scoreboard and deletes the entry. Returns the front entry tag
in the scoreboard queue if no identifier specified. If the identifier is not found, TB_ERROR alert is reported and 
'undefined' is returned. This method deletes the entry. If all information from an entry shall be retrieved, peek must be used for 
the first two entry elements. If there is no instance parameter, instance 1 is used.
This method uses the ID_DATA message ID.

.. code-block::

  string := fetch_tag(VOID)
  string := fetch_tag(instance, [msg])
  string := fetch_tag([instance], identifier_option, identifier, [msg])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | identifier_option  | in     | t_identifier_option          | Option for type of identifier used. Can only be POSITION|
|          |                    |        |                              | or ENTRY_NUM.                                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | identifier         | in     | positive                     | Describes the position or entry number, depending on    |
|          |                    |        |                              | identifier_option                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_tag := uart_sb.fetch_tag(VOID);
    v_tag := uart_sb.fetch_tag(1, POSITION, v_position);
    v_tag := uart_sb.fetch_tag(1, ENTRY_NUM, v_entry_num, "Fetch tag");


exists()
==================================================================================================================================
Returns true if the entry is found, false if not. If element and tag parameter is entered, both must match. If there is no instance 
parameter, instance 1 is used.

.. code-block::

  boolean := exists([instance], expected_element, [tag_usage, [tag]])
  boolean := exists([instance], tag_usage, tag)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | instance           | in     | integer                      | The instance number of the scoreboard. The scoreboard   |
|          |                    |        |                              | can have several instances,                             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | each instance acts as an independent scoreboard with    |
|          |                    |        |                              | own queue and statistics.                               |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Can also be ALL_INSTANCES.  Note that instance index 0  |
|          |                    |        |                              | is allowed, but will have to                            |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | be specified in all method calls, and that instance     |
|          |                    |        |                              | index 1 is default.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | expected_element   | in     | t_element                    | The element that shall be pushed to the queue           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | tag_usage          | in     | t_tag_usage                  | Enumerated type used before every tag is entered. Only  |
|          |                    |        |                              | 'TAG' can be used.                                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | tag                | in     | string                       | Tag of the scoreboard element                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    if uart_sb.exists(1, x"AA", TAG, "byte1") then ...
    if uart_sb.exists(1, TAG, "byte1") then ...


**********************************************************************************************************************************
Compilation
**********************************************************************************************************************************
The Generic Scoreboard must be compiled with VHDL-2008 or newer. It is dependent on the following libraries:

    * UVVM Utility Library (UVVM-Util)

Before compiling the Generic Scoreboard, assure that uvvm_util has been compiled.

See :ref:`Essential Mechanisms - Compile Scripts <vvc_framework_compile_scripts>` for information about compile scripts.

.. table:: Compile order for the Generic Scoreboard

    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | Compile to library           | File                                           | Comment                                         |
    +==============================+================================================+=================================================+
    | bitvis_vip_scoreboard        | generic_sb_support_pkg.vhd                     | Config declaration                              |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_scoreboard        | generic_sb_pkg.vhd                             | Generic scoreboard                              |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_scoreboard        | predefined_sb.vhd                              | Predefined packages with SLV and integer        |
    +------------------------------+------------------------------------------------+-------------------------------------------------+

Simulator compatibility and setup
==================================================================================================================================
.. include:: rst_snippets/simulator_compatibility.rst


**********************************************************************************************************************************
Additional Documentation
**********************************************************************************************************************************
A verification scoreboard typically includes some way to store expected outputs generated by e.g. the sequencer or a reference model, 
compare the expected outputs to received outputs, and to keep track of pass and failure rates identified in the comparison process. 
The advantage of using a scoreboard is that the checking/monitor side remains simple and has no need to know what the test/stimulus 
generation side is doing. Figure 1 shows the data-flow through the scoreboard and its main functions.

.. figure:: /images/vip_scoreboard/scoreboard.png
   :alt: Basic scoreboard
   :width: 500pt
   :align: center

   Figure 1 Basic scoreboard

The Scoreboard operates as a queue that holds generic elements. It is implemented as a protected type in a generic package, and a 
package declaration has to be made for each element type. The scoreboard offers advanced functionality for checking received data 
against expected data.

**Out-of-order**: Data can be checked out-of-order by enabling the allow_out_of_order parameter in :ref:`t_sb_config <t_sb_config>`.

**Lossy**: Lossy protocols, where data can be dropped during transfer, is supported by enabling allow_lossy parameter in 
:ref:`t_sb_config` <t_sb_config>. 

Out-of-order and lossy cannot both be enabled at the same time; the scoreboard can't know if something is loss or out-of-order. In 
the case of both out-of-order and lossy, enable out-of-order. The number of remaining entries in the scoreboard at the end of the 
simulation is the number of dropped data elements.


Use-cases
==================================================================================================================================
Scenarios where a scoreboard with out-of-order function is applicable:

* DUT with multiple execution paths:
  Data can take multiple paths inside DUT which affects the execution time. Modulating packet-order may be complex and all that is 
  needed is a check that all data is getting through independent of order.

* Many-to-one interfaces:
  Data from multiple asynchronous interfaces into the DUT is being re-transmitted in one interface out of the DUT.

Scenarios where a scoreboard with lossy function is applicable:

* Interfaces with packet-loss:
  Packet-loss is accepted and handled at a higher abstraction level. E.g. TCP.

* Non-monitored error-injection:
  Error is injected at a level that is not monitored into the DUT and the DUT stops all packets with wrong parity/CRC. Which packets 
  that are lost is unpredictable.

.. note::

    Generic scoreboard was inspired by similar functionality in SystemVerilog and OSVVM.

.. include:: rst_snippets/ip_disclaimer.rst
