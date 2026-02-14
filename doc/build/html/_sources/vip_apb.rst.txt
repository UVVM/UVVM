##################################################################################################################################
External VIP APB
##################################################################################################################################

**Quick Access**

* `BFM`_

  * :ref:`apb_write_bfm`
  * :ref:`apb_read_bfm`
  * :ref:`apb_check_bfm`
  * :ref:`apb_poll_until_bfm`
  * :ref:`init_apb_if_signals_bfm`

* `VVC`_

  * :ref:`apb_write_vvc`
  * :ref:`apb_read_vvc`
  * :ref:`apb_check_vvc`
  * :ref:`apb_poll_until_vvc`


**********************************************************************************************************************************
BFM
**********************************************************************************************************************************
BFM functionality is implemented in apb_bfm_pkg.vhd

.. _t_apb_if:

Signal Record
==================================================================================================================================
**t_apb_if**

+-------------------------+------------------------------+
| Record element          | Type                         |
+=========================+==============================+
| pclk                    | std_logic                    |
+-------------------------+------------------------------+
| paddr                   | std_logic_vector             |
+-------------------------+------------------------------+
| pprot                   | std_logic_vector(2 downto 0) |
+-------------------------+------------------------------+
| psel                    | std_logic                    |
+-------------------------+------------------------------+
| penable                 | std_logic                    |
+-------------------------+------------------------------+
| pwrite                  | std_logic                    |
+-------------------------+------------------------------+
| pwdata                  | std_logic_vector             |
+-------------------------+------------------------------+
| pstrb                   | std_logic_vector             |
+-------------------------+------------------------------+
| prdata                  | std_logic_vector             |
+-------------------------+------------------------------+
| pready                  | std_logic                    |
+-------------------------+------------------------------+
| pslverr                 | std_logic                    |
+-------------------------+------------------------------+

.. note::

    BFM calls can also be made with listing of single signals rather than t_apb_if.

.. _t_apb_bfm_config:

Configuration Record
==================================================================================================================================
**t_apb_bfm_config**

Default value for the record is C_APB_BFM_CONFIG_DEFAULT.

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| max_wait_cycles              | natural                      | 1000            | The maximum number of clock cycles to wait for  |
|                              |                              |                 | the DUT ready signal before reporting a timeout |
|                              |                              |                 | alert                                           |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| max_wait_cycles_severity     | :ref:`t_alert_level`         | FAILURE         | The above timeout will have this severity       |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| clock_period                 | time                         | C_UNDEFINED_TIME| Period of the clock signal                      |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| clock_period_margin          | time                         | 0 ns            | Input clock period margin to specified          |
|                              |                              |                 | clock_period. Will check 'T/2' if input clock is|
|                              |                              |                 | low when BFM is called and 'T' if input clock is|
|                              |                              |                 | high.                                           |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| clock_margin_severity        | :ref:`t_alert_level`         | TB_ERROR        | The above margin will have this severity        |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| setup_time                   | time                         | C_UNDEFINED_TIME| Generated signals setup time. Suggested value   |
|                              |                              |                 | is clock_period/4. An alert is reported if      |
|                              |                              |                 | setup_time exceeds clock_period/2.              |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| hold_time                    | time                         | C_UNDEFINED_TIME| Generated signals hold time. Suggested value    |
|                              |                              |                 | is clock_period/4. An alert is reported if      |
|                              |                              |                 | hold_time exceeds clock_period/2.               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| bfm_sync                     | :ref:`t_bfm_sync`            | SYNC_ON_CLOCK_O\| When set to SYNC_ON_CLOCK_ONLY the BFM will     |
|                              |                              | NLY             | always wait for the first falling edge of the   |
|                              |                              |                 | clock.                                          |
|                              |                              |                 |                                                 |
|                              |                              |                 | Then the interface output signals will be       |
|                              |                              |                 | set up immediately. After that, the BFM will    |
|                              |                              |                 | wait for the rising edge of the clock,          |
|                              |                              |                 |                                                 |
|                              |                              |                 | sample or set relevant interface signals (if    |
|                              |                              |                 | any), and estimate the clock period.            |
|                              |                              |                 |                                                 |
|                              |                              |                 | The BFM will deactivate potential interface     |
|                              |                              |                 | output signals and exit ¼ clock period after a  |
|                              |                              |                 | succeeding rising edge.                         |
|                              |                              |                 |                                                 |
|                              |                              |                 | When set to SYNC_WITH_SETUP_AND_HOLD the BFM    |
|                              |                              |                 | will always wait for the configured setup time  |
|                              |                              |                 | before the first rising edge of the clock.      |
|                              |                              |                 |                                                 |
|                              |                              |                 | Then the interface output signals will be set up|
|                              |                              |                 | immediately. After that, the BFM will wait for  |
|                              |                              |                 | the rising edge of the clock,                   |
|                              |                              |                 |                                                 |
|                              |                              |                 | and sample or set relevant interface signals (if|
|                              |                              |                 | any). Note that the clock period needs to be    |
|                              |                              |                 | configured in this mode.                        |
|                              |                              |                 |                                                 |
|                              |                              |                 | The BFM will deactivate potential interface     |
|                              |                              |                 | output signals and exit after the configured    |
|                              |                              |                 | hold time after a succeeding rising edge.       |
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
| id_for_bfm                   | :ref:`t_msg_id <message_ids>`| ID_BFM          | Message ID used for logging general messages in |
|                              |                              |                 | the BFM                                         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| id_for_bfm_wait              | :ref:`t_msg_id <message_ids>`| ID_BFM_WAIT     | Message ID used for logging waits in the BFM    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

