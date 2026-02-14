##################################################################################################################################
UVVM Data Stack
##################################################################################################################################
The UVVM Data Stack is a memory buffer that can be used to hold one or more stacks. Each stack will be allocated a chosen size and 
ID number. This allows a selectable number of stacks to operate individually and be independently accessed.

The difference between the FIFO (First-In-First-Out) and the stack is that the stack follows the LIFO (Last-In-First-Out) 
principle. This means that the last element added to the stack is the first one to be removed.

**********************************************************************************************************************************
Functional Parameters
**********************************************************************************************************************************

+-------------------------+------------------------------+---------------------------------------------------------+
| Name                    | Type                         | Description                                             |
+=========================+==============================+=========================================================+
| buffer_idx              | natural                      | The index of the stack that shall be initialized.       |
|                         |                              |                                                         |
|                         |                              | The maximum number of stacks is defined by              |
|                         |                              | C_NUMBER_OF_DATA_BUFFERS in adaptations_pkg.            |
+-------------------------+------------------------------+---------------------------------------------------------+
| buffer_size_in_bits     | natural                      | The size of the stack.                                  |
|                         |                              |                                                         |
|                         |                              | The maximum stack size is defined by                    |
|                         |                              | C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER in adaptations_pkg|
+-------------------------+------------------------------+---------------------------------------------------------+
| entry_size_in_bits      | natural                      | The size of the returned std_logic_vector               |
+-------------------------+------------------------------+---------------------------------------------------------+
| data                    | std_logic_vector             | The data that shall be pushed to the stack              |
+-------------------------+------------------------------+---------------------------------------------------------+
| void                    | :ref:`t_void`                | Unused, empty input parameter                           |
+-------------------------+------------------------------+---------------------------------------------------------+

**********************************************************************************************************************************
Methods
**********************************************************************************************************************************
* All stack functions and procedures are defined in data_stack_pkg.vhd
* All parameters in brackets are optional.

uvvm_stack_init()
----------------------------------------------------------------------------------------------------------------------------------
This UVVM stack call will allocate space in the stack buffer. If no buffer_idx is given, the call will return a buffer index for use 
when addressing the stack. Note that 0 will be returned on error. If a buffer_idx is given, the stack is initialized with this 
index. ::

    uvvm_stack_init([buffer_idx], buffer_size_in_bits)

.. code-block::

    -- Examples:
    uvvm_stack_init(C_BUFFER_IDX_1, C_BUFFER_SIZE-1); -- initialize buffer with index C_BUFFER_IDX_1 
    v_stack_idx := uvvm_stack_init(C_BUFFER_SIZE-1);


uvvm_stack_push()
----------------------------------------------------------------------------------------------------------------------------------
This procedure pushes data into a stack with index buffer_idx. The size of the data is unconstrained, meaning that it can be any 
size. Pushing data with a size that is larger than the stack size results in wrapping, i.e., that when reaching the end that data 
remaining will overwrite the data that was first written. ::

    uvvm_stack_push(buffer_idx, data)

.. code-block::

    -- Examples:
    uvvm_stack_push(C_BUFFER_IDX_1, v_rx_data);


uvvm_stack_pop()
----------------------------------------------------------------------------------------------------------------------------------
This function returns the data from the stack and removes the returned data from the stack. Note that buffer_idx is the index of the 
stack that shall be read, and that entry_size_in_bits is the size of the returned data as SLV. Attempting to get data from an empty 
stack is allowed but triggers a TB_WARNING and returns garbage data. Attempting to get a larger value than the stack size is allowed 
but triggers a TB_WARNING. ::

    std_logic_vector := uvvm_stack_pop(buffer_idx, entry_size_in_bits)

.. code-block::

    -- Examples:
    v_rx_data := uvvm_stack_pop(C_BUFFER_IDX_1, C_ENTRY_SIZE-1);


uvvm_stack_flush()
----------------------------------------------------------------------------------------------------------------------------------
This procedure empties the stack given by buffer_idx. ::

    uvvm_stack_flush(buffer_idx)    

.. code-block::

    -- Examples:
    uvvm_stack_flush(C_BUFFER_IDX_1);


uvvm_stack_peek()
----------------------------------------------------------------------------------------------------------------------------------
This function returns the data from the stack without removing it. Note that apart from not removing the data, this function will 
behave in the same way as the uvvm_stack_pop() function. ::

    std_logic_vector := uvvm_stack_peek(buffer_idx, entry_size_in_bits)

.. code-block::

    -- Examples:
    v_rx_data := uvvm_stack_peek(C_BUFFER_IDX_1, C_ENTRY_SIZE-1);


uvvm_stack_get_count()
----------------------------------------------------------------------------------------------------------------------------------
This function returns a natural indicating the number of elements currently occupying the stack given by buffer_idx. ::

    natural := uvvm_stack_get_count(buffer_idx)

.. code-block::

    -- Examples:
    v_num_elements := uvvm_stack_get_count(C_BUFFER_IDX);


uvvm_stack_get_max_count()
----------------------------------------------------------------------------------------------------------------------------------
This function returns a natural indicating the maximum number of elements that can occupy the stack given by buffer_idx. ::

    natural := uvvm_stack_get_max_count(buffer_idx)

.. code-block::

    -- Examples:
    v_max_elements := uvvm_stack_get_max_count(C_BUFFER_IDX);


uvvm_stack_is_full()
----------------------------------------------------------------------------------------------------------------------------------
This function returns a boolean indicating if the stack is full or not. ::

    boolean := uvvm_stack_is_full(buffer_idx)

.. code-block::

    -- Examples:
    v_stack_is_full := uvvm_stack_is_full(C_BUFFER_IDX);


uvvm_stack_deallocate()
----------------------------------------------------------------------------------------------------------------------------------
This function de-allocates the stack buffer, all the stack pointers are reset. ::

    uvvm_stack_deallocate(VOID)

.. code-block::

    -- Examples:
    uvvm_stack_deallocate(VOID);

.. include:: rst_snippets/ip_disclaimer.rst
