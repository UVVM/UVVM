##################################################################################################################################
Bitvis VIP I2C
##################################################################################################################################

**Quick Access**

* `BFM`_

  * :ref:`i2c_master_transmit_bfm`
  * :ref:`i2c_master_receive_bfm`
  * :ref:`i2c_master_check_bfm`
  * :ref:`i2c_master_quick_command_bfm`
  * :ref:`init_i2c_if_signals_bfm`
  * :ref:`i2c_slave_transmit_bfm`
  * :ref:`i2c_slave_receive_bfm`
  * :ref:`i2c_slave_check_bfm`

* `VVC`_

  * :ref:`i2c_master_transmit_vvc`
  * :ref:`i2c_master_receive_vvc`
  * :ref:`i2c_master_check_vvc`
  * :ref:`i2c_master_quick_command_vvc`
  * :ref:`i2c_slave_transmit_vvc`
  * :ref:`i2c_slave_receive_vvc`
  * :ref:`i2c_slave_check_vvc`


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
BFM
**********************************************************************************************************************************
BFM functionality is implemented in i2c_bfm_pkg.vhd

.. _t_i2c_if:

Signal Record
==================================================================================================================================
**t_i2c_if**

+-------------------------+------------------------------+
| Record element          | Type                         |
+=========================+==============================+
| scl                     | std_logic                    |
+-------------------------+------------------------------+
| sda                     | std_logic                    |
+-------------------------+------------------------------+

.. note::

    BFM calls can also be made with listing of single signals rather than t_i2c_if.

.. _t_i2c_bfm_config:

Configuration Record
==================================================================================================================================
**t_i2c_bfm_config**

Default value for the record is C_I2C_BFM_CONFIG_DEFAULT.

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| enable_10_bits_addressing    | boolean                      | false           | True: 10-bits addressing enabled. False: 7-bits |
|                              |                              |                 | addressing enabled.                             |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| master_sda_to_scl            | time                         | 20 ns           | Time from activation of SDA until activation of |
|                              |                              |                 | SCL. Used for start condition.                  |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| master_scl_to_sda            | time                         | 20 ns           | Time from last SCL until SDA off. Used for stop |
|                              |                              |                 | condition.                                      |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| master_stop_condition_hold_t\| time                         | 20 ns           | Ensures that the master holds the stop condition|
| ime                          |                              |                 | for a certain amount of time before the next    |
|                              |                              |                 | operation is started.                           |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| max_wait_scl_change          | time                         | 10 ms           | Timeout when checking the SCL active period.    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| max_wait_scl_change_severity | :ref:`t_alert_level`         | failure         | The above timeout will have this severity.      |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| max_wait_sda_change          | time                         | 10 ms           | Used when receiving and in slave transmit.      |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| max_wait_sda_change_severity | :ref:`t_alert_level`         | failure         | The above timeout will have this severity.      |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| i2c_bit_time                 | time                         | -1 ns           | Bit period. Will give a TB_ERROR if not set to  |
|                              |                              |                 | a different value than -1.                      |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| i2c_bit_time_severity        | :ref:`t_alert_level`         | failure         | A master method will report an alert with this  |
|                              |                              |                 | severity if a slave performs clock stretching   |
|                              |                              |                 | for longer than i2c_bit_time.                   |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| acknowledge_severity         | :ref:`t_alert_level`         | failure         | Severity of alert if message not acknowledged.  |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| slave_mode_address           | unsigned(9 downto 0)         | 0               | The slave methods expect to receive this address|
|                              |                              |                 | from the I2C master DUT.                        |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| slave_mode_address_severity  | :ref:`t_alert_level`         | failure         | The methods will report an alert with this      |
|                              |                              |                 | severity if the address format is wrong or the  |
|                              |                              |                 | address is not as expected.                     |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| slave_rw_bit_severity        | :ref:`t_alert_level`         | failure         | The methods will report an alert with this      |
|                              |                              |                 | severity if the Read/Write bit is not as        |
|                              |                              |                 | expected.                                       |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| reserved_address_severity    | :ref:`t_alert_level`         | warning         | The methods will trigger an alert with this     |
|                              |                              |                 | severity if the slave address is equal to one   |
|                              |                              |                 | of the reserved addresses from the NXP I2C      |
|                              |                              |                 | Specification.                                  |
|                              |                              |                 |                                                 |
|                              |                              |                 | For a list of reserved addresses, please see    |
|                              |                              |                 | :ref:`i2c_additional_doc`                       |
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
| id_for_bfm_poll              | t_msg_id                     | ID_BFM_POLL     | Message ID used for logging polling in the BFM  |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

Methods
==================================================================================================================================
* The record :ref:`t_i2c_if <t_i2c_if>` can be replaced with the signals listed in said record.
* All signals are active high.
* All parameters in brackets are optional.

.. note::

    The BFM configuration has to be defined and used when calling the I2C BFM procedures. See :ref:`i2c_local_bfm_config` for an 
    example of how to define a local BFM config.


.. _i2c_master_transmit_bfm:

i2c_master_transmit()
----------------------------------------------------------------------------------------------------------------------------------
Transmits the data to the slave DUT at the specified address using the I2C protocol. For protocol details, see :ref:`i2c_additional_doc`.

