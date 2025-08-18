.. _vip_error_injection:

##################################################################################################################################
Bitvis VIP Error Injection
##################################################################################################################################

**********************************************************************************************************************************
Entity
**********************************************************************************************************************************
The Error Injection VIP consists of two VHDL entities - a std_logic entity (error_injection_sl.vhd) and a std_logic_vector entity 
(error_injection_slv.vhd), and is used for inducing non protocol-dependent errors on single and vector signals.

Generics
==================================================================================================================================

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Name                         | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| GC_START_TIME                | time                         | 0 ns            | The error injector will wait the specified      |
|                              |                              |                 | time after initialization before starting to    |
|                              |                              |                 | monitor signal events, and injecting error if   |
|                              |                              |                 | configured to.                                  |
|                              |                              |                 |                                                 |
|                              |                              |                 | Note that default is 0 ns, i.e. not waiting     |
|                              |                              |                 | after initialization.                           |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_INSTANCE_IDX              | natural                      | 1               | Instance number to assign the error injector    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

Instantiation
==================================================================================================================================
* The Error Injection VIP can be used as a single instance or with multiple instances and can be used with std_logic 
  (error_injection_sl entity) or vector (error_injection_slv entity).
* The default error injector behavior is in BYPASS mode, i.e. without any error injected to the signal.
* The error injection is controlled using a dedicated shared variable array, shared_ei_config(index), of type 
  :ref:`t_error_injection_config <ei_configuration_record>`, where each error injector has its own dedicated array index.
* The error injection is disabled and set to bypass mode by setting the configuration to C_EI_CONFIG_DEFAULT.

The provided example below shows how a typical UART error injection setup could be done, using an error_injection_sl entity for 
the UART RX signal line.

.. figure:: /images/vip_error_injection/example_ei_uart.png
   :alt: Example Error Injection UART
   :width: 700pt
   :align: center

#. Include the error injection package.
#. Define the needed error injection configuration signal(s).
#. Instantiate the error injector(s) needed.
#. Set the error injection configurations.

.. code-block::

    library bitvis_vip_error_injection;
    use bitvis_vip_error_injection.error_injection_pkg.all;

    ...

    constant C_UART_TX_EI : natural := 1; -- Error injection instance index
    signal   uart_tx      : std_logic;
    signal   ei_uart_tx   : std_logic;

    ...

    uart_tx_error_injector: entity bitvis_vip_error_injection.error_injection_sl
    generic map (
      GC_START_TIME    => 10 ns,
      GC_INSTANCE_IDX  => C_UART_TX_EI
    )
    port map (
      ei_in   => uart_tx,
      ei_out  => ei_uart_tx
    );

    ...

    shared_ei_config(C_UART_TX_EI).error_type := DELAY;
    shared_ei_config(C_UART_TX_EI).delay_min  := 2 ns;
    shared_ei_config(C_UART_TX_EI).base_value := '0';

    uart_transmit(UART_VVCT, 1, TX, x"AA", "Transmitting data");

    wait for 10 ns;
    shared_ei_config(C_UART_TX_EI) := C_EI_CONFIG_DEFAULT; -- Set the configuration back to BYPASS when done

For more detailed examples see VHDL example ei_demo_tb.vhd, located in the tb folder.

.. _ei_configuration_record:

**********************************************************************************************************************************
Configuration Record
**********************************************************************************************************************************
Accessible via **shared_ei_config**

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Record element               | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| error_type                   | :ref:`t_error_injection_type\| BYPASS          | Type of error to be injected to signal. No error|
|                              | s <t_error_injection_types>` |                 | is injected when set to BYPASS. (1)             |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| initial_delay_min            | time                         | 0 ns            | Error injection start relative to initial signal|
|                              |                              |                 | event. (1)                                      |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| initial_delay_max            | time                         | 0 ns            | Setting the max parameter will generate a       |
|                              |                              |                 | randomized initial timing parameter. (2)        |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| return_delay_min             | time                         | 0 ns            | Error injection end relative to next signal     |
|                              |                              |                 | event. (1,4)                                    |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| return_delay_max             | time                         | 0 ns            | Setting the max parameter will generate a       |
|                              |                              |                 | randomized return timing parameter. (2,4)       |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| width_min                    | time                         | 0 ns            | The width of an error injected pulse if error   |
|                              |                              |                 | type PULSE is selected                          |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| width_max                    | time                         | 0 ns            | Setting the max parameter will generate a       |
|                              |                              |                 | randomized timing parameter. (2)                |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| interval                     | positive                     | 1               | Errors will be injected in this interval, e.g.  |
|                              |                              |                 | 1 for every signal event, 2 for every second    |
|                              |                              |                 | signal event, etc. (3,5)                        |
|                              |                              |                 |                                                 |
|                              |                              |                 | Interval = 1: SL will experience error          |
|                              |                              |                 | injection on every second signal event, e.g.    |
|                              |                              |                 | every rising edge.                              |
|                              |                              |                 |                                                 |
|                              |                              |                 | SLV will experience error injection on every    |
|                              |                              |                 | signal event.                                   |
|                              |                              |                 |                                                 |
|                              |                              |                 | Interval = 2: SL will experience error          |
|                              |                              |                 | injection on every fourth signal event, e.g.    |
|                              |                              |                 | every second rising edge.                       |
|                              |                              |                 |                                                 |
|                              |                              |                 | SLV will experience error injection on every    |
|                              |                              |                 | second signal event.                            |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| base_value                   | std_logic                    | '0'             | The initial edge in an SL error injection will  |
|                              |                              |                 | start on the transition from base_value to      |
|                              |                              |                 | another value, e.g. from '0' to '1'.            |
|                              |                              |                 |                                                 |
|                              |                              |                 | The return edge in an SL error injection will   |
|                              |                              |                 | be the transition back to base_value. (6)       |
|                              |                              |                 |                                                 |
|                              |                              |                 | Note that setting base_value = '-' will start   |
|                              |                              |                 | SL error injection on first upcoming edge       |
|                              |                              |                 | after configuration, regardless of input value  |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

.. note::

    * \(1\) See :ref:`Error Injection Types Parameters <t_error_injection_types_parameters>` for required configuration parameters 
      for each error type.
    * \(2\) Randomization is selected by setting the max parameter higher than the min parameter and will be in the range of min 
      parameter to max parameter.
    * \(3\) SL signal is handled with respect to a start and an end transition, and an error injection is activated at the start 
      transition. SLV signal is handled with respect to a start transition, and the following transition will be treated as a new 
      start transition.
    * \(4\) SLV signal does not have a return_delay_min/max parameter.
    * \(5\) Error injection interval will always start injection on the first signal event for any interval setting, followed by the 
      configured interval, e.g. every second for interval = 2.
    * \(6\) For initial and return edge definitions, see :ref:`BYPASS example <ei_bypass_example>`.

The configuration record can be accessed from the Central Testbench Sequencer through the shared variable array, e.g. ::

    shared_ei_config(C_EI_IDX).error_type := DELAY;


.. _t_error_injection_types:

**********************************************************************************************************************************
Error Injection Types
**********************************************************************************************************************************
**t_error_injection_types**

Description
==================================================================================================================================

