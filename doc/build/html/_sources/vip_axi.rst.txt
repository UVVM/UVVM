##################################################################################################################################
Bitvis VIP AXI4
##################################################################################################################################

**Quick Access**

* `BFM`_

  * :ref:`axi_write_bfm`
  * :ref:`axi_read_bfm`
  * :ref:`axi_check_bfm`
  * :ref:`init_axi_if_signals_bfm`

* `VVC`_

  * :ref:`axi_write_vvc`
  * :ref:`axi_read_vvc`
  * :ref:`axi_check_vvc`


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
BFM
**********************************************************************************************************************************
BFM functionality is implemented in axi_bfm_pkg.vhd

.. _t_axi_if:

Signal Record
==================================================================================================================================
**t_axi_if**

+-------------------------+-------------------------------------+
| Record element          | Type                                |
+=========================+=====================================+
| write_address_channel   | `t_axi_write_address_channel`_      |
+-------------------------+-------------------------------------+
| write_data_channel      | `t_axi_write_data_channel`_         |
+-------------------------+-------------------------------------+
| write_response_channel  | `t_axi_write_response_channel`_     |
+-------------------------+-------------------------------------+
| read_address_channel    | `t_axi_read_address_channel`_       |
+-------------------------+-------------------------------------+
| read_data_channel       | `t_axi_read_data_channel`_          |
+-------------------------+-------------------------------------+

.. note::

    * For more information on the AXI4 signals, refer to "AMBA® AXI™ and ACE™ Protocol Specification", Part A (ARM IHI 0022G) 
      available from ARM.

.. _t_axi_bfm_config:

Configuration Record
==================================================================================================================================
**t_axi_bfm_config**

Default value for the record is C_AXI_BFM_CONFIG_DEFAULT.

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| general_severity             | :ref:`t_alert_level`         | ERROR           | Severity level for various checks of expected   |
|                              |                              |                 | behavior in AXI4 transactions                   |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| max_wait_cycles              | natural                      | 1000            | The maximum number of clock cycles to wait for  |
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


.. _axi_write_bfm:

axi_write()
----------------------------------------------------------------------------------------------------------------------------------
Writes the given data to the given address of the DUT, using the AXI4 protocol. For protocol details, see the AXI4 specification.

The procedure reports an alert if:

  * wready does not occur within max_wait_cycles clock cycles (alert level: max_wait_cycles_severity, set in the config)
  * awready does not occur within max_wait_cycles clock cycles (alert level: max_wait_cycles_severity, set in the config)
  * bvalid is not set within max_wait_cycles clock cycles (alert level: max_wait_cycles_severity, set in the config)

