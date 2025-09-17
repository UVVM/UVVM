.. _faq:

##################################################################################################################################
Frequently Asked Questions
##################################################################################################################################

**********************************************************************************************************************************
General questions
**********************************************************************************************************************************
* My compiler reports that some of the VHDL source files do not exist. What is the problem?
   There is a 250 character limit on file paths in the Windows operating system. Please make sure that this product is placed so 
   that the paths of the files do not exceed 250 characters.

**********************************************************************************************************************************
UVVM Questions
**********************************************************************************************************************************
* Why do I get an error message saying "UVVM will not work without intitalize_uvvm instantiated as a concurrent procedure in the test harness"?
   You need to instantiate ``uvvm_vvc_framework.ti_uvvm_engine`` in your testbench, and you should include ``await_uvvm_initialization(VOID)`` 
   as your first statement in your test case sequencer. See "bitvis_uart/tb/uart_vvc_th|tb.vhd" for examples.

**********************************************************************************************************************************
VVC Questions
**********************************************************************************************************************************
* Can the ``*_VVCT`` signal be accessed from a procedure or function? 
   Yes, you can access VVC commands from procedures in your TB, and making overloading procedures in the TB can be smart, e.g. ::

      procedure axilite_write(
        constant data             : in std_logic_vector(GC_DATA_WIDTH-1 downto 0);
        constant addr             : in unsigned;
        constant msg              : in string  := "";
        constant vvc_instance_idx : in natural := C_VVC_IDX_MASTER) is
      begin
        axilite_write(AXILITE_VVCT, vvc_instance_idx, addr, data, msg);
      end procedure;

..................................................................................................................................

* How do I access the read data after calling ``*_read()`` or ``*_receive()`` procedure from the VVC? 
   Use ``fetch_result()`` as described in the corresponding VVC documentation. 

..................................................................................................................................

* When implementing a testbench using bitvis_vip_axilite, how do I declare and constrain the ``t_axilite_if`` signal that connect to the VVC in the test harness? 
   If you have a look :ref:`here <t_axilite_if>`, you will see the ``axilite_if`` record type.
   Then you could try to change your code to something like: ::

       signal axi_ctrl : t_axilite_if(write_address_channel(awaddr(GC_ADDR_WIDTH-1 downto 0)),
                                      write_data_channel(wdata(GC_DATA_WIDTH-1 downto 0),
                                      wstrb((GC_DATA_WIDTH/8)-1 downto 0)),
                                      read_address_channel(araddr(GC_ADDR_WIDTH-1 downto 0)),
                                      read_data_channel(rdata(GC_DATA_WIDTH-1 downto 0)) ) := init_axilite_if_signals(GC_ADDR_WIDTH, GC_DATA_WIDTH);


**********************************************************************************************************************************
Simulator Questions
**********************************************************************************************************************************
* Which simulators support UVVM?
   For a list of supported simulators see :ref:`uvvm_prerequisites` and for an overview of known issues see :ref:`tool_compatibility`.