Methods
==================================================================================================================================
* The record :ref:`t_apb_if <t_apb_if>` can be replaced with the signals listed in said record.
* All signals are active high.
* All parameters in brackets are optional.


.. _apb_write_bfm:

apb_write()
----------------------------------------------------------------------------------------------------------------------------------
Writes the given data to the given address on the DUT, using the APB protocol:

.. code-block:: none

    1. During the setup phase:
        a. paddr is set to addr_value
        b. pwdata is set to data_value
        c. pprot is set to protection
        d. pstrb is set to byte_enable
        e. psel is set to '1'
        f. pwrite is set to '1'
        g. penable is set to '0'
    2. During the access phase:
        a. penable is set to '1'
        b. the BFM waits for pready to be '1'
    3. Before exiting the procedure:
        e. psel is set to '0'
        g. penable is set to '0'

The procedure reports an alert if pready signal is not set to '1' within 'config.max_wait_cycles' after penable is set to '1'
(alert_level: config.max_wait_cycles_severity).

.. code-block::

    apb_write(addr_value, data_value, byte_enable, protection, msg, apb_if, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | The memory address of the peripheral being accessed     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_value         | in     | std_logic_vector             | The data value to be written to the memory address      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | byte_enable        | in     | std_logic_vector             | Each bit indicates which byte in data_value is valid    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | protection         | in     | std_logic_vector(2 downto 0) | Indicates normal, privileged or secure protection levels|
|          |                    |        |                              | and whether it's a data or instruction access           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | apb_if             | inout  | :ref:`t_apb_if <t_apb_if>`   | APB signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("APB BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_apb_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_apb_bfm_config>`          | value is C_APB_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    apb_write(x"1000", x"AA55", "1111", "000", "Write data to Peripheral 1", apb_if);
    apb_write(x"1000", x"AA55", "1111", "000", "Write data to Peripheral 1", apb_if, C_SCOPE, shared_msg_id_panel, C_APB_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    apb_write(C_ADDR_REG_1, x"AA55", "Write data to Peripheral 1");


.. _apb_read_bfm:

apb_read()
----------------------------------------------------------------------------------------------------------------------------------
Reads data from the DUT at the given address, using the APB protocol:

.. code-block:: none

    1. During the setup phase:
        a. paddr is set to addr_value
        b. pprot is set to protection
        c. psel is set to '1'
        d. pwrite is set to '0'
        e. penable is set to '0'
    2. During the access phase:
        a. penable is set to '1'
        b. the BFM waits for pready to be '1'
    3. Before exiting the procedure:
        e. psel is set to '0'
        g. penable is set to '0'

The procedure reports an alert if pready signal is not set to '1' within 'config.max_wait_cycles' after penable is set to '1'
(alert_level: config.max_wait_cycles_severity).

.. code-block::

    apb_read(addr_value, data_value, protection, msg, apb_if, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | The memory address of the peripheral being accessed     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | data_value         | out    | std_logic_vector             | The data value read from the addressed register         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | protection         | in     | std_logic_vector(2 downto 0) | Indicates normal, privileged or secure protection levels|
|          |                    |        |                              | and whether it's a data or instruction access           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | apb_if             | inout  | :ref:`t_apb_if <t_apb_if>`   | APB signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("APB BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_apb_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_apb_bfm_config>`          | value is C_APB_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    apb_read(x"1000", v_data_out, "000", "Read from Peripheral 1", apb_if);
    apb_read(x"1000", v_data_out, "000", "Read from Peripheral 1", apb_if, C_SCOPE, shared_msg_id_panel, C_APB_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    apb_read(C_ADDR_REG_1, v_data_out, "Read from Peripheral 1");


.. _apb_check_bfm:

apb_check()
----------------------------------------------------------------------------------------------------------------------------------
Reads data from the DUT at the given address, using the APB protocol described under :ref:`apb_read_bfm`. After reading data from
the APB bus, the read data is compared with the expected data.

* If the check was successful, and the read data matches the expected data, a log message is written with ID 'config.id_for_bfm'.
* If the read data did not match the expected data, an alert with severity 'alert_level' will be reported.
* The procedure will also report alerts for the same conditions as the :ref:`apb_read_bfm` procedure.

.. code-block::

    apb_check(addr_value, data_exp, protection, msg, apb_if, [alert_level, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | The memory address of the peripheral being accessed     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_logic_vector             | The data value to be expect when reading the memory     |
|          |                    |        |                              | address                                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | protection         | in     | std_logic_vector(2 downto 0) | Indicates normal, privileged or secure protection levels|
|          |                    |        |                              | and whether it's a data or instruction access           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | apb_if             | inout  | :ref:`t_apb_if <t_apb_if>`   | APB signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("APB BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_apb_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_apb_bfm_config>`          | value is C_APB_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    apb_check(x"1155", x"123B", "000", "Check data from Peripheral 1", apb_if);
    apb_check(x"1155", x"123B", "000", "Check data from Peripheral 1", apb_if, ERROR, C_SCOPE, shared_msg_id_panel, C_APB_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    apb_check(C_ADDR_REG_1, x"123B", "Check data from Peripheral 1");


.. _apb_poll_until_bfm:

apb_poll_until()
----------------------------------------------------------------------------------------------------------------------------------
Reads data from the DUT at the given address, using the APB protocol described under :ref:`apb_read_bfm`. After reading data from
the DUT, the read data is compared with the expected data. If the read data does not match the expected data, the process is
repeated until one or more of the following occurs:

1. The read data matches the expected data
2. The number of read retries is equal to 'max_polls'
3. The time between start of apb_poll_until procedure and now is greater than 'timeout'
4. The terminate_loop signal is set to '1'

If the procedure exits because of 2. or 3. an alert with severity 'alert_level' is issued. If either 'max_polls' or 'timeout' is
set to 0 (ns), this constraint will be ignored and interpreted as no limit.

* If the check was successful, and the read data matches the expected data, a log message is written with ID 'config.id_for_bfm'.
* If the read data did not match the expected data, an alert with severity 'alert_level' will be reported.
* If the procedure is terminated using 'terminate_loop' a log message with ID ID_TERMINATE_CMD will be issued.
* The procedure will also report alerts for the same conditions as the :ref:`apb_read_bfm` procedure.

.. code-block::

    apb_poll_until(addr_value, data_exp, protection, max_polls, timeout, msg, apb_if, terminate_loop, [alert_level, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | The memory address of the peripheral being accessed     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_logic_vector             | The data value to be expect when reading the memory     |
|          |                    |        |                              | address                                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | protection         | in     | std_logic_vector(2 downto 0) | Indicates normal, privileged or secure protection levels|
|          |                    |        |                              | and whether it's a data or instruction access           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | max_polls          | in     | integer                      | The maximum number of polls (reads) before the expected |
|          |                    |        |                              | data must be found. Exceeding this limit results in an  |
|          |                    |        |                              | alert with severity 'alert_level'. Note that 0 means no |
|          |                    |        |                              | limit.                                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | The maximum time to pass before the expected data must  |
|          |                    |        |                              | be found. Exceeding this limit results in an alert with |
|          |                    |        |                              | severity 'alert_level'. Note that 0 ns means no timeout.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | apb_if             | inout  | :ref:`t_apb_if <t_apb_if>`   | APB signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | External control of loop termination to e.g. stop       |
|          |                    |        |                              | polling prematurely                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("APB BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_apb_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_apb_bfm_config>`          | value is C_APB_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    apb_poll_until(x"1155", x"0A5D", "000", 10, 100 ns, "Poll for data from Peripheral 1", apb_if, terminate_loop);
    apb_poll_until(x"1155", x"0A5D", "000", 10, 100 ns, "Poll for data from Peripheral 1", apb_if, terminate_loop, ERROR, C_SCOPE, shared_msg_id_panel, C_APB_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    apb_poll_until(C_ADDR_REG_1, x"05AD", "Poll register 1 until expected data is found");
    apb_poll_until(C_ADDR_REG_1, x"05AD", C_MAX_POLLS, C_TIMEOUT, "Poll register 1 until expected data is found");


.. _init_apb_if_signals_bfm:

init_apb_if_signals()
----------------------------------------------------------------------------------------------------------------------------------
Initializes the APB interface. All the BFM outputs are set to '0', and BFM inputs are set to 'Z'.

.. code-block::

    t_apb_if := init_apb_if_signals(addr_width, data_width)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_width         | in     | natural                      | Width of the address signal                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_width         | in     | natural                      | Width of the data signals                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    apb_if <= init_apb_if_signals(apb_if.paddr'length, apb_if.pwdata'length);


Local BFM overloads
==================================================================================================================================
A good approach for better readability and maintainability is to make simple, local overloads for the BFM procedures in the TB
process. This allows calling the BFM procedures with the key parameters only, e.g. ::

    apb_write(C_ADDR_REG_1, x"AA55", "Write data to Peripheral 1");

rather than ::

    apb_write(C_ADDR_REG_1, x"AA55", "1111", "000", "Write data to Peripheral 1", apb_if, C_SCOPE, shared_msg_id_panel, C_APB_BFM_CONFIG_DEFAULT);

By defining the local overload as e.g. ::

    procedure apb_write(
      constant addr_value : in unsigned;
      constant data_value : in std_logic_vector;
      constant msg        : in string) is
      variable v_byte_enable : std_logic_vector((data_value'length / 8) - 1 downto 0) := (others => '1');
    begin
      apb_write(addr_value,           -- Keep as is
                data_value,           -- Keep as is
                v_byte_enable,        -- This could also be an input if needed
                C_DEFAULT_PROTECTION, -- This could also be an input if needed
                msg,                  -- Keep as is
                apb_if,               -- Signal must be visible in local process scope
                C_SCOPE,              -- Use the default
                shared_msg_id_panel,  -- Use global, shared msg_id_panel
                C_APB_CONFIG_LOCAL);  -- Use locally defined configuration or C_APB_CONFIG_DEFAULT
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
For more information on the APB specification, refer to "AMBA® APB Protocol Specification" (ARM IHI 0024D), available from ARM.

.. important::

    * This is a simplified Bus Functional Model (BFM) for APB.
    * The given BFM complies with the basic APB protocol and thus allows a normal access towards an APB interface.
    * This BFM is not an APB protocol checker.
    * For a more advanced BFM please contact UVVM support at info@uvvm.org


**********************************************************************************************************************************
VVC
**********************************************************************************************************************************
* VVC functionality is implemented in apb_vvc.vhd
* For general information see :ref:`vvc_framework_vvc_mechanisms_and_features`.

Entity
==================================================================================================================================

Generics
----------------------------------------------------------------------------------------------------------------------------------

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Name                         | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| GC_ADDR_WIDTH                | integer                      | 32              | Width of the APB address bus                    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_DATA_WIDTH                | integer                      | 32              | Width of the APB data bus                       |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_INSTANCE_IDX              | natural                      | 0               | Instance number to assign the VVC. Maximum value|
|                              |                              |                 | is defined by C_APB_VVC_MAX_INSTANCE_NUM        |
|                              |                              |                 | in adaptations_pkg.                             |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_APB_CONFIG                | :ref:`t_apb_bfm_config       | C_APB_BFM_CONFI\| Configuration for the APB BFM                   |
|                              | <t_apb_bfm_config>`          | G_DEFAULT       |                                                 |
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

.. note::

    Default values for the cmd/result queue generics are defined in adaptations_pkg.

Signals
----------------------------------------------------------------------------------------------------------------------------------

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | apb_vvc_master_if  | inout  | :ref:`t_apb_if <t_apb_if>`   | APB signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

In this VVC, the interface has been encapsulated in a signal record of type **t_apb_if** in order to improve readability of the code.
Since the APB interface buses can be of arbitrary size, the interface vectors have been left unconstrained. These unconstrained
vectors need to be constrained when the interface signals are instantiated. For this interface, it could look like: ::

    signal apb_if : t_apb_if(paddr(C_ADDR_WIDTH - 1 downto 0),
                             pwdata(C_DATA_WIDTH - 1 downto 0),
                             pstrobe((C_DATA_WIDTH / 8) - 1 downto 0),
                             prdata(C_DATA_WIDTH - 1 downto 0));

Configuration Record
==================================================================================================================================
**vvc_config** accessible via **shared_apb_vvc_config**

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| inter_bfm_delay              | :ref:`t_inter_bfm_delay`     | C_APB_INTER_BFM\| Delay between any requested BFM accesses        |
|                              |                              | _DELAY_DEFAULT  | towards the DUT.                                |
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
| bfm_config                   | :ref:`t_apb_bfm_config       | C_APB_BFM_CONFI\| Configuration for the APB BFM                   |
|                              | <t_apb_bfm_config>`          | G_DEFAULT       |                                                 |
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

    shared_apb_vvc_config(C_VVC_IDX).inter_bfm_delay.delay_in_time := 50 ns;
    shared_apb_vvc_config(C_VVC_IDX).bfm_config.id_for_bfm := ID_BFM;

Status Record
==================================================================================================================================
**vvc_status** accessible via **shared_apb_vvc_status**

.. include:: rst_snippets/vip_vvc_status.rst

Methods
==================================================================================================================================
* All VVC procedures are defined in vvc_methods_pkg.vhd (dedicated to this VVC).
* See :ref:`vvc_framework_methods` for procedures which are common to all VVCs.
* It is also possible to send a multicast to all instances of a VVC with ALL_INSTANCES as parameter for vvc_instance_idx.
* All parameters in brackets are optional.

.. note::

    Some parameters in the VVC procedures are unconstrained for flexibility. However, the maximum sizes of such parameters need to
    be defined for the VVC framework. For this VVC, the following maximum values can be configured from adaptations_pkg:

      +--------------------------------------------+--------------------------------------+
      | C_APB_VVC_CMD_DATA_MAX_LENGTH              | Maximum **pwdata/prdata** length     |
      +--------------------------------------------+--------------------------------------+
      | C_APB_VVC_CMD_ADDR_MAX_LENGTH              | Maximum **paddr** length             |
      +--------------------------------------------+--------------------------------------+
      | C_APB_VVC_CMD_BYTE_ENABLE_MAX_LENGTH       | Maximum **pstrb** length             |
      +--------------------------------------------+--------------------------------------+
      | C_APB_VVC_CMD_STRING_MAX_LENGTH            | Maximum **msg** length               |
      +--------------------------------------------+--------------------------------------+

.. _apb_write_vvc:

apb_write()
----------------------------------------------------------------------------------------------------------------------------------
Adds a write command to the APB VVC executor queue, which will run as soon as all preceding commands have completed. When the
command is scheduled to run, the executor calls the BFM :ref:`apb_write_bfm` procedure.

.. code-block::

    apb_write(VVCT, vvc_instance_idx, addr, data, [byte_enable, protection,] msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | addr               | in     | unsigned                     | The memory address of the peripheral being accessed     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The data value to be written to the memory address      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | byte_enable        | in     | std_logic_vector             | Each bit indicates which byte in data is valid          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | protection         | in     | std_logic_vector(2 downto 0) | Indicates normal, privileged or secure protection levels|
|          |                    |        |                              | and whether it's a data or instruction access           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT defined in     |
|          |                    |        |                              | adaptations_pkg.                                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    apb_write(APB_VVCT, 0, x"1000", x"4000", "Write data to Peripheral 1", C_SCOPE);
    apb_write(APB_VVCT, 0, x"1000", x"4000", "1111", "000" "Write data to Peripheral 1", C_SCOPE);

    -- It is recommended to use constants to improve the readability of the code, e.g.:
    apb_write(APB_VVCT, 0, C_ADDR_REG_1, x"4000", C_BYTE_ENABLE, C_NON_SECURE, "Write data to Peripheral 1");


.. _apb_read_vvc:

apb_read()
----------------------------------------------------------------------------------------------------------------------------------
Adds a read command to the APB VVC executor queue, which will run as soon as all preceding commands have completed. When the
command is scheduled to run, the executor calls the BFM :ref:`apb_read_bfm` procedure.

The value read from DUT will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but the
read data will be stored in the VVC for a potential future fetch (see example with fetch_result below).
If the data_routing is set to TO_SB, the read data will be sent to the APB VVC dedicated scoreboard where it will be checked
against the expected value (provided by the testbench).

.. code-block::

    apb_read(VVCT, vvc_instance_idx, addr, [protection,] [data_routing,] msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | addr               | in     | unsigned                     | The memory address of the peripheral being accessed     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | protection         | in     | std_logic_vector(2 downto 0) | Indicates normal, privileged or secure protection levels|
|          |                    |        |                              | and whether it's a data or instruction access           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_routing       | in     | :ref:`t_data_routing`        | Selects the destination of the read data                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT defined in     |
|          |                    |        |                              | adaptations_pkg.                                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    apb_read(APB_VVCT, 0, x"1000", "Read from Peripheral 1", C_SCOPE);
    apb_read(APB_VVCT, 0, x"1002", TO_SB, "Read from Peripheral 1 and send to Scoreboard", C_SCOPE);

    -- It is recommended to use constants to improve the readability of the code, e.g.:
    apb_read(APB_VVCT, 0, C_ADDR_REG_1, "Read from Peripheral 1");

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last read
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from read.
    ...
    apb_read(APB_VVCT, 0, C_ADDR_REG_1, "Read from Peripheral 1";
    v_cmd_idx := get_last_received_cmd_idx(APB_VVCT, 0);
    await_completion(APB_VVCT, 0, v_cmd_idx, 1 us, "Wait for read to finish");
    fetch_result(APB_VVCT, 0, v_cmd_idx, v_result, "Fetching result from read operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.


.. _apb_check_vvc:

apb_check()
----------------------------------------------------------------------------------------------------------------------------------
Adds a check command to the APB VVC executor queue, which will run as soon as all preceding commands have completed. When the
command is scheduled to run, the executor calls the BFM :ref:`apb_check_bfm` procedure. The apb_check() procedure will perform a
read operation, then check if the read data is equal to the expected data in the data parameter. If the read data is not equal to
the expected data parameter, an alert with severity 'alert_level' will be issued. The read data will not be stored in this procedure.

.. code-block::

    apb_check(VVCT, vvc_instance_idx, addr, data, [protection,] msg, [alert_level, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | addr               | in     | unsigned                     | The memory address of the peripheral being accessed     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The expected data value to be read from the addressed   |
|          |                    |        |                              | register                                                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | protection         | in     | std_logic_vector(2 downto 0) | Indicates normal, privileged or secure protection levels|
|          |                    |        |                              | and whether it's a data or instruction access           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT defined in     |
|          |                    |        |                              | adaptations_pkg.                                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    apb_check(APB_VVCT, 0, x"1155", x"123B", "Check data from Peripheral 1");
    apb_check(APB_VVCT, 0, x"1155", x"123B", "000", "Check data from Peripheral 1", TB_ERROR, C_SCOPE):

    -- It is recommended to use constants to improve the readability of the code, e.g.:
    apb_check(APB_VVCT, 0, C_ADDR_REG_1, x"4000", C_NON_SECURE, "Check data from Peripheral 1");


.. _apb_poll_until_vvc:

apb_poll_until()
----------------------------------------------------------------------------------------------------------------------------------
Adds a poll_until command to the APB VVC executor queue, which will run as soon as all preceding commands have completed. When the
command is scheduled to run, the executor calls the BFM :ref:`apb_poll_until_bfm` procedure. The apb_poll_until() procedure will
perform a read operation, then check if the read data is equal to the data in the data parameter. If the read data is not equal to
the expected data parameter, the process will be repeated until the read data is equal to the expected data, or the procedure is
terminated by either a terminate command, a timeout or the poll limit set in max_polls. The read data will not be stored by this
procedure.

.. code-block::

    apb_poll_until(VVCT, vvc_instance_idx, addr, data, [protection,] msg, [max_polls, [timeout, [alert_level, [scope]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | addr               | in     | unsigned                     | The memory address of the peripheral being accessed     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The expected data value to be read from the addressed   |
|          |                    |        |                              | register                                                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | protection         | in     | std_logic_vector(2 downto 0) | Indicates normal, privileged or secure protection levels|
|          |                    |        |                              | and whether it's a data or instruction access           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | max_polls          | in     | integer                      | The maximum number of polls (reads) before the expected |
|          |                    |        |                              | data must be found. Exceeding this limit results in an  |
|          |                    |        |                              | alert with severity 'alert_level'. Note that 0 means no |
|          |                    |        |                              | limit. Default value is 100.                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | The maximum time to pass before the expected data must  |
|          |                    |        |                              | be found. Exceeding this limit results in an alert with |
|          |                    |        |                              | severity 'alert_level'. Note that 0 ns means no timeout.|
|          |                    |        |                              | Default value is 1 us.                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT defined in     |
|          |                    |        |                              | adaptations_pkg.                                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    apb_poll_until(APB_VVCT, 0, x"1155", x"0ABD", "Poll for data from Peripheral 1");
    apb_poll_until(APB_VVCT, 0, x"1155", x"0ABD", "000", "Poll for data from Peripheral 1", 5, 0 ns, TB_WARNING, C_SCOPE);

    -- It is recommended to use constants to improve the readability of the code, e.g.:
    apb_poll_until(APB_VVCT, 0, C_ADDR_REG_1, x"0ABD", "Poll for data from Peripheral 1 until expected data is found");


Activity Watchdog
==================================================================================================================================
.. include:: rst_snippets/vip_activity_watchdog.rst


Transaction Info
==================================================================================================================================
.. include:: rst_snippets/vip_transaction_info.rst

.. table:: APB transaction info record fields. Transaction Type: t_base_transaction (BT) - accessible via **shared_apb_vvc_transaction_info.bt**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | address                      | unsigned(31 downto 0)        | 0x0             | Address of the APB read or write transaction    |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | data                         | std_logic_vector(31 downto 0)| 0x0             | Data for APB read or write transaction          |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | vvc_meta                     | t_vvc_meta                   | C_VVC_META_DEFA\| VVC meta data of the executing VVC command      |
    |                              |                              | ULT             |                                                 |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    |  -> msg                      | string                       | ""              | Message of executing VVC command                |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    |  -> cmd_idx                  | integer                      | -1              | Command index of executing VVC command          |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | transaction_status           | :ref:`t_transaction_status`  | INACTIVE        | Set to INACTIVE, IN_PROGRESS, FAILED or         |
    |                              |                              |                 | SUCCEEDED during a transaction                  |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+

.. table:: APB transaction info record fields. Transaction type: t_compound_transaction (CT) - accessible via **shared_apb_vvc_transaction_info.ct**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | address                      | unsigned(31 downto 0)        | 0x0             | Address of the APB read or write transaction    |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | data                         | std_logic_vector(31 downto 0)| 0x0             | Data for APB read or write transaction          |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | max_polls                    | integer                      | 1               | Maximum number of polls allowed in the          |
    |                              |                              |                 | apb_poll_until() procedure. 0 means no limit.   |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | vvc_meta                     | t_vvc_meta                   | C_VVC_META_DEFA\| VVC meta data of the executing VVC command      |
    |                              |                              | ULT             |                                                 |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    |  -> msg                      | string                       | ""              | Message of executing VVC command                |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    |  -> cmd_idx                  | integer                      | -1              | Command index of executing VVC command          |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | transaction_status           | :ref:`t_transaction_status`  | INACTIVE        | Set to INACTIVE, IN_PROGRESS, FAILED or         |
    |                              |                              |                 | SUCCEEDED during a transaction                  |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+

More information can be found in :ref:`Essential Mechanisms - Distribution of Transaction Info <vvc_framework_transaction_info>`.


Scoreboard
==================================================================================================================================
This VVC has built in Scoreboard functionality where data can be routed by setting the TO_SB parameter in supported method calls,
i.e. apb_read(). Note that the data is only stored in the scoreboard and not accessible with the fetch_result() method when the
TO_SB parameter is applied. The APB scoreboard is accessible from the testbench as a shared variable ``apb_vvc_sb``, located in
the vvc_methods_pkg.vhd, e.g. ::

    apb_vvc_sb.add_expected(C_APB_VVC_IDX, pad_apb_sb(v_expected), "Adding expected");

The APB scoreboard is per default a 32 bits wide standard logic vector. When sending expected data to the scoreboard, where the
data width is smaller than the default scoreboard width, we recommend zero-padding the data with the pad_apb_sb() function, e.g. ::

    apb_vvc_sb.add_expected(<APB VVC instance number>, pad_apb_sb(<exp data>));

See the :ref:`vip_scoreboard` for a complete list of available commands and additional information. All of the listed Generic
Scoreboard commands are available for the APB VVC scoreboard using the ``apb_vvc_sb``.


Unwanted Activity Detection
==================================================================================================================================
.. include:: rst_snippets/vip_unwanted_activity.rst

.. code-block::

    shared_apb_vvc_config(C_VVC_INDEX).unwanted_activity_severity := NO_ALERT;

Note that the pready signal is not monitored in this VVC. The pready signal is allowed to toggle whenever penable is low,
and there is no method to differentiate between the unwanted activity and intended activity. See the APB protocol specification
for more information on the pready signal.

For APB VVC, the unwanted activity detection is enabled by default with severity ERROR.

More information can be found in :ref:`Essential Mechanisms - Unwanted Activity Detection <vvc_framework_unwanted_activity>`.


Compilation
==================================================================================================================================
The APB VVC must be compiled with VHDL-2008 or newer. It is dependent on the following libraries:

    * UVVM Utility Library (UVVM-Util)
    * UVVM VVC Framework
    * Bitvis VIP Scoreboard
    * APB BFM

Before compiling the APB VVC, assure that uvvm_util, uvvm_vvc_framework and bitvis_vip_scoreboard have been compiled.

See :ref:`Essential Mechanisms - Compile Scripts <vvc_framework_compile_scripts>` for information about compile scripts.

.. table:: Compile order for the APB VVC

    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | Compile to library           | File                                           | Comment                                         |
    +==============================+================================================+=================================================+
    | external_vip_apb             | apb_bfm_pkg.vhd                                | APB BFM                                         |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | external_vip_apb             | transaction_pkg.vhd                            | APB transaction package with DTT types,         |
    |                              |                                                | constants, etc.                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | external_vip_apb             | vvc_cmd_pkg.vhd                                | APB VVC command types and operations            |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | external_vip_apb             | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC target support package, compiled into  |
    |                              | _target_support_pkg.vhd                        | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | external_vip_apb             | ../uvvm_vvc_framework/src_target_dependent/td\ | Common UVVM framework methods compiled into the |
    |                              | _vvc_framework_common_methods_pkg.vhd          | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | external_vip_apb             | vvc_sb_pkg.vhd                                 | APB VVC scoreboard                              |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | external_vip_apb             | vvc_methods_pkg.vhd                            | APB VVC methods                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | external_vip_apb             | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM queue package for this VVC                 |
    |                              | _queue_pkg.vhd                                 |                                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | external_vip_apb             | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC entity support compiled into this      |
    |                              | _vvc_entity_support_pkg.vhd                    | VVC library                                     |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | external_vip_apb             | apb_vvc.vhd                                    | APB VVC                                         |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | external_vip_apb             | vvc_context.vhd                                | APB VVC context file                            |
    +------------------------------+------------------------------------------------+-------------------------------------------------+

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


Additional Documentation
==================================================================================================================================
For more information on the APB specification, refer to "AMBA® APB Protocol Specification" (ARM IHI 0024D), available from ARM.

.. important::

    * This is a simplified Verification IP (VIP) for APB.
    * The given VIP complies with the basic APB protocol and thus allows a normal access towards an APB interface.
    * This VIP is not an APB protocol checker.
    * For a more advanced VIP please contact UVVM support at info@uvvm.org

.. include:: rst_snippets/ip_disclaimer.rst
