**********************************************************************************************************************************
t_coverpoint (protected)
**********************************************************************************************************************************
Protected type containing the Functional Coverage functionality.

set_name()
----------------------------------------------------------------------------------------------------------------------------------
Configures the name of the coverpoint. The maximum length is C_FC_MAX_NAME_LENGTH defined in adaptations_pkg. Default value is 
"Covpt_<idx>". ::

    set_name(name)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | name               | in     | string                       | Name of the coverpoint used in logs and reports         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Example:
    my_coverpoint.set_name("ADDR_COVPT");


get_name()
----------------------------------------------------------------------------------------------------------------------------------
Returns the coverpoint's name. ::

    string := get_name(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    log(ID_SEQUENCER, "Coverpoint: " & my_coverpoint.get_name(VOID));


set_scope()
----------------------------------------------------------------------------------------------------------------------------------
Configures the scope used in the log messages. Default value is C_TB_SCOPE_DEFAULT and maximum length is C_LOG_SCOPE_WIDTH defined 
in adaptations_pkg. ::

    set_scope(scope)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Example:
    my_coverpoint.set_scope("MY_SCOPE");


get_scope()
----------------------------------------------------------------------------------------------------------------------------------
Returns the configured scope. ::

    string := get_scope(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    scope := my_coverpoint.get_scope(VOID);


set_overall_coverage_weight()
----------------------------------------------------------------------------------------------------------------------------------
Configures the weight of the coverpoint used when calculating the overall coverage. If set to 0, the coverpoint will be excluded 
from the overall coverage calculation. Default value is 1. ::

    set_overall_coverage_weight(weight, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | weight             | in     | natural                      | Weight of the coverpoint                              |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default  |
|          |                    |        |                              | value is shared_msg_id_panel.                         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Examples:
    my_coverpoint_1.set_overall_coverage_weight(3);  -- If only this coverpoint is covered, total coverage will be 75%
    my_coverpoint_2.set_overall_coverage_weight(1);  -- If only this coverpoint is covered, total coverage will be 25%
    my_coverpoint_3.set_overall_coverage_weight(0);  -- This coverpoint is excluded from the total coverage calculation


get_overall_coverage_weight()
----------------------------------------------------------------------------------------------------------------------------------
Returns the coverpoint's coverage weight. ::

    natural := get_overall_coverage_weight(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    log(ID_SEQUENCER, "Coverage Weight: " & to_string(my_coverpoint.get_overall_coverage_weight(VOID)));


set_bins_coverage_goal()
----------------------------------------------------------------------------------------------------------------------------------
Configures the coverpoint's bins coverage goal, which represents the percentage of the number of bins that need to be covered in 
the coverpoint. Default value is 100. ::

    set_bins_coverage_goal(percentage, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | percentage         | in     | positive range 1 to 100      | Goal percentage of the coverpoint's bins to cover     |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default  |
|          |                    |        |                              | value is shared_msg_id_panel.                         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    my_coverpoint.set_bins_coverage_goal(75); -- Cover only 75% of the total number of bins in the coverpoint


get_bins_coverage_goal()
----------------------------------------------------------------------------------------------------------------------------------
Returns the coverpoint's bins coverage goal. ::

    positive := get_bins_coverage_goal(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    log(ID_SEQUENCER, "Bins Goal: " & to_string(my_coverpoint.get_bins_coverage_goal(VOID)));


set_hits_coverage_goal()
----------------------------------------------------------------------------------------------------------------------------------
Configures the coverpoint's hits coverage goal, which represents the percentage of the min_hits that need to be covered for each 
bin in the coverpoint. Default value is 100. ::

    set_hits_coverage_goal(percentage, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | percentage         | in     | positive                     | Goal percentage of the coverpoint's min_hits to cover |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default  |
|          |                    |        |                              | value is shared_msg_id_panel.                         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Examples:
    my_coverpoint.set_hits_coverage_goal(50);  -- Cover only half the min_hits of each bin in the coverpoint
    my_coverpoint.set_hits_coverage_goal(200); -- Cover twice the min_hits of each bin in the coverpoint


get_hits_coverage_goal()
----------------------------------------------------------------------------------------------------------------------------------
Returns the coverpoint's hits coverage goal. ::

    positive := get_hits_coverage_goal(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    log(ID_SEQUENCER, "Hits Goal: " & to_string(my_coverpoint.get_hits_coverage_goal(VOID)));


set_illegal_bin_alert_level()
----------------------------------------------------------------------------------------------------------------------------------
Configures the alert level when an illegal bin is sampled. Default value is ERROR. ::

    set_illegal_bin_alert_level(alert_level, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert, e.g. ERROR           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default  |
|          |                    |        |                              | value is shared_msg_id_panel.                         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    my_coverpoint.set_illegal_bin_alert_level(WARNING);


get_illegal_bin_alert_level()
----------------------------------------------------------------------------------------------------------------------------------
Returns the alert level when an illegal bin is sampled. ::

    t_alert_level := get_illegal_bin_alert_level(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    log(ID_SEQUENCER, "Illegal bin alert level: " & to_upper(to_string(my_coverpoint.get_illegal_bin_alert_level(VOID))));


set_bin_overlap_alert_level()
----------------------------------------------------------------------------------------------------------------------------------
Configures the alert level when overlapping bins are sampled (not including ignore or invalid bins). Default value is NO_ALERT. ::

    set_bin_overlap_alert_level(alert_level, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | alert_level        | in     | :ref:`t_alert_level`         | Sets the severity for the alert, e.g. ERROR           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default  |
|          |                    |        |                              | value is shared_msg_id_panel.                         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    my_coverpoint.set_bin_overlap_alert_level(TB_WARNING);


get_bin_overlap_alert_level()
----------------------------------------------------------------------------------------------------------------------------------
Returns the alert level when overlapping bins are sampled. ::

    t_alert_level := get_bin_overlap_alert_level(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    log(ID_SEQUENCER, "Bin overlap alert level: " & to_upper(to_string(my_coverpoint.get_bin_overlap_alert_level(VOID))));


write_coverage_db()
----------------------------------------------------------------------------------------------------------------------------------
Writes the coverpoint model, configuration and accumulated counters to a file. ::

    write_coverage_db(file_name, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | file_name          | in     | string                       | Name of the file where to store the coverpoint data   |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default  |
|          |                    |        |                              | value is shared_msg_id_panel.                         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    my_coverpoint.write_coverage_db("my_coverpoint_db.txt");


load_coverage_db()
----------------------------------------------------------------------------------------------------------------------------------
Loads the coverpoint model, configuration and accumulated counters from a file. It also prints a coverage report for the loaded
coverpoint. ::

    load_coverage_db(file_name, [new_bins_acceptance, [alert_level_if_not_found, [report_verbosity, [msg_id_panel]]]])

+----------+--------------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name                     | Dir.   | Type                         | Description                                           |
+==========+==========================+========+==============================+=======================================================+
| constant | file_name                | in     | string                       | Name of the file where the coverpoint data is stored  |
+----------+--------------------------+--------+------------------------------+-------------------------------------------------------+
| constant | new_bins_acceptance      | in     | :ref:`t_new_bins_acceptance` | Defines whether to generate an alert when finding new |
|          |                          |        |                              | bins in the current coverpoint which are not in the   |
|          |                          |        |                              | loaded database. Default value is WARNING_ON_NEW_BINS.|
+----------+--------------------------+--------+------------------------------+-------------------------------------------------------+
| constant | alert_level_if_not_found | in     | :ref:`t_alert_level`         | Sets the severity of the alert when the file is not   |
|          |                          |        |                              | found. Default value is TB_ERROR.                     |
+----------+--------------------------+--------+------------------------------+-------------------------------------------------------+
| constant | report_verbosity         | in     | :ref:`t_report_verbosity`    | Verbosity of the coverage report printed when the     |
|          |                          |        |                              | coverpoint is loaded. Default value is HOLES_ONLY.    |
+----------+--------------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel             | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default  |
|          |                          |        |                              | value is shared_msg_id_panel.                         |
+----------+--------------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    my_coverpoint.load_coverage_db("my_coverpoint_db.txt");
    my_coverpoint.load_coverage_db("my_coverpoint_db.txt", ERROR_ON_NEW_BINS);
    my_coverpoint.load_coverage_db("my_coverpoint_db.txt", NO_ALERT_ON_NEW_BINS, TB_NOTE, VERBOSE);


clear_coverage()
----------------------------------------------------------------------------------------------------------------------------------
Resets the coverpoint's coverage by clearing all the bin hit counters. ::

    clear_coverage(VOID)
    clear_coverage(msg_id_panel)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default  |
|          |                    |        |                              | value is shared_msg_id_panel.                         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Examples:
    my_coverpoint.clear_coverage(VOID);
    my_coverpoint.clear_coverage(my_msg_id_panel);


set_num_allocated_bins()
----------------------------------------------------------------------------------------------------------------------------------
Defines the size of the memory allocated for the list of bins in the coverpoint. It cannot be smaller than the actual number of 
bins. Default value is C_FC_DEFAULT_INITIAL_NUM_BINS_ALLOCATED defined in adaptations_pkg. ::

    set_num_allocated_bins(value, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | value              | in     | positive                     | New size of the bin list                              |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default  |
|          |                    |        |                              | value is shared_msg_id_panel.                         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    my_coverpoint.set_num_allocated_bins(60);


set_num_allocated_bins_increment()
----------------------------------------------------------------------------------------------------------------------------------
Defines how much the list of bins will be increased in size when it is full and a new bin is added. Default value is 
C_FC_DEFAULT_NUM_BINS_ALLOCATED_INCREMENT defined in adaptations_pkg. ::

    set_num_allocated_bins_increment(value)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | value              | in     | positive                     | Size increment of the bin list                        |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    my_coverpoint.set_num_allocated_bins_increment(3);


delete_coverpoint()
----------------------------------------------------------------------------------------------------------------------------------
De-allocates the list of bins and resets all configuration settings to their default values. ::

    delete_coverpoint(VOID)
    delete_coverpoint(msg_id_panel)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default  |
|          |                    |        |                              | value is shared_msg_id_panel.                         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Examples:
    my_coverpoint.delete_coverpoint(VOID);
    my_coverpoint.delete_coverpoint(my_msg_id_panel);


.. _add_bins:

add_bins()
----------------------------------------------------------------------------------------------------------------------------------
Adds bins to the coverpoint. Must be used together with the :ref:`bin functions <bin_functions>` which return a t_new_bin_array. 
Bin functions may be concatenated to add several bins at once. ::

    add_bins(bin, min_hits, rand_weight, [bin_name, [msg_id_panel]])
    add_bins(bin, min_hits, [bin_name, [msg_id_panel]])
    add_bins(bin, [bin_name, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | bin                | in     | t_new_bin_array              | Array containing one or several bins                  |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | min_hits           | in     | positive                     | Minimum number of hits for the bin to be covered.     |
|          |                    |        |                              | Default value is 1. When using ignore or illegal bins,|
|          |                    |        |                              | this value does not need to be specified since it will|
|          |                    |        |                              | automatically be 0.                                   |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | rand_weight        | in     | natural                      | Randomization weight assigned to the bin. Default     |
|          |                    |        |                              | value is 1. When using ignore or illegal bins, this   |
|          |                    |        |                              | value does not need to be specified since it will     |
|          |                    |        |                              | automatically be 0.                                   |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | bin_name           | in     | string                       | Name of the bin. Max length is C_FC_MAX_NAME_LENGTH.  |
|          |                    |        |                              | The default value is "bin_<idx>", and is determined by|
|          |                    |        |                              | the C_FC_DEFAULT_BIN_NAME constant in the             |
|          |                    |        |                              | adaptations_pkg. If the call results in multiple bins |
|          |                    |        |                              | the bin name is indexed as described in               |
|          |                    |        |                              | :ref:`bin name <bin_name>`.                           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default  |
|          |                    |        |                              | value is shared_msg_id_panel.                         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Examples:
    my_coverpoint.add_bins(ignore_bin(0), "ignore_value");
    my_coverpoint.add_bins(bin(10), 5, 3, "low_value");
    my_coverpoint.add_bins(bin(20), 5, "middle_value");
    my_coverpoint.add_bins(bin(30) & bin(40) & bin(50), "high_values");
    my_coverpoint.add_bins(illegal_bin(100), "illegal_value");


add_cross() {bin_array}
----------------------------------------------------------------------------------------------------------------------------------
Adds a cross between two t_new_bin_array elements to the coverpoint. Must be used together with the :ref:`bin functions <bin_functions>` 
which return a t_new_bin_array. Bin functions may be concatenated to add several bins at once. ::

    add_cross(bin1, bin2, min_hits, rand_weight, [bin_name, [msg_id_panel]])
    add_cross(bin1, bin2, min_hits, [bin_name, [msg_id_panel]])
    add_cross(bin1, bin2, [bin_name, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | bin(n)             | in     | t_new_bin_array              | Array containing one or several bins                  |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | min_hits           | in     | positive                     | Minimum number of hits for the bin to be covered.     |
|          |                    |        |                              | Default value is 1. When using ignore or illegal bins,|
|          |                    |        |                              | this value does not need to be specified since it will|
|          |                    |        |                              | automatically be 0.                                   |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | rand_weight        | in     | natural                      | Randomization weight assigned to the bin. Default     |
|          |                    |        |                              | value is 1. When using ignore or illegal bins, this   |
|          |                    |        |                              | value does not need to be specified since it will     |
|          |                    |        |                              | automatically be 0.                                   |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | bin_name           | in     | string                       | Name of the bin. Max length is C_FC_MAX_NAME_LENGTH.  |
|          |                    |        |                              | The default value is "bin_<idx>", and is determined by|
|          |                    |        |                              | the C_FC_DEFAULT_BIN_NAME constant in the             |
|          |                    |        |                              | adaptations_pkg. If the call results in multiple cross|
|          |                    |        |                              | bins the bin name is indexed as described in          |
|          |                    |        |                              | :ref:`bin name <bin_name>`.                           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default  |
|          |                    |        |                              | value is shared_msg_id_panel.                         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Examples:
    my_cross.add_cross(ignore_bin(0), bin_range(0,63), "ignore_values");
    my_cross.add_cross(bin(10), bin_range(0,15), 5, 3, "low_values");
    my_cross.add_cross(bin(20), bin_range(16,31), 5, "middle_values");
    my_cross.add_cross(bin(30), bin_range(32,63), "high_values");
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
Adds a cross between two coverpoints to the coverpoint. Note that the coverpoints being crossed must contain at least one bin. ::

    add_cross(coverpoint1, coverpoint2, min_hits, rand_weight, [bin_name, [msg_id_panel]])
    add_cross(coverpoint1, coverpoint2, min_hits, [bin_name, [msg_id_panel]])
    add_cross(coverpoint1, coverpoint2, [bin_name, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| variable | coverpoint(n)      | inout  | t_coverpoint                 | Protected type containing a coverpoint                |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | min_hits           | in     | positive                     | Minimum number of hits for the bin to be covered.     |
|          |                    |        |                              | Default value is 1. When using ignore or illegal bins,|
|          |                    |        |                              | this value does not need to be specified since it will|
|          |                    |        |                              | automatically be 0.                                   |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | rand_weight        | in     | natural                      | Randomization weight assigned to the bin. Default     |
|          |                    |        |                              | value is 1. When using ignore or illegal bins, this   |
|          |                    |        |                              | value does not need to be specified since it will     |
|          |                    |        |                              | automatically be 0.                                   |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | bin_name           | in     | string                       | Name of the bin. Max length is C_FC_MAX_NAME_LENGTH.  |
|          |                    |        |                              | The default value is "bin_<idx>", and is determined by|
|          |                    |        |                              | the C_FC_DEFAULT_BIN_NAME constant in the             |
|          |                    |        |                              | adaptations_pkg. If the call results in multiple cross|
|          |                    |        |                              | bins the bin name is indexed as described in          |
|          |                    |        |                              | :ref:`bin name <bin_name>`.                           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default  |
|          |                    |        |                              | value is shared_msg_id_panel.                         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Examples:
    my_coverpoint_addr.add_bins(bin_vector(addr,0));
    my_coverpoint_size.add_bins(bin_range(0,127));
    my_cross.add_cross(my_coverpoint_addr, my_coverpoint_size, 5, 3, "cross_addr_size");

This procedure has overloads which support crossing up to 16 coverpoints. **Beta release only supports up to 5 crossed elements.** ::

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


is_defined()
----------------------------------------------------------------------------------------------------------------------------------
Returns true if the coverpoint contains at least one bin. ::

    boolean := is_defined(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    if my_coverpoint.is_defined(VOID) then
    ...
    end if;

.. _sample_coverage:

sample_coverage()
----------------------------------------------------------------------------------------------------------------------------------
Samples a value (or values for crossed bins) in a coverpoint. If the value matches a bin, it will increase its number of hits and 
once the bin has reached its minimum number of hits, which is by default 1, it will be marked as covered. ::

    sample_coverage(value, [msg_id_panel])
    sample_coverage(values, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | value              | in     | integer                      | Value to be sampled                                   |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | values             | in     | integer_vector               | Values to be sampled                                  |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default  |
|          |                    |        |                              | value is shared_msg_id_panel.                         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Examples:
    my_coverpoint.sample_coverage(10);
    my_coverpoint.sample_coverage((10,50));


get_coverage()
----------------------------------------------------------------------------------------------------------------------------------
Returns either the bins coverage or the hits coverage of the coverpoint. For an overview on the types of coverage click 
:ref:`here <func_cov_pkg_coverage_status>`. ::

    real := get_coverage(coverage_type, [percentage_of_goal])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | coverage_type      | in     | :ref:`t_coverage_type`       | Selects which coverage value to return, either BINS   |
|          |                    |        |                              | or HITS                                               |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | percentage_of_goal | in     | boolean                      | When true, the percentage of the covered goal will be |
|          |                    |        |                              | returned instead. Default value is false.             |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Examples:
    log(ID_SEQUENCER, "Bins Coverage: " & to_string(my_coverpoint.get_coverage(BINS),2) & "%");
    log(ID_SEQUENCER, "Hits Coverage: " & to_string(my_coverpoint.get_coverage(HITS),2) & "%");
    log(ID_SEQUENCER, "Bins % of Goal: " & to_string(my_coverpoint.get_coverage(BINS, percentage_of_goal => true),2) & "%");
    log(ID_SEQUENCER, "Hits % of Goal: " & to_string(my_coverpoint.get_coverage(HITS, percentage_of_goal => true),2) & "%");


coverage_completed()
----------------------------------------------------------------------------------------------------------------------------------
Returns true if the coverage of the coverpoint has reached the goal. Default goal is 100. For an overview on the types of coverage 
click :ref:`here <func_cov_pkg_coverage_status>`. ::

    boolean := coverage_completed(coverage_type)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | coverage_type      | in     | :ref:`t_coverage_type`       | Selects which coverage value to check, either BINS,   |
|          |                    |        |                              | HITS or BINS_AND_HITS                                 |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    if my_coverpoint.coverage_completed(BINS_AND_HITS) then
    ...
    end if;


report_coverage()
----------------------------------------------------------------------------------------------------------------------------------
Prints the coverpoint coverage summary containing all the bins. The printing destination can be log and/or console and is defined 
by shared_default_log_destination in adaptations_pkg. The report can also be printed to a separate file by using the file_name 
parameter. To see an example of the generated report click :ref:`here <func_cov_pkg_coverage_report>`. ::

    report_coverage(VOID)
    report_coverage(verbosity, [file_name, [open_mode, [rand_weight_col]]])

+----------+--------------------+--------+---------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                            | Description                                           |
+==========+====================+========+=================================+=======================================================+
| constant | VOID               | in     | t_void                          | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+---------------------------------+-------------------------------------------------------+
| constant | verbosity          | in     | :ref:`t_report_verbosity`       | Controls which bins are shown in the report. Default  |
|          |                    |        |                                 | value is NON_VERBOSE.                                 |
+----------+--------------------+--------+---------------------------------+-------------------------------------------------------+
| constant | file_name          | in     | string                          | Name of the file where the report will be written.    |
|          |                    |        |                                 | Default value is an empty string, which means do not  |
|          |                    |        |                                 | write to file.                                        |
+----------+--------------------+--------+---------------------------------+-------------------------------------------------------+
| constant | open_mode          | in     | file_open_kind                  | Describes the access to the file. Default value is    |
|          |                    |        |                                 | append_mode.                                          |
+----------+--------------------+--------+---------------------------------+-------------------------------------------------------+
| constant | rand_weight_col    | in     | :ref:`t_rand_weight_visibility` | Shows or hides the rand_weight column of the report.  |
|          |                    |        |                                 | Default value is HIDE_RAND_WEIGHT.                    |
+----------+--------------------+--------+---------------------------------+-------------------------------------------------------+

.. code-block::

    -- Examples:
    my_coverpoint.report_coverage(VOID);
    my_coverpoint.report_coverage(HOLES_ONLY);
    my_coverpoint.report_coverage(VERBOSE, "coverage_report.txt");
    my_coverpoint.report_coverage(VERBOSE, rand_weight_col => SHOW_RAND_WEIGHT);


report_config()
----------------------------------------------------------------------------------------------------------------------------------
Prints a report containing the coverpoint's configuration parameters. The report can also be printed to a separate file by using 
the file_name parameter. To see an example of the generated report click :ref:`here <func_cov_pkg_config_report>`. ::

    report_config(VOID)
    report_config(file_name, [open_mode])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | file_name          | in     | string                       | Name of the file where the report will be written.      |
|          |                    |        |                              | Default value is an empty string, which means do not    |
|          |                    |        |                              | write to file.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | open_mode          | in     | file_open_kind               | Describes the access to the file. Default value is      |
|          |                    |        |                              | append_mode.                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Example:
    my_coverpoint.report_config(VOID);
    my_coverpoint.report_config("config_report.txt");


rand()
----------------------------------------------------------------------------------------------------------------------------------
Returns a random value (or values for crossed bins) generated from the uncovered bins. Once all the bins have been covered, 
it will return a random value among all the valid bins. Note that ignore and illegal bins will never be selected for randomization. 
Additionally, the random value can be used to automatically sample coverage. For a complete overview on Optimized Randomization 
click :ref:`here <optimized_randomization>`.::

    integer        := rand(sampling, [msg_id_panel])
    integer_vector := rand(sampling, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | sampling           | in     | :ref:`t_rand_sample_cov`     | Whether or not to sample coverage with the generated  |
|          |                    |        |                              | random value.                                         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default  |
|          |                    |        |                              | value is shared_msg_id_panel.                         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Examples:
    addr     := my_coverpoint.rand(NO_SAMPLE_COV);
    addr_vec := my_coverpoint.rand(SAMPLE_COV);


set_rand_seeds()
----------------------------------------------------------------------------------------------------------------------------------
Configures the randomization seeds. Default values are set using the coverpoint's name at the moment it is initialized (when 
adding the first configuration or bin). ::

    set_rand_seeds(seed1, seed2)
    set_rand_seeds(seeds)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | seed1              | in     | positive                     | A positive number representing seed 1                 |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | seed2              | in     | positive                     | A positive number representing seed 2                 |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | seeds              | in     | t_positive_vector            | A 2-dimensional vector containing both seeds          |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Examples:
    my_coverpoint.set_rand_seeds(10, 100);
    my_coverpoint.set_rand_seeds(seed_vector);


get_rand_seeds()
----------------------------------------------------------------------------------------------------------------------------------
Returns the randomization seeds. ::

    get_rand_seeds(seed1, seed2)
    t_positive_vector(0 to 1) := get_rand_seeds(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| variable | seed1              | out    | positive                     | A positive number representing seed 1                 |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| variable | seed2              | out    | positive                     | A positive number representing seed 2                 |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Examples:
    my_coverpoint.get_rand_seeds(seed1, seed2);
    seed_vector := my_coverpoint.get_rand_seeds(VOID);
