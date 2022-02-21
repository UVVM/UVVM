##################################################################################################################################
Bitvis VIP SBI
##################################################################################################################################

**********************************************************************************************************************************
BFM
**********************************************************************************************************************************
All functionality is defined in sbi_bfm_pkg.vhd

.. _t_sbi_if:

Signal Record
==================================================================================================================================
**t_sbi_if**

+-------------------------+------------------------------+
| Record element          | Type                         |
+=========================+==============================+
| cs                      | std_logic                    |
+-------------------------+------------------------------+
| addr                    | unsigned                     |
+-------------------------+------------------------------+
| wena                    | std_logic                    |
+-------------------------+------------------------------+
| rena                    | std_logic                    |
+-------------------------+------------------------------+
| wdata                   | std_logic_vector             |
+-------------------------+------------------------------+
| ready                   | std_logic                    |
+-------------------------+------------------------------+
| rdata                   | std_logic_vector             |
+-------------------------+------------------------------+

.. note::

    BFM calls can also be made with listing of single signals rather than t_sbi_if.

.. _t_sbi_bfm_config:

Configuration Record
==================================================================================================================================
**t_sbi_bfm_config**

Default value for the record is C_SBI_BFM_CONFIG_DEFAULT.

+------------------------------+------------------------------+---------------------+---------------------------------------------+
| Record element               | Type                         | Default             | Description                                 |
+==============================+==============================+=====================+=============================================+
| max_wait_cycles              | integer                      | 10                  | The maximum number of clock cycles to wait  |
|                              |                              |                     | for the DUT ready signal before reporting a |
|                              |                              |                     | timeout alert                               |
+------------------------------+------------------------------+---------------------+---------------------------------------------+
| max_wait_cycles_severity     | :ref:`t_alert_level`         | FAILURE             | The above timeout will have this severity   |
+------------------------------+------------------------------+---------------------+---------------------------------------------+
| use_fixed_wait_cycles_read   | boolean                      | false               | When true, wait 'fixed_wait_cycles_read'    |
|                              |                              |                     | after asserting rena signal, before sampling|
|                              |                              |                     | rdata                                       |
+------------------------------+------------------------------+---------------------+---------------------------------------------+
| fixed_wait_cycles_read       | natural                      | 0                   | Number of clock cycles to wait after        |
|                              |                              |                     | asserting rena signal, before sampling rdata|
+------------------------------+------------------------------+---------------------+---------------------------------------------+
| clock_period                 | time                         | -1 ns               | Period of the clock signal                  |
+------------------------------+------------------------------+---------------------+---------------------------------------------+
| clock_period_margin          | time                         | 0 ns                | Input clock period margin to specified      |
|                              |                              |                     | clock_period. Will check 'T/2' if input     |
|                              |                              |                     | clock is low when BFM is called and 'T' if  |
|                              |                              |                     | input clock is high.                        |
+------------------------------+------------------------------+---------------------+---------------------------------------------+
| clock_margin_severity        | :ref:`t_alert_level`         | TB_ERROR            | The above margin will have this severity    |
+------------------------------+------------------------------+---------------------+---------------------------------------------+
| setup_time                   | time                         | -1 ns               | Generated signals setup time. Suggested     |
|                              |                              |                     | value is clock_period/4. An alert is        |
|                              |                              |                     | reported if setup_time exceeds              |
|                              |                              |                     | clock_period/2.                             |
+------------------------------+------------------------------+---------------------+---------------------------------------------+
| hold_time                    | time                         | -1 ns               | Generated signals hold time. Suggested value|
|                              |                              |                     | is clock_period/4. An alert is reported if  |
|                              |                              |                     | hold_time exceeds clock_period/2.           |
+------------------------------+------------------------------+---------------------+---------------------------------------------+
| bfm_sync                     | :ref:`t_bfm_sync`            | SYNC_ON_CLOCK_ONLY  | | When set to SYNC_ON_CLOCK_ONLY the BFM    |
|                              |                              |                     |   will enter on the first falling edge,     |
|                              |                              |                     |   estimate the clock period, synchronise the|
|                              |                              |                     |   output signals and exit ¼ clock period    |
|                              |                              |                     |   after a succeeding rising edge.           |
|                              |                              |                     | | When set to SYNC_WITH_SETUP_AND_HOLD the  |
|                              |                              |                     |   BFM will use the configured setup_time,   |
|                              |                              |                     |   hold_time and clock_period to synchronise |
|                              |                              |                     |   output signals with clock edges.          |
+------------------------------+------------------------------+---------------------+---------------------------------------------+
| match_strictness             | :ref:`t_match_strictness`    | MATCH_EXACT         | | Matching strictness for std_logic values  |
|                              |                              |                     |   in check procedures.                      |
|                              |                              |                     | | MATCH_EXACT requires both values to be the|
|                              |                              |                     |   same. Note that the expected value can    |
|                              |                              |                     |   contain the don’t care operator '-'.      |
|                              |                              |                     | | MATCH_STD allows comparisons between 'H'  |
|                              |                              |                     |   and '1', 'L' and '0' and '-' in both      |
|                              |                              |                     |   values.                                   |
+------------------------------+------------------------------+---------------------+---------------------------------------------+
| id_for_bfm                   | t_msg_id                     | ID_BFM              | Message ID used for logging general messages|
|                              |                              |                     | in the BFM                                  |
+------------------------------+------------------------------+---------------------+---------------------------------------------+
| id_for_bfm_wait              | t_msg_id                     | ID_BFM_WAIT         | Message ID used for logging waits in the BFM|
+------------------------------+------------------------------+---------------------+---------------------------------------------+
| id_for_bfm_poll              | t_msg_id                     | ID_BFM_POLL         | Message ID used for logging polling in the  |
|                              |                              |                     | BFM                                         |
+------------------------------+------------------------------+---------------------+---------------------------------------------+
| use_ready_signal             | boolean                      | true                | Whether or not to use the interface 'ready' |
|                              |                              |                     | signal                                      |
+------------------------------+------------------------------+---------------------+---------------------------------------------+

