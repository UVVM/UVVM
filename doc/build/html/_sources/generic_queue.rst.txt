##################################################################################################################################
UVVM Generic Queue
##################################################################################################################################
The Generic Queue operate as a FIFO that can hold generic elements, which enable large FIFO and e.g. record elements possibilities.

**********************************************************************************************************************************
Functional Parameters
**********************************************************************************************************************************

+-------------------------+------------------------------+---------------------------------------------------------+
| Name                    | Type                         | Description                                             |
+=========================+==============================+=========================================================+
| instance                | integer                      | One generic queue variable can have multiple independent|
|                         |                              | queues referred to as instances                         |
+-------------------------+------------------------------+---------------------------------------------------------+
| identifier_option       | :ref:`t_identifier_option`   | Defines how to identify the queue element               |
+-------------------------+------------------------------+---------------------------------------------------------+
| identifier              | positive                     | The position or entry number                            |
+-------------------------+------------------------------+---------------------------------------------------------+
| identifier_min          | positive                     | The minimum position or entry number of a range         |
+-------------------------+------------------------------+---------------------------------------------------------+
| identifier_max          | positive                     | The maximum position or entry number of a range         |
+-------------------------+------------------------------+---------------------------------------------------------+
| position_val            | positive                     | The position value                                      |
+-------------------------+------------------------------+---------------------------------------------------------+
| range_option            | :ref:`t_range_option`        | The range that is affected                              |
+-------------------------+------------------------------+---------------------------------------------------------+
| scope                   | string                       | The scope for the generic queue. Has to be set prior to |
|                         |                              | usage of several procedure and functions.               |
+-------------------------+------------------------------+---------------------------------------------------------+
| element                 | t_generic_element            | The element that shall be pushed to the queue           |
+-------------------------+------------------------------+---------------------------------------------------------+
| queue_count_max         | natural                      | The maximum number of elements the queue shall hold     |
+-------------------------+------------------------------+---------------------------------------------------------+
| queue_count_alert_level | natural                      | The number of elements the queue can hold before an     |
|                         |                              | alert is raised                                         |
+-------------------------+------------------------------+---------------------------------------------------------+
| alert_level             | :ref:`t_alert_level`         | The alert level is raised when the number of elements   |
|                         |                              | in the queue exceeds queue_count_alert_level            |
+-------------------------+------------------------------+---------------------------------------------------------+
| void                    | t_void                       | Unused, empty input parameter                           |
+-------------------------+------------------------------+---------------------------------------------------------+

.. note::

    Default queue size is 2048 bits and the size can be adjusted with the C_NUMBER_OF_BITS_IN_DATA_BUFFER located in the 
    adaptations package.

**********************************************************************************************************************************
Generics
**********************************************************************************************************************************

+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| Name                         | Type                         | Default         | Description                                     |
+==============================+==============================+=================+=================================================+
| <generic_element>            | t_generic_element            | <none>          |                                                 |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_QUEUE_COUNT_MAX           | natural                      | 1000            | Maximum number of elements in the queue         |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+
| GC_QUEUE_COUNT_THRESHOLD     | natural                      | 950             | An alert will be generated when reaching this   |
|                              |                              |                 | threshold to indicate that the queue is almost  |
|                              |                              |                 | full                                            |
+------------------------------+------------------------------+-----------------+-------------------------------------------------+

.. _generic_queue_declaration:

**********************************************************************************************************************************
Declaration
**********************************************************************************************************************************

.. code-block::

   -- Package declaration example
   package queue_pkg is new uvvm_util.generic_queue_pkg
      generic map( t_generic_element => integer,
                   GC_QUEUE_COUNT_MAX => 1000,
                   GC_QUEUE_COUNT_THRESHOLD => 950);

.. code-block::

   -- Queue declaration example
   use work.queue_pkg.all;
   shared variable generic_queue : t_generic_queue;

**********************************************************************************************************************************
Methods
**********************************************************************************************************************************
* All generic queue functions and procedures are defined in generic_queue_pkg.vhd.
* The generic queue can be used with a single instance or with multiple instances. An instance is a separate queue.
* When multiple instances are used, the methods are called with the instance parameter.
* When only using a single generic queue instance, the instance parameter may be omitted if that instance is instance 1.
* Multiple instances are typically used when multiple queues with the same data types are needed.
* All parameters in brackets are optional.

