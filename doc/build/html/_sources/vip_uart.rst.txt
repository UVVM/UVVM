##################################################################################################################################
Bitvis VIP UART
##################################################################################################################################

**Quick Access**

* `BFM`_

  * :ref:`uart_transmit_bfm`
  * :ref:`uart_receive_bfm`
  * :ref:`uart_expect_bfm`

* `VVC`_

  * :ref:`uart_transmit_vvc`
  * :ref:`uart_receive_vvc`
  * :ref:`uart_expect_vvc`

* `Monitor`_


.. include:: rst_snippets/subtitle_1_division.rst

.. _vip_uart_bfm:

**********************************************************************************************************************************
BFM
**********************************************************************************************************************************
BFM functionality is implemented in uart_bfm_pkg.vhd

.. _t_uart_bfm_config:

Configuration Record
==================================================================================================================================
**t_uart_bfm_config**

Default value for the record is C_UART_BFM_CONFIG_DEFAULT.

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| bit_time                     | time                         | -1 ns           | The time it takes to transfer one bit. Will     |
|                              |                              |                 | raise an error if not set.                      |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| num_data_bits                | natural range 7 to 8         | 8               | Number of data bits to send per transmission    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| idle_state                   | std_logic                    | '1'             | Bit value when line is idle                     |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| num_stop_bits                | :ref:`t_stop_bits`           | STOP_BITS_ONE   | Number of stop-bits to use per transmission     |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| parity                       | :ref:`t_parity`              | PARITY_ODD      | Transmission parity bit                         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| timeout                      | time                         | 0 ns            | The maximum time to wait for the UART start bit |
|                              |                              |                 | on the RX line before timeout                   |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| timeout_severity             | :ref:`t_alert_level`         | ERROR           | The above timeout will have this severity       |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| num_bytes_to_log_before_expe\| natural                      | 10              | Maximum number of bytes to save ahead of the    |
| cted_data                    |                              |                 | expected data in the receive buffer. The bytes  |
|                              |                              |                 | in the receive buffer will be logged.           |
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
| id_for_bfm_wait              | t_msg_id                     | ID_BFM_WAIT     | Message ID used for logging waits in the BFM    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| id_for_bfm_poll              | t_msg_id                     | ID_BFM_POLL     | DEPRECATED                                      |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| id_for_bfm_poll_summary      | t_msg_id                     | ID_BFM_POLL_SUM\| Message ID used for logging polling summary in  |
|                              |                              | MARY            | the BFM                                         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| error_injection              | t_bfm_error_injection        | C_BFM_ERROR_INJ\| Record to set up error injection in the BFM     |
|                              |                              | ECTION_INACTIVE | procedure calls                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

**t_bfm_error_injection**

Default value for the record is C_BFM_ERROR_INJECTION_INACTIVE.

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| parity_bit_error             | boolean                      | false           | Will invert the parity bit in a transmission if |
|                              |                              |                 | TRUE, and thus generate a parity error.         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| stop_bit_error               | boolean                      | false           | Will invert the first stop bit in a transmission|
|                              |                              |                 | if TRUE. Note that the following UART frame may |
|                              |                              |                 | be misinterpreted if there is no Idle period or |
|                              |                              |                 | additional stop bits after the error injection. |
|                              |                              |                 | Hence a stop_bit_error may lead to multiple     |
|                              |                              |                 | following UART frame errors.                    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

For more information on error injection, please see :ref:`vvc_framework_error_injection`.

Methods
==================================================================================================================================
* All signals are active high.
* All parameters in brackets are optional.

.. note::

    The BFM configuration has to be defined and used when calling the UART BFM procedures. See :ref:`uart_local_bfm_config` for an 
    example of how to define a local BFM config.


.. _uart_transmit_bfm:

uart_transmit()
----------------------------------------------------------------------------------------------------------------------------------
Transmits data to the DUT using the UART protocol. For protocol details, see the UART specification.

    * The start bit, stop bit, parity, number of stop bits and number of data bits per transmission is defined in the 'config' 
      parameter. 
    * Errors may be injected depending on the 'config.error_injection' sub-record.

