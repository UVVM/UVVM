##################################################################################################################################
P2L2 VIP MDIO
##################################################################################################################################

**Quick Access**

* `BFM`_

  * :ref:`mdio_sta_c22_write_bfm`
  * :ref:`mdio_sta_c22_read_bfm`
  * :ref:`mdio_sta_c22_check_bfm`
  * :ref:`mdio_sta_c45_address_bfm`
  * :ref:`mdio_sta_c45_write_bfm`
  * :ref:`mdio_sta_c45_read_bfm`
  * :ref:`mdio_sta_c45_post_read_increment_bfm`
  * :ref:`mdio_sta_c45_check_bfm`
  * :ref:`mdio_sta_c45_check_post_read_increment_bfm`
  * :ref:`mdio_phy_c22_expect_write_bfm`
  * :ref:`mdio_phy_c22_receive_write_bfm`
  * :ref:`mdio_phy_c22_reply_read_bfm`
  * :ref:`mdio_phy_c45_expect_address_bfm`
  * :ref:`mdio_phy_c45_receive_address_bfm`
  * :ref:`mdio_phy_c45_expect_write_bfm`
  * :ref:`mdio_phy_c45_receive_write_bfm`
  * :ref:`mdio_phy_c45_reply_read_bfm`
  * :ref:`mdio_phy_c45_reply_post_read_increment_bfm`
  * :ref:`init_mdio_if_signals_bfm`
  * :ref:`mdio_check_bit_timing_bfm`

* `VVC`_

  * :ref:`mdio_sta_c22_write_vvc`
  * :ref:`mdio_sta_c22_read_vvc`
  * :ref:`mdio_sta_c22_check_vvc`
  * :ref:`mdio_sta_c45_address_vvc`
  * :ref:`mdio_sta_c45_write_vvc`
  * :ref:`mdio_sta_c45_read_vvc`
  * :ref:`mdio_sta_c45_post_read_increment_vvc`
  * :ref:`mdio_sta_c45_check_vvc`
  * :ref:`mdio_sta_c45_check_post_read_increment_vvc`
  * :ref:`mdio_sta_c45_write_reg_vvc`
  * :ref:`mdio_sta_c45_read_reg_vvc`
  * :ref:`mdio_sta_c45_check_reg_vvc`
  * :ref:`mdio_phy_c22_expect_write_vvc`
  * :ref:`mdio_phy_c22_receive_write_vvc`
  * :ref:`mdio_phy_c22_reply_read_vvc`
  * :ref:`mdio_phy_c45_expect_address_vvc`
  * :ref:`mdio_phy_c45_receive_address_vvc`
  * :ref:`mdio_phy_c45_expect_write_vvc`
  * :ref:`mdio_phy_c45_receive_write_vvc`
  * :ref:`mdio_phy_c45_reply_read_vvc`
  * :ref:`mdio_phy_c45_reply_post_read_increment_vvc`


**********************************************************************************************************************************
BFM
**********************************************************************************************************************************
BFM functionality is implemented in mdio_bfm_pkg.vhd

The BFM implements the MDIO management interface of IEEE 802.3, clause 22 and clause 45. It acts either as the station
management entity (STA, the bus master that drives MDC) with the ``mdio_sta_*`` procedures, or as the PHY (the addressed
target) with the ``mdio_phy_*`` procedures. See :ref:`mdio_abbreviations` for the abbreviations used in this document.

.. _t_mdio_if:

Signal Record
==================================================================================================================================
**t_mdio_if**

+-------------------------+------------------------------+--------------------------------------------------+
| Record element          | Type                         | Description                                      |
+=========================+==============================+==================================================+
| mdc                     | std_logic                    | Management data clock, driven by the STA.        |
+-------------------------+------------------------------+--------------------------------------------------+
| mdio                    | std_logic                    | Management data input/output. Tri-state bus,     |
|                         |                              | driven by the STA and by the PHY.                |
+-------------------------+------------------------------+--------------------------------------------------+

.. note::

    MDIO needs a pull-up. When only the BFM is used, add a weak pull-up in the test harness, e.g. ``mdio <= 'H';``. The VVC
    can drive the pull-up itself with the entity generic GC_MDIO_PULLUP set to true, see :ref:`mdio_vvc_signals`.

.. _t_mdio_bfm_config:

Configuration Record
==================================================================================================================================
**t_mdio_bfm_config**

Default value for the record is C_MDIO_BFM_CONFIG_DEFAULT.

+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| Record element               | Type                           | Default                         | Description                                   |
+==============================+================================+=================================+===============================================+
| min_setup_time               | time                           | 10 ns                           | Minimum time MDIO must be stable before a     |
|                              |                                |                                 | rising MDC edge                               |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| min_hold_time                | time                           | 10 ns                           | Minimum time MDIO must be stable after a      |
|                              |                                |                                 | rising MDC edge                               |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| min_mdc_period               | time                           | 400 ns                          | Minimum time between two rising and between   |
|                              |                                |                                 | two falling MDC edges                         |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| min_mdc_high_time            | time                           | 160 ns                          | Minimum MDC high time                         |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| min_mdc_low_time             | time                           | 160 ns                          | Minimum MDC low time                          |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| output_delay                 | time                           | 150 ns                          | Time from a rising MDC edge until MDIO is     |
|                              |                                |                                 | driven, in both roles. IEEE 802.3 22.3.4      |
|                              |                                |                                 | allows 0 ns to 300 ns for a PHY.              |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| id_for_bfm                   | :ref:`t_msg_id <message_ids>`  | ID_BFM                          | Message ID used for logging general messages  |
|                              |                                |                                 | in the BFM                                    |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| id_for_bfm_wait              | :ref:`t_msg_id <message_ids>`  | ID_BFM_WAIT                     | Message ID used for logging waits in the BFM  |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| suppress_preamble            | boolean                        | false                           | True: the STA sends no preamble and the PHY   |
|                              |                                |                                 | procedures expect none.                       |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| sync_to_frame_start          | boolean                        | true                            | True: a PHY call waits for the next frame     |
|                              |                                |                                 | start, also if started during other bus       |
|                              |                                |                                 | activity. False: the first frame must start   |
|                              |                                |                                 | at the next rising MDC edge.                  |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| protocol_error_severity      | :ref:`t_alert_level`           | ERROR                           | Severity if a frame breaks the MDIO protocol, |
|                              |                                |                                 | e.g. wrong turnaround, undefined bits,        |
|                              |                                |                                 | preamble not driven or too short. NO_ALERT    |
|                              |                                |                                 | disables these checks.                        |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| bus_contention_severity      | :ref:`t_alert_level`           | ERROR                           | Severity if the bus does not show the value   |
|                              |                                |                                 | driven by the BFM, or is driven where it must |
|                              |                                |                                 | be released.                                  |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| timing_violation_severity    | :ref:`t_alert_level`           | ERROR                           | Severity if the configured timing of the BFM  |
|                              |                                |                                 | is out of specification. NO_ALERT allows      |
|                              |                                |                                 | out-of-spec timing on purpose.                |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| phy                          | t_mdio_phy_bfm_config          | C_MDIO_PHY_BFM_CONFIG_DEFAULT   | Configuration of the PHY role, see below      |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| sta                          | t_mdio_sta_bfm_config          | C_MDIO_STA_BFM_CONFIG_DEFAULT   | Configuration of the STA role, see below      |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+

**t_mdio_phy_bfm_config** (default C_MDIO_PHY_BFM_CONFIG_DEFAULT)

+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| Record element               | Type                           | Default                         | Description                                   |
+==============================+================================+=================================+===============================================+
| phy_address                  | unsigned(4 downto 0)           | 5x"1"                           | Address of the PHY: PHYAD (clause 22) / PRTAD |
|                              |                                |                                 | (clause 45)                                   |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| max_wait_mdc_change          | time                           | 1 ms                            | Maximum time between two rising MDC edges     |
|                              |                                |                                 | within a frame                                |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| max_wait_mdc_change_severity | :ref:`t_alert_level`           | FAILURE                         | Severity of the above timeout                 |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| timeout                      | time                           | 10 ms                           | Maximum time to wait for the addressed frame  |
|                              |                                |                                 | to start, 0 ns = no timeout. Can be           |
|                              |                                |                                 | overridden per call.                          |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+
| timeout_severity             | :ref:`t_alert_level`           | ERROR                           | Severity of the above timeout                 |
+------------------------------+--------------------------------+---------------------------------+-----------------------------------------------+

**t_mdio_sta_bfm_config** (default C_MDIO_STA_BFM_CONFIG_DEFAULT)

+--------------------------------+------------------------------+---------------------------------+---------------------------------------------+
| Record element                 | Type                         | Default                         | Description                                 |
+================================+==============================+=================================+=============================================+
| mdc_period                     | time                         | 400 ns                          | Period of the MDC generated by the STA (50  |
|                                |                              |                                 | % duty cycle)                               |
+--------------------------------+------------------------------+---------------------------------+---------------------------------------------+
| preamble_length                | natural                      | 32                              | Number of preamble bits. Other values than  |
|                                |                              |                                 | 32 are meant for negative tests.            |
+--------------------------------+------------------------------+---------------------------------+---------------------------------------------+
| idle_cycles                    | natural                      | 1                               | IDLE bits (MDC running, MDIO released)      |
|                                |                              |                                 | after every frame. 0 is meant for negative  |
|                                |                              |                                 | tests.                                      |
+--------------------------------+------------------------------+---------------------------------+---------------------------------------------+
| turnaround_not_driven_severity | :ref:`t_alert_level`         | ERROR                           | Severity if the PHY does not drive '0' in   |
|                                |                              |                                 | the second turnaround bit of a read, i.e.   |
|                                |                              |                                 | no PHY answered                             |
+--------------------------------+------------------------------+---------------------------------+---------------------------------------------+


Methods
==================================================================================================================================
* All parameters in brackets are optional.
* ``mdio_sta_*`` procedures act as the STA, ``mdio_phy_*`` procedures act as the PHY. ``c22`` / ``c45`` in the name selects
  the clause 22 / clause 45 frame format.
* 'terminate_loop' aborts a call when set to '1': the bus is released and ID_TERMINATE_CMD is logged, without an alert. In
  an MDC high phase, an STA procedure waits for the falling edge, so MDC never gets a short high pulse.

**STA procedures**

* The STA generates MDC with config.sta.mdc_period (idle low between calls) and sends config.sta.preamble_length '1' bits
  before every frame (none with config.suppress_preamble). After every frame it clocks config.sta.idle_cycles IDLE bits
  with MDIO released.
* MDIO is driven config.output_delay after the rising MDC edge.
* The target is a parameter of every call ('phy_addr', and 'dev_addr' for clause 45), as an STA talks to several PHYs and
  MMDs.
* The STA never waits for the PHY, so there is no timeout parameter.

**PHY procedures**

.. important::

    The BFM does not model registers or the clause 45 address register: the testbench decides what is expected or
    returned.

* The address of the PHY is config.phy.phy_address.
* A call waits for a frame that addresses this PHY (and MMD for clause 45): at least 32 preamble '1' bits followed by ST,
  so a call may start in the middle of other traffic (config.sync_to_frame_start). Frames to other targets are skipped,
  their turnaround is checked. A read to an address without a PHY (e.g. the STA scans the bus) is not reported.
* The 'timeout' applies until the addressed frame starts, a started frame is always completed.
* The ``*_receive_*`` procedures make the same checks as the ``*_expect_*`` procedures, but return the 16 bits the STA sent
  instead of comparing them.

.. note::

    The PHY samples MDIO at the rising MDC edge. A zero-delay RTL STA that changes MDIO in the same delta cycle as MDC is
    out of specification (0 ns hold time) and is not received correctly. The bus timing checker of the VVC reports it.



.. _mdio_sta_c22_write_bfm:

mdio_sta_c22_write()
----------------------------------------------------------------------------------------------------------------------------------
Writes 'data' to register 'reg_addr' of the PHY 'phy_addr' with a clause 22 write frame. For protocol details, see
:ref:`mdio_additional_doc`.

The procedure reports an alert if:

    * A bit driven by the STA does not show on the bus, or the bus is not released after the frame
      (config.bus_contention_severity).
    * The configured timing violates the min_* settings of the config (config.timing_violation_severity).

