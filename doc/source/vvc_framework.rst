.. _vvc_framework:

##################################################################################################################################
VVC Framework
##################################################################################################################################

.. _vvc_framework_methods:

**********************************************************************************************************************************
Common VVC Methods
**********************************************************************************************************************************
* All VVC procedures are defined in td_vvc_framework_common_methods_pkg.vhd and ti_vvc_framework_support_pkg.vhd
* All parameters in brackets are optional.

await_completion()
==================================================================================================================================
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
    ...
    my_vvc_info_list.add("SBI_VVC", 1);
    my_vvc_info_list.add("AXISTREAM_VVC", 3, v_cmd_idx);
    my_vvc_info_list.add("UART_VVC", ALL_INSTANCES, ALL_CHANNELS);
    await_completion(ANY_OF, my_vvc_info_list, 1 ms, KEEP_LIST, "Wait for any VVC in the list to finish", C_SCOPE);

    -- Broadcast:
    await_completion(ALL_VVCS, 1 ms, CLEAR_LIST, "Wait for all the VVCs to finish", C_SCOPE);


await_any_completion()
==================================================================================================================================
Replaced by ``await_completion(ANY_OF, vvc_info_list, timeout, list_action, msg, scope)`` above to allow VVCs to accept commands 
while waiting for completion. This command still works as previously, but with less functionality than the new 
``await_completion()``. ::

    await_any_completion(vvc_target, vvc_instance_idx, [vvc_channel], [wanted_idx], lastness, [timeout, [msg, [awaiting_completion_idx, [scope]]]])

.. warning::

    This procedure will soon be deprecated and removed. For details and examples for using this call see UVVM release v2020.05.12 
    or any earlier releases.


enable_log_msg()
==================================================================================================================================
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
==================================================================================================================================
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
==================================================================================================================================
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
==================================================================================================================================
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
==================================================================================================================================
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
==================================================================================================================================
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
==================================================================================================================================
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
==================================================================================================================================
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
==================================================================================================================================
Commands in UVVM can be distributed to all instances of a VVC or to all VVCs using dedicated parameters.

VVC_BROADCAST
----------------------------------------------------------------------------------------------------------------------------------
The VVC_BROADCAST command parameter can be used when a command is to target all VVCs within the test environment, reducing the 
number of command instructions needed in the testbench. ::

    -- Examples:
    enable_log_msg(VVC_BROADCAST, ALL_MESSAGES); -- enable logging for all VVCs
    await_completion(VVC_BROADCAST, 10 us); -- wait for all VVCs to complete


ALL_INSTANCES
----------------------------------------------------------------------------------------------------------------------------------
The ALL_INSTANCES command parameter can be used when a command is targeting all instances of a VVC within the test environment, 
reducing the number of command instructions needed in the testbench. ::

    -- Examples:
    enable_log_msg(SBI_VVCT, ALL_INSTANCES, ALL_MESSAGES); -- enable logging for all instances of SBI_VVCT
    await_completion(SBI_VVCT, ALL_INSTANCES, 100 ns); -- wait for all instances of SBI_VVCT to complete


ALL_CHANNELS
----------------------------------------------------------------------------------------------------------------------------------
The ALL_CHANNELS command parameter can be used when a command is targeting all channels of a VVC within the test environment, 
reducing the number of command instructions needed in the testbench. ::

    -- Examples:
    enable_log_msg(UART_VVCT, 1, ALL_CHANNELS, ALL_MESSAGES); -- enable logging for all channels of UART_VVCT instance 1
    await_completion(UART_VVCT, ALL_INSTANCES, ALL_CHANNELS, 100 ns); -- wait for all instances and channels of UART_VVCT to complete


C_VVCT_ALL_INSTANCES
----------------------------------------------------------------------------------------------------------------------------------
See description above. C_VVCT_ALL_INSTANCES = ALL_INSTANCES.

.. warning::

    This command parameter might be removed in a future release and we encourage the use of ALL_INSTANCES.

.. _vvc_framework_essential_mechanisms:

**********************************************************************************************************************************
Essential Mechanisms
**********************************************************************************************************************************
This section explains some of the essential mechanisms necessary for running VVC Framework, in addition to helpful and important 
VVC status and configuration records which are accessible directly from the testbench.
More details on the VVC Framework and the command mechanism can be found in the VVC Framework Manual. TODO: link

Libraries
==================================================================================================================================
In order to use a VVC the following libraries need to be included: ::

    library uvvm_util;
    context uvvm_util.uvvm_util_context;

    library uvvm_vvc_framework;
    use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

    library bitvis_vip_<name>;
    context bitvis_vip_<name>.vvc_context;

UVVM Initialization
==================================================================================================================================
The following mechanisms are required for running UVVM VVC Framework:

ti_uvvm_engine
----------------------------------------------------------------------------------------------------------------------------------
This entity contains a process that will initialize the UVVM environment, and has to be instantiated in the testbench harness, or 
alternatively in the top-level testbench. ::

    -- Example:
    i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

await_uvvm_initialization()
----------------------------------------------------------------------------------------------------------------------------------
This procedure is a blocking procedure that has to be called from the testbench sequencer, prior to any VVC calls, to ensure that 
the UVVM engine has been initialized and is ready. This procedure will check the shared_uvvm_state on each delta cycle until the 
UVVM engine has been initialized. Note that this method is depending on the ti_uvvm_engine mechanism. ::

    -- Example:
    await_uvvm_initialization(VOID);