Methods
==================================================================================================================================
* The record :ref:`t_sbi_if <t_sbi_if>` can be replaced with the signals listed in said record.
* All signals are active high.
* All parameters in brackets are optional.


sbi_write()
----------------------------------------------------------------------------------------------------------------------------------
Writes the given data to the given address on the DUT, using the SBI protocol:

.. code-block:: none

    1 - At 'config.clock_period'/4 before the first rising clock edge the bus lines are set:
        a. cs and wena are set to '1'
        b. rena is set to '0'
        c. addr is set to addr_value
        d. wdata is set to data_value
    2 - With ready-signalling:
        a. on the first rising edge the DUT ready signal is evaluated:
            * If ready is '1', cs and wena are set to '0' again 'config.clock_period'/4 after the last rising edge and the write 
              procedure was successful.
            * If ready is '0', the procedure will wait one clock cycle and evaluate the ready signal again. This will repeat until 
              ready is set to '1', or invoke an error if the process has repeated 'config.max_wait_cycles times'. A log message with ID 
              'config.id_for_bfm_wait' is logged at the first wait.
    2 - Without ready-signalling:
        a. cs and wena are set to '0' again 'config.clock_period'/4 after the first rising edge

The procedure reports an alert if ready signal is not set to '1' within 'config.max_wait_cycles' after cs and wena are set to '1' 
(alert_level: config.max_wait_cycles_severity).

