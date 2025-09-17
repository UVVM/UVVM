##################################################################################################################################
Bitvis VIP SPI
##################################################################################################################################

**Quick Access**

* `BFM`_

  * :ref:`spi_master_transmit_and_receive_bfm`
  * :ref:`spi_master_transmit_and_check_bfm`
  * :ref:`spi_master_transmit_bfm`
  * :ref:`spi_master_receive_bfm`
  * :ref:`spi_master_check_bfm`
  * :ref:`init_spi_if_signals_bfm`
  * :ref:`spi_slave_transmit_and_receive_bfm`
  * :ref:`spi_slave_transmit_and_check_bfm`
  * :ref:`spi_slave_transmit_bfm`
  * :ref:`spi_slave_receive_bfm`
  * :ref:`spi_slave_check_bfm`

* `VVC`_

  * :ref:`spi_master_transmit_and_receive_vvc`
  * :ref:`spi_master_transmit_and_check_vvc`
  * :ref:`spi_master_transmit_only_vvc`
  * :ref:`spi_master_receive_only_vvc`
  * :ref:`spi_master_check_only_vvc`
  * :ref:`spi_slave_transmit_and_receive_vvc`
  * :ref:`spi_slave_transmit_and_check_vvc`
  * :ref:`spi_slave_transmit_only_vvc`
  * :ref:`spi_slave_receive_only_vvc`
  * :ref:`spi_slave_check_only_vvc`


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
BFM
**********************************************************************************************************************************
BFM functionality is implemented in spi_bfm_pkg.vhd

.. _t_spi_if:

Signal Record
==================================================================================================================================
**t_spi_if**

+-------------------------+------------------------------+
| Record element          | Type                         |
+=========================+==============================+
| ss_n                    | std_logic                    |
+-------------------------+------------------------------+
| sclk                    | std_logic                    |
+-------------------------+------------------------------+
| mosi                    | std_logic                    |
+-------------------------+------------------------------+
| miso                    | std_logic                    |
+-------------------------+------------------------------+

.. note::

    Some BFM calls can also be made with listing of single signals rather than t_spi_if.

.. _t_spi_bfm_config:

Configuration Record
==================================================================================================================================
**t_spi_bfm_config**

Default value for the record is C_SPI_BFM_CONFIG_DEFAULT.

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| CPOL                         | std_logic                    | '0'             | sclk polarity, i.e. the base value of the clock.|
|                              |                              |                 | If CPOL is '0', the clock will be set to '0'    |
|                              |                              |                 | when inactive, i.e., positive polarity.         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| CPHA                         | std_logic                    | '0'             | sclk phase, i.e. when data is sampled and       |
|                              |                              |                 | transmitted w.r.t. sclk. If '0', sampling occurs|
|                              |                              |                 | on the first sclk edge and data is transmitted  |
|                              |                              |                 | on the sclk active to idle state. If '1', data  |
|                              |                              |                 | is sampled on the second sclk edge and          |
|                              |                              |                 | transmitted on sclk idle to active state.       |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| spi_bit_time                 | time                         | -1 ns           | Used in master for dictating the sclk period.   |
|                              |                              |                 | Will give a TB_ERROR if not set to a different  |
|                              |                              |                 | value than -1.                                  |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| ss_n_to_sclk                 | time                         | 20 ns           | Time from ss_n low until sclk active            |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| sclk_to_ss_n                 | time                         | 20 ns           | Time from last sclk until ss_n is released      |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| inter_word_delay             | time                         | 0 ns            | Minimum time between words, from ss_n inactive  |
|                              |                              |                 | to ss_n active                                  |
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
* The record :ref:`t_spi_if <t_spi_if>` can be replaced with the signals listed in said record in some methods.
* All signals are active high.
* All parameters in brackets are optional.

.. note::

    The BFM configuration has to be defined and used when calling the SPI BFM procedures. See :ref:`spi_local_bfm_config` for an 
    example of how to define a local BFM config.


.. _spi_master_transmit_and_receive_bfm:

spi_master_transmit_and_receive()
----------------------------------------------------------------------------------------------------------------------------------
Transmits the data in 'tx_data' to the DUT and stores the received data in 'rx_data', using the SPI protocol. For protocol details, 
see the SPI specification.

When called, the procedure will set ss_n low. For a slave DUT to be able to transmit to a receiving master BFM, the master BFM 
must drive the sclk and ss_n signals and transmit data to the slave DUT.

* This procedure is responsible for driving sclk and ss_n.
* The SPI bit timing is given by config.spi_bit_time, config.spi_ss_n_to_sclk and config.sclk_to_ss_n.
* An error is reported if ss_n is not kept low during the entire transmission. 
* Note that action_between_words only apply for t_slv_array multi-word transfers.

