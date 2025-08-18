##################################################################################################################################
Bitvis VIP Avalon-ST
##################################################################################################################################

**Quick Access**

* `BFM`_

  * :ref:`avalon_st_transmit_bfm`
  * :ref:`avalon_st_receive_bfm`
  * :ref:`avalon_st_expect_bfm`
  * :ref:`init_avalon_st_if_signals_bfm`

* `VVC`_

  * :ref:`avalon_st_transmit_vvc`
  * :ref:`avalon_st_receive_vvc`
  * :ref:`avalon_st_expect_vvc`


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
BFM
**********************************************************************************************************************************
BFM functionality is implemented in avalon_st_bfm_pkg.vhd

.. _t_avalon_st_if:

Signal Record
==================================================================================================================================
**t_avalon_st_if**

+-------------------------+------------------------------+
| Record element          | Type                         |
+=========================+==============================+
| channel                 | std_logic_vector             |
+-------------------------+------------------------------+
| data                    | std_logic_vector             |
+-------------------------+------------------------------+
| data_error              | std_logic_vector             |
+-------------------------+------------------------------+
| ready                   | std_logic                    |
+-------------------------+------------------------------+
| valid                   | std_logic                    |
+-------------------------+------------------------------+
| empty                   | std_logic_vector             |
+-------------------------+------------------------------+
| end_of_packet           | std_logic                    |
+-------------------------+------------------------------+
| start_of_packet         | std_logic                    |
+-------------------------+------------------------------+

.. note::

    * All supported signals, including channel and data_error are included in the record type, even when not used or connected to 
      the DUT.
    * For more information on the Avalon-ST signals, refer to "Avalon® Interface Specifications, Chapter: Avalon Streaming 
      Interfaces" (MNL-AVABUSREF), available from Intel.

.. _t_avalon_st_bfm_config:

Configuration Record
==================================================================================================================================
**t_avalon_st_bfm_config**

Default value for the record is C_AVALON_ST_BFM_CONFIG_DEFAULT.

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| max_wait_cycles              | natural                      | 100             | The maximum number of clock cycles to wait for  |
|                              |                              |                 | the DUT ready or valid signal before reporting  |
|                              |                              |                 | a timeout alert                                 |
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
| symbol_width                 | natural                      | 8               | Number of data bits per symbol                  |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| first_symbol_in_msb          | boolean                      | true            | Symbol ordering. When true, first-order symbol  |
|                              |                              |                 | is in most significant bits.                    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| max_channel                  | natural                      | 0               | Maximum number of channels that the interface   |
|                              |                              |                 | supports                                        |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| use_packet_transfer          | boolean                      | true            | When true, packet signals are enabled:          |
|                              |                              |                 | start_of_packet, end_of_packet & empty          |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| valid_low_at_word_idx        | integer                      | 0               | Word index during which the master BFM shall    |
|                              |                              |                 | de-assert valid while sending a packet. Can be  |
|                              |                              |                 | set to multiple random indices using            |
|                              |                              |                 | C_MULTIPLE_RANDOM.                              |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| valid_low_multiple_random_pr\| real                         | 0.5             | Probability, between 0.0 and 1.0, of how often  |
| ob                           |                              |                 | valid shall be de-asserted when using           |
|                              |                              |                 | C_MULTIPLE_RANDOM.                              |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| valid_low_duration           | integer                      | 0               | Number of clock cycles to de-assert valid. To   |
|                              |                              |                 | disable this feature set to 0. Can be set to    |
|                              |                              |                 | random using C_RANDOM.                          |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| valid_low_max_random_duration| integer                      | 5               | Maximum number of clock cycles to de-assert     |
|                              |                              |                 | valid when using C_RANDOM.                      |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| ready_low_at_word_idx        | integer                      | 0               | Word index during which the slave BFM shall     |
|                              |                              |                 | de-assert ready while receiving the packet. Can |
|                              |                              |                 | be set to multiple random indices using         |
|                              |                              |                 | C_MULTIPLE_RANDOM.                              |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| ready_low_multiple_random_pr\| real                         | 0.5             | Probability, between 0.0 and 1.0, of how often  |
| ob                           |                              |                 | ready shall be de-asserted when using           |
|                              |                              |                 | C_MULTIPLE_RANDOM.                              |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| ready_low_duration           | integer                      | 0               | Number of clock cycles to de-assert ready. To   |
|                              |                              |                 | disable this feature set to 0. Can be set to    |
|                              |                              |                 | random using C_RANDOM.                          |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| ready_low_max_random_duration| integer                      | 5               | Maximum number of clock cycles to de-assert     |
|                              |                              |                 | ready when using C_RANDOM.                      |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| ready_default_value          | std_logic                    | '0'             | Determines the ready output value while the     |
|                              |                              |                 | slave BFM is idle.                              |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| id_for_bfm                   | t_msg_id                     | ID_BFM          | Message ID used for logging general messages in |
|                              |                              |                 | the BFM                                         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

