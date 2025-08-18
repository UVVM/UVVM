##################################################################################################################################
Bitvis VIP GMII
##################################################################################################################################

**Quick Access**

* `BFM`_

  * :ref:`gmii_write_bfm`
  * :ref:`gmii_read_bfm`
  * :ref:`gmii_expect_bfm`
  * :ref:`init_gmii_if_signals_bfm`

* `VVC`_

  * :ref:`gmii_write_vvc`
  * :ref:`gmii_read_vvc`
  * :ref:`gmii_expect_vvc`


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
BFM
**********************************************************************************************************************************
* This is a stripped-down version of GMII with only data lines.
* BFM functionality is implemented in gmii_bfm_pkg.vhd

.. _t_gmii_if:

Signal Record
==================================================================================================================================
**t_gmii_tx_if**

+-------------------------+------------------------------+-------------------------+
| Record element          | Type                         | Description             |
+=========================+==============================+=========================+
| gtxclk                  | std_logic                    | TX reference clock      |
+-------------------------+------------------------------+-------------------------+
| txd                     | std_logic_vector(7 downto 0) | TX data lines (to DUT)  |
+-------------------------+------------------------------+-------------------------+
| txen                    | std_logic                    | TX enable               |
+-------------------------+------------------------------+-------------------------+

**t_gmii_rx_if**

+-------------------------+------------------------------+-------------------------+
| Record element          | Type                         | Description             |
+=========================+==============================+=========================+
| rxclk                   | std_logic                    | RX reference clock      |
+-------------------------+------------------------------+-------------------------+
| rxd                     | std_logic_vector(7 downto 0) | RX data lines (from DUT)| 
+-------------------------+------------------------------+-------------------------+
| rxdv                    | std_logic                    | RX data valid           |
+-------------------------+------------------------------+-------------------------+

.. _t_gmii_bfm_config:

Configuration Record
==================================================================================================================================
**t_gmii_bfm_config**

Default value for the record is C_GMII_BFM_CONFIG_DEFAULT.

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| max_wait_cycles              | integer                      | 12              | The maximum number of clock cycles to wait for  |
|                              |                              |                 | the DUT signals before reporting a timeout alert|
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| max_wait_cycles_severity     | :ref:`t_alert_level`         | ERROR           | The above timeout will have this severity       |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| clock_period                 | time                         | -1 ns           | Period of the clock signal                      |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| clock_period_margin          | time                         | 0 ns            | Input clock period margin to specified          |
|                              |                              |                 | clock_period. Will check 'T/2' if input clock is|
|                              |                              |                 | low when BFM is called and 'T' if input clock is|
|                              |                              |                 | high.                                           |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| clock_margin_severity        | :ref:`t_alert_level`         | TB_ERROR        | The above margin will have this severity        |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| setup_time                   | time                         | -1 ns           | Generated signals setup time. Suggested value   |
|                              |                              |                 | is clock_period/4. An alert is reported if      |
|                              |                              |                 | setup_time exceeds clock_period/2.              |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| hold_time                    | time                         | -1 ns           | Generated signals hold time. Suggested value    |
|                              |                              |                 | is clock_period/4. An alert is reported if      |
|                              |                              |                 | hold_time exceeds clock_period/2.               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| bfm_sync                     | :ref:`t_bfm_sync`            | SYNC_ON_CLOCK_O\| When set to SYNC_ON_CLOCK_ONLY the BFM will     |
|                              |                              | NLY             | enter on the first falling edge, estimate the   |
|                              |                              |                 | clock period,                                   |
|                              |                              |                 |                                                 |
|                              |                              |                 | synchronize the output signals and exit ¼       |
|                              |                              |                 | clock period after a succeeding rising edge.    |
|                              |                              |                 |                                                 |
|                              |                              |                 | When set to SYNC_WITH_SETUP_AND_HOLD the BFM    |
|                              |                              |                 | will use the configured setup_time, hold_time   |
|                              |                              |                 | and                                             |
|                              |                              |                 |                                                 |
|                              |                              |                 | clock_period to synchronize output signals      |
|                              |                              |                 | with clock edges.                               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| match_strictness             | :ref:`t_match_strictness`    | MATCH_EXACT     | Matching strictness for std_logic values in     |
|                              |                              |                 | check procedures.                               |
|                              |                              |                 |                                                 |
|                              |                              |                 | MATCH_EXACT requires both values to be the      |
|                              |                              |                 | same. Note that the expected value can contain  |
|                              |                              |                 | the don't care operator '-'.                    |
|                              |                              |                 |                                                 |
|                              |                              |                 | MATCH_STD allows comparisons between 'H' and    |
|                              |                              |                 | '1', 'L' and '0' and '-' in both values.        |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| id_for_bfm                   | t_msg_id                     | ID_BFM          | Message ID used for logging general messages in |
|                              |                              |                 | the BFM                                         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

