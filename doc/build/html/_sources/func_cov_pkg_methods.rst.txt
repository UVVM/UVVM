**********************************************************************************************************************************
Methods
**********************************************************************************************************************************
Procedures and functions complementing the t_coverpoint functionality.

.. _bin_functions:

bin()
----------------------------------------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing a bin with a single value or multiple values. When having multiple values in a bin, only one 
of them needs to be sampled for the bin to collect coverage. The maximum number of multiple values is C_FC_MAX_NUM_BIN_VALUES 
defined in adaptations_pkg. ::

    t_new_bin_array := bin(value)
    t_new_bin_array := bin(set_of_values)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | value              | in     | integer                      | Single value contained in the bin                     |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | set_of_values      | in     | integer_vector               | Set of values contained in the bin                    |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Examples:
    my_coverpoint.add_bins(bin(10));
    my_coverpoint.add_bins(bin((5,10,15,20)));


bin_range()
----------------------------------------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing a bin with a range of values. When num_bins is different than 1, several bins are created 
instead by dividing the range into num_bins. If the division has a residue, it is spread equally starting from the last bins. If 
num_bins is 0 or greater than the number of values in the range, then a single bin is created for each value. ::

    t_new_bin_array := bin_range(min_value, max_value, [num_bins])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | min_value          | in     | integer                      | Minimum value in the range to create the bins         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | max_value          | in     | integer                      | Maximum value in the range to create the bins         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | num_bins           | in     | natural                      | Number of bins to divide the range into. Default is 1 |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Examples:
    my_coverpoint.add_bins(bin_range(10,20));    -- creates 1 bin:   10 to 20
    my_coverpoint.add_bins(bin_range(10,20,4));  -- creates 4 bins:  10 to 11, 12 to 14, 15 to 17, 18 to 20
    my_coverpoint.add_bins(bin_range(10,20,0));  -- creates 11 bins: 10,11,12,13,14,15,16,17,18,19,20
    my_coverpoint.add_bins(bin_range(10,20,11)); -- creates 11 bins: 10,11,12,13,14,15,16,17,18,19,20
    my_coverpoint.add_bins(bin_range(10,20,20)); -- creates 11 bins: 10,11,12,13,14,15,16,17,18,19,20


bin_vector()
----------------------------------------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing a bin with a vector's range. When num_bins is different than 1, several bins are created 
instead by dividing the range into num_bins. If the division has a residue, it is spread equally starting from the last bins. If 
num_bins is 0 or greater than the number of values in the vector's range, then a single bin is created for each value. ::

    t_new_bin_array := bin_vector(vector, [num_bins])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | vector             | in     | std_logic_vector             | Vector used to create the bins                        |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | num_bins           | in     | natural                      | Number of bins to divide the range into. Default is 1 |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Examples:
    signal address : std_logic_vector(7 downto 0);
    ...
    my_coverpoint.add_bins(bin_vector(address));   -- creates 1 bin:    0 to 255
    my_coverpoint.add_bins(bin_vector(address,4)); -- creates 4 bins:   0 to 63, 64 to 127, 128 to 191, 192 to 255
    my_coverpoint.add_bins(bin_vector(address,0)); -- creates 256 bins: 0, 1, 2, ..., 254, 255

.. note::

    This function only supports vector sizes up to 31 bits, as an integer cannot represent higher values than 2^31-1.


bin_transition()
----------------------------------------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing a bin with a transition of values. The maximum number of transition values is 
C_FC_MAX_NUM_BIN_VALUES defined in adaptations_pkg. ::

    t_new_bin_array := bin_transition(set_of_values)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | set_of_values      | in     | integer_vector               | Transition of values contained in the bin             |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    my_coverpoint.add_bins(bin_transition(1,2,9,10));


ignore_bin()
----------------------------------------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing an ignore bin with a single value. ::

    t_new_bin_array := ignore_bin(value)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | value              | in     | integer                      | Single value contained in the bin                     |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    my_coverpoint.add_bins(ignore_bin(50));


ignore_bin_range()
----------------------------------------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing an ignore bin with a range of values. ::

    t_new_bin_array := ignore_bin_range(min_value, max_value)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | min_value          | in     | integer                      | Minimum value in the range to create the bin          |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | max_value          | in     | integer                      | Maximum value in the range to create the bin          |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    my_coverpoint.add_bins(ignore_bin_range(50,60));


ignore_bin_transition()
----------------------------------------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing an ignore bin with a transition of values. The maximum number of transition values is 
C_FC_MAX_NUM_BIN_VALUES defined in adaptations_pkg. ::

    t_new_bin_array := ignore_bin_transition(set_of_values)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | set_of_values      | in     | integer_vector               | Transition of values contained in the bin             |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    my_coverpoint.add_bins(ignore_bin_transition(20,21,22,30));


