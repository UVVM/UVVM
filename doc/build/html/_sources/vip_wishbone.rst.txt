##################################################################################################################################
Bitvis VIP Wishbone (BETA)
##################################################################################################################################

**Quick Access**

* `BFM`_

  * :ref:`wishbone_write_bfm`
  * :ref:`wishbone_read_bfm`
  * :ref:`wishbone_check_bfm`
  * :ref:`init_wishbone_if_signals_bfm`

* `VVC`_

  * :ref:`wishbone_write_vvc`
  * :ref:`wishbone_read_vvc`
  * :ref:`wishbone_check_vvc`


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
BFM
**********************************************************************************************************************************
BFM functionality is implemented in wishbone_bfm_pkg.vhd

.. _t_wishbone_if:

Signal Record
==================================================================================================================================
**t_wishbone_if**

+-------------------------+------------------------------+
| Record element          | Type                         |
+=========================+==============================+
| dat_o                   | std_logic_vector             |
+-------------------------+------------------------------+
| dat_i                   | std_logic_vector             |
+-------------------------+------------------------------+
| adr_o                   | std_logic_vector             |
+-------------------------+------------------------------+
| cyc_o                   | std_logic                    |
+-------------------------+------------------------------+
| stb_o                   | std_logic                    |
+-------------------------+------------------------------+
| we_o                    | std_logic                    |
+-------------------------+------------------------------+
| ack_i                   | std_logic                    |
+-------------------------+------------------------------+

.. _t_wishbone_bfm_config:

Configuration Record
==================================================================================================================================
**t_wishbone_bfm_config**

Default value for the record is C_WISHBONE_BFM_CONFIG_DEFAULT.

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| max_wait_cycles              | integer                      | 10              | The maximum number of clock cycles to wait for  |
|                              |                              |                 | the DUT ready signal before reporting a timeout |
|                              |                              |                 | alert                                           |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| max_wait_cycles_severity     | :ref:`t_alert_level`         | FAILURE         | The above timeout will have this severity       |
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
| id_for_bfm_wait              | t_msg_id                     | ID_BFM_WAIT     | DEPRECATED                                      |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| id_for_bfm_poll              | t_msg_id                     | ID_BFM_POLL     | DEPRECATED                                      |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

Methods
==================================================================================================================================
* All signals are active high.
* All parameters in brackets are optional.


.. _wishbone_write_bfm:

wishbone_write()
----------------------------------------------------------------------------------------------------------------------------------
Writes the given data to the given address on the DUT, using the Wishbone protocol.