The procedure reports an alert if:

    * The i2c_if signals do not change within the timeouts given in config. Verifies that the bus is alive.
    * The 'addr_value' is wider than 7 bits in 7-bit addressing mode.
    * The 'addr_value' is wider than 10 bits in 10-bit addressing mode.
    * The 'addr_value' is equal to a I2C specification reserved address in 7-bit addressing mode.
    * If 'data' is of type std_logic_vector: The data is wider than 8 bits.
    * If 'data' is of type t_byte_array: The byte array is descending (using downto).
    * A slave holds the 'scl' signal low for longer than 'config.i2c_bit_time'.
    * The acknowledge bit set by the slave DUT after every transmitted byte is not '0'.

.. code-block::

    i2c_master_transmit(addr_value, data, msg, i2c_if, [action_when_transfer_is_done, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | Slave address. Valid address lengths are 7 bits and 10  |
|          |                    |        |                              | bits. 7-bit addresses with the four most-significant    |
|          |                    |        |                              | bits equal to x"0" and x"F" are reserved by the I2C     |
|          |                    |        |                              | standard. For a list of reserved addresses, please see  |
|          |                    |        |                              | :ref:`i2c_additional_doc`                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The data value to be transmitted to the DUT, either a   |
|          |                    |        |                              | single byte or a byte array.                            |
|          |                    |        | t_byte_array                 |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | i2c_if             | inout  | :ref:`t_i2c_if <t_i2c_if>`   | I2C signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether or not the I2C master method shall generate a   |
|          | er_is_done         |        | _is_done`                    | stop condition after the operation is finished. Default |
|          |                    |        |                              | value is RELEASE_LINE_AFTER_TRANSFER.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("I2C BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_i2c_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_i2c_bfm_config>`          | value is C_I2C_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    i2c_master_transmit(x"AA", x"10", "Transmitting data to peripheral 1", i2c_if);
    i2c_master_transmit(x"AA", byte_array(0 to 3), "Transmitting data to peripheral 1", i2c_if, RELEASE_LINE_AFTER_TRANSFER, 
                        C_SCOPE, shared_msg_id_panel, C_I2C_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    i2c_master_transmit(C_ASCII_A, "Transmitting ASCII A to DUT");


.. _i2c_master_receive_bfm:

i2c_master_receive()
----------------------------------------------------------------------------------------------------------------------------------
Receives data from the slave DUT at the specified address using the I2C protocol and stores it in 'data_output'. For protocol 
details, see :ref:`i2c_additional_doc`.

The procedure will report alerts for the same conditions as the :ref:`i2c_master_transmit_bfm` procedure.

.. code-block::

    i2c_master_receive(addr_value, data, msg, i2c_if, [action_when_transfer_is_done, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | Slave address. Valid address lengths are 7 bits and 10  |
|          |                    |        |                              | bits. 7-bit addresses with the four most-significant    |
|          |                    |        |                              | bits equal to x"0" and x"F" are reserved by the I2C     |
|          |                    |        |                              | standard. For a list of reserved addresses, please see  |
|          |                    |        |                              | :ref:`i2c_additional_doc`                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | data               | out    | std_logic_vector             | The data value read from the addressed register, either |
|          |                    |        |                              | a single byte or a byte array.                          |
|          |                    |        | t_byte_array                 |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | i2c_if             | inout  | :ref:`t_i2c_if <t_i2c_if>`   | I2C signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether or not the I2C master method shall generate a   |
|          | er_is_done         |        | _is_done`                    | stop condition after the operation is finished. Default |
|          |                    |        |                              | value is RELEASE_LINE_AFTER_TRANSFER.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("I2C BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_i2c_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_i2c_bfm_config>`          | value is C_I2C_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    i2c_master_receive(x"BB", v_data_out, "Receive from Peripheral 1", i2c_if);
    i2c_master_receive(x"BB", v_data_out, "Receive from Peripheral 1", i2c_if, RELEASE_LINE_AFTER_TRANSFER, 
                       C_SCOPE, shared_msg_id_panel, C_I2C_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    i2c_master_receive(v_data_out, "Receive from Peripheral 1");


.. _i2c_master_check_bfm:

i2c_master_check()
----------------------------------------------------------------------------------------------------------------------------------
Receives data from the slave DUT at the given address, using the receive procedure as described in :ref:`i2c_master_receive_bfm`. 
After receiving data, the data is compared with the expected data.

* If the check was successful, and the received data matches the expected data, a log message is written with ID 'config.id_for_bfm'.
* If the received data did not match the expected data, an alert with severity 'alert_level' will be reported.
* The procedure will report alerts for the same conditions as the :ref:`i2c_master_transmit_bfm` procedure.

.. code-block::

    i2c_master_check(addr_value, data_exp, msg, i2c_if, [action_when_transfer_is_done, [alert_level, [scope, [msg_id_panel, [config]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | Slave address. Valid address lengths are 7 bits and 10  |
|          |                    |        |                              | bits. 7-bit addresses with the four most-significant    |
|          |                    |        |                              | bits equal to x"0" and x"F" are reserved by the I2C     |
|          |                    |        |                              | standard. For a list of reserved addresses, please see  |
|          |                    |        |                              | :ref:`i2c_additional_doc`                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_logic_vector             | The data value to expect when receiving the addressed   |
|          |                    |        |                              | register, either a single byte or a byte array. A       |
|          |                    |        | t_byte_array                 | mismatch results in an alert with severity 'alert_level'|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | i2c_if             | inout  | :ref:`t_i2c_if <t_i2c_if>`   | I2C signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether or not the I2C master method shall generate a   |
|          | er_is_done         |        | _is_done`                    | stop condition after the operation is finished. Default |
|          |                    |        |                              | value is RELEASE_LINE_AFTER_TRANSFER.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("I2C BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_i2c_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_i2c_bfm_config>`          | value is C_I2C_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    i2c_master_check(x"CC", x"3B", "Expect data on I2C", i2c_if, RELEASE_LINE_AFTER_TRANSFER, ERROR);
    i2c_master_check(x"CC", x"3B", "Expect data on I2C", i2c_if, RELEASE_LINE_AFTER_TRANSFER, ERROR, 
                   C_SCOPE, shared_msg_id_panel, C_I2C_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    i2c_master_check(C_CR_BYTE, x"3B", "Expecting carriage return");


.. _i2c_master_quick_command_bfm:

i2c_master_quick_command()
----------------------------------------------------------------------------------------------------------------------------------
Transmits a zero-byte message to a slave DUT at the specified address using the I2C protocol.

* The procedure will report alerts for the same conditions as the :ref:`i2c_master_transmit_bfm` procedure.
* It will also report an error of 'alert_level' severity if 'exp_ack' is false and the DUT acks the quick command or if 'exp_ack' 
  is true and the DUT does not ack the quick command.

.. code-block::

    i2c_master_quick_command(addr_value, msg, i2c_if, [rw_bit, [exp_ack, [action_when_transfer_is_done, [alert_level, [scope, [msg_id_panel, [config]]]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | Slave address. Valid address lengths are 7 bits and 10  |
|          |                    |        |                              | bits. 7-bit addresses with the four most-significant    |
|          |                    |        |                              | bits equal to x"0" and x"F" are reserved by the I2C     |
|          |                    |        |                              | standard. For a list of reserved addresses, please see  |
|          |                    |        |                              | :ref:`i2c_additional_doc`                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | i2c_if             | inout  | :ref:`t_i2c_if <t_i2c_if>`   | I2C signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | rw_bit             | in     | std_logic                    | Expected R/W bit. '1': read, '0': write. Default value  |
|          |                    |        |                              | is '0' (write).                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | exp_ack            | in     | boolean                      | Set to true or false depending on whether or not the    |
|          |                    |        |                              | slave is expected to acknowledge the quick command.     |
|          |                    |        |                              | Default value is true.                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether or not the I2C master method shall generate a   |
|          | er_is_done         |        | _is_done`                    | stop condition after the operation is finished. Default |
|          |                    |        |                              | value is RELEASE_LINE_AFTER_TRANSFER.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("I2C BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_i2c_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_i2c_bfm_config>`          | value is C_I2C_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    i2c_master_quick_command(x"AA", "Pinging I2C slave, expecting ACK", i2c_if);
    i2c_master_quick_command(x"AA", "Sending read QC to I2C slave", i2c_if, '1', true, HOLD_LINE_AFTER_TRANSFER, ERROR, 
                             C_SCOPE, shared_msg_id_panel, C_I2C_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    i2c_master_quick_command(C_ADDR_S1, "Pinging I2C slave, expecting ACK");


.. _i2c_slave_transmit_bfm:

i2c_slave_transmit()
----------------------------------------------------------------------------------------------------------------------------------
Transmits the data to the master DUT using the I2C protocol. For protocol details, see :ref:`i2c_additional_doc`.

The procedure reports an alert if:

    * The i2c_if signals do not change within the timeouts given in config. Verifies that the bus is alive.
    * The 'config.slave_mode_address' has its 3 most-significant bits (9-7) set when in 7-bit addressing mode.
    * The 'config.slave_mode_address' is equal to a I2C specification reserved address in 7-bit addressing mode.
    * If 'data' is of type std_logic_vector: The data is wider than 8 bits.
    * If 'data' is of type t_byte_array: The byte array is descending (using downto).
    * The received address is not equal to the address set in 'config.slave_mode_address'.
    * The Read/Write bit received from the master is not as expected.
    * The acknowledge bit set by the master DUT after every transmitted byte is not as expected. Expects ACK ('0') after every 
      byte except the very last byte where a NACK ('1') is expected.

.. code-block::

    i2c_slave_transmit(data, msg, i2c_if, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | data               | in     | std_logic_vector             | The data value to be transmitted to the DUT, either a   |
|          |                    |        |                              | single byte or a byte array.                            |
|          |                    |        | t_byte_array                 |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | i2c_if             | inout  | :ref:`t_i2c_if <t_i2c_if>`   | I2C signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("I2C BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_i2c_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_i2c_bfm_config>`          | value is C_I2C_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    i2c_slave_transmit(x"AA", "Transmitting data to master", i2c_if);
    i2c_slave_transmit(x"AA", "Transmitting data to master", i2c_if, C_SCOPE, shared_msg_id_panel, C_I2C_BFM_CONFIG_DEFAULT);
    
    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    i2c_slave_transmit(C_ASCII_A, "Transmitting ASCII A to master");


.. _i2c_slave_receive_bfm:

i2c_slave_receive()
----------------------------------------------------------------------------------------------------------------------------------
Receives data from the master DUT using the I2C protocol and stores it in 'data'. For protocol details, see :ref:`i2c_additional_doc`.

The procedure will report alerts for the same conditions as the :ref:`i2c_slave_transmit_bfm` procedure.

.. code-block::

    i2c_slave_receive(data, msg, i2c_if, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| variable | data               | out    | std_logic_vector             | The data value read from the addressed register, either |
|          |                    |        |                              | a single byte or a byte array.                          |
|          |                    |        | t_byte_array                 |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | i2c_if             | inout  | :ref:`t_i2c_if <t_i2c_if>`   | I2C signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("I2C BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_i2c_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_i2c_bfm_config>`          | value is C_I2C_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    i2c_slave_receive(v_data_out, "Receive from master", i2c_if);
    i2c_slave_receive(v_data_out, "Receive from master", i2c_if, C_SCOPE, shared_msg_id_panel, C_I2C_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    i2c_slave_receive(v_data_out, "Receive from master");


.. _i2c_slave_check_bfm:

i2c_slave_check()
----------------------------------------------------------------------------------------------------------------------------------
Receives data from the master DUT, using the receive procedure as described in :ref:`i2c_slave_receive_bfm`. 
After receiving data, the data is compared with the expected data.

* If the check was successful, and the received data matches the expected data, a log message is written with ID 'config.id_for_bfm'.
* If the received data did not match the expected data, an alert with severity 'alert_level' will be reported.
* The procedure will report alerts for the same conditions as the :ref:`i2c_slave_transmit_bfm` procedure.

.. code-block::

    i2c_slave_check(data_exp, msg, i2c_if, [exp_rw_bit, [alert_level, [scope, [msg_id_panel, [config]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | data_exp           | in     | std_logic_vector             | The data value to expect when receiving the addressed   |
|          |                    |        |                              | register, either a single byte or a byte array. A       |
|          |                    |        | t_byte_array                 | mismatch results in an alert with severity 'alert_level'|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | i2c_if             | inout  | :ref:`t_i2c_if <t_i2c_if>`   | I2C signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | exp_rw_bit         | inout  | std_logic                    | Expected R/W bit. '1': read, '0': write. Default value  |
|          |                    |        |                              | is '0' (write). If this parameter is set to '1' (read)  |
|          |                    |        |                              | the data_exp parameter needs to be an empty byte_array, |
|          |                    |        |                              | otherwise, an error will be reported.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("I2C BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_i2c_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_i2c_bfm_config>`          | value is C_I2C_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    i2c_slave_check(x"3B", "Expect data on I2C", i2c_if);
    i2c_slave_check(x"3B", "Expect data on I2C", i2c_if, C_WRITE_BIT, ERROR, C_SCOPE, shared_msg_id_panel, C_I2C_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    i2c_slave_check(C_CR_BYTE, "Expecting carriage return");


.. _init_i2c_if_signals_bfm:

init_i2c_if_signals()
----------------------------------------------------------------------------------------------------------------------------------
Initializes the I2C interface. All the BFM outputs are set to '0', and BFM inputs are set to 'Z'.

.. code-block::

    t_i2c_if := init_i2c_if_signals(VOID)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    i2c_if <= init_i2c_if_signals(VOID);


Local BFM overloads
==================================================================================================================================
A good approach for better readability and maintainability is to make simple, local overloads for the BFM procedures in the TB 
process. This allows calling the BFM procedures with the key parameters only, e.g. ::

    i2c_master_transmit(C_SLAVE_ADDR, C_ASCII_A, "Transmitting ASCII A");

rather than ::

    i2c_master_transmit(C_SLAVE_ADDR, C_ASCII_A, "Transmitting ASCII A", i2c_if, RELEASE_LINE_AFTER_TRANSFER, C_SCOPE, shared_msg_id_panel, C_I2C_CONFIG_LOCAL);

By defining the local overload as e.g. ::

    procedure i2c_master_transmit(
      constant addr_value : in unsigned;
      constant data_value : in std_logic_vector;
      constant msg        : in string) is
    begin
      i2c_master_transmit(addr_value,                  -- Keep as is
                          data_value,                  -- Keep as is
                          msg,                         -- Keep as is
                          i2c_if,                      -- Signal must be visible in local process scope
                          RELEASE_LINE_AFTER_TRANSFER, -- Shall generate stop condition at the end of every transmit
                          C_SCOPE,                     -- Use the default
                          shared_msg_id_panel,         -- Use global, shared msg_id_panel
                          C_I2C_CONFIG_LOCAL);         -- Use locally defined configuration or C_I2C_CONFIG_DEFAULT
    end procedure;

Using a local overload like this also allows the following – if wanted:

* Have address value as natural – and convert in the overload
* Set up defaults for constants. May be different for two overloads of the same BFM
* Apply dedicated message ID panel to allow dedicated verbosity control


.. _i2c_local_bfm_config:

Local BFM configuration
==================================================================================================================================
The I2C BFM requires that a local configuration is declared in the testbench and used in the BFM procedure calls. The default BFM 
configuration is defined with a I2C bit time of -1 ns so that the BFM can detect and alert the user that the configuration has not 
been set.

Defining a local I2C BFM configuration:::

    constant C_I2C_CONFIG_LOCAL : t_i2c_bfm_config := (
      enable_10_bits_addressing       => false,
      master_sda_to_scl               => 400 ns,
      master_scl_to_sda               => 505 ns,
      master_stop_condition_hold_time => 505 ns,
      max_wait_scl_change             => 10 ms,
      max_wait_scl_change_severity    => failure,
      max_wait_sda_change             => 10 ms,
      max_wait_sda_change_severity    => failure,
      i2c_bit_time                    => 1100 ns,
      i2c_bit_time_severity           => failure,
      acknowledge_severity            => failure,
      slave_mode_address              => C_I2C_SLAVE_DUT_ADDR,
      slave_mode_address_severity     => failure,
      slave_rw_bit_severity           => failure,
      reserved_address_severity       => warning,
      match_strictness                => MATCH_EXACT,
      id_for_bfm                      => ID_BFM,
      id_for_bfm_wait                 => ID_BFM_WAIT,
      id_for_bfm_poll                 => ID_BFM_POLL
    );


Compilation
==================================================================================================================================
.. include:: rst_snippets/bfm_compilation.rst

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


.. _i2c_additional_doc:

Additional Documentation
==================================================================================================================================
For additional documentation on the I2C protocol, please see the NXP I2C specification "UM10204 I2C-bus specification and user 
manual Rev. 6", available from NXP Semiconductors.

.. important::

    * This is a simplified Bus Functional Model (BFM) for I2C.
    * The given BFM complies with the basic I2C protocol and thus allows a normal access towards a I2C interface.
    * This BFM is not a I2C protocol checker.
    * For a more advanced BFM please contact UVVM support at info@uvvm.org


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
VVC
**********************************************************************************************************************************
* VVC functionality is implemented in i2c_vvc.vhd
* For general information see :ref:`VVC Framework - Essential Mechanisms <vvc_framework_essential_mechanisms>`.

Entity
==================================================================================================================================

Generics
----------------------------------------------------------------------------------------------------------------------------------

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Name                         | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| GC_INSTANCE_IDX              | natural                      | 1               | Instance number to assign the VVC               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_MASTER_MODE               | boolean                      | true            | When set to 'true' the VVC may only use the     |
|                              |                              |                 | 'i2c_master_<transmit/check>' methods. When set |
|                              |                              |                 | to 'false' it may only use the                  |
|                              |                              |                 | 'i2c_slave_<transmit/check>' methods.           |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_I2C_CONFIG                | :ref:`t_i2c_bfm_config       | C_I2C_BFM_CONFI\| Configuration for the I2C BFM                   |
|                              | <t_i2c_bfm_config>`          | G_DEFAULT       |                                                 |
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
| signal   | i2c_vvc_if         | inout  | :ref:`t_i2c_if <t_i2c_if>`   | I2C signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

Configuration Record
==================================================================================================================================
**vvc_config** accessible via **shared_i2c_vvc_config**

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| inter_bfm_delay              | :ref:`t_inter_bfm_delay`     | C_I2C_INTER_BFM\| Delay between any requested BFM accesses        |
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
| bfm_config                   | :ref:`t_i2c_bfm_config       | C_I2C_BFM_CONFI\| Configuration for the I2C BFM                   |
|                              | <t_i2c_bfm_config>`          | G_DEFAULT       |                                                 |
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

    shared_i2c_vvc_config(C_VVC_IDX).inter_bfm_delay.delay_in_time := 50 ns;
    shared_i2c_vvc_config(C_VVC_IDX).bfm_config.i2c_bit_time := 100 ns;

Status Record
==================================================================================================================================
**vvc_status** accessible via **shared_i2c_vvc_status**

.. include:: rst_snippets/vip_vvc_status.rst

Methods
==================================================================================================================================
* All VVC procedures are defined in vvc_methods_pkg.vhd (dedicated to this VVC).
* See :ref:`vvc_framework_methods` for procedures which are common to all VVCs.
* It is also possible to send a multicast to all instances of a VVC with ALL_INSTANCES as parameter for vvc_instance_idx.
* All parameters in brackets are optional.


.. _i2c_master_transmit_vvc:

i2c_master_transmit()
----------------------------------------------------------------------------------------------------------------------------------
Adds a master transmit command to the I2C VVC executor queue, which will run as soon as all preceding commands have completed. 
When the command is scheduled to run, the executor calls the BFM :ref:`i2c_master_transmit_bfm` procedure. This procedure can only 
be called when the I2C VVC is instantiated in master mode, i.e. setting the VVC entity generic constant 'GC_MASTER_MODE' to 'true'.

.. code-block::

    i2c_master_transmit(VVCT, vvc_instance_idx, addr, data, msg, [action_when_transfer_is_done, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | addr               | in     | unsigned                     | Slave address. Valid address lengths are 7 bits and 10  |
|          |                    |        |                              | bits. 7-bit addresses with the four most-significant    |
|          |                    |        |                              | bits equal to x"0" and x"F" are reserved by the I2C     |
|          |                    |        |                              | standard. For a list of reserved addresses, please see  |
|          |                    |        |                              | :ref:`i2c_additional_doc`                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The data value to be transmitted to the DUT, either a   |
|          |                    |        |                              | single byte or a byte array.                            |
|          |                    |        | t_byte_array                 |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether or not the I2C master method shall generate a   |
|          | er_is_done         |        | _is_done`                    | stop condition after the operation is finished. Default |
|          |                    |        |                              | value is RELEASE_LINE_AFTER_TRANSFER.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    i2c_master_transmit(I2C_VVCT, 0, C_SLAVE_0_ADDR,  x"0D", "Transmitting data to slave 0");
    i2c_master_transmit(I2C_VVCT, 0, C_SLAVE_1_ADDR,  byte_array(0 to 3), "Transmitting byte array to slave 1 without generating stop condition at the end", HOLD_LINE_AFTER_TRANSFER, C_SCOPE);


.. _i2c_master_receive_vvc:

i2c_master_receive()
----------------------------------------------------------------------------------------------------------------------------------
Adds a master receive command to the I2C VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the BFM :ref:`i2c_master_receive_bfm` procedure.

The received data will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but the received 
data will be stored in the VVC for a potential future fetch (see example with fetch_result below). 
If the data_routing is set to TO_SB, the received data will be sent to the I2C VVC dedicated scoreboard where it will be 
checked against the expected value (provided by the testbench). This procedure can only be called when the I2C VVC is instantiated 
in master mode, i.e. setting the VVC entity generic constant 'GC_MASTER_MODE' to 'true'.

.. code-block::

    i2c_master_receive(VVCT, vvc_instance_idx, addr, num_bytes, [data_routing,] msg, [action_when_transfer_is_done, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | addr               | in     | unsigned                     | Slave address. Valid address lengths are 7 bits and 10  |
|          |                    |        |                              | bits. 7-bit addresses with the four most-significant    |
|          |                    |        |                              | bits equal to x"0" and x"F" are reserved by the I2C     |
|          |                    |        |                              | standard. For a list of reserved addresses, please see  |
|          |                    |        |                              | :ref:`i2c_additional_doc`                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | num_bytes          | in     | natural                      | Number of data bytes to receive.                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_routing       | in     | :ref:`t_data_routing`        | Selects the destination of the received data            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether or not the I2C master method shall generate a   |
|          | er_is_done         |        | _is_done`                    | stop condition after the operation is finished. Default |
|          |                    |        |                              | value is RELEASE_LINE_AFTER_TRANSFER.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    i2c_master_receive(I2C_VVCT, 0, C_I2C_SLAVE_ADDR, 4, "Receiving 4 bytes from I2C Slave with address C_I2C_SLAVE_ADDR", C_SCOPE);
    i2c_master_receive(I2C_VVCT, 0, C_I2C_SLAVE_ADDR, 4, TO_SB, "Receiving 4 bytes and send to Scoreboard", C_SCOPE);

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last receive
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from read.
    ...
    i2c_master_receive(I2C_VVCT, 0, C_I2C_SLAVE_ADDR, 4, "Master receives 4 bytes from Slave with address C_I2C_SLAVE_ADDR");
    v_cmd_idx := get_last_received_cmd_idx(I2C_VVCT, 0);
    await_completion(I2C_VVCT, 0, v_cmd_idx, 1 us, "Wait for receive to finish");
    fetch_result(I2C_VVCT, 0, v_cmd_idx, v_result, "Fetching result from receive operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.


.. _i2c_master_check_vvc:

i2c_master_check()
----------------------------------------------------------------------------------------------------------------------------------
Adds a master check command to the I2C VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the BFM :ref:`i2c_master_check_bfm` procedure. The i2c_master_check() procedure 
will perform a receive operation, then check if the received data is equal to the expected data in the data parameter. If the 
received data is not equal to the expected data parameter, an alert with severity 'alert_level' will be issued.

The received data will not be stored by this procedure. This procedure can only be called when the I2C VVC is instantiated in 
master mode, i.e. setting the VVC entity generic constant 'GC_MASTER_MODE' to 'true'.

.. code-block::

    i2c_master_check(VVCT, vvc_instance_idx, addr, data, msg, [action_when_transfer_is_done, [alert_level, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | addr               | in     | unsigned                     | Slave address. Valid address lengths are 7 bits and 10  |
|          |                    |        |                              | bits. 7-bit addresses with the four most-significant    |
|          |                    |        |                              | bits equal to x"0" and x"F" are reserved by the I2C     |
|          |                    |        |                              | standard. For a list of reserved addresses, please see  |
|          |                    |        |                              | :ref:`i2c_additional_doc`                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The data value to expect when receiving the addressed   |
|          |                    |        |                              | register, either a single byte or a byte array. A       |
|          |                    |        | t_byte_array                 | mismatch results in an alert with severity 'alert_level'|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether or not the I2C master method shall generate a   |
|          | er_is_done         |        | _is_done`                    | stop condition after the operation is finished. Default |
|          |                    |        |                              | value is RELEASE_LINE_AFTER_TRANSFER.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    i2c_master_check(I2C_VVCT, 0, C_SLAVE_0_ADDR, byte_array(0 to 20), "Expecting byte array from Slave 0");
    i2c_master_check(I2C_VVCT, 0, C_SLAVE_1_ADDR, x"AD", "Expecting data from Slave 1 without generating stop condition at the end", HOLD_LINE_AFTER_TRANSFER, WARNING, C_SCOPE);


.. _i2c_master_quick_command_vvc:

i2c_master_quick_command()
----------------------------------------------------------------------------------------------------------------------------------
Adds a master quick command to the I2C VVC executor queue, which will run as soon as all preceding commands have completed. 
When the command is scheduled to run, the executor calls the BFM :ref:`i2c_master_quick_command_bfm` procedure. This procedure can only 
be called when the I2C VVC is instantiated in master mode, i.e. setting the VVC entity generic constant 'GC_MASTER_MODE' to 'true'.

.. code-block::

    i2c_master_quick_command(VVCT, vvc_instance_idx, addr, msg, [rw_bit, [exp_ack, [action_when_transfer_is_done, [alert_level, [scope]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | addr               | in     | unsigned                     | Slave address. Valid address lengths are 7 bits and 10  |
|          |                    |        |                              | bits. 7-bit addresses with the four most-significant    |
|          |                    |        |                              | bits equal to x"0" and x"F" are reserved by the I2C     |
|          |                    |        |                              | standard. For a list of reserved addresses, please see  |
|          |                    |        |                              | :ref:`i2c_additional_doc`                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | rw_bit             | in     | std_logic                    | Expected R/W bit. '1': read, '0': write. Default value  |
|          |                    |        |                              | is '0' (write).                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | exp_ack            | in     | boolean                      | Set to true or false depending on whether or not the    |
|          |                    |        |                              | slave is expected to acknowledge the quick command.     |
|          |                    |        |                              | Default value is true.                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether or not the I2C master method shall generate a   |
|          | er_is_done         |        | _is_done`                    | stop condition after the operation is finished. Default |
|          |                    |        |                              | value is RELEASE_LINE_AFTER_TRANSFER.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    i2c_master_quick_command(I2C_VVCT, 0, C_SLAVE_0_ADDR, "Quick Command to Slave 0");
    i2c_master_quick_command(I2C_VVCT, 0, C_SLAVE_0_ADDR, "Sending QC to I2C slave", '1', true, HOLD_LINE_AFTER_TRANSFER, ERROR, C_SCOPE);


.. _i2c_slave_transmit_vvc:

i2c_slave_transmit()
----------------------------------------------------------------------------------------------------------------------------------
Adds a slave transmit command to the I2C VVC executor queue, which will run as soon as all preceding commands have completed. 
When the command is scheduled to run, the executor calls the BFM :ref:`i2c_slave_transmit_bfm` procedure. This procedure can only 
be called when the I2C VVC is instantiated in slave mode, i.e. setting the VVC entity generic constant 'GC_MASTER_MODE' to 'false'.

.. code-block::

    i2c_slave_transmit(VVCT, vvc_instance_idx, data, msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The data value to be transmitted to the DUT, either a   |
|          |                    |        |                              | single byte or a byte array.                            |
|          |                    |        | t_byte_array                 |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    i2c_slave_transmit(I2C_VVCT, 0, x"0D", "Transmitting a single byte to master", C_SCOPE);
    i2c_slave_transmit(I2C_VVCT, 0, byte_array(0 to 9), "Transmitting an array of bytes to master", C_SCOPE);


.. _i2c_slave_receive_vvc:

i2c_slave_receive()
----------------------------------------------------------------------------------------------------------------------------------
Adds a slave receive command to the I2C VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the BFM :ref:`i2c_slave_receive_bfm` procedure.

The received data will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but the received 
data will be stored in the VVC for a potential future fetch (see example with fetch_result below). 
If the data_routing is set to TO_SB, the received data will be sent to the I2C VVC dedicated scoreboard where it will be 
checked against the expected value (provided by the testbench). This procedure can only be called when the I2C VVC is instantiated 
in slave mode, i.e. setting the VVC entity generic constant 'GC_MASTER_MODE' to 'false'.

.. code-block::

    i2c_slave_receive(VVCT, vvc_instance_idx, num_bytes, [data_routing,] msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | num_bytes          | in     | natural                      | Number of data bytes to receive.                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_routing       | in     | :ref:`t_data_routing`        | Selects the destination of the received data            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    i2c_slave_receive(I2C_VVCT, 0, 1, "One byte from master to slave", C_SCOPE);
    i2c_slave_receive(I2C_VVCT, 0, 1, TO_SB, "One byte from master to slave sent to Scoreboard", C_SCOPE);

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last receive
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from read.
    ...
    i2c_slave_receive(I2C_VVCT, 0, 4, "Slave receives 4 bytes from Master");
    v_cmd_idx := get_last_received_cmd_idx(I2C_VVCT, 0);
    await_completion(I2C_VVCT, 0, v_cmd_idx, 1 us, "Wait for receive to finish");
    fetch_result(I2C_VVCT, 0, v_cmd_idx, v_result, "Fetching result from receive operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.


.. _i2c_slave_check_vvc:

i2c_slave_check()
----------------------------------------------------------------------------------------------------------------------------------
Adds a slave check command to the I2C VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the BFM :ref:`i2c_slave_check_bfm` procedure. The i2c_slave_check() procedure 
will perform a receive operation, then check if the received data is equal to the expected data in the data parameter. If the 
received data is not equal to the expected data parameter, an alert with severity 'alert_level' will be issued.

The received data will not be stored by this procedure. This procedure can only be called when the I2C VVC is instantiated in 
slave mode, i.e. setting the VVC entity generic constant 'GC_MASTER_MODE' to 'false'.

.. code-block::

    i2c_slave_check(VVCT, vvc_instance_idx, data, msg, [alert_level, [rw_bit, [scope]]])
    i2c_slave_check(VVCT, vvc_instance_idx, rw_bit, msg, [alert_level, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The data value to expect when receiving the addressed   |
|          |                    |        |                              | register, either a single byte or a byte array. A       |
|          |                    |        | t_byte_array                 | mismatch results in an alert with severity 'alert_level'|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | rw_bit             | in     | std_logic                    | Expected R/W bit. '1': read, '0': write. Default value  |
|          |                    |        |                              | is '0' (write).                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    i2c_slave_check(I2C_VVCT, 0, x"0D", "Expecting data from master");
    i2c_slave_check(I2C_VVCT, 0, x"0D", "Expecting data from master", WARNING, '0', C_SCOPE); 
    i2c_slave_check(I2C_VVCT, 0, '0', "Expecting write type Quick Command from master", WARNING, C_SCOPE);


Activity Watchdog
==================================================================================================================================
.. include:: rst_snippets/vip_activity_watchdog.rst


Transaction Info
==================================================================================================================================
.. include:: rst_snippets/vip_transaction_info.rst

.. table:: I2C transaction info record fields. Transaction Type: t_base_transaction (BT) - accessible via **shared_i2c_vvc_transaction_info.bt**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | addr                         | unsigned(9 downto 0)         | 0x0             | Slave address to interact with when VVC is in   |
    |                              |                              |                 | master mode                                     |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | data                         | t_byte_array(0 to 63)        | 0x0             | Data for I2C receive or write transaction       |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | num_bytes                    | natural                      | 0               | Number of bytes to be received                  |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | action_when_transfer_is_done | :ref:`t_action_when_transfer\| RELEASE_LINE_AF\| Whether or not the I2C master method generates a|
    |                              | _is_done`                    | TER_TRANSFER    | stop condition after the operation is finished  |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | exp_ack                      | boolean                      | true            | Expected acknowledge bit during a Quick Command.|
    |                              |                              |                 | Can be used to identify if a slave is present on|
    |                              |                              |                 | the bus.                                        |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | rw_bit                       | std_logic                    | '0'             | Bit set in the R/W# slot of the Quick Command   |
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
i.e. i2c_master_receive(). Note that the data is only stored in the scoreboard and not accessible with the fetch_result() method 
when the TO_SB parameter is applied. The I2C scoreboard is accessible from the testbench as a shared variable I2C_VVC_SB, located 
in the vvc_methods_pkg.vhd, e.g. ::

    I2C_VVC_SB.add_expected(C_I2C_VVC_IDX, pad_i2c_sb(v_expected), "Adding expected");

The I2C scoreboard is per default a 64 bits wide standard logic vector. When sending expected data to the scoreboard, where the 
data width is smaller than the default scoreboard width, we recommend zero-padding the data with the pad_i2c_sb() function, e.g. ::

    I2C_VVC_SB.add_expected(<I2C VVC instance number>, pad_i2c_sb(<exp data>));

See the :ref:`vip_scoreboard` for a complete list of available commands and additional information. All of the listed Generic
Scoreboard commands are available for the I2C VVC scoreboard using the I2C_VVC_SB.


Unwanted Activity Detection
==================================================================================================================================
.. include:: rst_snippets/vip_unwanted_activity.rst

.. code-block::

    shared_i2c_vvc_config(C_VVC_INDEX).unwanted_activity_severity := NO_ALERT;

If multiple I2C slave VVCs are connected to the same master DUT, unwanted activity will give alerts on the inactive slave VVCs. In 
order to avoid getting any false alerts, the unwanted activity must be disabled on the inactive slave VVCs. Note that the unwanted 
activity detection must be enabled again after the data transfer is complete.

For I2C VVC, the unwanted activity detection is enabled by default with severity ERROR.

More information can be found in :ref:`Essential Mechanisms - Unwanted Activity Detection <vvc_framework_unwanted_activity>`.


Compilation
==================================================================================================================================
The I2C VVC must be compiled with VHDL-2008 or newer. It is dependent on the following libraries:

    * UVVM Utility Library (UVVM-Util)
    * UVVM VVC Framework
    * Bitvis VIP Scoreboard
    * I2C BFM

Before compiling the I2C VVC, assure that uvvm_util, uvvm_vvc_framework and bitvis_vip_scoreboard have been compiled.

See :ref:`Essential Mechanisms - Compile Scripts <vvc_framework_compile_scripts>` for information about compile scripts.

.. table:: Compile order for the I2C VVC

    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | Compile to library           | File                                           | Comment                                         |
    +==============================+================================================+=================================================+
    | bitvis_vip_i2c               | i2c_bfm_pkg.vhd                                | I2C BFM                                         |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_i2c               | transaction_pkg.vhd                            | I2C transaction package with DTT types,         |
    |                              |                                                | constants, etc.                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_i2c               | vvc_cmd_pkg.vhd                                | I2C VVC command types and operations            |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_i2c               | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC target support package, compiled into  |
    |                              | _target_support_pkg.vhd                        | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_i2c               | ../uvvm_vvc_framework/src_target_dependent/td\ | Common UVVM framework methods compiled into the |
    |                              | _vvc_framework_common_methods_pkg.vhd          | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_i2c               | vvc_sb_pkg.vhd                                 | I2C VVC scoreboard                              |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_i2c               | vvc_methods_pkg.vhd                            | I2C VVC methods                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_i2c               | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM queue package for this VVC                 |
    |                              | _queue_pkg.vhd                                 |                                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_i2c               | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC entity support compiled into this      |
    |                              | _vvc_entity_support_pkg.vhd                    | VVC library                                     |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_i2c               | i2c_vvc.vhd                                    | I2C VVC                                         |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_i2c               | vvc_context.vhd                                | I2C VVC context file                            |
    +------------------------------+------------------------------------------------+-------------------------------------------------+

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


Additional Documentation
==================================================================================================================================
For additional documentation on the I2C protocol, please see the NXP I2C specification "UM10204 I2C-bus specification and user 
manual Rev. 6", available from NXP Semiconductors.

.. important::

    * This is a simplified Verification IP (VIP) for I2C.
    * The given VIP complies with the basic I2C protocol and thus allows a normal access towards a I2C interface.
    * This VIP is not a I2C protocol checker.
    * For a more advanced VIP please contact UVVM support at info@uvvm.org

.. include:: rst_snippets/ip_disclaimer.rst
