##################################################################################################################################
Bitvis VIP AXI4-Stream
##################################################################################################################################

**Quick Access**

* `BFM`_

  * :ref:`axistream_transmit_bfm`
  * :ref:`axistream_receive_bfm`
  * :ref:`axistream_expect_bfm`
  * :ref:`init_axistream_if_signals_bfm`

* `VVC`_

  * :ref:`axistream_transmit_vvc`
  * :ref:`axistream_receive_vvc`
  * :ref:`axistream_expect_vvc`


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
BFM
**********************************************************************************************************************************
BFM functionality is implemented in axistream_bfm_pkg.vhd

.. _t_axistream_if:

Signal Record
==================================================================================================================================
**t_axistream_if**

+-------------------------+------------------------------+
| Record element          | Type                         |
+=========================+==============================+
| tdata                   | std_logic_vector             |
+-------------------------+------------------------------+
| tkeep                   | std_logic_vector             |
+-------------------------+------------------------------+
| tuser                   | std_logic_vector             |
+-------------------------+------------------------------+
| tvalid                  | std_logic                    |
+-------------------------+------------------------------+
| tlast                   | std_logic                    |
+-------------------------+------------------------------+
| tready                  | std_logic                    |
+-------------------------+------------------------------+
| tstrb                   | std_logic_vector             |
+-------------------------+------------------------------+
| tid                     | std_logic_vector             |
+-------------------------+------------------------------+
| tdest                   | std_logic_vector             |
+-------------------------+------------------------------+

.. note::

    * All supported signals are included in the record type even when not used or connected to the DUT.
    * For more information on the AXI4-Stream signals, refer to "AMBA® 4 AXI4-Stream Protocol Specification" (ARM IHI 0051A), 
      available from ARM.

.. _t_axistream_bfm_config:

Configuration Record
==================================================================================================================================
**t_axistream_bfm_config**

Default value for the record is C_AXISTREAM_BFM_CONFIG_DEFAULT.

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| max_wait_cycles              | integer                      | 100             | The maximum number of clock cycles to wait for  |
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
| byte_endianness              | :ref:`t_byte_endianness`     | LOWER_BYTE_LEFT | Little-endian or big-endian endianness byte     |
|                              |                              |                 | ordering when using a t_slv_array with          |
|                              |                              |                 | multiple-byte width per array element.          |
|                              |                              |                 |                                                 |
|                              |                              |                 | Possible values are LOWER_BYTE_LEFT or          |
|                              |                              |                 | LOWER_BYTE_RIGHT.                               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| valid_low_at_word_num        | integer                      | 0               | Word index during which the master BFM shall    |
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
| check_packet_length          | boolean                      | false           | When true, receive() will check that tlast is   |
|                              |                              |                 | set at data_array'high. Set to false when length|
|                              |                              |                 | of packet to be received is unknown.            |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| protocol_error_severity      | :ref:`t_alert_level`         | ERROR           | Severity if protocol errors are detected.       |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| ready_low_at_word_num        | integer                      | 0               | Word index during which the slave BFM shall     |
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

    variable v_data_array : t_slv_array(0 to C_MAX_BYTES - 1)(7 downto 0);


.. _axistream_transmit_bfm:

axistream_transmit()
----------------------------------------------------------------------------------------------------------------------------------
Transmits a packet on the AXI4-Stream interface. The packet length and data are defined by the 'data_array' argument, and is either 
a t_slv_array or a std_logic_vector.

  * data_array(0) is sent first, data_array(data_array'high) is sent last.
  * When using a multiple-byte width per array element, the byte_endianness in the config determines which byte is sent first.
  * Byte locations within the data word are defined in chapter 2.3 in "AMBA® 4 AXI4-Stream Protocol Specification" (ARM IHI 0051A), 
    available from ARM.

The values to be transmitted on the signal TUSER are defined by the optional user_array parameter. There is one user_array index 
per transfer (data word). If user_array is omitted in the BFM call, the BFM transmits all zeros on the TUSER signal.

The values to be transmitted on the signals TSTRB, TID, TDEST are defined by the parameters strb_array, id_array and dest_array. 
There is one array index per transfer (data word). All or none of these three arrays may be omitted in the BFM call. If they are 
omitted, the BFM transmits all zeros on the TSTRB, TID, TDEST signals.

At the last word, the BFM asserts the TLAST bit, and it asserts the TKEEP bits corresponding to the data bytes that are valid within 
the word. At all other words, all TKEEP bits are '1', thus the BFM supports only "continuous aligned stream", as described in 
chapter 1.2.2 in "AMBA® 4 AXI4-Stream Protocol Specification" (ARM IHI 0051A).

.. code-block::

    axistream_transmit(data_array, [user_array, [strb_array, id_array, dest_array]], msg, clk, axistream_if, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | data_array         | in     | t_slv_array or               | An array of SLVs or a single std_logic_vector containing|
|          |                    |        | std_logic_vector             | the data to be sent                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | user_array         | in     | `t_user_array`_              | Side-band data to be sent via the TUSER signal.         |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of entries in user_array equals the number   |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | For example, if 16 bytes shall be sent, and there are   |
|          |                    |        |                              | 8 bytes transmitted per transfer, the user_array has    |
|          |                    |        |                              | 2 entries.                                              |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each user_array     |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tuser.   |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tuser is wider than 32, increase  |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TUSER_BITS in adaptations_pkg.      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | strb_array         | in     | `t_strb_array`_              | Side-band data to be sent via the TSTRB signal. The     |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | BFM transmits the values without affecting TDATA.       |
|          |                    |        |                              | The number of entries in strb_array equals the number   |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each strb_array     |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tstrb.   |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tstrb is wider than 32, increase  |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TSTRB_BITS in adaptations_pkg.      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | id_array           | in     | `t_id_array`_                | Side-band data to be sent via the TID signal.           |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of entries in id_array equals the number     |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each id_array       |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tid.     |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tid is wider than 8, increase     |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TID_BITS in adaptations_pkg.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dest_array         | in     | `t_dest_array`_              | Side-band data to be sent via the TDEST signal.         |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of entries in dest_array equals the number   |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each dest_array     |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tdest.   |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tdest is wider than 4, increase   |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TDEST_BITS in adaptations_pkg.      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the AXI4-Stream BFM                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | axistream_if       | inout  | :ref:`t_axistream_if         | AXI4-Stream signal interface record                     |
|          |                    |        | <t_axistream_if>`            |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AXISTREAM_BFM").         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_axistream_bfm_config | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_axistream_bfm_config>`    | value is C_AXISTREAM_BFM_CONFIG_DEFAULT.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    axistream_transmit((x"D0", x"D1", x"D2", x"D3"), (x"00", x"0A"), "Send a 4 byte packet with tuser=A at the 2nd (last) word", clk, axistream_if);               -- tdata'length = 16
    axistream_transmit((x"D0", x"D1", x"D2", x"D3"), (x"00", x"00", x"00", x"0A"), "Send a 4 byte packet with tuser=A at the 4th (last) word", clk, axistream_if); -- tdata'length = 8
    axistream_transmit(v_data_array(0 to v_num_bytes - 1), "Send v_num_bytes bytes", clk, axistream_if);
    axistream_transmit(v_data_array(0 to v_num_bytes - 1)(15 downto 0), "Send 2 x v_num_bytes bytes", clk, axistream_if);
    axistream_transmit(v_data_array(0 to v_num_bytes - 1), v_user_array(0 to v_num_words - 1), v_strb_array(0 to v_num_words - 1), v_id_array(0 to v_num_words - 1),
                       v_dest_array(0 to v_num_words - 1), "Send v_num_bytes bytes with tuser, tstrb, tid and tdest", clk, axistream_if, C_SCOPE, shared_msg_id_panel, C_AXISTREAM_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    axistream_transmit(v_data_array(0 to v_num_bytes - 1), "Send v_num_bytes bytes");
    axistream_transmit(v_data_array(0 to v_num_bytes - 1), v_user_array(0 to v_num_words - 1), v_strb_array(0 to v_num_words - 1), v_id_array(0 to v_num_words - 1), 
                       v_dest_array(0 to v_num_words - 1), "Send v_num_bytes bytes with tuser, tstrb, tid and tdest");


.. _axistream_receive_bfm:

axistream_receive()
----------------------------------------------------------------------------------------------------------------------------------
Receives a packet on the AXI4-Stream interface. The received packet data is stored in the 'data_array' output. data_array'length 
can be longer than the actual packet received, so that you can call the procedure without knowing the length to be expected. The 
number of bytes received is indicated in the 'data_length' output. 

  * The sampled values of the TUSER signal are stored in user_array, which has one entry per transfer (data word). 
  * The sampled values of the TSTRB signal are stored in strb_array, which has one entry per transfer (data word). 
  * The sampled values of the TID signal are stored in id_array, which has one entry per transfer (data word). 
  * The sampled values of the TDEST signal are stored in dest_array, which has one entry per transfer (data word). 

When TLAST = '1', the TKEEP bits are used to determine the number of valid data bytes within the last word. At all other words, the 
BFM checks that all TKEEP bits are '1', since the BFM supports only "continuous aligned stream", as described in chapter 1.2.2 in 
"AMBA® 4 AXI4-Stream Protocol Specification" (ARM IHI 0051A).

.. code-block::

    axistream_receive(data_array, data_length, user_array, strb_array, id_array, dest_array, msg, clk, axistream_if, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| variable | data_array         | inout  | t_slv_array                  | An array of SLVs or a single std_logic_vector containing|
|          |                    |        |                              | the data to be received                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | data_length        | inout  | natural                      | The number of bytes received, i.e. the number of valid  |
|          |                    |        |                              | bytes in data_array                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | user_array         | inout  | `t_user_array`_              | Side-band data to be received via the TUSER signal.     |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of entries in user_array equals the number   |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | For example, if 16 bytes shall be received, and there   |
|          |                    |        |                              | are 8 bytes received per transfer, the user_array has   |
|          |                    |        |                              | 2 entries.                                              |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each user_array     |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tuser.   |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tuser is wider than 32, increase  |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TUSER_BITS in adaptations_pkg.      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | strb_array         | inout  | `t_strb_array`_              | Side-band data to be received via the TSTRB signal.     |
|          |                    |        |                              | The BFM receives the values without affecting TDATA.    |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of entries in strb_array equals the number   |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each strb_array     |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tstrb.   |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tstrb is wider than 32, increase  |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TSTRB_BITS in adaptations_pkg.      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | id_array           | inout  | `t_id_array`_                | Side-band data to be received via the TID signal.       |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of entries in id_array equals the number     |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each id_array       |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tid.     |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tid is wider than 8, increase     |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TID_BITS in adaptations_pkg.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | dest_array         | inout  | `t_dest_array`_              | Side-band data to be received via the TDEST signal.     |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of entries in dest_array equals the number   |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each dest_array     |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tdest.   |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tdest is wider than 4, increase   |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TDEST_BITS in adaptations_pkg.      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the AXI4-Stream BFM                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | axistream_if       | inout  | :ref:`t_axistream_if         | AXI4-Stream signal interface record                     |
|          |                    |        | <t_axistream_if>`            |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AXISTREAM_BFM").         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_axistream_bfm_config | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_axistream_bfm_config>`    | value is C_AXISTREAM_BFM_CONFIG_DEFAULT.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    axistream_receive(v_rx_data_array, v_rx_length, v_rx_user_array, v_rx_strb_array, v_rx_id_array, v_rx_dest_array, "Receive packet", clk, axistream_if, 
                      C_SCOPE, shared_msg_id_panel, C_AXISTREAM_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    axistream_receive(v_rx_data_array, v_rx_length, v_rx_user_array, v_rx_strb_array, v_rx_id_array, v_rx_dest_array, "Receive packet");


.. _axistream_expect_bfm:

axistream_expect()
----------------------------------------------------------------------------------------------------------------------------------
Calls the :ref:`axistream_receive_bfm` procedure, then compares the received data with 'exp_data_array'. The 'exp_user_array', 
'exp_strb_array', 'exp_id_array' and 'exp_dest_array' are compared to the received user_array, strb_array, id_array and dest_array 
respectively. If some signals are unused, the checks can by skipped by filling the corresponding exp_*_array with don't cares. 
For example: ``v_dest_array := (others => (others => '-'));``

.. code-block::

    axistream_expect(exp_data_array, [exp_user_array, [exp_strb_array, exp_id_array, exp_dest_array]], msg, clk, axistream_if, [alert_level, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | exp_data_array     | in     | t_slv_array or               | An array of SLVs or a single std_logic_vector containing|
|          |                    |        | std_logic_vector             | the expected data to be received                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | exp_user_array     | in     | `t_user_array`_              | Expected side-band data via the TUSER signal.           |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of entries in user_array equals the number   |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | For example, if 16 bytes shall be sent, and there are   |
|          |                    |        |                              | 8 bytes transmitted per transfer, the user_array has    |
|          |                    |        |                              | 2 entries.                                              |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each user_array     |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tuser.   |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tuser is wider than 32, increase  |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TUSER_BITS in adaptations_pkg.      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | exp_strb_array     | in     | `t_strb_array`_              | Expected side-band data via the TSTRB signal. The BFM   |
|          |                    |        |                              | transmits the values without affecting TDATA.           |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of entries in strb_array equals the number   |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each strb_array     |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tstrb.   |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tstrb is wider than 32, increase  |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TSTRB_BITS in adaptations_pkg.      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | exp_id_array       | in     | `t_id_array`_                | Expected side-band data via the TID signal.             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of entries in id_array equals the number     |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each id_array       |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tid.     |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tid is wider than 8, increase     |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TID_BITS in adaptations_pkg.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | exp_dest_array     | in     | `t_dest_array`_              | Expected side-band data via the TDEST signal.           |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of entries in dest_array equals the number   |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each dest_array     |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tdest.   |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tdest is wider than 4, increase   |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TDEST_BITS in adaptations_pkg.      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the AXI4-Stream BFM                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | axistream_if       | inout  | :ref:`t_axistream_if         | AXI4-Stream signal interface record                     |
|          |                    |        | <t_axistream_if>`            |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AXISTREAM_BFM").         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_axistream_bfm_config | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_axistream_bfm_config>`    | value is C_AXISTREAM_BFM_CONFIG_DEFAULT.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    axistream_expect((x"D0", x"D1", x"D2", x"D3"), (x"00", x"0A"), "Expect a 4 byte packet with tuser=A at the 2nd (last) word", clk, axistream_if);               -- tdata'length = 16
    axistream_expect((x"D0", x"D1", x"D2", x"D3"), (x"00", x"00", x"00", x"0A"), "Expect a 4 byte packet with tuser=A at the 4th (last) word", clk, axistream_if); -- tdata'length =  8
    axistream_expect(v_data_array(0 to 1), "Expect a 2 byte packet, ignoring the tuser bits", clk, axistream_if);
    axistream_expect(v_data_array(0 to v_num_bytes - 1), v_user_array(0 to v_num_words - 1), "Expect a packet, check data and tuser, but ignore tstrb, tid, tdest", clk, axistream_if);
    axistream_expect(v_data_array(0 to v_num_bytes - 1), v_user_array(0 to v_num_words - 1), v_strb_array(0 to v_num_words - 1), v_id_array(0 to v_num_words - 1), 
                     v_dest_array(0 to v_num_words - 1), "Expect a packet", clk, axistream_if, C_SCOPE, shared_msg_id_panel, C_AXISTREAM_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    axistream_expect(v_data_array(0 to 1), "Expect a 2 byte packet, ignoring the tuser bits");
    axistream_expect(v_data_array(0 to v_num_bytes - 1), v_user_array(0 to v_num_words - 1), v_strb_array(0 to v_num_words - 1), v_id_array(0 to v_num_words - 1), 
                     v_dest_array(0 to v_num_words - 1), "Expect a packet");


.. _init_axistream_if_signals_bfm:

init_axistream_if_signals()
----------------------------------------------------------------------------------------------------------------------------------
Initializes the AXI4-Stream interface. All the BFM outputs are set to '0', and BFM inputs are set to 'Z'.

.. code-block::

    t_axistream_if := init_axistream_if_signals(is_master, data_width, user_width, id_width, dest_width, config)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | is_master          | in     | boolean                      | Whether the VVC is a master or slave interface          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_width         | in     | natural                      | Width of the TDATA signal                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | user_width         | in     | natural                      | Width of the TUSER signal                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | id_width           | in     | natural                      | Width of the TID signal                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dest_width         | in     | natural                      | Width of the TDEST signal                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_axistream_bfm_config | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_axistream_bfm_config>`    | value is C_AXISTREAM_BFM_CONFIG_DEFAULT.                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    axistream_if <= init_axistream_if_signals(true, axistream_if.tdata'length, axistream_if.tuser'length, axistream_if.tid'length, axistream_if.tdest'length);


Local types
==================================================================================================================================
.. _t_user_array:

t_user_array
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    array (natural range <>) of std_logic_vector(C_AXISTREAM_BFM_MAX_TUSER_BITS - 1 downto 0)

.. _t_strb_array:

t_strb_array
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    array (natural range <>) of std_logic_vector(C_AXISTREAM_BFM_MAX_TSTRB_BITS - 1 downto 0)

.. _t_id_array:

t_id_array
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    array (natural range <>) of std_logic_vector(C_AXISTREAM_BFM_MAX_TID_BITS - 1 downto 0)

.. _t_dest_array:

t_dest_array
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    array (natural range <>) of std_logic_vector(C_AXISTREAM_BFM_MAX_TDEST_BITS - 1 downto 0)


Local BFM overloads
==================================================================================================================================
A good approach for better readability and maintainability is to make simple, local overloads for the BFM procedures in the TB 
process. This allows calling the BFM procedures with the key parameters only, e.g. ::

    axistream_transmit(v_data_array(0 to 1), "Transmitting data to sink");

rather than ::

    axistream_transmit(v_data_array(0 to 1), "Transmitting data to sink", clk, axistream_if, C_SCOPE, shared_msg_id_panel, C_AXISTREAM_BFM_CONFIG_DEFAULT);

By defining the local overload as e.g. ::

    procedure axistream_transmit(
      constant data_array : in t_slv_array;
      constant msg        : in string) is
    begin
      axistream_transmit(data_array,                -- Keep as is
                         msg,                       -- Keep as is
                         clk,                       -- Signal must be visible in local process scope
                         axistream_if,              -- Signal must be visible in local process scope
                         C_SCOPE,                   -- Use the default
                         shared_msg_id_panel,       -- Use global, shared msg_id_panel
                         C_AXISTREAM_CONFIG_LOCAL); -- Use locally defined configuration or C_AXISTREAM_BFM_CONFIG_DEFAULT
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
The following signals from the AXI4-Stream interface are supported:

+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| Signal            | Source | Width  | Supported by BFM | Description                                                            |
+===================+========+========+==================+========================================================================+
| ACLK              | Clock  | 1      | Yes              | Sample on the rising edge                                              |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| ARESETn           | Reset  | 1      | No               | BFM doesn't control the reset                                          |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| TVALID            | Master | 1      | Yes              | This signal qualifies all other master to slave signals. A transfer    |
|                   |        |        |                  | takes place when both TVALID and TREADY are asserted.                  |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| TREADY            | Slave  | 1      | Yes              | Indicates that the slave can accept data. A transfer takes place when  |
|                   |        |        |                  | both TVALID and TREADY are asserted.                                   |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| TDATA             | Master | n*8    | Yes              | Data word. The width must be a multiple of bytes                       |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| TUSER             | Master | 1:32   | Yes              | Side-band info transmitted alongside the data stream.                  |
|                   |        |        |                  |                                                                        |
|                   |        |        |                  | If axistream_if.tuser is wider than 32, increase                       |
|                   |        |        |                  | C_AXISTREAM_BFM_MAX_TUSER_BITS in adaptations_pkg.                     |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| TSTRB             | Master | 1:32   | Yes              | The protocol uses this signal for marking TDATA as position byte, but  |
|                   |        |        |                  | the BFM simply sends/receives/checks the values of TSTRB               |
|                   |        |        |                  |                                                                        |
|                   |        |        |                  | as specified by the sequencer without affecting TDATA.                 |
|                   |        |        |                  |                                                                        |
|                   |        |        |                  | While transmitting, the test sequencer defines what TSTRB values to    |
|                   |        |        |                  | send. The BFM transmits TDATA regardless of the TSTRB value.           |
|                   |        |        |                  |                                                                        |
|                   |        |        |                  | While receiving, the received TSTRB values are presented to the test   |
|                   |        |        |                  | sequencer. The BFM presents TDATA regardless of the TSTRB value.       |
|                   |        |        |                  |                                                                        |
|                   |        |        |                  | If axistream_if.tstrb is wider than 32, increase                       |
|                   |        |        |                  | C_AXISTREAM_BFM_MAX_TSTRB_BITS in adaptations_pkg.                     |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| TKEEP             | Master | TDATA'\| Partly           | When TKEEP is '0', it indicates a null byte that can be removed from   |
|                   |        | length |                  | the stream.                                                            |
|                   |        | / 8    |                  |                                                                        |
|                   |        |        |                  | Null bytes are only used for signalling the number of valid bytes in   |
|                   |        |        |                  | the last data word.                                                    |
|                   |        |        |                  |                                                                        |
|                   |        |        |                  | Leading or intermediate null bytes are not supported.                  |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| TLAST             | Master | 1      | Yes              | When '1', it indicates that the TDATA is the last word of the packet   |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| TID               | Master | 1:8    | Yes              | Indicates different streams of data. Usually used by routing           |
|                   |        |        |                  | infrastructures.                                                       |
|                   |        |        |                  |                                                                        |
|                   |        |        |                  | When BFM is transmitting, the test sequencer defines what TID values   |
|                   |        |        |                  | to send.                                                               |
|                   |        |        |                  |                                                                        |
|                   |        |        |                  | When BFM is receiving, the received TID values are presented to the    |
|                   |        |        |                  | test sequencer.                                                        |
|                   |        |        |                  |                                                                        |
|                   |        |        |                  | If axistream_if.tid is wider than 8, increase                          |
|                   |        |        |                  | C_AXISTREAM_BFM_MAX_TID_BITS in adaptations_pkg.                       |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+
| TDEST             | Master | 1:4    | Yes              | Provides routing info for the data stream. Usually used by routing     |
|                   |        |        |                  | infrastructures.                                                       |
|                   |        |        |                  |                                                                        |
|                   |        |        |                  | When BFM is transmitting, the test sequencer defines what TDEST        |
|                   |        |        |                  | values to send.                                                        |
|                   |        |        |                  |                                                                        |
|                   |        |        |                  | When BFM is receiving, the received TDEST values are presented to the  |
|                   |        |        |                  | test sequencer.                                                        |
|                   |        |        |                  |                                                                        |
|                   |        |        |                  | If axistream_if.tdest is wider than 4, increase                        |
|                   |        |        |                  | C_AXISTREAM_BFM_MAX_TDEST_BITS in adaptations_pkg.                     |
+-------------------+--------+--------+------------------+------------------------------------------------------------------------+

This BFM only supports the "continuous aligned stream" subset of the AXI4-Stream protocol.
For more information on the AXI4-Stream specification, refer to "AMBA® 4 AXI4-Stream Protocol Specification" (ARM IHI 0051A), 
available from ARM.

.. important::

    * This is a simplified Bus Functional Model (BFM) for AXI4-Stream.
    * The given BFM complies with the basic AXI4-Stream protocol and thus allows a normal access towards an AXI4-Stream interface.
    * This BFM is not an AXI4-Stream protocol checker.
    * For a more advanced BFM please contact UVVM support at info@uvvm.org


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
VVC
**********************************************************************************************************************************
* VVC functionality is implemented in axistream_vvc.vhd
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
| GC_DATA_WIDTH                | integer                      | N/A             | Width of the AXI4-Stream data bus.              |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_USER_WIDTH                | integer                      | 1               | Width of the AXI4-Stream TUSER signal.          |
|                              |                              |                 |                                                 |
|                              |                              |                 | Note 1: if TUSER is wider than 8, increase the  |
|                              |                              |                 | value of the constant C_AXISTREAM_BFM_MAX_TUS\  |
|                              |                              |                 | ER_BITS in adaptations_pkg.                     |
|                              |                              |                 |                                                 |
|                              |                              |                 | Note 2: If the TUSER signal is not used, refer  |
|                              |                              |                 | to `Signals`_                                   |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_ID_WIDTH                  | integer                      | 1               | Width of the AXI4-Stream TID signal.            |
|                              |                              |                 |                                                 |
|                              |                              |                 | Note 1: if TID is wider than 8, increase the    |
|                              |                              |                 | value of the constant C_AXISTREAM_BFM_MAX_TID\  |
|                              |                              |                 | _BITS in adaptations_pkg.                       |
|                              |                              |                 |                                                 |
|                              |                              |                 | Note 2: If the TID signal is not used, refer    |
|                              |                              |                 | to `Signals`_                                   |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_DEST_WIDTH                | integer                      | 1               | Width of the AXI4-Stream TDEST signal.          |
|                              |                              |                 |                                                 |
|                              |                              |                 | Note 1: if TDEST is wider than 4, increase the  |
|                              |                              |                 | value of the constant C_AXISTREAM_BFM_MAX_TDE\  |
|                              |                              |                 | ST_BITS in adaptations_pkg.                     |
|                              |                              |                 |                                                 |
|                              |                              |                 | Note 2: If the TDEST signal is not used, refer  |
|                              |                              |                 | to `Signals`_                                   |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_INSTANCE_IDX              | natural                      | N/A             | Instance number to assign the VVC               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_PACKETINFO_QUEUE_COUNT_MAX| natural                      | 1               | DEPRECATED                                      |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_AXISTREAM_BFM_CONFIG      | :ref:`t_axistream_bfm_config | C_AXISTREAM_BFM\| Configuration for the AXI4-Stream BFM           |
|                              | <t_axistream_bfm_config>`    | _CONFIG_DEFAULT |                                                 |
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
| signal   | axistream_vvc_if   | inout  | :ref:`t_axistream_if         | AXI4-Stream signal interface record                     |
|          |                    |        | <t_axistream_if>`            |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

In this VVC, the interface has been encapsulated in a signal record of type t_axistream_if in order to improve readability of the code. 
Since the AXI4-Stream interface buses can be of arbitrary size, the interface vectors have been left unconstrained. These unconstrained 
vectors need to be constrained when the interface signals are instantiated. For this interface, this could look like: ::

    signal axistream_if : t_axistream_if(tdata(C_DATA_WIDTH - 1 downto 0),
                                         tkeep((C_DATA_WIDTH / 8) - 1 downto 0),
                                         tuser(C_USER_WIDTH - 1 downto 0),
                                         tstrb((C_DATA_WIDTH / 8) - 1 downto 0),
                                         tid(C_ID_WIDTH - 1 downto 0),
                                         tdest(C_DEST_WIDTH - 1 downto 0));

If the interface signals tuser, tstrb, tid or tdest are not used or not connected to the DUT, the same signal record shall be 
used by setting the widths of the unused signals to 1, e.g. ::

    signal axistream_if : t_axistream_if(tdata(C_DATA_WIDTH - 1 downto 0),
                                         tkeep((C_DATA_WIDTH / 8) - 1 downto 0),
                                         tuser(0 downto 0),
                                         tstrb(0 downto 0),
                                         tid(0 downto 0),
                                         tdest(0 downto 0));


Instantiation
----------------------------------------------------------------------------------------------------------------------------------
In order to select between the master and slave modes, the VVC must be instantiated using the correct value of the generic constant 
GC_VVC_IS_MASTER in the testbench or test-harness. Example instantiations of the VVC in both operation supplied for ease of reference.

**Master mode** ::

    i_axistream_vvc_master : entity work.axistream_vvc
        generic map(
          GC_VVC_IS_MASTER  => true,
          GC_DATA_WIDTH     => GC_DATA_WIDTH,
          GC_USER_WIDTH     => GC_USER_WIDTH,
          GC_ID_WIDTH       => GC_ID_WIDTH,
          GC_DEST_WIDTH     => GC_DEST_WIDTH,
          GC_INSTANCE_IDX   => 0)
        port map(
          clk               => clk,
          axistream_vvc_if  => axistream_master_if);

**Slave mode** ::

    i_axistream_vvc_slave : entity work.axistream_vvc
        generic map(
          GC_VVC_IS_MASTER  => false,
          GC_DATA_WIDTH     => GC_DATA_WIDTH,
          GC_USER_WIDTH     => GC_USER_WIDTH,
          GC_ID_WIDTH       => GC_ID_WIDTH,
          GC_DEST_WIDTH     => GC_DEST_WIDTH,
          GC_INSTANCE_IDX   => 1)
        port map(
          clk               => clk,
          axistream_vvc_if  => axistream_slave_if);


Configuration Record
==================================================================================================================================
**vvc_config** accessible via **shared_axistream_vvc_config**

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| inter_bfm_delay              | :ref:`t_inter_bfm_delay`     | C_AXISTREAM_INT\| Delay between any requested BFM accesses        |
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
| bfm_config                   | :ref:`t_axistream_bfm_config | C_AXISTREAM_BFM\| Configuration for the AXI4-Stream BFM           |
|                              | <t_axistream_bfm_config>`    | _CONFIG_DEFAULT |                                                 |
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

    shared_axistream_vvc_config(C_VVC_IDX).inter_bfm_delay.delay_in_time := 50 ns;
    shared_axistream_vvc_config(C_VVC_IDX).bfm_config.clock_period := 10 ns;

Status Record
==================================================================================================================================
**vvc_status** accessible via **shared_axistream_vvc_status**

.. include:: rst_snippets/vip_vvc_status.rst

Methods
==================================================================================================================================
* All VVC procedures are defined in vvc_methods_pkg.vhd (dedicated to this VVC).
* See :ref:`vvc_framework_methods` for procedures which are common to all VVCs.
* It is also possible to send a multicast to all instances of a VVC with ALL_INSTANCES as parameter for vvc_instance_idx.
* All parameters in brackets are optional.
* For clarity, data_array is required to be ascending, e.g. ::

    variable v_data_array : t_slv_array(0 to C_MAX_BYTES - 1)(7 downto 0);


.. _axistream_transmit_vvc:

axistream_transmit()
----------------------------------------------------------------------------------------------------------------------------------
Adds a transmit command to the AXI4-Stream VVC executor queue, which will run as soon as all preceding commands have completed. 
When the command is scheduled to run, the executor calls the BFM :ref:`axistream_transmit_bfm` procedure. 
The axistream_transmit() procedure can only be called when the AXI4-Stream VVC is instantiated in master mode, i.e. setting the 
generic constant 'GC_VVC_IS_MASTER' to true.

.. code-block::

    axistream_transmit(VVCT, vvc_instance_idx, data_array, [user_array, [strb_array, id_array, dest_array]], msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_array         | in     | t_slv_array or               | An array of SLVs or a single std_logic_vector containing|
|          |                    |        | std_logic_vector             | the data to be sent                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | user_array         | in     | `t_user_array`_              | Side-band data to be sent via the TUSER signal.         |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of entries in user_array equals the number   |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | For example, if 16 bytes shall be sent, and there are   |
|          |                    |        |                              | 8 bytes transmitted per transfer, the user_array has    |
|          |                    |        |                              | 2 entries.                                              |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each user_array     |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tuser.   |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tuser is wider than 32, increase  |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TUSER_BITS in adaptations_pkg.      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | strb_array         | in     | `t_strb_array`_              | Side-band data to be sent via the TSTRB signal. The     |
|          |                    |        |                              | BFM transmits the values without affecting TDATA.       |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of entries in strb_array equals the number   |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each strb_array     |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tstrb.   |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tstrb is wider than 32, increase  |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TSTRB_BITS in adaptations_pkg.      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | id_array           | in     | `t_id_array`_                | Side-band data to be sent via the TID signal.           |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of entries in id_array equals the number     |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each id_array       |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tid.     |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tid is wider than 8, increase     |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TID_BITS in adaptations_pkg.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dest_array         | in     | `t_dest_array`_              | Side-band data to be sent via the TDEST signal.         |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of entries in dest_array equals the number   |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each dest_array     |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tdest.   |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tdest is wider than 4, increase   |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TDEST_BITS in adaptations_pkg.      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    axistream_transmit(AXISTREAM_VVCT, 0, (x"D0", x"D1", x"D2", x"D3"), (x"00", x"0A"), "Send a 4 byte packet with tuser=A at the 2nd (last) word");               -- tdata'length = 16
    axistream_transmit(AXISTREAM_VVCT, 0, (x"D0", x"D1", x"D2", x"D3"), (x"00", x"00", x"00", x"0A"), "Send a 4 byte packet with tuser=A at the 4th (last) word"); -- tdata'length = 8
    axistream_transmit(AXISTREAM_VVCT, 0, v_data_array(0 to 1), "Send a 2 byte packet to DUT, tuser=0 each word / clock cycle", C_SCOPE);
    axistream_transmit(AXISTREAM_VVCT, 0, v_data_array(0 to 1)(15 downto 0), "Send a 4 byte packet to DUT, tuser=0 each word / clock cycle", C_SCOPE);
    axistream_transmit(AXISTREAM_VVCT, 0, v_data_array(0 to v_numBytes-1), v_user_array(0 to v_numWords-1), "Send a v_numBytes byte packet to DUT", C_SCOPE);
    axistream_transmit(AXISTREAM_VVCT, 0, v_data_array(0 to v_numBytes-1), v_user_array(0 to v_numWords-1), 
                       v_strb_array(0 to v_numWords-1), v_id_array(0 to  v_numWords-1), v_id_array(0 to v_numWords-1), 
                       "Send a v_numBytes byte packet to DUT with tuser, tstrb, tid and tdest", C_SCOPE);


.. _axistream_receive_vvc:

axistream_receive()
----------------------------------------------------------------------------------------------------------------------------------
Adds a receive command to the AXI4-Stream VVC executor queue, which will run as soon as all preceding commands have completed. 
When the command is scheduled to run, the executor calls the :ref:`axistream_receive_bfm` procedure. The axistream_receive() 
procedure can only be called when the AXI4-Stream VVC is instantiated in slave mode, i.e. setting the generic constant 
'GC_VVC_IS_MASTER' to false.

The value received from the DUT will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but 
the received data and metadata will be stored in the VVC for a potential future fetch (see example with fetch_result below). 

.. code-block::

    axistream_receive(VVCT, vvc_instance_idx, msg, [scope])

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
    axistream_receive(AXISTREAM_VVCT, 0, "Receiving data from source", C_SCOPE);

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last receive
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from receive (data and metadata)
    ...
    axistream_receive(AXISTREAM_VVCT, 0, "Receive data in VVC");
    v_cmd_idx := get_last_received_cmd_idx(AXISTREAM_VVCT, 0);               
    await_completion(AXISTREAM_VVCT, 0, v_cmd_idx, 1 ms, "Wait for receive to finish");
    fetch_result(AXISTREAM_VVCT, 0, v_cmd_idx, v_result, "Fetching result from receive operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.


.. _axistream_expect_vvc:

axistream_expect()
----------------------------------------------------------------------------------------------------------------------------------
Adds an expect command to the AXI4-Stream VVC executor queue, which will run as soon as all preceding commands have completed. 
When the command is scheduled to run, the executor calls the :ref:`axistream_expect_bfm` procedure. 
The axistream_expect() procedure can only be called when the AXI4-Stream VVC is instantiated in slave mode, i.e. setting the 
generic constant 'GC_VVC_IS_MASTER' to false.

.. code-block::

    axistream_expect(VVCT, vvc_instance_idx, data_array, [user_array, [strb_array, id_array, dest_array]], msg, [alert_level, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_array         | in     | t_slv_array or               | An array of SLVs or a single std_logic_vector containing|
|          |                    |        | std_logic_vector             | the expected data to be received                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | user_array         | in     | `t_user_array`_              | Expected side-band data via the TUSER signal.           |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of entries in user_array equals the number   |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | For example, if 16 bytes shall be sent, and there are   |
|          |                    |        |                              | 8 bytes transmitted per transfer, the user_array has    |
|          |                    |        |                              | 2 entries.                                              |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each user_array     |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tuser.   |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tuser is wider than 32, increase  |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TUSER_BITS in adaptations_pkg.      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | strb_array         | in     | `t_strb_array`_              | Expected side-band data via the TSTRB signal. The BFM   |
|          |                    |        |                              | transmits the values without affecting TDATA.           |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of entries in strb_array equals the number   |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each strb_array     |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tstrb.   |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tstrb is wider than 32, increase  |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TSTRB_BITS in adaptations_pkg.      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | id_array           | in     | `t_id_array`_                | Expected side-band data via the TID signal.             |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of entries in id_array equals the number     |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each id_array       |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tid.     |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tid is wider than 8, increase     |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TID_BITS in adaptations_pkg.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dest_array         | in     | `t_dest_array`_              | Expected side-band data via the TDEST signal.           |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of entries in dest_array equals the number   |
|          |                    |        |                              | of data words, i.e. transfers.                          |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | The number of bits actually used in each dest_array     |
|          |                    |        |                              | entry corresponds to the width of axistream_if.tdest.   |
|          |                    |        |                              |                                                         |
|          |                    |        |                              | Note: If axistream_if.tdest is wider than 4, increase   |
|          |                    |        |                              | the value of the constant                               |
|          |                    |        |                              | C_AXISTREAM_BFM_MAX_TDEST_BITS in adaptations_pkg.      |
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
    axistream_expect(AXISTREAM_VVCT, 0, (x"D0", x"D1", x"D2", x"D3"), (x"00", x"0A"), "Expect a 4 byte packet with tuser=A at the 2nd (last) word", ERROR);               -- tdata'length = 16
    axistream_expect(AXISTREAM_VVCT, 0, (x"D0", x"D1", x"D2", x"D3"), (x"00", x"00", x"00", x"0A"), "Expect a 4 byte packet with tuser=A at the 4th (last) word", ERROR); -- tdata'length = 8
    axistream_expect(AXISTREAM_VVCT, 0, v_exp_data_array(0 to 1), "Expect a 2 byte packet, ignoring the tuser bits", ERROR, C_SCOPE);
    axistream_expect(AXISTREAM_VVCT, 0, v_exp_data_array(0 to 1)(15 downto 0), "Expect a 4 byte packet, ignoring the tuser bits", ERROR, C_SCOPE);
    axistream_expect(AXISTREAM_VVCT, 0, v_exp_data_array(0 to v_numBytes-1), v_user_array(0 to v_numWords-1), "Expect a packet, checking the tuser bits", ERROR, C_SCOPE);
    axistream_expect(AXISTREAM_VVCT, 0, v_exp_data_array(0 to v_numBytes-1), v_user_array(0 to v_numWords-1), 
                     v_strb_array(0 to v_numWords-1), v_id_array(0 to v_numWords-1),v_id_array(0 to v_numWords-1), 
                     "Check all signals", ERROR, C_SCOPE);


Activity Watchdog
==================================================================================================================================
.. include:: rst_snippets/vip_activity_watchdog.rst


Transaction Info
==================================================================================================================================
.. include:: rst_snippets/vip_transaction_info.rst

.. table:: AXI4-Stream transaction info record fields. Transaction Type: t_base_transaction (BT) - accessible via **shared_axistream_vvc_transaction_info.bt**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | data_array                   | t_slv_array(0 to 16*1024)(7  | 0x0             | An array of SLVs containing the data to be sent |
    |                              | downto 0)                    |                 | /received                                       |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | data_length                  | integer                      | 0               | The number of valid bytes in data_array         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | user_array                   | :ref:`t_user_array(0 to 16*1\| 0x0             | Side-band data to send or which has been        |
    |                              | 024) <t_user_array>`         |                 | received via the TUSER signal.                  |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | strb_array                   | :ref:`t_strb_array(0 to 16*1\| 0x0             | Side-band data to send or which has been        |
    |                              | 024) <t_strb_array>`         |                 | received via the TSTRB signal.                  |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | id_array                     | :ref:`t_id_array(0 to 16*102\| 0x0             | Side-band data to send or which has been        |
    |                              | 4) <t_id_array>`             |                 | received via the TID signal.                    |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | dest_array                   | :ref:`t_dest_array(0 to 16*1\| 0x0             | Side-band data to send or which has been        |
    |                              | 024) <t_dest_array>`         |                 | received via the TDEST signal.                  |
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

    shared_axistream_vvc_config(C_VVC_INDEX).unwanted_activity_severity := NO_ALERT;

Note that the tready signal is not monitored in this VVC. The tready signal is allowed to be set independently of the tvalid signal, 
and there is no method to differentiate between the unwanted activity and intended activity. See the AXI4-Stream protocol specification 
for more information. 

The unwanted activity detection is ignored when the tvalid signal goes low within one clock period after the VVC becomes inactive. 
This is to handle the situation when the read command exits before the next rising edge, causing signal transitions during the 
first clock cycle after the VVC is inactive. 

For AXI4-Stream VVC, the unwanted activity detection is enabled by default with severity ERROR.

More information can be found in :ref:`Essential Mechanisms - Unwanted Activity Detection <vvc_framework_unwanted_activity>`.


Compilation
==================================================================================================================================
The AXI4-Stream VVC must be compiled with VHDL-2008 or newer. It is dependent on the following libraries:

    * UVVM Utility Library (UVVM-Util)
    * UVVM VVC Framework
    * AXI4-Stream BFM

Before compiling the AXI4-Stream VVC, assure that uvvm_util and uvvm_vvc_framework have been compiled.

See :ref:`Essential Mechanisms - Compile Scripts <vvc_framework_compile_scripts>` for information about compile scripts.

.. table:: Compile order for the AXI4-Stream VVC

    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | Compile to library           | File                                           | Comment                                         |
    +==============================+================================================+=================================================+
    | bitvis_vip_axistream         | axistream_bfm_pkg.vhd                          | AXI4-Stream BFM                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axistream         | transaction_pkg.vhd                            | AXI4-Stream transaction package with DTT types, |
    |                              |                                                | constants, etc.                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axistream         | vvc_cmd_pkg.vhd                                | AXI4-Stream VVC command types and operations    |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axistream         | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC target support package, compiled into  |
    |                              | _target_support_pkg.vhd                        | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axistream         | ../uvvm_vvc_framework/src_target_dependent/td\ | Common UVVM framework methods compiled into the |
    |                              | _vvc_framework_common_methods_pkg.vhd          | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axistream         | vvc_methods_pkg.vhd                            | AXI4-Stream VVC methods                         |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axistream         | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM queue package for this VVC                 |
    |                              | _queue_pkg.vhd                                 |                                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axistream         | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC entity support compiled into this      |
    |                              | _vvc_entity_support_pkg.vhd                    | VVC library                                     |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axistream         | axistream_vvc.vhd                              | AXI4-Stream VVC                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axistream         | vvc_context.vhd                                | AXI4-Stream VVC context file                    |
    +------------------------------+------------------------------------------------+-------------------------------------------------+

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


Additional Documentation
==================================================================================================================================
For more information on the AXI4-Stream specification, refer to "AMBA® 4 AXI4-Stream Protocol Specification" (ARM IHI 0051A), 
available from ARM.

.. important::

    * This is a simplified Verification IP (VIP) for AXI4-Stream.
    * The given VIP complies with the basic AXI4-Stream protocol and thus allows a normal access towards an AXI4-Stream interface.
    * This VIP is not an AXI4-Stream protocol checker.
    * For a more advanced VIP please contact UVVM support at info@uvvm.org

.. include:: rst_snippets/ip_disclaimer.rst