add()
----------------------------------------------------------------------------------------------------------------------------------
This procedure adds an element at the back of a generic queue. The queue element is generic, meaning that it can be of any type, 
specified by the package declaration (see :ref:`generic_queue_declaration` for example). Note that if no scope is set for the 
queue, a TB_WARNING will be raised. An alert, set by set_queue_count_threshold_severity(), will be raised when the queue reach a 
level, set by set_queue_count_threshold(). Also note that trying to add() to a full queue will raise a TB_ERROR. ::

   add([instance], element)

.. code-block::

    -- Examples:
   generic_queue.add(v_data_packet);
   generic_queue.add(2, v_data_packet);


fetch()
----------------------------------------------------------------------------------------------------------------------------------
This function returns an element from the generic queue and removes it from the queue. Note that the oldest element in the queue 
is returned first if no identifier is specified. Attempting to fetch() from the queue without setting queue scope first will 
trigger a TB_WARNING, and attempting to fetch() from an empty queue will trigger a TB_ERROR. ::

   t_generic_element := fetch([instance], [identifier_option, identifier])

.. code-block::

    -- Examples:
   v_data_packet := generic_queue.fetch(VOID);
   v_data_packet := generic_queue.fetch(2, POSITION, 5);
   v_data_packet := generic_queue.fetch(2, ENTRY_NUM, 14);   


get()
----------------------------------------------------------------------------------------------------------------------------------
.. warning::

   This function is deprecated. Use fetch.
    
.. code-block::

   t_generic_element := get([instance])


flush()
----------------------------------------------------------------------------------------------------------------------------------
This procedure empties the queue. A TB_WARNING will be raised if no scope is set for the queue prior to calling flush(). ::

   flush([instance])

.. code-block::

    -- Examples:
   generic_queue.flush(VOID);
   generic_queue.flush(2);


reset()
----------------------------------------------------------------------------------------------------------------------------------
This procedure empties the queue and resets the entry number. A TB_WARNING will be raised if no scope is set for the queue prior 
to calling reset(). ::

   reset([instance])

.. code-block::

    -- Examples:
   generic_queue.reset(VOID);
   generic_queue.reset(2);


is_empty()
----------------------------------------------------------------------------------------------------------------------------------
This function returns true if the queue is empty and false otherwise. ::

   boolean := is_empty([instance])

.. code-block::

    -- Examples:
   if generic_queue.is_empty(VOID) then ...


set_scope()
----------------------------------------------------------------------------------------------------------------------------------
This procedure will set the scope of the queue. Note that most of the procedures and functions in the generic queue will raise a 
TB_WARNING if no scope has been set for the queue. ::

   set_scope([instance], scope)

.. code-block::

    -- Examples:
   generic_queue.set_scope(C_QUEUE_SCOPE);
   generic_queue.set_scope(2, C_QUEUE_SCOPE);		


get_scope()
----------------------------------------------------------------------------------------------------------------------------------
This function returns the scope of the queue as a string. ::

   string := get_scope([instance])

.. code-block::

    -- Examples:
   v_queue_scope := generic_queue.get_scope(VOID);
   v_queue_scope := generic_queue.get_scope(2);


get_count()
----------------------------------------------------------------------------------------------------------------------------------
This function returns the number of elements currently in the queue. ::

   natural := get_count([instance])

.. code-block::

    -- Examples:
   v_num_elements := generic_queue.get_count(VOID);
   v_num_elements := generic_queue.get_count(2);   


insert()
----------------------------------------------------------------------------------------------------------------------------------
This procedure inserts an element at the specified position in the generic queue. If identifier_option is POSITION, the element is 
inserted at that position. If identifier_option is ENTRY_NUM, the element is inserted after that entry number. ::

   insert([instance], identifier_option, identifier, element)

.. code-block::

    -- Examples:
   generic_queue.insert(POSITION, 5, v_data_packet);
   generic_queue.insert(2, ENTRY_NUM, 8, v_data_packet);


delete()
----------------------------------------------------------------------------------------------------------------------------------
This procedure deletes the specified element from the generic queue. Element to be deleted can be specified by a matching element 
or by identifier and range. ::

   delete([instance], element)
   delete([instance], identifier_option, identifier, range_option)
   delete([instance], identifier_option, identifier_min, identifier_max)

.. code-block::

    -- Examples:
   generic_queue.delete(v_data_packet);
   generic_queue.delete(2, ENTRY_NUM, 8, SINGLE);
   generic_queue.delete(2, POSITION, 12, AND_HIGHER);
   generic_queue.delete(2, ENTRY_NUM, 3, 6);


peek()
----------------------------------------------------------------------------------------------------------------------------------
This function returns an element from the generic queue without deleting it. Element can be specified by POSITION or ENTRY_NUM. ::

   t_generic_element := peek([instance], [identifier_option, identifier])