Methods
==================================================================================================================================
* All signals are active high.
* All parameters in brackets are optional.
* For clarity, data_array is required to be ascending, e.g. ::

    variable v_data_array : t_slv_array(0 to C_MAX_WORDS - 1)(C_MAX_WORD_LENGTH - 1 downto 0);

* For simplicity, the word_length can only be the size of the configured symbol (usually with packet-based transfers) or the size 
  of the data bus (usually with data-based transfers), e.g. ::

    variable v_data_array : t_slv_array(0 to C_MAX_WORDS - 1)(C_SYMBOL_WIDTH - 1 downto 0);
    variable v_data_array : t_slv_array(0 to C_MAX_WORDS - 1)(C_DATA_BUS_LENGTH - 1 downto 0);


.. _avalon_st_transmit_bfm:

avalon_st_transmit()
----------------------------------------------------------------------------------------------------------------------------------
Transmits a stream/packet on the Avalon-ST interface. The length and data are defined by the "data_array" argument, which is a 
t_slv_array. data_array(0) is sent first. data_array(data_array'high) is sent last.

When the config use_packet_transfer is enabled:

  * During the first word, the BFM asserts the start_of_packet signal. 
  * During the last word, the BFM asserts the end_of_packet signal and it sets the number of invalid symbols in the word on the 
    empty signal. 

.. code-block::

    avalon_st_transmit([channel_value,] data_array, msg, clk, avalon_st_if, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | channel_value      | in     | std_logic_vector             | Channel number for the data being transferred. The value|
|          |                    |        |                              | is limited by max_channel in the BFM config             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_array         | in     | t_slv_array                  | An array of SLVs containing the data to be sent         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the Avalon-ST BFM                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | avalon_st_if       | inout  | :ref:`t_avalon_st_if         | Avalon-ST signal interface record                       |
|          |                    |        | <t_avalon_st_if>`            |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AVALON_ST BFM").         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_avalon_st_bfm_config | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_avalon_st_bfm_config>`    | value is C_AVALON_ST_BFM_CONFIG_DEFAULT.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_st_transmit(v_tx_data, "Transmitting data to sink", clk, avalon_st_if);
    avalon_st_transmit(C_CH0, v_tx_data, "Transmitting data to sink", clk, avalon_st_if, C_SCOPE, shared_msg_id_panel, C_AVALON_ST_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    avalon_st_transmit(C_CH0, v_tx_data, "Transmitting data to sink");


.. _avalon_st_receive_bfm:

avalon_st_receive()
----------------------------------------------------------------------------------------------------------------------------------
Receives a stream/packet on the Avalon-ST interface. The received data is stored in the data_array output, which is a t_slv_array.
data_array(0) is received first. data_array(data_array'high) is received last.

When the config use_packet_transfer is enabled:

  * The signal start_of_packet is expected to be set during the first word.
  * The signal end_of_packet is expected to be set during the last word. Also during this word the empty signal is used to 
    determine the number of invalid symbols.

.. code-block::

    avalon_st_receive([channel_value,] data_array, msg, clk, avalon_st_if, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| variable | channel_value      | out    | std_logic_vector             | Channel number for the data being received              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | data_array         | out    | t_slv_array                  | An array of SLVs containing the data to be received     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the Avalon-ST BFM                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | avalon_st_if       | inout  | :ref:`t_avalon_st_if         | Avalon-ST signal interface record                       |
|          |                    |        | <t_avalon_st_if>`            |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AVALON_ST BFM").         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_avalon_st_bfm_config | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_avalon_st_bfm_config>`    | value is C_AVALON_ST_BFM_CONFIG_DEFAULT.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_st_receive(v_rx_data, "Receiving data from source", clk, avalon_st_if);
    avalon_st_receive(v_rx_ch, v_rx_data, "Receiving data from source", clk, avalon_st_if, C_SCOPE, shared_msg_id_panel, C_AVALON_ST_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    avalon_st_receive(v_rx_ch, v_tx_data, "Receiving data from source");


.. _avalon_st_expect_bfm:

avalon_st_expect()
----------------------------------------------------------------------------------------------------------------------------------
Calls the :ref:`avalon_st_receive_bfm` procedure, then compares the received data with data_exp and the optional channel with 
channel_exp.

.. code-block::

    avalon_st_expect([channel_exp,] data_exp, msg, clk, avalon_st_if, [alert_level, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | channel_exp        | in     | std_logic_vector             | Expected channel number for the data being received     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | t_slv_array                  | An array of SLVs containing the expected data           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the Avalon-ST BFM                                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | avalon_st_if       | inout  | :ref:`t_avalon_st_if         | Avalon-ST signal interface record                       |
|          |                    |        | <t_avalon_st_if>`            |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AVALON_ST BFM").         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_avalon_st_bfm_config | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_avalon_st_bfm_config>`    | value is C_AVALON_ST_BFM_CONFIG_DEFAULT.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_st_expect(v_exp_data, "Expecting data from source", clk, avalon_st_if);
    avalon_st_expect(v_exp_ch, v_exp_data, "Expecting data from source", clk, avalon_st_if, ERROR, C_SCOPE, shared_msg_id_panel, C_AVALON_ST_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    avalon_st_expect(v_exp_ch, v_exp_data, "Expecting data from source");


.. _init_avalon_st_if_signals_bfm:

init_avalon_st_if_signals()
----------------------------------------------------------------------------------------------------------------------------------
Initializes the Avalon-ST interface. All the BFM outputs are set to '0', and BFM inputs are set to 'Z'.

.. code-block::

    t_avalon_st_if := init_avalon_st_if_signals(is_master, channel_width, data_width, data_error_width, empty_width)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | is_master          | in     | boolean                      | Whether the VVC is a master or slave interface          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | channel_width      | in     | natural                      | Width of the channel signal                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_width         | in     | natural                      | Width of the data signal                                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_error_width   | in     | natural                      | Width of the data error signal                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | empty_width        | in     | natural                      | Width of the empty signal                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_st_if <= init_avalon_st_if_signals(true, avalon_st_if.channel'length, avalon_st_if.data'length, avalon_st_if.data_error'length, avalon_st_if.empty'length);


Local BFM overloads
==================================================================================================================================
A good approach for better readability and maintainability is to make simple, local overloads for the BFM procedures in the TB 
process. This allows calling the BFM procedures with the key parameters only, e.g. ::

    avalon_st_transmit(C_CH0, v_tx_data, "Transmitting data to sink");

rather than ::

    avalon_st_transmit(C_CH0, v_tx_data, "Transmitting data to sink", clk, avalon_st_if, C_SCOPE, shared_msg_id_panel, C_AVALON_ST_BFM_CONFIG_DEFAULT);

By defining the local overload as e.g. ::

    procedure avalon_st_transmit(
      constant channel_value : in std_logic_vector;
      constant data_array    : in t_slv_array;
      constant msg           : in string) is
    begin
      avalon_st_transmit(channel_value,             -- Keep as is
                         data_array,                -- Keep as is
                         msg,                       -- Keep as is
                         clk,                       -- Signal must be visible in local process scope
                         avalon_st_if,              -- Signal must be visible in local process scope
                         C_SCOPE,                   -- Use the default
                         shared_msg_id_panel,       -- Use global, shared msg_id_panel
                         C_AVALON_ST_CONFIG_LOCAL); -- Use locally defined configuration or C_AVALON_ST_BFM_CONFIG_DEFAULT
    end procedure;

Using a local overload like this also allows the following – if wanted:

* Have channel value as natural – and convert in the overload
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
The following signals from the Avalon-ST interface are supported:

+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| Signal            | Source | Width  | Supported by BFM | Description                                                            |
+===================+========+========+==================+========================================================================+
| associatedClock   | Clock  | 1      | Yes              | Sample on the rising edge                                              |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| associatedReset   | Reset  | 1      | No               | BFM doesn't control the reset                                          |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| channel           | Master | 1-128  | Yes              | Channel number for the data being transferred on the current cycle     |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| data              | Master | 1-4096 | Yes              | Data word. It can consist of several symbols                           |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| error             | Master | 1-256  | No               | Bit mask to mark errors affecting the data being transferred on the    |
|                   |        |        |                  | current cycle. The error_descriptor in the BFM config defines the error|
|                   |        |        |                  | signal properties.                                                     |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| ready             | Slave  | 1      | Yes              | Indicates that the slave can accept data. A transfer takes place when  |
|                   |        |        |                  | both valid and ready are asserted.                                     |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| valid             | Master | 1      | Yes              | This signal qualifies all other master to slave signals. A transfer    |
|                   |        |        |                  | takes place when both valid and ready are asserted.                    |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| empty             | Master | 1-5    | Yes              | Number of symbols that are empty during the end_of_packet cycle. The   |
|                   |        |        |                  | signal width in bits is ceil[log2(symbols_per_cycle)].                 |
|                   |        |        |                  |                                                                        |
|                   |        |        |                  | Only required when the data signal carries more than one symbol of     |
|                   |        |        |                  | data per cycle and has a variable packet length.                       |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| end_of_packet     | Master | 1      | Yes              | When '1', it indicates that the data is the last word of the packet    |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| start_of_packet   | Master | 1      | Yes              | When '1', it indicates that the data is the first word of the packet   |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+

For more information on the Avalon-ST specification, refer to "Avalon® Interface Specifications, Chapter: Avalon Streaming 
Interfaces" (MNL-AVABUSREF), available from Intel.

.. important::

    * This is a simplified Bus Functional Model (BFM) for Avalon-ST.
    * The given BFM complies with the basic Avalon-ST protocol and thus allows a normal access towards an Avalon-ST interface.
    * This BFM is not an Avalon-ST protocol checker.
    * For a more advanced BFM please contact UVVM support at info@uvvm.org


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
VVC
**********************************************************************************************************************************
* VVC functionality is implemented in avalon_st_vvc.vhd
* For general information see :ref:`VVC Framework - Essential Mechanisms <vvc_framework_essential_mechanisms>`.

Entity
==================================================================================================================================

Generics
----------------------------------------------------------------------------------------------------------------------------------

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Name                         | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| GC_VVC_IS_MASTER             | boolean                      | N/A             | Set to true when data shall be output from this |
|                              |                              |                 | VVC. Set to false when data shall be input to   |
|                              |                              |                 | this VVC.                                       |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_CHANNEL_WIDTH             | integer                      | 1               | Width of the Avalon-ST channel signal.          |
|                              |                              |                 |                                                 |
|                              |                              |                 | Note 1: if CHANNEL is wider than 8, increase    |
|                              |                              |                 | the value of the constant C_AVALON_ST_CHANNEL\  |
|                              |                              |                 | _MAX_LENGTH in the local_adaptations_pkg.       |
|                              |                              |                 |                                                 |
|                              |                              |                 | Note 2: If the CHANNEL signal is not used,      |
|                              |                              |                 | refer to `Signals`_                             |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_DATA_WIDTH                | integer                      | N/A             | Width of the Avalon-ST data bus.                |
|                              |                              |                 |                                                 |
|                              |                              |                 | Note: if DATA is wider than 512, increase the   |
|                              |                              |                 | value of the constant C_AVALON_ST_WORD_MAX_LE\  |
|                              |                              |                 | GTH in the local_adaptations_pkg                |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_DATA_ERROR_WIDTH          | integer                      | 1               | Width of the Avalon-ST data error signal.       |
|                              |                              |                 |                                                 |
|                              |                              |                 | Note: If the DATA_ERROR signal is not used,     |
|                              |                              |                 | refer to `Signals`_                             |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_EMPTY_WIDTH               | integer                      | 1               | Width of the Avalon-ST empty signal.            |
|                              |                              |                 |                                                 |
|                              |                              |                 | Note: If the EMPTY signal is not used, refer    |
|                              |                              |                 | to `Signals`_                                   |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_INSTANCE_IDX              | natural                      | N/A             | Instance number to assign the VVC               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_AVALON_ST_BFM_CONFIG      | :ref:`t_avalon_st_bfm_config | C_AVALON_ST_BFM\| Configuration for the Avalon-ST BFM             |
|                              | <t_avalon_st_bfm_config>`    | _CONFIG_DEFAULT |                                                 |
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
| signal   | avalon_st_vvc_if   | inout  | :ref:`t_avalon_st_if         | Avalon-ST signal interface record                       |
|          |                    |        | <t_avalon_st_if>`            |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

In this VVC, the interface has been encapsulated in a signal record of type t_avalon_st_if in order to improve readability of the code. 
Since the Avalon-ST interface buses can be of arbitrary size, the interface vectors have been left unconstrained. These unconstrained 
vectors need to be constrained when the interface signals are instantiated. For this interface, this could look like: ::

    signal avalon_st_if : t_avalon_st_if(channel(C_CHANNEL_WIDTH - 1 downto 0),
                                         data(C_DATA_WIDTH - 1 downto 0),
                                         data_error(C_ERROR_WIDTH - 1 downto 0),
                                         empty(log2(C_DATA_WIDTH / C_SYMBOL_WIDTH) - 1 downto 0));

If the interface signals channel, data_error or empty are not used or not connected to the DUT, the same signal record shall be 
used by setting the widths of the unused signals to 1, e.g. ::

    signal avalon_st_if : t_avalon_st_if(channel(0 downto 0),
                                         data(C_DATA_WIDTH - 1 downto 0),
                                         data_error(C_ERROR_WIDTH - 1 downto 0),
                                         empty(0 downto 0));


Instantiation
----------------------------------------------------------------------------------------------------------------------------------
In order to select between the master and slave modes, the VVC must be instantiated using the correct value of the generic constant 
GC_VVC_IS_MASTER in the testbench or test-harness. Example instantiations of the VVC in both operation supplied for ease of reference.

**Master mode** ::

    i_avalon_st_vvc_master : entity work.avalon_st_vvc
        generic map(
          GC_VVC_IS_MASTER    => true,
          GC_CHANNEL_WIDTH    => GC_CHANNEL_WIDTH,
          GC_DATA_WIDTH       => GC_DATA_WIDTH,
          GC_DATA_ERROR_WIDTH => GC_ERROR_WIDTH,
          GC_EMPTY_WIDTH      => GC_EMPTY_WIDTH,
          GC_INSTANCE_IDX     => 0)
        port map(
          clk               => clk,
          avalon_st_vvc_if  => avalon_st_master_if);

**Slave mode** ::

    i_avalon_st_vvc_slave : entity work.avalon_st_vvc
        generic map(
          GC_VVC_IS_MASTER    => false,
          GC_CHANNEL_WIDTH    => GC_CHANNEL_WIDTH,
          GC_DATA_WIDTH       => GC_DATA_WIDTH,
          GC_DATA_ERROR_WIDTH => GC_ERROR_WIDTH,
          GC_EMPTY_WIDTH      => GC_EMPTY_WIDTH,
          GC_INSTANCE_IDX     => 1)
        port map(
          clk               => clk,
          avalon_st_vvc_if  => avalon_st_slave_if);


Configuration Record
==================================================================================================================================
**vvc_config** accessible via **shared_avalon_st_vvc_config**

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| inter_bfm_delay              | :ref:`t_inter_bfm_delay`     | C_AVALON_ST_INT\| Delay between any requested BFM accesses        |
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
| bfm_config                   | :ref:`t_avalon_st_bfm_config | C_AVALON_ST_BFM\| Configuration for the Avalon-ST BFM             |
|                              | <t_avalon_st_bfm_config>`    | _CONFIG_DEFAULT |                                                 |
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

    shared_avalon_st_vvc_config(C_VVC_IDX).inter_bfm_delay.delay_in_time := 50 ns;
    shared_avalon_st_vvc_config(C_VVC_IDX).bfm_config.clock_period := 10 ns;

Status Record
==================================================================================================================================
**vvc_status** accessible via **shared_avalon_st_vvc_status**

.. include:: rst_snippets/vip_vvc_status.rst

Methods
==================================================================================================================================
* All VVC procedures are defined in vvc_methods_pkg.vhd (dedicated to this VVC).
* See :ref:`vvc_framework_methods` for procedures which are common to all VVCs.
* It is also possible to send a multicast to all instances of a VVC with ALL_INSTANCES as parameter for vvc_instance_idx.
* All parameters in brackets are optional.
* For clarity, data_array is required to be ascending, e.g. ::

    variable v_data_array : t_slv_array(0 to C_MAX_WORDS - 1)(C_MAX_WORD_LENGTH - 1 downto 0);

* For simplicity, the word_length can only be the size of the configured symbol (usually with packet-based transfers) or the size 
  of the data bus (usually with data-based transfers), e.g. ::

    variable v_data_array : t_slv_array(0 to C_MAX_WORDS - 1)(C_SYMBOL_WIDTH - 1 downto 0);
    variable v_data_array : t_slv_array(0 to C_MAX_WORDS - 1)(C_DATA_BUS_LENGTH - 1 downto 0);


.. _avalon_st_transmit_vvc:

avalon_st_transmit()
----------------------------------------------------------------------------------------------------------------------------------
Adds a transmit command to the Avalon-ST VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the BFM :ref:`avalon_st_transmit_bfm` procedure. 
The avalon_st_transmit() procedure can only be called when the Avalon-ST VVC is instantiated in master mode, i.e. setting the 
generic constant 'GC_VVC_IS_MASTER' to true.

.. code-block::

    avalon_st_transmit(VVCT, vvc_instance_idx, [channel_value,] data_array, msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | channel_value      | in     | std_logic_vector             | Channel number for the data being transferred. The value|
|          |                    |        |                              | is limited by max_channel in the BFM config             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_array         | in     | t_slv_array                  | An array of SLVs containing the data to be sent         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_st_transmit(AVALON_ST_VVCT, 0, v_tx_data, "Transmitting data to sink");
    avalon_st_transmit(AVALON_ST_VVCT, 0, C_CH0, v_tx_data, "Transmitting data to sink", C_SCOPE);


.. _avalon_st_receive_vvc:

avalon_st_receive()
----------------------------------------------------------------------------------------------------------------------------------
Adds a receive command to the Avalon-ST VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the :ref:`avalon_st_receive_bfm` procedure. The avalon_st_receive() procedure 
can only be called when the Avalon-ST VVC is instantiated in slave mode, i.e. setting the generic constant 'GC_VVC_IS_MASTER' to 
false.

The value received from the DUT will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but 
the received data and metadata will be stored in the VVC for a potential future fetch (see example with fetch_result below). 

.. code-block::

    avalon_st_receive(VVCT, vvc_instance_idx, data_array_len, data_word_size, msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_array_len     | in     | natural                      | Length of the data_array expected to be received (number|
|          |                    |        |                              | of words)                                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_word_size     | in     | natural                      | Size in bits of the data words in the data_array        |
|          |                    |        |                              | expected to be received                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    avalon_st_receive(AVALON_ST_VVCT, 0, v_data_array'length, v_data_array(0)'length, "Receiving data from source", C_SCOPE);

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last receive
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from receive (data and metadata)
    ...
    avalon_st_receive(AVALON_ST_VVCT, 0, v_data_array'length, v_data_array(0)'length, "Receive data in VVC");
    v_cmd_idx := get_last_received_cmd_idx(AVALON_ST_VVCT, 0);               
    await_completion(AVALON_ST_VVCT, 0, v_cmd_idx, 1 ms, "Wait for receive to finish");
    fetch_result(AVALON_ST_VVCT, 0, v_cmd_idx, v_result, "Fetching result from receive operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.


.. _avalon_st_expect_vvc:

avalon_st_expect()
----------------------------------------------------------------------------------------------------------------------------------
Adds an expect command to the Avalon-ST VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the :ref:`avalon_st_expect_bfm` procedure. 
The avalon_st_expect() procedure can only be called when the Avalon-ST VVC is instantiated in slave mode, i.e. setting the 
generic constant 'GC_VVC_IS_MASTER' to false.

.. code-block::

    avalon_st_expect(VVCT, vvc_instance_idx, [channel_exp,] data_exp, msg, [alert_level, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | channel_exp        | in     | std_logic_vector             | Expected channel number for the data being received     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | t_slv_array                  | An array of SLVs containing the expected data           |
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
    avalon_st_expect(AVALON_ST_VVCT, 0, v_exp_data, "Expecting data from source");
    avalon_st_expect(AVALON_ST_VVCT, 0, v_exp_ch, v_exp_data, "Expecting data from source", ERROR, C_SCOPE);


Activity Watchdog
==================================================================================================================================
.. include:: rst_snippets/vip_activity_watchdog.rst


Transaction Info
==================================================================================================================================
.. include:: rst_snippets/vip_transaction_info.rst

.. table:: Avalon-ST transaction info record fields. Transaction Type: t_base_transaction (BT) - accessible via **shared_avalon_st_vvc_transaction_info.bt**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | channel_value                | std_logic_vector(7 downto 0) | 0x0             | Channel number for the data being transferred or|
    |                              |                              |                 | expected                                        |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | data_array                   | t_slv_array(0 to 1024)(512   | 0x0             | An array of SLVs containing the data to be sent |
    |                              | downto 0)                    |                 | /received                                       |
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
This VVC does not have a built in Scoreboard functionality due to the complexity to make it generic for several use cases. However, 
a dedicated Scoreboard can be added by the user if needed.

See the :ref:`vip_scoreboard` for a complete list of available commands and additional information.


Unwanted Activity Detection
==================================================================================================================================
.. include:: rst_snippets/vip_unwanted_activity.rst

.. code-block::

    shared_avalon_st_vvc_config(C_VVC_INDEX).unwanted_activity_severity := NO_ALERT;

Note that the ready signal is not monitored in this VVC. The ready signal is allowed to be set independently of the valid signal, 
and there is no method to differentiate between the unwanted activity and intended activity. See the Avalon-ST protocol specification 
for more information on the ready signal. 

The unwanted activity detection is ignored when the valid signal goes low within one clock period after the VVC becomes inactive. 
This is to handle the situation when the read command exits before the next rising edge, causing signal transitions during the 
first clock cycle after the VVC is inactive. 

For Avalon-ST VVC, the unwanted activity detection is enabled by default with severity ERROR.

More information can be found in :ref:`Essential Mechanisms - Unwanted Activity Detection <vvc_framework_unwanted_activity>`.


Compilation
==================================================================================================================================
The Avalon-ST VVC must be compiled with VHDL-2008 or newer. It is dependent on the following libraries:

    * UVVM Utility Library (UVVM-Util)
    * UVVM VVC Framework
    * Avalon-ST BFM

Before compiling the Avalon-ST VVC, assure that uvvm_util and uvvm_vvc_framework have been compiled.

See :ref:`Essential Mechanisms - Compile Scripts <vvc_framework_compile_scripts>` for information about compile scripts.

.. table:: Compile order for the Avalon-ST VVC

    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | Compile to library           | File                                           | Comment                                         |
    +==============================+================================================+=================================================+
    | bitvis_vip_avalon_st         | avalon_st_bfm_pkg.vhd                          | Avalon-ST BFM                                   |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_avalon_st         | transaction_pkg.vhd                            | Avalon-ST transaction package with DTT types,   |
    |                              |                                                | constants, etc.                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_avalon_st         | vvc_cmd_pkg.vhd                                | Avalon-ST VVC command types and operations      |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_avalon_st         | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC target support package, compiled into  |
    |                              | _target_support_pkg.vhd                        | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_avalon_st         | ../uvvm_vvc_framework/src_target_dependent/td\ | Common UVVM framework methods compiled into the |
    |                              | _vvc_framework_common_methods_pkg.vhd          | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_avalon_st         | vvc_methods_pkg.vhd                            | Avalon-ST VVC methods                           |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_avalon_st         | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM queue package for this VVC                 |
    |                              | _queue_pkg.vhd                                 |                                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_avalon_st         | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC entity support compiled into this      |
    |                              | _vvc_entity_support_pkg.vhd                    | VVC library                                     |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_avalon_st         | avalon_st_vvc.vhd                              | Avalon-ST VVC                                   |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_avalon_st         | vvc_context.vhd                                | Avalon-ST VVC context file                      |
    +------------------------------+------------------------------------------------+-------------------------------------------------+

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


Additional Documentation
==================================================================================================================================
For more information on the Avalon-ST specification, refer to "Avalon® Interface Specifications, Chapter: Avalon Streaming 
Interfaces" (MNL-AVABUSREF), available from Intel.

.. important::

    * This is a simplified Verification IP (VIP) for Avalon-ST.
    * The given VIP complies with the basic Avalon-ST protocol and thus allows a normal access towards an Avalon-ST interface.
    * This VIP is not an Avalon-ST protocol checker.
    * For a more advanced VIP please contact UVVM support at info@uvvm.org

.. include:: rst_snippets/ip_disclaimer.rst