.. code-block::

    axi_write(awid_value, awaddr_value, awlen_value, awsize_value, awburst_value, awlock_value, awcache_value, awprot_value, 
              awqos_value, awregion_value, awuser_value, wdata_value, wstrb_value, wuser_value, buser_value, bresp_value, msg, clk, 
              axi_if, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | awid_value         | in     | std_logic_vector             | Identification tag for a write transaction. Default     |
|          |                    |        |                              | value is 0x0.                                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awaddr_value       | in     | unsigned                     | The address of the first transfer in a write transaction|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awlen_value        | in     | unsigned(7 downto 0)         | The number of data transfers in a write transaction     |
|          |                    |        |                              | transaction. Default value is 0x0.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awsize_value       | in     | integer                      | The number of bytes in each data transfer in a write    |
|          |                    |        |                              | transaction (must be a power of 2). Default value is 4. |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awburst_value      | in     | `t_axburst`_                 | Burst type, indicates how address changes between each  |
|          |                    |        |                              | transfer in a write transaction. Default value is INCR. |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awlock_value       | in     | `t_axlock`_                  | Provides information about the atomic characteristics of|
|          |                    |        |                              | a write transaction. Default value is NORMAL.           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awcache_value      | in     | std_logic_vector(3 downto 0) | Indicates how a write transaction is required to        |
|          |                    |        |                              | progress through a system. Default value is 0x0.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awprot_value       | in     | `t_axprot`_                  | Protection attributes of a write transaction. Privilege,|
|          |                    |        |                              | security level and access type. Default value is        |
|          |                    |        |                              | UNPRIVILEGED_NONSECURE_DATA.                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awqos_value        | in     | std_logic_vector(3 downto 0) | Quality of Service identifier for a write transaction.  |
|          |                    |        |                              | Default value is 0x0.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awregion_value     | in     | std_logic_vector(3 downto 0) | Region indicator for a write transaction. Default value |
|          |                    |        |                              | is 0x0.                                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awuser_value       | in     | std_logic_vector             | User-defined extension for the write address channel.   |
|          |                    |        |                              | Default value is 0x0.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | wdata_value        | in     | t_slv_array                  | Array of data values to be written to the addressed     |
|          |                    |        |                              | registers                                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | wstrb_value        | in     | t_slv_array                  | Array of write strobes, indicates which byte lanes hold |
|          |                    |        |                              | valid data (all '1' means all bytes are updated).       |
|          |                    |        |                              | Default value is C_EMPTY_SLV_ARRAY.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | wuser_value        | in     | t_slv_array                  | Array of user-defined extension for the write data      |
|          |                    |        |                              | channel. Default value is C_EMPTY_SLV_ARRAY.            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | buser_value        | out    | std_logic_vector             | Output variable containing the user-defined extension   |
|          |                    |        |                              | for the write response channel                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | bresp_value        | out    | `t_xresp`_                   | Output variable containing the write response which     |
|          |                    |        |                              | indicates the status of a write transaction             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the AXI4 BFM                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | axi_if             | inout  | :ref:`t_axi_if <t_axi_if>`   | AXI4 signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AXI_BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_axi_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_axi_bfm_config>`          | value is C_AXI_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    axi_write(
      awid_value     => x"01",
      awaddr_value   => x"00000004",
      awlen_value    => x"01",
      awsize_value   => 4,
      awburst_value  => INCR,
      awlock_value   => NORMAL,
      awcache_value  => "0000",
      awprot_value   => UNPRIVILEGED_NONSECURE_DATA,
      awqos_value    => "0000",
      awregion_value => "0000",
      awuser_value   => x"01",
      wdata_value    => t_slv_array'(x"12345678", x"33333333"),
      wstrb_value    => t_slv_array'(x"F", x"F"),
      wuser_value    => t_slv_array'(x"01", x"01"),
      buser_value    => v_buser_value,
      bresp_value    => v_bresp_value,
      msg            => "Writing data to Peripheral 1",
      clk            => clk,
      axi_if         => axi_if,
      scope          => C_SCOPE,
      msg_id_panel   => shared_msg_id_panel,
      config         => C_AXI_BFM_CONFIG_DEFAULT);

    axi_write(
      awaddr_value   => x"00000004",
      wdata_value    => t_slv_array'(x"12345678", x"33333333"),
      buser_value    => v_buser_value,
      bresp_value    => v_bresp_value,
      msg            => "Writing data to Peripheral 1");

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    axi_write(C_ADDR_DMA, x"AAAA", "Writing data to DMA");
    axi_write(C_ADDR_MEMORY, x"FF", v_data_array, "Writing 256 data words to MEMORY");


.. _axi_read_bfm:

axi_read()
----------------------------------------------------------------------------------------------------------------------------------
Reads data from the DUT at the given address, using the AXI4 protocol. For protocol details, see the AXI4 specification. The read 
data is placed on the output 'rdata_value' when the read has completed.

The procedure reports an alert if:

  * The received rid is different from the transmitted arid_value
  * arready does not occur within max_wait_cycles clock cycles (alert level: max_wait_cycles_severity, set in the config)
  * rvalid is not set within max_wait_cycles clock cycles (alert level: max_wait_cycles_severity, set in the config)

.. code-block::

    axi_read(arid_value, araddr_value, arlen_value, arsize_value, arburst_value, arlock_value, arcache_value, arprot_value, arqos_value, 
             arregion_value, aruser_value, rdata_value, rresp_value, ruser_value, msg, clk, axi_if, [scope, [msg_id_panel, [config]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | arid_value         | in     | std_logic_vector             | Identification tag for a read transaction. Default      |
|          |                    |        |                              | value is 0x0.                                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | araddr_value       | in     | unsigned                     | The address of the first transfer in a read transaction |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arlen_value        | in     | unsigned(7 downto 0)         | The number of data transfers in a read transaction      |
|          |                    |        |                              | transaction. Default value is 0x0.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arsize_value       | in     | integer                      | The number of bytes in each data transfer in a read     |
|          |                    |        |                              | transaction (must be a power of 2). Default value is 4. |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arburst_value      | in     | `t_axburst`_                 | Burst type, indicates how address changes between each  |
|          |                    |        |                              | transfer in a read transaction. Default value is INCR.  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arlock_value       | in     | `t_axlock`_                  | Provides information about the atomic characteristics of|
|          |                    |        |                              | a read transaction. Default value is NORMAL.            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arcache_value      | in     | std_logic_vector(3 downto 0) | Indicates how a read transaction is required to         |
|          |                    |        |                              | progress through a system. Default value is 0x0.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arprot_value       | in     | `t_axprot`_                  | Protection attributes of a read transaction. Privilege, |
|          |                    |        |                              | security level and access type. Default value is        |
|          |                    |        |                              | UNPRIVILEGED_NONSECURE_DATA.                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arqos_value        | in     | std_logic_vector(3 downto 0) | Quality of Service identifier for a read transaction.   |
|          |                    |        |                              | Default value is 0x0.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arregion_value     | in     | std_logic_vector(3 downto 0) | Region indicator for a read transaction. Default value  |
|          |                    |        |                              | is 0x0.                                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | aruser_value       | in     | std_logic_vector             | User-defined extension for the read address channel.    |
|          |                    |        |                              | Default value is 0x0.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | rdata_value        | out    | t_slv_array                  | Output variable containing an array of read data        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | rresp_value        | out    | `t_xresp_array`_             | Output variable containing an array of read responses   |
|          |                    |        |                              | which indicates the status of a read transfer           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| variable | ruser_value        | out    | t_slv_array                  | Output variable containing an array of user-defined     |
|          |                    |        |                              | extensions for the read data channel                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the AXI4 BFM                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | axi_if             | inout  | :ref:`t_axi_if <t_axi_if>`   | AXI4 signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AXI_BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_axi_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_axi_bfm_config>`          | value is C_AXI_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    axi_read(
      arid_value     => x"01",
      araddr_value   => x"00000004",
      arlen_value    => x"01",
      arsize_value   => 4,
      arburst_value  => INCR,
      arlock_value   => NORMAL,
      arcache_value  => "0000",
      arprot_value   => UNPRIVILEGED_NONSECURE_DATA,
      arqos_value    => "0000",
      arregion_value => "0000",
      aruser_value   => x"01",
      rdata_value    => v_rdata_value,
      rresp_value    => v_rresp_value,
      ruser_value    => v_ruser_value,
      msg            => "Read from Peripheral 1",
      clk            => clk,
      axi_if         => axi_if,
      scope          => C_SCOPE,
      msg_id_panel   => shared_msg_id_panel,
      config         => C_AXI_BFM_CONFIG_DEFAULT);

    axi_read(
      araddr_value   => x"00000004",
      rdata_value    => v_rdata_value,
      rresp_value    => v_rresp_value,
      ruser_value    => v_ruser_value,
      msg            => "Read from Peripheral 1",
      clk            => clk,
      axi_if         => axi_if);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    axi_read(C_ADDR_IO, v_data_out, "Reading from IO device");
    axi_read(C_ADDR_MEMORY, x"FF", v_data_array_out, "Reading 256 data words from MEMORY");


.. _axi_check_bfm:

axi_check()
----------------------------------------------------------------------------------------------------------------------------------
Reads data from the DUT at the given address, using the AXI4 protocol. For protocol details, see the AXI4 specification. After 
reading data from the AXI4 bus, the read data is compared with the expected data, and if they don't match, an alert with severity 
'alert_level' is reported. The procedure also report alerts for the same conditions as the :ref:`axi_read_bfm` procedure.

.. code-block::

    axi_check(arid_value, araddr_value, arlen_value, arsize_value, arburst_value, arlock_value, arcache_value, arprot_value, arqos_value, 
              arregion_value, aruser_value, rdata_exp, rresp_exp, ruser_exp, msg, clk, axi_if, [alert_level, [scope, [msg_id_panel, [config]]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | arid_value         | in     | std_logic_vector             | Identification tag for a read transaction. Default      |
|          |                    |        |                              | value is 0x0.                                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | araddr_value       | in     | unsigned                     | The address of the first transfer in a read transaction |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arlen_value        | in     | unsigned(7 downto 0)         | The number of data transfers in a read transaction      |
|          |                    |        |                              | transaction. Default value is 0x0.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arsize_value       | in     | integer                      | The number of bytes in each data transfer in a read     |
|          |                    |        |                              | transaction (must be a power of 2). Default value is 4. |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arburst_value      | in     | `t_axburst`_                 | Burst type, indicates how address changes between each  |
|          |                    |        |                              | transfer in a read transaction. Default value is INCR.  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arlock_value       | in     | `t_axlock`_                  | Provides information about the atomic characteristics of|
|          |                    |        |                              | a read transaction. Default value is NORMAL.            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arcache_value      | in     | std_logic_vector(3 downto 0) | Indicates how a read transaction is required to         |
|          |                    |        |                              | progress through a system. Default value is 0x0.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arprot_value       | in     | `t_axprot`_                  | Protection attributes of a read transaction. Privilege, |
|          |                    |        |                              | security level and access type. Default value is        |
|          |                    |        |                              | UNPRIVILEGED_NONSECURE_DATA.                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arqos_value        | in     | std_logic_vector(3 downto 0) | Quality of Service identifier for a read transaction.   |
|          |                    |        |                              | Default value is 0x0.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arregion_value     | in     | std_logic_vector(3 downto 0) | Region indicator for a read transaction. Default value  |
|          |                    |        |                              | is 0x0.                                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | aruser_value       | in     | std_logic_vector             | User-defined extension for the read address channel.    |
|          |                    |        |                              | Default value is 0x0.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | rdata_exp          | in     | t_slv_array                  | Array of expected read data values. A mismatch results  |
|          |                    |        |                              | in an alert 'alert_level'                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | rresp_exp          | in     | `t_xresp_array`_             | Array of expected read responses which indicates the    |
|          |                    |        |                              | status of a read transfer. Default value is OKAY for    |
|          |                    |        |                              | all words.                                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | ruser_exp          | in     | t_slv_array                  | Array of expected user-defined extensions for the read  |
|          |                    |        |                              | data channel. Default value is 0x0 for all words.       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | clk                | in     | std_logic                    | The clock signal used to read and write data in/out of  |
|          |                    |        |                              | the AXI4 BFM                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| signal   | axi_if             | inout  | :ref:`t_axi_if <t_axi_if>`   | AXI4 signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert. Default value is       |
|          |                    |        |                              | C_AXI_BFM_CONFIG_DEFAULT.general_severity.              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_BFM_SCOPE ("AXI_BFM").               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | config             | in     | :ref:`t_axi_bfm_config       | Configuration of BFM behavior and restrictions. Default |
|          |                    |        | <t_axi_bfm_config>`          | value is C_AXI_BFM_CONFIG_DEFAULT.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    axi_check(
      arid_value     => x"01",
      araddr_value   => x"00000004",
      arlen_value    => x"01",
      arsize_value   => 4,
      arburst_value  => INCR,
      arlock_value   => NORMAL,
      arcache_value  => "0000",
      arprot_value   => UNPRIVILEGED_NONSECURE_DATA,
      arqos_value    => "0000",
      arregion_value => "0000",
      aruser_value   => x"01",
      rdata_exp      => t_slv_array'(x"12345678", x"33333333"),
      rresp_exp      => t_xresp_array'(OKAY, OKAY),
      ruser_exp      => t_slv_array'(x"00", x"00"),
      msg            => "Check data from Peripheral 1",
      clk            => clk,
      axi_if         => axi_if,
      alert_level    => ERROR,
      scope          => C_SCOPE,
      msg_id_panel   => shared_msg_id_panel,
      config         => C_AXI_BFM_CONFIG_DEFAULT);

    axi_check(
      araddr_value   => x"00000004",
      rdata_exp      => v_rdata_exp,
      msg            => "Check data from Peripheral 1",
      clk            => clk,
      axi_if         => axi_if);

    -- Suggested usage (requires local overload, see 'Local BFM overloads' section):
    axi_check(C_ADDR_UART_RX, x"3B", "Checking data in UART RX register");
    axi_check(C_ADDR_MEMORY, x"FF", v_rdata_exp_array, "Checking 256 data words from MEMORY");


.. _init_axi_if_signals_bfm:

init_axi_if_signals()
----------------------------------------------------------------------------------------------------------------------------------
Initializes the AXI4 interface. All the BFM outputs are set to '0', and BFM inputs are set to 'Z'. This function assumes that awid, 
bid, arid and rid shares a common width (id_width) and that awuser, buser, aruser, ruser also share a common width (user_width).


.. code-block::

    t_axi_if := init_axi_if_signals(addr_width, data_width, id_width, user_width)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | addr_width         | in     | natural                      | Width of the address signals                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | data_width         | in     | natural                      | Width of the data signals                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | id_width           | in     | natural                      | Width of the id signals                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | user_width         | in     | natural                      | Width of the user signals                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    axi_if <= init_axi_if_signals(addr_width, data_width, id_width, user_width);


Local types
==================================================================================================================================

t_axi_write_address_channel
----------------------------------------------------------------------------------------------------------------------------------

+-------------------------+------------------------------+
| Record element          | Type                         |
+=========================+==============================+
| awid                    | std_logic_vector             |
+-------------------------+------------------------------+
| awaddr                  | std_logic_vector             |
+-------------------------+------------------------------+
| awlen                   | std_logic_vector(7 downto 0) |
+-------------------------+------------------------------+
| awsize                  | std_logic_vector(2 downto 0) |
+-------------------------+------------------------------+
| awburst                 | std_logic_vector(1 downto 0) |
+-------------------------+------------------------------+
| awlock                  | std_logic                    |
+-------------------------+------------------------------+
| awcache                 | std_logic_vector(3 downto 0) |
+-------------------------+------------------------------+
| awprot                  | std_logic_vector(2 downto 0) |
+-------------------------+------------------------------+
| awqos                   | std_logic_vector(3 downto 0) |
+-------------------------+------------------------------+
| awregion                | std_logic_vector(3 downto 0) |
+-------------------------+------------------------------+
| awuser                  | std_logic_vector             |
+-------------------------+------------------------------+
| awvalid                 | std_logic                    |
+-------------------------+------------------------------+
| awready                 | std_logic                    |
+-------------------------+------------------------------+

t_axi_write_data_channel
----------------------------------------------------------------------------------------------------------------------------------

+-------------------------+------------------------------+
| Record element          | Type                         |
+=========================+==============================+
| wdata                   | std_logic_vector             |
+-------------------------+------------------------------+
| wstrb                   | std_logic_vector             |
+-------------------------+------------------------------+
| wlast                   | std_logic                    |
+-------------------------+------------------------------+
| wuser                   | std_logic_vector             |
+-------------------------+------------------------------+
| wvalid                  | std_logic                    |
+-------------------------+------------------------------+
| wready                  | std_logic                    |
+-------------------------+------------------------------+

t_axi_write_response_channel
----------------------------------------------------------------------------------------------------------------------------------

+-------------------------+------------------------------+
| Record element          | Type                         |
+=========================+==============================+
| bid                     | std_logic_vector             |
+-------------------------+------------------------------+
| bresp                   | std_logic_vector(1 downto 0) |
+-------------------------+------------------------------+
| buser                   | std_logic_vector             |
+-------------------------+------------------------------+
| bvalid                  | std_logic                    |
+-------------------------+------------------------------+
| bready                  | std_logic                    |
+-------------------------+------------------------------+

t_axi_read_address_channel
----------------------------------------------------------------------------------------------------------------------------------

+-------------------------+------------------------------+
| Record element          | Type                         |
+=========================+==============================+
| arid                    | std_logic_vector             |
+-------------------------+------------------------------+
| araddr                  | std_logic_vector             |
+-------------------------+------------------------------+
| arlen                   | std_logic_vector(7 downto 0) |
+-------------------------+------------------------------+
| arsize                  | std_logic_vector(2 downto 0) |
+-------------------------+------------------------------+
| arburst                 | std_logic_vector(1 downto 0) |
+-------------------------+------------------------------+
| arlock                  | std_logic                    |
+-------------------------+------------------------------+
| arcache                 | std_logic_vector(3 downto 0) |
+-------------------------+------------------------------+
| arprot                  | std_logic_vector(2 downto 0) |
+-------------------------+------------------------------+
| arqos                   | std_logic_vector(3 downto 0) |
+-------------------------+------------------------------+
| arregion                | std_logic_vector(3 downto 0) |
+-------------------------+------------------------------+
| aruser                  | std_logic_vector             |
+-------------------------+------------------------------+
| arvalid                 | std_logic                    |
+-------------------------+------------------------------+
| arready                 | std_logic                    |
+-------------------------+------------------------------+

t_axi_read_data_channel
----------------------------------------------------------------------------------------------------------------------------------

+-------------------------+------------------------------+
| Record element          | Type                         |
+=========================+==============================+
| rid                     | std_logic_vector             |
+-------------------------+------------------------------+
| rdata                   | std_logic_vector             |
+-------------------------+------------------------------+
| rresp                   | std_logic_vector(1 downto 0) |
+-------------------------+------------------------------+
| rlast                   | std_logic                    |
+-------------------------+------------------------------+
| ruser                   | std_logic_vector             |
+-------------------------+------------------------------+
| rvalid                  | std_logic                    |
+-------------------------+------------------------------+
| rready                  | std_logic                    |
+-------------------------+------------------------------+

t_axburst
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    FIXED, INCR, WRAP

t_axlock
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    NORMAL, EXCLUSIVE

t_axprot
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    UNPRIVILEGED_NONSECURE_DATA, UNPRIVILEGED_NONSECURE_INSTRUCTION, UNPRIVILEGED_SECURE_DATA, UNPRIVILEGED_SECURE_INSTRUCTION, 
    PRIVILEGED_NONSECURE_DATA, PRIVILEGED_NONSECURE_INSTRUCTION, PRIVILEGED_SECURE_DATA, PRIVILEGED_SECURE_INSTRUCTION

t_xresp
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    OKAY, EXOKAY, SLVERR, DECERR, ILLEGAL

.. _t_xresp_array:

t_xresp_array
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    array (natural range <>) of t_xresp;


Local BFM overloads
==================================================================================================================================
A good approach for better readability and maintainability is to make simple, local overloads for the BFM procedures in the TB 
process. This allows calling the BFM procedures with the key parameters only, e.g. ::

    axi_write(C_ADDR_PERIPHERAL_1, C_TEST_DATA, "Sending data to Peripheral 1");

rather than ::

    axi_write(
      awid_value     => x"01",
      awaddr_value   => x"00000004",
      awlen_value    => x"01",
      awsize_value   => 4,
      awburst_value  => INCR,
      awlock_value   => NORMAL,
      awcache_value  => "0000",
      awprot_value   => UNPRIVILEGED_NONSECURE_DATA,
      awqos_value    => "0000",
      awregion_value => "0000",
      awuser_value   => x"01",
      wdata_value    => t_slv_array'(x"12345678", x"33333333"),
      wstrb_value    => t_slv_array'(x"F", x"F"),
      wuser_value    => t_slv_array'(x"01", x"01"),
      buser_value    => v_buser_value,
      bresp_value    => v_bresp_value,
      msg            => "Writing data to Peripheral 1",
      clk            => clk,
      axi_if         => axi_if,
      scope          => C_SCOPE,
      msg_id_panel   => shared_msg_id_panel,
      config         => C_AXI_BFM_CONFIG_DEFAULT);

By defining the local overload as e.g. ::

    procedure axi_write(
      constant addr_value   : in unsigned;           
      constant data_value   : in std_logic_vector;
      constant msg          : in string
    ) is
      variable v_buser_value : std_logic_vector(C_USER_WIDTH - 1 downto 0);
      variable v_bresp_value : t_xresp;
    begin
      axi_write(
        awid_value     => x"00",                       -- Setting a default value
        awaddr_value   => addr_value,                  -- Keep as is
        awlen_value    => x"00",                       -- Set to length=1
        awsize_value   => 4,                           -- Setting a default value
        awburst_value  => INCR,                        -- Setting a default value
        awlock_value   => NORMAL,                      -- Setting a default value
        awcache_value  => "0000",                      -- Setting a default value
        awprot_value   => UNPRIVILEGED_NONSECURE_DATA, -- Setting a default value
        awqos_value    => "0000",                      -- Setting a default value
        awregion_value => "0000",                      -- Setting a default value
        awuser_value   => x"01",                       -- Setting a default value
        wdata_value    => data_value,                  -- Keep as is
        wstrb_value    => x"f"                         -- Setting a default value
        wuser_value    => x"01",                       -- Setting a default value
        buser_value    => v_buser_value,               -- Assigning to a local variable
        bresp_value    => v_bresp_value,               -- Assigning to a local variable
        msg            => msg,                         -- Keep as is
        clk            => clk,                         -- Signal must be visible in local process scope
        axi_if         => axi_if,                      -- Signal must be visible in local process scope
        scope          => C_SCOPE,                     -- Setting a default value
        msg_id_panel   => shared_msg_id_panel,         -- Use global, shared msg_id_panel
        config         => C_AXI_BFM_CONFIG_LOCAL);     -- Use locally defined configuration or C_AXI_BFM_CONFIG_DEFAULT
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
For more information on the AXI4 specification, refer to "AMBA® AXI™ and ACE™ Protocol Specification", Part A (ARM IHI 0022G), 
available from ARM.

.. important::

    * This is a simplified Bus Functional Model (BFM) for AXI4.
    * The given BFM complies with the basic AXI4 protocol and thus allows a normal access towards an AXI4 interface.
    * This BFM is not an AXI4 protocol checker.
    * For a more advanced BFM please contact UVVM support at info@uvvm.org


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
VVC
**********************************************************************************************************************************
* VVC functionality is implemented in axi_vvc.vhd
* For general information see :ref:`VVC Framework - Essential Mechanisms <vvc_framework_essential_mechanisms>`.

Entity
==================================================================================================================================

Generics
----------------------------------------------------------------------------------------------------------------------------------

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Name                         | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| GC_ADDR_WIDTH                | integer                      | 8               | Width of the AXI4 address bus (AWADDR, ARADDR)  |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_DATA_WIDTH                | integer                      | 32              | Width of the AXI4 data bus (WDATA, RDATA). The  |
|                              |                              |                 | write strobe (WSTRB) is derived from this       |
|                              |                              |                 | (GC_DATA_WIDTH/8)                               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_ID_WIDTH                  | integer                      | 8               | Width of the AXI4 ID signals (AWID, BID, ARID,  |
|                              |                              |                 | RID)                                            |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_USER_WIDTH                | integer                      | 8               | Width of the AXI4 User signals (AWUSER, WUSER,  |
|                              |                              |                 | BUSER, ARUSER, RUSER)                           |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_INSTANCE_IDX              | natural                      | 1               | Instance number to assign the VVC               |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_AXI_CONFIG                | :ref:`t_axi_bfm_config       | C_AXI_BFM_CONFI\| Configuration for the AXI4 BFM                  |
|                              | <t_axi_bfm_config>`          | G_DEFAULT       |                                                 |
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
| signal   | axi_vvc_master_if  | inout  | :ref:`t_axi_if <t_axi_if>`   | AXI4 signal interface record                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

In this VVC, the interface has been encapsulated in a signal record of type t_axi_if in order to improve readability of the code. 
Since the AXI4 interface buses can be of arbitrary size, the interface vectors have been left unconstrained. These unconstrained 
vectors need to be constrained when the interface signals are instantiated. For this interface, it could look like: ::

    signal axi_if : t_axi_if(write_address_channel(awid  (C_ID_WIDTH      -1 downto 0),
                                                   awaddr(C_ADDR_WIDTH    -1 downto 0),
                                                   awuser(C_USER_WIDTH    -1 downto 0)),
                             write_data_channel   (wdata (C_DATA_WIDTH    -1 downto 0),
                                                   wstrb ((C_DATA_WIDTH/8)-1 downto 0),
                                                   wuser (C_USER_WIDTH    -1 downto 0)),
                             write_response_channel(bid  (C_ID_WIDTH      -1 downto 0),
                                                    buser(C_USER_WIDTH    -1 downto 0)),
                             read_address_channel (arid  (C_ID_WIDTH      -1 downto 0),
                                                   araddr(C_ADDR_WIDTH    -1 downto 0),
                                                   aruser(C_USER_WIDTH    -1 downto 0)),
                             read_data_channel    (rid   (C_ID_WIDTH      -1 downto 0),
                                                   rdata (C_DATA_WIDTH    -1 downto 0),
                                                   ruser (C_USER_WIDTH    -1 downto 0)));


Configuration Record
==================================================================================================================================
**vvc_config** accessible via **shared_axi_vvc_config**

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| inter_bfm_delay              | :ref:`t_inter_bfm_delay`     | C_AXI_INTER_BFM\| Delay between any requested BFM accesses        |
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
| bfm_config                   | :ref:`t_axi_bfm_config       | C_AXI_BFM_CONFI\| Configuration for the AXI4 BFM                  |
|                              | <t_axi_bfm_config>`          | G_DEFAULT       |                                                 |
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

    shared_axi_vvc_config(C_VVC_IDX).inter_bfm_delay.delay_in_time := 50 ns;
    shared_axi_vvc_config(C_VVC_IDX).bfm_config.clock_period := 10 ns;

Status Record
==================================================================================================================================
**vvc_status** accessible via **shared_axi_vvc_status**

.. include:: rst_snippets/vip_vvc_status.rst

Methods
==================================================================================================================================
* All VVC procedures are defined in vvc_methods_pkg.vhd (dedicated to this VVC).
* See :ref:`vvc_framework_methods` for procedures which are common to all VVCs.
* It is also possible to send a multicast to all instances of a VVC with ALL_INSTANCES as parameter for vvc_instance_idx.
* All parameters in brackets are optional.


.. _axi_write_vvc:

axi_write()
----------------------------------------------------------------------------------------------------------------------------------
Adds a write command to the AXI4 VVC executor queue, which will distribute this command to the various channel executors which in 
turn will run as soon as all preceding commands have completed. When the command is scheduled to run, the executors call the AXI4 
procedures in axi_channel_handler_pkg.vhd. This procedure can be called with or without parameters that already have a default value.

.. code-block::

    axi_write(VVCT, vvc_instance_idx, awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awregion, awuser, wdata, 
              wstrb, wuser, bresp_exp, buser_exp, msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awid               | in     | std_logic_vector             | Identification tag for a write transaction. Default     |
|          |                    |        |                              | value is 0x0.                                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awaddr             | in     | unsigned                     | The address of the first transfer in a write transaction|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awlen              | in     | unsigned(7 downto 0)         | The number of data transfers in a write transaction     |
|          |                    |        |                              | transaction. Default value is 0x0.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awsize             | in     | integer                      | The number of bytes in each data transfer in a write    |
|          |                    |        |                              | transaction (must be a power of 2). Default value is 4. |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awburst            | in     | `t_axburst`_                 | Burst type, indicates how address changes between each  |
|          |                    |        |                              | transfer in a write transaction. Default value is INCR. |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awlock             | in     | `t_axlock`_                  | Provides information about the atomic characteristics of|
|          |                    |        |                              | a write transaction. Default value is NORMAL.           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awcache            | in     | std_logic_vector(3 downto 0) | Indicates how a write transaction is required to        |
|          |                    |        |                              | progress through a system. Default value is 0x0.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awprot             | in     | `t_axprot`_                  | Protection attributes of a write transaction. Privilege,|
|          |                    |        |                              | security level and access type. Default value is        |
|          |                    |        |                              | UNPRIVILEGED_NONSECURE_DATA.                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awqos              | in     | std_logic_vector(3 downto 0) | Quality of Service identifier for a write transaction.  |
|          |                    |        |                              | Default value is 0x0.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awregion           | in     | std_logic_vector(3 downto 0) | Region indicator for a write transaction. Default value |
|          |                    |        |                              | is 0x0.                                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | awuser             | in     | std_logic_vector             | User-defined extension for the write address channel.   |
|          |                    |        |                              | Default value is 0x0.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | wdata              | in     | t_slv_array                  | Array of data values to be written to the addressed     |
|          |                    |        |                              | registers                                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | wstrb              | in     | t_slv_array                  | Array of write strobes, indicates which byte lanes hold |
|          |                    |        |                              | valid data (all '1' means all bytes are updated).       |
|          |                    |        |                              | Default value is C_EMPTY_SLV_ARRAY.                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | wuser              | in     | t_slv_array                  | Array of user-defined extension for the write data      |
|          |                    |        |                              | channel. Default value is C_EMPTY_SLV_ARRAY.            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | bresp_exp          | in     | `t_xresp`_                   | Expected write response which indicates the status of a |
|          |                    |        |                              | write transaction. Default value is OKAY.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | buser_exp          | in     | std_logic_vector             | Expected user-defined extension for the write response  |
|          |                    |        |                              | channel. Default value is 0x0.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_VVC_CMD_SCOPE_DEFAULT.               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    axi_write(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 0,
      awid             => x"01", 
      awaddr           => x"00000004",
      awlen            => x"01",
      awsize           => 4,
      awburst          => INCR,
      awlock           => NORMAL,
      awcache          => "0000",
      awprot           => UNPRIVILEGED_NONSECURE_DATA,
      awqos            => "0000",
      awregion         => "0000",
      awuser           => x"01",
      wdata            => t_slv_array'(x"12345678", x"33333333"),
      wstrb            => t_slv_array'(x"F", x"F"),
      wuser            => t_slv_array'(x"01", x"01"),
      bresp_exp        => OKAY,
      buser_exp        => x"00",
      msg              => "Writing data to Peripheral 1");

    axi_write(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 0,
      awaddr           => x"00000004",
      wdata            => t_slv_array'(x"12345678", x"33333333"),
      msg              => "Writing data to Peripheral 1");


.. _axi_read_vvc:

axi_read()
----------------------------------------------------------------------------------------------------------------------------------
Adds a read command to the AXI4 VVC executor queue, which will distribute this command to the various channel executors which in 
turn will run as soon as all preceding commands have completed. When the command is scheduled to run, the executors call the AXI4 
procedures in axi_channel_handler_pkg.vhd.

The value read from the DUT will not be returned in this procedure call since it is non-blocking for the sequencer/caller. If the 
data_routing parameter is set to TO_BUFFER, the read data will be stored in the VVC for a potential future fetch (see example with 
fetch_result below). If the data_routing parameter is set to TO_SB, the received data will be sent to the AXI4 VVC dedicated 
scoreboard where it will be checked against the expected value (provided by the testbench).

.. code-block::

    axi_read(VVCT, vvc_instance_idx, arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, arregion, aruser, data_routing, msg, [scope])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arid               | in     | std_logic_vector             | Identification tag for a read transaction. Default      |
|          |                    |        |                              | value is 0x0.                                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | araddr             | in     | unsigned                     | The address of the first transfer in a read transaction |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arlen              | in     | unsigned(7 downto 0)         | The number of data transfers in a read transaction      |
|          |                    |        |                              | transaction. Default value is 0x0.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arsize             | in     | integer                      | The number of bytes in each data transfer in a read     |
|          |                    |        |                              | transaction (must be a power of 2). Default value is 4. |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arburst            | in     | `t_axburst`_                 | Burst type, indicates how address changes between each  |
|          |                    |        |                              | transfer in a read transaction. Default value is INCR.  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arlock             | in     | `t_axlock`_                  | Provides information about the atomic characteristics of|
|          |                    |        |                              | a read transaction. Default value is NORMAL.            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arcache            | in     | std_logic_vector(3 downto 0) | Indicates how a read transaction is required to         |
|          |                    |        |                              | progress through a system. Default value is 0x0.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arprot             | in     | `t_axprot`_                  | Protection attributes of a read transaction. Privilege, |
|          |                    |        |                              | security level and access type. Default value is        |
|          |                    |        |                              | UNPRIVILEGED_NONSECURE_DATA.                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arqos              | in     | std_logic_vector(3 downto 0) | Quality of Service identifier for a read transaction.   |
|          |                    |        |                              | Default value is 0x0.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arregion           | in     | std_logic_vector(3 downto 0) | Region indicator for a read transaction. Default value  |
|          |                    |        |                              | is 0x0.                                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | aruser             | in     | std_logic_vector             | User-defined extension for the read address channel.    |
|          |                    |        |                              | Default value is 0x0.                                   |
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
    axi_read(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 0,
      arid             => x"01",
      araddr           => x"00000004",
      arlen            => x"01",
      arsize           => 4,
      arburst          => INCR,
      arlock           => NORMAL,
      arcache          => "0000",
      arprot           => UNPRIVILEGED_UNSECURE_DATA,
      arqos            => "0000",
      arregion         => "0000",
      aruser           => x"01",
      data_routing     => TO_SB,
      msg              => "Read from Peripheral 1 and send result to scoreboard");

    axi_read(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 0,
      araddr           => x"00000004",
      data_routing     => TO_BUFFER,
      msg              => "Read from Peripheral 1 and send result to read buffer");

    -- Example with fetch_result() call: Result is placed in v_result
    variable v_cmd_idx : natural;                       -- Command index for the last read
    variable v_result  : work.vvc_cmd_pkg.t_vvc_result; -- Result from read.
    ...
    axi_read(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 0,
      araddr           => x"00000004",
      data_routing     => TO_BUFFER,
      msg              => "Read from Peripheral 1 and send result to read buffer");
    v_cmd_idx := get_last_received_cmd_idx(AXI_VVCT, 0);
    await_completion(AXI_VVCT, 0, v_cmd_idx, 100 ns, "Wait for read to finish");
    fetch_result(AXI_VVCT, 0, v_cmd_idx, v_result, "Fetching result from read operation");

.. hint::

    :ref:`t_vvc_result` is defined in the corresponding vvc_cmd_pkg.vhd for the VIP.


.. _axi_check_vvc:

axi_check()
----------------------------------------------------------------------------------------------------------------------------------
Adds a check command to the AXI4 VVC executor queue, which will distribute this command to the various channel executors which in 
turn will run as soon as all preceding commands have completed. When the command is scheduled to run, the executors call the AXI4 
procedures in axi_channel_handler_pkg.vhd. The axi_check() procedure will perform a read operation, then check if the read result 
is equal to the rdata_exp, rresp_exp and ruser_exp parameters. If the result is not equal to the expected result, an alert with 
severity 'alert_level' will be issued. The read data will not be stored by this procedure.

.. code-block::

    axi_check(VVCT, vvc_instance_idx, arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, arregion, aruser, rdata_exp, 
              rresp_exp, ruser_exp, msg, [alert_level, [scope]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| signal   | VVCT               | inout  | t_vvc_target_record          | VVC target type compiled into each VVC in order to      |
|          |                    |        |                              | differentiate between VVCs                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | vvc_instance_idx   | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arid               | in     | std_logic_vector             | Identification tag for a read transaction. Default      |
|          |                    |        |                              | value is 0x0.                                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | araddr             | in     | unsigned                     | The address of the first transfer in a read transaction |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arlen              | in     | unsigned(7 downto 0)         | The number of data transfers in a read transaction      |
|          |                    |        |                              | transaction. Default value is 0x0.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arsize             | in     | integer                      | The number of bytes in each data transfer in a read     |
|          |                    |        |                              | transaction (must be a power of 2). Default value is 4. |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arburst            | in     | `t_axburst`_                 | Burst type, indicates how address changes between each  |
|          |                    |        |                              | transfer in a read transaction. Default value is INCR.  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arlock             | in     | `t_axlock`_                  | Provides information about the atomic characteristics of|
|          |                    |        |                              | a read transaction. Default value is NORMAL.            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arcache            | in     | std_logic_vector(3 downto 0) | Indicates how a read transaction is required to         |
|          |                    |        |                              | progress through a system. Default value is 0x0.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arprot             | in     | `t_axprot`_                  | Protection attributes of a read transaction. Privilege, |
|          |                    |        |                              | security level and access type. Default value is        |
|          |                    |        |                              | UNPRIVILEGED_NONSECURE_DATA.                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arqos              | in     | std_logic_vector(3 downto 0) | Quality of Service identifier for a read transaction.   |
|          |                    |        |                              | Default value is 0x0.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | arregion           | in     | std_logic_vector(3 downto 0) | Region indicator for a read transaction. Default value  |
|          |                    |        |                              | is 0x0.                                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | aruser             | in     | std_logic_vector             | User-defined extension for the read address channel.    |
|          |                    |        |                              | Default value is 0x0.                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | rdata_exp          | in     | t_slv_array                  | Array of expected read data values. A mismatch results  |
|          |                    |        |                              | in an alert 'alert_level'                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | rresp_exp          | in     | `t_xresp_array`_             | Array of expected read responses which indicates the    |
|          |                    |        |                              | status of a read transfer. Default value is OKAY for    |
|          |                    |        |                              | all words.                                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | ruser_exp          | in     | t_slv_array                  | Array of expected user-defined extensions for the read  |
|          |                    |        |                              | data channel. Default value is 0x0 for all words.       |
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
    axi_check(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 0,
      arid             => x"01",
      araddr           => x"00000004",
      arlen            => x"01",
      arsize           => 4,
      arburst          => INCR,
      arlock           => NORMAL,
      arcache          => "0000",
      arprot           => UNPRIVILEGED_UNSECURE_DATA,
      arqos            => "0000",
      arregion         => "0000",
      aruser           => x"01",
      rdata_exp        => t_slv_array'(x"12345678", x"33333333"),
      rresp_exp        => t_xresp_array'(OKAY, OKAY),
      ruser_exp        => t_slv_array'(x"00", x"00"),
      msg              => "Check data from Peripheral 1");

    axi_check(
      VVCT             => AXI_VVCT,
      vvc_instance_idx => 0,
      araddr           => x"00000004",
      rdata_exp        => t_slv_array'(x"12345678", x"33333333"),
      msg              => "Check data from Peripheral 1");


Activity Watchdog
==================================================================================================================================
.. include:: rst_snippets/vip_activity_watchdog.rst


Transaction Info
==================================================================================================================================
.. include:: rst_snippets/vip_transaction_info.rst

.. table:: AXI4 transaction info record fields. Transaction Type: t_base_transaction (BT) - accessible via **shared_axi_vvc_transaction_info.bt_wr** and
           **shared_axi_vvc_transaction_info.bt_rd**

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

.. table:: AXI4 transaction info record fields. Transaction type: t_arw_transaction (ST) - accessible via **shared_axi_vvc_transaction_info.st_aw** and
           **shared_axi_vvc_transaction_info.st_ar**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | arwid                        | std_logic_vector(31 downto 0)| 0x0             | Identification tag for a read or write          |
    |                              |                              |                 | transaction                                     |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | arwaddr                      | unsigned(31 downto 0)        | 0x0             | The address for a read or write transaction     |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | arwlen                       | unsigned(7 downto 0)         | 0x0             | Burst length for a read or write transaction    |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | arwsize                      | integer                      | 4               | Burst size for a read or write transaction      |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | arwburst                     | `t_axburst`_                 | INCR            | Burst type for a read or write transaction      |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | arwlock                      | `t_axlock`_                  | NORMAL          | Lock value for a read or write transaction      |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | arwcache                     | std_logic_vector(3 downto 0) | 0x0             | Cache value for a read or write transaction     |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | arwprot                      | `t_axprot`_                  | UNPRIVILEGED_NO\| Protection value for a read or write transaction|
    |                              |                              | NSECURE_DATA    |                                                 |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | arwqos                       | std_logic_vector(3 downto 0) | 0x0             | QoS value for a read or write transaction       |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | arwregion                    | std_logic_vector(3 downto 0) | 0x0             | Region value for a read or write transaction    |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | arwuser                      | std_logic_vector(127 downto  | 0x0             | User value for a read or write transaction      |
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

.. table:: AXI4 transaction info record fields. Transaction type: t_w_transaction (ST) - accessible via **shared_axi_vvc_transaction_info.st_w**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | wdata                        | t_slv_array(0 to 255)(255 do\| 0x0             | Write data                                      |
    |                              | wnto 0)                      |                 |                                                 |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | wstrb                        | t_slv_array(0 to 255)(31 dow\| 0x0             | Write strobe                                    |
    |                              | nto 0)                       |                 |                                                 |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | wuser                        | t_slv_array(0 to 255)(127 do\| 0x0             | User value                                      |
    |                              | wnto 0)                      |                 |                                                 |
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

.. table:: AXI4 transaction info record fields. Transaction type: t_b_transaction (ST) - accessible via **shared_axi_vvc_transaction_info.st_b**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | bid                          | std_logic_vector(31 downto 0)| 0x0             | Identification tag                              |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | bresp                        | `t_xresp`_                   | OKAY            | Write response                                  |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | buser                        | std_logic_vector(127 downto  | 0x0             | User value for write response channel           |
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

.. table:: AXI4 transaction info record fields. Transaction type: t_r_transaction (ST) - accessible via **shared_axi_vvc_transaction_info.st_r**

    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | Info field                   | Type                         | Default         | Description                                     |
    +==============================+==============================+=================+=================================================+
    | operation                    | t_operation                  | NO_OPERATION    | Current VVC operation, e.g. INSERT_DELAY,       |
    |                              |                              |                 | POLL_UNTIL, READ, WRITE                         |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | rid                          | std_logic_vector(31 downto 0)| 0x0             | Identification tag for read data channel        |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | rdata                        | t_slv_array(0 to 255)(255 do\| 0x0             | Read data array                                 |
    |                              | wnto 0)                      |                 |                                                 |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | rresp                        | :ref:`t_xresp_array(0 to 255)| OKAY            | Read response array                             |
    |                              | <t_xresp_array>`             |                 |                                                 |
    +------------------------------+------------------------------+-----------------+-------------------------------------------------+
    | ruser                        | t_slv_array(0 to 255)(127 do\| 0x0             | Read user extension array                       |
    |                              | wnto 0)                      |                 |                                                 |
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
i.e. axi_read(). Note that the data is only stored in the scoreboard and not accessible with the fetch_result() method when the 
TO_SB parameter is applied. The AXI4 scoreboard is accessible from the testbench as a shared variable AXI_VVC_SB, located in the 
vvc_methods_pkg.vhd, e.g. ::

    AXI_VVC_SB.add_expected(C_AXI_VVC_IDX, v_expected, "Adding expected");

The AXI4 scoreboard is per default the maximum width of rid, rdata, rresp and ruser. When sending expected result to the scoreboard, 
where the result width is smaller than the default scoreboard width, we recommend zero-padding the data.

See the :ref:`vip_scoreboard` for a complete list of available commands and additional information. All of the listed Generic
Scoreboard commands are available for the AXI4 VVC scoreboard using the AXI_VVC_SB.


Unwanted Activity Detection
==================================================================================================================================
.. include:: rst_snippets/vip_unwanted_activity.rst

.. code-block::

    shared_axi_vvc_config(C_VVC_INDEX).unwanted_activity_severity := NO_ALERT;

Note that the ready signals (awready, wready, arready) are not monitored in this VVC. The ready signals are allowed to be set 
independently of the valid signals (awvalid, wvalid, arvalid), and there is no method to differentiate between the unwanted activity 
and intended activity. See the AXI4 protocol specification for more information. 

The unwanted activity detection is ignored when the valid signals (bvalid, rvalid) go low within one clock period after the VVC 
becomes inactive. This is to handle the situation when the read command exits before the next rising edge, causing signal transitions 
during the first clock cycle after the VVC is inactive. 

For AXI4 VVC, the unwanted activity detection is enabled by default with severity ERROR.

More information can be found in :ref:`Essential Mechanisms - Unwanted Activity Detection <vvc_framework_unwanted_activity>`.


Compilation
==================================================================================================================================
The AXI4 VVC must be compiled with VHDL-2008 or newer. It is dependent on the following libraries:

    * UVVM Utility Library (UVVM-Util)
    * UVVM VVC Framework
    * Bitvis VIP Scoreboard
    * AXI4 BFM

Before compiling the AXI4 VVC, assure that uvvm_util, uvvm_vvc_framework and bitvis_vip_scoreboard have been compiled.

See :ref:`Essential Mechanisms - Compile Scripts <vvc_framework_compile_scripts>` for information about compile scripts.

.. table:: Compile order for the AXI4 VVC

    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | Compile to library           | File                                           | Comment                                         |
    +==============================+================================================+=================================================+
    | bitvis_vip_axi               | axi_bfm_pkg.vhd                                | AXI4 BFM                                        |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axi               | transaction_pkg.vhd                            | AXI4 transaction package with DTT types,        |
    |                              |                                                | constants, etc.                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axi               | vvc_cmd_pkg.vhd                                | AXI4 VVC command types and operations           |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axi               | axi_read_data_queue_pkg.vhd                    | Package for storing read data responses in a    |
    |                              |                                                | queue to support out-of-order read data         |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axi               | axi_channel_handler_pkg.vhd                    | Package containing procedures for accessing AXI4|
    |                              |                                                | channels. Only for use by the VVC.              |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axi               | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC target support package, compiled into  |
    |                              | _target_support_pkg.vhd                        | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axi               | ../uvvm_vvc_framework/src_target_dependent/td\ | Common UVVM framework methods compiled into the |
    |                              | _vvc_framework_common_methods_pkg.vhd          | this VVC library                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axi               | vvc_sb_pkg.vhd                                 | AXI4 VVC scoreboard                             |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axi               | vvc_methods_pkg.vhd                            | AXI4 VVC methods                                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axi               | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM queue package for this VVC                 |
    |                              | _queue_pkg.vhd                                 |                                                 |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axi               | ../uvvm_vvc_framework/src_target_dependent/td\ | UVVM VVC entity support compiled into this      |
    |                              | _vvc_entity_support_pkg.vhd                    | VVC library                                     |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axi               | axi_vvc.vhd                                    | AXI4 VVC                                        |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_axi               | vvc_context.vhd                                | AXI4 VVC context file                           |
    +------------------------------+------------------------------------------------+-------------------------------------------------+

Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


Additional Documentation
==================================================================================================================================
For more information on the AXI4 specification, refer to "AMBA® AXI™ and ACE™ Protocol Specification", Part A (ARM IHI 0022G), 
available from ARM.

.. important::

    * This is a simplified Verification IP (VIP) for AXI4.
    * The given VIP complies with the basic AXI4 protocol and thus allows a normal access towards an AXI4 interface.
    * This VIP is not an AXI4 protocol checker.
    * For a more advanced VIP please contact UVVM support at info@uvvm.org

.. include:: rst_snippets/ip_disclaimer.rst