Methods
==================================================================================================================================
* All signals are active high.
* All parameters in brackets are optional.
* For clarity, data_array is required to be ascending, e.g. ::

    variable v_data_array : t_slv_array(0 to C_MAX_BYTES - 1)(7 downto 0);


.. _gmii_write_bfm:

gmii_write()
----------------------------------------------------------------------------------------------------------------------------------
Writes data to the DUT. The length and data are defined by the "data_array" argument, which is a t_slv_array. data_array(0) is 
written first, while data_array(data_array'high) is written last.

.. code-block::

    gmii_write(data_array, msg, gmii_tx_if, [action_when_transfer_is_done], [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | data_array         | in     | t_slv_array                  | An array of bytes containing the data to be written     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | gmii_tx_if         | inout  | :ref:`t_gmii_tx_if           | GMII TX signal interface record                         |
|          |                    |        | <t_gmii_if>`                 |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether to release or hold the TXEN line after the      |
|          | er_is_done         |        | _is_done`                    | procedure is finished. Useful when transmitting a packet|
|          |                    |        |                              | of data through several procedures, e.g. from Ethernet  |
|          |                    |        |                              | HVVC. Default value is RELEASE_LINE_AFTER_TRANSFER.     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("GMII BFM").              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_gmii_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_gmii_bfm_config>`         | value is C_GMII_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    gmii_write((x"01", x"02", x"03", x"04"), "Write 4 bytes", gmii_tx_if);
    gmii_write(v_data_array(0 to v_num_bytes - 1), "Write v_num_bytes bytes", gmii_tx_if, HOLD_LINE_AFTER_TRANSFER, C_SCOPE, shared_msg_id_panel, gmii_bfm_config);


.. _gmii_read_bfm:

gmii_read()
----------------------------------------------------------------------------------------------------------------------------------
Reads data from the DUT. The received data is stored in the data_array output, which is a t_slv_array. The number of valid bytes 
in the data_array is stored in data_len. data_array(0) is read first, while data_array(data_array'high) is read last.

.. code-block::

    gmii_read(data_array, data_len, msg, gmii_rx_if, [scope, [msg_id_panel, [config]]]) 

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| variable | data_array         | out    | t_slv_array                  | An array of bytes containing the data to be read        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | data_len           | out    | natural                      | The number of valid bytes in the data_array. Note that  |
|          |                    |        |                              | the data_array can be bigger and that is why the length |
|          |                    |        |                              | is returned.                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | gmii_rx_if         | inout  | :ref:`t_gmii_rx_if           | GMII RX signal interface record                         |
|          |                    |        | <t_gmii_if>`                 |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("GMII BFM").              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_gmii_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_gmii_bfm_config>`         | value is C_GMII_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    gmii_read(v_data_array, v_num_bytes, "Read GMII data", gmii_rx_if);
    gmii_read(v_data_array, v_num_bytes, "Read GMII data", gmii_rx_if, C_SCOPE, shared_msg_id_panel, gmii_bfm_config);


.. _gmii_expect_bfm:

gmii_expect()
----------------------------------------------------------------------------------------------------------------------------------
Calls the :ref:`gmii_read_bfm` procedure, then compares the received data with data_exp.

.. code-block::

    gmii_expect(data_exp, msg, gmii_rx_if, [alert_level, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | data_exp           | in     | t_slv_array                  | An array of bytes containing the data to be expected    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | gmii_rx_if         | inout  | :ref:`t_gmii_rx_if           | GMII RX signal interface record                         |
|          |                    |        | <t_gmii_if>`                 |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("GMII BFM").              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_gmii_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_gmii_bfm_config>`         | value is C_GMII_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    gmii_expect((x"01", x"02", x"03", x"04"), "Expect 4 bytes", gmii_rx_if);
    gmii_expect(v_data_array(0 to v_num_bytes - 1), "Expect v_num_bytes bytes", gmii_rx_if, ERROR, C_SCOPE, shared_msg_id_panel, gmii_bfm_config);


.. _init_gmii_if_signals_bfm:

init_gmii_if_signals()
----------------------------------------------------------------------------------------------------------------------------------
Initializes the GMII interface. All the BFM outputs are set to '0', and BFM inputs are set to 'Z'.

.. code-block::

    t_gmii_rx_if := init_gmii_if_signals
    t_gmii_tx_if := init_gmii_if_signals

.. code-block::

    -- Examples:
    gmii_rx_if <= init_gmii_if_signals;
    gmii_tx_if <= init_gmii_if_signals;


Local BFM overloads
==================================================================================================================================
A good approach for better readability and maintainability is to make simple, local overloads for the BFM procedures in the TB 
process. This allows calling the BFM procedures with the key parameters only, e.g. ::

    gmii_write(v_data_array(0 to 1), "msg");

rather than ::

    gmii_write(v_data_array(0 to 1), "msg", gmii_tx_if, C_SCOPE, shared_msg_id_panel, C_GMII_BFM_CONFIG_DEFAULT);

By defining the local overload as e.g. ::

    procedure gmii_write(
      constant data_array : in t_slv_array; 
      constant msg        : in string) is
    begin
      gmii_write(data_array,               -- Keep as is
                 msg,                      -- Keep as is
                 gmii_tx_if,               -- Signal must be visible in local process scope
                 C_SCOPE,                  -- Use the default
                 shared_msg_id_panel,      -- Use global, shared msg_id_panel
                 C_GMII_BFM_CONFIG_LOCAL); -- Use locally defined configuration or C_GMII_BFM_CONFIG_DEFAULT
    end procedure;

Using a local overload like this also allows the following – if wanted:

* Set up defaults for constants. May be different for two overloads of the same BFM
* Apply dedicated message ID panel to allow dedicated verbosity control


Compilation
==================================================================================================================================
.. include:: rst_snippets/bfm_compilation.rst

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


Additional Documentation
==================================================================================================================================
.. important::

    * This is a simplified Bus Functional Model (BFM) for GMII.
    * The given BFM complies with the basic GMII protocol and thus allows a normal access towards a GMII interface.
    * This BFM is not a GMII protocol checker.
    * For a more advanced BFM please contact UVVM support at info@uvvm.org


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
VVC
**********************************************************************************************************************************
* VVC functionality is implemented in gmii_vvc.vhd
* For general information see :ref:`VVC Framework - Essential Mechanisms <vvc_framework_essential_mechanisms>`.

Entity
==================================================================================================================================

Generics
----------------------------------------------------------------------------------------------------------------------------------

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Name                         | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| GC_INSTANCE_IDX              | natural                      | N/A             | Instance number to assign the VVC               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_GMII_BFM_CONFIG           | :ref:`t_gmii_bfm_config      | C_GMII_BFM_CONF\| Configuration for the GMII BFM                  |
|                              | <t_gmii_bfm_config>`         | IG_DEFAULT      |                                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_CMD_QUEUE_COUNT_MAX       | natural                      | C_CMD_QUEUE_COU\| Absolute maximum number of commands in the VVC  |
|                              |                              | NT_MAX          | command queue                                   |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_CMD_QUEUE_COUNT_THRESHOLD | natural                      | C_CMD_QUEUE_COU\| An alert will be generated when reaching this   |
|                              |                              | NT_THRESHOLD    | threshold to indicate that the command queue is |
|                              |                              |                 | almost full. The queue will still accept new co\|
|                              |                              |                 | mmands until it reaches GC_CMD_QUEUE_COUNT_MAX. |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_CMD_QUEUE_COUNT_THRESHOLD\| :ref:`t_alert_level`         | C_CMD_QUEUE_COU\| Alert severity which will be used when command  |
| _SEVERITY                    |                              | NT_THRESHOLD_SE\| queue reaches GC_CMD_QUEUE_COUNT_THRESHOLD      |
|                              |                              | VERITY          |                                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_RESULT_QUEUE_COUNT_MAX    | natural                      | C_RESULT_QUEUE\ | Maximum number of unfetched results before      |
|                              |                              | _COUNT_MAX      | result_queue is full                            |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_RESULT_QUEUE_COUNT_THRESH\| natural                      | C_RESULT_QUEUE\ | An alert will be issued if result queue exceeds |
| OLD                          |                              | _COUNT_THRESHOLD| this count. Used for early warning if result    |
|                              |                              |                 | queue is almost full. Will be ignored if set to |
|                              |                              |                 | 0.                                              |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_RESULT_QUEUE_COUNT_THRESH\| :ref:`t_alert_level`         | C_RESULT_QUEUE \| Severity of alert to be initiated if exceeding  |
| OLD_SEVERITY                 |                              | _COUNT_THRESHOL\| GC_RESULT_QUEUE_COUNT_THRESHOLD                 |
|                              |                              | D_SEVERITY      |                                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

Signals
----------------------------------------------------------------------------------------------------------------------------------

+----------+--------------------+--------+--------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                           | Description                                           |
+==========+====================+========+================================+=======================================================+
| signal   | gmii_vvc_tx_if     | inout  | :ref:`t_gmii_tx_if <t_gmii_if>`| GMII TX signal interface record                       |
+----------+--------------------+--------+--------------------------------+-------------------------------------------------------+
| signal   | gmii_vvc_rx_if     | inout  | :ref:`t_gmii_rx_if <t_gmii_if>`| GMII RX signal interface record                       |
+----------+--------------------+--------+--------------------------------+-------------------------------------------------------+

Configuration Record
==================================================================================================================================
**vvc_config** accessible via **shared_gmii_vvc_config**

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| inter_bfm_delay              | :ref:`t_inter_bfm_delay`     | C_GMII_INTER_BF\| Delay between any requested BFM accesses        |
|                              |                              | M_DELAY_DEFAULT | towards the DUT.                                |
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
| cmd_queue_count_max          | natural                      | C_CMD_QUEUE_COU\| Maximum pending number in command queue before  |
|                              |                              | NT_MAX          | queue is full. Adding additional commands will  |
|                              |                              |                 | result in an ERROR.                             |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| cmd_queue_count_threshold    | natural                      | C_CMD_QUEUE_COU\| An alert will be issued if command queue exceeds|
|                              |                              | NT_THRESHOLD    | this count. Used for early warning if command   |
|                              |                              |                 | queue is almost full. Will be ignored if set to |
|                              |                              |                 | 0.                                              |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| cmd_queue_count_threshold_se\| :ref:`t_alert_level`         | C_CMD_QUEUE_COU\| Severity of alert to be initiated if exceeding  |
| verity                       |                              | NT_THRESHOLD_SE\| cmd_queue_count_threshold                       |
|                              |                              | ERITY           |                                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| result_queue_count_max       | natural                      | C_RESULT_QUEUE\ | Maximum number of unfetched results before      |
|                              |                              | _COUNT_MAX      | result_queue is full                            |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| result_queue_count_threshold | natural                      | C_RESULT_QUEUE\ | An alert will be issued if result queue exceeds |
|                              |                              | _COUNT_THRESHOLD| this count. Used for early warning if result    |
|                              |                              |                 | queue is almost full. Will be ignored if set to |
|                              |                              |                 | 0.                                              |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| result_queue_count_threshold\| :ref:`t_alert_level`         | C_RESULT_QUEUE\ | Severity of alert to be initiated if exceeding  |
| _severity                    |                              | _COUNT_THRESHOL\| result_queue_count_threshold                    |
|                              |                              | D_SEVERITY      |                                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| bfm_config                   | :ref:`t_gmii_bfm_config      | C_GMII_BFM_CONF\| Configuration for the GMII BFM                  |
|                              | <t_gmii_bfm_config>`         | IG_DEFAULT      |                                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| msg_id_panel                 | t_msg_id_panel               | C_VVC_MSG_ID_PA\| VVC dedicated message ID panel. See             |
|                              |                              | NEL_DEFAULT     | :ref:`vvc_framework_verbosity_ctrl` for how to  |
|                              |                              |                 | use verbosity control.                          |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| unwanted_activity_severity   | :ref:`t_alert_level`         | C_UNWANTED_ACTI\| Severity of alert to be issued if unwanted      |
|                              |                              | VITY_SEVERITY   | activity on the DUT outputs is detected. It is  |
|                              |                              |                 | enabled with ERROR severity by default.         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

.. note::

    cmd/result queue parameters in the configuration record are unused and will be removed in v3.0, use instead the entity generic constants.

The configuration record can be accessed from the Central Testbench Sequencer through the shared variable array, e.g. ::

    shared_gmii_vvc_config(RX, C_VVC_IDX).inter_bfm_delay.delay_in_time := 50 ns;
    shared_gmii_vvc_config(TX, C_VVC_IDX).bfm_config.id_for_bfm := ID_BFM;

Status Record
==================================================================================================================================
**vvc_status** accessible via **shared_gmii_vvc_status**

.. include:: rst_snippets/vip_vvc_status.rst

Methods
==================================================================================================================================
* All VVC procedures are defined in vvc_methods_pkg.vhd (dedicated to this VVC).
* See :ref:`vvc_framework_methods` for procedures which are common to all VVCs.
* It is also possible to send a multicast to all instances of a VVC with ALL_INSTANCES as parameter for vvc_instance_idx.
* All parameters in brackets are optional.
* For clarity, data_array is required to be ascending, e.g. ::

    variable v_data_array : t_slv_array(0 to C_MAX_BYTES - 1)(7 downto 0);


.. _gmii_write_vvc:

gmii_write()
----------------------------------------------------------------------------------------------------------------------------------
Adds a write command to the GMII VVC executor queue, which will run as soon as all preceding commands have completed. When the 
command is scheduled to run, the executor calls the BFM :ref:`gmii_write_bfm` procedure. data_array(0) is written first, while 
data_array(data_array'high) is written last.

.. code-block::

    gmii_write(VVCT, vvc_instance_idx, channel, data_array, msg, [action_when_transfer_is_done], [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | channel            | in     | t_channel                    | The VVC channel of the VVC instance                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_array         | in     | t_slv_array                  | An array of bytes containing the data to be written     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether to release or hold the TXEN line after the      |
|          | er_is_done         |        | _is_done`                    | procedure is finished. Useful when transmitting a packet|
|          |                    |        |                              | of data through several procedures, e.g. from Ethernet  |
|          |                    |        |                              | HVVC. Default value is RELEASE_LINE_AFTER_TRANSFER.     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    gmii_write(GMII_VVCT, 0, TX, (x"01", x"02", x"03", x"04"), "Write 4 bytes");
    gmii_write(GMII_VVCT, 0, TX, v_data_array(0 to v_num_bytes - 1), "Write v_num_bytes bytes", HOLD_LINE_AFTER_TRANSFER, C_SCOPE);


.. _gmii_read_vvc:

gmii_read()
----------------------------------------------------------------------------------------------------------------------------------
Adds a read command to the GMII VVC executor queue, which will run as soon as all preceding commands have completed. When the 
command is scheduled to run, the executor calls the BFM :ref:`gmii_read_bfm` procedure.

The value read from DUT will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but the 
read data will be stored in the VVC for a potential future fetch (see example with fetch_result below). 
If the data_routing is set to TO_SB, the read data will be sent to the GMII VVC dedicated scoreboard where it will be 
checked against the expected value (provided by the testbench).

.. code-block::

    gmii_read(VVCT, vvc_instance_idx, channel, [num_bytes], [data_routing,] msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | channel            | in     | t_channel                    | The VVC channel of the VVC instance                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | num_bytes          | in     | t_channel                    | Number of bytes to be read                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_routing       | in     | :ref:`t_data_routing`        | Selects the destination of the read data                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    gmii_read(GMII_VVCT, 0, RX, "Read data and store it in the VVC");
    gmii_read(GMII_VVCT, 0, RX, 10, "Read 10 bytes of data", C_SCOPE);
    gmii_read(GMII_VVCT, 0, RX, TO_SB, "Read data and send to Scoreboard for checking");

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last read
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from read.
    ...
    gmii_read(GMII_VVCT, 0, RX, "Read data in VVC");
    v_cmd_idx := get_last_received_cmd_idx(GMII_VVCT, 0, RX);
    await_completion(GMII_VVCT, 0, RX, v_cmd_idx, 1 us, "Wait for read to finish");
    fetch_result(GMII_VVCT, 0, RX, v_cmd_idx, v_result, "Fetching result from read operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.


.. _gmii_expect_vvc:

gmii_expect()
----------------------------------------------------------------------------------------------------------------------------------
Adds an expect command to the GMII VVC executor queue, which will run as soon as all preceding commands have completed. When the 
command is scheduled to run, the executor calls the BFM :ref:`gmii_expect_bfm` procedure. The gmii_expect() procedure will perform a 
read operation, then check if the read data is equal to the expected data in the data parameter. If the read data is not equal to 
the expected data parameter, an alert with severity 'alert_level' will be issued. The read data will not be stored in this procedure.

.. code-block::

    gmii_expect(VVCT, vvc_instance_idx, channel, data_exp, msg, [alert_level, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | channel            | in     | t_channel                    | The VVC channel of the VVC instance                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | t_slv_array                  | An array of bytes containing the data to be expected    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    gmii_expect(GMII_VVCT, 0, RX, (x"01", x"02", x"03", x"04"), "Expect 4 bytes from DUT");
    gmii_expect(GMII_VVCT, 0, RX, v_data_array(0 to v_num_bytes - 1), "Expect v_num_bytes from DUT", ERROR, C_SCOPE);


Activity Watchdog
==================================================================================================================================
.. include:: rst_snippets/vip_activity_watchdog.rst


Transaction Info
==================================================================================================================================
.. include:: rst_snippets/vip_transaction_info.rst

.. table:: GMII transaction info record fields. Transaction Type: t_base_transaction (BT) - accessible via **shared_gmii_vvc_transaction_info.bt**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | data_array                   | t_slv_array(0 to 2047)(7     | 0x0             | Data for GMII read or write transaction         |
    |                              | downto 0)                    |                 |                                                 |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | vvc_meta                     | t_vvc_meta                   | C_VVC_META_DEFA\| VVC meta data of the executing VVC command      |
    |                              |                              | ULT             |                                                 |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    |  -> msg                      | string                       | ""              | Message of executing VVC command                |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    |  -> cmd_idx                  | integer                      | -1              | Command index of executing VVC command          |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | transaction_status           | t_transaction_status         | INACTIVE        | Set to INACTIVE, IN_PROGRESS, FAILED or         |
    |                              |                              |                 | SUCCEEDED during a transaction                  |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+

More information can be found in :ref:`Essential Mechanisms - Distribution of Transaction Info <vvc_framework_transaction_info>`.


Scoreboard
==================================================================================================================================
This VVC has built in Scoreboard functionality where data can be routed by setting the TO_SB parameter in supported method calls, 
i.e. gmii_read(). Note that the data is only stored in the scoreboard and not accessible with the fetch_result() method when the 
TO_SB parameter is applied. The GMII scoreboard is accessible from the testbench as a shared variable GMII_VVC_SB, located in the 
vvc_methods_pkg.vhd, e.g. ::

    GMII_VVC_SB.add_expected(C_GMII_VVC_IDX, v_expected, "Adding expected");

See the :ref:`vip_scoreboard` for a complete list of available commands and additional information. All of the listed Generic
Scoreboard commands are available for the GMII VVC scoreboard using the GMII_VVC_SB.


Unwanted Activity Detection
==================================================================================================================================
.. include:: rst_snippets/vip_unwanted_activity.rst

.. code-block::

    shared_gmii_vvc_config(RX, C_VVC_INDEX).unwanted_activity_severity := NO_ALERT;

The unwanted activity detection is ignored when the rxdv signal goes low within one clock period after the VVC becomes inactive. 
This is to handle the situation when the read command exits before the next rising edge, causing signal transitions during the 
first clock cycle after the VVC is inactive. 

For GMII VVC, the unwanted activity detection is enabled by default with severity ERROR.

.. note::

    This feature is only implemented on gmii_rx_vvc.

More information can be found in :ref:`Essential Mechanisms - Unwanted Activity Detection <vvc_framework_unwanted_activity>`.


Compilation
==================================================================================================================================
The GMII VVC must be compiled with VHDL-2008 or newer. It is dependent on the following libraries:

    * UVVM Utility Library (UVVM-Util)
    * UVVM VVC Framework
    * Bitvis VIP Scoreboard
    * GMII BFM

Before compiling the GMII VVC, assure that uvvm_util, uvvm_vvc_framework and bitvis_vip_scoreboard have been compiled.

See :ref:`Essential Mechanisms - Compile Scripts <vvc_framework_compile_scripts>` for information about compile scripts.

.. table:: Compile order for the GMII VVC

    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | Compile to library           | File                                           | Comment                                         |
    +==============================+================================================+=================================================+
    | bitvis_vip_gmii              | gmii_bfm_pkg.vhd                               | GMII BFM                                        |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_gmii              | transaction_pkg.vhd                            | GMII transaction package with DTT types,        |
    |                              |                                                | constants, etc.                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_gmii              | vvc_cmd_pkg.vhd                                | GMII VVC command types and operations           |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_gmii              | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC target support package, compiled into  |
    |                              | _target_support_pkg.vhd                        | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_gmii              | ../uvvm_vvc_framework/src_target_dependent/td\ | Common UVVM framework methods compiled into the |
    |                              | _vvc_framework_common_methods_pkg.vhd          | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_gmii              | vvc_sb_pkg.vhd                                 | GMII VVC scoreboard                             |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_gmii              | vvc_methods_pkg.vhd                            | GMII VVC methods                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_gmii              | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM queue package for this VVC                 |
    |                              | _queue_pkg.vhd                                 |                                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_gmii              | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC entity support compiled into this      |
    |                              | _vvc_entity_support_pkg.vhd                    | VVC library                                     |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_gmii              | gmii_tx_vvc.vhd                                | GMII TX VVC                                     |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_gmii              | gmii_rx_vvc.vhd                                | GMII RX VVC                                     |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_gmii              | gmii_vvc.vhd                                   | GMII VVC wrapper for the TX and RX VVCs         |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_gmii              | vvc_context.vhd                                | GMII VVC context file                           |
    +------------------------------+------------------------------------------------+-------------------------------------------------+

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


Additional Documentation
==================================================================================================================================
.. important::

    * This is a simplified Verification IP (VIP) for GMII.
    * The given VIP complies with the basic GMII protocol and thus allows a normal access towards a GMII interface.
    * This VIP is not a GMII protocol checker.
    * For a more advanced VIP please contact UVVM support at info@uvvm.org

.. include:: rst_snippets/ip_disclaimer.rst
