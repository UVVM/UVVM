.. _vvc_framework:

##################################################################################################################################
VVC Framework
##################################################################################################################################

**********************************************************************************************************************************
Common VVC Methods
**********************************************************************************************************************************
* All VVC procedures are defined in td_vvc_framework_common_methods_pkg.vhd and ti_vvc_framework_support_pkg.vhd
* All parameters in brackets are optional.

await_completion()
----------------------------------------------------------------------------------------------------------------------------------
Tells the VVC to await the completion of either all pending commands or a specified command index. A message will be logged before 
and at the end of the wait. The procedure will report an alert if not all commands have completed within the specified timeout. 
The severity of this alert will be TB_ERROR. It is also possible to :ref:`broadcast and multicast <vvc_framework_broadcasting>`.

To await the completion of one out of several VVCs in a group use the overload with the vvc_info_list. The vvc_info_list of type 
:ref:`t_vvc_info_list` (protected type) is a local variable that needs to be declared in the sequencer. This overload will block 
the sequencer while waiting, but not the VVCs, so they can continue to receive commands from other sequencers.

.. important::

    * To use the vvc_info_list, the package ``uvvm_vvc_framework.ti_protected_types_pkg.all`` must be included in the testbench.
    * The command with the vvc_info_list requires VVCs supporting the VVC activity register introduced in UVVM release v2020.05.19