.. code-block::

    mdio_sta_c22_write(phy_addr, reg_addr, data, msg, mdio_if, terminate_loop, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | phy_addr           | in     | unsigned(4 downto 0)         | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45)                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | reg_addr           | in     | unsigned(4 downto 0)         | Register address (REGAD)                                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_ulogic_vector(15         | The data value to be written to the register            |
|          |                    |        | downto 0)                    |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | mdio_if            | inout  | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | '1' aborts the call and releases the bus, without an    |
|          |                    |        |                              | alert. Tie to '0' if not used.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("MDIO BFM").  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_mdio_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_mdio_bfm_config>`         | value is C_MDIO_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c22_write(5x"01", 5x"00", x"1140", "Restart autonegotiation", mdio_if, terminate_loop);
    mdio_sta_c22_write(5x"01", 5x"00", x"1140", "Restart autonegotiation", mdio_if, terminate_loop, C_SCOPE,
                       shared_msg_id_panel, C_MDIO_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    mdio_sta_c22_write(5x"01", 5x"00", x"1140", "Restart autonegotiation");

.. _mdio_sta_c22_read_bfm:

mdio_sta_c22_read()
----------------------------------------------------------------------------------------------------------------------------------
Reads register 'reg_addr' of the PHY 'phy_addr' with a clause 22 read frame and returns the data in 'data'. 'data' is set to all
'X' at the start of the call and only assigned after a complete frame.

The procedure reports an alert if:

    * A bit driven by the STA does not show on the bus, or the bus is not released after the frame
      (config.bus_contention_severity).
    * The first turnaround bit is not released, i.e. is driven by someone (config.bus_contention_severity).
    * The PHY does not drive '0' in the second turnaround bit (config.sta.turnaround_not_driven_severity), e.g. no PHY
      at that address. The data is still returned, typically all ones, so this check can be disabled to scan for PHYs.
    * The read data contains undefined bits (config.protocol_error_severity). 'H' and 'L' count as '1' and '0'.
    * The configured timing violates the min_* settings of the config, or config.sta.mdc_period is below
      300 ns + config.min_setup_time (config.timing_violation_severity).

.. code-block::

    mdio_sta_c22_read(phy_addr, reg_addr, data, msg, mdio_if, terminate_loop, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | phy_addr           | in     | unsigned(4 downto 0)         | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45)                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | reg_addr           | in     | unsigned(4 downto 0)         | Register address (REGAD)                                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | data               | out    | std_ulogic_vector(15         | The data value read from the register. All 'X' if the   |
|          |                    |        | downto 0)                    | call ended without a complete frame.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | mdio_if            | inout  | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | '1' aborts the call and releases the bus, without an    |
|          |                    |        |                              | alert. Tie to '0' if not used.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("MDIO BFM").  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_mdio_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_mdio_bfm_config>`         | value is C_MDIO_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c22_read(5x"01", 5x"01", v_data, "Read status register", mdio_if, terminate_loop);
    mdio_sta_c22_read(5x"01", 5x"01", v_data, "Read status register", mdio_if, terminate_loop, C_SCOPE,
                      shared_msg_id_panel, C_MDIO_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    mdio_sta_c22_read(5x"01", 5x"01", v_data, "Read status register");

.. _mdio_sta_c22_check_bfm:

mdio_sta_c22_check()
----------------------------------------------------------------------------------------------------------------------------------
Reads register 'reg_addr' of the PHY 'phy_addr', using the read procedure as described in :ref:`mdio_sta_c22_read_bfm`. After
receiving data, the data is compared with the expected data.

* If the check was successful, and the read data matches the expected data, a log message is written with ID 'config.id_for_bfm'.
* If the read data did not match the expected data, an alert with severity 'alert_level' will be reported.
* The data is only compared if the turnaround and the data bits were fine, otherwise that alert is reported instead of a
  misleading data mismatch.
* The procedure will report alerts for the same conditions as the :ref:`mdio_sta_c22_read_bfm` procedure.

.. code-block::

    mdio_sta_c22_check(phy_addr, reg_addr, data_exp, msg, mdio_if, terminate_loop, [alert_level, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | phy_addr           | in     | unsigned(4 downto 0)         | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45)                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | reg_addr           | in     | unsigned(4 downto 0)         | Register address (REGAD)                                |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_ulogic_vector(15         | The data value to expect when reading the register. A   |
|          |                    |        | downto 0)                    | mismatch results in an alert with severity              |
|          |                    |        |                              | 'alert_level'.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | mdio_if            | inout  | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | '1' aborts the call and releases the bus, without an    |
|          |                    |        |                              | alert. Tie to '0' if not used.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert if the read data does   |
|          |                    |        |                              | not match. Default value is ERROR.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("MDIO BFM").  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_mdio_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_mdio_bfm_config>`         | value is C_MDIO_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c22_check(5x"01", 5x"01", x"796D", "Check status register", mdio_if, terminate_loop);
    mdio_sta_c22_check(5x"01", 5x"01", x"796D", "Check status register", mdio_if, terminate_loop, ERROR, C_SCOPE,
                       shared_msg_id_panel, C_MDIO_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    mdio_sta_c22_check(5x"01", 5x"01", x"796D", "Check status register");

.. _mdio_sta_c45_address_bfm:

mdio_sta_c45_address()
----------------------------------------------------------------------------------------------------------------------------------
Sends a clause 45 address frame: sets the register address of the MMD 'dev_addr' in the PHY 'phy_addr' to 'reg_addr'. The
following write and read frames to this MMD access that register address.

The overload with the 'success' output returns false if the frame was terminated or a bus check of the frame failed: a bit driven
by the STA did not show on the bus, or the bus was not released after the frame (config.bus_contention_severity). A caller can
then skip the access frame that would follow. Alerts from the timing check of the configuration (config.timing_violation_severity)
do not set 'success' to false, and a check disabled with NO_ALERT counts as passed. The VVC uses it for the ``*_reg`` methods.

The procedure reports an alert if:

    * A bit driven by the STA does not show on the bus, or the bus is not released after the frame
      (config.bus_contention_severity).
    * The configured timing violates the min_* settings of the config (config.timing_violation_severity).

.. code-block::

    mdio_sta_c45_address(phy_addr, dev_addr, reg_addr, msg, mdio_if, terminate_loop, [scope, [msg_id_panel, [config]]])
    mdio_sta_c45_address(phy_addr, dev_addr, reg_addr, success, msg, mdio_if, terminate_loop, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | phy_addr           | in     | unsigned(4 downto 0)         | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45)                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned(4 downto 0)         | Address of the target MMD within the PHY (DEVAD)        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | reg_addr           | in     | unsigned(15 downto 0)        | Register address sent in the address frame              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | success            | out    | boolean                      | False if the frame was terminated or a bus check of the |
|          |                    |        |                              | frame failed (config.bus_contention_severity)           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | mdio_if            | inout  | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | '1' aborts the call and releases the bus, without an    |
|          |                    |        |                              | alert. Tie to '0' if not used.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("MDIO BFM").  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_mdio_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_mdio_bfm_config>`         | value is C_MDIO_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c45_address(5x"01", 5x"03", x"0000", "Select PCS control register", mdio_if, terminate_loop);
    mdio_sta_c45_address(5x"01", 5x"03", x"0000", v_success, "Select PCS control register", mdio_if, terminate_loop);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    mdio_sta_c45_address(5x"01", 5x"03", x"0000", "Select PCS control register");

.. _mdio_sta_c45_write_bfm:

mdio_sta_c45_write()
----------------------------------------------------------------------------------------------------------------------------------
Writes 'data' to the register at the current address of the MMD 'dev_addr' in the PHY 'phy_addr' with a clause 45 write frame.
The register address is set with :ref:`mdio_sta_c45_address_bfm` before.

The procedure reports an alert if:

    * A bit driven by the STA does not show on the bus, or the bus is not released after the frame
      (config.bus_contention_severity).
    * The configured timing violates the min_* settings of the config (config.timing_violation_severity).

.. code-block::

    mdio_sta_c45_write(phy_addr, dev_addr, data, msg, mdio_if, terminate_loop, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | phy_addr           | in     | unsigned(4 downto 0)         | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45)                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned(4 downto 0)         | Address of the target MMD within the PHY (DEVAD)        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_ulogic_vector(15         | The data value to be written to the register            |
|          |                    |        | downto 0)                    |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | mdio_if            | inout  | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | '1' aborts the call and releases the bus, without an    |
|          |                    |        |                              | alert. Tie to '0' if not used.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("MDIO BFM").  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_mdio_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_mdio_bfm_config>`         | value is C_MDIO_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c45_write(5x"01", 5x"03", x"2040", "Write PCS control register", mdio_if, terminate_loop);
    mdio_sta_c45_write(5x"01", 5x"03", x"2040", "Write PCS control register", mdio_if, terminate_loop, C_SCOPE,
                       shared_msg_id_panel, C_MDIO_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    mdio_sta_c45_write(5x"01", 5x"03", x"2040", "Write PCS control register");

.. _mdio_sta_c45_read_bfm:

mdio_sta_c45_read()
----------------------------------------------------------------------------------------------------------------------------------
Reads the register at the current address of the MMD 'dev_addr' in the PHY 'phy_addr' with a clause 45 read frame and returns the
data in 'data'. The register address is set with :ref:`mdio_sta_c45_address_bfm` before. 'data' is set to all 'X' at the start of
the call and only assigned after a complete frame.

The procedure reports an alert if:

    * A bit driven by the STA does not show on the bus, or the bus is not released after the frame
      (config.bus_contention_severity).
    * The first turnaround bit is not released, i.e. is driven by someone (config.bus_contention_severity).
    * The PHY does not drive '0' in the second turnaround bit (config.sta.turnaround_not_driven_severity), e.g. no PHY
      at that address. The data is still returned, typically all ones, so this check can be disabled to scan for PHYs.
    * The read data contains undefined bits (config.protocol_error_severity). 'H' and 'L' count as '1' and '0'.
    * The configured timing violates the min_* settings of the config, or config.sta.mdc_period is below
      300 ns + config.min_setup_time (config.timing_violation_severity).

.. code-block::

    mdio_sta_c45_read(phy_addr, dev_addr, data, msg, mdio_if, terminate_loop, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | phy_addr           | in     | unsigned(4 downto 0)         | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45)                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned(4 downto 0)         | Address of the target MMD within the PHY (DEVAD)        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | data               | out    | std_ulogic_vector(15         | The data value read from the register. All 'X' if the   |
|          |                    |        | downto 0)                    | call ended without a complete frame.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | mdio_if            | inout  | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | '1' aborts the call and releases the bus, without an    |
|          |                    |        |                              | alert. Tie to '0' if not used.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("MDIO BFM").  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_mdio_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_mdio_bfm_config>`         | value is C_MDIO_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c45_read(5x"01", 5x"03", v_data, "Read PCS control register", mdio_if, terminate_loop);
    mdio_sta_c45_read(5x"01", 5x"03", v_data, "Read PCS control register", mdio_if, terminate_loop, C_SCOPE,
                      shared_msg_id_panel, C_MDIO_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    mdio_sta_c45_read(5x"01", 5x"03", v_data, "Read PCS control register");

.. _mdio_sta_c45_post_read_increment_bfm:

mdio_sta_c45_post_read_increment()
----------------------------------------------------------------------------------------------------------------------------------
Reads the register at the current address of the MMD 'dev_addr' in the PHY 'phy_addr' with a clause 45
post-read-increment-address frame, which tells the MMD to increment its address after the read.

The procedure will report alerts for the same conditions as the :ref:`mdio_sta_c45_read_bfm` procedure.

.. code-block::

    mdio_sta_c45_post_read_increment(phy_addr, dev_addr, data, msg, mdio_if, terminate_loop, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | phy_addr           | in     | unsigned(4 downto 0)         | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45)                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned(4 downto 0)         | Address of the target MMD within the PHY (DEVAD)        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | data               | out    | std_ulogic_vector(15         | The data value read from the register. All 'X' if the   |
|          |                    |        | downto 0)                    | call ended without a complete frame.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | mdio_if            | inout  | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | '1' aborts the call and releases the bus, without an    |
|          |                    |        |                              | alert. Tie to '0' if not used.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("MDIO BFM").  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_mdio_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_mdio_bfm_config>`         | value is C_MDIO_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c45_post_read_increment(5x"01", 5x"03", v_data, "Read PCS register, increment", mdio_if, terminate_loop);
    mdio_sta_c45_post_read_increment(5x"01", 5x"03", v_data, "Read PCS register, increment", mdio_if, terminate_loop,
                                     C_SCOPE, shared_msg_id_panel, C_MDIO_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    mdio_sta_c45_post_read_increment(5x"01", 5x"03", v_data, "Read PCS register, increment");

.. _mdio_sta_c45_check_bfm:

mdio_sta_c45_check()
----------------------------------------------------------------------------------------------------------------------------------
Reads the register at the current address of the MMD 'dev_addr', using the read procedure as described in
:ref:`mdio_sta_c45_read_bfm`.
After receiving data, the data is compared with the expected data.

* If the check was successful, and the read data matches the expected data, a log message is written with ID 'config.id_for_bfm'.
* If the read data did not match the expected data, an alert with severity 'alert_level' will be reported.
* The data is only compared if the turnaround and the data bits were fine, otherwise that alert is reported instead of a
  misleading data mismatch.
* The procedure will report alerts for the same conditions as the :ref:`mdio_sta_c45_read_bfm` procedure.

.. code-block::

    mdio_sta_c45_check(phy_addr, dev_addr, data_exp, msg, mdio_if, terminate_loop, [alert_level, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | phy_addr           | in     | unsigned(4 downto 0)         | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45)                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned(4 downto 0)         | Address of the target MMD within the PHY (DEVAD)        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_ulogic_vector(15         | The data value to expect when reading the register. A   |
|          |                    |        | downto 0)                    | mismatch results in an alert with severity              |
|          |                    |        |                              | 'alert_level'.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | mdio_if            | inout  | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | '1' aborts the call and releases the bus, without an    |
|          |                    |        |                              | alert. Tie to '0' if not used.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert if the read data does   |
|          |                    |        |                              | not match. Default value is ERROR.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("MDIO BFM").  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_mdio_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_mdio_bfm_config>`         | value is C_MDIO_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c45_check(5x"01", 5x"03", x"2040", "Check PCS control register", mdio_if, terminate_loop);
    mdio_sta_c45_check(5x"01", 5x"03", x"2040", "Check PCS control register", mdio_if, terminate_loop, ERROR,
                       C_SCOPE, shared_msg_id_panel, C_MDIO_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    mdio_sta_c45_check(5x"01", 5x"03", x"2040", "Check PCS control register");

.. _mdio_sta_c45_check_post_read_increment_bfm:

mdio_sta_c45_check_post_read_increment()
----------------------------------------------------------------------------------------------------------------------------------
Reads the register at the current address of the MMD 'dev_addr', using the post-read-increment procedure as described in
:ref:`mdio_sta_c45_post_read_increment_bfm`. After receiving data, the data is compared with the expected data in the same way as
in :ref:`mdio_sta_c45_check_bfm`.

The procedure will report alerts for the same conditions as the :ref:`mdio_sta_c45_read_bfm` procedure.

.. code-block::

    mdio_sta_c45_check_post_read_increment(phy_addr, dev_addr, data_exp, msg, mdio_if, terminate_loop, [alert_level, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | phy_addr           | in     | unsigned(4 downto 0)         | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45)                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned(4 downto 0)         | Address of the target MMD within the PHY (DEVAD)        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_ulogic_vector(15         | The data value to expect when reading the register. A   |
|          |                    |        | downto 0)                    | mismatch results in an alert with severity              |
|          |                    |        |                              | 'alert_level'.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | mdio_if            | inout  | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | '1' aborts the call and releases the bus, without an    |
|          |                    |        |                              | alert. Tie to '0' if not used.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert if the read data does   |
|          |                    |        |                              | not match. Default value is ERROR.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("MDIO BFM").  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_mdio_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_mdio_bfm_config>`         | value is C_MDIO_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c45_check_post_read_increment(5x"01", 5x"03", x"2040", "Check PCS register, increment", mdio_if,
                                           terminate_loop);
    mdio_sta_c45_check_post_read_increment(5x"01", 5x"03", x"2040", "Check PCS register, increment", mdio_if,
                                           terminate_loop, ERROR, C_SCOPE, shared_msg_id_panel, C_MDIO_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    mdio_sta_c45_check_post_read_increment(5x"01", 5x"03", x"2040", "Check PCS register, increment");

.. _mdio_phy_c22_expect_write_bfm:

mdio_phy_c22_expect_write()
----------------------------------------------------------------------------------------------------------------------------------
Waits for a clause 22 write frame to register 'reg_addr' of this PHY (config.phy.phy_address) and compares the written data with
'data'. If the data matches, a log message is written with ID 'config.id_for_bfm'. For protocol details, see
:ref:`mdio_additional_doc`.

The procedure reports an alert if:

    * No addressed frame starts within 'timeout' (config.phy.timeout_severity).
    * MDC does not change within config.phy.max_wait_mdc_change during a frame (config.phy.max_wait_mdc_change_severity).
    * The addressed frame has the wrong opcode, register address (clause 22) or data ('alert_level').
    * ST, OP, address fields or the written data contain undefined bits, the turnaround of a write or address frame is
      not "10", or preamble bits are only pulled up and not driven by the STA (config.protocol_error_severity).

.. code-block::

    mdio_phy_c22_expect_write(reg_addr, data, msg, mdio_if, terminate_loop, [timeout, [alert_level, [scope, [msg_id_panel, [config]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | reg_addr           | in     | unsigned(4 downto 0)         | Register address (REGAD) the frame must access. A       |
|          |                    |        |                              | different address results in an alert with severity     |
|          |                    |        |                              | 'alert_level'.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_ulogic_vector(15         | The data value to expect in the write frame. A mismatch |
|          |                    |        | downto 0)                    | results in an alert with severity 'alert_level'.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | mdio_if            | in     | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | '1' aborts the call and releases the bus, without an    |
|          |                    |        |                              | alert. Tie to '0' if not used.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time to wait for the addressed frame to start.  |
|          |                    |        |                              | A started frame is always completed. Default value is   |
|          |                    |        |                              | C_UNDEFINED_TIME, which uses config.phy.timeout. 0 ns = |
|          |                    |        |                              | no timeout.                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Severity if the addressed frame is not as expected:     |
|          |                    |        |                              | wrong opcode, wrong register address or wrong written   |
|          |                    |        |                              | data. Default value is ERROR.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("MDIO BFM").  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_mdio_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_mdio_bfm_config>`         | value is C_MDIO_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_phy_c22_expect_write(5x"00", x"1140", "Expect control register write", mdio_if, terminate_loop);
    mdio_phy_c22_expect_write(5x"00", x"1140", "Expect control register write", mdio_if, terminate_loop, 1 ms, ERROR,
                              C_SCOPE, shared_msg_id_panel, C_MDIO_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    mdio_phy_c22_expect_write(5x"00", x"1140", "Expect control register write");

.. _mdio_phy_c22_receive_write_bfm:

mdio_phy_c22_receive_write()
----------------------------------------------------------------------------------------------------------------------------------
Waits for a clause 22 write frame to register 'reg_addr' of this PHY and returns the written data in 'data'. 'data' is set to all
'X' at the start of the call and only assigned once the data was received with the right opcode.

The procedure will report alerts for the same conditions as the :ref:`mdio_phy_c22_expect_write_bfm` procedure. A data mismatch is
not possible.

.. code-block::

    mdio_phy_c22_receive_write(reg_addr, data, msg, mdio_if, terminate_loop, [timeout, [alert_level, [scope, [msg_id_panel, [config]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | reg_addr           | in     | unsigned(4 downto 0)         | Register address (REGAD) the frame must access. A       |
|          |                    |        |                              | different address results in an alert with severity     |
|          |                    |        |                              | 'alert_level'.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | data               | out    | std_ulogic_vector(15         | The data value written by the STA. All 'X' if the call  |
|          |                    |        | downto 0)                    | ended without a complete frame.                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | mdio_if            | in     | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | '1' aborts the call and releases the bus, without an    |
|          |                    |        |                              | alert. Tie to '0' if not used.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time to wait for the addressed frame to start.  |
|          |                    |        |                              | A started frame is always completed. Default value is   |
|          |                    |        |                              | C_UNDEFINED_TIME, which uses config.phy.timeout. 0 ns = |
|          |                    |        |                              | no timeout.                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Severity if the addressed frame is not as expected:     |
|          |                    |        |                              | wrong opcode or wrong register address. Default value   |
|          |                    |        |                              | is ERROR.                                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("MDIO BFM").  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_mdio_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_mdio_bfm_config>`         | value is C_MDIO_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_phy_c22_receive_write(5x"00", v_data, "Receive control register write", mdio_if, terminate_loop);
    mdio_phy_c22_receive_write(5x"00", v_data, "Receive control register write", mdio_if, terminate_loop, 1 ms, ERROR,
                               C_SCOPE, shared_msg_id_panel, C_MDIO_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    mdio_phy_c22_receive_write(5x"00", v_data, "Receive control register write");

.. _mdio_phy_c22_reply_read_bfm:

mdio_phy_c22_reply_read()
----------------------------------------------------------------------------------------------------------------------------------
Waits for a clause 22 read frame of register 'reg_addr' of this PHY and returns 'data' to the STA. MDIO is driven
config.output_delay after the rising MDC edge.

The procedure reports an alert if:

    * No addressed frame starts within 'timeout' (config.phy.timeout_severity).
    * MDC does not change within config.phy.max_wait_mdc_change during a frame (config.phy.max_wait_mdc_change_severity).
    * The addressed frame has the wrong opcode or register address (clause 22) ('alert_level').
    * ST, OP or address fields contain undefined bits, or preamble bits are only pulled up and not driven by the STA
      (config.protocol_error_severity).
    * The STA does not release the first turnaround bit, or the bus does not show the bits driven by the PHY
      (config.bus_contention_severity).
    * config.output_delay is above 300 ns (config.timing_violation_severity).

.. code-block::

    mdio_phy_c22_reply_read(reg_addr, data, msg, mdio_if, terminate_loop, [timeout, [alert_level, [scope, [msg_id_panel, [config]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | reg_addr           | in     | unsigned(4 downto 0)         | Register address (REGAD) the frame must access. A       |
|          |                    |        |                              | different address results in an alert with severity     |
|          |                    |        |                              | 'alert_level'.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_ulogic_vector(15         | The data value returned to the STA                      |
|          |                    |        | downto 0)                    |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | mdio_if            | inout  | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | '1' aborts the call and releases the bus, without an    |
|          |                    |        |                              | alert. Tie to '0' if not used.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time to wait for the addressed frame to start.  |
|          |                    |        |                              | A started frame is always completed. Default value is   |
|          |                    |        |                              | C_UNDEFINED_TIME, which uses config.phy.timeout. 0 ns = |
|          |                    |        |                              | no timeout.                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Severity if the addressed frame is not as expected:     |
|          |                    |        |                              | wrong opcode or wrong register address. Default value   |
|          |                    |        |                              | is ERROR.                                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("MDIO BFM").  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_mdio_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_mdio_bfm_config>`         | value is C_MDIO_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_phy_c22_reply_read(5x"01", x"796D", "Reply status register", mdio_if, terminate_loop);
    mdio_phy_c22_reply_read(5x"01", x"796D", "Reply status register", mdio_if, terminate_loop, 1 ms, ERROR,
                            C_SCOPE, shared_msg_id_panel, C_MDIO_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    mdio_phy_c22_reply_read(5x"01", x"796D", "Reply status register");

.. _mdio_phy_c45_expect_address_bfm:

mdio_phy_c45_expect_address()
----------------------------------------------------------------------------------------------------------------------------------
Waits for a clause 45 address frame to the MMD 'dev_addr' of this PHY and compares the received register address with 'reg_addr'.
The BFM does not model the clause 45 address register: the testbench decides which register the following frames access.

The procedure will report alerts for the same conditions as the :ref:`mdio_phy_c22_expect_write_bfm` procedure.

.. code-block::

    mdio_phy_c45_expect_address(dev_addr, reg_addr, msg, mdio_if, terminate_loop, [timeout, [alert_level, [scope, [msg_id_panel, [config]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | dev_addr           | in     | unsigned(4 downto 0)         | MMD within this PHY (DEVAD) that the frame must         |
|          |                    |        |                              | address. Frames to other MMDs are skipped.              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | reg_addr           | in     | unsigned(15 downto 0)        | Expected register address in the address frame. A       |
|          |                    |        |                              | mismatch results in an alert with severity              |
|          |                    |        |                              | 'alert_level'.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | mdio_if            | in     | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | '1' aborts the call and releases the bus, without an    |
|          |                    |        |                              | alert. Tie to '0' if not used.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time to wait for the addressed frame to start.  |
|          |                    |        |                              | A started frame is always completed. Default value is   |
|          |                    |        |                              | C_UNDEFINED_TIME, which uses config.phy.timeout. 0 ns = |
|          |                    |        |                              | no timeout.                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Severity if the addressed frame is not as expected:     |
|          |                    |        |                              | wrong opcode or wrong register address in the address   |
|          |                    |        |                              | frame. Default value is ERROR.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("MDIO BFM").  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_mdio_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_mdio_bfm_config>`         | value is C_MDIO_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_phy_c45_expect_address(5x"03", x"0000", "Expect PCS control register address", mdio_if, terminate_loop);
    mdio_phy_c45_expect_address(5x"03", x"0000", "Expect PCS control register address", mdio_if, terminate_loop,
                                1 ms, ERROR, C_SCOPE, shared_msg_id_panel, C_MDIO_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    mdio_phy_c45_expect_address(5x"03", x"0000", "Expect PCS control register address");

.. _mdio_phy_c45_receive_address_bfm:

mdio_phy_c45_receive_address()
----------------------------------------------------------------------------------------------------------------------------------
Waits for a clause 45 address frame to the MMD 'dev_addr' of this PHY and returns the received register address in 'reg_addr'.
'reg_addr' is set to all 'X' at the start of the call and only assigned once the address was received with the right opcode.

The procedure will report alerts for the same conditions as the :ref:`mdio_phy_c22_expect_write_bfm` procedure.

.. code-block::

    mdio_phy_c45_receive_address(dev_addr, reg_addr, msg, mdio_if, terminate_loop, [timeout, [alert_level, [scope, [msg_id_panel, [config]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | dev_addr           | in     | unsigned(4 downto 0)         | MMD within this PHY (DEVAD) that the frame must         |
|          |                    |        |                              | address. Frames to other MMDs are skipped.              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | reg_addr           | out    | unsigned(15 downto 0)        | The register address received in the address frame. All |
|          |                    |        |                              | 'X' if the call ended without a complete frame.         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | mdio_if            | in     | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | '1' aborts the call and releases the bus, without an    |
|          |                    |        |                              | alert. Tie to '0' if not used.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time to wait for the addressed frame to start.  |
|          |                    |        |                              | A started frame is always completed. Default value is   |
|          |                    |        |                              | C_UNDEFINED_TIME, which uses config.phy.timeout. 0 ns = |
|          |                    |        |                              | no timeout.                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Severity if the addressed frame is not as expected:     |
|          |                    |        |                              | wrong opcode. Default value is ERROR.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("MDIO BFM").  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_mdio_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_mdio_bfm_config>`         | value is C_MDIO_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_phy_c45_receive_address(5x"03", v_reg_addr, "Receive PCS register address", mdio_if, terminate_loop);
    mdio_phy_c45_receive_address(5x"03", v_reg_addr, "Receive PCS register address", mdio_if, terminate_loop,
                                 1 ms, ERROR, C_SCOPE, shared_msg_id_panel, C_MDIO_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    mdio_phy_c45_receive_address(5x"03", v_reg_addr, "Receive PCS register address");

.. _mdio_phy_c45_expect_write_bfm:

mdio_phy_c45_expect_write()
----------------------------------------------------------------------------------------------------------------------------------
Waits for a clause 45 write frame to the MMD 'dev_addr' of this PHY and compares the written data with 'data'. If the data
matches, a log message is written with ID 'config.id_for_bfm'.

The procedure will report alerts for the same conditions as the :ref:`mdio_phy_c22_expect_write_bfm` procedure.

.. code-block::

    mdio_phy_c45_expect_write(dev_addr, data, msg, mdio_if, terminate_loop, [timeout, [alert_level, [scope, [msg_id_panel, [config]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | dev_addr           | in     | unsigned(4 downto 0)         | MMD within this PHY (DEVAD) that the frame must         |
|          |                    |        |                              | address. Frames to other MMDs are skipped.              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_ulogic_vector(15         | The data value to expect in the write frame. A mismatch |
|          |                    |        | downto 0)                    | results in an alert with severity 'alert_level'.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | mdio_if            | in     | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | '1' aborts the call and releases the bus, without an    |
|          |                    |        |                              | alert. Tie to '0' if not used.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time to wait for the addressed frame to start.  |
|          |                    |        |                              | A started frame is always completed. Default value is   |
|          |                    |        |                              | C_UNDEFINED_TIME, which uses config.phy.timeout. 0 ns = |
|          |                    |        |                              | no timeout.                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Severity if the addressed frame is not as expected:     |
|          |                    |        |                              | wrong opcode or wrong written data. Default value is    |
|          |                    |        |                              | ERROR.                                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("MDIO BFM").  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_mdio_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_mdio_bfm_config>`         | value is C_MDIO_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_phy_c45_expect_write(5x"03", x"2040", "Expect PCS control register write", mdio_if, terminate_loop);
    mdio_phy_c45_expect_write(5x"03", x"2040", "Expect PCS control register write", mdio_if, terminate_loop,
                              1 ms, ERROR, C_SCOPE, shared_msg_id_panel, C_MDIO_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    mdio_phy_c45_expect_write(5x"03", x"2040", "Expect PCS control register write");

.. _mdio_phy_c45_receive_write_bfm:

mdio_phy_c45_receive_write()
----------------------------------------------------------------------------------------------------------------------------------
Waits for a clause 45 write frame to the MMD 'dev_addr' of this PHY and returns the written data in 'data'. 'data' is set to all
'X' at the start of the call and only assigned once the data was received with the right opcode.

The procedure will report alerts for the same conditions as the :ref:`mdio_phy_c22_expect_write_bfm` procedure. A data mismatch is
not possible.

.. code-block::

    mdio_phy_c45_receive_write(dev_addr, data, msg, mdio_if, terminate_loop, [timeout, [alert_level, [scope, [msg_id_panel, [config]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | dev_addr           | in     | unsigned(4 downto 0)         | MMD within this PHY (DEVAD) that the frame must         |
|          |                    |        |                              | address. Frames to other MMDs are skipped.              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | data               | out    | std_ulogic_vector(15         | The data value written by the STA. All 'X' if the call  |
|          |                    |        | downto 0)                    | ended without a complete frame.                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | mdio_if            | in     | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | '1' aborts the call and releases the bus, without an    |
|          |                    |        |                              | alert. Tie to '0' if not used.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time to wait for the addressed frame to start.  |
|          |                    |        |                              | A started frame is always completed. Default value is   |
|          |                    |        |                              | C_UNDEFINED_TIME, which uses config.phy.timeout. 0 ns = |
|          |                    |        |                              | no timeout.                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Severity if the addressed frame is not as expected:     |
|          |                    |        |                              | wrong opcode. Default value is ERROR.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("MDIO BFM").  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_mdio_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_mdio_bfm_config>`         | value is C_MDIO_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_phy_c45_receive_write(5x"03", v_data, "Receive PCS control register write", mdio_if, terminate_loop);
    mdio_phy_c45_receive_write(5x"03", v_data, "Receive PCS control register write", mdio_if, terminate_loop,
                               1 ms, ERROR, C_SCOPE, shared_msg_id_panel, C_MDIO_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    mdio_phy_c45_receive_write(5x"03", v_data, "Receive PCS control register write");

.. _mdio_phy_c45_reply_read_bfm:

mdio_phy_c45_reply_read()
----------------------------------------------------------------------------------------------------------------------------------
Waits for a clause 45 read frame to the MMD 'dev_addr' of this PHY and returns 'data' to the STA. MDIO is driven
config.output_delay after the rising MDC edge.

The procedure will report alerts for the same conditions as the :ref:`mdio_phy_c22_reply_read_bfm` procedure.

.. code-block::

    mdio_phy_c45_reply_read(dev_addr, data, msg, mdio_if, terminate_loop, [timeout, [alert_level, [scope, [msg_id_panel, [config]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | dev_addr           | in     | unsigned(4 downto 0)         | MMD within this PHY (DEVAD) that the frame must         |
|          |                    |        |                              | address. Frames to other MMDs are skipped.              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_ulogic_vector(15         | The data value returned to the STA                      |
|          |                    |        | downto 0)                    |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | mdio_if            | inout  | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | '1' aborts the call and releases the bus, without an    |
|          |                    |        |                              | alert. Tie to '0' if not used.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time to wait for the addressed frame to start.  |
|          |                    |        |                              | A started frame is always completed. Default value is   |
|          |                    |        |                              | C_UNDEFINED_TIME, which uses config.phy.timeout. 0 ns = |
|          |                    |        |                              | no timeout.                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Severity if the addressed frame is not as expected:     |
|          |                    |        |                              | wrong opcode. Default value is ERROR.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("MDIO BFM").  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_mdio_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_mdio_bfm_config>`         | value is C_MDIO_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_phy_c45_reply_read(5x"03", x"2040", "Reply PCS control register", mdio_if, terminate_loop);
    mdio_phy_c45_reply_read(5x"03", x"2040", "Reply PCS control register", mdio_if, terminate_loop, 1 ms, ERROR,
                            C_SCOPE, shared_msg_id_panel, C_MDIO_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    mdio_phy_c45_reply_read(5x"03", x"2040", "Reply PCS control register");

.. _mdio_phy_c45_reply_post_read_increment_bfm:

mdio_phy_c45_reply_post_read_increment()
----------------------------------------------------------------------------------------------------------------------------------
Waits for a clause 45 post-read-increment-address frame to the MMD 'dev_addr' of this PHY and returns 'data' to the STA. The BFM
does not increment any address.

The procedure will report alerts for the same conditions as the :ref:`mdio_phy_c22_reply_read_bfm` procedure.

.. code-block::

    mdio_phy_c45_reply_post_read_increment(dev_addr, data, msg, mdio_if, terminate_loop, [timeout, [alert_level, [scope, [msg_id_panel, [config]]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | dev_addr           | in     | unsigned(4 downto 0)         | MMD within this PHY (DEVAD) that the frame must         |
|          |                    |        |                              | address. Frames to other MMDs are skipped.              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_ulogic_vector(15         | The data value returned to the STA.                     |
|          |                    |        | downto 0)                    |                                                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | mdio_if            | inout  | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | '1' aborts the call and releases the bus, without an    |
|          |                    |        |                              | alert. Tie to '0' if not used.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time to wait for the addressed frame to start.  |
|          |                    |        |                              | A started frame is always completed. Default value is   |
|          |                    |        |                              | C_UNDEFINED_TIME, which uses config.phy.timeout. 0 ns = |
|          |                    |        |                              | no timeout.                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Severity if the addressed frame is not as expected:     |
|          |                    |        |                              | wrong opcode. Default value is ERROR.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("MDIO BFM").  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_mdio_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_mdio_bfm_config>`         | value is C_MDIO_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_phy_c45_reply_post_read_increment(5x"03", x"2040", "Reply PCS register, increment", mdio_if, terminate_loop);
    mdio_phy_c45_reply_post_read_increment(5x"03", x"2040", "Reply PCS register, increment", mdio_if, terminate_loop,
                                           1 ms, ERROR, C_SCOPE, shared_msg_id_panel, C_MDIO_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    mdio_phy_c45_reply_post_read_increment(5x"03", x"2040", "Reply PCS register, increment");

.. _init_mdio_if_signals_bfm:

init_mdio_if_signals()
----------------------------------------------------------------------------------------------------------------------------------
Initializes the MDIO interface. MDC and MDIO are set to 'Z' (released).

.. code-block::

    t_mdio_if := init_mdio_if_signals

.. code-block::

    -- Examples:
    mdio_if <= init_mdio_if_signals;

.. _mdio_check_bit_timing_bfm:

mdio_check_bit_timing()
----------------------------------------------------------------------------------------------------------------------------------
Passive timing check of one bit time, used by the bus timing checker of the VVC (see :ref:`vvc_mdio_bus_timing_check`). It waits
for the next rising MDC edge and returns the sampled bit. The caller follows the frames and passes who drives MDIO in this bit
time ('driver'). Only the side of the bus selected with 'checked_side' is checked:

* STA side (CHECK_STA or CHECK_BOTH):

  * STA_DRIVES: MDIO does not change at the rising MDC edge that starts the bit time (0 ns hold time) or within
    config.min_hold_time after it, and is stable config.min_setup_time before the next rising edge.
  * STA_RELEASES: hold time only, as nobody drives the next bit.
  * PHY_RELEASES: the next bit, driven by the STA, is stable config.min_setup_time before the next rising edge.
  * The MDC period between two rising and between two falling edges (config.min_mdc_period), the high time
    (config.min_mdc_high_time) and the low time (config.min_mdc_low_time). This is also checked with NOT_CHECKED.

* PHY side (CHECK_PHY or CHECK_BOTH):

  * PHY_DRIVES: MDIO has settled at most 300 ns after the rising MDC edge that starts the bit time.
  * PHY_RELEASES: the PHY releases MDIO at most 300 ns after the rising MDC edge of the last data bit of a read.

With NOT_CHECKED (before the first MDC edge) MDIO is not checked.

.. code-block::

    mdio_check_bit_timing(mdio_if, driver, mdc_edges, sampled, checked_side, [alert_level, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | mdio_if            | in     | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | driver             | in     | t_mdio_bit_driver            | Who drives MDIO in this bit time: NOT_CHECKED,          |
|          |                    |        |                              | STA_DRIVES, STA_RELEASES, PHY_DRIVES or PHY_RELEASES    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | mdc_edges          | inout  | t_mdio_mdc_edges             | MDC edges seen so far, kept by the caller between the   |
|          |                    |        |                              | calls. Needs no initialisation.                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | sampled            | out    | std_ulogic                   | The MDIO value at the rising MDC edge, not normalized   |
|          |                    |        |                              | (e.g. 'H' stays 'H'). If MDIO changes in the same time  |
|          |                    |        |                              | step as the edge, the value before the change.          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | checked_side       | in     | t_mdio_timing_check          | Side of the bus to check: CHECK_STA (MDC and the bits   |
|          |                    |        |                              | driven by the STA), CHECK_PHY (the bits driven by a     |
|          |                    |        |                              | PHY) or CHECK_BOTH. The VVC checks the other side than  |
|          |                    |        |                              | its own role.                                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for a timing violation. Default value |
|          |                    |        |                              | is ERROR.                                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_BFM_SCOPE ("MDIO BFM").  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel. For more information see  |
|          |                    |        |                              | :ref:`vvc_framework_verbosity_ctrl`.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_mdio_bfm_config      | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_mdio_bfm_config>`         | value is C_MDIO_BFM_CONFIG_DEFAULT.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_check_bit_timing(mdio_if, STA_DRIVES, v_mdc_edges, v_bit, CHECK_STA);
    mdio_check_bit_timing(mdio_if, PHY_DRIVES, v_mdc_edges, v_bit, CHECK_PHY, ERROR, C_SCOPE,
                          shared_msg_id_panel, C_MDIO_BFM_CONFIG_DEFAULT);


Local BFM overloads
==================================================================================================================================
A good approach for better readability and maintainability is to make simple, local overloads for the BFM procedures in the TB
process. This allows calling the BFM procedures with the key parameters only, e.g. ::

    mdio_sta_c22_write(C_PHY_ADDR, C_REG_CONTROL, x"1140", "Restart autonegotiation");

rather than ::

    mdio_sta_c22_write(C_PHY_ADDR, C_REG_CONTROL, x"1140", "Restart autonegotiation", mdio_if, terminate_loop, C_SCOPE,
                       shared_msg_id_panel, C_MDIO_CONFIG_LOCAL);

By defining the local overload as e.g. ::

    procedure mdio_sta_c22_write(
      constant phy_addr : in unsigned;
      constant reg_addr : in unsigned;
      constant data     : in std_ulogic_vector;
      constant msg      : in string) is
    begin
      mdio_sta_c22_write(phy_addr,             -- Keep as is
                         reg_addr,             -- Keep as is
                         data,                 -- Keep as is
                         msg,                  -- Keep as is
                         mdio_if,              -- Signal must be visible in local process scope
                         terminate_loop,       -- Signal must be visible in local process scope
                         C_SCOPE,              -- Use the default
                         shared_msg_id_panel,  -- Use global, shared msg_id_panel
                         C_MDIO_CONFIG_LOCAL); -- Use locally defined configuration or C_MDIO_BFM_CONFIG_DEFAULT
    end procedure;

Using a local overload like this also allows the following – if wanted:

* Have address value as natural – and convert in the overload
* Set up defaults for constants. May be different for two overloads of the same BFM
* Apply dedicated message ID panel to allow dedicated verbosity control


.. _mdio_local_bfm_config:

Local BFM configuration
==================================================================================================================================
The default BFM configuration C_MDIO_BFM_CONFIG_DEFAULT follows IEEE 802.3 and can be used as is. A local configuration is
needed to e.g. change the MDC period, the address of the PHY or to suppress the preamble.

Defining a local MDIO BFM configuration: ::

    constant C_MDIO_CONFIG_LOCAL : t_mdio_bfm_config := (
      min_setup_time            => 10 ns,
      min_hold_time             => 10 ns,
      min_mdc_period            => 400 ns,
      min_mdc_high_time         => 160 ns,
      min_mdc_low_time          => 160 ns,
      output_delay              => 150 ns,
      id_for_bfm                => ID_BFM,
      id_for_bfm_wait           => ID_BFM_WAIT,
      suppress_preamble         => false,
      sync_to_frame_start       => true,
      protocol_error_severity   => ERROR,
      bus_contention_severity   => ERROR,
      timing_violation_severity => ERROR,
      phy                       => (phy_address                  => 5x"03",
                                    max_wait_mdc_change          => 1 ms,
                                    max_wait_mdc_change_severity => FAILURE,
                                    timeout                      => 10 ms,
                                    timeout_severity             => ERROR),
      sta                       => (mdc_period                     => 1 us,
                                    preamble_length                => 32,
                                    idle_cycles                    => 1,
                                    turnaround_not_driven_severity => ERROR)
    );

The local configuration can also be derived from the default, e.g. ::

    variable v_mdio_config : t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT;
    ...
    v_mdio_config.sta.mdc_period    := 1 us;
    v_mdio_config.phy.phy_address   := 5x"03";
    v_mdio_config.suppress_preamble := true;


Compilation
==================================================================================================================================
.. include:: rst_snippets/bfm_compilation.rst

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


.. _mdio_additional_doc:

Additional Documentation
==================================================================================================================================
For additional documentation on the MDIO protocol, please see IEEE Std 802.3, clause 22 (22.2.4 "Management functions",
22.3.4 "MDIO timing") and clause 45 ("Management Data Input/Output (MDIO) Interface").

.. important::

    * This BFM implements the MDIO management interface of IEEE 802.3, clause 22 and clause 45, for the STA and the PHY.
    * The BFM is not a complete MDIO protocol checker, only the listed checks are made.


.. _mdio_abbreviations:

Abbreviations
----------------------------------------------------------------------------------------------------------------------------------
+------------------+------------------------------------------------------------------------------------------------------------------+
| Abbreviation     | Meaning                                                                                                          |
+==================+==================================================================================================================+
| STA              | Station management entity: the bus master, drives MDC and starts every frame                                     |
+------------------+------------------------------------------------------------------------------------------------------------------+
| PHY              | The addressed target. In clause 45 any port addressed by PRTAD.                                                  |
+------------------+------------------------------------------------------------------------------------------------------------------+
| MMD              | MDIO manageable device: a clause 45 device within a PHY, addressed by DEVAD                                      |
+------------------+------------------------------------------------------------------------------------------------------------------+
| PHYAD / PRTAD    | 5-bit PHY / port address (clause 22 / clause 45), parameter phy_addr                                             |
+------------------+------------------------------------------------------------------------------------------------------------------+
| DEVAD            | 5-bit MMD address (clause 45), parameter dev_addr                                                                |
+------------------+------------------------------------------------------------------------------------------------------------------+
| REGAD            | 5-bit register address (clause 22), parameter reg_addr                                                           |
+------------------+------------------------------------------------------------------------------------------------------------------+
| ST / OP / TA     | Start of frame, operation code and turnaround fields of a frame                                                  |
+------------------+------------------------------------------------------------------------------------------------------------------+


**********************************************************************************************************************************
VVC
**********************************************************************************************************************************
* VVC functionality is implemented in mdio_vvc.vhd
* For general information see :ref:`vvc_framework_vvc_mechanisms_and_features`.
* The generic constant GC_STA_MODE selects the role: in STA mode the VVC drives MDC and the frames (``mdio_sta_*``
  methods), in PHY mode it answers frames from a DUT that is the STA (``mdio_phy_*`` methods).

Entity
==================================================================================================================================

Generics
----------------------------------------------------------------------------------------------------------------------------------
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| Name                                      | Type                         | Default                                 | Description                              |
+===========================================+==============================+=========================================+==========================================+
| GC_INSTANCE_IDX                           | natural                      |                                         | Instance number to assign the VVC.       |
|                                           |                              |                                         | Maximum value is defined by              |
|                                           |                              |                                         | C_MDIO_VVC_MAX_INSTANCE_NUM in           |
|                                           |                              |                                         | adaptations_pkg.                         |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| GC_STA_MODE                               | boolean                      |                                         | True: STA, false: PHY. No default, every |
|                                           |                              |                                         | instance states its role.                |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| GC_MDIO_BFM_CONFIG                        | :ref:`t_mdio_bfm_config      | C_MDIO_BFM_CONFIG_DEFAULT               | Configuration for the MDIO BFM           |
|                                           | <t_mdio_bfm_config>`         |                                         |                                          |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| GC_MDIO_PULLUP                            | boolean                      | false                                   | True: the VVC drives a weak pull-up      |
|                                           |                              |                                         | ('H') on mdio. False: the test harness   |
|                                           |                              |                                         | provides it.                             |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| GC_CMD_QUEUE_COUNT_MAX                    | natural                      | C_CMD_QUEUE_COUNT_MAX                   | Absolute maximum number of commands in   |
|                                           |                              |                                         | the VVC command queue                    |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| GC_CMD_QUEUE_COUNT_THRESHOLD              | natural                      | C_CMD_QUEUE_COUNT_THRESHOLD             | An alert is generated when reaching this |
|                                           |                              |                                         | threshold                                |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY     | :ref:`t_alert_level`         | C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    | Severity of the above alert              |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| GC_RESULT_QUEUE_COUNT_MAX                 | natural                      | C_RESULT_QUEUE_COUNT_MAX                | Maximum number of unfetched results      |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| GC_RESULT_QUEUE_COUNT_THRESHOLD           | natural                      | C_RESULT_QUEUE_COUNT_THRESHOLD          | An alert is generated when reaching this |
|                                           |                              |                                         | threshold                                |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY  | :ref:`t_alert_level`         | C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY | Severity of the above alert              |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+


.. _mdio_vvc_signals:

Signals
----------------------------------------------------------------------------------------------------------------------------------
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | mdio_vvc_if        | inout  | :ref:`t_mdio_if <t_mdio_if>` | MDIO signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

A VVC in STA mode drives MDC low from the start of the simulation, a VVC in PHY mode never drives MDC.

.. note::

    MDIO needs a pull-up. Either set the generic GC_MDIO_PULLUP to true, so that the VVC drives a weak pull-up ('H') on mdio
    (in both modes), or provide the pull-up in the test harness, e.g. ``mdio <= 'H';``. It is enough to enable the pull-up on
    one VVC connected to the bus.

Configuration Record
==================================================================================================================================
**vvc_config** accessible via **shared_mdio_vvc_config**

+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| Record element                            | Type                         | Default                                 | Description                              |
+===========================================+==============================+=========================================+==========================================+
| inter_bfm_delay                           | :ref:`t_inter_bfm_delay`     | C_MDIO_INTER_BFM_DELAY_DEFAULT          | Delay between BFM accesses               |
|                                           |                              |                                         | (TIME_START2START or TIME_FINISH2START)  |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| cmd_queue_count_max                       | natural                      | C_CMD_QUEUE_COUNT_MAX                   | Unused, use the entity generic           |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| cmd_queue_count_threshold                 | natural                      | C_CMD_QUEUE_COUNT_THRESHOLD             | Unused, use the entity generic           |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| cmd_queue_count_threshold_severity        | :ref:`t_alert_level`         | C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    | Unused, use the entity generic           |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| result_queue_count_max                    | natural                      | C_RESULT_QUEUE_COUNT_MAX                | Unused, use the entity generic           |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| result_queue_count_threshold              | natural                      | C_RESULT_QUEUE_COUNT_THRESHOLD          | Unused, use the entity generic           |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| result_queue_count_threshold_severity     | :ref:`t_alert_level`         | C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY | Unused, use the entity generic           |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| bfm_config                                | :ref:`t_mdio_bfm_config      | C_MDIO_BFM_CONFIG_DEFAULT               | Configuration for the MDIO BFM           |
|                                           | <t_mdio_bfm_config>`         |                                         |                                          |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| msg_id_panel                              | t_msg_id_panel               | C_VVC_MSG_ID_PANEL_DEFAULT              | VVC dedicated message ID panel, see      |
|                                           |                              |                                         | :ref:`vvc_framework_verbosity_ctrl`      |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| unwanted_activity_severity                | :ref:`t_alert_level`         | C_UNWANTED_ACTIVITY_SEVERITY            | Severity of unwanted activity, see       |
|                                           |                              |                                         | :ref:`vvc_mdio_unwanted_activity`        |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+
| bus_timing_checker                        | t_bus_timing_checker         | C_BUS_TIMING_CHECKER_DEFAULT            | Fields 'enable' (true) and 'alert_level' |
|                                           |                              |                                         | (ERROR), see                             |
|                                           |                              |                                         | :ref:`vvc_mdio_bus_timing_check`         |
+-------------------------------------------+------------------------------+-----------------------------------------+------------------------------------------+

The configuration record can be accessed from the Central Testbench Sequencer through the shared variable array, e.g. ::

    shared_mdio_vvc_config(C_VVC_IDX).bfm_config.sta.mdc_period := 1 us;

Status Record
==================================================================================================================================
**vvc_status** accessible via **shared_mdio_vvc_status**

.. include:: rst_snippets/vip_vvc_status.rst

Methods
==================================================================================================================================
* All VVC procedures are defined in vvc_methods_pkg.vhd (dedicated to this VVC).
* See :ref:`vvc_framework_methods` for procedures which are common to all VVCs.
* It is also possible to send a multicast to all instances of a VVC with ALL_INSTANCES as parameter for vvc_instance_idx.
* All parameters in brackets are optional.
* ``mdio_sta_*`` methods can only be used in STA mode, ``mdio_phy_*`` methods only in PHY mode. A command for the other
  role is reported with TB_ERROR and not executed.
* Address and data parameters are unconstrained and normalized to the widths given by the protocol. A value wider than the
  protocol width is only accepted if the extra bits are zero.
* Read and receive methods store the 16-bit result for fetch_result(), or send it to the scoreboard with TO_SB.
* insert_delay() with a number of clock cycles: STA mode delays that number of bfm_config.sta.mdc_period, PHY mode waits
  for that number of rising MDC edges on the bus. In PHY mode MDC is driven by the DUT (STA) and usually only runs during
  frames, so there is no timeout: if the STA stops MDC, the delay only ends with terminate_current_command(). Use
  insert_delay() with a time if the DUT may stop MDC, and a timeout in await_completion() to detect a stuck VVC.

.. note::

    Some parameters in the VVC procedures are unconstrained for flexibility. However, the maximum sizes of such parameters need to
    be defined for the VVC framework. For this VVC, the following maximum values can be configured from adaptations_pkg:

      +--------------------------------------------+--------------------------------------+
      | C_MDIO_VVC_CMD_STRING_MAX_LENGTH           | Maximum **msg** length               |
      +--------------------------------------------+--------------------------------------+


.. _mdio_sta_c22_write_vvc:

mdio_sta_c22_write()
----------------------------------------------------------------------------------------------------------------------------------
Adds a clause 22 write command to the MDIO VVC executor queue, which will run as soon as all preceding commands have completed.
When the command is scheduled to run, the executor calls the BFM :ref:`mdio_sta_c22_write_bfm` procedure. This procedure can only
be called when the MDIO VVC is instantiated in STA mode, i.e. setting the VVC entity generic constant 'GC_STA_MODE' to 'true'.

.. code-block::

    mdio_sta_c22_write(VVCT, vvc_instance_idx, phy_addr, reg_addr, data, msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | phy_addr           | in     | unsigned                     | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45). Normalized to 5 bits.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | reg_addr           | in     | unsigned                     | Register address (REGAD). Normalized to 5 bits.         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_ulogic_vector            | The data value to be written to the register.           |
|          |                    |        |                              | Normalized to 16 bits.                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c22_write(MDIO_VVCT, 0, 5x"01", 5x"00", x"1140", "Restart autonegotiation");
    mdio_sta_c22_write(MDIO_VVCT, 0, 5x"01", 5x"00", x"1140", "Restart autonegotiation", C_SCOPE);

.. _mdio_sta_c22_read_vvc:

mdio_sta_c22_read()
----------------------------------------------------------------------------------------------------------------------------------
Adds a clause 22 read command to the MDIO VVC executor queue, which will run as soon as all preceding commands have completed.
When the command is scheduled to run, the executor calls the BFM :ref:`mdio_sta_c22_read_bfm` procedure.

The read data will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but the read data
will be stored in the VVC for a potential future fetch (see example with fetch_result below). If the data_routing is set to TO_SB,
the read data will be sent to the MDIO VVC dedicated scoreboard where it will be checked against the expected value (provided by
the testbench). This procedure can only be called when the MDIO VVC is instantiated in STA mode, i.e. setting the VVC entity
generic constant 'GC_STA_MODE' to 'true'.

.. code-block::

    mdio_sta_c22_read(VVCT, vvc_instance_idx, phy_addr, reg_addr, [data_routing,] msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | phy_addr           | in     | unsigned                     | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45). Normalized to 5 bits.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | reg_addr           | in     | unsigned                     | Register address (REGAD). Normalized to 5 bits.         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_routing       | in     | :ref:`t_data_routing`        | Selects the destination of the received data. TO_SB     |
|          |                    |        |                              | sends it to the VVC scoreboard instead of the result    |
|          |                    |        |                              | queue.                                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c22_read(MDIO_VVCT, 0, 5x"01", 5x"01", "Read status register");
    mdio_sta_c22_read(MDIO_VVCT, 0, 5x"01", 5x"01", TO_SB, "Read status register and send to Scoreboard", C_SCOPE);

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last read
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from read
    ...
    mdio_sta_c22_read(MDIO_VVCT, 0, 5x"01", 5x"01", "Read status register");
    v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, 0);
    await_completion(MDIO_VVCT, 0, v_cmd_idx, 1 ms, "Wait for read to finish");
    fetch_result(MDIO_VVCT, 0, v_cmd_idx, v_result, "Fetching result from read operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.

.. _mdio_sta_c22_check_vvc:

mdio_sta_c22_check()
----------------------------------------------------------------------------------------------------------------------------------
Adds a clause 22 check command to the MDIO VVC executor queue, which will run as soon as all preceding commands have completed.
When the command is scheduled to run, the executor calls the BFM :ref:`mdio_sta_c22_check_bfm` procedure. The mdio_sta_c22_check()
procedure will perform a read operation, then check if the read data is equal to the expected data in the data_exp parameter. If
the read data is not equal to the expected data parameter, an alert with severity 'alert_level' will be issued. The read data will
not be stored by this procedure. This procedure can only be called when the MDIO VVC is instantiated in STA mode, i.e. setting the
VVC entity generic constant 'GC_STA_MODE' to 'true'.

.. code-block::

    mdio_sta_c22_check(VVCT, vvc_instance_idx, phy_addr, reg_addr, data_exp, msg, [alert_level, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | phy_addr           | in     | unsigned                     | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45). Normalized to 5 bits.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | reg_addr           | in     | unsigned                     | Register address (REGAD). Normalized to 5 bits.         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_ulogic_vector            | The data value to expect when reading the register.     |
|          |                    |        |                              | Normalized to 16 bits. A mismatch results in an alert   |
|          |                    |        |                              | with severity 'alert_level'.                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert if the read data does   |
|          |                    |        |                              | not match. Default value is ERROR.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c22_check(MDIO_VVCT, 0, 5x"01", 5x"01", x"796D", "Check status register");
    mdio_sta_c22_check(MDIO_VVCT, 0, 5x"01", 5x"01", x"796D", "Check status register", WARNING, C_SCOPE);

.. _mdio_sta_c45_address_vvc:

mdio_sta_c45_address()
----------------------------------------------------------------------------------------------------------------------------------
Adds a clause 45 address command to the MDIO VVC executor queue, which will run as soon as all preceding commands have completed.
When the command is scheduled to run, the executor calls the BFM :ref:`mdio_sta_c45_address_bfm` procedure. This procedure can
only be called when the MDIO VVC is instantiated in STA mode, i.e. setting the VVC entity generic constant 'GC_STA_MODE' to
'true'.

.. code-block::

    mdio_sta_c45_address(VVCT, vvc_instance_idx, phy_addr, dev_addr, reg_addr, msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | phy_addr           | in     | unsigned                     | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45). Normalized to 5 bits.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned                     | Address of the target MMD within the PHY (DEVAD).       |
|          |                    |        |                              | Normalized to 5 bits.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | reg_addr           | in     | unsigned                     | Register address sent in the address frame. Normalized  |
|          |                    |        |                              | to 16 bits.                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c45_address(MDIO_VVCT, 0, 5x"01", 5x"03", x"0000", "Select PCS control register");
    mdio_sta_c45_address(MDIO_VVCT, 0, 5x"01", 5x"03", x"0000", "Select PCS control register", C_SCOPE);

.. _mdio_sta_c45_write_vvc:

mdio_sta_c45_write()
----------------------------------------------------------------------------------------------------------------------------------
Adds a clause 45 write command to the MDIO VVC executor queue, which will run as soon as all preceding commands have completed.
When the command is scheduled to run, the executor calls the BFM :ref:`mdio_sta_c45_write_bfm` procedure. The frame writes the
register address set by a preceding address frame. This procedure can only be called when the MDIO VVC is instantiated in STA
mode, i.e. setting the VVC entity generic constant 'GC_STA_MODE' to 'true'.

.. code-block::

    mdio_sta_c45_write(VVCT, vvc_instance_idx, phy_addr, dev_addr, data, msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | phy_addr           | in     | unsigned                     | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45). Normalized to 5 bits.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned                     | Address of the target MMD within the PHY (DEVAD).       |
|          |                    |        |                              | Normalized to 5 bits.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_ulogic_vector            | The data value to be written to the register.           |
|          |                    |        |                              | Normalized to 16 bits.                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c45_write(MDIO_VVCT, 0, 5x"01", 5x"03", x"2040", "Write PCS control register");
    mdio_sta_c45_write(MDIO_VVCT, 0, 5x"01", 5x"03", x"2040", "Write PCS control register", C_SCOPE);

.. _mdio_sta_c45_read_vvc:

mdio_sta_c45_read()
----------------------------------------------------------------------------------------------------------------------------------
Adds a clause 45 read command to the MDIO VVC executor queue, which will run as soon as all preceding commands have completed.
When the command is scheduled to run, the executor calls the BFM :ref:`mdio_sta_c45_read_bfm` procedure. The frame reads the
register address set by a preceding address frame.

The read data will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but the read data
will be stored in the VVC for a potential future fetch (see example with fetch_result below). If the data_routing is set to TO_SB,
the read data will be sent to the MDIO VVC dedicated scoreboard where it will be checked against the expected value (provided by
the testbench). This procedure can only be called when the MDIO VVC is instantiated in STA mode, i.e. setting the VVC entity
generic constant 'GC_STA_MODE' to 'true'.

.. code-block::

    mdio_sta_c45_read(VVCT, vvc_instance_idx, phy_addr, dev_addr, [data_routing,] msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | phy_addr           | in     | unsigned                     | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45). Normalized to 5 bits.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned                     | Address of the target MMD within the PHY (DEVAD).       |
|          |                    |        |                              | Normalized to 5 bits.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_routing       | in     | :ref:`t_data_routing`        | Selects the destination of the received data. TO_SB     |
|          |                    |        |                              | sends it to the VVC scoreboard instead of the result    |
|          |                    |        |                              | queue.                                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c45_read(MDIO_VVCT, 0, 5x"01", 5x"03", "Read PCS control register");
    mdio_sta_c45_read(MDIO_VVCT, 0, 5x"01", 5x"03", TO_SB, "Read PCS control register and send to Scoreboard", C_SCOPE);

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last read
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from read
    ...
    mdio_sta_c45_read(MDIO_VVCT, 0, 5x"01", 5x"03", "Read PCS control register");
    v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, 0);
    await_completion(MDIO_VVCT, 0, v_cmd_idx, 1 ms, "Wait for read to finish");
    fetch_result(MDIO_VVCT, 0, v_cmd_idx, v_result, "Fetching result from read operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.

.. _mdio_sta_c45_post_read_increment_vvc:

mdio_sta_c45_post_read_increment()
----------------------------------------------------------------------------------------------------------------------------------
Adds a clause 45 post-read-increment command to the MDIO VVC executor queue, which will run as soon as all preceding commands have
completed. When the command is scheduled to run, the executor calls the BFM :ref:`mdio_sta_c45_post_read_increment_bfm` procedure.

The read data will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but the read data
will be stored in the VVC for a potential future fetch (see example with fetch_result below). If the data_routing is set to TO_SB,
the read data will be sent to the MDIO VVC dedicated scoreboard where it will be checked against the expected value (provided by
the testbench). This procedure can only be called when the MDIO VVC is instantiated in STA mode, i.e. setting the VVC entity
generic constant 'GC_STA_MODE' to 'true'.

.. code-block::

    mdio_sta_c45_post_read_increment(VVCT, vvc_instance_idx, phy_addr, dev_addr, [data_routing,] msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | phy_addr           | in     | unsigned                     | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45). Normalized to 5 bits.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned                     | Address of the target MMD within the PHY (DEVAD).       |
|          |                    |        |                              | Normalized to 5 bits.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_routing       | in     | :ref:`t_data_routing`        | Selects the destination of the received data. TO_SB     |
|          |                    |        |                              | sends it to the VVC scoreboard instead of the result    |
|          |                    |        |                              | queue.                                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c45_post_read_increment(MDIO_VVCT, 0, 5x"01", 5x"03", "Read PCS register, increment");
    mdio_sta_c45_post_read_increment(MDIO_VVCT, 0, 5x"01", 5x"03", TO_SB, "Read PCS register, increment", C_SCOPE);

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last read
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from read
    ...
    mdio_sta_c45_post_read_increment(MDIO_VVCT, 0, 5x"01", 5x"03", "Read PCS register, increment");
    v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, 0);
    await_completion(MDIO_VVCT, 0, v_cmd_idx, 1 ms, "Wait for read to finish");
    fetch_result(MDIO_VVCT, 0, v_cmd_idx, v_result, "Fetching result from read operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.

.. _mdio_sta_c45_check_vvc:

mdio_sta_c45_check()
----------------------------------------------------------------------------------------------------------------------------------
Adds a clause 45 check command to the MDIO VVC executor queue, which will run as soon as all preceding commands have completed.
When the command is scheduled to run, the executor calls the BFM :ref:`mdio_sta_c45_check_bfm` procedure. The mdio_sta_c45_check()
procedure will perform a read operation, then check if the read data is equal to the expected data in the data_exp parameter. If
the read data is not equal to the expected data parameter, an alert with severity 'alert_level' will be issued. The read data will
not be stored by this procedure. This procedure can only be called when the MDIO VVC is instantiated in STA mode, i.e. setting the
VVC entity generic constant 'GC_STA_MODE' to 'true'.

.. code-block::

    mdio_sta_c45_check(VVCT, vvc_instance_idx, phy_addr, dev_addr, data_exp, msg, [alert_level, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | phy_addr           | in     | unsigned                     | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45). Normalized to 5 bits.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned                     | Address of the target MMD within the PHY (DEVAD).       |
|          |                    |        |                              | Normalized to 5 bits.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_ulogic_vector            | The data value to expect when reading the register.     |
|          |                    |        |                              | Normalized to 16 bits. A mismatch results in an alert   |
|          |                    |        |                              | with severity 'alert_level'.                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert if the read data does   |
|          |                    |        |                              | not match. Default value is ERROR.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c45_check(MDIO_VVCT, 0, 5x"01", 5x"03", x"2040", "Check PCS control register");
    mdio_sta_c45_check(MDIO_VVCT, 0, 5x"01", 5x"03", x"2040", "Check PCS control register", WARNING, C_SCOPE);

.. _mdio_sta_c45_check_post_read_increment_vvc:

mdio_sta_c45_check_post_read_increment()
----------------------------------------------------------------------------------------------------------------------------------
Adds a clause 45 post-read-increment check command to the MDIO VVC executor queue, which will run as soon as all preceding
commands have completed. When the command is scheduled to run, the executor calls the BFM
:ref:`mdio_sta_c45_check_post_read_increment_bfm` procedure. The mdio_sta_c45_check_post_read_increment() procedure will perform a
read operation, then check if the read data is equal to the expected data in the data_exp parameter. If the read data is not equal
to the expected data parameter, an alert with severity 'alert_level' will be issued. The read data will not be stored by this
procedure. This procedure can only be called when the MDIO VVC is instantiated in STA mode, i.e. setting the VVC entity generic
constant 'GC_STA_MODE' to 'true'.

.. code-block::

    mdio_sta_c45_check_post_read_increment(VVCT, vvc_instance_idx, phy_addr, dev_addr, data_exp, msg, [alert_level, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | phy_addr           | in     | unsigned                     | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45). Normalized to 5 bits.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned                     | Address of the target MMD within the PHY (DEVAD).       |
|          |                    |        |                              | Normalized to 5 bits.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_ulogic_vector            | The data value to expect when reading the register.     |
|          |                    |        |                              | Normalized to 16 bits. A mismatch results in an alert   |
|          |                    |        |                              | with severity 'alert_level'.                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert if the read data does   |
|          |                    |        |                              | not match. Default value is ERROR.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c45_check_post_read_increment(MDIO_VVCT, 0, 5x"01", 5x"03", x"2040", "Check PCS register, increment");
    mdio_sta_c45_check_post_read_increment(MDIO_VVCT, 0, 5x"01", 5x"03", x"2040", "Check PCS register, increment", WARNING, C_SCOPE);

.. _mdio_sta_c45_write_reg_vvc:

mdio_sta_c45_write_reg()
----------------------------------------------------------------------------------------------------------------------------------
Adds a complete clause 45 register write as one command to the MDIO VVC executor queue, which will run as soon as all preceding
commands have completed. When the command is scheduled to run, the executor calls the BFM :ref:`mdio_sta_c45_address_bfm`
procedure followed by the BFM :ref:`mdio_sta_c45_write_bfm` procedure. If the address frame fails, i.e. it is terminated or a bus
check of the frame fails (bfm_config.bus_contention_severity), the access frame is not sent and the command ends. Timing alerts of
the configuration (bfm_config.timing_violation_severity) do not stop the access frame. This procedure can only be called when the
MDIO VVC is instantiated in STA mode, i.e. setting the VVC entity generic constant 'GC_STA_MODE' to 'true'.

.. code-block::

    mdio_sta_c45_write_reg(VVCT, vvc_instance_idx, phy_addr, dev_addr, reg_addr, data, msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | phy_addr           | in     | unsigned                     | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45). Normalized to 5 bits.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned                     | Address of the target MMD within the PHY (DEVAD).       |
|          |                    |        |                              | Normalized to 5 bits.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | reg_addr           | in     | unsigned                     | Register address sent in the address frame. Normalized  |
|          |                    |        |                              | to 16 bits.                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_ulogic_vector            | The data value to be written to the register.           |
|          |                    |        |                              | Normalized to 16 bits.                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c45_write_reg(MDIO_VVCT, 0, 5x"01", 5x"03", x"0000", x"2040", "Write PCS control register");
    mdio_sta_c45_write_reg(MDIO_VVCT, 0, 5x"01", 5x"03", x"0000", x"2040", "Write PCS control register", C_SCOPE);

.. _mdio_sta_c45_read_reg_vvc:

mdio_sta_c45_read_reg()
----------------------------------------------------------------------------------------------------------------------------------
Adds a complete clause 45 register read as one command to the MDIO VVC executor queue, which will run as soon as all preceding
commands have completed. When the command is scheduled to run, the executor calls the BFM :ref:`mdio_sta_c45_address_bfm`
procedure followed by the BFM :ref:`mdio_sta_c45_read_bfm` procedure. If the address frame fails, i.e. it is terminated or a bus
check of the frame fails (bfm_config.bus_contention_severity), the access frame is not sent and the command ends: the read returns
no data ('X'). Timing alerts of the configuration (bfm_config.timing_violation_severity) do not stop the access frame.

The read data will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but the read data
will be stored in the VVC for a potential future fetch (see example with fetch_result below). If the data_routing is set to TO_SB,
the read data will be sent to the MDIO VVC dedicated scoreboard where it will be checked against the expected value (provided by
the testbench). This procedure can only be called when the MDIO VVC is instantiated in STA mode, i.e. setting the VVC entity
generic constant 'GC_STA_MODE' to 'true'.

.. code-block::

    mdio_sta_c45_read_reg(VVCT, vvc_instance_idx, phy_addr, dev_addr, reg_addr, [data_routing,] msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | phy_addr           | in     | unsigned                     | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45). Normalized to 5 bits.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned                     | Address of the target MMD within the PHY (DEVAD).       |
|          |                    |        |                              | Normalized to 5 bits.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | reg_addr           | in     | unsigned                     | Register address sent in the address frame. Normalized  |
|          |                    |        |                              | to 16 bits.                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_routing       | in     | :ref:`t_data_routing`        | Selects the destination of the received data. TO_SB     |
|          |                    |        |                              | sends it to the VVC scoreboard instead of the result    |
|          |                    |        |                              | queue.                                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c45_read_reg(MDIO_VVCT, 0, 5x"01", 5x"03", x"0001", "Read PCS status register");
    mdio_sta_c45_read_reg(MDIO_VVCT, 0, 5x"01", 5x"03", x"0001", TO_SB, "Read PCS status register and send to Scoreboard", C_SCOPE);

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last read
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from read
    ...
    mdio_sta_c45_read_reg(MDIO_VVCT, 0, 5x"01", 5x"03", x"0001", "Read PCS status register");
    v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, 0);
    await_completion(MDIO_VVCT, 0, v_cmd_idx, 1 ms, "Wait for read to finish");
    fetch_result(MDIO_VVCT, 0, v_cmd_idx, v_result, "Fetching result from read operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.

.. _mdio_sta_c45_check_reg_vvc:

mdio_sta_c45_check_reg()
----------------------------------------------------------------------------------------------------------------------------------
Adds a complete clause 45 register check as one command to the MDIO VVC executor queue, which will run as soon as all preceding
commands have completed. When the command is scheduled to run, the executor calls the BFM :ref:`mdio_sta_c45_address_bfm`
procedure followed by the BFM :ref:`mdio_sta_c45_check_bfm` procedure. If the address frame fails, i.e. it is terminated or a bus
check of the frame fails (bfm_config.bus_contention_severity), the access frame is not sent and the command ends. Timing alerts of
the configuration (bfm_config.timing_violation_severity) do not stop the access frame. If the read data is not equal to the
expected data parameter, an alert with severity 'alert_level' will be issued. This procedure can only be called when the MDIO VVC
is instantiated in STA mode, i.e. setting the VVC entity generic constant 'GC_STA_MODE' to 'true'.

.. code-block::

    mdio_sta_c45_check_reg(VVCT, vvc_instance_idx, phy_addr, dev_addr, reg_addr, data_exp, msg, [alert_level, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | phy_addr           | in     | unsigned                     | Address of the target PHY: PHYAD (clause 22) / PRTAD    |
|          |                    |        |                              | (clause 45). Normalized to 5 bits.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned                     | Address of the target MMD within the PHY (DEVAD).       |
|          |                    |        |                              | Normalized to 5 bits.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | reg_addr           | in     | unsigned                     | Register address sent in the address frame. Normalized  |
|          |                    |        |                              | to 16 bits.                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_ulogic_vector            | The data value to expect when reading the register.     |
|          |                    |        |                              | Normalized to 16 bits. A mismatch results in an alert   |
|          |                    |        |                              | with severity 'alert_level'.                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert if the read data does   |
|          |                    |        |                              | not match. Default value is ERROR.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_sta_c45_check_reg(MDIO_VVCT, 0, 5x"01", 5x"03", x"0001", x"0004", "Check PCS status register");
    mdio_sta_c45_check_reg(MDIO_VVCT, 0, 5x"01", 5x"03", x"0001", x"0004", "Check PCS status register", WARNING, C_SCOPE);

.. _mdio_phy_c22_expect_write_vvc:

mdio_phy_c22_expect_write()
----------------------------------------------------------------------------------------------------------------------------------
Adds a clause 22 expect write command to the MDIO VVC executor queue, which will run as soon as all preceding commands have
completed. When the command is scheduled to run, the executor calls the BFM :ref:`mdio_phy_c22_expect_write_bfm` procedure. This
procedure can only be called when the MDIO VVC is instantiated in PHY mode, i.e. setting the VVC entity generic constant
'GC_STA_MODE' to 'false'.

.. code-block::

    mdio_phy_c22_expect_write(VVCT, vvc_instance_idx, reg_addr, data, msg, [timeout, [alert_level, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | reg_addr           | in     | unsigned                     | Register address (REGAD). Normalized to 5 bits.         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_ulogic_vector            | The data value to expect in the write frame. Normalized |
|          |                    |        |                              | to 16 bits. A mismatch results in an alert with         |
|          |                    |        |                              | severity 'alert_level'.                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time to wait for the addressed frame to start.  |
|          |                    |        |                              | Default value is C_UNDEFINED_TIME, which uses           |
|          |                    |        |                              | bfm_config.phy.timeout. 0 ns = no timeout.              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Severity if the addressed frame is not as expected:     |
|          |                    |        |                              | wrong opcode, wrong register address or wrong written   |
|          |                    |        |                              | data. Default value is ERROR.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_phy_c22_expect_write(MDIO_VVCT, 1, 5x"00", x"1140", "Expect control register write");
    mdio_phy_c22_expect_write(MDIO_VVCT, 1, 5x"00", x"1140", "Expect control register write", 1 ms, ERROR, C_SCOPE);

.. _mdio_phy_c22_receive_write_vvc:

mdio_phy_c22_receive_write()
----------------------------------------------------------------------------------------------------------------------------------
Adds a clause 22 receive write command to the MDIO VVC executor queue, which will run as soon as all preceding commands have
completed. When the command is scheduled to run, the executor calls the BFM :ref:`mdio_phy_c22_receive_write_bfm` procedure.

The received data will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but the received
data will be stored in the VVC for a potential future fetch (see example with fetch_result below). If the data_routing is set to
TO_SB, the received data will be sent to the MDIO VVC dedicated scoreboard where it will be checked against the expected value
(provided by the testbench). This procedure can only be called when the MDIO VVC is instantiated in PHY mode, i.e. setting the VVC
entity generic constant 'GC_STA_MODE' to 'false'.

.. code-block::

    mdio_phy_c22_receive_write(VVCT, vvc_instance_idx, reg_addr, [data_routing,] msg, [timeout, [alert_level, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | reg_addr           | in     | unsigned                     | Register address (REGAD). Normalized to 5 bits.         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_routing       | in     | :ref:`t_data_routing`        | Selects the destination of the received data. TO_SB     |
|          |                    |        |                              | sends it to the VVC scoreboard instead of the result    |
|          |                    |        |                              | queue.                                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time to wait for the addressed frame to start.  |
|          |                    |        |                              | Default value is C_UNDEFINED_TIME, which uses           |
|          |                    |        |                              | bfm_config.phy.timeout. 0 ns = no timeout.              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Severity if the addressed frame is not as expected:     |
|          |                    |        |                              | wrong opcode or wrong register address. Default value   |
|          |                    |        |                              | is ERROR.                                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_phy_c22_receive_write(MDIO_VVCT, 1, 5x"00", "Receive control register write");
    mdio_phy_c22_receive_write(MDIO_VVCT, 1, 5x"00", TO_SB, "Receive control register write and send to Scoreboard", 1 ms, ERROR, C_SCOPE);

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last receive
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from receive
    ...
    mdio_phy_c22_receive_write(MDIO_VVCT, 1, 5x"00", "Receive control register write");
    v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, 1);
    await_completion(MDIO_VVCT, 1, v_cmd_idx, 1 ms, "Wait for receive to finish");
    fetch_result(MDIO_VVCT, 1, v_cmd_idx, v_result, "Fetching result from receive operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.

.. _mdio_phy_c22_reply_read_vvc:

mdio_phy_c22_reply_read()
----------------------------------------------------------------------------------------------------------------------------------
Adds a clause 22 reply read command to the MDIO VVC executor queue, which will run as soon as all preceding commands have
completed. When the command is scheduled to run, the executor calls the BFM :ref:`mdio_phy_c22_reply_read_bfm` procedure. This
procedure can only be called when the MDIO VVC is instantiated in PHY mode, i.e. setting the VVC entity generic constant
'GC_STA_MODE' to 'false'.

.. code-block::

    mdio_phy_c22_reply_read(VVCT, vvc_instance_idx, reg_addr, data, msg, [timeout, [alert_level, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | reg_addr           | in     | unsigned                     | Register address (REGAD). Normalized to 5 bits.         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_ulogic_vector            | The data value returned to the STA. Normalized to 16    |
|          |                    |        |                              | bits.                                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time to wait for the addressed frame to start.  |
|          |                    |        |                              | Default value is C_UNDEFINED_TIME, which uses           |
|          |                    |        |                              | bfm_config.phy.timeout. 0 ns = no timeout.              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Severity if the addressed frame is not as expected:     |
|          |                    |        |                              | wrong opcode or wrong register address. Default value   |
|          |                    |        |                              | is ERROR.                                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_phy_c22_reply_read(MDIO_VVCT, 1, 5x"01", x"796D", "Reply status register");
    mdio_phy_c22_reply_read(MDIO_VVCT, 1, 5x"01", x"796D", "Reply status register", 1 ms, ERROR, C_SCOPE);

.. _mdio_phy_c45_expect_address_vvc:

mdio_phy_c45_expect_address()
----------------------------------------------------------------------------------------------------------------------------------
Adds a clause 45 expect address command to the MDIO VVC executor queue, which will run as soon as all preceding commands have
completed. When the command is scheduled to run, the executor calls the BFM :ref:`mdio_phy_c45_expect_address_bfm` procedure. This
procedure can only be called when the MDIO VVC is instantiated in PHY mode, i.e. setting the VVC entity generic constant
'GC_STA_MODE' to 'false'.

.. code-block::

    mdio_phy_c45_expect_address(VVCT, vvc_instance_idx, dev_addr, reg_addr, msg, [timeout, [alert_level, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned                     | MMD within this PHY (DEVAD) that the frame must         |
|          |                    |        |                              | address. Normalized to 5 bits.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | reg_addr           | in     | unsigned                     | Expected register address in the address frame.         |
|          |                    |        |                              | Normalized to 16 bits. A mismatch results in an alert   |
|          |                    |        |                              | with severity 'alert_level'.                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time to wait for the addressed frame to start.  |
|          |                    |        |                              | Default value is C_UNDEFINED_TIME, which uses           |
|          |                    |        |                              | bfm_config.phy.timeout. 0 ns = no timeout.              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Severity if the addressed frame is not as expected:     |
|          |                    |        |                              | wrong opcode or wrong register address in the address   |
|          |                    |        |                              | frame. Default value is ERROR.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_phy_c45_expect_address(MDIO_VVCT, 1, 5x"03", x"0000", "Expect PCS control register address");
    mdio_phy_c45_expect_address(MDIO_VVCT, 1, 5x"03", x"0000", "Expect PCS control register address", 1 ms, ERROR, C_SCOPE);

.. _mdio_phy_c45_receive_address_vvc:

mdio_phy_c45_receive_address()
----------------------------------------------------------------------------------------------------------------------------------
Adds a clause 45 receive address command to the MDIO VVC executor queue, which will run as soon as all preceding commands have
completed. When the command is scheduled to run, the executor calls the BFM :ref:`mdio_phy_c45_receive_address_bfm` procedure.

The received register address will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but
the received register address will be stored in the VVC for a potential future fetch (see example with fetch_result below). If the
data_routing is set to TO_SB, the received register address will be sent to the MDIO VVC dedicated scoreboard where it will be
checked against the expected value (provided by the testbench). This procedure can only be called when the MDIO VVC is
instantiated in PHY mode, i.e. setting the VVC entity generic constant 'GC_STA_MODE' to 'false'.

.. code-block::

    mdio_phy_c45_receive_address(VVCT, vvc_instance_idx, dev_addr, [data_routing,] msg, [timeout, [alert_level, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned                     | MMD within this PHY (DEVAD) that the frame must         |
|          |                    |        |                              | address. Normalized to 5 bits.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_routing       | in     | :ref:`t_data_routing`        | Selects the destination of the received data. TO_SB     |
|          |                    |        |                              | sends it to the VVC scoreboard instead of the result    |
|          |                    |        |                              | queue.                                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time to wait for the addressed frame to start.  |
|          |                    |        |                              | Default value is C_UNDEFINED_TIME, which uses           |
|          |                    |        |                              | bfm_config.phy.timeout. 0 ns = no timeout.              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Severity if the addressed frame is not as expected:     |
|          |                    |        |                              | wrong opcode. Default value is ERROR.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_phy_c45_receive_address(MDIO_VVCT, 1, 5x"03", "Receive PCS register address");
    mdio_phy_c45_receive_address(MDIO_VVCT, 1, 5x"03", TO_SB, "Receive PCS register address and send to Scoreboard", 1 ms, ERROR, C_SCOPE);

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last receive
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from receive
    ...
    mdio_phy_c45_receive_address(MDIO_VVCT, 1, 5x"03", "Receive PCS register address");
    v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, 1);
    await_completion(MDIO_VVCT, 1, v_cmd_idx, 1 ms, "Wait for receive to finish");
    fetch_result(MDIO_VVCT, 1, v_cmd_idx, v_result, "Fetching result from receive operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.

.. _mdio_phy_c45_expect_write_vvc:

mdio_phy_c45_expect_write()
----------------------------------------------------------------------------------------------------------------------------------
Adds a clause 45 expect write command to the MDIO VVC executor queue, which will run as soon as all preceding commands have
completed. When the command is scheduled to run, the executor calls the BFM :ref:`mdio_phy_c45_expect_write_bfm` procedure. This
procedure can only be called when the MDIO VVC is instantiated in PHY mode, i.e. setting the VVC entity generic constant
'GC_STA_MODE' to 'false'.

.. code-block::

    mdio_phy_c45_expect_write(VVCT, vvc_instance_idx, dev_addr, data, msg, [timeout, [alert_level, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned                     | MMD within this PHY (DEVAD) that the frame must         |
|          |                    |        |                              | address. Normalized to 5 bits.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_ulogic_vector            | The data value to expect in the write frame. Normalized |
|          |                    |        |                              | to 16 bits. A mismatch results in an alert with         |
|          |                    |        |                              | severity 'alert_level'.                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time to wait for the addressed frame to start.  |
|          |                    |        |                              | Default value is C_UNDEFINED_TIME, which uses           |
|          |                    |        |                              | bfm_config.phy.timeout. 0 ns = no timeout.              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Severity if the addressed frame is not as expected:     |
|          |                    |        |                              | wrong opcode or wrong written data. Default value is    |
|          |                    |        |                              | ERROR.                                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_phy_c45_expect_write(MDIO_VVCT, 1, 5x"03", x"2040", "Expect PCS control register write");
    mdio_phy_c45_expect_write(MDIO_VVCT, 1, 5x"03", x"2040", "Expect PCS control register write", 1 ms, ERROR, C_SCOPE);

.. _mdio_phy_c45_receive_write_vvc:

mdio_phy_c45_receive_write()
----------------------------------------------------------------------------------------------------------------------------------
Adds a clause 45 receive write command to the MDIO VVC executor queue, which will run as soon as all preceding commands have
completed. When the command is scheduled to run, the executor calls the BFM :ref:`mdio_phy_c45_receive_write_bfm` procedure.

The received data will not be returned in this procedure call since it is non-blocking for the sequencer/caller, but the received
data will be stored in the VVC for a potential future fetch (see example with fetch_result below). If the data_routing is set to
TO_SB, the received data will be sent to the MDIO VVC dedicated scoreboard where it will be checked against the expected value
(provided by the testbench). This procedure can only be called when the MDIO VVC is instantiated in PHY mode, i.e. setting the VVC
entity generic constant 'GC_STA_MODE' to 'false'.

.. code-block::

    mdio_phy_c45_receive_write(VVCT, vvc_instance_idx, dev_addr, [data_routing,] msg, [timeout, [alert_level, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned                     | MMD within this PHY (DEVAD) that the frame must         |
|          |                    |        |                              | address. Normalized to 5 bits.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_routing       | in     | :ref:`t_data_routing`        | Selects the destination of the received data. TO_SB     |
|          |                    |        |                              | sends it to the VVC scoreboard instead of the result    |
|          |                    |        |                              | queue.                                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time to wait for the addressed frame to start.  |
|          |                    |        |                              | Default value is C_UNDEFINED_TIME, which uses           |
|          |                    |        |                              | bfm_config.phy.timeout. 0 ns = no timeout.              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Severity if the addressed frame is not as expected:     |
|          |                    |        |                              | wrong opcode. Default value is ERROR.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_phy_c45_receive_write(MDIO_VVCT, 1, 5x"03", "Receive PCS control register write");
    mdio_phy_c45_receive_write(MDIO_VVCT, 1, 5x"03", TO_SB, "Receive PCS control register write and send to Scoreboard", 1 ms, ERROR, C_SCOPE);

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last receive
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from receive
    ...
    mdio_phy_c45_receive_write(MDIO_VVCT, 1, 5x"03", "Receive PCS control register write");
    v_cmd_idx := get_last_received_cmd_idx(MDIO_VVCT, 1);
    await_completion(MDIO_VVCT, 1, v_cmd_idx, 1 ms, "Wait for receive to finish");
    fetch_result(MDIO_VVCT, 1, v_cmd_idx, v_result, "Fetching result from receive operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.

.. _mdio_phy_c45_reply_read_vvc:

mdio_phy_c45_reply_read()
----------------------------------------------------------------------------------------------------------------------------------
Adds a clause 45 reply read command to the MDIO VVC executor queue, which will run as soon as all preceding commands have
completed. When the command is scheduled to run, the executor calls the BFM :ref:`mdio_phy_c45_reply_read_bfm` procedure. This
procedure can only be called when the MDIO VVC is instantiated in PHY mode, i.e. setting the VVC entity generic constant
'GC_STA_MODE' to 'false'.

.. code-block::

    mdio_phy_c45_reply_read(VVCT, vvc_instance_idx, dev_addr, data, msg, [timeout, [alert_level, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned                     | MMD within this PHY (DEVAD) that the frame must         |
|          |                    |        |                              | address. Normalized to 5 bits.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_ulogic_vector            | The data value returned to the STA. Normalized to 16    |
|          |                    |        |                              | bits.                                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time to wait for the addressed frame to start.  |
|          |                    |        |                              | Default value is C_UNDEFINED_TIME, which uses           |
|          |                    |        |                              | bfm_config.phy.timeout. 0 ns = no timeout.              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Severity if the addressed frame is not as expected:     |
|          |                    |        |                              | wrong opcode. Default value is ERROR.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_phy_c45_reply_read(MDIO_VVCT, 1, 5x"03", x"2040", "Reply PCS control register");
    mdio_phy_c45_reply_read(MDIO_VVCT, 1, 5x"03", x"2040", "Reply PCS control register", 1 ms, ERROR, C_SCOPE);

.. _mdio_phy_c45_reply_post_read_increment_vvc:

mdio_phy_c45_reply_post_read_increment()
----------------------------------------------------------------------------------------------------------------------------------
Adds a clause 45 reply post-read-increment command to the MDIO VVC executor queue, which will run as soon as all preceding
commands have completed. When the command is scheduled to run, the executor calls the BFM
:ref:`mdio_phy_c45_reply_post_read_increment_bfm` procedure. This procedure can only be called when the MDIO VVC is instantiated
in PHY mode, i.e. setting the VVC entity generic constant 'GC_STA_MODE' to 'false'.

.. code-block::

    mdio_phy_c45_reply_post_read_increment(VVCT, vvc_instance_idx, dev_addr, data, msg, [timeout, [alert_level, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | dev_addr           | in     | unsigned                     | MMD within this PHY (DEVAD) that the frame must         |
|          |                    |        |                              | address. Normalized to 5 bits.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data               | in     | std_ulogic_vector            | The data value returned to the STA. Normalized to 16    |
|          |                    |        |                              | bits.                                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | Maximum time to wait for the addressed frame to start.  |
|          |                    |        |                              | Default value is C_UNDEFINED_TIME, which uses           |
|          |                    |        |                              | bfm_config.phy.timeout. 0 ns = no timeout.              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Severity if the addressed frame is not as expected:     |
|          |                    |        |                              | wrong opcode. Default value is ERROR.                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert            |
|          |                    |        |                              | originates. Default value is C_VVC_CMD_SCOPE_DEFAULT    |
|          |                    |        |                              | defined in adaptations_pkg.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    mdio_phy_c45_reply_post_read_increment(MDIO_VVCT, 1, 5x"03", x"2040", "Reply PCS register, increment");
    mdio_phy_c45_reply_post_read_increment(MDIO_VVCT, 1, 5x"03", x"2040", "Reply PCS register, increment", 1 ms, ERROR, C_SCOPE);


Activity Watchdog
==================================================================================================================================
.. include:: rst_snippets/vip_activity_watchdog.rst


Transaction Info
==================================================================================================================================
.. include:: rst_snippets/vip_transaction_info.rst

.. table:: MDIO transaction info record fields. Transaction Type: t_base_transaction (BT) - accessible via **shared_mdio_vvc_transaction_info.bt**

    +------------------------------+----------------------------------+----------------------+------------------------------------------------+
    | Info field                   | Type                             | Default              | Description                                    |
    +==============================+==================================+======================+================================================+
    | operation                    | t_operation                      | NO_OPERATION         | Current VVC operation, e.g. INSERT_DELAY,      |
    |                              |                                  |                      | STA_C22_READ, PHY_C45_REPLY_READ               |
    +------------------------------+----------------------------------+----------------------+------------------------------------------------+
    | data                         | std_ulogic_vector(15 downto 0)   | 0x0                  | Data written / expected, or read / received    |
    |                              |                                  |                      | (on COMPLETED)                                 |
    +------------------------------+----------------------------------+----------------------+------------------------------------------------+
    | dev_addr                     | unsigned(4 downto 0)             | 0x0                  | DEVAD of a clause 45 access                    |
    +------------------------------+----------------------------------+----------------------+------------------------------------------------+
    | phy_addr                     | unsigned(4 downto 0)             | 0x0                  | PHYAD / PRTAD (STA operations)                 |
    +------------------------------+----------------------------------+----------------------+------------------------------------------------+
    | reg_addr                     | unsigned(15 downto 0)            | 0x0                  | Register address. PHY_C45_RECEIVE_ADDRESS: the |
    |                              |                                  |                      | received address (on COMPLETED)                |
    +------------------------------+----------------------------------+----------------------+------------------------------------------------+
    | vvc_meta                     | t_vvc_meta                       | C_VVC_META_DEFAULT   | VVC meta data of the executing VVC command     |
    +------------------------------+----------------------------------+----------------------+------------------------------------------------+
    |  -> msg                      | string                           | ""                   | Message of executing VVC command               |
    +------------------------------+----------------------------------+----------------------+------------------------------------------------+
    |  -> cmd_idx                  | integer                          | -1                   | Command index of executing VVC command         |
    +------------------------------+----------------------------------+----------------------+------------------------------------------------+
    | transaction_status           | :ref:`t_transaction_status`      | INACTIVE             | Set to INACTIVE, IN_PROGRESS or COMPLETED      |
    |                              |                                  |                      | during a transaction                           |
    +------------------------------+----------------------------------+----------------------+------------------------------------------------+

More information can be found in :ref:`Essential Mechanisms - Distribution of Transaction Info <vvc_framework_transaction_info>`.


.. _mdio_vvc_scoreboard:

Scoreboard
==================================================================================================================================
This VVC has built in Scoreboard functionality where data can be routed by setting the TO_SB parameter in supported method calls,
i.e. mdio_sta_c22_read() or mdio_phy_c22_receive_write(). Note that the data is only stored in the scoreboard and not accessible
with the fetch_result() method when the TO_SB parameter is applied. The MDIO scoreboard is accessible from the testbench as a
shared variable ``mdio_vvc_sb``, located in the vvc_methods_pkg.vhd, e.g. ::

    mdio_vvc_sb.add_expected(C_MDIO_VVC_IDX, pad_mdio_sb(v_expected), "Adding expected");
    mdio_sta_c22_read(MDIO_VVCT, C_MDIO_VVC_IDX, 5x"01", 5x"01", TO_SB, "Read status register");
    ...
    mdio_vvc_sb.report_counters(ALL_INSTANCES);

The MDIO scoreboard is per default a 16 bits wide standard logic vector. When sending expected data to the scoreboard, where the
data width is smaller than the default scoreboard width, we recommend zero-padding the data with the pad_mdio_sb() function, e.g. ::

    mdio_vvc_sb.add_expected(<MDIO VVC instance number>, pad_mdio_sb(<exp data>));

pad_mdio_sb() is located in vvc_sb_support_pkg, which is not part of the MDIO vvc_context. It must be made visible in the
testbench in addition to the context, e.g. ::

    library p2l2_vip_mdio;
    context p2l2_vip_mdio.vvc_context;
    use p2l2_vip_mdio.vvc_sb_support_pkg.all;

A command that ends without data (terminated, timed out or wrong opcode, all reported by the BFM) sends nothing to the
scoreboard and is logged with ID_DATA, the expected entry stays pending.

See the :ref:`vip_scoreboard` for a complete list of available commands and additional information. All of the listed Generic
Scoreboard commands are available for the MDIO VVC scoreboard using the ``mdio_vvc_sb``.


.. _vvc_mdio_unwanted_activity:

Unwanted Activity Detection
==================================================================================================================================
.. include:: rst_snippets/vip_unwanted_activity.rst

.. code-block::

    shared_mdio_vvc_config(C_VVC_INDEX).unwanted_activity_severity := NO_ALERT;

* STA mode: any change of mdio while the VVC is inactive is reported, except changes that keep the logic level (e.g. 'H' to
  '1').
* PHY mode: a valid frame to this PHY address that no PHY command was waiting for is reported. With the default
  sync_to_frame_start, a command must be waiting from the first preamble bit to catch the frame.
* Several PHY VVCs on one address (e.g. one VVC per MMD) report each other's frames: set unwanted_activity_severity to
  NO_ALERT on these VVCs.

For MDIO VVC, the unwanted activity detection is enabled by default with severity ERROR.

More information can be found in :ref:`Essential Mechanisms - Unwanted Activity Detection <vvc_framework_unwanted_activity>`.


.. _vvc_mdio_bus_timing_check:

Bus Timing Checker
==================================================================================================================================
Every VVC runs a bus timing property checker (see :ref:`vvc_framework_property_checkers`) that follows the frames on the bus and
checks every bit time with :ref:`mdio_check_bit_timing_bfm`. Each mode checks the other side of the bus: PHY mode checks MDC and
the bits driven by the STA, STA mode checks the bits driven by a PHY. Frames with an undefined ST/OP combination are not followed.

The checker is configured with vvc_config.bus_timing_checker and enabled with severity ERROR by default, e.g. ::

    shared_mdio_vvc_config(C_VVC_INDEX).bus_timing_checker.enable      := false;
    shared_mdio_vvc_config(C_VVC_INDEX).bus_timing_checker.alert_level := WARNING;


Compilation
==================================================================================================================================
The MDIO VVC must be compiled with VHDL-2008 or newer. It is dependent on the following libraries:

    * UVVM Utility Library (UVVM-Util)
    * UVVM VVC Framework
    * Bitvis VIP Scoreboard
    * MDIO BFM

Before compiling the MDIO VVC, assure that uvvm_util, uvvm_vvc_framework and bitvis_vip_scoreboard have been compiled.

See :ref:`Essential Mechanisms - Compile Scripts <vvc_framework_compile_scripts>` for information about compile scripts.

.. table:: Compile order for the MDIO VVC

    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | Compile to library           | File                                           | Comment                                         |
    +==============================+================================================+=================================================+
    | p2l2_vip_mdio                | mdio_bfm_pkg.vhd                               | MDIO BFM                                        |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | p2l2_vip_mdio                | transaction_pkg.vhd                            | MDIO transaction package with DTT types,        |
    |                              |                                                | constants, etc.                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | p2l2_vip_mdio                | vvc_cmd_pkg.vhd                                | MDIO VVC command types and operations           |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | p2l2_vip_mdio                | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC target support package, compiled into  |
    |                              | _target_support_pkg.vhd                        | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | p2l2_vip_mdio                | ../uvvm_vvc_framework/src_target_dependent/td\ | Common UVVM framework methods compiled into     |
    |                              | _vvc_framework_common_methods_pkg.vhd          | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | p2l2_vip_mdio                | vvc_sb_pkg.vhd                                 | MDIO VVC scoreboard (vvc_sb_pkg) and            |
    |                              |                                                | pad_mdio_sb() (vvc_sb_support_pkg)              |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | p2l2_vip_mdio                | vvc_methods_pkg.vhd                            | MDIO VVC methods                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | p2l2_vip_mdio                | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM queue package for this VVC                 |
    |                              | _queue_pkg.vhd                                 |                                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | p2l2_vip_mdio                | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC entity support compiled into this      |
    |                              | _vvc_entity_support_pkg.vhd                    | VVC library                                     |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | p2l2_vip_mdio                | mdio_vvc.vhd                                   | MDIO VVC                                        |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | p2l2_vip_mdio                | vvc_context.vhd                                | MDIO VVC context file                           |
    +------------------------------+------------------------------------------------+-------------------------------------------------+

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


Additional Documentation
==================================================================================================================================
For additional documentation on the MDIO protocol, please see :ref:`mdio_additional_doc`.

.. important::

    * This VIP implements the MDIO management interface of IEEE 802.3, clause 22 and clause 45, for the STA and the PHY.
    * This VIP is not a complete MDIO protocol checker, only the listed checks are made.

.. include:: rst_snippets/ip_disclaimer.rst