+---------------------------+---------------------------------------------------+-------------------------------------------------+
| Error                     | std_logic                                         | std_logic_vector                                |
+===========================+===================================================+=================================================+
| BYPASS                    | Signal is preserved and no error is injected      | As for std_logic                                |
+---------------------------+---------------------------------------------------+-------------------------------------------------+
| PULSE                     | Signal will experience a pulse of width "width"   | As for std_logic                                |
|                           | after a time of "initial_delay". (1)              |                                                 |
|                           |                                                   |                                                 |
|                           | Note that the pulse value will be the value       |                                                 |
|                           | prior to initial event                            |                                                 |
+---------------------------+---------------------------------------------------+-------------------------------------------------+
| DELAY                     | Signal will be skewed for a time of "initial_de\  | As for std_logic                                |
|                           | lay" on initial edge and on return edge. (1)      |                                                 |
|                           |                                                   |                                                 |
|                           | Any signal activity while error injection is      |                                                 |
|                           | active will override the error injection.         |                                                 |
+---------------------------+---------------------------------------------------+-------------------------------------------------+
| JITTER                    | As for DELAY, but with different values on edge   | Not applicable for vector signals               |
|                           | delays                                            |                                                 |
|                           |                                                   |                                                 |
|                           | Note that only positive jitter is supported, and  |                                                 |
|                           | that reordering of positive and negative edges    |                                                 |
|                           | yield an invalid configuration and will not work  |                                                 |
+---------------------------+---------------------------------------------------+-------------------------------------------------+
| INVERT                    | The signal is inverted as long as the error       | As for std_logic                                |
|                           | injection configuration is set to INVERT.         |                                                 |
|                           |                                                   |                                                 |
|                           | Note that when error injection configuration is   |                                                 |
|                           | changed from INVERT, a new signal event is        |                                                 |
|                           | required for the new configuration to take        |                                                 |
|                           | effect                                            |                                                 |
+---------------------------+---------------------------------------------------+-------------------------------------------------+
| STUCK_AT_OLD              | The signal will be stuck at the value it had      | As for std_logic                                |
|                           | prior to initial signal event, and released to    |                                                 |
|                           | the current signal value after the specified      |                                                 |
|                           | "width_min" time. (1)                             |                                                 |
|                           |                                                   |                                                 |
|                           | Note that any signal event during STUCK_AT_OLD    |                                                 |
|                           | is ignored                                        |                                                 |
+---------------------------+---------------------------------------------------+-------------------------------------------------+
| STUCK_AT_NEW              | The signal will be stuck at the value it had      | As for std_logic                                |
|                           | prior to initial signal event, and released to    |                                                 |
|                           | the current signal value after a specified        |                                                 |
|                           | "width_min" time. (1)                             |                                                 |
|                           |                                                   |                                                 |
|                           | Note that any signal event during STUCK_AT_NEW    |                                                 |
|                           | is ignored                                        |                                                 |
+---------------------------+---------------------------------------------------+-------------------------------------------------+

.. note::

    * \(1\) Initial event is when a SL signal is at base_value (see :ref:`ei_configuration_record`) and changes signal level.
      The return event is when a SL signal is returning to its base_value. Note that vector signals only have initial events.
      See :ref:`BYPASS example <ei_bypass_example>`.


.. _t_error_injection_types_parameters:

Parameters
==================================================================================================================================

+---------------------------+-------------------+-------------------+------------------+------------------+-----------+-----------+
| Error                     | initial_delay_min | initial_delay_max | return_delay_min | return_delay_max | width_min | width_max |
+===========================+===================+===================+==================+==================+===========+===========+
| BYPASS                    | Ignored           | Ignored           | Ignored          | Ignored          | Ignored   | Ignored   |                 
+---------------------------+-------------------+-------------------+------------------+------------------+-----------+-----------+
| PULSE                     | Required          | Optional          | Ignored          | Ignored          | Required  | Optional  |                 
+---------------------------+-------------------+-------------------+------------------+------------------+-----------+-----------+
| DELAY                     | Required          | Optional          | Ignored          | Ignored          | Ignored   | Ignored   |                 
+---------------------------+-------------------+-------------------+------------------+------------------+-----------+-----------+
| JITTER                    | Required          | Optional          | Required         | Optional         | Ignored   | Ignored   |                 
+---------------------------+-------------------+-------------------+------------------+------------------+-----------+-----------+
| INVERT                    | Ignored           | Ignored           | Ignored          | Ignored          | Ignored   | Ignored   |                 
+---------------------------+-------------------+-------------------+------------------+------------------+-----------+-----------+
| STUCK_AT_OLD              | Ignored           | Ignored           | Ignored          | Ignored          | Required  | Optional  |                 
+---------------------------+-------------------+-------------------+------------------+------------------+-----------+-----------+
| STUCK_AT_NEW              | Ignored           | Ignored           | Ignored          | Ignored          | Required  | Optional  |                 
+---------------------------+-------------------+-------------------+------------------+------------------+-----------+-----------+

