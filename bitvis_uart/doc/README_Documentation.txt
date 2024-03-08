Information about documentation for UART
===========================================

The complete documentation for this module is not included - as this module is not a part of the UVVM deliverables.
The design (VHDL source code) and Testbench is delivered with UVVM in order to illustrate the usage and debugging support provided by UVVM.
This is NOT an example of how to implement a UART. This is just a simple test vehicle that can be used to demonstrate the functionality of the UVVM VVC Framework.

See sim/compile_order.txt for compile order of files

Usage of module
===========================================
The module is interfaced through SBI. For additional info on SBI see UVVM/bitvis_vip_sbi/doc.

The following generic constants are used when instantiating the module:
+------------------------------+-----------+---------------+-------------------------------------------------------+
| Name                         | Type      | Default value | Description                                           |
+==============================+===========+===============+=======================================================+
| GC_START_BIT                 | std_logic | '0'           | Value of start bit                                    |
+------------------------------+-----------+---------------+-------------------------------------------------------+
| GC_STOP_BIT                  | std_logic | '1'           | Value of stop bit                                     |
+------------------------------+-----------+---------------+-------------------------------------------------------+
| GC_CLOCKS_PER_BIT            | integer   | 16            | Number of clock periods per bit period                |
+------------------------------+-----------+---------------+-------------------------------------------------------+
| GC_MIN_EQUAL_SAMPLES_PER_BIT | integer   | 15            | Minimum number of equal samples needed for valid bit. |
|                              |           |               | The module samples on every clock                     |
+------------------------------+-----------+---------------+-------------------------------------------------------+

The following registers are available for usage of the module:
+---------------+-----+------------------------------+---------+-----------------------------------+
| Name          | R/W | Type                         | Address | Description                       |
+===============+=====+==============================+=========+===================================+
| RX_DATA       | RO  | std_logic_vector(7 downto 0) | 0       | Rx data                           |
+---------------+-----+------------------------------+---------+-----------------------------------+
| RX_DATA_VALID | RO  | std_logic                    | 1       | Rx data valid                     |
+---------------+-----+------------------------------+---------+-----------------------------------+
| TX_DATA       | WO  | std_logic_vector(7 downto 0) | 2       | Tx data                           |
+---------------+-----+------------------------------+---------+-----------------------------------+
| TX_DATA_READY | RO  | std_logic                    | 3       | Tx data ready                     |
+---------------+-----+------------------------------+---------+-----------------------------------+
| NUM_DATA_BITS | RW  | positive range 7 to 8        | 4       | Number of data bits in UART frame |
+---------------+-----+------------------------------+---------+-----------------------------------+