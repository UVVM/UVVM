##################################################################################################################################
Bitvis VIP Avalon-MM
##################################################################################################################################

**Quick Access**

* `BFM`_

  * :ref:`avalon_mm_write_bfm`
  * :ref:`avalon_mm_read_bfm`
  * :ref:`avalon_mm_check_bfm`
  * :ref:`avalon_mm_reset_bfm`
  * :ref:`avalon_mm_lock_bfm`
  * :ref:`avalon_mm_unlock_bfm`
  * :ref:`init_avalon_mm_if_signals_bfm`
  * :ref:`avalon_mm_read_request_bfm`
  * :ref:`avalon_mm_read_response_bfm`
  * :ref:`avalon_mm_check_response_bfm`

* `VVC`_

  * :ref:`avalon_mm_write_vvc`
  * :ref:`avalon_mm_read_vvc`
  * :ref:`avalon_mm_check_vvc`
  * :ref:`avalon_mm_reset_vvc`
  * :ref:`avalon_mm_lock_vvc`
  * :ref:`avalon_mm_unlock_vvc`


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
BFM
**********************************************************************************************************************************
BFM functionality is implemented in avalon_mm_bfm_pkg.vhd

.. _t_avalon_mm_if:

Signal Record
==================================================================================================================================
**t_avalon_mm_if**

+-------------------------+------------------------------+------------------+
| Record element          | Type                         | Direction        |
+=========================+==============================+==================+
| reset                   | std_logic                    | BFM to DUT       |
+-------------------------+------------------------------+------------------+
| address                 | std_logic_vector             | BFM to DUT       |
+-------------------------+------------------------------+------------------+
| begintransfer           | std_logic                    | BFM to DUT       |
+-------------------------+------------------------------+------------------+
| byte_enable             | std_logic_vector             | BFM to DUT       |
+-------------------------+------------------------------+------------------+
| chipselect              | std_logic                    | BFM to DUT       |
+-------------------------+------------------------------+------------------+
| write                   | std_logic                    | BFM to DUT       |
+-------------------------+------------------------------+------------------+
| writedata               | std_logic_vector             | BFM to DUT       |
+-------------------------+------------------------------+------------------+
| read                    | std_logic                    | BFM to DUT       |
+-------------------------+------------------------------+------------------+
| lock                    | std_logic                    | BFM to DUT       |
+-------------------------+------------------------------+------------------+
| readdata                | std_logic_vector             | DUT to BFM       |
+-------------------------+------------------------------+------------------+
| response                | std_logic_vector             | DUT to BFM       |
+-------------------------+------------------------------+------------------+
| waitrequest             | std_logic                    | DUT to BFM       |
+-------------------------+------------------------------+------------------+
| readdatavalid           | std_logic                    | DUT to BFM       |
+-------------------------+------------------------------+------------------+
| irq                     | std_logic                    | DUT to BFM       |
+-------------------------+------------------------------+------------------+

.. note::

    * For more information on the Avalon-MM signals, refer to "Avalon® Interface Specifications, Chapter: Avalon Memory-Mapped 
      Interfaces" (MNL-AVABUSREF), available from Intel.

.. _t_avalon_mm_bfm_config:

Configuration Record
==================================================================================================================================
**t_avalon_mm_bfm_config**

Default value for the record is C_AVALON_MM_BFM_CONFIG_DEFAULT.

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| max_wait_cycles              | integer                      | 10              | The maximum number of clock cycles to wait for  |
|                              |                              |                 | readdatavalid or stalling because of waitrequest|
|                              |                              |                 | before reporting a timeout alert                |
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
| num_wait_states_read         | natural                      | 0               | Number of fixed wait states to use for read     |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| num_wait_states_write        | natural                      | 0               | Number of fixed wait states to use for write    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| use_waitrequest              | boolean                      | true            | Set to true if slave uses waitrequest           |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| use_readdatavalid            | boolean                      | false           | Set to true if slave uses readdatavalid         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| use_response_signal          | boolean                      | true            | Whether or not to check the response signal on  |
|                              |                              |                 | read                                            |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| use_begintransfer            | boolean                      | false           | Whether or not to use the begintransfer signal  |
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


.. _avalon_mm_write_bfm:

avalon_mm_write()
----------------------------------------------------------------------------------------------------------------------------------
Writes the given data to the given address of the DUT, using the Avalon-MM protocol. For protocol details, see the Avalon-MM specification.

  * If the byte_enable argument is not used, it will be set to all '1', i.e. all bytes are used.
  * The procedure supports wait-request or fixed wait-states, but not both. If 'config.use_waitrequest' is set to false, 
    'config.num_wait_states' will be used as the number of cycles to use as fixed wait cycles.
  