.. code-block::

    uart_transmit(data_value, msg, tx, [config, [scope, [msg_id_panel]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | data_value         | in     | std_logic_vector             | The data value to be transmitted to the DUT             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | tx                 | inout  | std_logic                    | The UART BFM transmission signal. Must be connected to  |
|          |                    |        |                              | the UART DUT 'rx' port.                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_uart_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_uart_bfm_config>`         | value is C_UART_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("UART BFM").              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    uart_transmit(x"AA", "Transmitting data to DUT UART", tx);
    uart_transmit(x"AA", "Transmitting data to DUT UART", tx, C_UART_BFM_CONFIG_DEFAULT, C_SCOPE, shared_msg_id_panel);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    uart_transmit(C_ASCII_A, "Transmitting ASCII A to DUT UART");


.. _uart_receive_bfm:

uart_receive()
----------------------------------------------------------------------------------------------------------------------------------
Receives data from the DUT using the UART protocol. For protocol details, see the UART specification. 

When called, the procedure will wait for the start bit to be present on the rx line. The initial wait for the start bit will be 
terminated if one of the following occurs:

    #. The start bit is present on the rx line.
    #. The terminate_loop flag is set to '1'.
    #. The number of clock cycles waited for the start bit exceeds 'config.max_wait_cycles' clock cycles.

Once all the bits have been received according to the UART specification, the parity and stop bit are checked. If correct, the 
read data is placed on the output 'data_value' and the procedure returns.

The procedure reports an alert if:

    * Timeout occurs, i.e. start bit does not occur within 'config.max_wait_cycles' clock cycles (alert level: 'config.max_wait_cycles_severity')
    * terminate_loop is set to '1' (alert level: WARNING)
    * Expected stop_bit does not match received stop bit(s) (alert level: ERROR)
    * Calculated parity 'config.parity' does not match received parity (alert level: ERROR)

.. code-block::

    uart_receive(data_value, msg, rx, terminate_loop, [config, [scope, [msg_id_panel]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| variable | data_value         | out    | std_logic_vector             | The data value received from the DUT                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | rx                 | in     | std_logic                    | The UART BFM reception signal. Must be connected to the |
|          |                    |        |                              | UART DUT 'tx' port.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | External control of loop termination to e.g. stop expect|
|          |                    |        |                              | procedure prematurely                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_uart_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_uart_bfm_config>`         | value is C_UART_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("UART BFM").              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    uart_receive(v_data_out, "Receive from DUT UART", rx, terminate_signal);
    uart_receive(v_data_out, "Receive from DUT UART", rx, terminate_signal, C_UART_BFM_CONFIG_DEFAULT, C_SCOPE, shared_msg_id_panel); 

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    uart_receive(v_data_out, "Receive from DUT UART");


.. _uart_expect_bfm:

uart_expect()
----------------------------------------------------------------------------------------------------------------------------------
Receives data from the DUT using the UART protocol described under :ref:`uart_receive_bfm`. After receiving data from the DUT, the 
received data is compared with the expected data. If the received data does not match the expected data, another uart_receive() 
procedure will be initiated. This process will repeat until one of the following occurs:

    #. The received data matches the expected data.
    #. A timeout occurs.
    #. The process has repeated 'max_receptions' number of times.
    #. The 'terminate_loop' signal is set to '1'.

| A log message with ID 'config.id_for_bfm' is issued when the procedure starts.
| If the data was received successfully, and the received data matches the expected data, a log message is written with ID 'config.id_for_bfm'.
| If the received data did not match the expected data, an alert with severity 'alert_level' will be reported.
| This procedure reports an alert if:

    * 'max_receptions' and 'timeout' are set to 0, which will result in a possible infinite loop (alert_level: ERROR)
    * The expected data is not received within the time set in 'timeout' (alert_level: 'alert_level')
    * The expected data is not received within the number of received packets set in 'max_receptions' (alert_level: 'alert_level')
    * 'terminate_loop' is set to '1' (alert_level: WARNING)
    * The same alert conditions as the :ref:`uart_receive_bfm` procedure.

.. code-block::

    uart_expect(data_exp, msg, rx, terminate_loop, [max_receptions, [timeout, [alert_level, [config, [scope, [msg_id_panel]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | data_exp           | in     | std_logic_vector             | The data value to expect when receiving the data. A     |
|          |                    |        |                              | mismatch results in an alert with severity 'alert_level'|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | rx                 | in     | std_logic                    | The UART BFM reception signal. Must be connected to the |
|          |                    |        |                              | UART DUT 'tx' port.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | External control of loop termination to e.g. stop expect|
|          |                    |        |                              | procedure prematurely                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | max_receptions     | in     | natural                      | The maximum number of bytes received before the expected|
|          |                    |        |                              | data must be received. Exceeding this limit results in  |
|          |                    |        |                              | an alert with severity 'alert_level'. Setting this value|
|          |                    |        |                              | to 0 will be interpreted as no limit. Default value is 1|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | The maximum time to pass before the expected data must  |
|          |                    |        |                              | be received. Exceeding this limit results in an alert   |
|          |                    |        |                              | with severity 'alert_level'. Setting this value to 0    |
|          |                    |        |                              | will be interpreted as no timeout. Default value is the |
|          |                    |        |                              | BFM config timeout.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_uart_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_uart_bfm_config>`         | value is C_UART_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("UART BFM").              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    uart_expect(x"3B", "Expect data on UART RX", rx, terminate_signal, 1, 0 ns);
    uart_expect(x"3B", "Expect data on UART RX", rx, terminate_signal, 1, 0 ns, ERROR, C_UART_BFM_CONFIG_DEFAULT, C_SCOPE, shared_msg_id_panel);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    uart_expect(C_CR_BYTE, "Expecting carriage return");   
    uart_expect(C_CR_BYTE, "Expecting carriage return", C_TIMEOUT, C_MAX_RECEPTIONS);  


Local BFM overloads
==================================================================================================================================
A good approach for better readability and maintainability is to make simple, local overloads for the BFM procedures in the TB 
process. This allows calling the BFM procedures with the key parameters only, e.g. ::

    uart_transmit(C_ASCII_A, "Transmitting ASCII A");

rather than ::

    uart_transmit(C_ASCII_A, "Transmitting ASCII A", tx, C_UART_CONFIG_LOCAL, C_SCOPE, shared_msg_id_panel);

By defining the local overload as e.g. ::

    procedure uart_transmit(
      constant data_value : in std_logic_vector;
      constant msg        : in string) is
    begin
      uart_transmit(data_value,           -- Keep as is
                    msg,                  -- Keep as is
                    tx,                   -- Signal must be visible in local process scope
                    C_UART_CONFIG_LOCAL,  -- Use locally defined configuration or C_UART_CONFIG_DEFAULT
                    C_SCOPE,              -- Use the default
                    shared_msg_id_panel); -- Use global, shared msg_id_panel
    end procedure;

Using a local overload like this also allows the following – if wanted:

* Set up defaults for constants. May be different for two overloads of the same BFM
* Apply dedicated message ID panel to allow dedicated verbosity control


.. _uart_local_bfm_config:

Local BFM configuration
==================================================================================================================================
The UART BFM requires that a local configuration is declared in the testbench and used in the BFM procedure calls. The default BFM 
configuration is defined with a clock period of -1 ns so that the BFM can detect and alert the user that the configuration has not 
been set.

Defining a local UART BFM configuration:::

    constant C_UART_CONFIG_LOCAL : t_uart_bfm_config := (
      bit_time                              => C_UART_BIT_TIME,
      num_data_bits                         => 8,
      idle_state                            => '1',
      num_stop_bits                         => STOP_BITS_ONE,
      parity                                => PARITY_ODD,
      timeout                               => 0 ns,                
      timeout_severity                      => error,
      num_bytes_to_log_before_expected_data => 10,
      match_strictness                      => MATCH_EXACT,
      id_for_bfm                            => ID_BFM,
      id_for_bfm_wait                       => ID_BFM_WAIT,
      id_for_bfm_poll                       => ID_BFM_POLL,
      id_for_bfm_poll_summary               => ID_BFM_POLL_SUMMARY,
      error_injection                       => C_BFM_ERROR_INJECTION_INACTIVE
    );


Compilation
==================================================================================================================================
.. include:: rst_snippets/bfm_compilation.rst

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


Additional Documentation
==================================================================================================================================
For additional documentation on the UART protocol, please see the UART specification.

.. important::

    * This is a simplified Bus Functional Model (BFM) for UART TX and RX.
    * The given BFM complies with the basic UART protocol and thus allows a normal access towards a UART interface.
    * This BFM is not a UART protocol checker.
    * For a more advanced BFM please contact UVVM support at info@uvvm.org


.. include:: rst_snippets/subtitle_1_division.rst

.. _vip_uart_vvc:

**********************************************************************************************************************************
VVC
**********************************************************************************************************************************
* VVC functionality is implemented in uart_vvc.vhd
* For general information see :ref:`VVC Framework - Essential Mechanisms <vvc_framework_essential_mechanisms>`.

Entity
==================================================================================================================================

Generics
----------------------------------------------------------------------------------------------------------------------------------

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Name                         | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| GC_DATA_WIDTH                | natural                      | 8               | Bits in the UART byte. Note that this will      |
|                              |                              |                 | initialize num_data_bits in the BFM             |
|                              |                              |                 | configuration and override the setting in       |
|                              |                              |                 | GC_UART_CONFIG.                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_INSTANCE_IDX              | natural                      | 1               | Instance number to assign the VVC               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_UART_CONFIG               | :ref:`t_uart_bfm_config      | C_UART_BFM_CONF\| Configuration for the UART BFM                  |
|                              | <t_uart_bfm_config>`         | IG_DEFAULT      |                                                 |
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

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | uart_vvc_rx        | in     | std_logic                    | UART VVC RX signal                                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | uart_vvc_tx        | inout  | std_logic                    | UART VVC TX signal                                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

Configuration Record
==================================================================================================================================
**vvc_config** accessible via **shared_uart_vvc_config**

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| inter_bfm_delay              | :ref:`t_inter_bfm_delay`     | C_UART_INTER_BF\| Delay between any requested BFM accesses        |
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
| bfm_config                   | :ref:`t_uart_bfm_config      | C_UART_BFM_CONF\| Configuration for the UART BFM                  |
|                              | <t_uart_bfm_config>`         | IG_DEFAULT      |                                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| msg_id_panel                 | t_msg_id_panel               | C_VVC_MSG_ID_PA\| VVC dedicated message ID panel. See             |
|                              |                              | NEL_DEFAULT     | :ref:`vvc_framework_verbosity_ctrl` for how to  |
|                              |                              |                 | use verbosity control.                          |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| error_injection              | t_vvc_error_injection        | C_VVC_ERROR_INJ\| Record to set up the error injection policy in  |
|                              |                              | ECTION_INACTIVE | the BFM procedure calls                         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| bit_rate_checker             | t_bit_rate_checker           | C_BIT_RATE_CHEC\| Configure the UART property checker behavior    |
|                              |                              | KER_DEFAULT     |                                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| unwanted_activity_severity   | :ref:`t_alert_level`         | C_UNWANTED_ACTI\| Severity of alert to be issued if unwanted      |
|                              |                              | VITY_SEVERITY   | activity on the DUT outputs is detected. It is  |
|                              |                              |                 | enabled with ERROR severity by default.         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

.. note::

    cmd/result queue parameters in the configuration record are unused and will be removed in v3.0, use instead the entity generic constants.

The configuration record can be accessed from the Central Testbench Sequencer through the shared variable array, e.g. ::

    shared_uart_vvc_config(RX, C_VVC_IDX).inter_bfm_delay.delay_in_time := 10 ms;
    shared_uart_vvc_config(TX, C_VVC_IDX).bfm_config.num_data_bits := 8;

**t_vvc_error_injection**

Default value for the record is C_VVC_ERROR_INJECTION_INACTIVE.

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| parity_bit_error_prob        | real                         | -1.0            | The probability that the VVC will request a     |
|                              |                              |                 | parity_bit_error when calling a BFM transmission|
|                              |                              |                 | procedure. (See :ref:`t_uart_bfm_config         |
|                              |                              |                 | <t_uart_bfm_config>`)                           |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| stop_bit_error_prob          | real                         | -1.0            | The probability that the VVC will request a     |
|                              |                              |                 | stop_bit_error when calling a BFM transmission  |
|                              |                              |                 | procedure. (See :ref:`t_uart_bfm_config         |
|                              |                              |                 | <t_uart_bfm_config>`)                           |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

.. note::

    * A value of 1.0 means every transmission should have this error injection, whereas 0.0 means error injection is turned off. 
      Anything in between means randomization with the given probability.
    * The error_injection config in the VVC config will override any error injection specified in the BFM config, unless set to 
      -1.0 (default) in which case the BFM config error injection setting will be used.

For more information on error injection, please see :ref:`vvc_framework_error_injection`.

**t_bit_rate_checker**

Default value for the record is C_BIT_RATE_CHECKER_DEFAULT.

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| enable                       | boolean                      | false           | Enables or disables the complete bit rate       |
|                              |                              |                 | checker                                         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| min_period                   | time                         | 0.0             | The minimum allowed bit period for any bit (any |
|                              |                              |                 | bit level change to the next)                   |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| alert_level                  | :ref:`t_alert_level`         | ERROR           | Alert generated if min_period is violated       |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

For more information on property checking, please see :ref:`vvc_framework_property_checkers`.

Status Record
==================================================================================================================================
**vvc_status** accessible via **shared_uart_vvc_status**

.. include:: rst_snippets/vip_vvc_status.rst

Methods
==================================================================================================================================
* All VVC procedures are defined in vvc_methods_pkg.vhd (dedicated to this VVC).
* See :ref:`vvc_framework_methods` for procedures which are common to all VVCs.
* It is also possible to send a multicast to all instances of a VVC with ALL_INSTANCES as parameter for vvc_instance_idx.
* All parameters in brackets are optional.


.. _uart_transmit_vvc:

uart_transmit()
----------------------------------------------------------------------------------------------------------------------------------
| Adds a transmit command to the UART TX VVC executor queue, which will run as soon as all preceding commands have completed. It 
  has two variants using either just data for a basic single transaction, or num_words + randomization for a more advanced version.
| When the basic transmit command is scheduled to run, the executor calls the BFM :ref:`uart_transmit_bfm` procedure. This 
  procedure scan only be called using the UART TX channel, i.e. setting 'channel' to 'TX'.
| When the more advanced randomization command is applied, the basic BFM uart_transmit() transaction is executed num_words times 
  with new random data each time - according to the given randomization profile. Current defined randomization profiles are: 
  RANDOM: Standard uniform random. This is provided as an example.
| Errors may be injected depending on the 'config.error_injection' sub-record.

.. code-block::

    uart_transmit(VVCT, vvc_instance_idx, channel, data, msg, [scope])
    uart_transmit(VVCT, vvc_instance_idx, channel, num_words, randomisation, msg, [scope])

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
| constant | data               | in     | std_logic_vector             | The data value to be transmitted                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | num_words          | in     | natural                      | Number of times the procedure is called to send new     |
|          |                    |        |                              | random data words                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | randomisation      | in     | t_randomisation              | Randomization profile                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    uart_transmit(UART_VVCT, 0, TX, x"AF", "Sending data to DUT UART instance 0", C_SCOPE);
    uart_transmit(UART_VVCT, 0, TX, 5, RANDOM, "Sending 5 random bytes to DUT UART instance 0");


.. _uart_receive_vvc:

uart_receive()
----------------------------------------------------------------------------------------------------------------------------------
Adds a receive command to the UART RX VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the BFM :ref:`uart_receive_bfm` procedure.

The received data from DUT will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but the 
received data will be stored in the VVC for a potential future fetch (see example with fetch_result below). This procedure can 
only be called using the UART RX channel, i.e. setting 'channel' to 'RX'.
If the data_routing is set to TO_SB, the received data will be sent to the UART VVC dedicated scoreboard where it will be 
checked against the expected value (provided by the testbench).

.. code-block::

    uart_receive(VVCT, vvc_instance_idx, channel, [data_routing,] msg, [alert_level, [scope]])

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
| constant | data_routing       | in     | :ref:`t_data_routing`        | Selects the destination of the read data                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Unused. DEPRECATED                                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    uart_receive(UART_VVCT, 0, RX, "Receiving from DUT UART instance 0"); 
    uart_receive(UART_VVCT, 0, RX, TO_SB, "Receiving data from DUT UART instance 0 and passing on to Scoreboard", ERROR, C_SCOPE); 

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last receive
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from receive.
    ...
    uart_receive(UART_VVCT, 0, RX, "Receiving from DUT UART instance 0");
    v_cmd_idx := get_last_received_cmd_idx(UART_VVCT, 0, RX);               
    await_completion(UART_VVCT, 0, RX, v_cmd_idx, 1 us, "Wait for receive to finish");
    fetch_result(UART_VVCT, 0, RX, v_cmd_idx, v_result, "Fetching result from receive operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.


.. _uart_expect_vvc:

uart_expect()
----------------------------------------------------------------------------------------------------------------------------------
Adds an expect command to the UART RX VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls BFM :ref:`uart_expect_bfm` procedure. The uart_expect() procedure will perform 
a receive operation, then check if the received data is equal to the expected data in the data parameter. If the received data is 
not equal to the expected data parameter, an alert with severity 'alert_level' will be issued. The received data will not be 
stored in this procedure. This procedure can only be called using the UART RX channel, i.e. setting 'channel' to 'RX'.

.. code-block::

    uart_expect(VVCT, vvc_instance_idx, channel, data, msg, [max_receptions, [timeout, [alert_level, [scope]]]])

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
| constant | data               | in     | std_logic_vector             | The expected data value to be received                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | max_receptions     | in     | natural                      | The maximum number of bytes received before the expected|
|          |                    |        |                              | data must be received. Exceeding this limit results in  |
|          |                    |        |                              | an alert with severity 'alert_level'. Setting this value|
|          |                    |        |                              | to 0 will be interpreted as no limit. Default value is 1|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | The maximum time to pass before the expected data must  |
|          |                    |        |                              | be received. Exceeding this limit results in an alert   |
|          |                    |        |                              | with severity 'alert_level'. Setting this value to 0    |
|          |                    |        |                              | will be interpreted as no timeout. Default value is the |
|          |                    |        |                              | BFM config timeout.                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    uart_expect(UART_VVCT, 0, RX, x"0D", "Expecting carriage return from DUT UART instance 0");
    uart_expect(UART_VVCT, 0, RX, C_CR_BYTE, "Expecting carriage return from DUT UART instance 0", 5, 10 ms, ERROR, C_SCOPE);


Activity Watchdog
==================================================================================================================================
.. include:: rst_snippets/vip_activity_watchdog.rst


.. _uart_vvc_transaction_info:

Transaction Info
==================================================================================================================================
.. include:: rst_snippets/vip_transaction_info.rst

.. table:: UART transaction info record fields. Transaction Type: t_base_transaction (BT) - accessible via **shared_uart_vvc_transaction_info.bt**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | data                         | std_logic_vector(7 downto 0) | 0x0             | Data for UART receive or transmit transaction   |
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
    | error_info                   | t_error_info                 | C_ERROR_INFO_DE\| Error injection status                          |
    |                              |                              | FAULT           |                                                 |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    |  -> parity_bit_error         | boolean                      | false           | Status of the parity bit error injection        |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    |  -> stop_bit_error           | boolean                      | false           | Status of the stop bit error injection          |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+

More information can be found in :ref:`Essential Mechanisms - Distribution of Transaction Info <vvc_framework_transaction_info>`.


Scoreboard
==================================================================================================================================
This VVC has built in Scoreboard functionality where data can be routed by setting the TO_SB parameter in supported method calls, 
i.e. uart_receive(). Note that the data is only stored in the scoreboard and not accessible with the fetch_result() method when the 
TO_SB parameter is applied. The UART scoreboard is accessible from the testbench as a shared variable UART_VVC_SB, located in the 
vvc_methods_pkg.vhd, e.g. ::

    UART_VVC_SB.add_expected(C_UART_VVC_IDX, v_expected, "Adding expected");

See the :ref:`vip_scoreboard` for a complete list of available commands and additional information. All of the listed Generic
Scoreboard commands are available for the UART VVC scoreboard using the UART_VVC_SB.


Unwanted Activity Detection
==================================================================================================================================
.. include:: rst_snippets/vip_unwanted_activity.rst

.. code-block::

    shared_uart_vvc_config(RX, C_VVC_INDEX).unwanted_activity_severity := NO_ALERT;

For UART VVC, the unwanted activity detection is enabled by default with severity ERROR.

.. note::

    This feature is only implemented on uart_rx_vvc.

More information can be found in :ref:`Essential Mechanisms - Unwanted Activity Detection <vvc_framework_unwanted_activity>`.


Compilation
==================================================================================================================================
The UART VVC must be compiled with VHDL-2008 or newer. It is dependent on the following libraries:

    * UVVM Utility Library (UVVM-Util)
    * UVVM VVC Framework
    * Bitvis VIP Scoreboard
    * UART BFM

Before compiling the UART VVC, assure that uvvm_util, uvvm_vvc_framework and bitvis_vip_scoreboard have been compiled.

See :ref:`Essential Mechanisms - Compile Scripts <vvc_framework_compile_scripts>` for information about compile scripts.

.. table:: Compile order for the UART VVC

    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | Compile to library           | File                                           | Comment                                         |
    +==============================+================================================+=================================================+
    | bitvis_vip_uart              | uart_bfm_pkg.vhd                               | UART BFM                                        |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | transaction_pkg.vhd                            | UART transaction package with DTT types,        |
    |                              |                                                | constants, etc.                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | vvc_cmd_pkg.vhd                                | UART VVC command types and operations           |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | monitor_cmd_pkg.vhd                            | UART Monitor package. Only include this file if |
    |                              |                                                | you intend to use Monitor.                      |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC target support package, compiled into  |
    |                              | _target_support_pkg.vhd                        | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | ../uvvm_vvc_framework/src_target_dependent/td\ | Common UVVM framework methods compiled into the |
    |                              | _vvc_framework_common_methods_pkg.vhd          | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | vvc_sb_pkg.vhd                                 | UART VVC scoreboard                             |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | vvc_methods_pkg.vhd                            | UART VVC methods                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM queue package for this VVC                 |
    |                              | _queue_pkg.vhd                                 |                                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC entity support compiled into this      |
    |                              | _vvc_entity_support_pkg.vhd                    | VVC library                                     |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | uart_rx_vvc.vhd                                | UART RX VVC                                     |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | uart_tx_vvc.vhd                                | UART TX VVC                                     |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | uart_vvc.vhd                                   | UART VVC wrapper for the TX and RX VVCs         |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | uart_monitor.vhd                               | UART Monitor. Only include this file if you     |
    |                              |                                                | intend to use Monitor.                          |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | vvc_context.vhd                                | UART VVC context file                           |
    +------------------------------+------------------------------------------------+-------------------------------------------------+

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


Additional Documentation
==================================================================================================================================
For additional documentation on the UART protocol, please see the UART specification.

.. important::

    * This is a simplified Verification IP (VIP) for UART TX and RX.
    * The given VIP complies with the basic UART protocol and thus allows a normal access towards a UART interface.
    * This VIP is not a UART protocol checker.
    * For a more advanced VIP please contact UVVM support at info@uvvm.org


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
Monitor
**********************************************************************************************************************************

Entity
==================================================================================================================================

Generics
----------------------------------------------------------------------------------------------------------------------------------

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Name                         | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| GC_INSTANCE_IDX              | natural                      | 1               | Instance number to assign the VVC               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_MONITOR_CONFIG            | :ref:`t_uart_monitor_config  | C_UART_MONITOR\ | Configuration of the UART monitor, both channels|
|                              | <t_uart_monitor_config>`     | _CONFIG_DEFAULT | get initiated with this configuration           |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

Signals
----------------------------------------------------------------------------------------------------------------------------------

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | uart_dut_rx        | in     | std_logic                    | Input of DUTs UART RX signal.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | uart_dut_tx        | in     | std_logic                    | Input of DUTs UART TX signal.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. _t_uart_monitor_config:

Configuration Record
==================================================================================================================================
**t_uart_monitor_config** accessible via **shared_uart_monitor_config**

Default value for the record is C_UART_MONITOR_CONFIG_DEFAULT.

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| scope_name                   | string                       | "set scope name"| Describes the scope from which the log/alert    |
|                              |                              |                 | originates.                                     |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| msg_id_panel                 | t_msg_id_panel               | C_UART_MONITOR\ | Monitor dedicated message ID panel. See         |
|                              |                              | _MSG_ID_PANEL_D\| :ref:`vvc_framework_verbosity_ctrl` for how to  |
|                              |                              | EFAULT          | use verbosity control.                          |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| interface_config             | t_uart_interface_config      | C_UART_MONITOR\ | The configuration for the interface             |
|                              |                              | _INTERFACE_CONF\|                                                 |
|                              |                              | IG_DEFAULT      |                                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| transaction_display_time     | time                         | 0 ns            | After this amount of time operation is set to   |
|                              |                              |                 | NO_OPERATION and transaction_status is set to   |
|                              |                              |                 | INACTIVE if a new transaction is not received.  |
|                              |                              |                 | If set to 0 ns, operation and transaction_status|
|                              |                              |                 | will be unchanged until the next transfer is    |
|                              |                              |                 | started.                                        |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

The configuration record can be accessed from the Central Testbench Sequencer through the shared variable array, e.g. ::

    shared_uart_monitor_config(TX, C_MONITOR_IDX).msg_id_panel := new_msg_id_panel;
    shared_uart_monitor_config(TX, C_MONITOR_IDX).interface_config.num_data_bits := 8;

**t_uart_interface_config**

Default value for the record is C_UART_MONITOR_INTERFACE_CONFIG_DEFAULT.

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| bit_time                     | time                         | 0 ns            | The time it takes to transfer one bit           |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| num_data_bits                | natural range 7 to 8         | 8               | Number of data bits to send per transmission    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| parity                       | :ref:`t_parity`              | PARITY_ODD      | Transmission parity bit                         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| num_stop_bits                | :ref:`t_stop_bits`           | STOP_BITS_ONE   | Number of stop-bits to use per transmission     |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

Transaction info
==================================================================================================================================
| All transaction information from the UART Monitor is accessible via **shared_uart_monitor_transaction_info**
| The global trigger pulsed when UART Monitor transaction info is available is accessible via **global_uart_monitor_transaction_trigger**

An example of use of the global_uart_monitor_transaction and shared_uart_monitor_transaction_info is seen below. A process 
extracts the transaction info from the shared variable when the global signal is triggered.

.. code-block::

    p_monitor_tx : process
      variable v_transaction : t_uart_transaction;
    begin
      wait until global_uart_monitor_transaction_trigger(TX, 1) = '1';
  
      if (shared_uart_monitor_transaction_info(TX, 1).bt.transaction_status = SUCCEEDED or
          shared_uart_monitor_transaction_info(TX, 1).bt.transaction_status = FAILED) then
        v_transaction := shared_uart_monitor_transaction_info(TX, 1).bt;
      end if;

      -- Processing received transaction 
      ...

    end process p_monitor_tx;

For more information on the type, please see :ref:`VVC Transaction Info <uart_vvc_transaction_info>`.


Message IDs
==================================================================================================================================
* ID_FRAME_INITIATE: Logs start of UART frame
* ID_MONITOR: Logs information about monitored transaction


Compilation
==================================================================================================================================
The UART Monitor must be compiled with VHDL-2008 or newer. It is dependent on the following libraries:

    * UVVM Utility Library (UVVM-Util)
    * UVVM VVC Framework
    * Bitvis VIP Scoreboard
    * UART BFM

Before compiling the UART Monitor, assure that uvvm_util, uvvm_vvc_framework and bitvis_vip_scoreboard have been compiled.

See :ref:`Essential Mechanisms - Compile Scripts <vvc_framework_compile_scripts>` for information about compile scripts.

.. table:: Compile order for the UART Monitor

    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | Compile to library           | File                                           | Comment                                         |
    +==============================+================================================+=================================================+
    | bitvis_vip_uart              | uart_bfm_pkg.vhd                               | UART BFM                                        |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | transaction_pkg.vhd                            | UART transaction package with DTT types,        |
    |                              |                                                | constants, etc.                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | vvc_cmd_pkg.vhd                                | UART VVC command types and operations           |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | monitor_cmd_pkg.vhd                            | UART Monitor package                            |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC target support package, compiled into  |
    |                              | _target_support_pkg.vhd                        | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | vvc_sb_pkg.vhd                                 | UART VVC scoreboard                             |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | vvc_methods_pkg.vhd                            | UART VVC methods                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_uart              | uart_monitor.vhd                               | UART Monitor                                    |
    +------------------------------+------------------------------------------------+-------------------------------------------------+

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


Additional Documentation
==================================================================================================================================
For additional documentation on the UART protocol, please see the UART specification.

.. include:: rst_snippets/ip_disclaimer.rst
