##################################################################################################################################
Bitvis VIP AXI4-Lite
##################################################################################################################################

**Quick Access**

* `BFM`_

  * :ref:`axilite_write_bfm`
  * :ref:`axilite_read_bfm`
  * :ref:`axilite_check_bfm`
  * :ref:`init_axilite_if_signals_bfm`

* `VVC`_

  * :ref:`axilite_write_vvc`
  * :ref:`axilite_read_vvc`
  * :ref:`axilite_check_vvc`


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
BFM
**********************************************************************************************************************************
BFM functionality is implemented in axilite_bfm_pkg.vhd

.. _t_axilite_if:

Signal Record
==================================================================================================================================
**t_axilite_if**

+-------------------------+-----------------------------------------+
| Record element          | Type                                    |
+=========================+=========================================+
| write_address_channel   | `t_axilite_write_address_channel`_      |
+-------------------------+-----------------------------------------+
| write_data_channel      | `t_axilite_write_data_channel`_         |
+-------------------------+-----------------------------------------+
| write_response_channel  | `t_axilite_write_response_channel`_     |
+-------------------------+-----------------------------------------+
| read_address_channel    | `t_axilite_read_address_channel`_       |
+-------------------------+-----------------------------------------+
| read_data_channel       | `t_axilite_read_data_channel`_          |
+-------------------------+-----------------------------------------+

.. note::

    * For more information on the AXI4-Lite signals, refer to "AMBA® AXI™ and ACE™ Protocol Specification", Part B (ARM IHI 0022G), 
      available from ARM.

.. _t_axilite_bfm_config:

Configuration Record
==================================================================================================================================
**t_axilite_bfm_config**

Default value for the record is C_AXILITE_BFM_CONFIG_DEFAULT.

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| max_wait_cycles              | natural                      | 10              | The maximum number of clock cycles to wait for  |
|                              |                              |                 | the DUT ready or valid signals before reporting |
|                              |                              |                 | a timeout alert                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| max_wait_cycles_severity     | :ref:`t_alert_level`         | TB_FAILURE      | The above timeout will have this severity       |
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
| expected_response            | `t_xresp`_                   | OKAY            | Sets the expected response for both read and    |
|                              |                              |                 | write transactions                              |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| expected_response_severity   | :ref:`t_alert_level`         | TB_FAILURE      | A response mismatch will have this severity     |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| protection_setting           | `t_axprot`_                  | UNPRIVILEGED_NO\| Sets the access permissions (e.g. write to      |
|                              |                              | NSECURE_DATA    | data/instruction, privileged and secure access) |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| num_aw_pipe_stages           | natural                      | 1               | Write Address Channel pipeline steps            |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| num_w_pipe_stages            | natural                      | 1               | Write Data Channel pipeline steps               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| num_ar_pipe_stages           | natural                      | 1               | Read Address Channel pipeline steps             |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| num_r_pipe_stages            | natural                      | 1               | Read Data Channel pipeline steps                |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| num_b_pipe_stages            | natural                      | 1               | Response Channel pipeline steps                 |
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

.. note::

    The AXI4-Lite BFM procedures do not access the AXI channels independently. However, this is sufficient for most use cases. If 
    independent channel access is required, for instance simultaneous read and write accesses, use the `VVC`_.

.. _axilite_write_bfm:

axilite_write()
----------------------------------------------------------------------------------------------------------------------------------
Writes the given data to the given address of the DUT, using the AXI4-Lite protocol. For protocol details, see the AXI4-Lite specification.
If the byte_enable argument is not used, it will be set to all '1', i.e. all bytes are used.

The procedure reports an alert if:

  * Data length is neither 32 bit nor 64 bit (alert level: TB_ERROR)
  * wready does not occur within max_wait_cycles clock cycles (alert level: max_wait_cycles_severity, set in the config)
  * awready does not occur within max_wait_cycles clock cycles (alert level: max_wait_cycles_severity, set in the config)
  * bresp is not set to expected_response (set in the config) when bvalid is set to '1' (alert level: expected_response_severity, set in the config)
  * bvalid is not set within max_wait_cycles clock cycles (alert level: max_wait_cycles_severity, set in the config)

