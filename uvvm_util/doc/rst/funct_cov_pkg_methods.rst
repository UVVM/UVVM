Methods
=======
Procedures and functions complementing the t_coverpoint functionality.

.. _bin_functions:

bin()
----------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing a bin with a single value or multiple values. When having multiple values in a bin, only one 
of them needs to be sampled for the bin to collect coverage. ::

    t_new_bin_array := bin(value)
    t_new_bin_array := bin(set_values)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | value              | in     | integer                      | Single value contained in the bin                     |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | set_values         | in     | integer_vector               | Set of values contained in the bin                    |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.add_bins(bin(10));
    my_coverpoint.add_bins(bin((5,10,15,20)));


bin_range()
----------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing a range of values divided into a number of bins. If the number of bins is 0 then a bin is 
created for each value. If the division has a residue, it is spread equally starting from the last bins. ::

    t_new_bin_array := bin_range(min_value, max_value, [num_bins])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | min_value          | in     | integer                      | Minimum value in the range to create the bins         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | max_value          | in     | integer                      | Maximum value in the range to create the bins         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | num_bins           | in     | natural                      | Number of bins to divide the range into. Default is 0 |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.add_bins(bin_range(10,20));   -- creates 11 bins: 10,11,12,13,14,15,16,17,18,19,20
    my_coverpoint.add_bins(bin_range(10,20,1)); -- creates 1 bin:   10 to 20
    my_coverpoint.add_bins(bin_range(10,20,4)); -- creates 4 bins:  10 to 11, 12 to 14, 15 to 17, 18 to 20


bin_vector()
----------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing a vector's range divided into a number of bins. If the number of bins is 0 then a bin is 
created for each value. If the division has a residue, it is spread equally starting from the last bins. ::

    t_new_bin_array := bin_vector(vector, [num_bins])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | vector             | in     | std_logic_vector             | Vector used to create the bins                        |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | num_bins           | in     | natural                      | Number of bins to divide the range into. Default is 0 |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.add_bins(bin_vector(address));   -- creates 2**(address'length) bins: address[0], address[1], ...
    my_coverpoint.add_bins(bin_vector(address,1)); -- creates 1 bin
    my_coverpoint.add_bins(bin_vector(address,4)); -- creates 4 bins


bin_transition()
----------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing a bin with a transition of values. ::

    t_new_bin_array := bin_transition(set_values)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | set_values         | in     | integer_vector               | Transition of values contained in the bin             |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.add_bins(bin_transition(1,2,9,10));


ignore_bin()
----------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing an ignore bin with a single value. ::

    t_new_bin_array := ignore_bin(value)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | value              | in     | integer                      | Single value contained in the bin                     |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.add_bins(ignore_bin(50));


ignore_bin_range()
----------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing an ignore bin with a range of values. ::

    t_new_bin_array := ignore_bin_range(min_value, max_value)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | min_value          | in     | integer                      | Minimum value in the range to create the bin          |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | max_value          | in     | integer                      | Maximum value in the range to create the bin          |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.add_bins(ignore_bin_range(50,60));


ignore_bin_transition()
----------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing an ignore bin with a transition of values. ::

    t_new_bin_array := ignore_bin_transition(set_values)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | set_values         | in     | integer_vector               | Transition of values contained in the bin             |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.add_bins(ignore_bin_transition(20,21,22,30));


illegal_bin()
----------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing an illegal bin with a single value. ::

    t_new_bin_array := illegal_bin(value)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | value              | in     | integer                      | Single value contained in the bin                     |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.add_bins(illegal_bin(100));


illegal_bin_range()
----------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing an illegal bin with a range of values. ::

    t_new_bin_array := illegal_bin_range(min_value, max_value)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | min_value          | in     | integer                      | Minimum value in the range to create the bin          |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | max_value          | in     | integer                      | Maximum value in the range to create the bin          |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.add_bins(illegal_bin_range(100,200));


illegal_bin_transition()
----------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing an illegal bin with a transition of values. ::

    t_new_bin_array := illegal_bin_transition(set_values)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | set_values         | in     | integer_vector               | Transition of values contained in the bin             |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.add_bins(illegal_bin_transition(30,10,0));


set_sim_coverage_goal()
----------------------------------------------------------------------------------------------------
Configures the simulation coverage goal. This is an easy way to apply the same goal to all the coverpoints. If a coverpoint's goal 
has also been modified by ``set_coverage_goal()``, they will be multiplied for the given coverpoint. Default value is 100. ::

    set_sim_coverage_goal(percentage, [scope, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | percentage         | in     | positive                     | Goal percentage of the simulation to cover              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    Examples:
    set_sim_coverage_goal(200);


get_sim_coverage()
----------------------------------------------------------------------------------------------------
Returns the accumulated coverage for all the coverpoints in the simulation. ::

    real := get_sim_coverage(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    log(ID_SEQUENCER, to_string(get_sim_coverage(VOID)));


sim_coverage_completed()
----------------------------------------------------------------------------------------------------
Returns true if the accumulated coverage for all the coverpoints in the simulation has reached the goal. Default goal is 100. ::

    boolean := sim_coverage_completed(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    if sim_coverage_completed(VOID) then
    ...
    end if;


print_sim_coverage_summary()
----------------------------------------------------------------------------------------------------
Prints the simulation coverage summary containing the main information of all the coverpoints, however it does not print the bins. 
The printing destination can be log and/or console and is defined by shared_default_log_destination in adaptations_pkg.::

    print_sim_coverage_summary(VOID)
    print_sim_coverage_summary(scope)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    Examples:
    print_sim_coverage_summary(VOID);
    print_sim_coverage_summary(my_scope);