.. code-block::

    -- Examples:
   v_data_packet := generic_queue.peek(VOID); --first element in queue, instance 1
   v_data_packet := generic_queue.peek(2, ENTRY_NUM, 8);
   v_data_packet := generic_queue.peek(2, POSITION, 2);


find_position()
----------------------------------------------------------------------------------------------------------------------------------
This function returns the position of the matching element. Returns -1 if no matching element is found. ::

   integer := find_position([instance], element)

.. code-block::

    -- Examples:
   v_position := generic_queue.find_position(v_data_packet);
   v_position := generic_queue.find_position(2, v_data_packet);


find_entry_num()
----------------------------------------------------------------------------------------------------------------------------------
This function returns the entry number of the matching element. Returns -1 if no matching element is found. ::

   integer := find_entry_num([instance], element)

.. code-block::

    -- Examples:
   v_entry_num := generic_queue.find_entry_num(v_data_packet);
   v_entry_num := generic_queue.find_entry_num(2, v_data_packet);


get_entry_num()
----------------------------------------------------------------------------------------------------------------------------------
This function returns the entry number of the element in the specified position. ::

   integer := get_entry_num([instance], position_val)

.. code-block::

    -- Examples:
   v_entry_num := generic_queue.get_entry_num(6);
   v_entry_num := generic_queue.get_entry_num(2, 8);


exists()
----------------------------------------------------------------------------------------------------------------------------------
This function returns true if a matching element is found in the generic queue and false otherwise. ::

   boolean := exists([instance], element)

.. code-block::

    -- Examples:
   if generic_queue.exists(element) then ...
   if generic_queue.exists(2, element) then ...		


print_queue()
----------------------------------------------------------------------------------------------------------------------------------
This procedure prints the position and entry number for all elements in the generic queue. ::

   print_queue([instance])

.. code-block::

    -- Examples:
   generic_queue.print_queue(VOID);
   generic_queue.print_queue(2);


set_queue_count_max()
----------------------------------------------------------------------------------------------------------------------------------
This procedure sets the maximum number of elements the queue can hold. Note that a TB_ERROR is raised if parameter queue_count_max 
is less than the number of elements currently in the queue. ::

   set_queue_count_max([instance], queue_count_max)
   
.. code-block::

    -- Examples:
   generic_queue.set_queue_count_max(1000);
   generic_queue.set_queue_count_max(2, 1000);		


get_queue_count_max()
----------------------------------------------------------------------------------------------------------------------------------
This function returns the maximum number of elements the queue can hold. ::

   natural := get_queue_count_max([instance])
   
.. code-block::

    -- Examples:
   v_queue_max_elements := generic_queue.get_queue_count_max(VOID);
   v_queue_max_elements := generic_queue.get_queue_count_max(2);


set_queue_count_threshold()
----------------------------------------------------------------------------------------------------------------------------------
This procedure sets the threshold value that will raise an alert, set by set_queue_count_threshold_severity(), if the number of 
queue elements exceeds the queue_count_alert_level. ::

   set_queue_count_threshold([instance], queue_count_alert_level)
   
.. code-block::

    -- Examples:
   generic_queue.set_queue_count_threshold(950);
   generic_queue.set_queue_count_threshold(2, 950);


get_queue_count_threshold()
----------------------------------------------------------------------------------------------------------------------------------
This function returns the threshold value that will raise an alert, set by set_queue_count_threshold_severity(), if the number of 
queue elements exceeds the queue_count_alert_level. ::

   natural := get_queue_count_threshold([instance])
   
.. code-block::

    -- Examples:
   v_queue_threshold := generic_queue.get_queue_count_threshold(VOID);
   v_queue_threshold := generic_queue.get_queue_count_threshold(2);


set_queue_count_threshold_severity()
----------------------------------------------------------------------------------------------------------------------------------
This procedure sets the severity level for the alert that is raised when the number of queue elements exceeds the value set by 
set_queue_count_threshold(). ::

   set_queue_count_threshold_severity(alert_level)
   
.. code-block::

    -- Examples:
   generic_queue.set_queue_count_threshold_severity(TB_WARNING);


get_queue_count_threshold_severity()
----------------------------------------------------------------------------------------------------------------------------------
This function returns the severity level for the alert that is raised when the number of queue elements exceeds the value set by 
set_queue_count_threshold(). ::

   t_alert_level := get_queue_count_threshold_severity(void)
   
.. code-block::

    -- Examples:
   v_queue_level_severity := generic_queue.get_queue_count_threshold_severity(VOID);


.. include:: rst_snippets/ip_disclaimer.rst