illegal_bin()
----------------------------------------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing an illegal bin with a single value. ::

    t_new_bin_array := illegal_bin(value)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | value              | in     | integer                      | Single value contained in the bin                     |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    my_coverpoint.add_bins(illegal_bin(100));


illegal_bin_range()
----------------------------------------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing an illegal bin with a range of values. ::

    t_new_bin_array := illegal_bin_range(min_value, max_value)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | min_value          | in     | integer                      | Minimum value in the range to create the bin          |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | max_value          | in     | integer                      | Maximum value in the range to create the bin          |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    my_coverpoint.add_bins(illegal_bin_range(100,200));


illegal_bin_transition()
----------------------------------------------------------------------------------------------------------------------------------
Returns a t_new_bin_array containing an illegal bin with a transition of values. The maximum number of transition values is 
C_FC_MAX_NUM_BIN_VALUES defined in adaptations_pkg. ::

    t_new_bin_array := illegal_bin_transition(set_of_values)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | set_of_values      | in     | integer_vector               | Transition of values contained in the bin             |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    my_coverpoint.add_bins(illegal_bin_transition(30,10,0));


fc_set_covpts_coverage_goal()
----------------------------------------------------------------------------------------------------------------------------------
Configures the coverpoints coverage goal, which represents the percentage of the number of coverpoints that need to be covered. 
Default value is 100. ::

    fc_set_covpts_coverage_goal(percentage, [scope, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | percentage         | in     | positive range 1 to 100      | Goal percentage of the coverpoints to cover             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default    |
|          |                    |        |                              | value is shared_msg_id_panel.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Example:
    fc_set_covpts_coverage_goal(75); -- Cover only 75% of the total number of coverpoints


fc_get_covpts_coverage_goal()
----------------------------------------------------------------------------------------------------------------------------------
Returns the coverpoints coverage goal. ::

    positive := fc_get_covpts_coverage_goal(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    log(ID_SEQUENCER, "Covpts goal: " & to_string(fc_get_covpts_coverage_goal(VOID)));


fc_get_overall_coverage()
----------------------------------------------------------------------------------------------------------------------------------
Returns either the coverpoints coverage, bins coverage or hits coverage accumulated from all the coverpoints. For an overview on 
the types of coverage click :ref:`here <func_cov_pkg_coverage_status>`. ::

    real := fc_get_overall_coverage(coverage_type)

+----------+--------------------+--------+--------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                           | Description                                           |
+==========+====================+========+================================+=======================================================+
| constant | coverage_type      | in     | :ref:`t_overall_coverage_type` | Selects which coverage value to return                |
+----------+--------------------+--------+--------------------------------+-------------------------------------------------------+

.. code-block::

    -- Examples:
    log(ID_SEQUENCER, "Covpts Overall Coverage: " & to_string(fc_get_overall_coverage(COVPTS),2) & "%");
    log(ID_SEQUENCER, "Bins Overall Coverage: " & to_string(fc_get_overall_coverage(BINS),2) & "%");
    log(ID_SEQUENCER, "Hits Overall Coverage: " & to_string(fc_get_overall_coverage(HITS),2) & "%");


fc_overall_coverage_completed()
----------------------------------------------------------------------------------------------------------------------------------
Returns true if the coverpoints coverage has reached the goal. Default goal is 100. ::

    boolean := fc_overall_coverage_completed(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    if fc_overall_coverage_completed(VOID) then
    ...
    end if;


fc_report_overall_coverage()
----------------------------------------------------------------------------------------------------------------------------------
Prints the overall coverage summary for all the coverpoints in the testbench. The printing destination can be log and/or console 
and is defined by shared_default_log_destination in adaptations_pkg. The report can also be printed to a separate file by using 
the file_name parameter. To see an example of the generated report click :ref:`here <func_cov_pkg_coverage_report>`. ::

    fc_report_overall_coverage(VOID)
    fc_report_overall_coverage(verbosity, [file_name, [open_mode, [scope]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | verbosity          | in     | :ref:`t_report_verbosity`    | Controls if the coverpoints are shown in the report.    |
|          |                    |        |                              | Default value is NON_VERBOSE.                           |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | file_name          | in     | string                       | Name of the file where the report will be written.      |
|          |                    |        |                              | Default value is an empty string, which means do not    |
|          |                    |        |                              | write to file.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | open_mode          | in     | file_open_kind               | Describes the access to the file. Default value is      |
|          |                    |        |                              | append_mode.                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates |
|          |                    |        |                              | Default value is C_TB_SCOPE_DEFAULT.                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    fc_report_overall_coverage(VOID);
    fc_report_overall_coverage(VERBOSE);
    fc_report_overall_coverage(HOLES_ONLY, "coverage_report.txt");
