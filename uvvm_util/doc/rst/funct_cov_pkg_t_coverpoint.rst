**********************************************************************************************************************************
t_coverpoint (protected)
**********************************************************************************************************************************
Protected type containing all the coverage functionality.

set_name()
----------------------------------------------------------------------------------------------------------------------------------
Configures the name of the coverpoint. The maximum length is C_FC_MAX_NAME_LENGTH defined in adaptations_pkg. ::

    set_name(name)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | name               | in     | string                       | Name of the coverpoint used in logs and reports         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.set_name("ADDR_COVPT");


get_name()
----------------------------------------------------------------------------------------------------------------------------------
Returns the coverpoint's name. ::

    string := get_name(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    log(ID_SEQUENCER, my_coverpoint.get_name(VOID));


set_scope()
----------------------------------------------------------------------------------------------------------------------------------
Configures the scope used in the log messages. Default is C_TB_SCOPE_DEFAULT and maximum length is C_LOG_SCOPE_WIDTH defined in 
adaptations_pkg. ::

    set_scope(scope)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.set_scope("MY_SCOPE");


get_scope()
----------------------------------------------------------------------------------------------------------------------------------
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


set_coverage_weight()
----------------------------------------------------------------------------------------------------------------------------------
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


get_coverage_weight()
----------------------------------------------------------------------------------------------------------------------------------
Returns the coverpoint's coverage weight. ::

    positive := get_coverage_weight(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    log(ID_SEQUENCER, to_string(my_coverpoint.get_coverage_weight(VOID)));


set_coverage_goal()
----------------------------------------------------------------------------------------------------------------------------------
Configures the coverpoint's coverage goal. Default value is 100. ::

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


get_coverage_goal()
----------------------------------------------------------------------------------------------------------------------------------
Returns the coverpoint's coverage goal. ::

    positive := get_coverage_goal(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    log(ID_SEQUENCER, to_string(my_coverpoint.get_coverage_goal(VOID)));


set_illegal_bin_alert_level()
----------------------------------------------------------------------------------------------------------------------------------
Configures the alert level when an illegal bin is sampled. ::

    set_illegal_bin_alert_level(alert_level, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | alert_level        | in     | t_alert_level                | Sets the severity for the alert, e.g. ERROR           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.set_illegal_bin_alert_level(WARNING);


get_illegal_bin_alert_level()
----------------------------------------------------------------------------------------------------------------------------------
Returns the alert level when an illegal bin is sampled. ::

    t_alert_level := get_illegal_bin_alert_level(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    log(ID_SEQUENCER, to_string(my_coverpoint.get_illegal_bin_alert_level(VOID)));


set_bin_overlap_detection()
----------------------------------------------------------------------------------------------------------------------------------
Configures if a TB_WARNING alert should be generated when overlapping bins are sampled (not including ignore or invalid bins). ::

    set_bin_overlap_detection(enable, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | enable             | in     | boolean                      | Enables/disables the alert                            |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.set_bin_overlap_detection(true);


get_bin_overlap_detection()
----------------------------------------------------------------------------------------------------------------------------------
Returns true when the alert for overlapping bins is enabled otherwise returns false. ::

    boolean := get_bin_overlap_detection(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    log(ID_SEQUENCER, to_string(my_coverpoint.get_bin_overlap_detection(VOID)));


write_coverage_db()
----------------------------------------------------------------------------------------------------------------------------------
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
    my_coverpoint.write_coverage_db("my_coverpoint_db.txt");


load_coverage_db()
----------------------------------------------------------------------------------------------------------------------------------
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
    my_coverpoint.load_coverage_db("my_coverpoint_db.txt");


clear_coverage()
----------------------------------------------------------------------------------------------------------------------------------
Resets the coverpoint's coverage by clearing all the bin hit counters. ::

    clear_coverage(VOID)
    clear_coverage(msg_id_panel)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.clear_coverage(VOID);
    my_coverpoint.clear_coverage(my_msg_id_panel);


set_num_bins_allocated()
----------------------------------------------------------------------------------------------------------------------------------
Defines the size of the memory allocated for the list of bins in the coverpoint. It cannot be smaller than the actual number of 
bins. ::

    set_num_bins_allocated(value, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | value              | in     | positive                     | New size of the bin list                              |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.set_num_bins_allocated(60);


set_num_bins_allocated_increment()
----------------------------------------------------------------------------------------------------------------------------------
Defines how much the list of bins will be increased in size when it is full and a new bin is added. ::

    set_num_bins_allocated_increment(value)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | value              | in     | positive                     | Size increment of the bin list                        |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.set_num_bins_allocated_increment(3);


add_bins()
----------------------------------------------------------------------------------------------------------------------------------
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
| constant | bin_name           | in     | string                       | Name of the bin. Max length is C_FC_MAX_NAME_LENGTH   |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.add_bins(bin(10), 5, 3, "low_value");
    my_coverpoint.add_bins(bin(20), 5, "middle_value");
    my_coverpoint.add_bins(bin(30) & bin(40) & bin(50), "high_values");


add_cross() {bin_array}
----------------------------------------------------------------------------------------------------------------------------------
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
| constant | bin_name           | in     | string                       | Name of the bin. Max length is C_FC_MAX_NAME_LENGTH   |
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
----------------------------------------------------------------------------------------------------------------------------------
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
| constant | bin_name           | in     | string                       | Name of the bin. Max length is C_FC_MAX_NAME_LENGTH   |
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
----------------------------------------------------------------------------------------------------------------------------------
Returns a random value (or values for crossed bins) generated from the uncovered bins. Once all the bins have been covered, 
it will return a random value among all the valid bins. Note that ignore and illegal bins will never be selected for randomization. ::

    integer        := rand(VOID)
    integer        := rand(msg_id_panel)
    integer_vector := rand(VOID)
    integer_vector := rand(msg_id_panel)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    addr := my_coverpoint.rand(VOID);
    addr := my_coverpoint.rand(my_msg_id_panel);
    addr_vec := my_coverpoint.rand(VOID);
    addr_vec := my_coverpoint.rand(my_msg_id_panel);


is_defined()
----------------------------------------------------------------------------------------------------------------------------------
Returns true if the coverpoint contains at least one bin. ::

    boolean := is_defined(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    if my_coverpoint.is_defined(VOID) then
    ...
    end if;


sample_coverage()
----------------------------------------------------------------------------------------------------------------------------------
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


get_coverage()
----------------------------------------------------------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------------------------------------------------
Prints the coverpoint coverage summary containing all the bins. By default, illegal and ignore bins are not printed out, with the 
exception of illegal bins that have at least one hit. Using the parameter verbosity, all illegal and ignore bins can be printed. 
The printing destination can be log and/or console and is defined by shared_default_log_destination in adaptations_pkg. ::

    print_summary(VOID)
    print_summary(verbosity)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | verbosity          | in     | t_report_verbosity           | Controls verbosity of the report                      |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.print_summary(VOID);
    my_coverpoint.print_summary(VERBOSE);


report_config()
----------------------------------------------------------------------------------------------------------------------------------
Prints a report containing the coverpoints's configuration parameters. ::

    report_config(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_coverpoint.report_config(VOID);
