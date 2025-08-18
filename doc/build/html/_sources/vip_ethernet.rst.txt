##################################################################################################################################
Bitvis VIP Ethernet
##################################################################################################################################

**Quick Access**

* `HVVC`_

  * :ref:`ethernet_transmit`
  * :ref:`ethernet_receive`
  * :ref:`ethernet_expect`


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
HVVC
**********************************************************************************************************************************
* This Ethernet Hierarchical-VVC is based on IEEE 802.3.
* It does not support optional fields or EtherType, only length is supported.
* HVVCs are different than normal VVCs since they represent a higher protocol level than the physical layer, i.e. they have no 
  physical connections. However due to similarities in the core code, the VVC term is used instead.
* HVVC functionality is implemented in ethernet_vvc.vhd
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
| GC_PHY_INTERFACE             | :ref:`t_interface            | N/A             | Physical VVC interface type, e.g. SBI, GMII.    |
|                              | <adaptations_pkg>`           |                 | (see note below)                                |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_PHY_VVC_INSTANCE_IDX      | natural                      | N/A             | Instance number of the physical VVC             |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_PHY_MAX_ACCESS_TIME       | time                         | 1 us            | Maximum time that the physical VVC takes to     |
|                              |                              |                 | execute an access, e.g. GMII write 1 byte. It   |
|                              |                              |                 | should also account for any margin it needs.    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_DUT_IF_FIELD_CONFIG       | :ref:`t_dut_if_field_config_\| C_DUT_IF_FIELD\ | Array of configurations for address based VVC   |
|                              | direction_array`             | _CONFIG_DIRECTI\| interfaces                                      |
|                              |                              | ON_ARRAY_DEFAULT|                                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_ETHERNET_PROTOCOL_CONFIG  | :ref:`t_ethernet_protocol_co\| C_ETHERNET_PROT\| Configuration of the Ethernet protocol          |
|                              | nfig`                        | OCOL_CONFIG_DEF\|                                                 |
|                              |                              | AULT            |                                                 |
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

    You can use any of the physical interfaces already implemented just by using the appropriate name in GC_PHY_INTERFACE and 
    instantiating the corresponding VVC in the testbench (in addition to the HVVC). For more information see 
    :ref:`VVC Framework - Essential Mechanisms <vvc_framework_essential_mechanisms>`.
    If you however want to use an interface type which is not already included, see :ref:`vip_hvvc_to_vvc_bridge` for more info.

Signals
----------------------------------------------------------------------------------------------------------------------------------
Since HVVCs represent a higher protocol level than the physical layer, they have no physical connections. The actual signals 
controlled by the HVVC are those from the physical interface defined by GC_PHY_INTERFACE and GC_PHY_VVC_INSTANCE_IDX.

Configuration Record
==================================================================================================================================
**vvc_config** accessible via **shared_ethernet_vvc_config**

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| inter_bfm_delay              | :ref:`t_inter_bfm_delay`     | C_ETHERNET_INTE\| Delay between any requested BFM accesses        |
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
| bfm_config                   | :ref:`t_ethernet_protocol_co\| C_ETHERNET_PROT\| Not strictly a bus functional model (BFM) but   |
|                              | nfig`                        | OCOL_CONFIG_DEF\| holds BFM-like configuration data for the       |
|                              |                              | AULT            | Ethernet protocol                               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| msg_id_panel                 | t_msg_id_panel               | C_ETHERNET_VVC\ | VVC dedicated message ID panel. See             |
|                              |                              | _MSG_ID_PANEL_D\| :ref:`vvc_framework_verbosity_ctrl` for how to  |
|                              |                              | EFAULT          | use verbosity control.                          |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

.. note::

    cmd/result queue parameters in the configuration record are unused and will be removed in v3.0, use instead the entity generic constants.

The configuration record can be accessed from the Central Testbench Sequencer through the shared variable array, e.g. ::

    shared_ethernet_vvc_config(RX, C_VVC_IDX).inter_bfm_delay.delay_in_time := 50 ns;
    shared_ethernet_vvc_config(TX, C_VVC_IDX).bfm_config.interpacket_gap_time := 96 ns;

Status Record
==================================================================================================================================
**vvc_status** accessible via **shared_ethernet_vvc_status**