Note that a randomized error injection is selected by setting optional parameter "_max" /= 0 ns, and by setting "_max" > "_min". 
The randomization interval will be in the range of required parameter time to optional parameter time.
The seeds used for generating randomized timing parameters are initialized with a unique string assigned to each error injection VIP.


Examples
==================================================================================================================================
Below follows a series of examples showing error configuration of a std_logic and a std_logic_vector type signal, respectively.

.. note::

    * In these examples the std_logic_signal is active high for 20 ns and active low for 20 ns, while the std_logic_vector signal 
      is updated to a new value every 40 ns.
    * JITTER is an invalid error injection type for vector signals and that the signal therefore is not error injected.

.. _ei_bypass_example:

BYPASS
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    shared_ei_config(1) := C_EI_CONFIG_DEFAULT;

.. figure:: /images/vip_error_injection/example_bypass.png
   :alt: Example BYPASS
   :width: 1000pt
   :align: center

|

DELAY
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    shared_ei_config(1).error_type        := DELAY;
    shared_ei_config(1).initial_delay_min := 7 ns;

.. figure:: /images/vip_error_injection/example_delay.png
   :alt: Example DELAY
   :width: 1000pt
   :align: center

|

JITTER
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    shared_ei_config(1).error_type        := JITTER;
    shared_ei_config(1).initial_delay_min := 7 ns;
    shared_ei_config(1).return_delay      := 3 ns;

.. figure:: /images/vip_error_injection/example_jitter.png
   :alt: Example JITTER
   :width: 1000pt
   :align: center

|

PULSE
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    shared_ei_config(1).error_type        := PULSE;
    shared_ei_config(1).initial_delay_min := 7 ns;
    shared_ei_config(1).width_min         := 6 ns;

.. figure:: /images/vip_error_injection/example_pulse.png
   :alt: Example PULSE
   :width: 1000pt
   :align: center

|

INVERT
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    shared_ei_config(1).error_type := INVERT;

.. figure:: /images/vip_error_injection/example_invert.png
   :alt: Example INVERT
   :width: 1000pt
   :align: center

|

STUCK_AT_OLD
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    shared_ei_config(1).error_type := STUCK_AT_OLD;
    shared_ei_config(1).width_min  := 13 ns;

.. figure:: /images/vip_error_injection/example_stuck_at_old.png
   :alt: Example STUCK_AT_OLD
   :width: 1000pt
   :align: center

|

STUCK_AT_NEW
----------------------------------------------------------------------------------------------------------------------------------
.. code-block::

    shared_ei_config(1).error_type := STUCK_AT_NEW;
    shared_ei_config(1).width_min  := 35 ns; -- SL
    shared_ei_config(1).width_min  := 45 ns; -- SLV

.. figure:: /images/vip_error_injection/example_stuck_at_new.png
   :alt: Example STUCK_AT_NEW
   :width: 1000pt
   :align: center

|

**********************************************************************************************************************************
Compilation
**********************************************************************************************************************************
The Error Injection VIP must be compiled with VHDL-2008 or newer. It is dependent on the following libraries:

    * UVVM Utility Library (UVVM-Util)

Before compiling the Error Injection VIP, assure that uvvm_util has been compiled.

See :ref:`Essential Mechanisms - Compile Scripts <vvc_framework_compile_scripts>` for information about compile scripts.

.. table:: Compile order for the Error Injection VIP

    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | Compile to library           | File                                           | Comment                                         |
    +==============================+================================================+=================================================+
    | bitvis_vip_error_injection   | error_injection_pkg.vhd                        | Configuration declaration                       |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_error_injection   | error_injection_slv.vhd                        | Vector entity and error injection functionality |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_error_injection   | error_injection_sl.vhd                         | std_logic entity, only needed when using error  |
    |                              |                                                | injection with std_logic signals                |
    +------------------------------+------------------------------------------------+-------------------------------------------------+

Simulator compatibility and setup
==================================================================================================================================
.. include:: rst_snippets/simulator_compatibility.rst

.. include:: rst_snippets/ip_disclaimer.rst