.. code-block::

    -- Old method
    await_completion(vvc_target, vvc_instance_idx, [vvc_channel], [wanted_idx], timeout, [msg, [scope]])
    await_completion(VVC_BROADCAST, timeout, [msg, [scope]])

    -- New method
    await_completion(vvc_select, [vvc_info_list], timeout, [list_action, [msg, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | vvc_target         | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC used in this method          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_channel        | in     | t_channel                    | The VVC channel of the VVC instance used in this method |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_select         | in     | :ref:`t_vvc_select`          | Selects whether to await for any of the VVCs in the     |
|          |                    |        |                              | list, all of the VVCs in the list or all the registered |
|          |                    |        |                              | VVCs in the testbench (broadcast)                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_info_list      | in     | :ref:`t_vvc_info_list`       | A list of protected type containing one or several VVC  |
|          |                    |        |                              | IDs (name, instance, channel) & command index. VVC IDs  |
|          |                    |        |                              | and corresponding command index can be added to the list|
|          |                    |        |                              | by using the procedure add() from the                   |
|          |                    |        |                              | :ref:`t_vvc_info_list`                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | The maximum time to await completion of a specified     |
|          |                    |        |                              | command, or all pending commands. An alert of severity  |
|          |                    |        |                              | ERROR will be triggered if the awaited time is equal to |
|          |                    |        |                              | the specified timeout.                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | wanted_idx         | in     | natural                      | The index to be fetched or awaited                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | list_action        | in     | :ref:`t_list_action`         | An enumerated type to either keep the VVC IDs or remove |
|          |                    |        |                              | them from the list after await_completion() has         |
|          |                    |        |                              | finished. Default value is CLEAR_LIST.                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended to the log when the     |
|          |                    |        |                              | method is executed. Default value is "".                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples (old method):
    await_completion(SBI_VVCT, 1, 16 ns, "Wait for SBI instance 1 to finish", C_SCOPE);
    await_completion(SBI_VVCT, 1, v_cmd_idx, 100 ns, "Wait for sbi_read to finish", C_SCOPE);

    -- Multicast:
    await_completion(SBI_VVCT, ALL_INSTANCES, 100 ns, "Wait for all SBI instances to finish", C_SCOPE);
    await_completion(UART_VVCT, 1, ALL_CHANNELS, 100 ns, "Wait for all UART channels from instance 1 to finish", C_SCOPE);

    -- Broadcast:
    await_completion(VVC_BROADCAST, 1 ms, "Wait for all the VVCs to finish", C_SCOPE)

    -- Examples (new method):
    variable my_vvc_info_list : t_vvc_info_list;
    my_vvc_info_list.add("SBI_VVC", 1);
    my_vvc_info_list.add("AXISTREAM_VVC", 3, v_cmd_idx);
    my_vvc_info_list.add("UART_VVC", ALL_INSTANCES, ALL_CHANNELS);
    await_completion(ANY_OF, my_vvc_info_list, 1 ms, KEEP_LIST, "Wait for any VVC in the list to finish", C_SCOPE);

    -- Broadcast:
    await_completion(ALL_VVCS, 1 ms, CLEAR_LIST, "Wait for all the VVCs to finish", C_SCOPE);


await_any_completion()
----------------------------------------------------------------------------------------------------------------------------------
Replaced by ``await_completion(ANY_OF, vvc_info_list, timeout, list_action, msg, scope)`` above to allow VVCs to accept commands 
while waiting for completion. This command still works as previously, but with less functionality than the new 
``await_completion()``. ::

    await_any_completion(vvc_target, vvc_instance_idx, [vvc_channel], [wanted_idx], lastness, [timeout, [msg, [awaiting_completion_idx, [scope]]]])

.. warning::

    This procedure will soon be deprecated and removed. For details and examples for using this call see UVVM release v2020.05.12 
    or any earlier releases.


enable_log_msg()
----------------------------------------------------------------------------------------------------------------------------------
Instructs the VVC to enable a given log ID. This call will be forwarded to the UVVM Utility Library :ref:`util_enable_log_msg` 
function. It is also possible to :ref:`broadcast and multicast <vvc_framework_broadcasting>`. ::

    enable_log_msg(vvc_target, vvc_instance_idx, [vvc_channel], msg_id, [msg, [quietness, [scope]]])
    enable_log_msg(VVC_BROADCAST, msg_id, [msg, [quietness, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | vvc_target         | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC used in this method          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_channel        | in     | t_channel                    | The VVC channel of the VVC instance used in this method |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | The ID to enable/disable with enable/disable_log_msg(). |
|          |                    |        |                              | For more info, see the UVVM-Util documentation.         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | quietness          | in     | :ref:`t_quietness`           | Logging of this procedure can be turned off by setting  |
|          |                    |        |                              | quietness=QUIET. Default value is NON_QUIET.            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended to the log when the     |
|          |                    |        |                              | method is executed. Default value is "".                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    enable_log_msg(SBI_VVCT, 1, ID_LOG_BFM, "Enabling SBI BFM logging");
    enable_log_msg(UART_VVCT, 1, TX, ID_LOG_BFM, "Enabling UART TX BFM logging", NON_QUIET, C_SCOPE);

    -- Broadcast:
    enable_log_msg(VVC_BROADCAST, ID_LOG_BFM, "Enabling BFM logging for all VVCs", NON_QUIET, C_SCOPE);


disable_log_msg()
----------------------------------------------------------------------------------------------------------------------------------
Instructs the VVC to disable a given log ID. This call will be forwarded to the UVVM Utility Library :ref:`util_disable_log_msg` 
function. It is also possible to :ref:`broadcast and multicast <vvc_framework_broadcasting>`. ::

    disable_log_msg(vvc_target, vvc_instance_idx, [vvc_channel], msg_id, [msg, [quietness, [scope]]])
    disable_log_msg(VVC_BROADCAST, msg_id, [msg, [quietness, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | vvc_target         | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC used in this method          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_channel        | in     | t_channel                    | The VVC channel of the VVC instance used in this method |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id             | in     | t_msg_id                     | The ID to enable/disable with enable/disable_log_msg(). |
|          |                    |        |                              | For more info, see the UVVM-Util documentation.         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | quietness          | in     | :ref:`t_quietness`           | Logging of this procedure can be turned off by setting  |
|          |                    |        |                              | quietness=QUIET. Default value is NON_QUIET.            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended to the log when the     |
|          |                    |        |                              | method is executed. Default value is "".                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    disable_log_msg(SBI_VVCT, 1, ID_LOG_BFM, "Disabling SBI BFM logging");
    disable_log_msg(UART_VVCT, 1, TX, ID_LOG_BFM, "Disabling UART TX BFM logging", NON_QUIET, C_SCOPE);

    -- Broadcast:
    disable_log_msg(VVC_BROADCAST, ALL_MESSAGES, "Disables all messages in all VVCs", NON_QUIET, C_SCOPE);


flush_command_queue()
----------------------------------------------------------------------------------------------------------------------------------
Flushes the VVC command queue for the specified VVC target/channel. The procedure will log information with log ID ID_IMMEDIATE_CMD.
It is also possible to :ref:`broadcast and multicast <vvc_framework_broadcasting>`. ::

    flush_command_queue(vvc_target, vvc_instance_idx, [vvc_channel], [msg, [scope]])
    flush_command_queue(VVC_BROADCAST, [msg, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | vvc_target         | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC used in this method          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_channel        | in     | t_channel                    | The VVC channel of the VVC instance used in this method |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended to the log when the     |
|          |                    |        |                              | method is executed. Default value is "".                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    flush_command_queue(SBI_VVCT, 1, "Flushing command queue", C_SCOPE);

    -- Broadcast:
    flush_command_queue(VVC_BROADCAST, "Flushing command queues", C_SCOPE);


fetch_result()
----------------------------------------------------------------------------------------------------------------------------------
Fetches a stored result using the command index. A result is stored when using e.g. the read or receive commands in a VVC. The 
fetched result is available on the *result* output. The Boolean output *fetch_is_accepted* is used to indicate if the fetch was 
successful or not. A fetch can fail if e.g. the wanted_idx did not have a result to store, or the wanted_idx read has not yet been 
executed. Omitting the *fetch_is_accepted* parameter causes the parameters to be checked automatically in the procedure. On 
successful fetch, a message with log ID ID_UVVM_CMD_RESULT is logged. ::

    fetch_result(vvc_target, vvc_instance_idx, [vvc_channel], wanted_idx, result, [fetch_is_accepted], [msg, [alert_level, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | vvc_target         | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC used in this method          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_channel        | in     | t_channel                    | The VVC channel of the VVC instance used in this method |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | wanted_idx         | in     | natural                      | The index to be fetched or awaited                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | result             | out    | t_vvc_result                 | The output where the fetched data is to be placed       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | fetch_is_accepted  | out    | boolean                      | Whether the fetch command was accepted or not. Will be  |
|          |                    |        |                              | false if the specified command idx has not been stored. |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended to the log when the     |
|          |                    |        |                              | method is executed. Default value is "".                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | The alert level used when the command is not accepted.  |
|          |                    |        |                              | Default value is TB_ERROR.                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    fetch_result(SBI_VVCT,1, v_cmd_idx, v_data, v_is_ok, "Fetching read-result", C_SCOPE);

    -- Full example:
    sbi_read(SBI_VVCT, 1, C_ADDR_FIFO_GET, "Read from FIFO");
    v_cmd_idx := get_last_received_cmd_idx(SBI_VVCT,1); -- Retrieve the command index
    await_completion(SBI_VVCT, 1, v_cmd_idx, 100 ns, "Wait for sbi_read to finish");
    fetch_result(SBI_VVCT, 1, v_cmd_idx, v_data, v_is_ok, "Fetching read-result");
    check_value(v_is_ok, ERROR, "Readback OK via fetch_result()");


insert_delay()
----------------------------------------------------------------------------------------------------------------------------------
Inserts a delay of *delay* clock cycles or *delay* seconds in the VVC. It is also possible to 
:ref:`broadcast and multicast <vvc_framework_broadcasting>`. ::

    insert_delay(vvc_target, vvc_instance_idx, [vvc_channel], delay, [msg, [scope]])
    insert_delay(VVC_BROADCAST, delay, [msg, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | vvc_target         | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC used in this method          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_channel        | in     | t_channel                    | The VVC channel of the VVC instance used in this method |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | delay              | in     | time or natural              | Delay to be inserted as time or number of clock cycles  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended to the log when the     |
|          |                    |        |                              | method is executed. Default value is "".                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    insert_delay(SBI_VVCT,1, 50 ns, "50 ns delay", C_SCOPE);
    insert_delay(SBI_VVCT,1, 100, "100T delay", C_SCOPE);

    -- Broadcast:
    insert_delay(VVC_BROADCAST, 50 ns, "Insert 50 ns delay to all VVCs", C_SCOPE);


terminate_current_command()
----------------------------------------------------------------------------------------------------------------------------------
Terminates the current command in the VVC, if the currently running BFM command supports the terminate signal. It is also possible 
to :ref:`broadcast and multicast <vvc_framework_broadcasting>`. ::

    terminate_current_command(vvc_target, vvc_instance_idx, [vvc_channel], [msg, [scope]])
    terminate_current_command(VVC_BROADCAST, [msg, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | vvc_target         | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC used in this method          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_channel        | in     | t_channel                    | The VVC channel of the VVC instance used in this method |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended to the log when the     |
|          |                    |        |                              | method is executed. Default value is "".                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    terminate_current_command(SBI_VVCT, 1, "Terminating current command", C_SCOPE);

    -- Broadcast:
    terminate_current_command(VVC_BROADCAST, "Terminating current command in all VVCs", C_SCOPE);


terminate_all_commands()
----------------------------------------------------------------------------------------------------------------------------------
Terminates the current command in the VVC, if the currently running BFM command supports the terminate signal. The procedure also 
flushes the VVC command queue, removing all pending commands. It is also possible to 
:ref:`broadcast and multicast <vvc_framework_broadcasting>`. ::

    terminate_all_commands(vvc_target, vvc_instance_idx, [vvc_channel], [msg, [scope]])
    terminate_all_commands(VVC_BROADCAST, [msg, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | vvc_target         | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC used in this method          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_channel        | in     | t_channel                    | The VVC channel of the VVC instance used in this method |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended to the log when the     |
|          |                    |        |                              | method is executed. Default value is "".                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    terminate_all_commands(SBI_VVCT, 1, "Terminating all commands", C_SCOPE);

    -- Broadcast:
    terminate_all_commands(VVC_BROADCAST, "Terminating all commands in all VVCs", C_SCOPE);


get_last_received_cmd_idx()
----------------------------------------------------------------------------------------------------------------------------------
Gets the command index of the last command received by the VVC interpreter. Necessary for getting the command index of a read for 
fetch_result. ::

    get_last_received_cmd_idx(vvc_target, vvc_instance_idx, [vvc_channel, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | vvc_target         | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC used in this method          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_channel        | in     | t_channel                    | The VVC channel of the VVC instance used in this method |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    v_cmd_idx := get_last_received_cmd_idx(SBI_VVCT, 1, C_SCOPE);


.. _vvc_framework_broadcasting:

Broadcasting and Multicasting
----------------------------------------------------------------------------------------------------------------------------------
Commands in UVVM can be distributed to all instances of a VVC or to all VVCs using dedicated parameters.

VVC_BROADCAST
^^^^^^^^^^^^^
The VVC_BROADCAST command parameter can be used when a command is to target all VVCs within the test environment, reducing the 
number of command instructions needed in the testbench. ::

    -- Examples:
    enable_log_msg(VVC_BROADCAST, ALL_MESSAGES); -- enable logging for all VVCs
    await_completion(VVC_BROADCAST, 10 us); -- wait for all VVCs to complete


ALL_INSTANCES
^^^^^^^^^^^^^
The ALL_INSTANCES command parameter can be used when a command is targeting all instances of a VVC within the test environment, 
reducing the number of command instructions needed in the testbench. ::

    -- Examples:
    enable_log_msg(SBI_VVCT, ALL_INSTANCES, ALL_MESSAGES); -- enable logging for all instances of SBI_VVCT
    await_completion(SBI_VVCT, ALL_INSTANCES, 100 ns); -- wait for all instances of SBI_VVCT to complete


ALL_CHANNELS
^^^^^^^^^^^^
The ALL_CHANNELS command parameter can be used when a command is targeting all channels of a VVC within the test environment, 
reducing the number of command instructions needed in the testbench. ::

    -- Examples:
    enable_log_msg(UART_VVCT, 1, ALL_CHANNELS, ALL_MESSAGES); -- enable logging for all channels of UART_VVCT instance 1
    await_completion(UART_VVCT, ALL_INSTANCES, ALL_CHANNELS, 100 ns); -- wait for all instances and channels of UART_VVCT to complete


C_VVCT_ALL_INSTANCES
^^^^^^^^^^^^^^^^^^^^
See description above. C_VVCT_ALL_INSTANCES = ALL_INSTANCES.

.. warning::

    This command parameter might be removed in a future release and we encourage the use of ALL_INSTANCES.

.. _vvc_framework_essential_mechanisms:

**********************************************************************************************************************************
Essential Mechanisms
**********************************************************************************************************************************

**********************************************************************************************************************************
VVC Implementation Guide
**********************************************************************************************************************************

.. include:: ip_disclaimer.rst
