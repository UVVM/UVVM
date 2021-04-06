t_coverpoint (protected)
========================
Protected type containing all the coverage functionality.

set_name()
----------------------------------------------------------------------------------------------------
Configures the name of the coverpoint. ::

    set_name(name)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | name               | in     | string                       | Name of the coverpoint used in logs and reports         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.set_name("MEM_ADDR");


get_name()
----------------------------------------------------------------------------------------------------
Returns the coverpoint's name. ::

    string := get_name(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    log(ID_SEQUENCER, to_string(my_coverpoint.get_name(VOID)));


set_scope()
----------------------------------------------------------------------------------------------------
Configures the scope used in the log messages. ::

    set_scope(scope)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.set_scope("MEM_ADDR_COVERPOINT");


get_scope()
----------------------------------------------------------------------------------------------------
Returns the configured scope. ::

    string := get_scope(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    scope := my_coverpoint.get_scope(VOID);


detect_bin_overlap()
----------------------------------------------------------------------------------------------------
Configures if a TB_WARNING alert should be generated when overlapping bins are sampled (not including ignore or invalid bins). ::

    detect_bin_overlap(enable, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | enable             | in     | boolean                      | Enables/disables the alert                            |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.detect_bin_overlap(true);


write_coverage_db()
----------------------------------------------------------------------------------------------------
Writes the coverpoint model to a file. ::

    write_coverage_db(file_name, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | file_name          | in     | string                       | Name of the file where to store the coverpoint model  |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.write_coverage_db("coverage_db.txt");


load_coverage_db()
----------------------------------------------------------------------------------------------------
Loads the coverpoint model from a file. ::

    load_coverage_db(file_name, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | file_name          | in     | string                       | Name of the file where the coverpoint model is stored |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.load_coverage_db("coverage_db.txt");


add_bins()
----------------------------------------------------------------------------------------------------
Adds bins to the coverpoint. Must be used together with the :ref:`bin functions <bin_functions>` which return a t_new_bin_array. 
Bin functions may be concatenated to add several bins at once. Default values for min_hits and rand_weight are both 1. ::

    add_bins(bin, min_hits, rand_weight, [bin_name, [msg_id_panel]])
    add_bins(bin, min_hits, [bin_name, [msg_id_panel]])
    add_bins(bin, [bin_name, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | bin                | in     | t_new_bin_array              | Array containing one or several bins                  |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | min_hits           | in     | positive                     | Minimum number of hits for the bin to be covered      |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | rand_weight        | in     | natural                      | Randomization weight assigned to the bin              |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | bin_name           | in     | string                       | Name of the bin (optional)                            |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.add_bins(bin(10), 5, 3, "low_value");
    my_coverpoint.add_bins(bin(20), 5, "middle_value");
    my_coverpoint.add_bins(bin(30) & bin(40) & bin(50), "high_values");


add_cross() {bin_array}
----------------------------------------------------------------------------------------------------
Adds a cross between two t_new_bin_array elements to the coverpoint. Must be used together with the :ref:`bin functions <bin_functions>` 
which return a t_new_bin_array. Bin functions may be concatenated to add several bins at once. Default values for min_hits and 
rand_weight are both 1. ::

    add_cross(bin1, bin2, min_hits, rand_weight, [bin_name, [msg_id_panel]])
    add_cross(bin1, bin2, min_hits, [bin_name, [msg_id_panel]])
    add_cross(bin1, bin2, [bin_name, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | bin(n)             | in     | t_new_bin_array              | Array containing one or several bins                  |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | min_hits           | in     | positive                     | Minimum number of hits for the bin to be covered      |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | rand_weight        | in     | natural                      | Randomization weight assigned to the bin              |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | bin_name           | in     | string                       | Name of the bin (optional)                            |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_cross.add_cross(bin(10), bin_range(0,15,1), 5, 3, "low_values");
    my_cross.add_cross(bin(20), bin_range(16,31,1), 5, "middle_values");
    my_cross.add_cross(bin(30), bin_range(32,63,1), "high_values");
    my_cross.add_cross(bin((10,20,30)), illegal_bin_range(64,95) & illegal_bin_range(96,127), "illegal_values");

This procedure has overloads which support crossing up to 5 t_new_bin_array elements. ::

    add_cross(bin1, bin2, bin3, min_hits, rand_weight, [bin_name, [msg_id_panel]])
    add_cross(bin1, bin2, bin3, min_hits, [bin_name, [msg_id_panel]])
    add_cross(bin1, bin2, bin3, [bin_name, [msg_id_panel]])

    add_cross(bin1, bin2, bin3, bin4, min_hits, rand_weight, [bin_name, [msg_id_panel]])
    add_cross(bin1, bin2, bin3, bin4, min_hits, [bin_name, [msg_id_panel]])
    add_cross(bin1, bin2, bin3, bin4, [bin_name, [msg_id_panel]])

    add_cross(bin1, bin2, bin3, bin4, bin5, min_hits, rand_weight, [bin_name, [msg_id_panel]])
    add_cross(bin1, bin2, bin3, bin4, bin5, min_hits, [bin_name, [msg_id_panel]])
    add_cross(bin1, bin2, bin3, bin4, bin5, [bin_name, [msg_id_panel]])


add_cross() {coverpoint}
----------------------------------------------------------------------------------------------------
Adds a cross between two coverpoints to the coverpoint. Note that the coverpoints being crossed must contain at least one bin. 
Default values for min_hits and rand_weight are both 1. ::

    add_cross(coverpoint1, coverpoint2, min_hits, rand_weight, [bin_name, [msg_id_panel]])
    add_cross(coverpoint1, coverpoint2, min_hits, [bin_name, [msg_id_panel]])
    add_cross(coverpoint1, coverpoint2, [bin_name, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| variable | coverpoint(n)      | inout  | t_coverpoint                 | Protected type containing a coverpoint                |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | min_hits           | in     | positive                     | Minimum number of hits for the bin to be covered      |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | rand_weight        | in     | natural                      | Randomization weight assigned to the bin              |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | bin_name           | in     | string                       | Name of the bin (optional)                            |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint_addr.add_bins(bin_vector(addr));
    my_coverpoint_size.add_bins(bin_range(0,127,1));
    my_cross.add_cross(my_coverpoint_addr, my_coverpoint_size, 5, 3, "cross_addr_size");

This procedure has overloads which support crossing up to 16 coverpoints. ::

    add_cross(coverpoint1, coverpoint2, coverpoint3, min_hits, rand_weight, [bin_name, [msg_id_panel]])
    add_cross(coverpoint1, coverpoint2, coverpoint3, min_hits, [bin_name, [msg_id_panel]])
    add_cross(coverpoint1, coverpoint2, coverpoint3, [bin_name, [msg_id_panel]])

    add_cross(coverpoint1, coverpoint2, coverpoint3, coverpoint4, min_hits, rand_weight, [bin_name, [msg_id_panel]])
    add_cross(coverpoint1, coverpoint2, coverpoint3, coverpoint4, min_hits, [bin_name, [msg_id_panel]])
    add_cross(coverpoint1, coverpoint2, coverpoint3, coverpoint4, [bin_name, [msg_id_panel]])

    add_cross(coverpoint1, coverpoint2, coverpoint3, coverpoint4, coverpoint5, min_hits, rand_weight, [bin_name, [msg_id_panel]])
    add_cross(coverpoint1, coverpoint2, coverpoint3, coverpoint4, coverpoint5, min_hits, [bin_name, [msg_id_panel]])
    add_cross(coverpoint1, coverpoint2, coverpoint3, coverpoint4, coverpoint5, [bin_name, [msg_id_panel]])

    ...


rand()
----------------------------------------------------------------------------------------------------
Returns a random value (or values for crossed bins) generated from the uncovered bins. Once all the bins have been covered, 
it will return a random value among all the valid bins. Note that ignore and illegal bins will never be selected for randomization. ::

    integer := rand([msg_id_panel])
    integer_vector := rand([msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    addr := my_coverpoint.rand;
    addr_vec := my_coverpoint.rand;


sample_coverage()
----------------------------------------------------------------------------------------------------
Samples a value (or values for crossed bins) in a coverpoint. If the value matches a bin, it will increase its number of hits and 
once the bin has reached its minimum number of hits, which is by default 1, it will be marked as covered. ::

    sample_coverage(value, [msg_id_panel])
    sample_coverage(values, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | value              | in     | integer                      | Value to be sampled                                   |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | values             | in     | integer_vector               | Values to be sampled                                  |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.sample_coverage(10);
    my_coverpoint.sample_coverage((10,50));


set_coverage_weight()
----------------------------------------------------------------------------------------------------
Configures the weight of the coverpoint used for calculating the simulation coverage. Default value is 1. ::

    set_coverage_weight(weight, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | weight             | in     | positive                     | Weight of the coverpoint                              |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.set_coverage_weight(3);


set_coverage_goal()
----------------------------------------------------------------------------------------------------
Configures the coverpoint coverage goal. Default value is 100. ::

    set_coverage_goal(percentage, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | percentage         | in     | positive                     | Goal percentage of the coverpoint to cover            |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.set_coverage_goal(150);


get_coverage()
----------------------------------------------------------------------------------------------------
Returns the accumulated coverage for all the bins in the coverpoint. ::

    real := get_coverage(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    log(ID_SEQUENCER, to_string(my_coverpoint.get_coverage(VOID)));


coverage_completed()
----------------------------------------------------------------------------------------------------
Returns true if the accumulated coverage for all the bins in the coverpoint has reached the goal. Default goal is 100. ::

    boolean := coverage_completed(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    if my_coverpoint.coverage_completed(VOID) then
    ...
    end if;


print_summary()
----------------------------------------------------------------------------------------------------
Prints the coverpoint coverage summary containing all the bins, including illegal and ignored. The printing destination can be 
log and/or console and is defined by shared_default_log_destination in adaptations_pkg. ::

    print_summary(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.print_summary(VOID);