.. include:: rst_snippets/vip_vvc_status.rst

Methods
==================================================================================================================================
* All VVC procedures are defined in vvc_methods_pkg.vhd (dedicated to this VVC).
* See :ref:`vvc_framework_methods` for procedures which are common to all VVCs.
* It is also possible to send a multicast to all instances of a VVC with ALL_INSTANCES as parameter for vvc_instance_idx.
* All parameters in brackets are optional.


.. _ethernet_transmit:

ethernet_transmit()
----------------------------------------------------------------------------------------------------------------------------------
Adds a transmit command to the Ethernet VVC executor queue, which will runs as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the priv_ethernet_transmit_to_bridge() procedure. This procedure builds an 
Ethernet packet and transmits each field using the HVVC-to-VVC bridge which then transfers the data to the lower level VVC 
(physical interface). After it has finished, it waits for the configured interpacket gap time.

.. code-block::

    ethernet_transmit(VVCT, vvc_instance_idx, channel, [mac_destination], [mac_source], payload, msg, [scope])

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
| constant | mac_destination    | in     | unsigned(47 downto 0)        | The MAC address of destination                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | mac_source         | in     | unsigned(47 downto 0)        | The MAC address of source                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | payload            | in     | t_byte_array                 | The payload of the packet                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    ethernet_transmit(ETHERNET_VVCT, 0, TX, v_mac_dest, v_mac_src, v_payload, "Transmit an ethernet packet", C_SCOPE);
    ethernet_transmit(ETHERNET_VVCT, 0, TX, v_payload, "Transmit an ethernet packet using default MAC addresses");


.. _ethernet_receive:

ethernet_receive()
----------------------------------------------------------------------------------------------------------------------------------
Adds a receive command to the Ethernet VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the priv_ethernet_receive_from_bridge() procedure. This procedure receives an 
Ethernet packet by requesting each field from the HVVC-to-VVC bridge which calls the lower level VVC (physical interface) to read 
the data. When the complete packet is received, it computes the FCS and checks that it corresponds to the one received in the 
packet.

The received data from the DUT is not to be returned in this procedure call since it is non-blocking for the sequencer/caller, but 
it will be stored in the VVC for a potential future fetch (see example with fetch_result below). 
If the data_routing is set to TO_SB, the read data will be sent to the Ethernet VVC dedicated scoreboard where it will be 
checked against the expected value (provided by the testbench).

