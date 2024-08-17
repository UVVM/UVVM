.. _uvvm_fifo_collection:

##################################################################################################################################
UVVM FIFO Collection
##################################################################################################################################
The FIFO Collection is a memory buffer that can be used to hold one or more FIFOs. Each FIFO will be allocated a chosen size and 
ID number. This allows a selectable number of FIFOs to operate individually and be independently accessed.

**********************************************************************************************************************************
Functional Parameters
**********************************************************************************************************************************

+-------------------------+------------------------------+---------------------------------------------------------+
| Name                    | Type                         | Description                                             |
+=========================+==============================+=========================================================+
| buffer_idx              | natural                      | The index of the FIFO that shall be initialized         |
+-------------------------+------------------------------+---------------------------------------------------------+
| buffer_size_in_bits     | natural                      | The size of the FIFO                                    |
+-------------------------+------------------------------+---------------------------------------------------------+
| entry_size_in_bits      | natural                      | The size of the returned std_logic_vector               |
+-------------------------+------------------------------+---------------------------------------------------------+
| data                    | std_logic_vector             | The data that shall be pushed to the FIFO               |
+-------------------------+------------------------------+---------------------------------------------------------+
| void                    | t_void                       | Unused, empty input parameter                           |
+-------------------------+------------------------------+---------------------------------------------------------+

**********************************************************************************************************************************
Methods
**********************************************************************************************************************************
* All FIFO functions and procedures are defined in data_fifo_pkg.vhd
* All parameters in brackets are optional.

uvvm_fifo_init()
----------------------------------------------------------------------------------------------------------------------------------
This UVVM FIFO call will allocate space in the FIFO buffer. If no buffer_idx is given, the call will return a buffer index for use 
when addressing the FIFO. Note that 0 will be returned on error. If a buffer_idx is given, the FIFO is initialized with this 
index. ::

    uvvm_fifo_init([buffer_idx], buffer_size_in_bits)

.. code-block::

    -- Examples:
    uvvm_fifo_init(C_BUFFER_IDX_1, C_BUFFER_SIZE-1); -- initialize buffer with index C_BUFFER_IDX_1 
    v_fifo_idx := uvvm_fifo_init(C_BUFFER_SIZE-1);


uvvm_fifo_put()
----------------------------------------------------------------------------------------------------------------------------------
This procedure puts data into a FIFO with index buffer_idx. The size of the data is unconstrained, meaning that it can be any 
size. Pushing data with a size that is larger than the FIFO size results in wrapping, i.e., that when reaching the end that data 
remaining will overwrite the data that was first written. ::

    uvvm_fifo_put(buffer_idx, data)

.. code-block::

    -- Examples:
    uvvm_fifo_put(C_BUFFER_IDX_1, v_rx_data);


uvvm_fifo_get()
----------------------------------------------------------------------------------------------------------------------------------
This function returns the data from the FIFO and removes the returned data from the FIFO. Note that buffer_idx is the index of the 
FIFO that shall be read, and that entry_size_in_bits is the size of the returned data as SLV. Attempting to get data from an empty 
FIFO is allowed but triggers a TB_WARNING and returns garbage data. Attempting to get a larger value than the FIFO size is allowed 
but triggers a TB_WARNING. ::

    std_logic_vector := uvvm_fifo_get(buffer_idx, entry_size_in_bits)

.. code-block::

    -- Examples:
    v_rx_data := uvvm_fifo_get(C_BUFFER_IDX_1, C_ENTRY_SIZE-1);


uvvm_fifo_flush()
----------------------------------------------------------------------------------------------------------------------------------
This procedure empties the FIFO given by buffer_idx. ::

    uvvm_fifo_flush(buffer_idx)    

.. code-block::

    -- Examples:
    uvvm_fifo_flush(C_BUFFER_IDX_1);


uvvm_fifo_peek()
----------------------------------------------------------------------------------------------------------------------------------
This function returns the data from the FIFO without removing it. Note that apart from not removing the data, this function will 
behave in the same way as the uvvm_fifo_get() function. ::

    std_logic_vector := uvvm_fifo_peek(buffer_idx, entry_size_in_bits)

.. code-block::

    -- Examples:
    v_rx_data := uvvm_fifo_peek(C_BUFFER_IDX_1, C_ENTRY_SIZE-1);


uvvm_fifo_get_count()
----------------------------------------------------------------------------------------------------------------------------------
This function returns a natural indicating the number of elements currently occupying the FIFO given by buffer_idx. ::

    natural := uvvm_fifo_get_count(buffer_idx)

.. code-block::

    -- Examples:
    v_num_elements := uvvm_fifo_get_count(C_BUFFER_IDX);


uvvm_fifo_get_max_count()
----------------------------------------------------------------------------------------------------------------------------------
This function returns a natural indicating the maximum number of elements that can occupy the FIFO given by buffer_idx. ::

    natural := uvvm_fifo_get_max_count(buffer_idx)

.. code-block::

    -- Examples:
    v_max_elements := uvvm_fifo_get_max_count(C_BUFFER_IDX);


uvvm_fifo_is_full()
----------------------------------------------------------------------------------------------------------------------------------
This function returns a boolean indicating if the FIFO is full or not. ::

    boolean := uvvm_fifo_is_full(buffer_idx)

.. code-block::

    -- Examples:
    v_fifo_is_full := uvvm_fifo_is_full(C_BUFFER_IDX);


uvvm_fifo_deallocate()
----------------------------------------------------------------------------------------------------------------------------------
This function de-allocates the FIFO buffer, all the FIFO pointers are reset. ::

    uvvm_fifo_deallocate(VOID)

.. code-block::

    -- Examples:
    uvvm_fifo_deallocate(VOID);

.. include:: rst_snippets/ip_disclaimer.rst
