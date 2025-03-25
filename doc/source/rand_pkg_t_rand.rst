**********************************************************************************************************************************
t_rand (protected)
**********************************************************************************************************************************
Protected type containing the Enhanced Randomization functionality.

.. _random_generator:

The expression 'random generator' refers to the specific variable instance of *t_rand*.

Common configuration
==================================================================================================================================

set_name()
----------------------------------------------------------------------------------------------------------------------------------
Configures the name of the :ref:`random generator <random_generator>`. The maximum length is C_RAND_MAX_NAME_LENGTH defined in 
adaptations_pkg. Default value is \**unnamed\**. ::

    set_name(name)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | name               | in     | string                       | Name of the random generator used in the reports        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.set_name("SIZE_RAND_GEN");


get_name()
----------------------------------------------------------------------------------------------------------------------------------
Returns the random :ref:`random generator's <random_generator>` name. ::

    string := get_name(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    log(ID_SEQUENCER, "Random generator: " & my_rand.get_name(VOID));


set_scope()
----------------------------------------------------------------------------------------------------------------------------------
Configures the scope used by the log methods. Default value is C_TB_SCOPE_DEFAULT and maximum length is C_LOG_SCOPE_WIDTH defined 
in adaptations_pkg. ::

    set_scope(scope)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Example 1:
    my_rand.set_scope("MY_SCOPE");

    -- Example 2:
    p_uart_tx : process
      constant C_SCOPE : string := "UART_TX";
    begin
      my_rand.set_scope(C_SCOPE & "_RAND");
      ...
    end process p_uart_tx;

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
    scope := my_rand.get_scope(VOID);


set_rand_dist()
----------------------------------------------------------------------------------------------------------------------------------
Configures the randomization distribution to be used with the ``rand()`` functions. Default value is UNIFORM. For an overview on 
distributions click :ref:`here <rand_pkg_distributions>`. ::

    set_rand_dist(rand_dist, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | rand_dist          | in     | :ref:`t_rand_dist`           | Randomization distribution, e.g. UNIFORM, GAUSSIAN    |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default  |
|          |                    |        |                              | value is shared_msg_id_panel.                         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.set_rand_dist(GAUSSIAN);


get_rand_dist()
----------------------------------------------------------------------------------------------------------------------------------
Returns the configured randomization distribution. ::

    t_rand_dist := get_rand_dist(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    log(ID_SEQUENCER, "Distribution: " & to_upper(to_string(my_rand.get_rand_dist(VOID))));


set_rand_dist_mean()
----------------------------------------------------------------------------------------------------------------------------------
Configures the mean value for the randomization distribution. If not configured, the value depends on the parameters of each 
``rand()`` call: **(max_range-min_range)/2** (note that this default value has no special meaning other than giving a fair 
distribution curve). ::

    set_rand_dist_mean(mean, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | mean               | in     | real                         | Mean value for the distribution                       |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default  |
|          |                    |        |                              | value is shared_msg_id_panel.                         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.set_rand_dist_mean(5.0);


get_rand_dist_mean()
----------------------------------------------------------------------------------------------------------------------------------
Returns the configured mean value. If not configured, it will return 0.0 and print a TB_NOTE mentioning that the default value is 
being used (since it depends on the parameters of each ``rand()`` call). ::

    real := get_rand_dist_mean(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    log(ID_SEQUENCER, "Mean: " & to_string(my_rand.get_rand_dist_mean(VOID),2));


clear_rand_dist_mean()
----------------------------------------------------------------------------------------------------------------------------------
Clears the configured mean value. A value depending on the parameters of each ``rand()`` call will be used instead: 
**(max_range-min_range)/2** (note that this default value has no special meaning other than giving a fair distribution curve). ::

    clear_rand_dist_mean(VOID)
    clear_rand_dist_mean(msg_id_panel)

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
    my_rand.clear_rand_dist_mean(VOID);
    my_rand.clear_rand_dist_mean(my_msg_id_panel);


set_rand_dist_std_deviation()
----------------------------------------------------------------------------------------------------------------------------------
Configures the standard deviation value for the randomization distribution. If not configured, the value depends on the parameters 
of each ``rand()`` call: **(max_range-min_range)/6** (note that this default value has no special meaning other than giving a fair 
distribution curve). ::

    set_rand_dist_std_deviation(std_deviation, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | std_deviation      | in     | real                         | Standard deviation value for the distribution.        |
|          |                    |        |                              | Must be a positive value                              |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default  |
|          |                    |        |                              | value is shared_msg_id_panel.                         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.set_rand_dist_std_deviation(1.0);


get_rand_dist_std_deviation()
----------------------------------------------------------------------------------------------------------------------------------
Returns the configured standard deviation value. If not configured, it will return 0.0 and print a TB_NOTE mentioning that the 
default value is being used (since it depends on the parameters of each ``rand()`` call). ::

    real := get_rand_dist_std_deviation(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    log(ID_SEQUENCER, "Std. Deviation: " & to_string(my_rand.get_rand_dist_std_deviation(VOID),2));


clear_rand_dist_std_deviation()
----------------------------------------------------------------------------------------------------------------------------------
Clears the configured standard deviation value. A value depending on the parameters of each ``rand()`` call will be used instead: 
**(max_range-min_range)/6** (note that this default value has no special meaning other than giving a fair distribution curve). ::

    clear_rand_dist_std_deviation(VOID)
    clear_rand_dist_std_deviation(msg_id_panel)

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
    my_rand.clear_rand_dist_std_deviation(VOID);
    my_rand.clear_rand_dist_std_deviation(my_msg_id_panel);


set_range_weight_default_mode()
----------------------------------------------------------------------------------------------------------------------------------
Configures the default range weight mode for the weighted randomization distribution. Default value is COMBINED_WEIGHT. For an 
overview on weighted randomization click :ref:`here <rand_pkg_weighted>`. ::

    set_range_weight_default_mode(mode, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | mode               | in     | :ref:`t_weight_mode`         | How to divide the weight among a range of values      |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default  |
|          |                    |        |                              | value is shared_msg_id_panel.                         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.set_range_weight_default_mode(INDIVIDUAL_WEIGHT);


get_range_weight_default_mode()
----------------------------------------------------------------------------------------------------------------------------------
Returns the default range weight mode. ::

    t_weight_mode := get_range_weight_default_mode(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    log(ID_SEQUENCER, "Weight default mode: " & to_upper(to_string(my_rand.get_range_weight_default_mode(VOID))));


clear_rand_cyclic()
----------------------------------------------------------------------------------------------------------------------------------
Clears the state of the cyclic random generation. De-allocates the list/queue used to store the generated numbers. For an overview 
on cyclic randomization click :ref:`here <rand_pkg_cyclic>`. ::

    clear_rand_cyclic(VOID)
    clear_rand_cyclic(msg_id_panel)

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
    my_rand.clear_rand_cyclic(VOID);
    my_rand.clear_rand_cyclic(my_msg_id_panel);


report_config()
----------------------------------------------------------------------------------------------------------------------------------
Prints a report containing the :ref:`random generator's <random_generator>` configuration parameters. To see an example of the 
generated report click :ref:`here <rand_pkg_config_report>`. ::

    report_config(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.report_config(VOID);


set_rand_seeds()
----------------------------------------------------------------------------------------------------------------------------------
Configures the randomization seeds by using a string or the two actual seed values. Default values are defined by C_RAND_INIT_SEED_1 
and C_RAND_INIT_SEED_2 in adaptations_pkg. ::

    set_rand_seeds(str)
    set_rand_seeds(seed1, seed2)
    set_rand_seeds(seeds)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | str                | in     | string                       | A string from which the seeds will be generated       |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | seed1              | in     | positive                     | A positive number representing seed 1                 |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | seed2              | in     | positive                     | A positive number representing seed 2                 |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | seeds              | in     | t_positive_vector            | A 2-dimensional vector containing both seeds          |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    -- Examples:
    my_rand.set_rand_seeds(my_rand'instance_name);
    my_rand.set_rand_seeds(10, 100);
    my_rand.set_rand_seeds(seed_vector);


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
    my_rand.get_rand_seeds(seed1, seed2);
    seed_vector := my_rand.get_rand_seeds(VOID);


Single-method approach
==================================================================================================================================

rand()
----------------------------------------------------------------------------------------------------------------------------------

.. _rand_int:

return integer
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random integer value. For more information on the probability distribution click :ref:`here <rand_pkg_distributions>`. ::

    integer := rand(min_value, max_value, [cyclic_mode, [msg_id_panel]])
    integer := rand(specifier, set_of_values, [cyclic_mode, [msg_id_panel]])
    integer := rand(min_value, max_value, specifier, value, [cyclic_mode, [msg_id_panel]])
    integer := rand(min_value, max_value, specifier, set_of_values, [cyclic_mode, [msg_id_panel]])
    integer := rand(min_value, max_value, specifier1, value1, specifier2, value2, [cyclic_mode, [msg_id_panel]])
    integer := rand(min_value, max_value, specifier1, value1, specifier2, set_of_values2, [cyclic_mode, [msg_id_panel]])
    integer := rand(min_value, max_value, specifier1, set_of_values1, specifier2, set_of_values2, [cyclic_mode, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | min_value          | in     | integer                      | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | integer                      | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | specifier          | in     | :ref:`t_value_specifier`     | Defines how to handle a single value or a set of values       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | value              | in     | integer                      | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_of_values      | in     | integer_vector               | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | cyclic_mode        | in     | :ref:`t_cyclic`              | Whether cyclic mode is enabled or disabled. Default value is  |
|          |                    |        |                              | NON_CYCLIC.                                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Examples:
    rand_int := my_rand.rand(-50, 50);
    rand_int := my_rand.rand(ONLY, (-20,-10,0,10,20));
    rand_int := my_rand.rand(-50, 50, ADD,(60));
    rand_int := my_rand.rand(-50, 50, EXCL,(-25,25));
    rand_int := my_rand.rand(-50, 50, ADD,(60), EXCL,(25));
    rand_int := my_rand.rand(-50, 50, ADD,(60), EXCL,(-25,25));
    rand_int := my_rand.rand(-50, 50, ADD,(-60,60,70,80), EXCL,(-25,25), CYCLIC);


.. _rand_real:

return real
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random real value. For more information on the probability distribution click :ref:`here <rand_pkg_distributions>`. ::

    real := rand(min_value, max_value, [msg_id_panel])
    real := rand(specifier, set_of_values, [msg_id_panel])
    real := rand(min_value, max_value, specifier, value, [msg_id_panel])
    real := rand(min_value, max_value, specifier, set_of_values, [msg_id_panel])
    real := rand(min_value, max_value, specifier1, value1, specifier2, value2, [msg_id_panel])
    real := rand(min_value, max_value, specifier1, value1, specifier2, set_of_values2, [msg_id_panel])
    real := rand(min_value, max_value, specifier1, set_of_values1, specifier2, set_of_values2, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | min_value          | in     | real                         | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | real                         | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | specifier          | in     | :ref:`t_value_specifier`     | Defines how to handle a single value or a set of values       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | value              | in     | real                         | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_of_values      | in     | real_vector                  | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Examples:
    rand_real := my_rand.rand(0.0, 9.99);
    rand_real := my_rand.rand(ONLY, (0.5,1.0,1.5,2.0));
    rand_real := my_rand.rand(0.0, 9.99, ADD,(20.0));
    rand_real := my_rand.rand(0.0, 9.99, EXCL,(5.0,6.0));
    rand_real := my_rand.rand(0.0, 9.99, ADD,(20.0), EXCL,(5.0));
    rand_real := my_rand.rand(0.0, 9.99, ADD,(20.0), EXCL,(5.0,6.0));
    rand_real := my_rand.rand(0.0, 9.99, ADD,(20.0,30.0,40.0), EXCL,(5.0,6.0));


.. _rand_time:

return time
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random time value. For more information on the probability distribution click :ref:`here <rand_pkg_distributions>`. ::

    time := rand(min_value, max_value, [time_resolution], [msg_id_panel])
    time := rand(specifier, set_of_values, [msg_id_panel])
    time := rand(min_value, max_value, [time_resolution], specifier, value, [msg_id_panel])
    time := rand(min_value, max_value, [time_resolution], specifier, set_of_values, [msg_id_panel])
    time := rand(min_value, max_value, [time_resolution], specifier1, value1, specifier2, value2, [msg_id_panel])
    time := rand(min_value, max_value, [time_resolution], specifier1, value1, specifier2, set_of_values2, [msg_id_panel])
    time := rand(min_value, max_value, [time_resolution], specifier1, set_of_values1, specifier2, set_of_values2, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | min_value          | in     | time                         | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | time                         | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | time_resolution    | in     | time                         | Defines how many values can be generated between min_value and|
|          |                    |        |                              | max_value. If the given resolution is too small for the range,|
|          |                    |        |                              | a TB_WARNING will be printed once. Default value is the       |
|          |                    |        |                              | smallest time unit between the min and max parameters.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | specifier          | in     | :ref:`t_value_specifier`     | Defines how to handle a single value or a set of values       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | value              | in     | time                         | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_of_values      | in     | time_vector                  | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Examples:
    rand_time := my_rand.rand(1 us, 100 us);         -- Generates random values with a resolution of 1 us
    rand_time := my_rand.rand(1 us, 100 us, ns);     -- Generates random values with a resolution of 1 ns
    rand_time := my_rand.rand(1 us, 100 us, 100 ns); -- Generates random values with a resolution of 100 ns
    rand_time := my_rand.rand(ONLY, (5 us, 10 us, 15 us, 20 us));
    rand_time := my_rand.rand(1 ns, 10 ns, ADD,(20 ns));
    rand_time := my_rand.rand(1 ns, 10 ns, EXCL,(5 ns, 6 ns));
    rand_time := my_rand.rand(1 ns, 10 ns, ADD,(20 ns), EXCL,(5 ns));
    rand_time := my_rand.rand(1 ns, 10 ns, ADD,(20 ns), EXCL,(5 ns, 6 ns));
    rand_time := my_rand.rand(1 ns, 10 ns, ADD,(20 ns, 30 ns, 40 ns), EXCL,(5 ns, 6 ns));


.. _rand_int_vec:

return integer_vector
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a vector of random integer values. For more information on the probability distribution click :ref:`here <rand_pkg_distributions>`. ::

    integer_vector := rand(length, min_value, max_value, [uniqueness, [cyclic_mode, [msg_id_panel]]])
    integer_vector := rand(length, specifier, set_of_values, [uniqueness, [cyclic_mode, [msg_id_panel]]])
    integer_vector := rand(length, min_value, max_value, specifier, value, [uniqueness, [cyclic_mode, [msg_id_panel]]])
    integer_vector := rand(length, min_value, max_value, specifier, set_of_values, [uniqueness, [cyclic_mode, [msg_id_panel]]])
    integer_vector := rand(length, min_value, max_value, specifier1, value1, specifier2, value2, [uniqueness, [cyclic_mode, [msg_id_panel]]])
    integer_vector := rand(length, min_value, max_value, specifier1, value1, specifier2, set_of_values2, [uniqueness, [cyclic_mode, [msg_id_panel]]])
    integer_vector := rand(length, min_value, max_value, specifier1, set_of_values1, specifier2, set_of_values2, [uniqueness, [cyclic_mode, [msg_id_panel]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | min_value          | in     | integer                      | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | integer                      | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | specifier          | in     | :ref:`t_value_specifier`     | Defines how to handle a single value or a set of values       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | value              | in     | integer                      | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_of_values      | in     | integer_vector               | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | uniqueness         | in     | :ref:`t_uniqueness`          | Whether the values in the vector should be unique or not.     |
|          |                    |        |                              | Default value is NON_UNIQUE.                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | cyclic_mode        | in     | :ref:`t_cyclic`              | Whether cyclic mode is enabled or disabled. Default value is  |
|          |                    |        |                              | NON_CYCLIC.                                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Examples:
    rand_int_vec := my_rand.rand(rand_int_vec'length, -50, 50);
    rand_int_vec := my_rand.rand(rand_int_vec'length, ONLY, (-20,-10,0,10,20));
    rand_int_vec := my_rand.rand(rand_int_vec'length, -50, 50, ADD,(60));
    rand_int_vec := my_rand.rand(rand_int_vec'length, -50, 50, EXCL,(-25,25));
    rand_int_vec := my_rand.rand(rand_int_vec'length, -50, 50, ADD,(60), EXCL,(25));
    rand_int_vec := my_rand.rand(rand_int_vec'length, -50, 50, ADD,(60), EXCL,(-25,25), UNIQUE);
    rand_int_vec := my_rand.rand(rand_int_vec'length, -50, 50, ADD,(-60,60,70,80), EXCL,(-25,25), NON_UNIQUE, CYCLIC);


.. _rand_real_vec:

return real_vector
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a vector of random real values. For more information on the probability distribution click :ref:`here <rand_pkg_distributions>`. ::

    real_vector := rand(length, min_value, max_value, [uniqueness, [msg_id_panel]])
    real_vector := rand(length, specifier, set_of_values, [uniqueness, [msg_id_panel]])
    real_vector := rand(length, min_value, max_value, specifier, value, [uniqueness, [msg_id_panel]])
    real_vector := rand(length, min_value, max_value, specifier, set_of_values, [uniqueness, [msg_id_panel]])
    real_vector := rand(length, min_value, max_value, specifier1, value1, specifier2, value2, [uniqueness, [msg_id_panel]])
    real_vector := rand(length, min_value, max_value, specifier1, value1, specifier2, set_of_values2, [uniqueness, [msg_id_panel]])
    real_vector := rand(length, min_value, max_value, specifier1, set_of_values1, specifier2, set_of_values2, [uniqueness, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | min_value          | in     | real                         | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | real                         | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | specifier          | in     | :ref:`t_value_specifier`     | Defines how to handle a single value or a set of values       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | value              | in     | real                         | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_of_values      | in     | real_vector                  | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | uniqueness         | in     | :ref:`t_uniqueness`          | Whether the values in the vector should be unique or not.     |
|          |                    |        |                              | Default value is NON_UNIQUE.                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Examples:
    rand_real_vec := my_rand.rand(rand_real_vec'length, 0.0, 9.99);
    rand_real_vec := my_rand.rand(rand_real_vec'length, ONLY, (0.5,1.0,1.5,2.0,2.5,3.0));
    rand_real_vec := my_rand.rand(rand_real_vec'length, 0.0, 9.99, ADD,(20.0));
    rand_real_vec := my_rand.rand(rand_real_vec'length, 0.0, 9.99, EXCL,(5.0,6.0));
    rand_real_vec := my_rand.rand(rand_real_vec'length, 0.0, 9.99, ADD,(20.0), EXCL,(5.0));
    rand_real_vec := my_rand.rand(rand_real_vec'length, 0.0, 9.99, ADD,(20.0), EXCL,(5.0,6.0));
    rand_real_vec := my_rand.rand(rand_real_vec'length, 0.0, 9.99, ADD,(20.0,30.0,40.0), EXCL,(5.0,6.0), UNIQUE);


.. _rand_time_vec:

return time_vector
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a vector of random time values. For more information on the probability distribution click :ref:`here <rand_pkg_distributions>`. ::

    time_vector := rand(length, min_value, max_value, [time_resolution], [uniqueness, [msg_id_panel]])
    time_vector := rand(length, specifier, set_of_values, [uniqueness, [msg_id_panel]])
    time_vector := rand(length, min_value, max_value, [time_resolution], specifier, value, [uniqueness, [msg_id_panel]])
    time_vector := rand(length, min_value, max_value, [time_resolution], specifier, set_of_values, [uniqueness, [msg_id_panel]])
    time_vector := rand(length, min_value, max_value, [time_resolution], specifier1, value1, specifier2, value2, [uniqueness, [msg_id_panel]])
    time_vector := rand(length, min_value, max_value, [time_resolution], specifier1, value1, specifier2, set_of_values2, [uniqueness, [msg_id_panel]])
    time_vector := rand(length, min_value, max_value, [time_resolution], specifier1, set_of_values1, specifier2, set_of_values2, [uniqueness, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | min_value          | in     | time                         | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | time                         | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | time_resolution    | in     | time                         | Defines how many values can be generated between min_value and|
|          |                    |        |                              | max_value. If the given resolution is too small for the range,|
|          |                    |        |                              | a TB_WARNING will be printed once. Default value is the       |
|          |                    |        |                              | smallest time unit between the min and max parameters.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | specifier          | in     | :ref:`t_value_specifier`     | Defines how to handle a single value or a set of values       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | value              | in     | time                         | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_of_values      | in     | time_vector                  | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | uniqueness         | in     | :ref:`t_uniqueness`          | Whether the values in the vector should be unique or not.     |
|          |                    |        |                              | Default value is NON_UNIQUE.                                  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Examples:
    rand_time_vec := my_rand.rand(rand_time_vec'length, 1 us, 100 us);         -- Generates random values with a resolution of 1 us
    rand_time_vec := my_rand.rand(rand_time_vec'length, 1 us, 100 us, ns);     -- Generates random values with a resolution of 1 ns
    rand_time_vec := my_rand.rand(rand_time_vec'length, 1 us, 100 us, 100 ns); -- Generates random values with a resolution of 100 ns
    rand_time_vec := my_rand.rand(rand_time_vec'length, ONLY, (5 us, 10 us, 15 us, 20 us, 25 us, 30 us));
    rand_time_vec := my_rand.rand(rand_time_vec'length, 1 ns, 10 ns, ADD,(20 ns));
    rand_time_vec := my_rand.rand(rand_time_vec'length, 1 ns, 10 ns, EXCL,(5 ns, 6 ns));
    rand_time_vec := my_rand.rand(rand_time_vec'length, 1 ns, 10 ns, ADD,(20 ns), EXCL,(5 ns));
    rand_time_vec := my_rand.rand(rand_time_vec'length, 1 ns, 10 ns, ADD,(20 ns), EXCL,(5 ns, 6 ns));
    rand_time_vec := my_rand.rand(rand_time_vec'length, 1 ns, 10 ns, ADD,(20 ns, 30 ns, 40 ns), EXCL,(5 ns, 6 ns), UNIQUE);


.. _rand_uns:

return unsigned
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random unsigned value. For more information on the probability distribution click :ref:`here <rand_pkg_distributions>`. ::

    unsigned := rand(length, [cyclic_mode, [msg_id_panel]])
    unsigned := rand(length, min_value, max_value, [cyclic_mode, [msg_id_panel]])
    unsigned := rand(length, specifier, set_of_values, [cyclic_mode, [msg_id_panel]])
    unsigned := rand(length, min_value, max_value, specifier, value, [cyclic_mode, [msg_id_panel]])
    unsigned := rand(length, min_value, max_value, specifier, set_of_values, [cyclic_mode, [msg_id_panel]])
    unsigned := rand(length, min_value, max_value, specifier1, value1, specifier2, value2, [cyclic_mode, [msg_id_panel]])
    unsigned := rand(length, min_value, max_value, specifier1, value1, specifier2, set_of_values2, [cyclic_mode, [msg_id_panel]])
    unsigned := rand(length, min_value, max_value, specifier1, set_of_values1, specifier2, set_of_values2, [cyclic_mode, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | min_value          | in     | natural                      | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | natural                      | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | specifier          | in     | :ref:`t_value_specifier`     | Defines how to handle a single value or a set of values       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | value              | in     | natural                      | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_of_values      | in     | t_natural_vector             | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | cyclic_mode        | in     | :ref:`t_cyclic`              | Whether cyclic mode is enabled or disabled. Default value is  |
|          |                    |        |                              | NON_CYCLIC.                                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Examples:
    rand_uns := my_rand.rand(rand_uns'length);
    rand_uns := my_rand.rand(rand_uns'length, 0, 50);
    rand_uns := my_rand.rand(rand_uns'length, ONLY, (0,10,40,50));
    rand_uns := my_rand.rand(rand_uns'length, 0, 50, ADD,(60));
    rand_uns := my_rand.rand(rand_uns'length, 0, 50, EXCL,(25,35));
    rand_uns := my_rand.rand(rand_uns'length, 0, 50, ADD,(60), EXCL,(25));
    rand_uns := my_rand.rand(rand_uns'length, 0, 50, ADD,(60), EXCL,(25,35));
    rand_uns := my_rand.rand(rand_uns'length, 0, 50, ADD,(60,70,80), EXCL,(25,35), CYCLIC);


.. _rand_uns_long:

return unsigned (long range)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random unsigned value. The unsigned constraints can be used for min and max values bigger than the integer's 32-bit range. 
If the length parameter is not used, the return value's length will be equal to the largest length of either min_value or max_value. 
For more information on the probability distribution click :ref:`here <rand_pkg_distributions>`. ::

    unsigned := rand([length], min_value, max_value, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | min_value          | in     | unsigned                     | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | unsigned                     | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Examples:
    rand_uns := my_rand.rand(rand_uns'length, C_MIN_VALUE, v_max_value);
    rand_uns := my_rand.rand(C_MIN_VALUE, v_max_value);


.. _rand_sig:

return signed
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random signed value. For more information on the probability distribution click :ref:`here <rand_pkg_distributions>`. ::

    signed := rand(length, [cyclic_mode, [msg_id_panel]])
    signed := rand(length, min_value, max_value, [cyclic_mode, [msg_id_panel]])
    signed := rand(length, specifier, set_of_values, [cyclic_mode, [msg_id_panel]])
    signed := rand(length, min_value, max_value, specifier, value, [cyclic_mode, [msg_id_panel]])
    signed := rand(length, min_value, max_value, specifier, set_of_values, [cyclic_mode, [msg_id_panel]])
    signed := rand(length, min_value, max_value, specifier1, value1, specifier2, value2, [cyclic_mode, [msg_id_panel]])
    signed := rand(length, min_value, max_value, specifier1, value1, specifier2, set_of_values2, [cyclic_mode, [msg_id_panel]])
    signed := rand(length, min_value, max_value, specifier1, set_of_values1, specifier2, set_of_values2, [cyclic_mode, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | min_value          | in     | integer                      | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | integer                      | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | specifier          | in     | :ref:`t_value_specifier`     | Defines how to handle a single value or a set of values       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | value              | in     | integer                      | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_of_values      | in     | integer_vector               | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | cyclic_mode        | in     | :ref:`t_cyclic`              | Whether cyclic mode is enabled or disabled. Default value is  |
|          |                    |        |                              | NON_CYCLIC.                                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Examples:
    rand_sign := my_rand.rand(rand_sign'length);
    rand_sign := my_rand.rand(rand_sign'length, -50, 50);
    rand_sign := my_rand.rand(rand_sign'length, ONLY, (-20,-10,0,10,20));
    rand_sign := my_rand.rand(rand_sign'length, -50, 50, ADD,(60));
    rand_sign := my_rand.rand(rand_sign'length, -50, 50, EXCL,(-25,25));
    rand_sign := my_rand.rand(rand_sign'length, -50, 50, ADD,(60), EXCL,(25));
    rand_sign := my_rand.rand(rand_sign'length, -50, 50, ADD,(60), EXCL,(-25,25));
    rand_sign := my_rand.rand(rand_sign'length, -50, 50, ADD,(-60,60,70,80), EXCL,(-25,25), CYCLIC);


.. _rand_sig_long:

return signed (long range)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random signed value. The signed constraints can be used for min and max values bigger than the integer's 32-bit range. 
If the length parameter is not used, the return value's length will be equal to the largest length of either min_value or max_value. 
For more information on the probability distribution click :ref:`here <rand_pkg_distributions>`. ::

    signed := rand([length], min_value, max_value, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | min_value          | in     | signed                       | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | signed                       | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Examples:
    rand_sign := my_rand.rand(rand_sign'length, C_MIN_VALUE, v_max_value);
    rand_sign := my_rand.rand(C_MIN_VALUE, v_max_value);


.. _rand_slv:

return std_logic_vector
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random std_logic_vector value (interpreted as unsigned). For more information on the probability distribution click 
:ref:`here <rand_pkg_distributions>`. ::

    std_logic_vector := rand(length, [cyclic_mode, [msg_id_panel]])
    std_logic_vector := rand(length, min_value, max_value, [cyclic_mode, [msg_id_panel]])
    std_logic_vector := rand(length, specifier, set_of_values, [cyclic_mode, [msg_id_panel]])
    std_logic_vector := rand(length, min_value, max_value, specifier, value, [cyclic_mode, [msg_id_panel]])
    std_logic_vector := rand(length, min_value, max_value, specifier, set_of_values, [cyclic_mode, [msg_id_panel]])
    std_logic_vector := rand(length, min_value, max_value, specifier1, value1, specifier2, value2, [cyclic_mode, [msg_id_panel]])
    std_logic_vector := rand(length, min_value, max_value, specifier1, value1, specifier2, set_of_values2, [cyclic_mode, [msg_id_panel]])
    std_logic_vector := rand(length, min_value, max_value, specifier1, set_of_values1, specifier2, set_of_values2, [cyclic_mode, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | min_value          | in     | natural                      | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | natural                      | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | specifier          | in     | :ref:`t_value_specifier`     | Defines how to handle a single value or a set of values       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | value              | in     | natural                      | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_of_values      | in     | t_natural_vector             | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | cyclic_mode        | in     | :ref:`t_cyclic`              | Whether cyclic mode is enabled or disabled. Default value is  |
|          |                    |        |                              | NON_CYCLIC.                                                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Examples:
    rand_slv := my_rand.rand(rand_slv'length);
    rand_slv := my_rand.rand(rand_slv'length, 0, 50);
    rand_slv := my_rand.rand(rand_slv'length, ONLY, (0,10,40,50));
    rand_slv := my_rand.rand(rand_slv'length, 0, 50, ADD,(60));
    rand_slv := my_rand.rand(rand_slv'length, 0, 50, EXCL,(25,35));
    rand_slv := my_rand.rand(rand_slv'length, 0, 50, ADD,(60), EXCL,(25));
    rand_slv := my_rand.rand(rand_slv'length, 0, 50, ADD,(60), EXCL,(25,35));
    rand_slv := my_rand.rand(rand_slv'length, 0, 50, ADD,(60,70,80), EXCL,(25,35), CYCLIC);


.. _rand_slv_long:

return std_logic_vector (long range)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random std_logic_vector value (interpreted as unsigned). The std_logic_vector constraints can be used for min and max 
values bigger than the integer's 32-bit range. If the length parameter is not used, the return value's length will be equal to the 
largest length of either min_value or max_value. For more information on the probability distribution click 
:ref:`here <rand_pkg_distributions>`. ::

    std_logic_vector := rand([length], min_value, max_value, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | min_value          | in     | std_logic_vector             | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | std_logic_vector             | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Examples:
    rand_slv := my_rand.rand(rand_slv'length, C_MIN_VALUE, v_max_value);
    rand_slv := my_rand.rand(C_MIN_VALUE, v_max_value);


.. _rand_sl:

return std_logic
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random std_logic value. ::

    std_logic := rand(VOID)
    std_logic := rand(msg_id_panel)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default          |
|          |                    |        |                              | value is shared_msg_id_panel.                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Examples:
    rand_sl := my_rand.rand(VOID);
    rand_sl := my_rand.rand(my_msg_id_panel);


.. _rand_bool:

return boolean
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random boolean value. ::

    boolean := rand(VOID)
    boolean := rand(msg_id_panel)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default          |
|          |                    |        |                              | value is shared_msg_id_panel.                                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Examples:
    rand_bool := my_rand.rand(VOID);
    rand_bool := my_rand.rand(my_msg_id_panel);


.. _rand_val_weight:

rand_val_weight()
----------------------------------------------------------------------------------------------------------------------------------
Returns a random value using a weighted distribution. Each given value has a weight which determines how often it is chosen during 
randomization. The sum of all weights could be any value since each individual probability is equal to individual_weight/sum_of_weights. ::

    integer          := rand_val_weight(weighted_vector, [msg_id_panel])
    real             := rand_val_weight(weighted_vector, [msg_id_panel])
    time             := rand_val_weight(weighted_vector, [msg_id_panel])
    unsigned         := rand_val_weight(length, weighted_vector, [msg_id_panel])
    signed           := rand_val_weight(length, weighted_vector, [msg_id_panel])
    std_logic_vector := rand_val_weight(length, weighted_vector, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | weighted_vector    | in     | :ref:`t_val_weight_int_vec`  | A vector containing pairs of (value, weight)                  |
|          |                    |        |                              |                                                               |
|          |                    |        | :ref:`t_val_weight_real_vec` |                                                               |
|          |                    |        |                              |                                                               |
|          |                    |        | :ref:`t_val_weight_time_vec` |                                                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Examples:
    rand_int  := my_rand.rand_val_weight(((-5,10),(0,30),(5,60)));
    rand_real := my_rand.rand_val_weight(((-5.0,10),(0.0,30),(5.0,60)));
    rand_time := my_rand.rand_val_weight(((1 ns,10),(10 ns,30),(25 ns,60)));
    rand_uns  := my_rand.rand_val_weight(rand_uns'length, ((10,1),(20,3),(30,6)));
    rand_sign := my_rand.rand_val_weight(rand_sign'length, ((-5,1),(0,2),(5,2)));
    rand_slv  := my_rand.rand_val_weight(rand_slv'length, ((10,5),(20,1),(30,1))); -- SLV is interpreted as unsigned


.. _rand_range_weight:

rand_range_weight()
----------------------------------------------------------------------------------------------------------------------------------
Returns a random value using a weighted distribution. Each given range (min/max) has a weight which determines how often it is 
chosen during randomization. The sum of all weights could be any value since each individual probability is equal to 
individual_weight/sum_of_weights. 

The given weight is assigned to the range as a whole, i.e. each value within the range has an equal fraction of the given weight. 
This mode can be changed to assigning the given weight equally to each value within the range by using 
``set_range_weight_default_mode(INDIVIDUAL_WEIGHT)`` (EXCEPT for the real and time types). ::

    integer          := rand_range_weight(weighted_vector, [msg_id_panel])
    real             := rand_range_weight(weighted_vector, [msg_id_panel])
    time             := rand_range_weight(weighted_vector, [time_resolution], [msg_id_panel])
    unsigned         := rand_range_weight(length, weighted_vector, [msg_id_panel])
    signed           := rand_range_weight(length, weighted_vector, [msg_id_panel])
    std_logic_vector := rand_range_weight(length, weighted_vector, [msg_id_panel])

+----------+--------------------+--------+-------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                          | Description                                                   |
+==========+====================+========+===============================+===============================================================+
| constant | weighted_vector    | in     | :ref:`t_range_weight_int_vec` | A vector containing sets of (min, max, weight). To specify a  |
|          |                    |        |                               | single value, it needs to be set equally for min and max.     |
|          |                    |        | :ref:`t_range_weight_real_vec`|                                                               |
|          |                    |        |                               |                                                               |
|          |                    |        | :ref:`t_range_weight_time_vec`|                                                               |
+----------+--------------------+--------+-------------------------------+---------------------------------------------------------------+
| constant | time_resolution    | in     | time                          | Defines how many values can be generated between min_value and|
|          |                    |        |                               | max_value. If the given resolution is too small for the range,|
|          |                    |        |                               | a TB_WARNING will be printed once. Default value is the       |
|          |                    |        |                               | smallest time unit between the min and max parameters of the  |
|          |                    |        |                               | first element in the weighted_vector.                         |
+----------+--------------------+--------+-------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel                | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                               | shared_msg_id_panel.                                          |
+----------+--------------------+--------+-------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Examples:
    rand_int  := my_rand.rand_range_weight(((-5,-3,30),(0,0,20),(1,5,50)));
    rand_real := my_rand.rand_range_weight(((-5.0,-3.0,10),(0.0,0.0,30),(1.0,5.0,60)));
    rand_time := my_rand.rand_range_weight(((1 us,5 us,10),(10 us,10 us,30),(25 us,50 us,60)));         -- Generates random values with a resolution of 1 us
    rand_time := my_rand.rand_range_weight(((1 us,5 us,10),(10 us,10 us,30),(25 us,50 us,60)), ns);     -- Generates random values with a resolution of 1 ns
    rand_time := my_rand.rand_range_weight(((1 us,5 us,10),(10 us,10 us,30),(25 us,50 us,60)), 100 ns); -- Generates random values with a resolution of 100 ns
    rand_uns  := my_rand.rand_range_weight(rand_uns'length, ((10,15,1),(20,25,3),(30,35,6)));
    rand_sign := my_rand.rand_range_weight(rand_sign'length, ((-5,-3,1),(0,0,2),(5,10,2)));
    rand_slv  := my_rand.rand_range_weight(rand_slv'length, ((10,15,5),(20,25,1),(30,35,1))); -- SLV is interpreted as unsigned


.. _rand_range_weight_mode:

rand_range_weight_mode()
----------------------------------------------------------------------------------------------------------------------------------
Returns a random value using a weighted distribution. Each given range (min/max) has a weight which determines how often it is 
chosen during randomization. The sum of all weights could be any value since each individual probability is equal to 
individual_weight/sum_of_weights. 

The weight of a range can have two possible interpretations:

#. COMBINED_WEIGHT: The given weight is assigned to the range as a whole, i.e. each value within the range has an equal fraction 
   of the given weight.
#. INDIVIDUAL_WEIGHT: The given weight is assigned equally to each value within the range, hence the range will have a total weight 
   higher than the given weight.

While it is possible to use different weight modes on each range in a single procedure call, it is recommended to use the same ones 
to avoid confusion regarding the distribution of the weights.

Note that the real and time weighted randomization functions only support the COMBINED_WEIGHT mode due to the very large number of 
values within a real/time range. ::

    integer          := rand_range_weight_mode(weighted_vector, [msg_id_panel])
    real             := rand_range_weight_mode(weighted_vector, [msg_id_panel])
    time             := rand_range_weight_mode(weighted_vector, [time_resolution], [msg_id_panel])
    unsigned         := rand_range_weight_mode(length, weighted_vector, [msg_id_panel])
    signed           := rand_range_weight_mode(length, weighted_vector, [msg_id_panel])
    std_logic_vector := rand_range_weight_mode(length, weighted_vector, [msg_id_panel])

+----------+--------------------+--------+------------------------------------+----------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                               | Description                                                    |
+==========+====================+========+====================================+================================================================+
| constant | weighted_vector    | in     | :ref:`t_range_weight_mode_int_vec` | A vector containing sets of (min, max, weight, mode). To       |
|          |                    |        |                                    | specify a single value, it needs to be set equally for min and |
|          |                    |        | :ref:`t_range_weight_mode_real_vec`| max, and the mode to NA since it doesn't have any meaning.     |
|          |                    |        |                                    |                                                                |
|          |                    |        | :ref:`t_range_weight_mode_time_vec`|                                                                |
+----------+--------------------+--------+------------------------------------+----------------------------------------------------------------+
| constant | time_resolution    | in     | time                               | Defines how many values can be generated between min_value and |
|          |                    |        |                                    | max_value. If the given resolution is too small for the range, |
|          |                    |        |                                    | a TB_WARNING will be printed once. Default value is the        |
|          |                    |        |                                    | smallest time unit between the min and max parameters of the   |
|          |                    |        |                                    | first element in the weighted_vector.                          |
+----------+--------------------+--------+------------------------------------+----------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel                     | Controls verbosity within a specified scope. Default value is  |
|          |                    |        |                                    | shared_msg_id_panel.                                           |
+----------+--------------------+--------+------------------------------------+----------------------------------------------------------------+

.. code-block::

    -- Examples:
    rand_int  := my_rand.rand_range_weight_mode(((-5,-3,30,INDIVIDUAL_WEIGHT),(0,0,20,NA),(1,5,50,INDIVIDUAL_WEIGHT)));
    rand_real := my_rand.rand_range_weight_mode(((-5.0,-3.0,10,COMBINED_WEIGHT),(0.0,0.0,30,NA),(1.0,5.0,60,COMBINED_WEIGHT)));
    rand_time := my_rand.rand_range_weight_mode(((1 us,5 us,10,COMBINED_WEIGHT),(10 us,10 us,30,NA),(25 us,50 us,60,COMBINED_WEIGHT)));         -- Generates random values with a resolution of 1 us
    rand_time := my_rand.rand_range_weight_mode(((1 us,5 us,10,COMBINED_WEIGHT),(10 us,10 us,30,NA),(25 us,50 us,60,COMBINED_WEIGHT)), ns);     -- Generates random values with a resolution of 1 ns
    rand_time := my_rand.rand_range_weight_mode(((1 us,5 us,10,COMBINED_WEIGHT),(10 us,10 us,30,NA),(25 us,50 us,60,COMBINED_WEIGHT)), 100 ns); -- Generates random values with a resolution of 100 ns
    rand_uns  := my_rand.rand_range_weight_mode(rand_uns'length, ((10,15,1,INDIVIDUAL_WEIGHT),(20,20,3,NA),(30,35,6,INDIVIDUAL_WEIGHT)));
    rand_sign := my_rand.rand_range_weight_mode(rand_sign'length, ((-5,-3,1,INDIVIDUAL_WEIGHT),(0,0,2,NA),(5,10,2,INDIVIDUAL_WEIGHT)));
    rand_slv  := my_rand.rand_range_weight_mode(rand_slv'length, ((10,15,5,INDIVIDUAL_WEIGHT),(20,20,1,NA),(30,35,1,INDIVIDUAL_WEIGHT))); -- SLV is interpreted as unsigned


Multi-method approach
==================================================================================================================================

add_range()
----------------------------------------------------------------------------------------------------------------------------------
Adds a constraint specifying a range which will be included in the randomized values. ::

    add_range(min_value, max_value, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | min_value          | in     | integer                      | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | integer                      | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.add_range(1, 10);


add_range_real()
----------------------------------------------------------------------------------------------------------------------------------
Adds a constraint specifying a range which will be included in the randomized values. ::

    add_range_real(min_value, max_value, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | min_value          | in     | real                         | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | real                         | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.add_range_real(1.0, 10.0);


add_range_time()
----------------------------------------------------------------------------------------------------------------------------------
Adds a constraint specifying a range which will be included in the randomized values. ::

    add_range_time(min_value, max_value, [time_resolution], [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | min_value          | in     | time                         | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | time                         | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | time_resolution    | in     | time                         | Defines how many values can be generated between min_value and|
|          |                    |        |                              | max_value. If the given resolution is too small for the range,|
|          |                    |        |                              | a TB_WARNING will be printed once. Default value is the       |
|          |                    |        |                              | smallest time unit between the min and max parameters.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.add_range_time(1 us, 10 us);         -- Generates random values with a resolution of 1 us
    my_rand.add_range_time(1 us, 10 us, ns);     -- Generates random values with a resolution of 1 ns
    my_rand.add_range_time(1 us, 10 us, 100 ns); -- Generates random values with a resolution of 100 ns


.. _add_range_unsigned:

add_range_unsigned()
----------------------------------------------------------------------------------------------------------------------------------
Adds a constraint specifying a range which will be included in the randomized values. This procedure can be used for min and max 
values bigger than the integer's 32-bit range. ::

    add_range_unsigned(min_value, max_value, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | min_value          | in     | unsigned                     | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | unsigned                     | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.add_range_unsigned(x"0000000000000000", x"FFFF000000000000"); -- [0:18446462598732840960]


.. _add_range_signed:

add_range_signed()
----------------------------------------------------------------------------------------------------------------------------------
Adds a constraint specifying a range which will be included in the randomized values. This procedure can be used for min and max 
values bigger than the integer's 32-bit range. ::

    add_range_signed(min_value, max_value, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | min_value          | in     | signed                       | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | signed                       | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.add_range_signed(x"F000000000000000", x"0000000000000005"); -- [-1152921504606846976:5]


add_val()
----------------------------------------------------------------------------------------------------------------------------------
Adds a constraint specifying a single value or a set of values which will be included in the randomized values. ::

    add_val(value, [msg_id_panel])
    add_val(set_of_values, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | value              | in     | integer                      | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_of_values      | in     | integer_vector               | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.add_val(20);
    my_rand.add_val((30,32,34,36,38));


add_val_real()
----------------------------------------------------------------------------------------------------------------------------------
Adds a constraint specifying a single value or a set of values which will be included in the randomized values. ::

    add_val_real(value, [msg_id_panel])
    add_val_real(set_of_values, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | value              | in     | real                         | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_of_values      | in     | real_vector                  | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.add_val_real(20.0);
    my_rand.add_val_real((30.0,32.2,34.4,36.6,38.8));


add_val_time()
----------------------------------------------------------------------------------------------------------------------------------
Adds a constraint specifying a single value or a set of values which will be included in the randomized values. ::

    add_val_time(value, [msg_id_panel])
    add_val_time(set_of_values, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | value              | in     | time                         | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_of_values      | in     | time_vector                  | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.add_val_time(20 ps);
    my_rand.add_val_time((30 ps,32 ps,34 ps,36 ps,38 ps));


excl_val()
----------------------------------------------------------------------------------------------------------------------------------
Adds a constraint specifying a single value or a set of values which will be excluded from the randomized values. ::

    excl_val(value, [msg_id_panel])
    excl_val(set_of_values, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | value              | in     | integer                      | A single value excluded from the generated random numbers     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_of_values      | in     | integer_vector               | A set of values excluded from the generated random numbers    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.excl_val(5);
    my_rand.excl_val((3,7,9));


excl_val_real()
----------------------------------------------------------------------------------------------------------------------------------
Adds a constraint specifying a single value or a set of values which will be excluded from the randomized values. ::

    excl_val_real(value, [msg_id_panel])
    excl_val_real(set_of_values, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | value              | in     | real                         | A single value excluded from the generated random numbers     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_of_values      | in     | real_vector                  | A set of values excluded from the generated random numbers    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.excl_val_real(5.0);
    my_rand.excl_val_real((3.0,7.0,9.0));


excl_val_time()
----------------------------------------------------------------------------------------------------------------------------------
Adds a constraint specifying a single value or a set of values which will be excluded from the randomized values. ::

    excl_val_time(value, [msg_id_panel])
    excl_val_time(set_of_values, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | value              | in     | time                         | A single value excluded from the generated random numbers     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_of_values      | in     | time_vector                  | A set of values excluded from the generated random numbers    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.excl_val_time(5 ps);
    my_rand.excl_val_time((3 ps,7 ps,9 ps));


.. _add_val_weight:

add_val_weight()
----------------------------------------------------------------------------------------------------------------------------------
Adds a constraint specifying a single value with a weight which will be included in the randomized values. ::

    add_val_weight(value, weight, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | value              | in     | integer                      | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | weight             | in     | natural                      | Determines how often the value is chosen during randomization |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.add_val_weight(10, 1);
    my_rand.add_val_weight(20, 3);


.. _add_val_weight_real:

add_val_weight_real()
----------------------------------------------------------------------------------------------------------------------------------
Adds a constraint specifying a single value with a weight which will be included in the randomized values. ::

    add_val_weight_real(value, weight, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | value              | in     | real                         | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | weight             | in     | natural                      | Determines how often the value is chosen during randomization |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.add_val_weight_real(10.0, 1);
    my_rand.add_val_weight_real(20.0, 3);


.. _add_val_weight_time:

add_val_weight_time()
----------------------------------------------------------------------------------------------------------------------------------
Adds a constraint specifying a single value with a weight which will be included in the randomized values. ::

    add_val_weight_time(value, weight, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | value              | in     | time                         | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | weight             | in     | natural                      | Determines how often the value is chosen during randomization |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.add_val_weight_time(10 ns, 1);
    my_rand.add_val_weight_time(20 ns, 3);


.. _add_range_weight:

add_range_weight()
----------------------------------------------------------------------------------------------------------------------------------
Adds a constraint specifying a range with a weight which will be included in the randomized values. ::

    add_range_weight(min_value, max_value, weight, [mode, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | min_value          | in     | integer                      | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | integer                      | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | weight             | in     | natural                      | Determines how often the range is chosen during randomization |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | mode               | in     | :ref:`t_weight_mode`         | Determines how to divide the weight among the range of values.|
|          |                    |        |                              | Default value is COMBINED_WEIGHT and can be updated via       |
|          |                    |        |                              | ``set_range_weight_default_mode()``.                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example 1:
    my_rand.add_range_weight(10,19, 1); -- Will use default mode COMBINED_WEIGHT
    my_rand.add_range_weight(20,29, 3); -- Will use default mode COMBINED_WEIGHT
    my_rand.set_range_weight_default_mode(INDIVIDUAL_WEIGHT);
    my_rand.add_range_weight(30,39, 2); -- Will use new default mode INDIVIDUAL_WEIGHT
    my_rand.add_range_weight(40,49, 1); -- Will use new default mode INDIVIDUAL_WEIGHT

    -- Example 2:
    my_rand.add_range_weight(10,19, 1, INDIVIDUAL_WEIGHT);
    my_rand.add_range_weight(20,29, 3, INDIVIDUAL_WEIGHT);


.. _add_range_weight_real:

add_range_weight_real()
----------------------------------------------------------------------------------------------------------------------------------
Adds a constraint specifying a range with a weight which will be included in the randomized values. The COMBINED_WEIGHT mode is 
used by default due to the very large number of values within a real range. ::

    add_range_weight_real(min_value, max_value, weight, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | min_value          | in     | real                         | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | real                         | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | weight             | in     | natural                      | Determines how often the range is chosen during randomization |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.add_range_weight_real(10.0,19.0, 1);
    my_rand.add_range_weight_real(20.0,29.0, 3);


.. _add_range_weight_time:

add_range_weight_time()
----------------------------------------------------------------------------------------------------------------------------------
Adds a constraint specifying a range with a weight which will be included in the randomized values. The COMBINED_WEIGHT mode is 
used by default due to the very large number of values within a time range. To specify the time resolution see 
:ref:`set_range_weight_time_resolution` ::

    add_range_weight_time(min_value, max_value, weight, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | min_value          | in     | time                         | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | time                         | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | weight             | in     | natural                      | Determines how often the range is chosen during randomization |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.add_range_weight_time(10 us,19 us, 1);
    my_rand.add_range_weight_time(20 us,29 us, 3);


set_cyclic_mode()
----------------------------------------------------------------------------------------------------------------------------------
Configures whether cyclic mode is enabled or disabled. Default value is NON_CYCLIC. For an overview on cyclic randomization click 
:ref:`here <rand_pkg_cyclic>`. ::

    set_cyclic_mode(cyclic_mode, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | cyclic_mode        | in     | :ref:`t_cyclic`              | Whether cyclic mode is enabled or disabled                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.set_cyclic_mode(CYCLIC);


set_uniqueness()
----------------------------------------------------------------------------------------------------------------------------------
Configures whether uniqueness is enabled or disabled. Default value is NON_UNIQUE. For an overview on uniqueness click 
:ref:`here <rand_pkg_uniqueness>`. ::

    set_uniqueness(uniqueness, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | uniqueness         | in     | :ref:`t_uniqueness`          | Whether the values in a vector should be unique or not        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.set_uniqueness(UNIQUE);


.. _set_range_weight_time_resolution:

set_range_weight_time_resolution()
----------------------------------------------------------------------------------------------------------------------------------
Sets the time resolution to use in the weighted distribution functions. Default value is the smallest time unit between the min 
and max parameters of the first element added to the weighted_vector. ::

    set_range_weight_time_resolution(time_resolution, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | time_resolution    | in     | time                         | Defines how many values can be generated between min_value and|
|          |                    |        |                              | max_value. If the given resolution is too small for the range,|
|          |                    |        |                              | a TB_WARNING will be printed once.                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.set_range_weight_time_resolution(100 ns); -- Generates random values with a resolution of 100 ns
    my_rand.add_range_weight_time(10 us,19 us, 1);
    my_rand.add_range_weight_time(20 us,29 us, 3);


clear_constraints()
----------------------------------------------------------------------------------------------------------------------------------
Removes all the randomization constraints in the :ref:`random generator <random_generator>`. ::

    clear_constraints(VOID)
    clear_constraints(msg_id_panel)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.clear_constraints(VOID);


clear_config()
----------------------------------------------------------------------------------------------------------------------------------
Resets all the configuration parameters to their default values and removes all the randomization constraints in the 
:ref:`random generator <random_generator>`. ::

    clear_config(VOID)
    clear_config(msg_id_panel)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.clear_config(VOID);


randm()
----------------------------------------------------------------------------------------------------------------------------------

.. _randm_int:

return integer
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random integer value using the configured constraints. For more information on the probability distribution click 
:ref:`here <rand_pkg_distributions>`. ::

    integer := randm(VOID)
    integer := randm(msg_id_panel)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.add_range(0, 50);
    my_rand.add_val((100,150,200));
    my_rand.excl_val((25));
    rand_int := my_rand.randm(VOID);


.. _randm_real:

return real
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random real value using the configured constraints. For more information on the probability distribution click 
:ref:`here <rand_pkg_distributions>`. ::

    real := randm(VOID)
    real := randm(msg_id_panel)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.add_range_real(0.0, 1.0);
    my_rand.add_val_real((10.0,15.0,20.0));
    my_rand.excl_val_real((0.5));
    rand_real := my_rand.randm(VOID);


.. _randm_time:

return time
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random time value using the configured constraints. For more information on the probability distribution click 
:ref:`here <rand_pkg_distributions>`. ::

    time := randm(VOID)
    time := randm(msg_id_panel)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.add_range_time(0 ps, 50 ps);
    my_rand.add_val_time((100 ps,150 ps,200 ps));
    my_rand.excl_val_time((25 ps));
    rand_time := my_rand.randm(VOID);


.. _randm_int_vec:

return integer_vector
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a vector of random integer values using the configured constraints. For more information on the probability distribution 
click :ref:`here <rand_pkg_distributions>`. ::

    integer_vector := randm(length, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.add_range(0, 50);
    my_rand.add_val((100,150,200));
    my_rand.excl_val((25));
    rand_int_vec := my_rand.randm(rand_int_vec'length);


.. _randm_real_vec:

return real_vector
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a vector of random real values using the configured constraints. For more information on the probability distribution 
click :ref:`here <rand_pkg_distributions>`. ::

    real_vector := randm(length, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.add_range_real(0.0, 1.0);
    my_rand.add_val_real((10.0,15.0,20.0));
    my_rand.excl_val_real((0.5));
    rand_real_vec := my_rand.randm(rand_real_vec'length);


.. _randm_time_vec:

return time_vector
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a vector of random time values using the configured constraints. For more information on the probability distribution 
click :ref:`here <rand_pkg_distributions>`. ::

    time_vector := randm(length, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example:
    my_rand.add_range_time(0 ps, 50 ps);
    my_rand.add_val_time((100 ps,150 ps,200 ps));
    my_rand.excl_val_time((25 ps));
    rand_time_vec := my_rand.randm(rand_time_vec'length);


.. _randm_uns:

return unsigned
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random unsigned value using the configured constraints. For more information on the probability distribution click 
:ref:`here <rand_pkg_distributions>`. ::

    unsigned := randm(length, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example 1:
    my_rand.add_range(0, 50);
    my_rand.add_val((100,150,200));
    my_rand.excl_val((25));
    rand_uns := my_rand.randm(rand_uns'length);

    -- Example 2:
    my_rand.add_range_unsigned(x"0F000000000000000000000000000000", x"0F000000000000000000000000000003");
    rand_uns := my_rand.randm(rand_uns'length);


.. _randm_sig:

return signed
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random signed value using the configured constraints. For more information on the probability distribution click 
:ref:`here <rand_pkg_distributions>`. ::

    signed := randm(length, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example 1:
    my_rand.add_range(-50, 50);
    my_rand.add_val((-100,100));
    my_rand.excl_val((0));
    rand_sign := my_rand.randm(rand_sign'length);

    -- Example 2:
    my_rand.add_range_signed(x"F000000000000000000000000000000", x"F000000000000000000000000000003");
    rand_sign := my_rand.randm(rand_sign'length);


.. _randm_slv:

return std_logic_vector
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random std_logic_vector value (interpreted as unsigned) using the configured constraints. For more information on the 
probability distribution click :ref:`here <rand_pkg_distributions>`. ::

    std_logic_vector := randm(length, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope. Default value is |
|          |                    |        |                              | shared_msg_id_panel.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    -- Example 1:
    my_rand.add_range(0, 50);
    my_rand.add_val((100,150,200));
    my_rand.excl_val((25));
    rand_slv := my_rand.randm(rand_slv'length);

    -- Example 2:
    my_rand.add_range_unsigned(x"0F000000000000000000000000000000", x"0F000000000000000000000000000003");
    rand_slv := my_rand.randm(rand_slv'length);