.. code-block::

    sbi_write(addr_value, data_value, msg, clk, sbi_if, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | The address of a software accessible register           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | data_value         | out    | std_logic_vector             | The data value to be written to the addressed register  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the SBI BFM                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | sbi_if             | inout  | :ref:`t_sbi_if <t_sbi_if>`   | SBI signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_SCOPE ("SBI BFM").                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_sbi_bfm_config       | Configuration of BFM behaviour and restrictions. Default|
|          |                    |        | <t_sbi_bfm_config>`          | value is C_SBI_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    sbi_write(x"1000", x"55", "Write data to Peripheral 1", clk, sbi_if);
    sbi_write(x"1000", x"55", "Write data to Peripheral 1", clk, sbi_if, C_SCOPE, shared_msg_id_panel, C_SBI_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    sbi_write(C_ADDR_UART_TX, x"40", "Set baud rate to 9600");


.. _sbi_read:

sbi_read()
----------------------------------------------------------------------------------------------------------------------------------
Reads data from the DUT at the given address, using the SBI protocol:

.. code-block:: none

    1. At 'config.clock_period'/4 before the first rising clock edge the bus lines are set:
        a. cs and rena are set to '1'
        b. wena is set to '0'
        c. addr is set to addr_value
    2. With ready-signalling:
        a. On the first rising edge the DUT ready signal is evaluated:
            * If ready is '1', the data on the rdata line is returned to the reader in data_value.
            * If ready is '0', the procedure will wait one clock cycle and evaluate the ready signal again. This will repeat until 
              ready is set to '1', or invoke an error if the process has repeated 'config.max_wait_cycles' times. A log message with 
              ID 'config.id_for_bfm_wait' is logged at the first wait.
    2. Without ready-signalling:
        a. On the first rising edge the data on the rdata line is returned to the reader in data_value.
    3. After 'config.clock_period'/4 cs and rena are set to '0' again

The procedure reports an alert if ready signal is not set to '1' within 'config.max_wait_cycles' after cs and wena are set to '1' 
(alert_level: config.max_wait_cycles_severity).

.. code-block::

    sbi_read(addr_value, data_value, msg, clk, sbi_if, [scope, [msg_id_panel, [config]]])

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
|          |                    |        |                              | the SBI BFM                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | sbi_if             | inout  | :ref:`t_sbi_if <t_sbi_if>`   | SBI signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_SCOPE ("SBI BFM").                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_sbi_bfm_config       | Configuration of BFM behaviour and restrictions. Default|
|          |                    |        | <t_sbi_bfm_config>`          | value is C_SBI_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    sbi_read(x"1000", v_data_out, "Read from Peripheral 1", clk, sbi_if);
    sbi_read(x"1000", v_data_out, "Read from Peripheral 1", clk, sbi_if, C_SCOPE, shared_msg_id_panel, C_SBI_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    sbi_read(C_ADDR_UART_BAUD, v_data_out, "Read UART baud rate");


sbi_check()
----------------------------------------------------------------------------------------------------------------------------------
Reads data from the DUT at the given address, using the SBI protocol described under :ref:`sbi_read`. After reading data from the 
SBI bus, the read data is compared with the expected data.

* If the check was successful, and the read data matches the expected data, a log message is written with ID 'config.id_for_bfm'.
* If the read data did not match the expected data, an alert with severity 'alert_level' will be reported.
* The procedure will also report alerts for the same conditions as the :ref:`sbi_read` procedure.

.. code-block::

    sbi_check(addr_value, data_exp, msg, clk, sbi_if, [alert_level, [scope, [msg_id_panel, [config]]]])

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
|          |                    |        |                              | the SBI BFM                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | sbi_if             | inout  | :ref:`t_sbi_if <t_sbi_if>`   | SBI signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_SCOPE ("SBI BFM").                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_sbi_bfm_config       | Configuration of BFM behaviour and restrictions. Default|
|          |                    |        | <t_sbi_bfm_config>`          | value is C_SBI_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    sbi_check(x"1155", x"3B", "Check data from Peripheral 1", clk, sbi_if);
    sbi_check(x"1155", x"3B", "Check data from Peripheral 1", clk, sbi_if, ERROR, C_SCOPE, shared_msg_id_panel, C_SBI_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    sbi_check(C_ADDR_UART_RX, x"3B", "Check data from UART RX buffer");


sbi_poll_until()
----------------------------------------------------------------------------------------------------------------------------------
Reads data from the DUT at the given address, using the SBI protocol described under :ref:`sbi_read`. After reading data from the 
DUT, the read data is compared with the expected data. If the read data does not match the expected data, the process is repeated 
until one or more of the following occurs:

#. The read data matches the expected data
#. The number of read retries is equal to 'max_polls'
#. The time between start of sbi_poll_until procedure and now is greater than 'timeout'
#. The terminate_loop signal is set to '1'

If the procedure exits because of 2. or 3. an alert with severity 'alert_level' is issued. If either 'max_polls' or 'timeout' is 
set to 0 (ns), this constraint will be ignored and interpreted as no limit.

* If the check was successful, and the read data matches the expected data, a log message is written with ID 'config.id_for_bfm'.
* If the read data did not match the expected data, an alert with severity 'alert_level' will be reported.
* The procedure will also report alerts for the same conditions as the :ref:`sbi_read` procedure.
* If the procedure is terminated using 'terminate_loop' a log message with ID ID_TERMINATE_CMD will be issued.

.. code-block::

    sbi_poll_until(addr_value, data_exp, max_polls, timeout, msg, clk, sbi_if, terminate_loop, [alert_level, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_value         | in     | unsigned                     | The address of a software accessible register           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_exp           | in     | std_logic_vector             | The data value to expect when reading the addressed     |
|          |                    |        |                              | register. A mismatch results in an alert with severity  |
|          |                    |        |                              | 'alert_level'.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | max_polls          | in     | integer                      | The maximum number of polls (reads) before the expected |
|          |                    |        |                              | data must be found. Exceeding this limit results in an  |
|          |                    |        |                              | alert with severity 'alert_level'.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | timeout            | in     | time                         | The maximum time to pass before the expected data must  |
|          |                    |        |                              | be found. Exceeding this limit results in an alert with |
|          |                    |        |                              | severity 'alert_level'.                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the SBI BFM                                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | sbi_if             | inout  | :ref:`t_sbi_if <t_sbi_if>`   | SBI signal interface record                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | terminate_loop     | in     | std_logic                    | External control of loop termination to e.g. stop       |
|          |                    |        |                              | polling prematurely                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is ERROR.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_SCOPE ("SBI BFM").                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_sbi_bfm_config       | Configuration of BFM behaviour and restrictions. Default|
|          |                    |        | <t_sbi_bfm_config>`          | value is C_SBI_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    sbi_poll_until(x"1155", x"0D", 10, 100 ns, "Poll for data from Peripheral 1", clk, sbi_if, terminate_loop);
    sbi_poll_until(x"1155", x"0D", 10, 100 ns, "Poll for data from Peripheral 1", clk, sbi_if, terminate_loop, ERROR, C_SCOPE, shared_msg_id_panel, C_SBI_BFM_CONFIG_DEFAULT);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    sbi_poll_until(C_ADDR_UART_RX, x"0D", "Poll UART RX buffer until CR is found");
    sbi_poll_until(C_ADDR_UART_RX, x"0D", C_MAX_POLLS, C_TIMEOUT, "Poll UART RX buffer until CR is found");


init_sbi_if_signals()
----------------------------------------------------------------------------------------------------------------------------------
Initializes the SBI interface. All the BFM outputs are set to '0', and BFM inputs are set to 'Z'. ::

    t_sbi_if := init_sbi_if_signals(addr_width, data_width)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_width         | in     | natural                      | Width of the address signal                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_width         | in     | natural                      | Width of the data signals                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    sbi_if <= init_sbi_if_signals(addr_width, data_width)


Additional Documentation
==================================================================================================================================
The SBI BFM is used in the IRQC example provided with the UVVM Utility Library. Thus, you can find info under:

    * Making a simple, structured and efficient VHDL testbench – Step-by-step (PPT)

There is also a webinar available on 'Making a simple, structured and efficient VHDL testbench – Step-by-step' (via Aldec [#f1]_)

SBI protocol
----------------------------------------------------------------------------------------------------------------------------------
SBI is our name for the simplest bus interface possible, one that has been used for decades in the electronics industry. Some 
think of it as a simple SRAM interface, but that is not a standard, and is probably understood and used in many different ways. 
Thus, we have defined a name and an exact behaviour, with some flexibility.

SBI is a single cycle bus with an optional ready-signalling. The protocol for SBI with and without ready-signalling is given below. 
Data is sampled on rising edge **a** and **b**.

.. figure:: images/sbi_protocol_1.png
   :width: 600
   :align: center

.. figure:: images/sbi_protocol_2.png
   :width: 1000
   :align: center

As can be seen from the figure all required signals including data input must be ready on the rising edge of the clock. This also 
applies for a read access, but the actual data output is provided combinatorial as soon as the combinational logic allows.
Note that an active 'cs', a valid 'addr' and an active 'wena' or 'rena' is needed on the same active clock edge to be registered 
as a valid read or write. (Being active on two consecutive rising clocks will result in two consecutive accesses - with or without 
side-effects depending on the module's internal functional logic.) 'rdata' will just ripple out for the right combination of 'cs', 
'addr' and 'rena'.

With this simple version, the designer has the option to provide input and/or output registers externally to allow a higher 
frequency (with added latency). SBI has optional ready-signalling. When 'ready' is used it applies to both read and write accesses. 
For both read and write accesses all input signals must be held until 'ready' is active. For a read access, the output data may 
not be used (sampled) until 'ready' is active, but must do so on the first rising edge of the clock after 'ready' active.

Compilation
==================================================================================================================================
* The SBI BFM may only be compiled with VHDL 2008. It is dependent on the :ref:`utility_library`, which is only compatible with 
  VHDL 2008.
* After UVVM-Util has been compiled, the sbi_bfm_pkg.vhd can be compiled into any desired library.
* See :ref:`vvc_framework_essential_mechanisms` for information about compile scripts.

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
* See :ref:`uvvm_prerequisites` for a list of supported simulators.
* For required simulator setup see :ref:`UVVM-Util Simulator compatibility and setup <util_simulator_compatibility>`.

Local BFM overloads
==================================================================================================================================
A good approach for better readability and maintainability is to make simple, local overloads for the BFM procedures in the TB 
process. This allows calling the BFM procedures with the key parameters only, e.g. ::

    sbi_write(C_ADDR_UART_BAUDRATE, C_BAUDRATE_9600, "Set Baudrate to 9600");

rather than ::

    sbi_write(C_ADDR_UART_BAUDRATE, C_BAUDRATE_9600, "Set Baudrate to 9600", clk, sbi_if, C_CLK_PERIOD, C_SCOPE, shared_msg_id_panel, C_SBI_CONFIG_DEFAULT);

By defining the local overload as e.g. ::

    procedure sbi_write(
      constant addr_value : in unsigned;
      constant data_value : in std_logic_vector;
      constant msg        : in string) is
    begin
      sbi_write(addr_value,          -- keep as is
                data_value,          -- keep as is
                msg,                 -- keep as is
                sbi_if,              -- Signal must be visible in local process scope
                C_CLK_PERIOD,        -- Just use the default
                C_SCOPE,             -- Just use the default
                shared_msg_id_panel, -- Use global, shared msg_id_panel
                C_SBI_CONFIG_LOCAL); -- Use locally defined configuration or C_SBI_CONFIG_DEFAULT
    end procedure;

Using a local overload like this also allows the following – if wanted:

* Have address value as natural – and convert in the overload
* Set up defaults for constants. May be different for two overloads of the same BFM
* Apply dedicated message ID panel to allow dedicated verbosity control

.. important::

    * This is a simplified Bus Functional Model (BFM) for SBI.
    * The given BFM complies with the basic SBI protocol and thus allows a normal access towards a SBI interface.
    * This BFM is not a SBI protocol checker.
    * For a more advanced BFM please contact Bitvis AS at support@bitvis.no

***********************************************************************************************************************	     
VVC
***********************************************************************************************************************	     

.. include:: ip_disclaimer.rst

.. rubric:: Footnotes

.. [#f1] https://www.aldec.com/en/support/resources/multimedia/webinars/1673