UVVM and VVC User Accessible Shared Variables and Global Signals
==================================================================================================================================
UVVM and VVC shared variables and global signals are defined in global_signals_and_shared_variables_pkg.vhd and the various VVC 
packages.

shared_uvvm_status
----------------------------------------------------------------------------------------------------------------------------------
Shared variable providing access to VVC related information via the info_on_finishing_await_any_completion record element, e.g. ::

    shared_uvvm_status.info_on_finishing_await_any_completion

This record element gives access to the name, command index and the time of completion of the VVC that first fulfilled the
await_any_completion(). The available record fields are: ::

    vvc_name               : string  -- default "no await_any_completion() yet"
    vvc_cmd_idx            : natural -- default 0
    vvc_time_of_completion : time    -- default 0 ns

For more information regarding other fields available in the shared_uvvm_status see :ref:`UVVM Util - Shared Variables
<util_shared_variables>`.

shared_<vvc_name>_vvc_config
----------------------------------------------------------------------------------------------------------------------------------
Shared variable providing access to configuration parameters for each VVC instance and channel if applicable, e.g. ::

    shared_sbi_vvc_config(1).inter_bfm_delay.delay_type := TIME_START2START;
    shared_uart_vvc_config(RX,1).bfm_config.bit_time := C_BIT_TIME;

shared_<vvc_name>_vvc_status
----------------------------------------------------------------------------------------------------------------------------------
Shared variable providing access to status parameters for each VVC instance and channel if applicable, e.g. ::

    v_num_pending_cmds := shared_sbi_vvc_status(1).pending_cmd_cnt;
    v_current_cmd_idx  := shared_uart_vvc_status(TX,2).current_cmd_idx;
    v_previous_cmd_idx := shared_uart_vvc_status(TX,2).previous_cmd_idx;

global_<vvc_name>_vvc_transaction_trigger
----------------------------------------------------------------------------------------------------------------------------------
Global trigger signal for when a VVC has updated its shared variable with VVC transaction info. See 
:ref:`vvc_framework_transaction_info` for more details.

shared_<vvc_name>_vvc_transaction_info
----------------------------------------------------------------------------------------------------------------------------------
Shared variable providing access to Transaction Info VVC instances. See :ref:`vvc_framework_transaction_info` for more details.
Available information is dependent on VVC type and typical information is: ::

    operation          : t_operation;                                            -- default NO_OPERATION
    data               : std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH-1 downto 0); -- default 0x0
    vvc_meta           : t_vvc_meta;                                             -- default C_VVC_META_DEFAFULT
    transaction_status : t_transaction_status;                                   -- default C_TRANSACTION_STATUS_DEFAULT (INACTIVE)

.. note::

    This shared variable is replacing the shared_<vvc_name>_transaction_info, which will soon be deprecated.

VVC Status, Configuration and Transaction Information
==================================================================================================================================
The VVC status, configuration and transaction information records are defined in each individual VVC methods package.

Each VVC instance and channel can be configured and useful information can be accessed from the testbench via dedicated shared 
variables.

From the VVC configuration shared variable, one is given the ability to tailor each VVC to one's needs, in addition to access the 
BFM configuration record via the bfm_config identifier. In addition to BFM configuration possibility, the configuration settings 
consist of command and result queue settings, BFM access separation delay and a VVC dedicated message ID panel. Note that some 
BFMs require user configuration, e.g. the bit_time setting in serial interface BFMs.

The VVC status shared variable provide access to the command status parameters for each of the VVCs, such as the current and 
previous command index, and the number of pending commands in the VVCs command queue. This provide a helpful tool, e.g. when 
synchronizing VVCs in the test sequencer using the await_completion() or await_any_completion() methods.

When using a wave viewer during simulation, the transaction shared variable provides helpful information regarding current VVC 
operation and transaction information such as address and data. Note that the accessible fields depend on the VVC and its 
implementation. An example of two SBI VVCs performing FIFO write operations, followed by check operations, is shown in Figure 1.

.. figure:: /images/vvc_framework/transaction_info_wave_view.png
   :alt: VVC transaction info waveview
   :width: 800pt
   :align: center

   Figure 1 VVC Transaction info example

.. _vvc_framework_activity_watchdog:

Activity Watchdog
==================================================================================================================================
UVVM VVC Framework has an activity watchdog mechanism which all Bitvis VVCs support. All VVCs can be automatically registered in a 
centralized VVC activity register at start-up and will, during simulation, update the VVC activity register with their current 
activity status, i.e. ACTIVE or INACTIVE, which again is monitored by the activity watchdog. A timeout counter in the activity 
watchdog will start after the last update has occurred in the VVC activity register, and the timeout counter is reset on any VVC 
activity. An alert will be raised if none of the VVCs have an activity prior to the timeout counter reaching the specified timeout 
value. Note that the activity watchdog will continue to monitor VVC activity, even after a timeout, until alert stop limit is 
reached.

The activity watchdog has to be included as a concurrent procedure parallel to the testbench sequencer or in the test harness in 
order to be activated. Note that the activity watchdog will raise a TB_WARNING if the number of expected VVCs does not match the 
number of registered VVCs in the VVC activity register, and that leaf VVCs (e.g. channels such as UART RX and TX) are counted 
individually. This checking can be disabled by setting the number of expected VVCs to 0. Also note that the total number of VVCs 
registered in the VVC activity register cannot exceed the C_MAX_TB_VVC_NUM count, default set to 20 in the adaptations_pkg.vhd, 
and this will result in a TB_ERROR raised by the VVC activity register.