The procedure reports an alert if:

  * waitrequest is enabled for more than 'config.max_wait_cycles' clock cycles (alert level: 'config.max_wait_cycles_severity')

.. code-block::

    avalon_mm_write(addr_value, data_value, msg, clk, avalon_mm_if, [byte_enable,] [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | The address of an Avalon-MM accessible register         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_value         | in     | std_logic_vector             | The data value to be written to the addressed register  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the Avalon-MM BFM                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | avalon_mm_if       | inout  | :ref:`t_avalon_mm_if         | Avalon-MM signal interface record                       |
|          |                    |        | <t_avalon_mm_if>`            |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | byte_enable        | in     | string                       | Selects which bytes to use (all '1' means all bytes are |
|          |                    |        |                              | updated)                                                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AVALON MM BFM").         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_avalon_mm_bfm_config | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_avalon_mm_bfm_config>`    | value is C_AVALON_MM_BFM_CONFIG_DEFAULT.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_mm_write(x"11005500", x"AAFF0055", "Writing test to Peripheral 1", clk, avalon_mm_if, C_SCOPE, shared_msg_id_panel, C_AVALON_MM_BFM_CONFIG_DEFAULT);
    avalon_mm_write(x"11005500", x"AAFF0055", "Writing test to Peripheral 1", clk, avalon_mm_if, "1111", C_SCOPE, shared_msg_id_panel, C_AVALON_MM_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    avalon_mm_write(C_ADDR_DMA, x"AAFF0055", "Writing data to DMA");


.. _avalon_mm_read_bfm:

avalon_mm_read()
----------------------------------------------------------------------------------------------------------------------------------
Reads data from the given address of the DUT, using the Avalon-MM protocol. For protocol details, see the Avalon-MM specification. 
The read data is placed on the output 'data_value' when the read has completed.

  * The procedure supports pipelining/fixed wait-states, readdatavalid and/or waitrequest, set by the config parameter.
  * The maximum number of wait cycles while waiting for readdatavalid is given in 'config.max_wait_cycles'
  * The maximum number of cycles acceptable to be stalled by waitrequest is given in 'config.max_wait_cycles'
  * If use_waitrequest and use_readdatavalid are disabled in the config, the read procedure will use the num_wait_states as readWaitTime.
  * The BFM can be configured to use waitrequest and readdatavalid in the config parameter.

The procedure reports an alert if:

  * waitrequest is enabled for more than 'config.max_wait_cycles' clock cycles (alert level: 'config.max_wait_cycles_severity')
  * readdatavalid is not set active for more than 'config.max_wait_cycles' clock cycles (alert level: 'config.max_wait_cycles_severity')

.. code-block::

    avalon_mm_read(addr_value, data_value, msg, clk, avalon_mm_if, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | The address of an Avalon-MM accessible register         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | data_value         | out    | std_logic_vector             | The data value to be read from the addressed register   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the Avalon-MM BFM                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | avalon_mm_if       | inout  | :ref:`t_avalon_mm_if         | Avalon-MM signal interface record                       |
|          |                    |        | <t_avalon_mm_if>`            |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AVALON MM BFM").         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_avalon_mm_bfm_config | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_avalon_mm_bfm_config>`    | value is C_AVALON_MM_BFM_CONFIG_DEFAULT.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_mm_read(x"11005500", v_data_out, "Read from Peripheral 1", clk, avalon_mm_if, C_SCOPE, shared_msg_id_panel, C_AVALON_MM_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    avalon_mm_read(C_ADDR_IO, v_data_out, "Reading from IO device");


.. _avalon_mm_check_bfm:

avalon_mm_check()
----------------------------------------------------------------------------------------------------------------------------------
Reads data from the given address of the DUT, using the Avalon-MM protocol. For protocol details, see the Avalon-MM specification. 
After reading data from the Avalon-MM bus, the read data is compared with the expected data, and if they don't match, an alert with 
severity 'alert_level' is reported. The procedure also report alerts for the same conditions as the :ref:`avalon_mm_read_bfm` procedure.

.. code-block::

    avalon_mm_check(addr_value, data_exp, msg, clk, avalon_mm_if, [alert_level, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | The address of an Avalon-MM accessible register         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_logic_vector             | The data value to expect when reading the addressed     |
|          |                    |        |                              | register. A mismatch results in an alert 'alert_level'  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the Avalon-MM BFM                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | avalon_mm_if       | inout  | :ref:`t_avalon_mm_if         | Avalon-MM signal interface record                       |
|          |                    |        | <t_avalon_mm_if>`            |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AVALON MM BFM").         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_avalon_mm_bfm_config | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_avalon_mm_bfm_config>`    | value is C_AVALON_MM_BFM_CONFIG_DEFAULT.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_mm_check(x"11AA5100", x"5500133B", "Check data from Peripheral 1", clk, avalon_mm_if, ERROR, shared_msg_id_panel, C_AVALON_MM_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    avalon_mm_check(C_ADDR_UART_RX, x"55", "Check data from UART RX buffer");


.. _avalon_mm_reset_bfm:

avalon_mm_reset()
----------------------------------------------------------------------------------------------------------------------------------
Resets the avalon_mm_if interface by first setting the signals to their default state with :ref:`init_avalon_mm_if_signals_bfm`, then 
setting reset active. The reset signal is held active for 'num_rst_cycles' clock cycles.

.. code-block::

    avalon_mm_reset(clk, avalon_mm_if, num_rst_cycles, msg, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the Avalon-MM BFM                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | avalon_mm_if       | inout  | :ref:`t_avalon_mm_if         | Avalon-MM signal interface record                       |
|          |                    |        | <t_avalon_mm_if>`            |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | num_rst_cycles     | in     | integer                      | Number of cycles to hold the reset signal active        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AVALON MM BFM").         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_avalon_mm_bfm_config | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_avalon_mm_bfm_config>`    | value is C_AVALON_MM_BFM_CONFIG_DEFAULT.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_mm_reset(clk, avalon_mm_if, 5, "Resetting Avalon-MM Interface", C_SCOPE, shared_msg_id_panel, AVALON_MM_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    avalon_mm_reset(5, "Resetting Avalon-MM Interface");


.. _avalon_mm_lock_bfm:

avalon_mm_lock()
----------------------------------------------------------------------------------------------------------------------------------
Locks the Avalon-MM interface by setting the avalon_mm_if signal 'lock' to '1'. The lock signal will be kept at '1' until 
:ref:`avalon_mm_unlock_bfm` is called.

.. code-block::

    avalon_mm_lock(avalon_mm_if, msg, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | avalon_mm_if       | inout  | :ref:`t_avalon_mm_if         | Avalon-MM signal interface record                       |
|          |                    |        | <t_avalon_mm_if>`            |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AVALON MM BFM").         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_avalon_mm_bfm_config | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_avalon_mm_bfm_config>`    | value is C_AVALON_MM_BFM_CONFIG_DEFAULT.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_mm_lock(avalon_mm_if, "Locking Avalon-MM Interface", C_SCOPE, shared_msg_id_panel, AVALON_MM_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    avalon_mm_lock("Locking Avalon-MM Interface");


.. _avalon_mm_unlock_bfm:

avalon_mm_unlock()
----------------------------------------------------------------------------------------------------------------------------------
Unlocks the Avalon-MM interface by setting the avalon_mm_if signal 'lock' to '0'.

.. code-block::

    avalon_mm_unlock(avalon_mm_if, msg, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | avalon_mm_if       | inout  | :ref:`t_avalon_mm_if         | Avalon-MM signal interface record                       |
|          |                    |        | <t_avalon_mm_if>`            |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AVALON MM BFM").         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_avalon_mm_bfm_config | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_avalon_mm_bfm_config>`    | value is C_AVALON_MM_BFM_CONFIG_DEFAULT.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_mm_unlock(avalon_mm_if, "Unlocking Avalon-MM Interface", C_SCOPE, shared_msg_id_panel, AVALON_MM_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    avalon_mm_unlock("Unlocking Avalon-MM Interface");


.. _init_avalon_mm_if_signals_bfm:

init_avalon_mm_if_signals()
----------------------------------------------------------------------------------------------------------------------------------
Initializes the Avalon-MM interface. All the BFM outputs are set to '0', and BFM inputs are set to 'Z'. The value of the lock 
signal can be specified in the lock_value argument.

.. code-block::

    t_avalon_mm_if := init_avalon_mm_if_signals(addr_width, data_width, [lock_value])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_width         | in     | natural                      | Width of the address signal                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_width         | in     | natural                      | Width of the data signals                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | lock_value         | in     | natural                      | Initial value of the lock signal. Default value is '0'  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_mm_if <= init_avalon_mm_if_signals(avalon_mm_if.address'length, avalon_mm_if.writedata'length);
    avalon_mm_if <= init_avalon_mm_if_signals(avalon_mm_if.address'length, avalon_mm_if.writedata'length, '1');


.. _avalon_mm_read_request_bfm:

avalon_mm_read_request()
----------------------------------------------------------------------------------------------------------------------------------
Initiates a read request to the given address of the DUT, using the Avalon-MM protocol. For protocol details, see the Avalon-MM 
specification. This procedure returns as soon as the request has been completed, and will therefore not return any data. This 
procedure is meant to be used for pipelined reads where multiple read requests can be issued before the slave DUT responds with 
the read data. This procedure corresponds to the first half of the :ref:`avalon_mm_read_bfm` and :ref:`avalon_mm_check_bfm` 
procedures. For more information, please see :ref:`avalon_mm_read_bfm`.

.. code-block::

    avalon_mm_read_request(addr_value, msg, clk, avalon_mm_if, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | The address of an Avalon-MM accessible register         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the Avalon-MM BFM                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | avalon_mm_if       | inout  | :ref:`t_avalon_mm_if         | Avalon-MM signal interface record                       |
|          |                    |        | <t_avalon_mm_if>`            |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AVALON MM BFM").         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_avalon_mm_bfm_config | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_avalon_mm_bfm_config>`    | value is C_AVALON_MM_BFM_CONFIG_DEFAULT.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_mm_read_request(x"5A001120", "Initiating read from Peripheral 1", clk, avalon_mm_if, C_SCOPE, shared_msg_id_panel, C_AVALON_MM_BFM_CONFIG_DEFAULT); 

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    avalon_mm_read_request(C_ADDR_IO, "Initiating read from IO device");


.. _avalon_mm_read_response_bfm:

avalon_mm_read_response()
----------------------------------------------------------------------------------------------------------------------------------
Reads data which is returned from the slave DUT, using the Avalon-MM protocol. For protocol details, see the Avalon-MM specification. 
This procedure is meant as the second half of the :ref:`avalon_mm_read_bfm` procedure, which is responsible for receiving data that 
has been requested by the :ref:`avalon_mm_read_request_bfm` procedure. The read data is placed on the output 'data_value' when the 
read has completed. For more information, please see :ref:`avalon_mm_read_bfm`.

.. code-block::

    avalon_mm_read_response(addr_value, data_value, msg, clk, avalon_mm_if, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | The address of an Avalon-MM accessible register         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | data_value         | out    | std_logic_vector             | The data value to be read from the addressed register   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the Avalon-MM BFM                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | avalon_mm_if       | inout  | :ref:`t_avalon_mm_if         | Avalon-MM signal interface record                       |
|          |                    |        | <t_avalon_mm_if>`            |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AVALON MM BFM").         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_avalon_mm_bfm_config | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_avalon_mm_bfm_config>`    | value is C_AVALON_MM_BFM_CONFIG_DEFAULT.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_mm_read_response(x"5A001120", v_data_out, "Read response from Peripheral 1", clk, avalon_mm_if, C_SCOPE, shared_msg_id_panel, C_AVALON_MM_BFM_CONFIG_DEFAULT); 

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    avalon_mm_read_response(C_ADDR_IO, v_data_out, "Reading response from IO device");


.. _avalon_mm_check_response_bfm:

avalon_mm_check_response()
----------------------------------------------------------------------------------------------------------------------------------
Reads data which is returned from the slave DUT using the Avalon-MM protocol, and compares it to the data in data_exp. For protocol 
details, see the Avalon-MM specification. This procedure is meant as the second half of the :ref:`avalon_mm_check_bfm` procedure, 
which is responsible for checking data that has been requested by the :ref:`avalon_mm_read_request_bfm` procedure. For more 
information, please see :ref:`avalon_mm_check_bfm`.

.. code-block::

    avalon_mm_check_response(addr_value, data_exp, msg, clk, avalon_mm_if, [alert_level, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | The address of an Avalon-MM accessible register         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_logic_vector             | The data value to expect when reading the addressed     |
|          |                    |        |                              | register. A mismatch results in an alert 'alert_level'  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the Avalon-MM BFM                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | avalon_mm_if       | inout  | :ref:`t_avalon_mm_if         | Avalon-MM signal interface record                       |
|          |                    |        | <t_avalon_mm_if>`            |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AVALON MM BFM").         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_avalon_mm_bfm_config | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_avalon_mm_bfm_config>`    | value is C_AVALON_MM_BFM_CONFIG_DEFAULT.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_mm_check_response(x"5A001120", x"5500133B", "Check response from Peripheral 1", clk, avalon_mm_if, ERROR, C_SCOPE, shared_msg_id_panel, C_AVALON_MM_BFM_CONFIG_DEFAULT); 

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    avalon_mm_check_response(C_ADDR_IO, x"5500133B", "Checking response from IO device");


Local BFM overloads
==================================================================================================================================
A good approach for better readability and maintainability is to make simple, local overloads for the BFM procedures in the TB 
process. This allows calling the BFM procedures with the key parameters only, e.g. ::

    avalon_mm_write(C_ADDR_PERIPHERAL_1, C_TEST_DATA, "Writing data to Peripheral 1");

rather than ::

    avalon_mm_write(C_ADDR_PERIPHERAL_1, C_TEST_DATA, "Writing data to Peripheral 1", clk, avalon_mm_if, C_SCOPE, shared_msg_id_panel, C_AVALON_MM_BFM_CONFIG_DEFAULT);


By defining the local overload as e.g. ::

    procedure avalon_mm_write(
      constant add_value  : in unsigned;
      constant data_value : in std_logic_vector;
      constant msg        : in string) is
    begin
      avalon_mm_write(addr_value,                -- Keep as is
                      data_value,                -- Keep as is
                      msg,                       -- Keep as is
                      clk,                       -- Signal must be visible in local process scope
                      avalon_mm_if,              -- Signal must be visible in local process scope
                      C_SCOPE,                   -- Use the default
                      shared_msg_id_panel,       -- Use global, shared msg_id_panel
                      C_AVALON_MM_CONFIG_LOCAL); -- Use locally defined configuration or C_AVALON_MM_BFM_CONFIG_DEFAULT
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
For more information on the Avalon-MM specification, refer to "Avalon® Interface Specifications, Chapter: Avalon Memory-Mapped 
Interfaces" (MNL-AVABUSREF), available from Intel.

.. important::

    * This is a simplified Bus Functional Model (BFM) for Avalon-MM.
    * The given BFM complies with the basic Avalon-MM protocol and thus allows a normal access towards an Avalon-MM interface.
    * This BFM is not an Avalon-MM protocol checker.
    * For a more advanced BFM please contact UVVM support at info@uvvm.org


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
VVC
**********************************************************************************************************************************
* VVC functionality is implemented in avalon_mm_vvc.vhd
* For general information see :ref:`VVC Framework - Essential Mechanisms <vvc_framework_essential_mechanisms>`.

Entity
==================================================================================================================================

Generics
----------------------------------------------------------------------------------------------------------------------------------

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Name                         | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| GC_ADDR_WIDTH                | integer                      | 8               | Width of the Avalon-MM address bus              |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_DATA_WIDTH                | integer                      | 32              | Width of the Avalon-MM data bus                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_INSTANCE_IDX              | natural                      | 1               | Instance number to assign the VVC               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_AVALON_MM_CONFIG          | :ref:`t_avalon_mm_bfm_config | C_AVALON_MM_BFM\| Configuration for the Avalon-MM BFM             |
|                              | <t_avalon_mm_bfm_config>`    | _CONFIG_DEFAULT |                                                 |
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
| signal   | avalon_mm_vvc_mast\| inout  | :ref:`t_avalon_mm_if         | Avalon-MM signal interface record                       |
|          | er_if              |        | <t_avalon_mm_if>`            |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

In this VVC, the interface has been encapsulated in a signal record of type t_avalon_mm_if in order to improve readability of the code. 
Since the Avalon-MM interface buses can be of arbitrary size, the interface vectors have been left unconstrained. These unconstrained 
vectors need to be constrained when the interface signals are instantiated. For this interface, this could look like: ::

    signal avalon_mm_if : t_avalon_mm_if(address(C_ADDR_WIDTH - 1 downto 0),
                                         byte_enable((C_DATA_WIDTH / 8) - 1 downto 0),
                                         writedata(C_DATA_WIDTH - 1 downto 0),
                                         readdata(C_DATA_WIDTH - 1 downto 0));


Configuration Record
==================================================================================================================================
**vvc_config** accessible via **shared_avalon_mm_vvc_config**

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| inter_bfm_delay              | :ref:`t_inter_bfm_delay`     | C_AVALON_MM_INT\| Delay between any requested BFM accesses        |
|                              |                              | ER_BFM_DELAY_DE\| towards the DUT.                                |
|                              |                              | FAULT           |                                                 |
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
| bfm_config                   | :ref:`t_avalon_mm_bfm_config | C_AVALON_MM_BFM\| Configuration for the Avalon-MM BFM             |
|                              | <t_avalon_mm_bfm_config>`    | _CONFIG_DEFAULT |                                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| use_read_pipeline            | boolean                      | true            | When true, allows sending multiple read requests|
|                              |                              |                 | before receiving a read response                |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| num_pipeline_stages          | natural                      | 5               | Max read_requests in pipeline                   |
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

    shared_avalon_mm_vvc_config(C_VVC_IDX).inter_bfm_delay.delay_in_time := 50 ns;
    shared_avalon_mm_vvc_config(C_VVC_IDX).bfm_config.use_waitrequest := true;

Status Record
==================================================================================================================================
**vvc_status** accessible via **shared_avalon_mm_vvc_status**

.. include:: rst_snippets/vip_vvc_status.rst

Methods
==================================================================================================================================
* All VVC procedures are defined in vvc_methods_pkg.vhd (dedicated to this VVC).
* See :ref:`vvc_framework_methods` for procedures which are common to all VVCs.
* It is also possible to send a multicast to all instances of a VVC with ALL_INSTANCES as parameter for vvc_instance_idx.
* All parameters in brackets are optional.


.. _avalon_mm_write_vvc:

avalon_mm_write()
----------------------------------------------------------------------------------------------------------------------------------
Adds a write command to the Avalon-MM VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the BFM :ref:`avalon_mm_write_bfm` procedure. 
The avalon_mm_write() procedure can be called with or without byte_enable constant. When not set, byte_enable is interpreted as 
all '1', indicating that all bytes are valid. 

.. code-block::

    avalon_mm_write(VVCT, vvc_instance_idx, addr, data, [byte_enable,] msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | addr               | in     | unsigned                     | The address of an Avalon-MM accessible register         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The data value to be written to the addressed register  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | byte_enable        | in     | std_logic_vector             | Selects which bytes to use (all '1' means all bytes are |
|          |                    |        |                              | updated)                                                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_mm_write(AVALON_MM_VVCT, 0, x"11221100", x"0000F102", "Writing to Peripheral 1", C_SCOPE);
    avalon_mm_write(AVALON_MM_VVCT, 0, C_ADDR_DMA, x"F102", "1111", "Writing to DMA", C_SCOPE); 


.. _avalon_mm_read_vvc:

avalon_mm_read()
----------------------------------------------------------------------------------------------------------------------------------
Adds a read command to the Avalon-MM VVC executor queue, which will run as soon as all preceding commands have completed. When the 
command is scheduled to run, the executor calls the :ref:`avalon_mm_read_bfm` procedure. 

The value read from DUT will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but the read 
data will be stored in the VVC for a potential future fetch (see example with fetch_result below). 
If the data_routing is set to TO_SB, the read data will be sent to the Avalon-MM VVC dedicated scoreboard where it will be 
checked against the expected value (provided by the testbench).

**Using read pipeline:**
If vvc_config.use_read_pipeline has been set to true, the VVC will perform the read transaction using the BFM procedures 
:ref:`avalon_mm_read_request_bfm` and :ref:`avalon_mm_read_response_bfm`. First, the VVC executor will check if the number of 
pending commands in the pipeline will exceed the number of pipeline stages. If this is the case, the VVC executor will stall the 
read transaction until a command in the pipeline has been executed. The command executor will then let the BFM start the read 
request. After the read request has completed, the command will be added to the command response queue, which will run the BFM 
procedure avalon_mm_read_response().  

.. code-block::

    avalon_mm_read(VVCT, vvc_instance_idx, addr, [data_routing,] msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | addr               | in     | unsigned                     | The address of an Avalon-MM accessible register         |
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
    avalon_mm_read(AVALON_MM_VVCT, 0, x"112252AA", "Receiving data from source", C_SCOPE);
    avalon_mm_read(AVALON_MM_VVCT, 0, x"112252AA", TO_SB, "Receiving data from source and sending to Scoreboard", C_SCOPE);

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last read
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from read (data and metadata)
    ...
    avalon_mm_read(AVALON_MM_VVCT, 0, x"112252AA", "Read from Peripheral 1", C_SCOPE); 
    v_cmd_idx := get_last_received_cmd_idx(AVALON_MM_VVCT, 0);               
    await_completion(AVALON_MM_VVCT, 0, v_cmd_idx, 100 ns, "Wait for receive to finish");
    fetch_result(AVALON_MM_VVCT, 0, v_cmd_idx, v_result, "Fetching result from read operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.


.. _avalon_mm_check_vvc:

avalon_mm_check()
----------------------------------------------------------------------------------------------------------------------------------
Adds a check command to the Avalon-MM VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the :ref:`avalon_mm_check_bfm` procedure. 
The avalon_mm_check() procedure will perform a read operation, then check if the read data is equal to the 'data' parameter. If 
the read data is not equal to the expected 'data' parameter, an alert with severity 'alert_level' will be issued. The read data 
will not be stored by this procedure.

**Using read pipeline:**
If vvc_config.use_read_pipeline has been set to true, the VVC will perform the check transaction using the BFM procedures 
:ref:`avalon_mm_read_request_bfm` and :ref:`avalon_mm_read_response_bfm`, similar to the procedure described in :ref:`avalon_mm_read_vvc`. 

.. code-block::

    avalon_mm_check(VVCT, vvc_instance_idx, addr, data, msg, [alert_level, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | addr               | in     | unsigned                     | The address of an Avalon-MM accessible register         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The data value to expect when reading the addressed     |
|          |                    |        |                              | register. A mismatch results in an alert 'alert_level'  |
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
    avalon_mm_check(AVALON_MM_VVCT, 0, x"11A49800", x"0000393B", "Check data from Peripheral 1", ERROR, C_SCOPE);


.. _avalon_mm_reset_vvc:

avalon_mm_reset()
----------------------------------------------------------------------------------------------------------------------------------
Adds a reset command to the Avalon-MM VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the :ref:`avalon_mm_reset_bfm` procedure. 

.. code-block::

    avalon_mm_reset(VVCT, vvc_instance_idx, num_rst_cycles, msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | num_rst_cycles     | in     | integer                      | Number of cycles to hold the reset signal active        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_mm_reset(AVALON_MM_VVCT, 0, 5, "Resetting Avalon-MM Interface", C_SCOPE);


.. _avalon_mm_lock_vvc:

avalon_mm_lock()
----------------------------------------------------------------------------------------------------------------------------------
Adds a lock command to the Avalon-MM VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the :ref:`avalon_mm_lock_bfm` procedure. 

.. code-block::

    avalon_mm_lock(VVCT, vvc_instance_idx, msg, [scope])

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
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_mm_lock(AVALON_MM_VVCT, 0, "Locking Avalon-MM Interface", C_SCOPE);


.. _avalon_mm_unlock_vvc:

avalon_mm_unlock()
----------------------------------------------------------------------------------------------------------------------------------
Adds an unlock command to the Avalon-MM VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the :ref:`avalon_mm_unlock_bfm` procedure. 

.. code-block::

    avalon_mm_unlock(VVCT, vvc_instance_idx, msg, [scope])

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
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_mm_unlock(AVALON_MM_VVCT, 0, "Unlocking Avalon-MM Interface", C_SCOPE);


Activity Watchdog
==================================================================================================================================
.. include:: rst_snippets/vip_activity_watchdog.rst


Transaction Info
==================================================================================================================================
.. include:: rst_snippets/vip_transaction_info.rst

.. table:: Avalon-MM transaction info record fields. Transaction Type: t_base_transaction (BT) - accessible via **shared_avalon_mm_vvc_transaction_info.bt**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | addr                         | unsigned(63 downto 0)        | 0x0             | Address of the Avalon-MM read or write          |
    |                              |                              |                 | transaction                                     |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | data                         | std_logic_vector(1023 downto | 0x0             | Data of the Avalon-MM read or write transaction |
    |                              | 0)                           |                 |                                                 |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | byte_enable                  | std_logic_vector(127 downto  | 0x0             | Used to indicate which data bytes to use. When  |
    |                              | 0)                           |                 | all bits are set to '1', all bytes are enabled. |
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

.. table:: Avalon-MM transaction info record fields. Transaction Type: t_sub_transaction (ST) - accessible via **shared_avalon_mm_vvc_transaction_info.st**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | addr                         | unsigned(63 downto 0)        | 0x0             | Address of the Avalon-MM read or write          |
    |                              |                              |                 | transaction                                     |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | data                         | std_logic_vector(1023 downto | 0x0             | Data of the Avalon-MM read or write transaction |
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
i.e. avalon_mm_read(). Note that the data is only stored in the scoreboard and not accessible with the fetch_result() method when 
the TO_SB parameter is applied. The Avalon-MM scoreboard is accessible from the testbench as a shared variable AVALON_MM_VVC_SB, 
located in the vvc_methods_pkg.vhd, e.g. ::

    AVALON_MM_VVC_SB.add_expected(C_AVALON_MM_VVC_IDX, pad_avalon_mm_sb(v_expected), "Adding expected");

The Avalon-MM scoreboard is per default a 1024 bits wide standard logic vector. When sending expected data to the scoreboard, where the 
data width is smaller than the default scoreboard width, we recommend zero-padding the data with the pad_avalon_mm_sb() function, e.g. ::

    AVALON_MM_VVC_SB.add_expected(<Avalon-MM VVC instance number>, pad_avalon_mm_sb(<exp data>));

See the :ref:`vip_scoreboard` for a complete list of available commands and additional information. All of the listed Generic
Scoreboard commands are available for the Avalon-MM VVC scoreboard using the AVALON_MM_VVC_SB.


Unwanted Activity Detection
==================================================================================================================================
.. include:: rst_snippets/vip_unwanted_activity.rst

.. code-block::

    shared_avalon_mm_vvc_config(C_VVC_INDEX).unwanted_activity_severity := NO_ALERT;

The unwanted activity detection is ignored when the readdatavalid signal goes low within one clock period after the VVC becomes 
inactive. This is to handle the situation when the read command exits before the next rising edge, causing signal transitions 
during the first clock cycle after the VVC is inactive. 

For Avalon-MM VVC, the unwanted activity detection is enabled by default with severity ERROR.

More information can be found in :ref:`Essential Mechanisms - Unwanted Activity Detection <vvc_framework_unwanted_activity>`.


Compilation
==================================================================================================================================
The Avalon-MM VVC must be compiled with VHDL-2008 or newer. It is dependent on the following libraries:

    * UVVM Utility Library (UVVM-Util)
    * UVVM VVC Framework
    * Bitvis VIP Scoreboard
    * Avalon-MM BFM

Before compiling the Avalon-MM VVC, assure that uvvm_util, uvvm_vvc_framework and bitvis_vip_scoreboard have been compiled.

See :ref:`Essential Mechanisms - Compile Scripts <vvc_framework_compile_scripts>` for information about compile scripts.

.. table:: Compile order for the Avalon-MM VVC

    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | Compile to library           | File                                           | Comment                                         |
    +==============================+================================================+=================================================+
    | bitvis_vip_avalon_mm         | avalon_mm_bfm_pkg.vhd                          | Avalon-MM BFM                                   |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_avalon_mm         | transaction_pkg.vhd                            | Avalon-MM transaction package with DTT types,   |
    |                              |                                                | constants, etc.                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_avalon_mm         | vvc_cmd_pkg.vhd                                | Avalon-MM VVC command types and operations      |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_avalon_mm         | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC target support package, compiled into  |
    |                              | _target_support_pkg.vhd                        | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_avalon_mm         | ../uvvm_vvc_framework/src_target_dependent/td\ | Common UVVM framework methods compiled into the |
    |                              | _vvc_framework_common_methods_pkg.vhd          | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_avalon_mm         | vvc_sb_pkg.vhd                                 | Avalon-MM VVC scoreboard                        |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_avalon_mm         | vvc_methods_pkg.vhd                            | Avalon-MM VVC methods                           |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_avalon_mm         | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM queue package for this VVC                 |
    |                              | _queue_pkg.vhd                                 |                                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_avalon_mm         | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC entity support compiled into this      |
    |                              | _vvc_entity_support_pkg.vhd                    | VVC library                                     |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_avalon_mm         | avalon_mm_vvc.vhd                              | Avalon-MM VVC                                   |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_avalon_mm         | vvc_context.vhd                                | Avalon-MM VVC context file                      |
    +------------------------------+------------------------------------------------+-------------------------------------------------+

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


Additional Documentation
==================================================================================================================================
For more information on the Avalon-MM specification, refer to "Avalon® Interface Specifications, Chapter: Avalon Memory-Mapped 
Interfaces" (MNL-AVABUSREF), available from Intel.

.. important::

    * This is a simplified Verification IP (VIP) for Avalon-MM.
    * The given VIP complies with the basic Avalon-MM protocol and thus allows a normal access towards an Avalon-MM interface.
    * This VIP is not an Avalon-MM protocol checker.
    * For a more advanced VIP please contact UVVM support at info@uvvm.org

.. include:: rst_snippets/ip_disclaimer.rst