.. code-block::

    axilite_write(addr_value, data_value, [byte_enable,] msg, clk, axilite_if, [scope, [msg_id_panel, [config]]]) 

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | The address of an AXI4-Lite accessible register         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_value         | in     | std_logic_vector             | The data value to be written to the addressed register  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | byte_enable        | in     | std_logic_vector             | This argument selects which bytes to use (all '1' means |
|          |                    |        |                              | all bytes are updated)                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the AXI4-Lite BFM                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | axilite_if         | inout  | :ref:`t_axilite_if           | AXI4-Lite signal interface record                       |
|          |                    |        | <t_axilite_if>`              |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AXILITE_BFM").           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_axilite_bfm_config   | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_axilite_bfm_config>`      | value is C_AXILITE_BFM_CONFIG_DEFAULT.                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    axilite_write(x"00101155", x"AAAA", "Writing data to Peripheral 1", clk, axilite_if, C_SCOPE, shared_msg_id_panel, C_AXILITE_BFM_CONFIG_DEFAULT); 
    axilite_write(C_ADDR_PERIPHERAL_1, x"00F1", "01", "Writing first byte to Peripheral 1", clk, axilite_if, C_SCOPE, shared_msg_id_panel, C_AXILITE_BFM_CONFIG_DEFAULT); 

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    axilite_write(C_ADDR_DMA, x"AAAA", "Writing data to DMA");


.. _axilite_read_bfm:

axilite_read()
----------------------------------------------------------------------------------------------------------------------------------
Reads data from the DUT at the given address, using the AXI4-Lite protocol. For protocol details, see the AXI4-Lite specification. 
The read data is placed on the output 'data_value' when the read has completed.

The procedure reports an alert if:

  * The read data length (rdata) is neither 32 bit nor 64 bit (alert level: TB_ERROR)
  * arready does not occur within max_wait_cycles clock cycles (alert level: max_wait_cycles_severity, set in the config)
  * rresp is not set to expected_response (set in the config) when rvalid is set to '1' (alert level: expected_response_severity, set in the config)
  * rvalid is not set within max_wait_cycles clock cycles (alert level: max_wait_cycles_severity, set in the config)