Note that some VVCs should not be monitored by the activity watchdog. This currently applies to the clock generator VVC, as this 
VVC may continue to be active even after all other testbench activity has stopped. This VVC will have to be included in the number 
of expected VVCs registered in the VVC activity register but will not have any effect on the activity watchdog timeout counter.

+------------------+------------------------+-----------------+-------------------------------------------------------------------+
| Name             | Type                   | Default         | Description                                                       |
+==================+========================+=================+===================================================================+
| num_exp_vvc      | natural                | <none>          | | Expected number of VVCs which is expected to be registered in   |
|                  |                        |                 |   the VVC activity register (including any clock generator VVC).  |
|                  |                        |                 | | Note 1: each channel is counted as an independent VVC expected  |
|                  |                        |                 |   to be registered in the VVC activity register.                  |
|                  |                        |                 | | Note 2: setting num_exp_vvc = 0 will disable checking of number |
|                  |                        |                 |   of expected VVCs vs actual number of VVCs registered in the VVC |
|                  |                        |                 |   activity register.                                              |
+------------------+------------------------+-----------------+-------------------------------------------------------------------+
| timeout          | time                   | <none>          | Timeout value after last VVC activity.                            |
+------------------+------------------------+-----------------+-------------------------------------------------------------------+
| alert_level      | :ref:`t_alert_level`   | TB_ERROR        | The timeout will have this alert level.                           |
+------------------+------------------------+-----------------+-------------------------------------------------------------------+
| msg              | string                 | \"Activity Watc\| Message included with activity watchdog log messages, e.g. name   |
|                  |                        | hdog\"          | of activity watchdog.                                             |
+------------------+------------------------+-----------------+-------------------------------------------------------------------+

.. code-block::

    -- Example:
    p_activity_watchdog:
        activity_watchdog(num_exp_vvc => 3, timeout => C_ACTIVITY_WATCHDOG_TIMEOUT);

.. _vvc_framework_transaction_info:

Distribution of Transaction Info - From VVCs and/or Monitors
==================================================================================================================================
UVVM supports sharing transaction information in a controlled manner within the complete testbench environment. This allows VVCs 
and Monitors to provide transaction info to any other part of your testbench – using a predefined structured mechanism. This makes 
it even easier to make good VHDL testbenches.

Transaction information may be used in many different ways, but the main purpose is to share information inside the testbench of 
activity or accesses on a given DUT interface. Such information could typically be provided from a dedicated interface Monitor, 
but making such a dedicated Monitor is sometimes quite time consuming and often not really needed. For that reason, UVVM provides 
a mechanism for getting the transaction information directly from the VVC.

.. _vvc_framework_transaction_info_purpose:

Purpose
----------------------------------------------------------------------------------------------------------------------------------
By enabling the distribution of transaction info, models or any other parts of the testbench can see exactly what accesses have 
been made on the various interfaces of the DUT, so that the expected DUT behaviour and outputs may be checked. Let us illustrate 
this with a really simple testbench scenario to verify a UART peripheral with an AXI-lite register/CPU interface on one side and 
the UART RX and TX ports on the other side. The test sequencer may command the AXI-lite BFM or VVC to write a data byte into the 
UART TX register, and then it must be checked that the data byte is transmitted out on the DUT TX output some time later.

    a. A simple testbench approach could be to have the test sequencer also telling the receiving UART BFM or VVC exactly what to 
       expect. This is a straightforward approach, but requires more action and data control inside the test sequencer. This could 
       of course all be handled in a super-procedure, but for any undetermined behaviour inside the BFM or VVC, like random data 
       generation or error injection, that would not work. See Figure 2.
    b. A more advanced approach is to have a model overlooking the DUT accesses, generate the expected data and tell the receiving 
       BFM or VVC to check for that data. See Figure 3.
    c. An even more advanced approach would be to use a Scoreboard to check received data (from DUT via VVC) against expected data 
       from a model. See Figure 4.

However, for the two latter approaches the model needs information about exactly what happened (the transaction) on the various 
DUT interfaces, so that it can generate the correct expected data. For the model it doesn’t matter if the transaction info comes 
from a Monitor or from a VVC, as long as the information is correct.

The model could of course look at the interfaces and analyse the actual transactions, but distributing this task to the VVC or 
Monitor makes the testbench far more structured and significantly improves overview, maintenance, extensibility and reuse – at 
least for anything above medium simple verification challenges.

Another purpose of providing transaction information is for progress viewing and debugging – typically via the wave view or 
simulation transcripts.

.. list-table:: 

    * - .. figure:: /images/vvc_framework/direct_transaction_transfer_example_A.png
           :alt: Direct transaction transfer A
           :align: center

           Figure 2 Distribution of Transaction Info Approach A

      - .. figure:: /images/vvc_framework/direct_transaction_transfer_example_B.png
           :alt: Direct transaction transfer B
           :align: center

           Figure 3 Distribution of Transaction Info Approach B

      - .. figure:: /images/vvc_framework/direct_transaction_transfer_example_C.png
           :alt: Direct transaction transfer C
           :align: center

           Figure 4 Distribution of Transaction Info Approach C

.. _vvc_framework_transaction_info_definitions:

Transaction definitions
----------------------------------------------------------------------------------------------------------------------------------
By transactions we normally talk about a complete end to end transfer of data across an interface. This could be anything from a 
simple write, read or transfer of a single word - to a complete packet in a packet-oriented protocol like Ethernet. The word 
transaction is however also used for both sub-sets and super-sets of this – depending on the protocol and even on how we want to 
control our system or testbench. In order to communicate properly and to assure that transactions are properly understood, the 
following terms are defined:

    * **Base transaction (BT)** is the lowest level of a complete transaction as allowed from the central sequencer. E.g. 
      AXI-lite, UART, Ethernet and AXI-Stream transactions.
    * **Sub-transaction (ST)** is the lowest level of an incomplete transaction as allowed from a BFM. The sub-transaction as such 
      is complete seen from a handshake point of view, but the transfer of data is not complete. A split transaction protocol will 
      typically have sub-transactions. E.g. Avalon Read Request and Avalon Read Response.
    * **Leaf transaction (LT)** is not a transaction type in itself, but is the lowest level of complete or incomplete transaction 
      defined for a given protocol. I.e. a sub-transaction when this is defined for a given protocol, otherwise a base transaction. 
      This definition is needed in order simplify various explanations. E.g. for Avalon: LT = the sub transactions, and for UART, 
      SBI or Ethernet: LT = the base transactions (as no sub-transaction exist for these protocols)
    * **Compound transaction (CT)** is a set of transactions or other methods or statements that as a total is doing a more 
      complex operation. A compound transaction involves calling multiple base transactions. E.g. sbi_poll_until() or a UART 
      transmit of N consecutive bytes. No compound transaction needs to be defined.

Transaction information
----------------------------------------------------------------------------------------------------------------------------------
Information about the above transactions is typically provided to a model in the test harness. Depending on whether the 
transaction info is provided from the VVC or Monitor, different types of information will be available. Common for both is that 
they always provide info about the operation (read, write, transmit, etc.) and often also any other protocol specific info. For a 
UART this could be data and parity, for an SBI it could be address and data, and for Ethernet, the packet fields.

This minimum is normally what the Monitor can provide from just analysing the interface, and this is also normally enough for a 
model to generate expected DUT outputs. The VVC on the other hand, can provide more info, which could be useful for instance for 
progress viewing and debugging.

The transaction information is organised as a transaction record with some predefined fields as shown below. Table 1 shows the 
general transaction record, whereas table 2 shows a concrete example for the SBI.

Note that for a given interface/protocol, the VVC and the Monitor will use the same interface dedicated transaction record type - 
with some fields potentially unused.

.. table:: Table 1 - General transaction record t_transaction. The fields in bold indicate optional or protocol dedicated fields

    +-------------------------+------------------------------+--------------------------------------------------------------------+
    | Field                   | Type                         | Description                                                        |
    +=========================+==============================+====================================================================+
    | operation               | t_operation                  | | Protocol operation on the given DUT interface. E.g. NO_OPERATION,|
    |                         |                              |   WRITE, READ, TRANSMIT, POLL_UNTIL, ...                           |
    |                         |                              | | NO_OPERATION is default and thus used when there is no access.   |
    |                         |                              | | All operations will be separated with a NO_OPERATION for at least|
    |                         |                              |   1 delta cycle, e.g. NO_OPERATION - WRITE - NO_OPERATION - READ - |
    |                         |                              |   NO_OPERATION.                                                    |
    +-------------------------+------------------------------+--------------------------------------------------------------------+
    | | **<optional protocol**| **<protocol dedicated>**     | | One or more fields required to complete the transaction info.    |
    | | **dedicated           |                              | | E.g. for UART: single field 'data'; for SBI: field 1: 'addr',    |
    |   field(s)>**           |                              |   field 2: 'data'; for Ethernet: most Ethernet fields as separate  |
    |                         |                              |   fields, or a better solution, include as a complete sub-record.  |
    +-------------------------+------------------------------+--------------------------------------------------------------------+
    | transaction_status      | t_transaction_status         | | Handled slightly different from a VVC and a Monitor.             |
    |                         |                              | | VVC: Will show 'IN_PROGRESS' during the transaction and INACTIVE |
    |                         |                              |   in between (for at least one delta cycle).                       |
    |                         |                              | | Monitor: Will show FAILED or SUCCEEDED immediately as soon as    |
    |                         |                              |   this is 100% certain - and keep this info for the display period |
    |                         |                              |   defined in the Monitor configuration record, or until the start  |
    |                         |                              |   of the next transaction,                                         |
    |                         |                              | | whichever occurs first. Other than that, it will show IN_PROGRESS|
    |                         |                              |   when active or INACTIVE when not.                                |
    +-------------------------+------------------------------+--------------------------------------------------------------------+
    | vvc_meta                | t_vvc_meta                   | Additional transaction information - only known by the VVC. So far |
    |                         |                              | 'msg' and 'cmd_idx' (the free running command index). A Monitor has|
    |                         |                              | no knowledge of this and will set them to msg = "", cmd_idx = -1   |
    +-------------------------+------------------------------+--------------------------------------------------------------------+
    | **error_info**          | **t_error_info**             | Any type of error injection relevant for the given protocol.       |
    |                         |                              | Typically parity or stop-bit error in an UART or a CRC error in an |
    |                         |                              | Ethernet. If no error injection or detection has been implemented, |
    |                         |                              | this sub-record may be left out.                                   |
    +-------------------------+------------------------------+--------------------------------------------------------------------+
    | | *Note: For transaction info from a VVC, the record reflects the command status, i.e. the status assumed by the VVC when   |
    |   initiating the command, whereas the Monitor will set up the record only after knowing whether the transaction has failed  |
    |   or succeeded.*                                                                                                            |
    | | *The VVC does not know the BFM status, and this is fine because the BFM will issue an alert for unexpected behaviour.*    |
    +-------------------------+------------------------------+--------------------------------------------------------------------+