.. code-block::

    ethernet_receive(VVCT, vvc_instance_idx, channel, [data_routing], msg, [scope])

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
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    ethernet_receive(ETHERNET_VVCT, 0, RX, "Receive an ethernet packet and store it in the VVC", C_SCOPE);
    ethernet_receive(ETHERNET_VVCT, 0, RX, TO_SB, "Receive an ethernet packet and send to Scoreboard for checking");

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last receive
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from receive.
    ...
    ethernet_receive(ETHERNET_VVCT, 0, RX, "Receive ethernet packet");
    v_cmd_idx := get_last_received_cmd_idx(ETHERNET_VVCT, 0, RX);               
    await_completion(ETHERNET_VVCT, 0, RX, v_cmd_idx, 1 us, "Wait for receive to finish");
    fetch_result(ETHERNET_VVCT, 0, RX, v_cmd_idx, v_result, "Fetching result from receive operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.


.. _ethernet_expect:

ethernet_expect()
----------------------------------------------------------------------------------------------------------------------------------
Adds an expect command to the Ethernet VVC executor queue, which will run as soon as all preceding commands have completed. When 
the command is scheduled to run, the executor calls the priv_ethernet_expect_from_bridge() procedure. This procedure performs a 
receive operation, then checks if the received data is equal to the expected data. The received data is not stored in this 
procedure.

.. code-block::

    ethernet_expect(VVCT, vvc_instance_idx, channel, [mac_destination], [mac_source], payload, msg, [alert_level, [scope]])

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
| constant | mac_destination    | in     | unsigned(47 downto 0)        | The MAC address of destination                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | mac_source         | in     | unsigned(47 downto 0)        | The MAC address of source                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | payload            | in     | t_byte_array                 | The payload of the packet                               |
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
    ethernet_expect(ETHERNET_VVCT, 0, RX, v_mac_dest, v_mac_src, v_payload, "Expect an ethernet packet", ERROR, C_SCOPE);


Activity Watchdog
==================================================================================================================================
.. include:: rst_snippets/vip_activity_watchdog.rst


Transaction Info
==================================================================================================================================
.. include:: rst_snippets/vip_transaction_info.rst

.. table:: Ethernet transaction info record fields. Transaction Type: t_base_transaction (BT) - accessible via **shared_ethernet_vvc_transaction_info.bt**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | ethernet_frame               | :ref:`t_ethernet_frame`      | C_ETHERNET_FRAM\| Ethernet frame                                  |
    |                              |                              | E_DEFAULT       |                                                 |
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
i.e. ethernet_receive(). Note that the data is only stored in the scoreboard and not accessible with the fetch_result() method 
when the TO_SB parameter is applied. The Ethernet scoreboard is accessible from the testbench as a shared variable ETHERNET_VVC_SB, 
located in the vvc_methods_pkg.vhd, e.g. ::

    ETHERNET_VVC_SB.add_expected(C_ETH_GMII_VVC_IDX, v_expected_frame, "Adding expected");

See the :ref:`vip_scoreboard` for a complete list of available commands and additional information. All of the listed Generic
Scoreboard commands are available for the Ethernet VVC scoreboard using the ETHERNET_VVC_SB.


Unwanted Activity Detection
==================================================================================================================================
Since HVVCs do not contain any physical ports, the unwanted activity detection is found in the physical layer VVC connected to the 
HVVC, e.g. GMII/RGMII/SBI. Thus, when the data is not expected from the DUT, i.e. Ethernet VVC receive/expect methods are not 
called, an alert of severity will be generated from the physical layer VVCs.

The unwanted activity detection can be configured from the central testbench sequencer, where the severity of alert can be changed 
to a different value. To disable this feature in the testbench, e.g. for GMII VVC::

    shared_gmii_vvc_config(RX, C_VVC_INDEX).unwanted_activity_severity := NO_ALERT;

Note that the unwanted activity detection is enabled (unwanted_activity_severity := ERROR) by default for the GMII/RGMII/SBI VVCs.

More information can be found in :ref:`Essential Mechanisms - Unwanted Activity Detection <vvc_framework_unwanted_activity>`.


Support package
==================================================================================================================================
Contains constants and types for the Ethernet protocol, defined in support_pkg.vhd

The table below shows which index in the DUT IF field configuration array (:ref:`t_dut_if_field_config_direction_array`) the 
Ethernet fields are associated with. These configurations are only necessary when the lower level VVC is address-based, e.g. SBI. 
The DUT IF field configuration array is a two-dimensional array (direction and index). If the same configuration is used for all 
fields, only one configuration per direction is needed. The highest indexed configuration is used for indexes higher than those 
supplied. E.g. if the array consists of two configurations the first configuration, index 0, is used for the field preamble & SFD 
and the other fields use the last configuration, index 1. Each index holds an element of type :ref:`t_dut_if_field_config`, 
see table below. 

+----------------------+-------------------------------+-------+
| Ethernet field       | Name                          | Index |
+======================+===============================+=======+
| Preamble & SFD       | C_FIELD_IDX_PREAMBLE_AND_SFD  | 0     |
+----------------------+-------------------------------+-------+
| MAC destination      | C_FIELD_IDX_MAC_DESTINATION   | 1     |
+----------------------+-------------------------------+-------+
| MAC source           | C_FIELD_IDX_MAC_SOURCE        | 2     |
+----------------------+-------------------------------+-------+
| Payload length       | C_FIELD_IDX_PAYLOAD_LENGTH    | 3     |
+----------------------+-------------------------------+-------+
| Payload              | C_FIELD_IDX_PAYLOAD           | 4     |
+----------------------+-------------------------------+-------+
| FCS                  | C_FIELD_IDX_FCS               | 5     |
+----------------------+-------------------------------+-------+

.. _t_ethernet_protocol_config:

t_ethernet_protocol_config
----------------------------------------------------------------------------------------------------------------------------------
+------------------------------------+-------------------------+
| Record element                     | Type                    |
+====================================+=========================+
| mac_destination                    | unsigned(47 downto 0)   |
+------------------------------------+-------------------------+
| mac_source                         | unsigned(47 downto 0)   |
+------------------------------------+-------------------------+
| fcs_error_severity                 | :ref:`t_alert_level`    |
+------------------------------------+-------------------------+
| interpacket_gap_time               | time                    |
+------------------------------------+-------------------------+

.. note::

    * Interpacket gap is implemented as a wait statement after the ethernet packet has been transmitted.
    * Check of interpacket gap on receive is not implemented.
    * If the physical VVC has a timeout, e.g. max_wait_cycles, it must be big enough to handle the interpacket gap and any other 
      delays in the transmission.


.. _t_ethernet_frame:

t_ethernet_frame
----------------------------------------------------------------------------------------------------------------------------------
+------------------------------------+-------------------------------+
| Record element                     | Type                          |
+====================================+===============================+
| mac_destination                    | unsigned(47 downto 0)         |
+------------------------------------+-------------------------------+
| mac_source                         | unsigned(47 downto 0)         |
+------------------------------------+-------------------------------+
| payload_length                     | integer                       |
+------------------------------------+-------------------------------+
| payload                            | t_byte_array(0 to 1499)       |
+------------------------------------+-------------------------------+
| fcs                                | std_logic_vector(31 downto 0) |
+------------------------------------+-------------------------------+


Compilation
==================================================================================================================================
The Ethernet VVC must be compiled with VHDL-2008 or newer. It is dependent on the following libraries:

    * UVVM Utility Library (UVVM-Util)
    * UVVM VVC Framework
    * Bitvis VIP Scoreboard
    * Library of the physical interface used (e.g. Bitvis VIP GMII)
    * HVVC-to-VVC Bridge

Before compiling the Ethernet VVC, assure that uvvm_util, uvvm_vvc_framework and bitvis_vip_scoreboard have been compiled.

See :ref:`Essential Mechanisms - Compile Scripts <vvc_framework_compile_scripts>` for information about compile scripts.

.. table:: Compile order for the Ethernet VVC

    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | Compile to library           | File                                           | Comment                                         |
    +==============================+================================================+=================================================+
    | bitvis_vip_ethernet          | support_pkg.vhd                                | Ethernet support package                        |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_ethernet          | transaction_pkg.vhd                            | Ethernet transaction package with DTT types,    |
    |                              |                                                | constants, etc.                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_ethernet          | vvc_cmd_pkg.vhd                                | Ethernet VVC command types and operations       |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_ethernet          | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC target support package, compiled into  |
    |                              | _target_support_pkg.vhd                        | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_ethernet          | ../uvvm_vvc_framework/src_target_dependent/td\ | Common UVVM framework methods compiled into the |
    |                              | _vvc_framework_common_methods_pkg.vhd          | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_ethernet          | vvc_sb_pkg.vhd                                 | Ethernet VVC scoreboard                         |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_ethernet          | vvc_methods_pkg.vhd                            | Ethernet VVC methods                            |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_ethernet          | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM queue package for this VVC                 |
    |                              | _queue_pkg.vhd                                 |                                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_ethernet          | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC entity support compiled into this      |
    |                              | _vvc_entity_support_pkg.vhd                    | VVC library                                     |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_ethernet          | ethernet_rx_vvc.vhd                            | Ethernet RX VVC                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_ethernet          | ethernet_tx_vvc.vhd                            | Ethernet TX VVC                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_ethernet          | ethernet_vvc.vhd                               | Ethernet VVC wrapper for the RX and TX VVCs     |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_ethernet          | vvc_context.vhd                                | Ethernet VVC context file                       |
    +------------------------------+------------------------------------------------+-------------------------------------------------+

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


Additional Documentation
==================================================================================================================================
.. important::

    * This is a simplified Verification IP (VIP) for Ethernet.
    * This Ethernet VVC is based on IEEE 802.3
    * It does not support optional fields or EtherType, only length is supported.
    * This VIP is not an Ethernet protocol checker.
    * For a more advanced VIP please contact UVVM support at info@uvvm.org

.. include:: rst_snippets/ip_disclaimer.rst