.. code-block::

    wishbone_write(addr_value, data_value, msg, clk, wishbone_if, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | The address of a software accessible register           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_value         | in     | std_logic_vector             | The data value to be written to the addressed register  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the Wishbone BFM                                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | wishbone_if        | inout  | :ref:`t_wishbone_if          | Wishbone signal interface record                        |
|          |                    |        | <t_wishbone_if>`             |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("WISHBONE BFM").          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_wishbone_bfm_config  | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_wishbone_bfm_config>`     | value is C_WISHBONE_BFM_CONFIG_DEFAULT.                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    wishbone_write(x"1000", x"55", "Write data to Peripheral 1", clk, wishbone_if);
    wishbone_write(x"1000", x"55", "Write data to Peripheral 1", clk, wishbone_if, C_SCOPE, shared_msg_id_panel, C_WISHBONE_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    wishbone_write(C_ADDR_UART_TX, x"40", "Set baud rate to 9600");


.. _wishbone_read_bfm:

wishbone_read()
----------------------------------------------------------------------------------------------------------------------------------
Reads data from the DUT at the given address, using the Wishbone protocol.

.. code-block::

    wishbone_read(addr_value, data_value, msg, clk, wishbone_if, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | The address of a software accessible register           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | data_value         | out    | std_logic_vector             | The data value read from the addressed register         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the Wishbone BFM                                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | wishbone_if        | inout  | :ref:`t_wishbone_if          | Wishbone signal interface record                        |
|          |                    |        | <t_wishbone_if>`             |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("WISHBONE BFM").          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_wishbone_bfm_config  | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_wishbone_bfm_config>`     | value is C_WISHBONE_BFM_CONFIG_DEFAULT.                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    wishbone_read(x"1000", v_data_out, "Read from Peripheral 1", clk, wishbone_if);
    wishbone_read(x"1000", v_data_out, "Read from Peripheral 1", clk, wishbone_if, C_SCOPE, shared_msg_id_panel, C_WISHBONE_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    wishbone_read(C_ADDR_UART_BAUD, v_data_out, "Read UART baud rate");


.. _wishbone_check_bfm:

wishbone_check()
----------------------------------------------------------------------------------------------------------------------------------
Reads data from the DUT at the given address, using the Wishbone protocol. After reading data from the Wishbone bus, the read data 
is compared with the expected data.

* If the check was successful, and the read data matches the expected data, a log message is written with ID 'config.id_for_bfm'.
* If the read data did not match the expected data, an alert with severity 'alert_level' will be reported.

.. code-block::

    wishbone_check(addr_value, data_exp, msg, clk, wishbone_if, [alert_level, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | The address of a software accessible register           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_logic_vector             | The data value to expect when reading the addressed     |
|          |                    |        |                              | register. A mismatch results in an alert with severity  |
|          |                    |        |                              | 'alert_level'.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the Wishbone BFM                                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | wishbone_if        | inout  | :ref:`t_wishbone_if          | Wishbone signal interface record                        |
|          |                    |        | <t_wishbone_if>`             |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("WISHBONE BFM").          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_wishbone_bfm_config  | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_wishbone_bfm_config>`     | value is C_WISHBONE_BFM_CONFIG_DEFAULT.                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    wishbone_check(x"1155", x"3B", "Check data from Peripheral 1", clk, wishbone_if);
    wishbone_check(x"1155", x"3B", "Check data from Peripheral 1", clk, wishbone_if, ERROR, C_SCOPE, shared_msg_id_panel, C_WISHBONE_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    wishbone_check(C_ADDR_UART_RX, x"3B", "Check data from UART RX buffer");


.. _init_wishbone_if_signals_bfm:

init_wishbone_if_signals()
----------------------------------------------------------------------------------------------------------------------------------
Initializes the Wishbone interface. All the BFM outputs are set to '0', and BFM inputs are set to 'Z'.

.. code-block::

    t_wishbone_if := init_wishbone_if_signals(addr_width, data_width)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_width         | in     | natural                      | Width of the address signal                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_width         | in     | natural                      | Width of the data signals                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    wishbone_if <= init_wishbone_if_signals(dat_o.addr'length, adr_o.wdata'length);


Local BFM overloads
==================================================================================================================================
A good approach for better readability and maintainability is to make simple, local overloads for the BFM procedures in the TB 
process. This allows calling the BFM procedures with the key parameters only, e.g. ::

    wishbone_write(C_ADDR_UART_BAUDRATE, C_BAUDRATE_9600, "Set Baud-rate to 9600");

rather than ::

    wishbone_write(C_ADDR_UART_BAUDRATE, C_BAUDRATE_9600, "Set Baud-rate to 9600", clk, wishbone_if, C_SCOPE, shared_msg_id_panel, C_WISHBONE_BFM_CONFIG_DEFAULT);

By defining the local overload as e.g. ::

    procedure wishbone_write(
      constant addr_value : in unsigned;
      constant data_value : in std_logic_vector;
      constant msg        : in string) is
    begin
      wishbone_write(addr_value,               -- Keep as is
                     data_value,               -- Keep as is
                     msg,                      -- Keep as is
                     clk,                      -- Signal must be visible in local process scope
                     wishbone_if,              -- Signal must be visible in local process scope
                     C_SCOPE,                  -- Use the default
                     shared_msg_id_panel,      -- Use global, shared msg_id_panel
                     C_WISHBONE_CONFIG_LOCAL); -- Use locally defined configuration or C_WISHBONE_BFM_CONFIG_DEFAULT
    end procedure;

Using a local overload like this also allows the following – if wanted:

* Have address value as natural – and convert in the overload
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

    * This is a simplified Bus Functional Model (BFM) for Wishbone.
    * The given BFM complies with the basic Wishbone protocol and thus allows a normal access towards a Wishbone interface.
    * This BFM is not a Wishbone protocol checker.
    * For a more advanced BFM please contact UVVM support at info@uvvm.org


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
VVC
**********************************************************************************************************************************
* VVC functionality is implemented in wishbone_vvc.vhd
* For general information see :ref:`VVC Framework - Essential Mechanisms <vvc_framework_essential_mechanisms>`.

Entity
==================================================================================================================================

Generics
----------------------------------------------------------------------------------------------------------------------------------

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Name                         | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| GC_ADDR_WIDTH                | integer                      | 8               | Width of the Wishbone address bus               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_DATA_WIDTH                | integer                      | 32              | Width of the Wishbone data bus                  |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_INSTANCE_IDX              | natural                      | 1               | Instance number to assign the VVC               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_WISHBONE_BFM_CONFIG       | :ref:`t_wishbone_bfm_config  | C_WISHBONE_BFM\ | Configuration for the Wishbone BFM              |
|                              | <t_wishbone_bfm_config>`     | _CONFIG_DEFAULT |                                                 |
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

+----------+------------------------+--------+------------------------------+-----------------------------------------------------+
| Object   | Name                   | Dir.   | Type                         | Description                                         |
+==========+========================+========+==============================+=====================================================+
| signal   | clk                    | in     | std_logic                    | VVC Clock signal                                    |
+----------+------------------------+--------+------------------------------+-----------------------------------------------------+
| signal   | wishbone_vvc_master_if | inout  | :ref:`t_wishbone_if          | Wishbone signal interface record                    |
|          |                        |        | <t_wishbone_if>`             |                                                     |
+----------+------------------------+--------+------------------------------+-----------------------------------------------------+

In this VVC, the interface has been encapsulated in a signal record of type t_wishbone_if in order to improve readability of the code. 
Since the Wishbone interface buses can be of arbitrary size, the interface vectors have been left unconstrained. These unconstrained 
vectors need to be constrained when the interface signals are instantiated. For this interface, it could look like: ::

    signal wishbone_if : t_wishbone_if(adr_o(C_ADDR_WIDTH - 1 downto 0),
                                       dat_o(C_DATA_WIDTH - 1 downto 0),
                                       dat_i(C_DATA_WIDTH - 1 downto 0));

Configuration Record
==================================================================================================================================
**vvc_config** accessible via **shared_wishbone_vvc_config**

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| inter_bfm_delay              | :ref:`t_inter_bfm_delay`     | C_WISHBONE_INTE\| Delay between any requested BFM accesses        |
|                              |                              | R_BFM_DELAY_DEF\| towards the DUT.                                |
|                              |                              | AULT            |                                                 |
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
| bfm_config                   | :ref:`t_wishbone_bfm_config  | C_WISHBONE_BFM\ | Configuration for the Wishbone BFM              |
|                              | <t_wishbone_bfm_config>`     | _CONFIG_DEFAULT |                                                 |
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

    shared_wishbone_vvc_config(C_VVC_IDX).inter_bfm_delay.delay_in_time := 50 ns;
    shared_wishbone_vvc_config(C_VVC_IDX).bfm_config.id_for_bfm := ID_BFM;

Status Record
==================================================================================================================================
**vvc_status** accessible via **shared_wishbone_vvc_status**

.. include:: rst_snippets/vip_vvc_status.rst

Methods
==================================================================================================================================
* All VVC procedures are defined in vvc_methods_pkg.vhd (dedicated to this VVC).
* See :ref:`vvc_framework_methods` for procedures which are common to all VVCs.
* It is also possible to send a multicast to all instances of a VVC with ALL_INSTANCES as parameter for vvc_instance_idx.
* All parameters in brackets are optional.


.. _wishbone_write_vvc:

wishbone_write()
----------------------------------------------------------------------------------------------------------------------------------
Adds a write command to the Wishbone VVC executor queue, which will run as soon as all preceding commands have completed. When the 
command is scheduled to run, the executor calls the BFM :ref:`wishbone_write_bfm` procedure.

.. code-block::

    wishbone_write(VVCT, vvc_instance_idx, addr, data, msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | addr               | in     | unsigned                     | The address of a SW accessible register                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The data value to be written to the addressed register  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    wishbone_write(WISHBONE_VVCT, 0, x"1000", x"40", "Set UART baud rate to 9600", C_SCOPE);

    -- It is recommended to use constants to improve the readability of the code, e.g.:
    wishbone_write(WISHBONE_VVCT, 0, C_ADDR_UART_BAUDRATE, C_BAUDRATE_9600, "Set UART baud rate to 9600");


.. _wishbone_read_vvc:

wishbone_read()
----------------------------------------------------------------------------------------------------------------------------------
Adds a read command to the Wishbone VVC executor queue, which will run as soon as all preceding commands have completed. When the 
command is scheduled to run, the executor calls the BFM :ref:`wishbone_read_bfm` procedure.

The value read from DUT will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but the 
read data will be stored in the VVC for a potential future fetch (see example with fetch_result below).
If the data_routing is set to TO_SB, the read data will be sent to the Wishbone VVC dedicated scoreboard where it will be 
checked against the expected value (provided by the testbench).

.. code-block::

    wishbone_read(VVCT, vvc_instance_idx, addr, [data_routing,] msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | addr               | in     | unsigned                     | The address of a SW accessible register                 |
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
    wishbone_read(WISHBONE_VVCT, 0, x"1000", "Read UART baud rate", C_SCOPE);
    wishbone_read(WISHBONE_VVCT, 0, x"1002", TO_SB, "Read UART RX and send to Scoreboard", C_SCOPE);

    -- It is recommended to use constants to improve the readability of the code, e.g.:
    wishbone_read(WISHBONE_VVCT, 0, C_ADDR_UART_BAUDRATE, "Read UART baud rate");

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last read
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from read.
    ...
    wishbone_read(WISHBONE_VVCT, 0, C_ADDR_UART_BAUDRATE, "Read from Peripheral 1");
    v_cmd_idx := get_last_received_cmd_idx(WISHBONE_VVCT, 0);
    await_completion(WISHBONE_VVCT, 0, v_cmd_idx, 1 us, "Wait for read to finish");
    fetch_result(WISHBONE_VVCT, 0, v_cmd_idx, v_result, "Fetching result from read operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.


.. _wishbone_check_vvc:

wishbone_check()
----------------------------------------------------------------------------------------------------------------------------------
Adds a check command to the Wishbone VVC executor queue, which will run as soon as all preceding commands have completed. When the 
command is scheduled to run, the executor calls the BFM :ref:`wishbone_check_bfm` procedure. The wishbone_check() procedure will 
perform a read operation, then check if the read data is equal to the expected data in the data parameter. If the read data is not 
equal to the expected data parameter, an alert with severity 'alert_level' will be issued. The read data will not be stored in 
this procedure.

.. code-block::

    wishbone_check(VVCT, vvc_instance_idx, addr, data, msg, [alert_level, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | addr               | in     | unsigned                     | The address of a SW accessible register                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The expected data value to be read from the addressed   |
|          |                    |        |                              | register                                                |
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
    wishbone_check(WISHBONE_VVCT, 0, x"1155", x"3B", "Check data from UART RX");
    wishbone_check(WISHBONE_VVCT, 0, x"1155", x"3B", "Check data from UART RX", TB_ERROR, C_SCOPE):

    -- It is recommended to use constants to improve the readability of the code, e.g.:
    wishbone_check(WISHBONE_VVCT, 0, C_ADDR_UART_RX, C_UART_START_BYTE, "Check data from UART RX");


Activity Watchdog
==================================================================================================================================
.. include:: rst_snippets/vip_activity_watchdog.rst


Transaction Info
==================================================================================================================================
.. include:: rst_snippets/vip_transaction_info.rst

.. table:: Wishbone transaction info record fields. Transaction Type: t_base_transaction (BT) - accessible via **shared_wishbone_vvc_transaction_info.bt**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | addr                         | unsigned(63 downto 0)        | 0x0             | Address of the Wishbone read/write transaction  |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | data                         | std_logic_vector(1023 downto | 0x0             | Data for Wishbone read or write transaction     |
    |                              | 0)                           |                 |                                                 |
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
i.e. wishbone_read(). Note that the data is only stored in the scoreboard and not accessible with the fetch_result() method when 
the TO_SB parameter is applied. The Wishbone scoreboard is accessible from the testbench as a shared variable WISHBONE_VVC_SB, 
located in the vvc_methods_pkg.vhd, e.g. ::

    WISHBONE_VVC_SB.add_expected(C_WISHBONE_VVC_IDX, pad_wishbone_sb(v_expected), "Adding expected");

The Wishbone scoreboard is per default a 1024 bits wide standard logic vector. When sending expected data to the scoreboard, where 
the data width is smaller than the default scoreboard width, we recommend zero-padding the data with the pad_wishbone_sb() 
function, e.g. ::

    WISHBONE_VVC_SB.add_expected(<Wishbone VVC instance number>, pad_wishbone_sb(<exp data>));

See the :ref:`vip_scoreboard` for a complete list of available commands and additional information. All of the listed Generic
Scoreboard commands are available for the Wishbone VVC scoreboard using the WISHBONE_VVC_SB.


Unwanted Activity Detection
==================================================================================================================================
.. include:: rst_snippets/vip_unwanted_activity.rst

.. code-block::

    shared_wishbone_vvc_config(C_VVC_INDEX).unwanted_activity_severity := NO_ALERT;

For Wishbone VVC, the unwanted activity detection is enabled by default with severity ERROR.

More information can be found in :ref:`Essential Mechanisms - Unwanted Activity Detection <vvc_framework_unwanted_activity>`.


Compilation
==================================================================================================================================
The Wishbone VVC must be compiled with VHDL-2008 or newer. It is dependent on the following libraries:

    * UVVM Utility Library (UVVM-Util)
    * UVVM VVC Framework
    * Bitvis VIP Scoreboard
    * Wishbone BFM

Before compiling the Wishbone VVC, assure that uvvm_util, uvvm_vvc_framework and bitvis_vip_scoreboard have been compiled.

See :ref:`Essential Mechanisms - Compile Scripts <vvc_framework_compile_scripts>` for information about compile scripts.

.. table:: Compile order for the Wishbone VVC

    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | Compile to library           | File                                           | Comment                                         |
    +==============================+================================================+=================================================+
    | bitvis_vip_wishbone          | wishbone_bfm_pkg.vhd                           | Wishbone BFM                                    |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_wishbone          | transaction_pkg.vhd                            | Wishbone transaction package with DTT types,    |
    |                              |                                                | constants, etc.                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_wishbone          | vvc_cmd_pkg.vhd                                | Wishbone VVC command types and operations       |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_wishbone          | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC target support package, compiled into  |
    |                              | _target_support_pkg.vhd                        | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_wishbone          | ../uvvm_vvc_framework/src_target_dependent/td\ | Common UVVM framework methods compiled into the |
    |                              | _vvc_framework_common_methods_pkg.vhd          | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_wishbone          | vvc_sb_pkg.vhd                                 | Wishbone VVC scoreboard                         |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_wishbone          | vvc_methods_pkg.vhd                            | Wishbone VVC methods                            |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_wishbone          | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM queue package for this VVC                 |
    |                              | _queue_pkg.vhd                                 |                                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_wishbone          | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC entity support compiled into this      |
    |                              | _vvc_entity_support_pkg.vhd                    | VVC library                                     |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_wishbone          | wishbone_vvc.vhd                               | Wishbone VVC                                    |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_wishbone          | vvc_context.vhd                                | Wishbone VVC context file                       |
    +------------------------------+------------------------------------------------+-------------------------------------------------+

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


Additional Documentation
==================================================================================================================================

.. important::

    * This is a simplified Verification IP (VIP) for Wishbone.
    * The given VIP complies with the basic Wishbone protocol and thus allows a normal access towards a Wishbone interface.
    * This VIP is not a Wishbone protocol checker.
    * For a more advanced VIP please contact UVVM support at info@uvvm.org

.. include:: rst_snippets/ip_disclaimer.rst