.. table:: Table 2 - SBI specific transaction record t_transaction. The fields in bold indicate protocol dedicated fields

    +-------------------------+------------------------------+--------------------------------------------------------------------+
    | Field                   | Type                         | Description                                                        |
    +=========================+==============================+====================================================================+
    | operation               | t_operation                  | Either of WRITE, READ or CHECK, but could also be POLL_UNTIL or a  |
    |                         |                              | more complex compound transaction                                  |
    +-------------------------+------------------------------+--------------------------------------------------------------------+
    | **address**             | **unsigned**                 |                                                                    |
    +-------------------------+------------------------------+--------------------------------------------------------------------+
    | **data**                | **std_logic_vector**         |                                                                    |
    +-------------------------+------------------------------+--------------------------------------------------------------------+
    | transaction_status      | t_transaction_status         |                                                                    |
    +-------------------------+------------------------------+--------------------------------------------------------------------+
    | vvc_meta                | t_vvc_meta                   |                                                                    |
    +-------------------------+------------------------------+--------------------------------------------------------------------+
    | *Note: No error_info field as no error injection or detection has been implemented in neither VVC nor Monitor - at this     |
    | stage.*                                                                                                                     |
    +-------------------------+------------------------------+--------------------------------------------------------------------+

Other interfaces will of course have different protocol dedicated fields, or even a complete protocol dedicated sub-record (e.g. 
for Ethernet packet fields).

Transaction Info transfer
----------------------------------------------------------------------------------------------------------------------------------
In order to reduce the number of signals from a VVC or Monitor, all possible simultaneous transactions (and their transaction 
records) are collected into a single transaction group record. For an SBI interface, this will consist of a BT record and 
potentially a CT record. Whereas for an Avalon, it will in addition also consist of two ST records, because for instance a read 
request may be active at the same time as a read response. (And the sub-transactions are part of a base transaction and may also 
be part of a CT).

Table 3 shows the maximum transaction group record for an SBI, whereas Table 4 shows the maximum transaction group record for an 
Avalon. The bold CT is optional for both, and thus depends on whether CTs have been defined in the VVC. Multiple parallel STs may 
be written to the transaction group record simultaneously - as these are handled by different "threads" (concurrent statements 
like a process).

A Monitor cannot know about CTs, and thus a Monitor will never fill in that sub-record. A Monitor for a split transaction protocol 
(i.e. with multiple STs) may or may not provide BT info. If it does, this should normally be implemented in a higher level 
"wrapper".

.. note::

    * A VVC will update its Transaction Info leaf transaction details at the start of the transaction when the BFM is called. and 
      turned off when BFM is finished.
    * A Monitor will set its Transaction Info record after the transaction is finished (or transaction status is known) and keep 
      it on for a pre-defined time - or until the next transaction is finished if earlier.

.. hint::

    It is recommended that the model (or any other user of Transaction Info) triggers on the VVC/Monitor trigger signal and checks 
    when transaction_status is changing to 'INACTIVE' and then sample <signal>'last_value.

.. table:: Table 3 - Maximum transaction group record t_transaction_group - for an SBI interface

    +-------------------------+------------------------------+--------------------------------------------------------------------+
    | Field                   | Type                         | Description                                                        |
    +=========================+==============================+====================================================================+
    | bt                      | t_transaction                | Base transaction                                                   |
    +-------------------------+------------------------------+--------------------------------------------------------------------+
    | **ct**                  | **t_transaction**            | Compound transaction                                               |
    +-------------------------+------------------------------+--------------------------------------------------------------------+

.. table:: Table 4 - Maximum transaction group record t_transaction_group - for an Avalon MM interface

    +-------------------------+------------------------------+--------------------------------------------------------------------+
    | Field                   | Type                         | Description                                                        |
    +=========================+==============================+====================================================================+
    | st_request              | t_transaction                | Sub-transaction                                                    |
    +-------------------------+------------------------------+--------------------------------------------------------------------+
    | st_response             | t_transaction                | Sub-transaction                                                    |
    +-------------------------+------------------------------+--------------------------------------------------------------------+
    | bt                      | t_transaction                | Base transaction                                                   |
    +-------------------------+------------------------------+--------------------------------------------------------------------+
    | **ct**                  | **t_transaction**            | Compound transaction                                               |
    +-------------------------+------------------------------+--------------------------------------------------------------------+

.. _vvc_framework_transaction_info_record:

Transaction Info record signals
----------------------------------------------------------------------------------------------------------------------------------
The Transaction Info record is provided out of the VVC and Monitor using sets of a global signal and a shared variable. These and 
all Transaction Info related VHDL types are defined in transaction_pkg.vhd, located in the VIP src folder.

    * **Monitor trigger signal** : *global_<protocol-name>_monitor_transaction_trigger*, e.g. global_uart_monitor_transaction_trigger
    * **Monitor shared variable** : *shared_<protocol-name>_monitor_transaction_info*, e.g. shared_uart_monitor_transaction_info
    * **VVC trigger signal**: *global_<protocol-name>_vvc_transaction_trigger*, e.g. global_uart_vvc_transaction_trigger.
    * **VVC shared variable** : *shared_<protocol-name>_vvc_transaction_info*, e.g, shared_uart_vvc_transaction_info. The VVC is also 
      responsible for filling out the vvc_meta record field.