.. code-block::

    spi_master_transmit_and_receive(tx_data(slv), rx_data(slv), msg, spi_if, [action_when_transfer_is_done, [scope, [msg_id_panel, [config]]]])
    spi_master_transmit_and_receive(tx_data(slv_array), rx_data(slv_array), msg, spi_if, [action_when_transfer_is_done, [action_between_words, [scope, [msg_id_panel, [config]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | tx_data            | in     | std_logic_vector             | The data value to be transmitted to the DUT, either a   |
|          |                    |        |                              | single word or a word array.                            |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | rx_data            | out    | std_logic_vector             | The data value received from the DUT, either a single   |
|          |                    |        |                              | word or a word array.                                   |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | spi_if             | inout  | :ref:`t_spi_if <t_spi_if>`   | SPI signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether or not the SPI master method shall release or   |
|          | er_is_done         |        | _is_done`                    | hold ss_n after the operation is finished. Default      |
|          |                    |        |                              | value is RELEASE_LINE_AFTER_TRANSFER.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_between_wor\| in     | :ref:`t_action_between_words`| Whether or not the SPI master method shall release or   |
|          | ds                 |        |                              | hold ss_n between words when transmitting a word array. |
|          |                    |        |                              | Default value is HOLD_LINE_BETWEEN_WORDS.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("SPI BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_spi_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_spi_bfm_config>`          | value is C_SPI_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    spi_master_transmit_and_receive(x"AA", v_data_out, "Transmitting data to peripheral 1 and receiving data back", spi_if);
    spi_master_transmit_and_receive((x"AA", x"BB"), v_data_out, "Transmitting data to peripheral 1 and receiving data back", spi_if, 
                                    RELEASE_LINE_AFTER_TRANSFER, HOLD_LINE_BETWEEN_WORDS, C_SCOPE, shared_msg_id_panel, C_SPI_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    spi_master_transmit_and_receive(C_ASCII_A, v_data_out, "Transmitting ASCII A to DUT and receiving data from DUT");


.. _spi_master_transmit_and_check_bfm:

spi_master_transmit_and_check()
----------------------------------------------------------------------------------------------------------------------------------
Transmits the data in 'tx_data' and receives data from the DUT, using the transmit and receive procedure as described in 
:ref:`spi_master_transmit_and_receive_bfm`. After receiving data, the data is compared with the expected data.

* If the check was successful, and the received data matches the expected data, a log message is written with ID 'config.id_for_bfm'.
* If the received data did not match the expected data, an alert with severity 'alert_level' will be reported.
* The procedure will report alerts for the same conditions and use similar default values as the 
  :ref:`spi_master_transmit_and_receive_bfm` procedure.
* Note that action_between_words only apply for t_slv_array multi-word transfers.

.. code-block::

    spi_master_transmit_and_check(tx_data(slv), data_exp(slv), msg, spi_if, [alert_level, [action_when_transfer_is_done, [scope, [msg_id_panel, [config]]]]])
    spi_master_transmit_and_check(tx_data(slv_array), data_exp(slv_array), msg, spi_if, [alert_level, [action_when_transfer_is_done, [action_between_words, [scope, [msg_id_panel, [config]]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | tx_data            | in     | std_logic_vector             | The data value to be transmitted to the DUT, either a   |
|          |                    |        |                              | single word or a word array.                            |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_logic_vector             | The data value to expect when receiving data from the   |
|          |                    |        |                              | DUT, either a single word or a word array.              |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | spi_if             | inout  | :ref:`t_spi_if <t_spi_if>`   | SPI signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether or not the SPI master method shall release or   |
|          | er_is_done         |        | _is_done`                    | hold ss_n after the operation is finished. Default      |
|          |                    |        |                              | value is RELEASE_LINE_AFTER_TRANSFER.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_between_wor\| in     | :ref:`t_action_between_words`| Whether or not the SPI master method shall release or   |
|          | ds                 |        |                              | hold ss_n between words when transmitting a word array. |
|          |                    |        |                              | Default value is HOLD_LINE_BETWEEN_WORDS.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("SPI BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_spi_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_spi_bfm_config>`          | value is C_SPI_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    spi_master_transmit_and_check(x"AA", x"3B", "Transmitting data and checking received data on SPI interface", spi_if);
    spi_master_transmit_and_check((x"AA", x"BB"), (x"3A", x"3B"), "Transmitting data and checking received data on SPI interface", 
                                  spi_if, ERROR, RELEASE_LINE_AFTER_TRANSFER, HOLD_LINE_BETWEEN_WORDS, C_SCOPE, shared_msg_id_panel, 
                                  C_SPI_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    spi_master_transmit_and_check(x"AA", C_CR_BYTE, "Transmitting 0xAA and expecting carriage return");


.. _spi_master_transmit_bfm:

spi_master_transmit()
----------------------------------------------------------------------------------------------------------------------------------
Transmits the data in 'tx_data' using the transmit and receive procedure as described in :ref:`spi_master_transmit_and_receive_bfm`.

* The received data from the DUT is ignored.
* The procedure will report alerts for the same conditions and use similar default values as the 
  :ref:`spi_master_transmit_and_receive_bfm` procedure.
* Note that action_between_words only apply for t_slv_array multi-word transfers.

.. code-block::

    spi_master_transmit(tx_data(slv), msg, spi_if, [action_when_transfer_is_done, [scope, [msg_id_panel, [config]]]])
    spi_master_transmit(tx_data(slv_array), msg, spi_if, [action_when_transfer_is_done, [action_between_words, [scope, [msg_id_panel, [config]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | tx_data            | in     | std_logic_vector             | The data value to be transmitted to the DUT, either a   |
|          |                    |        |                              | single word or a word array.                            |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | spi_if             | inout  | :ref:`t_spi_if <t_spi_if>`   | SPI signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether or not the SPI master method shall release or   |
|          | er_is_done         |        | _is_done`                    | hold ss_n after the operation is finished. Default      |
|          |                    |        |                              | value is RELEASE_LINE_AFTER_TRANSFER.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_between_wor\| in     | :ref:`t_action_between_words`| Whether or not the SPI master method shall release or   |
|          | ds                 |        |                              | hold ss_n between words when transmitting a word array. |
|          |                    |        |                              | Default value is HOLD_LINE_BETWEEN_WORDS.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("SPI BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_spi_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_spi_bfm_config>`          | value is C_SPI_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    spi_master_transmit(x"AA", "Transmitting data to peripheral 1", spi_if);
    spi_master_transmit((x"AA", x"BB"), "Transmitting data to peripheral 1", spi_if, RELEASE_LINE_AFTER_TRANSFER, HOLD_LINE_BETWEEN_WORDS, 
                        C_SCOPE, shared_msg_id_panel, C_SPI_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    spi_master_transmit(C_ASCII_A, "Transmitting ASCII A to DUT");


.. _spi_master_receive_bfm:

spi_master_receive()
----------------------------------------------------------------------------------------------------------------------------------
Receives data from the DUT using the transmit and receive procedure as described in :ref:`spi_master_transmit_and_receive_bfm`.

* The procedure will transmit dummy data (0x0) to the DUT.
* The procedure will report alerts for the same conditions and use similar default values as the 
  :ref:`spi_master_transmit_and_receive_bfm` procedure.
* Note that action_between_words only apply for t_slv_array multi-word transfers.

.. code-block::

    spi_master_receive(rx_data(slv), msg, spi_if, [action_when_transfer_is_done, [scope, [msg_id_panel, [config]]]])
    spi_master_receive(rx_data(slv_array), msg, spi_if, [action_when_transfer_is_done, [action_between_words, [scope, [msg_id_panel, [config]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| variable | rx_data            | out    | std_logic_vector             | The data value received from the DUT, either a single   |
|          |                    |        |                              | word or a word array.                                   |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | spi_if             | inout  | :ref:`t_spi_if <t_spi_if>`   | SPI signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether or not the SPI master method shall release or   |
|          | er_is_done         |        | _is_done`                    | hold ss_n after the operation is finished. Default      |
|          |                    |        |                              | value is RELEASE_LINE_AFTER_TRANSFER.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_between_wor\| in     | :ref:`t_action_between_words`| Whether or not the SPI master method shall release or   |
|          | ds                 |        |                              | hold ss_n between words when transmitting a word array. |
|          |                    |        |                              | Default value is HOLD_LINE_BETWEEN_WORDS.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("SPI BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_spi_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_spi_bfm_config>`          | value is C_SPI_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    spi_master_receive(v_data_out, "Receive from Peripheral 1", spi_if);
    spi_master_receive(v_data_out, "Receive from Peripheral 1", spi_if, RELEASE_LINE_AFTER_TRANSFER, HOLD_LINE_BETWEEN_WORDS, 
                       C_SCOPE, shared_msg_id_panel, C_SPI_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    spi_master_receive(v_data_out, "Receive from Peripheral 1");


.. _spi_master_check_bfm:

spi_master_check()
----------------------------------------------------------------------------------------------------------------------------------
Receives data from the DUT, using the transmit and receive procedure as described in :ref:`spi_master_transmit_and_receive_bfm`. 
After receiving data, the data is compared with the expected data.

* If the check was successful, and the received data matches the expected data, a log message is written with ID 'config.id_for_bfm'.
* If the received data did not match the expected data, an alert with severity 'alert_level' will be reported.
* The procedure will transmit dummy data (0x0) to the DUT.
* The procedure will report alerts for the same conditions and use similar default values as the 
  :ref:`spi_master_transmit_and_receive_bfm` procedure.
* Note that action_between_words only apply for t_slv_array multi-word transfers.

.. code-block::

    spi_master_check(data_exp(slv), msg, spi_if, [alert_level, [action_when_transfer_is_done, [scope, [msg_id_panel, [config]]]]])
    spi_master_check(data_exp(slv_array), msg, spi_if, [alert_level, [action_when_transfer_is_done, [action_between_words, [scope, [msg_id_panel, [config]]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | data_exp           | in     | std_logic_vector             | The data value to expect when receiving data from the   |
|          |                    |        |                              | DUT, either a single word or a word array.              |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | spi_if             | inout  | :ref:`t_spi_if <t_spi_if>`   | SPI signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether or not the SPI master method shall release or   |
|          | er_is_done         |        | _is_done`                    | hold ss_n after the operation is finished. Default      |
|          |                    |        |                              | value is RELEASE_LINE_AFTER_TRANSFER.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_between_wor\| in     | :ref:`t_action_between_words`| Whether or not the SPI master method shall release or   |
|          | ds                 |        |                              | hold ss_n between words when transmitting a word array. |
|          |                    |        |                              | Default value is HOLD_LINE_BETWEEN_WORDS.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("SPI BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_spi_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_spi_bfm_config>`          | value is C_SPI_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    spi_master_check(x"3B", "Checking data on SPI interface", spi_if);
    spi_master_check((x"AA", x"BB"), "Checking data on SPI interface", spi_if, ERROR, RELEASE_LINE_AFTER_TRANSFER, HOLD_LINE_BETWEEN_WORDS, 
                     C_SCOPE, shared_msg_id_panel, C_SPI_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    spi_master_check(C_CR_BYTE, "Expecting carriage return");


.. _spi_slave_transmit_and_receive_bfm:

spi_slave_transmit_and_receive()
----------------------------------------------------------------------------------------------------------------------------------
Transmits the data in 'tx_data' to the DUT and stores the received data in 'rx_data', using the SPI protocol. For protocol details, 
see the SPI specification.

When called, the procedure will wait for next ss_n, or start transfer and receive immediately, depending on the selection of 
when_to_start_transfer and if ss_n is already set. If terminate_access is '1' when this happens, the transfer and receive will be 
terminated instead. 

* An error is reported if ss_n is not kept low during the entire transmission. 

.. code-block::

    spi_slave_transmit_and_receive(tx_data, rx_data, aborted, msg, spi_if, terminate_access, [aborted_alert_level, [when_to_start_transfer, [scope, [msg_id_panel, [config]]]]])
    spi_slave_transmit_and_receive(tx_data, rx_data, msg, spi_if, [terminate_access,] [when_to_start_transfer, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | tx_data            | in     | std_logic_vector             | The data value to be transmitted to the DUT, either a   |
|          |                    |        |                              | single word or a word array.                            |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | rx_data            | out    | std_logic_vector             | The data value received from the DUT, either a single   |
|          |                    |        |                              | word or a word array.                                   |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | aborted            | out    | boolean                      | Set to true when the procedure is aborted               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | spi_if             | inout  | :ref:`t_spi_if <t_spi_if>`   | SPI signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_access   | in     | std_logic                    | Determines if SPI slave transfer is performed. Setting  |
|          |                    |        |                              | this to '1' before a slave command is executed          |
|          |                    |        |                              | terminates the command.                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | aborted_alert_level| in     | :ref:`t_alert_level`         | Sets the severity for the alert when the procedure is   |
|          |                    |        |                              | aborted. Default value is ERROR.                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | when_to_start_tran\| in     | :ref:`t_when_to_start_transf\| Determines if SPI slave shall wait for next ss_n if a   |
|          | sfer               |        | er`                          | transfer has already started. Default value is          |
|          |                    |        |                              | START_TRANSFER_ON_NEXT_SS.                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("SPI BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_spi_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_spi_bfm_config>`          | value is C_SPI_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    spi_slave_transmit_and_receive(x"AA", v_data_out, "Transmitting and receiving data from peripheral 1", spi_if);
    spi_slave_transmit_and_receive((x"AA", x"BB"), v_data_out, "Transmitting and receiving data from peripheral 1", spi_if, 
                                   terminate_access, START_TRANSFER_ON_NEXT_SS, C_SCOPE, shared_msg_id_panel, C_SPI_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    spi_slave_transmit_and_receive(C_ASCII_A, v_data_out, "Transmitting ASCII A to DUT and receiving data from DUT");


.. _spi_slave_transmit_and_check_bfm:

spi_slave_transmit_and_check()
----------------------------------------------------------------------------------------------------------------------------------
Transmits the data in 'tx_data' and receives data from the DUT, using the transmit and receive procedure as described in 
:ref:`spi_slave_transmit_and_receive_bfm`. After receiving data, the data is compared with the expected data.

* If the check was successful, and the received data matches the expected data, a log message is written with ID 'config.id_for_bfm'.
* If the received data did not match the expected data, an alert with severity 'alert_level' will be reported.
* The procedure will report alerts for the same conditions and use similar default values as the 
  :ref:`spi_slave_transmit_and_receive_bfm` procedure.

.. code-block::

    spi_slave_transmit_and_check(tx_data, data_exp, msg, spi_if, [terminate_access,] [alert_level, [when_to_start_transfer, [scope, [msg_id_panel, [config]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | tx_data            | in     | std_logic_vector             | The data value to be transmitted to the DUT, either a   |
|          |                    |        |                              | single word or a word array.                            |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_logic_vector             | The data value to expect when receiving data from the   |
|          |                    |        |                              | DUT, either a single word or a word array.              |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | spi_if             | inout  | :ref:`t_spi_if <t_spi_if>`   | SPI signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_access   | in     | std_logic                    | Determines if SPI slave transfer is performed. Setting  |
|          |                    |        |                              | this to '1' before a slave command is executed          |
|          |                    |        |                              | terminates the command.                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | when_to_start_tran\| in     | :ref:`t_when_to_start_transf\| Determines if SPI slave shall wait for next ss_n if a   |
|          | sfer               |        | er`                          | transfer has already started. Default value is          |
|          |                    |        |                              | START_TRANSFER_ON_NEXT_SS.                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("SPI BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_spi_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_spi_bfm_config>`          | value is C_SPI_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    spi_slave_transmit_and_check(x"AA", x"3B", "Transmitting data and checking received data on SPI interface", spi_if);
    spi_slave_transmit_and_check((x"AA", x"BB"), (x"3A", x"3B"), "Transmitting data and checking received data on SPI interface",
                                  spi_if, terminate_access, ERROR, START_TRANSFER_ON_NEXT_SS, C_SCOPE, shared_msg_id_panel, 
                                  C_SPI_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    spi_slave_transmit_and_check(x"AA", C_CR_BYTE, "Transmitting 0xAA and expecting carriage return");


.. _spi_slave_transmit_bfm:

spi_slave_transmit()
----------------------------------------------------------------------------------------------------------------------------------
Transmits the data in 'tx_data' using the transmit and receive procedure as described in :ref:`spi_slave_transmit_and_receive_bfm`.

* The received data from the DUT is ignored.
* The procedure will report alerts for the same conditions and use similar default values as the 
  :ref:`spi_slave_transmit_and_receive_bfm` procedure.

.. code-block::

    spi_slave_transmit(tx_data(slv), aborted, msg, spi_if, terminate_access, [when_to_start_transfer, [scope, [msg_id_panel, [config]]]])
    spi_slave_transmit(tx_data(slv), msg, spi_if, [terminate_access,] [when_to_start_transfer, [scope, [msg_id_panel, [config]]]])
    spi_slave_transmit(tx_data(slv_array), msg, spi_if, [terminate_access,] [when_to_start_transfer, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | tx_data            | in     | std_logic_vector             | The data value to be transmitted to the DUT, either a   |
|          |                    |        |                              | single word or a word array.                            |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | aborted            | out    | boolean                      | Set to true when the procedure is aborted               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | spi_if             | inout  | :ref:`t_spi_if <t_spi_if>`   | SPI signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_access   | in     | std_logic                    | Determines if SPI slave transfer is performed. Setting  |
|          |                    |        |                              | this to '1' before a slave command is executed          |
|          |                    |        |                              | terminates the command.                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | when_to_start_tran\| in     | :ref:`t_when_to_start_transf\| Determines if SPI slave shall wait for next ss_n if a   |
|          | sfer               |        | er`                          | transfer has already started. Default value is          |
|          |                    |        |                              | START_TRANSFER_ON_NEXT_SS.                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("SPI BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_spi_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_spi_bfm_config>`          | value is C_SPI_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    spi_slave_transmit(x"AA", "Transmitting data to peripheral 1", spi_if);
    spi_slave_transmit((x"AA", x"BB"), "Transmitting data to peripheral 1", spi_if, terminate_access, START_TRANSFER_ON_NEXT_SS, 
                       C_SCOPE, shared_msg_id_panel, C_SPI_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    spi_slave_transmit(C_ASCII_A, "Transmitting ASCII A to DUT");


.. _spi_slave_receive_bfm:

spi_slave_receive()
----------------------------------------------------------------------------------------------------------------------------------
Receives data from the DUT using the transmit and receive procedure as described in :ref:`spi_slave_transmit_and_receive_bfm`.

* The procedure will transmit dummy data (0x0) to the DUT.
* The procedure will report alerts for the same conditions and use similar default values as the 
  :ref:`spi_slave_transmit_and_receive_bfm` procedure.

.. code-block::

    spi_slave_receive(rx_data(slv), aborted, msg, spi_if, terminate_access, [when_to_start_transfer, [scope, [msg_id_panel, [config]]]])
    spi_slave_receive(rx_data(slv), msg, spi_if, [terminate_access,] [when_to_start_transfer, [scope, [msg_id_panel, [config]]]])
    spi_slave_receive(rx_data(slv_array), msg, spi_if, [terminate_access,] [when_to_start_transfer, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| variable | rx_data            | out    | std_logic_vector             | The data value received from the DUT, either a single   |
|          |                    |        |                              | word or a word array.                                   |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | aborted            | out    | boolean                      | Set to true when the procedure is aborted               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | spi_if             | inout  | :ref:`t_spi_if <t_spi_if>`   | SPI signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_access   | in     | std_logic                    | Determines if SPI slave transfer is performed. Setting  |
|          |                    |        |                              | this to '1' before a slave command is executed          |
|          |                    |        |                              | terminates the command.                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | when_to_start_tran\| in     | :ref:`t_when_to_start_transf\| Determines if SPI slave shall wait for next ss_n if a   |
|          | sfer               |        | er`                          | transfer has already started. Default value is          |
|          |                    |        |                              | START_TRANSFER_ON_NEXT_SS.                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("SPI BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_spi_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_spi_bfm_config>`          | value is C_SPI_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    spi_slave_receive(v_data_out, "Receive from Peripheral 1", spi_if);
    spi_slave_receive(v_data_out, "Receive from Peripheral 1", spi_if, terminate_access, START_TRANSFER_ON_NEXT_SS, C_SCOPE, 
                      shared_msg_id_panel, C_SPI_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    spi_slave_receive(v_data_out, "Receive from Peripheral 1");


.. _spi_slave_check_bfm:

spi_slave_check()
----------------------------------------------------------------------------------------------------------------------------------
Receives data from the DUT using the transmit and receive procedure as described in :ref:`spi_slave_transmit_and_receive_bfm`. 
After receiving data, the data is compared with the expected data.

* If the check was successful, and the received data matches the expected data, a log message is written with ID 'config.id_for_bfm'.
* If the received data did not match the expected data, an alert with severity 'alert_level' will be reported.
* The procedure will transmit dummy data (0x0) to the DUT.
* The procedure will report alerts for the same conditions and use similar default values as the 
  :ref:`spi_slave_transmit_and_receive_bfm` procedure.

.. code-block::

    spi_slave_check(data_exp, msg, spi_if, [terminate_access,] [alert_level, [when_to_start_transfer, [scope, [msg_id_panel, [config]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | data_exp           | in     | std_logic_vector             | The data value to expect when receiving data from the   |
|          |                    |        |                              | DUT, either a single word or a word array.              |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | spi_if             | inout  | :ref:`t_spi_if <t_spi_if>`   | SPI signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_access   | in     | std_logic                    | Determines if SPI slave transfer is performed. Setting  |
|          |                    |        |                              | this to '1' before a slave command is executed          |
|          |                    |        |                              | terminates the command.                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | when_to_start_tran\| in     | :ref:`t_when_to_start_transf\| Determines if SPI slave shall wait for next ss_n if a   |
|          | sfer               |        | er`                          | transfer has already started. Default value is          |
|          |                    |        |                              | START_TRANSFER_ON_NEXT_SS.                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("SPI BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_spi_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_spi_bfm_config>`          | value is C_SPI_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    spi_slave_check(x"3B", "Checking data on SPI interface", spi_if);
    spi_slave_check((x"3A", x"3B"), "Checking data on SPI interface", spi_if, terminate_access, ERROR, START_TRANSFER_ON_NEXT_SS, 
                    C_SCOPE, shared_msg_id_panel, C_SPI_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    spi_slave_check(C_CR_BYTE, "Expecting carriage return");


.. _init_spi_if_signals_bfm:

init_spi_if_signals()
----------------------------------------------------------------------------------------------------------------------------------
Initializes the SPI interface.

Master mode set true:
    * ss_n initialized to 'H'.
    * if config.CPOL = '1', sclk initialized to 'H'. Otherwise, sclk initialized to 'L'.
    * miso and mosi initialized to 'Z'.

Master mode set false:
    * All signals initialized to 'Z'.

.. code-block::

    t_spi_if := init_spi_if_signals(config, [master_mode])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | config             | in     | :ref:`t_spi_bfm_config       | Configuration of BFM behavior and restrictions          |
|          |                    |        | <t_spi_bfm_config>`          |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | master_mode        | in     | boolean                      | Whether the interface is in master or slave mode.       |
|          |                    |        |                              | Default value is true (master).                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    spi_if <= init_spi_if_signals(C_SPI_BFM_CONFIG_DEFAULT);        -- Implicitly master mode since default is 'true'
    spi_if <= init_spi_if_signals(C_SPI_BFM_CONFIG_DEFAULT, true);  -- Explicitly indicating master mode
    spi_if <= init_spi_if_signals(C_SPI_BFM_CONFIG_DEFAULT, false); -- master_mode is false, i.e., shall act as a slave 


Local BFM overloads
==================================================================================================================================
A good approach for better readability and maintainability is to make simple, local overloads for the BFM procedures in the TB 
process. This allows calling the BFM procedures with the key parameters only, e.g. ::

    spi_master_transmit_and_receive(C_ASCII_A, v_data_out, "Transmitting ASCII A");

rather than ::

    spi_master_transmit_and_receive(C_ASCII_A, v_data_out, "Transmitting ASCII A", spi_if, RELEASE_LINE_AFTER_TRANSFER, C_SCOPE, shared_msg_id_panel, C_SPI_CONFIG_LOCAL);

By defining the local overload as e.g. ::

    procedure spi_master_transmit_and_receive(
      constant tx_data : in  std_logic_vector;
      variable rx_data : out std_logic_vector;
      constant msg     : in  string) is
    begin
      spi_master_transmit_and_receive(tx_data,                     -- Keep as is
                                      rx_data,                     -- Keep as is
                                      msg,                         -- Keep as is
                                      spi_if,                      -- Signal must be visible in local process scope
                                      RELEASE_LINE_AFTER_TRANSFER, -- Use default, unless passing SLVs to master in a multi-word transfer
                                      C_SCOPE,                     -- Use the default
                                      shared_msg_id_panel,         -- Use global, shared msg_id_panel
                                      C_SPI_CONFIG_LOCAL);         -- Use locally defined configuration or C_SPI_CONFIG_DEFAULT
    end procedure;

Using a local overload like this also allows the following – if wanted:

* Set up defaults for constants. May be different for two overloads of the same BFM
* Apply dedicated message ID panel to allow dedicated verbosity control


.. _spi_local_bfm_config:

Local BFM configuration
==================================================================================================================================
The SPI BFM requires that a local configuration is declared in the testbench and used in the BFM procedure calls. The default BFM 
configuration is defined with a bit period of -1 ns so that the BFM can detect and alert the user that the configuration has not
been set.

Defining a local SPI BFM configuration:::

    constant C_SPI_CONFIG_LOCAL : t_spi_bfm_config := (
      CPOL             => '0',
      CPHA             => '0',
      spi_bit_time     => 200 ns,
      ss_n_to_sclk     => 301 ns,
      sclk_to_ss_n     => 301 ns,
      inter_word_delay => 0 ns,
      match_strictness => MATCH_EXACT,
      id_for_bfm       => ID_BFM,
      id_for_bfm_wait  => ID_BFM_WAIT,
      id_for_bfm_poll  => ID_BFM_POLL
    );


Compilation
==================================================================================================================================
.. include:: rst_snippets/bfm_compilation.rst

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


Additional Documentation
==================================================================================================================================
For additional documentation on the SPI protocol, please see the SPI specification, e.g. "ST TN0897 Technical note ST SPI protocol. 
ID 023176 Rev 2".

.. important::

    * This is a simplified Bus Functional Model (BFM) for SPI.
    * The given BFM complies with the basic SPI protocol and thus allows a normal access towards a SPI interface.
    * This BFM is not a SPI protocol checker.
    * For a more advanced BFM please contact UVVM support at info@uvvm.org


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
VVC
**********************************************************************************************************************************
* VVC functionality is implemented in spi_vvc.vhd
* For general information see :ref:`VVC Framework - Essential Mechanisms <vvc_framework_essential_mechanisms>`.

Entity
==================================================================================================================================

Generics
----------------------------------------------------------------------------------------------------------------------------------

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Name                         | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| GC_DATA_WIDTH                | natural                      | 8               | Bits in the SPI data word                       |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_DATA_ARRAY_WIDTH          | natural                      | 32              | Number of SPI data words in a data word array of|
|                              |                              |                 | type t_slv_array                                |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_INSTANCE_IDX              | natural                      | 1               | Instance number to assign the VVC               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_MASTER_MODE               | boolean                      | true            | Whether the VVC shall act as an SPI master or   |
|                              |                              |                 | an SPI slave on the bus                         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_SPI_CONFIG                | :ref:`t_spi_bfm_config       | C_SPI_BFM_CONFI\| Configuration for the SPI BFM                   |
|                              | <t_spi_bfm_config>`          | G_DEFAULT       |                                                 |
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
| signal   | spi_vvc_if         | inout  | :ref:`t_spi_if <t_spi_if>`   | SPI signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

Configuration Record
==================================================================================================================================
**vvc_config** accessible via **shared_spi_vvc_config**

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| inter_bfm_delay              | :ref:`t_inter_bfm_delay`     | C_SPI_INTER_BFM\| Delay between any requested BFM accesses        |
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
| bfm_config                   | :ref:`t_spi_bfm_config       | C_SPI_BFM_CONFI\| Configuration for the SPI BFM                   |
|                              | <t_spi_bfm_config>`          | G_DEFAULT       |                                                 |
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

    shared_spi_vvc_config(C_VVC_IDX_MASTER).inter_bfm_delay.delay_in_time := 10 ms;
    shared_spi_vvc_config(C_VVC_IDX_SLAVE).bfm_config.CPOL := '1';

Status Record
==================================================================================================================================
**vvc_status** accessible via **shared_spi_vvc_status**

.. include:: rst_snippets/vip_vvc_status.rst

Methods
==================================================================================================================================
* All VVC procedures are defined in vvc_methods_pkg.vhd (dedicated to this VVC).
* See :ref:`vvc_framework_methods` for procedures which are common to all VVCs.
* It is also possible to send a multicast to all instances of a VVC with ALL_INSTANCES as parameter for vvc_instance_idx.
* All parameters in brackets are optional.


.. _spi_master_transmit_and_receive_vvc:

spi_master_transmit_and_receive()
----------------------------------------------------------------------------------------------------------------------------------
Adds a master transmit and receive command to the SPI VVC executor queue, which will run as soon as all preceding commands have 
completed. When the command is scheduled to run, the executor calls the BFM :ref:`spi_master_transmit_and_receive_bfm` procedure.

The received data will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but the received 
data will be stored in the VVC for a potential future fetch (see example with fetch_result below). 
If the data_routing is set to TO_SB, the received data will be sent to the SPI VVC dedicated scoreboard where it will be 
checked against the expected value (provided by the testbench). This procedure can only be called when the SPI VVC is instantiated 
in master mode, i.e. setting the VVC entity generic constant 'GC_MASTER_MODE' to 'true'.

.. code-block::

    spi_master_transmit_and_receive(VVCT, vvc_instance_idx, data(slv), [data_routing,] msg, [action_when_transfer_is_done, [scope]])
    spi_master_transmit_and_receive(VVCT, vvc_instance_idx, data(slv_array), [data_routing,] msg, [action_when_transfer_is_done, [action_between_words, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The data value to be transmitted to the DUT, either a   |
|          |                    |        |                              | single word or a word array.                            |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_routing       | in     | :ref:`t_data_routing`        | Selects the destination of the received data            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether or not the SPI master method shall release or   |
|          | er_is_done         |        | _is_done`                    | hold ss_n after the operation is finished. Default      |
|          |                    |        |                              | value is RELEASE_LINE_AFTER_TRANSFER.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_between_wor\| in     | :ref:`t_action_between_words`| Whether or not the SPI master method shall release or   |
|          | ds                 |        |                              | hold ss_n between words when transmitting a word array. |
|          |                    |        |                              | Default value is HOLD_LINE_BETWEEN_WORDS.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    spi_master_transmit_and_receive(SPI_VVCT, 0, x"AF", "SPI Master Tx and Rx to/from Peripheral 1. Rx data will be stored in VVC to be retrieved later using fetch_result.");
    spi_master_transmit_and_receive(SPI_VVCT, 0, x"AF", TO_SB, "SPI Master Tx and Rx to/from Peripheral 1. Rx data will be sent to the SPI scoreboard for checking.");

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                              -- Command index for the last receive
    variable v_data    : t_slv_array(1 downto 0)(7 downto 0);  -- Data array to transmit
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result;        -- Result from read.
    ...
    v_data(0) := x"AB";
    v_data(1) := x"CD";

    spi_master_transmit_and_receive(SPI_VVCT, 0, v_data, "Transmitting two bytes to Peripheral 1 and receiving from Peripheral 1");
    v_cmd_idx := get_last_received_cmd_idx(SPI_VVCT, 0);
    await_completion(SPI_VVCT, 0, v_cmd_idx, 1 us, "Wait for transmit and receive to finish");
    fetch_result(SPI_VVCT, 0, v_cmd_idx, v_result, "Fetching first byte from transmit and receive operation");
    fetch_result(SPI_VVCT, 0, v_cmd_idx, v_result, "Fetching second byte from transmit and receive operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.


.. _spi_master_transmit_only_vvc:

spi_master_transmit_only()
----------------------------------------------------------------------------------------------------------------------------------
Adds a master transmit command to the SPI VVC executor queue, which will run as soon as all preceding commands have completed. 
When the command is scheduled to run, the executor calls the BFM :ref:`spi_master_transmit_bfm` procedure.

This procedure will ignore the received data from the slave DUT. This procedure can only be called when the SPI VVC is 
instantiated in master mode, i.e. setting the VVC entity generic constant 'GC_MASTER_MODE' to 'true'.

.. code-block::

    spi_master_transmit_only(VVCT, vvc_instance_idx, data(slv), msg, [action_when_transfer_is_done, [scope]])
    spi_master_transmit_only(VVCT, vvc_instance_idx, data(slv_array), msg, [action_when_transfer_is_done, [action_between_words, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The data value to be transmitted to the DUT, either a   |
|          |                    |        |                              | single word or a word array.                            |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether or not the SPI master method shall release or   |
|          | er_is_done         |        | _is_done`                    | hold ss_n after the operation is finished. Default      |
|          |                    |        |                              | value is RELEASE_LINE_AFTER_TRANSFER.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_between_wor\| in     | :ref:`t_action_between_words`| Whether or not the SPI master method shall release or   |
|          | ds                 |        |                              | hold ss_n between words when transmitting a word array. |
|          |                    |        |                              | Default value is HOLD_LINE_BETWEEN_WORDS.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    variable v_data : t_slv_array(1 downto 0)(7 downto 0);  -- Data array to transmit
    ...
    v_data(0) := x"AA";
    v_data(1) := x"BB";

    spi_master_transmit_only(SPI_VVCT, 0, x"0D", "Transmitting carriage return to Peripheral 1");
    spi_master_transmit_only(SPI_VVCT, 0, v_data, "Transmitting two bytes to Peripheral 1",
                             RELEASE_LINE_AFTER_TRANSFER, HOLD_LINE_BETWEEN_WORDS, C_SCOPE);


.. _spi_master_receive_only_vvc:

spi_master_receive_only()
----------------------------------------------------------------------------------------------------------------------------------
Adds a master receive command to the SPI VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the BFM :ref:`spi_master_receive_bfm` procedure.

The procedure will transmit dummy data (0x0) to the DUT.
The received data will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but the received 
data will be stored in the VVC for a potential future fetch (see example with fetch_result below). When receiving multiple words, 
each word must be fetched separately with the same command index.
If the data_routing is set to TO_SB, the received data will be sent to the SPI VVC dedicated scoreboard where it will be 
checked against the expected value (provided by the testbench). This procedure can only be called when the SPI VVC is instantiated 
in master mode, i.e. setting the VVC entity generic constant 'GC_MASTER_MODE' to 'true'.

.. code-block::

    spi_master_receive_only(VVCT, vvc_instance_idx, [data_routing,] msg, [num_words, [action_when_transfer_is_done, [action_between_words, [scope]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_routing       | in     | :ref:`t_data_routing`        | Selects the destination of the received data            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | num_words          | in     | positive                     | Number of words that shall be received. Default value is|
|          |                    |        |                              | 1.                                                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether or not the SPI master method shall release or   |
|          | er_is_done         |        | _is_done`                    | hold ss_n after the operation is finished. Default      |
|          |                    |        |                              | value is RELEASE_LINE_AFTER_TRANSFER.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_between_wor\| in     | :ref:`t_action_between_words`| Whether or not the SPI master method shall release or   |
|          | ds                 |        |                              | hold ss_n between words when transmitting a word array. |
|          |                    |        |                              | Default value is HOLD_LINE_BETWEEN_WORDS.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    spi_master_receive_only(SPI_VVCT, 0, "Receiving from Peripheral 1. Rx data will be stored in VVC to be retrieved later using fetch_result.");
    spi_master_receive_only(SPI_VVCT, 0, TO_SB, "Receiving 6 words from Peripheral 1. Rx data will be sent to the SPI scoreboard for checking.", 6);

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last receive
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from read.
    ...
    spi_master_receive_only(SPI_VVCT, 0, "Receiving from Peripheral 1"); 
    v_cmd_idx := get_last_received_cmd_idx(SPI_VVCT, 0);
    await_completion(SPI_VVCT, 0, v_cmd_idx, 1 us, "Wait for receive to finish");
    fetch_result(SPI_VVCT, 0, v_cmd_idx, v_result, "Fetching result from receive operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.


.. _spi_master_transmit_and_check_vvc:

spi_master_transmit_and_check()
----------------------------------------------------------------------------------------------------------------------------------
Adds a master transmit and check command to the SPI VVC executor queue, which will run as soon as all preceding commands have 
completed. When the command is scheduled to run, the executor calls the BFM :ref:`spi_master_transmit_and_check_bfm` procedure.

This procedure can only be called when the SPI VVC is instantiated in master mode, i.e. setting the VVC entity generic constant 
'GC_MASTER_MODE' to 'true'.

.. code-block::

    spi_master_transmit_and_check(VVCT, vvc_instance_idx, data(slv), data_exp(slv), msg, [alert_level, [action_when_transfer_is_done, [scope]]])
    spi_master_transmit_and_check(VVCT, vvc_instance_idx, data(slv_array), data_exp(slv_array), msg, [alert_level, [action_when_transfer_is_done, [action_between_words, [scope]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The data value to be transmitted to the DUT, either a   |
|          |                    |        |                              | single word or a word array.                            |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_logic_vector             | The data value to expect when receiving data from the   |
|          |                    |        |                              | DUT, either a single word or a word array.              |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether or not the SPI master method shall release or   |
|          | er_is_done         |        | _is_done`                    | hold ss_n after the operation is finished. Default      |
|          |                    |        |                              | value is RELEASE_LINE_AFTER_TRANSFER.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_between_wor\| in     | :ref:`t_action_between_words`| Whether or not the SPI master method shall release or   |
|          | ds                 |        |                              | hold ss_n between words when transmitting a word array. |
|          |                    |        |                              | Default value is HOLD_LINE_BETWEEN_WORDS.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    spi_master_transmit_and_check(SPI_VVCT, 0, x"0D", x"5F", "Transmitting carriage return to Peripheral 1 and expecting data back");
    spi_master_transmit_and_check(SPI_VVCT, 0, C_CR_BYTES, C_EXP_BYTES, "Transmitting carriage return to Peripheral 1 and expecting data back", 
                                  ERROR, RELEASE_LINE_AFTER_TRANSFER, HOLD_LINE_BETWEEN_WORDS, C_SCOPE);


.. _spi_master_check_only_vvc:

spi_master_check_only()
----------------------------------------------------------------------------------------------------------------------------------
Adds a master check command to the SPI VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the BFM :ref:`spi_master_check_bfm` procedure.

The procedure will transmit dummy data (0x0) to the DUT. This procedure can only be called when the SPI VVC is instantiated in 
master mode, i.e. setting the VVC entity generic constant 'GC_MASTER_MODE' to 'true'.

.. code-block::

    spi_master_check_only(VVCT, vvc_instance_idx, data_exp(slv), msg, [alert_level, [action_when_transfer_is_done, [scope]]])
    spi_master_check_only(VVCT, vvc_instance_idx, data_exp(slv_array), msg, [alert_level, [action_when_transfer_is_done, [action_between_words, [scope]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_logic_vector             | The data value to expect when receiving data from the   |
|          |                    |        |                              | DUT, either a single word or a word array.              |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_when_transf\| in     | :ref:`t_action_when_transfer\| Whether or not the SPI master method shall release or   |
|          | er_is_done         |        | _is_done`                    | hold ss_n after the operation is finished. Default      |
|          |                    |        |                              | value is RELEASE_LINE_AFTER_TRANSFER.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | action_between_wor\| in     | :ref:`t_action_between_words`| Whether or not the SPI master method shall release or   |
|          | ds                 |        |                              | hold ss_n between words when transmitting a word array. |
|          |                    |        |                              | Default value is HOLD_LINE_BETWEEN_WORDS.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    spi_master_check_only(SPI_VVCT, 0, x"0D", "Expecting carriage return from Peripheral 1");
    spi_master_check_only(SPI_VVCT, 0, C_CR_BYTE, "Expecting carriage return from Peripheral 1", ERROR, RELEASE_LINE_AFTER_TRANSFER, 
                          HOLD_LINE_BETWEEN_WORDS, C_SCOPE);


.. _spi_slave_transmit_and_receive_vvc:

spi_slave_transmit_and_receive()
----------------------------------------------------------------------------------------------------------------------------------
Adds a slave transmit and receive command to the SPI VVC executor queue, which will run as soon as all preceding commands have 
completed. When the command is scheduled to run, the executor calls the BFM :ref:`spi_slave_transmit_and_receive_bfm` procedure.

The received data will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but the received 
data will be stored in the VVC for a potential future fetch (see example with fetch_result below). 
If the data_routing is set to TO_SB, the received data will be sent to the SPI VVC dedicated scoreboard where it will be 
checked against the expected value (provided by the testbench). This procedure can only be called when the SPI VVC is instantiated 
in slave mode, i.e. setting the VVC entity generic constant 'GC_MASTER_MODE' to 'false'.

.. code-block::

    spi_slave_transmit_and_receive(VVCT, vvc_instance_idx, data, [data_routing,] msg, [when_to_start_transfer, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The data value to be transmitted to the DUT, either a   |
|          |                    |        |                              | single word or a word array.                            |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_routing       | in     | :ref:`t_data_routing`        | Selects the destination of the received data            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | when_to_start_tran\| in     | :ref:`t_when_to_start_transf\| Determines if SPI slave shall wait for next ss_n if a   |
|          | sfer               |        | er`                          | transfer has already started. Default value is          |
|          |                    |        |                              | START_TRANSFER_ON_NEXT_SS.                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    spi_slave_transmit_and_receive(SPI_VVCT, 0, x"0D", "Transmitting carriage return to Peripheral 1 and receiving data back");
    spi_slave_transmit_and_receive(SPI_VVCT, 0, x"0D", TO_SB, "Transmitting carriage return to Peripheral 1 and receiving data back", 
                                   START_TRANSFER_ON_NEXT_SS, C_SCOPE);

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                              -- Command index for the last receive
    variable v_data    : t_slv_array(1 downto 0)(7 downto 0);  -- Data array to transmit
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result;        -- Result from read
    ...
    v_data(0) := x"AB";
    v_data(1) := x"CD";

    spi_slave_transmit_and_receive(SPI_VVCT, 0, v_data, "Transmitting and receiving two bytes");
    v_cmd_idx := get_last_received_cmd_idx(SPI_VVCT, 0);
    await_completion(SPI_VVCT, 0, v_cmd_idx, 1 us, "Wait for transmit and receive to finish");
    fetch_result(SPI_VVCT, 0, v_cmd_idx, v_result, "Fetching first byte from transmit and receive operation");
    fetch_result(SPI_VVCT, 0, v_cmd_idx, v_result, "Fetching second byte from transmit and receive operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.


.. _spi_slave_transmit_only_vvc:

spi_slave_transmit_only()
----------------------------------------------------------------------------------------------------------------------------------
Adds a slave transmit command to the SPI VVC executor queue, which will run as soon as all preceding commands have 
completed. When the command is scheduled to run, the executor calls the BFM :ref:`spi_slave_transmit_bfm` procedure.

This procedure will ignore the received data from the master DUT. This procedure can only be called when the SPI VVC is 
instantiated in slave mode, i.e. setting the VVC entity generic constant 'GC_MASTER_MODE' to 'false'.

.. code-block::

    spi_slave_transmit_only(VVCT, vvc_instance_idx, data, msg, [when_to_start_transfer, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The data value to be transmitted to the DUT, either a   |
|          |                    |        |                              | single word or a word array.                            |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | when_to_start_tran\| in     | :ref:`t_when_to_start_transf\| Determines if SPI slave shall wait for next ss_n if a   |
|          | sfer               |        | er`                          | transfer has already started. Default value is          |
|          |                    |        |                              | START_TRANSFER_ON_NEXT_SS.                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    spi_slave_transmit_only(SPI_VVCT, 0, x"0D", "Transmitting carriage return to Peripheral 1");
    spi_slave_transmit_only(SPI_VVCT, 0, x"0D", "Transmitting carriage return to Peripheral", START_TRANSFER_ON_NEXT_SS, C_SCOPE);


.. _spi_slave_receive_only_vvc:

spi_slave_receive_only()
----------------------------------------------------------------------------------------------------------------------------------
Adds a slave receive command to the SPI VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the BFM :ref:`spi_slave_receive_bfm` procedure.

The procedure will transmit dummy data (0x0) to the DUT.
The received data will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but the received 
data will be stored in the VVC for a potential future fetch (see example with fetch_result below). When receiving multiple words, 
each word must be fetched separately with the same command index.
If the data_routing is set to TO_SB, the received data will be sent to the SPI VVC dedicated scoreboard where it will be 
checked against the expected value (provided by the testbench). This procedure can only be called when the SPI VVC is instantiated 
in slave mode, i.e. setting the VVC entity generic constant 'GC_MASTER_MODE' to 'false'.

.. code-block::

    spi_slave_receive_only(VVCT, vvc_instance_idx, [data_routing,] msg, [num_words, [when_to_start_transfer, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_routing       | in     | :ref:`t_data_routing`        | Selects the destination of the received data            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | num_words          | in     | positive                     | Number of words that shall be received. Default value is|
|          |                    |        |                              | 1.                                                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | when_to_start_tran\| in     | :ref:`t_when_to_start_transf\| Determines if SPI slave shall wait for next ss_n if a   |
|          | sfer               |        | er`                          | transfer has already started. Default value is          |
|          |                    |        |                              | START_TRANSFER_ON_NEXT_SS.                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    spi_slave_receive_only(SPI_VVCT, 0, "Receiving from Peripheral 1");
    spi_slave_receive_only(SPI_VVCT, 0, TO_SB, "Receiving from Peripheral 1", 6, START_TRANSFER_ON_NEXT_SS, C_SCOPE);

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last receive
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from read.
    ...
    spi_slave_receive_only(SPI_VVCT, 0, "Receiving from Peripheral 1"); 
    v_cmd_idx := get_last_received_cmd_idx(SPI_VVCT, 0);
    await_completion(SPI_VVCT, 0, v_cmd_idx, 1 us, "Wait for receive to finish");
    fetch_result(SPI_VVCT, 0, v_cmd_idx, v_result, "Fetching result from receive operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.


.. _spi_slave_transmit_and_check_vvc:

spi_slave_transmit_and_check()
----------------------------------------------------------------------------------------------------------------------------------
Adds a slave transmit and check command to the SPI VVC executor queue, which will run as soon as all preceding commands have 
completed. When the command is scheduled to run, the executor calls the BFM :ref:`spi_slave_transmit_and_check_bfm` procedure.

This procedure can only be called when the SPI VVC is instantiated in slave mode, i.e. setting the VVC entity generic constant 
'GC_MASTER_MODE' to 'false'.

.. code-block::

    spi_slave_transmit_and_check(VVCT, vvc_instance_idx, data, data_exp, msg, [alert_level, [when_to_start_transfer, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_logic_vector             | The data value to be transmitted to the DUT, either a   |
|          |                    |        |                              | single word or a word array.                            |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_logic_vector             | The data value to expect when receiving data from the   |
|          |                    |        |                              | DUT, either a single word or a word array.              |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | when_to_start_tran\| in     | :ref:`t_when_to_start_transf\| Determines if SPI slave shall wait for next ss_n if a   |
|          | sfer               |        | er`                          | transfer has already started. Default value is          |
|          |                    |        |                              | START_TRANSFER_ON_NEXT_SS.                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    variable v_data_tx  : t_slv_array(1 downto 0)(7 downto 0);  -- Data array to transmit
    variable v_data_exp : t_slv_array(1 downto 0)(7 downto 0);  -- Expected data received
    ...
    v_data_tx(0)  := x"AA";
    v_data_tx(1)  := x"BB";
    v_data_exp(0) := x"3A";
    v_data_exp(1) := x"3B";

    spi_slave_transmit_and_check(SPI_VVCT, 0, x"0D", x"5F", "Transmitting carriage return to Peripheral 1 and expecting data back");
    spi_slave_transmit_and_check(SPI_VVCT, 0, v_data_tx, v_data_exp, "Transmitting two bytes to Peripheral 1 and expecting two bytes back",
                                 ERROR, START_TRANSFER_IMMEDIATE, C_SCOPE);


.. _spi_slave_check_only_vvc:

spi_slave_check_only()
----------------------------------------------------------------------------------------------------------------------------------
Adds a slave check command to the SPI VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the BFM :ref:`spi_slave_check_bfm` procedure.

The procedure will transmit dummy data (0x0) to the DUT.
This procedure can only be called when the SPI VVC is instantiated in slave mode, i.e. setting the VVC entity generic constant 
'GC_MASTER_MODE' to 'false'.

.. code-block::

    spi_slave_check_only(VVCT, vvc_instance_idx, data_exp, msg, [alert_level, [when_to_start_transfer, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_logic_vector             | The data value to expect when receiving data from the   |
|          |                    |        |                              | DUT, either a single word or a word array.              |
|          |                    |        | t_slv_array                  |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | when_to_start_tran\| in     | :ref:`t_when_to_start_transf\| Determines if SPI slave shall wait for next ss_n if a   |
|          | sfer               |        | er`                          | transfer has already started. Default value is          |
|          |                    |        |                              | START_TRANSFER_ON_NEXT_SS.                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    variable v_data_exp : t_slv_array(1 downto 0)(7 downto 0);  -- Expected data received
    ...
    v_data_exp(0) := x"3A";
    v_data_exp(1) := x"3B";

    spi_slave_check_only(SPI_VVCT, 0, x"0D", "Expecting carriage return from Peripheral 1");
    spi_slave_check_only(SPI_VVCT, 0, v_data_exp, "Receive and check data from Peripheral 1", ERROR, START_TRANSFER_IMMEDIATE, C_SCOPE);


Activity Watchdog
==================================================================================================================================
.. include:: rst_snippets/vip_activity_watchdog.rst


Transaction Info
==================================================================================================================================
.. include:: rst_snippets/vip_transaction_info.rst

.. table:: SPI transaction info record fields. Transaction Type: t_base_transaction (BT) - accessible via **shared_spi_vvc_transaction_info.bt**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | data                         | t_slv_array(31 downto 0)(31  | 0x0             | The data to be transmitted                      |
    |                              | downto 0)                    |                 |                                                 |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | data_exp                     | t_slv_array(31 downto 0)(31  | 0x0             | The expected data to be received                |
    |                              | downto 0)                    |                 |                                                 |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | num_words                    | natural                      | 0               | Number of words that shall be received          |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | word_length                  | natural                      | 0               | Length of words to be sent or received          |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | when_to_start_transfer       | :ref:`t_when_to_start_transf\| START_TRANSFER\ | Determines if SPI slave shall wait for next ss_n|
    |                              | er`                          | _IMMEDIATE      | if a transfer has already started               |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | action_when_transfer_is_done | :ref:`t_action_when_transfer\| RELEASE_LINE_AF\| Determines if SPI master shall release or hold  |
    |                              | _is_done`                    | TER_TRANSFER    | ss_n after the transfer is done                 |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | action_between_words         | :ref:`t_action_between_words`| HOLD_LINE_BETWE\| Determines if SPI master shall release or hold  |
    |                              |                              | EN_WORDS        | ss_n between words when transmitting a word     |
    |                              |                              |                 | array                                           |
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
i.e. spi_master_receive_only(). Note that the data is only stored in the scoreboard and not accessible with the fetch_result() method 
when the TO_SB parameter is applied. The SPI scoreboard is accessible from the testbench as a shared variable SPI_VVC_SB, located 
in the vvc_methods_pkg.vhd, e.g. ::

    SPI_VVC_SB.add_expected(C_SPI_VVC_IDX, pad_spi_sb(v_expected), "Adding expected");

The SPI scoreboard is per default a 32 bits wide standard logic vector. When sending expected data to the scoreboard, where the 
data width is smaller than the default scoreboard width, we recommend zero-padding the data with the pad_spi_sb() function, e.g. ::

    SPI_VVC_SB.add_expected(<SPI VVC instance number>, pad_spi_sb(<exp data>));

See the :ref:`vip_scoreboard` for a complete list of available commands and additional information. All of the listed Generic
Scoreboard commands are available for the SPI VVC scoreboard using the SPI_VVC_SB.


Unwanted Activity Detection
==================================================================================================================================
.. include:: rst_snippets/vip_unwanted_activity.rst

.. code-block::

    shared_spi_vvc_config(C_VVC_INDEX).unwanted_activity_severity := NO_ALERT;

For SPI VVC, the unwanted activity detection is enabled by default with severity ERROR.

More information can be found in :ref:`Essential Mechanisms - Unwanted Activity Detection <vvc_framework_unwanted_activity>`.


Compilation
==================================================================================================================================
The SPI VVC must be compiled with VHDL-2008 or newer. It is dependent on the following libraries:

    * UVVM Utility Library (UVVM-Util)
    * UVVM VVC Framework
    * Bitvis VIP Scoreboard
    * SPI BFM

Before compiling the SPI VVC, assure that uvvm_util, uvvm_vvc_framework and bitvis_vip_scoreboard have been compiled.

See :ref:`Essential Mechanisms - Compile Scripts <vvc_framework_compile_scripts>` for information about compile scripts.

.. table:: Compile order for the SPI VVC

    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | Compile to library           | File                                           | Comment                                         |
    +==============================+================================================+=================================================+
    | bitvis_vip_spi               | spi_bfm_pkg.vhd                                | SPI BFM                                         |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_spi               | transaction_pkg.vhd                            | SPI transaction package with DTT types,         |
    |                              |                                                | constants, etc.                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_spi               | vvc_cmd_pkg.vhd                                | SPI VVC command types and operations            |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_spi               | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC target support package, compiled into  |
    |                              | _target_support_pkg.vhd                        | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_spi               | ../uvvm_vvc_framework/src_target_dependent/td\ | Common UVVM framework methods compiled into the |
    |                              | _vvc_framework_common_methods_pkg.vhd          | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_spi               | vvc_sb_pkg.vhd                                 | SPI VVC scoreboard                              |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_spi               | vvc_methods_pkg.vhd                            | SPI VVC methods                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_spi               | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM queue package for this VVC                 |
    |                              | _queue_pkg.vhd                                 |                                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_spi               | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC entity support compiled into this      |
    |                              | _vvc_entity_support_pkg.vhd                    | VVC library                                     |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_spi               | spi_vvc.vhd                                    | SPI VVC                                         |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_spi               | vvc_context.vhd                                | SPI VVC context file                            |
    +------------------------------+------------------------------------------------+-------------------------------------------------+

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


Additional Documentation
==================================================================================================================================
For additional documentation on the SPI protocol, please see the SPI specification, e.g. "ST TN0897 Technical note ST SPI protocol. 
ID 023176 Rev 2".

.. important::

    * This is a simplified Verification IP (VIP) for SPI.
    * The given VIP complies with the basic SPI protocol and thus allows a normal access towards a SPI interface.
    * This VIP is not a SPI protocol checker.
    * For a more advanced VIP please contact UVVM support at info@uvvm.org

.. include:: rst_snippets/ip_disclaimer.rst