.. code-block::

    axilite_read(addr_value, data_value, msg, clk, axilite_if, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | The address of an AXI4-Lite accessible register         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | data_value         | out    | std_logic_vector             | The data value to be read from the addressed register   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the AXI4-Lite BFM                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | axilite_if         | inout  | :ref:`t_axilite_if           | AXI4-Lite signal interface record                       |
|          |                    |        | <t_axilite_if>`              |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AXILITE_BFM").           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_axilite_bfm_config   | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_axilite_bfm_config>`      | value is C_AXILITE_BFM_CONFIG_DEFAULT.                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    axilite_read(C_ADDR_PERIPHERAL_1, v_data_out, "Read from Peripheral 1", clk, axilite_if, C_SCOPE, shared_msg_id_panel, C_AXILITE_BFM_CONFIG_DEFAULT); 

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    axilite_read(C_ADDR_IO, v_data_out, "Reading from IO device");


.. _axilite_check_bfm:

axilite_check()
----------------------------------------------------------------------------------------------------------------------------------
Reads data from the DUT at the given address, using the AXI4-Lite protocol. For protocol details, see the AXI4-Lite specification. 
After reading data from the AXI4-Lite bus, the read data is compared with the expected data, and if they don't match, an alert with 
severity 'alert_level' is reported. The procedure also report alerts for the same conditions as the :ref:`axilite_read_bfm` procedure.

.. code-block::

    axilite_check(addr_value, data_exp, msg, clk, axilite_if, [alert_level, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | The address of an AXI4-Lite accessible register         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_logic_vector             | The data value to expect when reading the addressed     |
|          |                    |        |                              | register                                                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the AXI4-Lite BFM                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | axilite_if         | inout  | :ref:`t_axilite_if           | AXI4-Lite signal interface record                       |
|          |                    |        | <t_axilite_if>`              |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AXILITE_BFM").           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_axilite_bfm_config   | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_axilite_bfm_config>`      | value is C_AXILITE_BFM_CONFIG_DEFAULT.                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    axilite_check(C_ADDR_PERIPHERAL_1, x"3B", "Check data from Peripheral 1", clk, axilite_if, C_SCOPE, shared_msg_id_panel, ERROR, C_AXILITE_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    axilite_check(C_ADDR_UART_RX, x"3B", "Checking data in UART RX register");


.. _init_axilite_if_signals_bfm:

init_axilite_if_signals()
----------------------------------------------------------------------------------------------------------------------------------
Initializes the AXI4-Lite interface. All the BFM outputs are set to '0', and BFM inputs are set to 'Z'. awprot and arprot are set 
to UNPRIVILEGED_NONSECURE_DATA ("010").

.. code-block::

    t_axilite_if := init_axilite_if_signals(addr_width, data_width)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_width         | in     | natural                      | Width of the address signals                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_width         | in     | natural                      | Width of the data signals                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    axilite_if <= init_axilite_if_signals(addr_width, data_width);


Local types
==================================================================================================================================

t_axilite_write_address_channel
----------------------------------------------------------------------------------------------------------------------------------

+-------------------------+------------------------------+
| Record element          | Type                         |
+=========================+==============================+
| awaddr                  | std_logic_vector             |
+-------------------------+------------------------------+
| awvalid                 | std_logic                    |
+-------------------------+------------------------------+
| awprot                  | std_logic_vector(2 downto 0) |
+-------------------------+------------------------------+
| awready                 | std_logic                    |
+-------------------------+------------------------------+

t_axilite_write_data_channel
----------------------------------------------------------------------------------------------------------------------------------

+-------------------------+------------------------------+
| Record element          | Type                         |
+=========================+==============================+
| wdata                   | std_logic_vector             |
+-------------------------+------------------------------+
| wstrb                   | std_logic_vector             |
+-------------------------+------------------------------+
| wvalid                  | std_logic                    |
+-------------------------+------------------------------+
| wready                  | std_logic                    |
+-------------------------+------------------------------+

t_axilite_write_response_channel
----------------------------------------------------------------------------------------------------------------------------------

+-------------------------+------------------------------+
| Record element          | Type                         |
+=========================+==============================+
| bready                  | std_logic                    |
+-------------------------+------------------------------+
| bresp                   | std_logic_vector(1 downto 0) |
+-------------------------+------------------------------+
| bvalid                  | std_logic                    |
+-------------------------+------------------------------+

t_axilite_read_address_channel
----------------------------------------------------------------------------------------------------------------------------------

+-------------------------+------------------------------+
| Record element          | Type                         |
+=========================+==============================+
| araddr                  | std_logic_vector             |
+-------------------------+------------------------------+
| arvalid                 | std_logic                    |
+-------------------------+------------------------------+
| arprot                  | std_logic_vector(2 downto 0) |
+-------------------------+------------------------------+
| arready                 | std_logic                    |
+-------------------------+------------------------------+

t_axilite_read_data_channel
----------------------------------------------------------------------------------------------------------------------------------

+-------------------------+------------------------------+
| Record element          | Type                         |
+=========================+==============================+
| rready                  | std_logic                    |
+-------------------------+------------------------------+
| rdata                   | std_logic_vector             |
+-------------------------+------------------------------+
| rresp                   | std_logic_vector(1 downto 0) |
+-------------------------+------------------------------+
| rvalid                  | std_logic                    |
+-------------------------+------------------------------+

t_axprot
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    UNPRIVILEGED_NONSECURE_DATA, UNPRIVILEGED_NONSECURE_INSTRUCTION, UNPRIVILEGED_SECURE_DATA, UNPRIVILEGED_SECURE_INSTRUCTION, 
    PRIVILEGED_NONSECURE_DATA, PRIVILEGED_NONSECURE_INSTRUCTION, PRIVILEGED_SECURE_DATA, PRIVILEGED_SECURE_INSTRUCTION

t_xresp
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    OKAY, SLVERR, DECERR, ILLEGAL


Local BFM overloads
==================================================================================================================================
A good approach for better readability and maintainability is to make simple, local overloads for the BFM procedures in the TB 
process. This allows calling the BFM procedures with the key parameters only, e.g. ::

    axilite_write(C_ADDR_PERIPHERAL_1, C_TEST_DATA, "Sending data to Peripheral 1");

rather than ::

    axilite_write(C_ADDR_PERIPHERAL_1, C_TEST_DATA, "Sending data to Peripheral 1", clk, axilite_if, C_SCOPE, shared_msg_id_panel, C_AXILITE_BFM_CONFIG_DEFAULT); 

By defining the local overload as e.g. ::

    procedure axilite_write(
      constant addr_value   : in unsigned;           
      constant data_value   : in std_logic_vector;
      constant msg          : in string
    ) is
    begin
      axilite_write(
        addr_value,                  -- Keep as is
        data_value,                  -- Keep as is
        msg,                         -- Keep as is
        clk,                         -- Signal must be visible in local process scope
        axilite_if,                  -- Signal must be visible in local process scope 
        C_SCOPE,                     -- Setting a default value
        shared_msg_id_panel,         -- Use global, shared msg_id_panel
        C_AXILITE_BFM_CONFIG_LOCAL); -- Use locally defined configuration or C_AXILITE_BFM_CONFIG_DEFAULT
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
For more information on the AXI4-Lite specification, refer to "AMBA® AXI™ and ACE™ Protocol Specification", Part B (ARM IHI 0022G), 
available from ARM.

.. important::

    * This is a simplified Bus Functional Model (BFM) for AXI4-Lite.
    * The given BFM complies with the basic AXI4-Lite protocol and thus allows a normal access towards an AXI4-Lite interface.
    * This BFM is not an AXI4-Lite protocol checker.
    * For a more advanced BFM please contact UVVM support at info@uvvm.org


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
VVC
**********************************************************************************************************************************
* VVC functionality is implemented in axilite_vvc.vhd
* For general information see :ref:`VVC Framework - Essential Mechanisms <vvc_framework_essential_mechanisms>`.

Entity
==================================================================================================================================

Generics
----------------------------------------------------------------------------------------------------------------------------------

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Name                         | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| GC_ADDR_WIDTH                | integer                      | 8               | Width of the AXI4-Lite address bus              |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_DATA_WIDTH                | integer                      | 32              | Width of the AXI4-Lite data bus                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_INSTANCE_IDX              | natural                      | 1               | Instance number to assign the VVC               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_AXILITE_CONFIG            | :ref:`t_axilite_bfm_config   | C_AXILITE_BFM_C\| Configuration for the AXI4-Lite BFM             |
|                              | <t_axilite_bfm_config>`      | ONFIG_DEFAULT   |                                                 |
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
| signal   | clk                | in     | std_logic                    | VVC Clock signal                                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | axilite_vvc_master\| inout  | :ref:`t_axilite_if           | AXI4-Lite signal interface record                       |
|          | _if                |        | <t_axilite_if>`              |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

In this VVC, the interface has been encapsulated in a signal record of type t_axilite_if in order to improve readability of the code. 
Since the AXI4-Lite interface buses can be of arbitrary size, the interface vectors have been left unconstrained. These unconstrained 
vectors need to be constrained when the interface signals are instantiated. For this interface, it could look like: ::

    signal axilite_if : t_axilite_if(write_address_channel(awaddr(C_ADDR_WIDTH    -1 downto 0)),
                                     write_data_channel   (wdata (C_DATA_WIDTH    -1 downto 0),
                                                           wstrb ((C_DATA_WIDTH/8)-1 downto 0)),
                                     read_address_channel (araddr(C_ADDR_WIDTH    -1 downto 0)),
                                     read_data_channel    (rdata (C_DATA_WIDTH    -1 downto 0)));


Configuration Record
==================================================================================================================================
**vvc_config** accessible via **shared_axilite_vvc_config**

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| inter_bfm_delay              | :ref:`t_inter_bfm_delay`     | C_AXILITE_INTER\| Delay between any requested BFM accesses        |
|                              |                              | _BFM_DELAY_DEFA\| towards the DUT.                                |
|                              |                              | ULT             |                                                 |
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
| bfm_config                   | :ref:`t_axilite_bfm_config   | C_AXILITE_BFM_C\| Configuration for the AXI4-Lite BFM             |
|                              | <t_axilite_bfm_config>`      | ONFIG_DEFAULT   |                                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| msg_id_panel                 | t_msg_id_panel               | C_VVC_MSG_ID_PA\| VVC dedicated message ID panel. See             |
|                              |                              | NEL_DEFAULT     | :ref:`vvc_framework_verbosity_ctrl` for how to  |
|                              |                              |                 | use verbosity control.                          |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| force_single_pending_transac/| boolean                      | false           | Waits until the previous transaction is         |
| tion                         |                              |                 | completed before starting the next one          |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| unwanted_activity_severity   | :ref:`t_alert_level`         | C_UNWANTED_ACTI\| Severity of alert to be issued if unwanted      |
|                              |                              | VITY_SEVERITY   | activity on the DUT outputs is detected. It is  |
|                              |                              |                 | enabled with ERROR severity by default.         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

.. note::

    cmd/result queue parameters in the configuration record are unused and will be removed in v3.0, use instead the entity generic constants.

The configuration record can be accessed from the Central Testbench Sequencer through the shared variable array, e.g. ::

    shared_axilite_vvc_config(C_VVC_IDX).inter_bfm_delay.delay_in_time := 50 ns;
    shared_axilite_vvc_config(C_VVC_IDX).bfm_config.clock_period := 10 ns;

Status Record
==================================================================================================================================
**vvc_status** accessible via **shared_axilite_vvc_status**

.. include:: rst_snippets/vip_vvc_status.rst

Methods
==================================================================================================================================
* All VVC procedures are defined in vvc_methods_pkg.vhd (dedicated to this VVC).
* See :ref:`vvc_framework_methods` for procedures which are common to all VVCs.
* It is also possible to send a multicast to all instances of a VVC with ALL_INSTANCES as parameter for vvc_instance_idx.
* All parameters in brackets are optional.


.. _axilite_write_vvc:

axilite_write()
----------------------------------------------------------------------------------------------------------------------------------
Adds a write command to the AXI4-Lite VVC executor queue, which will distribute this command to the various channel executors which 
in turn will run as soon as all preceding commands have completed. When the command is scheduled to run, the executors call the 
AXI4-Lite procedures in axilite_channel_handler_pkg.vhd. This procedure can be called with or without byte_enable constant. When 
not set, byte_enable is set to all '1', indicating that all bytes are valid. 

.. code-block::

    axilite_write(VVCT, vvc_instance_idx, addr, data, [byte_enable,] msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | addr               | in     | unsigned                     | The address of an AXI4-Lite accessible register         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The data value to be written to the addressed register  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | byte_enable        | in     | std_logic_vector             | This argument selects which bytes to use (all '1' means |
|          |                    |        |                              | all bytes are updated)                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    axilite_write(AXILITE_VVCT, 0, x"0011A000", x"F102", "Writing data to Peripheral 1", C_SCOPE);
    axilite_write(AXILITE_VVCT, 0, C_ADDR_PERIPHERAL_1, x"F102", b"11", "Writing data to Peripheral 1", C_SCOPE);
    axilite_write(AXILITE_VVCT, 0, C_ADDR_DMA, x"1155F102", "Writing data to DMA", C_SCOPE);


.. _axilite_read_vvc:

axilite_read()
----------------------------------------------------------------------------------------------------------------------------------
Adds a read command to the AXI4-Lite VVC executor queue, which will distribute this command to the various channel executors which 
in turn will run as soon as all preceding commands have completed. When the command is scheduled to run, the executors call the 
AXI4-Lite procedures in axilite_channel_handler_pkg.vhd.

The value read from DUT will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but the read 
data will be stored in the VVC for a potential future fetch (see example with fetch_result below). 
If the data_routing is set to TO_SB, the read data will be sent to the AXI4-Lite VVC dedicated scoreboard where it will be 
checked against the expected value (provided by the testbench).

.. code-block::

    axilite_read(VVCT, vvc_instance_idx, addr, [data_routing,] msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | addr               | in     | unsigned                     | The address of an AXI4-Lite accessible register         |
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
    axilite_read(AXILITE_VVCT, 0, x"00099555", "Read from Peripheral 1", C_SCOPE);
    axilite_read(AXILITE_VVCT, 0, C_ADDR_IO, "Read from IO device", C_SCOPE);

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx         : natural;                       -- Command index for the last read
    variable v_result          : work.vvc_cmd_pkg.t_vvc_result; -- Result from read
    ...
    axilite_read(AXILITE_VVCT, 0, x"112252AA", "Read from Peripheral 1");
    v_cmd_idx := get_last_received_cmd_idx(AXILITE_VVCT, 0);               
    await_completion(AXILITE_VVCT, 0, v_cmd_idx, 100 ns, "Wait for read to finish");
    fetch_result(AXILITE_VVCT, 0, v_cmd_idx, v_result, "Fetching result from read operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.


.. _axilite_check_vvc:

axilite_check()
----------------------------------------------------------------------------------------------------------------------------------
Adds a check command to the AXI4-Lite VVC executor queue, which will distribute this command to the various channel executors which 
in turn will run as soon as all preceding commands have completed. When the command is scheduled to run, the executors call the 
AXI4-lite procedures in axilite_channel_handler_pkg.vhd. The axilite_check() procedure will perform a read operation, then check 
if the read data is equal to the 'data' parameter. If the read data is not equal to the expected data, an alert with severity 
'alert_level' will be issued. The read data will not be stored by this procedure.

.. code-block::

    axilite_check(VVCT, vvc_instance_idx, addr, data, msg, [alert_level, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | addr               | in     | unsigned                     | The address of an AXI4-Lite accessible register         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The data value to expect when reading the addressed     |
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
    axilite_check(AXILITE_VVCT, 0, x"00099555", x"393B", "Check data from Peripheral 1", ERROR, C_SCOPE);


Activity Watchdog
==================================================================================================================================
.. include:: rst_snippets/vip_activity_watchdog.rst


Transaction Info
==================================================================================================================================
.. include:: rst_snippets/vip_transaction_info.rst

.. table:: AXI4-Lite transaction info record fields. Transaction Type: t_base_transaction (BT) - accessible via **shared_axilite_vvc_transaction_info.bt_wr** and
           **shared_axilite_vvc_transaction_info.bt_rd**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
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

.. table:: AXI4-Lite transaction info record fields. Transaction type: t_arw_transaction (ST) - accessible via **shared_axilite_vvc_transaction_info.st_aw** and
           **shared_axilite_vvc_transaction_info.st_ar**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | arwaddr                      | unsigned(31 downto 0)        | 0x0             | The address for a read or write transaction     |
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

.. table:: AXI4-Lite transaction info record fields. Transaction type: t_w_transaction (ST) - accessible via **shared_axilite_vvc_transaction_info.st_w**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | wdata                        | std_logic_vector(255 downto  | 0x0             | Write data                                      |
    |                              | 0)                           |                 |                                                 |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | wstrb                        | std_logic_vector(31 downto 0)| 0x0             | Write strobe                                    |
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

.. table:: AXI4-Lite transaction info record fields. Transaction type: t_b_transaction (ST) - accessible via **shared_axilite_vvc_transaction_info.st_b**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
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

.. table:: AXI4-Lite transaction info record fields. Transaction type: t_r_transaction (ST) - accessible via **shared_axilite_vvc_transaction_info.st_r**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | rdata                        | std_logic_vector(255 downto  | 0x0             | Read data                                       |
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
i.e. axilite_read(). Note that the data is only stored in the scoreboard and not accessible with the fetch_result() method when the 
TO_SB parameter is applied. The AXI4-Lite scoreboard is accessible from the testbench as a shared variable AXILITE_VVC_SB, located 
in the vvc_methods_pkg.vhd, e.g. ::

    AXILITE_VVC_SB.add_expected(C_AXILITE_VVC_IDX, pad_axilite_sb(v_expected), "Adding expected");

The AXI4-Lite scoreboard is per default 256 bits wide standard logic vector. When sending expected result to the scoreboard, where 
the result width is smaller than the default scoreboard width, we recommend zero-padding the data with the pad_axilite_sb() 
function, e.g. ::

    AXILITE_VVC_SB.add_expected(<AXI-Lite VVC instance number>, pad_axilite_sb(<exp data>));

See the :ref:`vip_scoreboard` for a complete list of available commands and additional information. All of the listed Generic
Scoreboard commands are available for the AXI4-Lite VVC scoreboard using the AXILITE_VVC_SB.


Unwanted Activity Detection
==================================================================================================================================
.. include:: rst_snippets/vip_unwanted_activity.rst

.. code-block::

    shared_axilite_vvc_config(C_VVC_INDEX).unwanted_activity_severity := NO_ALERT;

Note that the ready signals (awready, wready, arready) are not monitored in this VVC. The ready signals are allowed to be set 
independently of the valid signals (awvalid, wvalid, arvalid), and there is no method to differentiate between the unwanted activity 
and intended activity. See the AXI4-Lite protocol specification for more information. 

The unwanted activity detection is ignored when the valid signals (bvalid, rvalid) go low within one clock period after the VVC 
becomes inactive. This is to handle the situation when the read command exits before the next rising edge, causing signal transitions 
during the first clock cycle after the VVC is inactive. 

For AXI4-Lite VVC, the unwanted activity detection feature is enabled by default with severity ERROR.

More information can be found in :ref:`Essential Mechanisms - Unwanted Activity Detection <vvc_framework_unwanted_activity>`.


Compilation
==================================================================================================================================
The AXI4-Lite VVC must be compiled with VHDL-2008 or newer. It is dependent on the following libraries:

    * UVVM Utility Library (UVVM-Util)
    * UVVM VVC Framework
    * Bitvis VIP Scoreboard
    * AXI4-Lite BFM

Before compiling the AXI4-Lite VVC, assure that uvvm_util, uvvm_vvc_framework and bitvis_vip_scoreboard have been compiled.

See :ref:`Essential Mechanisms - Compile Scripts <vvc_framework_compile_scripts>` for information about compile scripts.

.. table:: Compile order for the AXI4-Lite VVC

    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | Compile to library           | File                                           | Comment                                         |
    +==============================+================================================+=================================================+
    | bitvis_vip_axilite           | axilite_bfm_pkg.vhd                            | AXI4-Lite BFM                                   |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axilite           | transaction_pkg.vhd                            | AXI4-Lite transaction package with DTT types,   |
    |                              |                                                | constants, etc.                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axilite           | vvc_cmd_pkg.vhd                                | AXI4-Lite VVC command types and operations      |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axilite           | axilite_channel_handler_pkg.vhd                | Package containing procedures for accessing     |
    |                              |                                                | AXI4-Lite channels. Only for use by the VVC.    |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axilite           | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC target support package, compiled into  |
    |                              | _target_support_pkg.vhd                        | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axilite           | ../uvvm_vvc_framework/src_target_dependent/td\ | Common UVVM framework methods compiled into the |
    |                              | _vvc_framework_common_methods_pkg.vhd          | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axilite           | vvc_sb_pkg.vhd                                 | AXI4-Lite VVC scoreboard                        |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axilite           | vvc_methods_pkg.vhd                            | AXI4-Lite VVC methods                           |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axilite           | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM queue package for this VVC                 |
    |                              | _queue_pkg.vhd                                 |                                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axilite           | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC entity support compiled into this      |
    |                              | _vvc_entity_support_pkg.vhd                    | VVC library                                     |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axilite           | axilite_vvc.vhd                                | AXI4-Lite VVC                                   |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axilite           | vvc_context.vhd                                | AXI4-Lite VVC context file                      |
    +------------------------------+------------------------------------------------+-------------------------------------------------+

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


Additional Documentation
==================================================================================================================================
For more information on the AXI4-Lite specification, refer to "AMBA® AXI™ and ACE™ Protocol Specification", Part B (ARM IHI 0022G), 
available from ARM.

.. important::

    * This is a simplified Verification IP (VIP) for AXI4-Lite.
    * The given VIP complies with the basic AXI4-Lite protocol and thus allows a normal access towards an AXI4-Lite interface.
    * This VIP is not an AXI4-Lite protocol checker.
    * For a more advanced VIP please contact UVVM support at info@uvvm.org

.. include:: rst_snippets/ip_disclaimer.rst