.. table:: Table 5 - Transaction Info record **t_<if>_transaction_group** for an UART interface - accessible via 
           **shared_uart_vvc_transaction_info(vvc_idx)** t_uart_transaction_group_array

    +------------------+------------------------+-----------------+---------------------------------------------------------------+
    | Name             | Type                   | Default         | Description                                                   |
    +==================+========================+=================+===============================================================+
    | bt               | t_transaction          | C_TRANSACTION_S\| Transaction Info record entry for base transaction            |
    |                  |                        | ET_DEFAULT      |                                                               |
    +------------------+------------------------+-----------------+---------------------------------------------------------------+
    | -> operation     | t_operation            | NO_OPERATION    | Equal to VVC transaction operation, e.g. TRANSMIT, RECEIVE and|
    |                  |                        |                 | EXPECT (UART)                                                 |
    +------------------+------------------------+-----------------+---------------------------------------------------------------+
    | -> address [#f1]_| unsigned               | 0x0             | DUT access read or write address                              |
    +------------------+------------------------+-----------------+---------------------------------------------------------------+
    | -> data          | std_logic_vector       | 0x0             | DUT read or write data                                        |
    +------------------+------------------------+-----------------+---------------------------------------------------------------+
    | -> vvc_meta      | t_vvc_meta             | C_VVC_META_DEFA\| Record of meta data belonging to VVC command request resulting|
    |                  |                        | ULT             | in this base transaction                                      |
    +------------------+------------------------+-----------------+---------------------------------------------------------------+
    | ---> msg         | string                 | ""              | Message transmitted with VVC command resulting in this base   |
    |                  |                        |                 | transaction                                                   |
    +------------------+------------------------+-----------------+---------------------------------------------------------------+
    | ---> cmd_idx     | integer                | -1              | VVC command index resulting in this base transaction          |
    +------------------+------------------------+-----------------+---------------------------------------------------------------+
    | -> transaction_s\| t_transaction_status   | C_TRANSACTION_S\| The current status of transaction. Available statuses are     |
    | tatus            |                        | TATUS_DEFAULT   | INACTIVE, IN_PROGRESS, FAILED and SUCCEEDED [#f2]_            |
    +------------------+------------------------+-----------------+---------------------------------------------------------------+
    | -> error_info    | t_error_info           | C_ERRO_INFO_DEF\| Record entry of errors that will be injected to the DUT access|
    | [#f3]_           |                        | AULT            | transaction                                                   |
    +------------------+------------------------+-----------------+---------------------------------------------------------------+
    | ---> parity_bit\ | boolean                | False           | The DUT transaction will have a parity bit error if entry is  |
    | _error [#f4]_    |                        |                 | set to true                                                   |
    +------------------+------------------------+-----------------+---------------------------------------------------------------+
    | ---> stop_bir_er\| boolean                | False           | The DUT transaction will have a stop bit error if entry is set|
    | ror [#f4]_       |                        |                 | to true                                                       |
    +------------------+------------------------+-----------------+---------------------------------------------------------------+
    | ct [#f5]_        | t_transaction          | C_TRANSACTION_S\| | Transaction Info record entry for compound transaction      |
    |                  |                        | ET_DEFAULT      | | Note that sub-record entries would typically have the same  |
    |                  |                        |                 |   entries as for a base transaction, and that this entry does |
    |                  |                        |                 |   not have to be suited for all interface Transaction Info    |
    |                  |                        |                 |   records.                                                    |
    +------------------+------------------------+-----------------+---------------------------------------------------------------+

.. note::

    .. [#f1] Record field **address** is not applicable for all interface types, e.g. UART, and is only shown here for 
       informational purposes.
    .. [#f2] Transaction status **FAILED** and **SUCCEEDED** are not applicable for VVC Transaction Info records, but will be used 
       for Monitor Transaction Info records.
    .. [#f3] Record field **error_info** and its sub-record fields can be omitted if no error injection is implemented in the BFM.
    .. [#f4] **error_info** sub-record fields **parity_bit_error** and **stop_bit_error** are examples of UART error injection.
    .. [#f5] Record entry **ct** will consist of similar record fields as **bt**, and might not always be necessary. This applies 
       to record entry **st** as well (not shown here).

Transaction Info signal and shared variable
----------------------------------------------------------------------------------------------------------------------------------
A VVC or Monitor will trigger the global trigger signals listed in :ref:`vvc_framework_transaction_info_record` when information 
of a new transaction info is made available. For a VVC, the transaction info is made available prior to the corresponding bus 
access, i.e. before calling the BFM method, and the global trigger signal will be pulsed for a delta cycle. The VVC will set the 
transaction info back to default values immediately after the bus access has finished, but then without pulsing the global trigger 
signal.

For a Monitor, the transaction info will be made available immediately after a bus access is completed and then the global trigger 
signal will be pulsed for a delta cycle. The transaction info is valid when the global trigger signal is pulsed and is set back to 
default values after a period of transaction_display_time, set in the Monitor configuration record, or when a new transaction is 
started.

Examples of Transaction Info Usage
----------------------------------------------------------------------------------------------------------------------------------
All important information regarding a transfer is available in the transaction info and accessible in the test environment, and 
depending on one's needs there are some recommended approaches for how to utilize the transaction info:

    #. For complex protocols, where several combinations of data widths and others are possible, it can be complicated for a VVC 
       to determine the structure and constraints of the scoreboard element. Examples of VVCs with such complex protocols are the 
       AXI Stream and the Avalon ST VVCs. Setting up the Scoreboard and checking of received data against expected data for such 
       complex protocols has to be done in the test harness, where the generic scoreboard is instantiated with a constrained 
       scoreboard element and where a dedicated process monitors the VVC transaction info and checks received data with the 
       scoreboard.
    #. Transaction info can be used in a DUT Model process that monitors and decodes the actual transaction info data in the test 
       harness. The DUT Model will use the decoded transaction info and add expected data to the VVC scoreboard on the DUT 
       receiving side, e.g. to the SBI_VVC_SB while a SBI VVC is responsible for performing the DUT read access and check received 
       data with SBI_VVC_SB. See :ref:`Transaction Info Purpose <vvc_framework_transaction_info_purpose>`, example C, for how a 
       DUT Model will appear in the test harness.

.. _vvc_framework_transaction_info_mechanism:

Mechanism
^^^^^^^^^
The technique of using transaction info in the test environment, either in a VVC scoreboard support process or in a DUT Model, 
involves the following 3 steps:

    #. Wait for the interface trigger signal to be set.
    #. Decode the base transaction info operation.
    #. Execute wanted operation from the obtained transaction info.

A simple VVC Scoreboard Support process is presented in Figure 5, demonstrating how VVC scoreboard actions can be accomplished 
using transaction info and a stand-alone process when not performed by a VVC. The same approach is shown in Figure 6 with a simple 
DUT Model process, demonstrating how DUT modelling can be accomplished using transaction info and a stand-alone process. Note that 
Figure 5 uses aliasing to simplify and improve code readability, while Figure 6 uses full transaction info names.

.. code-block::
    :caption: Figure 5 VVC Scoreboard Support – with aliasing

    p_vvc_sb_support : process
      -- transaction info handles
      alias sbi_transaction_trigger     : std_logic is global_sbi_vvc_transaction_trigger(C_SBI_VVC_1);
      alias sbi_transaction_info        : bitvis_vip_sbi.transaction_pkg.t_base_transaction is shared_sbi_vvc_transaction_info(C_SBI_VVC_1).bt;
      alias uart_rx_transaction_trigger : std_logic is global_uart_vvc_transaction_trigger(RX, C_UART_VVC_1);
      alias uart_rx_info                : bitvis_vip_uart.transaction_pkg.t_base_transaction is shared_uart_vvc_transaction_info(RX, C_UART_VVC_1).bt;
      -- helper variable
      variable v_sb_element             : std_logic_vector(C_DATA_WIDTH-1 downto 0);
    begin
      while true loop:

        -- Wait for available transaction info
        wait until (sbi_transaction_trigger = '1') or (uart_rx_transaction_trigger = '1');

        if sbi_transaction_trigger'event then
          case sbi_transaction_info.operation is
            when READ =>
              v_sb_element := sbi_transaction_info.data(C_DATA_WIDTH-1 downto 0);
              SBI_VVC_SB.check_received(C_SBI_VVC_1, v_sb_element);
          end case;
        end if;

        if uart_rx_transaction_trigger'event then
          case uart_rx_info.operation is
            when RECEIVE =>
              v_sb_element := uart_rx_info.data(C_DATA_WIDTH-1 downto 0);
              UART_VVC_SB.check_received(C_UART_VVC_1, v_sb_element);
          end case;
        end if;

      end loop;
    end process p_vvc_sb_support;

Figure 5 demonstrates the setup of a VVC Scoreboard Support process that operates with the 3 steps listed in 
:ref:`Transaction Info Mechanism <vvc_framework_transaction_info_mechanism>`. For simple scoreboard elements, such as std_logic_vector, 
these scoreboard approaches are already performed by the VVCs.

.. code-block::
    :caption: Figure 6 DUT Model – no aliasing

    p_dut_model : process
    begin
      while true loop:

        -- Wait for available transaction info
        wait until (global_sbi_vvc_transaction_trigger(C_SBI_VVC_1) = '1') or (global_uart_vvc_transaction_trigger(TX, C_UART_VVC_1) = '1');

        if global_sbi_vvc_transaction_trigger(C_SBI_VVC_1)'event then
          case shared_sbi_vvc_transaction_info(C_SBI_VVC_1).bt.operation is
            when WRITE =>
              UART_VVC_SB.add_expected(shared_sbi_vvc_transaction_info(C_SBI_VVC_1).bt.data(C_DATA_WIDTH-1 downto 0));
          end case;
        end if;

        if global_uart_vvc_transaction_trigger(TX, C_UART_VVC_1)'event then
          case shared_uart_vvc_transaction_info(TX, C_UART_VVC_1).bt.operation is
            when TRANSMIT =>
              SBI_VVC_SB.add_expected(shared_uart_vvc_transaction(TX, C_UART_VVC_1).bt.data(C_DATA_WIDTH-1 downto 0));
          end case;
        end if;

      end loop;
    end process p_dut_model;

Figure 6 demonstrates the setup of a DUT Model process that operates with the 3 steps listed in 
:ref:`Transaction Info Mechanism <vvc_framework_transaction_info_mechanism>`. For simple scoreboard elements, such as std_logic_vector, 
these scoreboard approaches are already performed by the VVCs.

Complex Protocols
^^^^^^^^^^^^^^^^^
For scoreboards with complex protocols, e.g. AXI Stream and Avalon ST, the same approach as listed in 
:ref:`Transaction Info Mechanism <vvc_framework_transaction_info_mechanism>` applies. The only difference is that the scoreboard 
element is of a more complex type, i.e. a record element. Figure 7 demonstrates a VVC scoreboard support approach using a complex 
record element.

.. code-block::
    :caption: Figure 7 VVC Scoreboard Support – complex scoreboard element

    -- define complex Avalon ST scoreboard type
    type t_avalon_st_element is record
      channel_value : std_logic_vector(C_CH_WIDTH-1 downto 0);
      data_array    : t_slv_array(0 to C_ARRAY_LENGTH-1)(C_WORD_WIDTH-1 downto 0);
    end record t_avalon_st_element;

    -- create to_string() function for t_avalon_st_element
    function avalon_st_element_to_string(
      constant rec_element : t_avalon_st_element
    ) return string is
    begin
      return "channel value: " & to_string(rec_element.channel_value) & ", data: " & to_string(rec_element.data_array);
    end function avalon_st_element_to_string;

    -- define Avalon ST scoreboard
    package avalon_st_sb_pkg is new bitvis_vip_scoreboard.generic_sb_package
    generic map(t_element         => t_avalon_st_element,
                element_match     => "=",
                to_string_element => avalon_st_element_to_string);
    use avalon_st_sb_pkg.all;

    shared variable AVALON_ST_VVC_SB : avalon_st_sb_pkg.t_generic_sb;
    ...
    p_vvc_sb_support : process
      -- transaction info handles
      alias avalon_st_transaction_trigger : std_logic is global_avalon_st_vvc_transaction_trigger(C_AVALON_ST_VVC_1);
      alias avalon_st_transaction_info    : bitvis_vip_avalon_st.transaction_pkg.t_base_transaction is
                                            shared_avalon_st_vvc_transaction_info(C_AVALON_ST_VVC_1).bt;
      -- helper variable
      variable v_sb_element : t_avalon_st_element;
    begin
      while true loop:

        -- Wait for available transaction info
        wait until avalon_st_transaction_trigger = '1';

        if avalon_st_transaction_trigger'event then
          case avalon_st_transaction_info.operation is
            when RECEIVE =>
              v_sb_element.channel_value := avalon_st_transaction_info.channel_value(C_CH_WIDTH-1 downto 0);
              v_sb_element.data_array    := avalon_st_transaction_info.data_array(0 to C_ARRAY_LENGTH-1)(C_WORD_WIDTH-1 downto 0);
              AVALON_ST_VVC_SB.check_received(C_AVALON_ST_VVC_1, v_sb_element);
          end case;
        end if;

      end loop;
    end process p_vvc_sb_support;

Figure 7 demonstrates the setup of a VVC Scoreboard Support process that operates with the 3 steps listed in 
:ref:`Transaction Info Mechanism <vvc_framework_transaction_info_mechanism>`. For complex scoreboard elements, such as records, the 
scoreboard package declaration, defining the shared variable and scoreboard approaches have to be performed outside the VVC.

VVC Local Sequencers
==================================================================================================================================
UVVM testbenches may have one or more central sequencers – also known as test sequencers or test drivers. A single test sequencer 
is recommended in order to reduce complexity – as synchronization between multiple parallel test sequencer could be really complex.
UVVM does however also provide support for so called local sequencers. These sequencers will typically run inside the VVCs 
executor process. The executor will typically run a single transaction via a BFM procedure towards the DUT interface, like an 
sbi_write() or uart_expect() procedure. For more advanced VVCs it would however make sense to send even higher level commands to a 
VVC, like requesting it to transmit N random bytes, or setting up a peripheral by writing to multiple configuration registers. In 
these cases, a single command to the VVC will trigger a complete sequence of accesses towards the DUT. The code inside the VVC 
executors handling these sequences are called local sequencers as they are local to the VVC and thus also improves re-use. These 
sequences of transactions may also be defined as Compound Transactions (see :ref:`vvc_framework_transaction_info_definitions`).

An example of a local sequencer is the randomisation sequences in the UART VVC, and poll_until in the SBI VVC.

Local sequencer requirements
----------------------------------------------------------------------------------------------------------------------------------
The following requirements should be followed when making local sequencers (basically any VVC command resulting in more than one 
base transaction):

    #. If Transaction Info is supported, then both the leaf transaction and the compound transaction info should be updated (the 
       latter is not required).
    #. The sequence should be handled directly inside the VVC executor - and not inside the BFM (otherwise updating the leaf 
       transactions for Transaction Info could be difficult).
    #. It should be possible to terminate the sequence immediately after each leaf (or base) transaction - on request from the 
       central sequencer issuing a terminate_current_command() or terminate_all_commands().

Protocol Aware Error Injection
==================================================================================================================================

Randomisation
==================================================================================================================================

Testbench Data Routing
==================================================================================================================================

Controlling Property Checkers
==================================================================================================================================

VVC Parameters and Sequence for Randomization, Sources and Destinations
==================================================================================================================================

Multiple Central Sequencers
==================================================================================================================================

Monitors
==================================================================================================================================

.. _vvc_framework_compile_scripts:

Compile Scripts
==================================================================================================================================

.. _vvc_framework_verbosity_ctrl:

Scope of Verbosity Control
==================================================================================================================================

Hierarchical VVCs
==================================================================================================================================

**********************************************************************************************************************************
VVC Implementation Guide
**********************************************************************************************************************************

.. include:: rst_snippets/ip_disclaimer.rst
