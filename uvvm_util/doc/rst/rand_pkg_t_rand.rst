**********************************************************************************************************************************
t_rand (protected)
**********************************************************************************************************************************
Protected type containing all the randomization functionality.

set_name()
----------------------------------------------------------------------------------------------------------------------------------
Configures the name of the random generator. The maximum length is C_RAND_MAX_NAME_LENGTH defined in adaptations_pkg. ::

    set_name(name)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | name               | in     | string                       | Name of the random generator used in reports            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    Examples:
    my_rand.set_name("SIZE_RAND_GEN");


get_name()
----------------------------------------------------------------------------------------------------------------------------------
Returns the random generator's name. ::

    string := get_name(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    log(ID_SEQUENCER, my_rand.get_name(VOID));


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
    my_rand.set_scope("MY_SCOPE");


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
    scope := my_rand.get_scope(VOID);


set_rand_dist()
----------------------------------------------------------------------------------------------------------------------------------
Configures the randomization distribution to be used with the rand() functions. Default value is UNIFORM. ::

    set_rand_dist(rand_dist, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | rand_dist          | in     | :ref:`t_rand_dist`           | Randomization distribution, e.g. UNIFORM, GAUSSIAN    |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_rand.set_rand_dist(GAUSSIAN);


get_rand_dist()
----------------------------------------------------------------------------------------------------------------------------------
Returns the configured randomization distribution. ::

    t_rand_dist := get_rand_dist(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    log(ID_SEQUENCER, to_string(my_rand.get_rand_dist(VOID)));


set_rand_dist_mean()
----------------------------------------------------------------------------------------------------------------------------------
Configures the mean value for the randomization distribution. Default value depends on the parameters of each rand() call: 
(max_range-min_range)/2 ::

    set_rand_dist_mean(mean, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | mean               | in     | real                         | Mean value for the distribution                       |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_rand.set_rand_dist_mean(5.0);


get_rand_dist_mean()
----------------------------------------------------------------------------------------------------------------------------------
Returns the configured mean value. If a value hasn't been configured it will return 0.0 and print a TB_NOTE mentioning that the 
default value is being used. ::

    real := get_rand_dist_mean(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    log(ID_SEQUENCER, to_string(my_rand.get_rand_dist_mean(VOID)));


clear_rand_dist_mean()
----------------------------------------------------------------------------------------------------------------------------------
Clears the configured mean value. Default value will be (max_range-min_range)/2 ::

    clear_rand_dist_mean(VOID)
    clear_rand_dist_mean(msg_id_panel)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_rand.clear_rand_dist_mean(VOID);
    my_rand.clear_rand_dist_mean(my_msg_id_panel);


set_rand_dist_std_deviation()
----------------------------------------------------------------------------------------------------------------------------------
Configures the standard deviation value for the randomization distribution. Default value depends on the parameters of each rand() 
call: (max_range-min_range)/6 ::

    set_rand_dist_std_deviation(std_deviation, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | std_deviation      | in     | real                         | Standard deviation value for the distribution.        |
|          |                    |        |                              | Must be a positive value                              |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_rand.set_rand_dist_std_deviation(1.0);


get_rand_dist_std_deviation()
----------------------------------------------------------------------------------------------------------------------------------
Returns the configured standard deviation value. If a value hasn't been configured it will return 0.0 and print a TB_NOTE mentioning 
that the default value is being used. ::

    real := get_rand_dist_std_deviation(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    log(ID_SEQUENCER, to_string(my_rand.get_rand_dist_std_deviation(VOID)));


clear_rand_dist_std_deviation()
----------------------------------------------------------------------------------------------------------------------------------
Clears the configured standard deviation value. Default value will be (max_range-min_range)/6 ::

    clear_rand_dist_std_deviation(VOID)
    clear_rand_dist_std_deviation(msg_id_panel)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_rand.clear_rand_dist_std_deviation(VOID);
    my_rand.clear_rand_dist_std_deviation(my_msg_id_panel);


set_range_weight_default_mode()
----------------------------------------------------------------------------------------------------------------------------------
Configures the default range weight mode for the weighted randomization distribution. ::

    set_range_weight_default_mode(mode, [msg_id_panel])

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | mode               | in     | :ref:`t_weight_mode`         | How to divide the weight among a range of values      |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_rand.set_range_weight_default_mode(INDIVIDUAL_WEIGHT);


get_range_weight_default_mode()
----------------------------------------------------------------------------------------------------------------------------------
Returns the default range weight mode. ::

    t_weight_mode := get_range_weight_default_mode(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    log(ID_SEQUENCER, to_string(my_rand.get_range_weight_default_mode(VOID)));


clear_rand_cyclic()
----------------------------------------------------------------------------------------------------------------------------------
Clears the state of the cyclic generation. Deallocates the list/queue used to store the generated numbers. ::

    clear_rand_cyclic(VOID)
    clear_rand_cyclic(msg_id_panel)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_rand.clear_rand_cyclic(VOID);
    my_rand.clear_rand_cyclic(my_msg_id_panel);


report_config()
----------------------------------------------------------------------------------------------------------------------------------
Prints a report containing the random generator's configuration parameters. ::

    report_config(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_rand.report_config(VOID);


set_rand_seeds()
----------------------------------------------------------------------------------------------------------------------------------
Configures the randomization seeds by using a string or the actual seed values. Default values are defined by C_RAND_INIT_SEED_1 
and C_RAND_INIT_SEED_2 in adaptations_pkg. ::

    set_rand_seeds(str)
    set_rand_seeds(seed1, seed2)
    set_rand_seeds(seeds)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
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

    Examples:
    my_rand.set_rand_seeds("my_rand");
    my_rand.set_rand_seeds(10, 100);
    my_rand.set_rand_seeds(seed_vector);


get_rand_seeds()
----------------------------------------------------------------------------------------------------------------------------------
Returns the randomization seeds. ::

    get_rand_seeds(seed1, seed2)
    t_positive_vector(0 to 1) := get_rand_seeds(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| variable | seed1              | out    | positive                     | A positive number representing seed 1                 |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| variable | seed2              | out    | positive                     | A positive number representing seed 2                 |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_rand.get_rand_seeds(seed1, seed2);
    seed_vector := my_rand.get_rand_seeds(VOID);


rand()
----------------------------------------------------------------------------------------------------------------------------------

.. _rand_int:

return integer
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random integer value. ::

    integer := rand(min_value, max_value, [cyclic_mode, [msg_id_panel]])
    integer := rand(set_type, set_values, [cyclic_mode, [msg_id_panel]])
    integer := rand(min_value, max_value, set_type, set_value, [cyclic_mode, [msg_id_panel]])
    integer := rand(min_value, max_value, set_type, set_values, [cyclic_mode, [msg_id_panel]])
    integer := rand(min_value, max_value, set_type1, set_value1, set_type2, set_value2, [cyclic_mode, [msg_id_panel]])
    integer := rand(min_value, max_value, set_type1, set_value1, set_type2, set_values2, [cyclic_mode, [msg_id_panel]])
    integer := rand(min_value, max_value, set_type1, set_values1, set_type2, set_values2, [cyclic_mode, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | min_value          | in     | integer                      | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | integer                      | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_type           | in     | :ref:`t_set_type`            | Defines how to handle the set of values                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_value          | in     | integer                      | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_values         | in     | integer_vector               | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | cyclic_mode        | in     | :ref:`t_cyclic`              | Whether cyclic mode is enabled or disabled                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
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
Returns a random real value. ::

    real := rand(min_value, max_value, [msg_id_panel])
    real := rand(set_type, set_values, [msg_id_panel])
    real := rand(min_value, max_value, set_type, set_value, [msg_id_panel])
    real := rand(min_value, max_value, set_type, set_values, [msg_id_panel])
    real := rand(min_value, max_value, set_type1, set_value1, set_type2, set_value2, [msg_id_panel])
    real := rand(min_value, max_value, set_type1, set_value1, set_type2, set_values2, [msg_id_panel])
    real := rand(min_value, max_value, set_type1, set_values1, set_type2, set_values2, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | min_value          | in     | real                         | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | real                         | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_type           | in     | :ref:`t_set_type`            | Defines how to handle the set of values                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_value          | in     | real                         | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_values         | in     | real_vector                  | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
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
Returns a random time value. ::

    time := rand(min_value, max_value, [msg_id_panel])
    time := rand(set_type, set_values, [msg_id_panel])
    time := rand(min_value, max_value, set_type, set_value, [msg_id_panel])
    time := rand(min_value, max_value, set_type, set_values, [msg_id_panel])
    time := rand(min_value, max_value, set_type1, set_value1, set_type2, set_value2, [msg_id_panel])
    time := rand(min_value, max_value, set_type1, set_value1, set_type2, set_values2, [msg_id_panel])
    time := rand(min_value, max_value, set_type1, set_values1, set_type2, set_values2, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | min_value          | in     | time                         | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | time                         | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_type           | in     | :ref:`t_set_type`            | Defines how to handle the set of values                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_value          | in     | time                         | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_values         | in     | time_vector                  | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
    rand_time := my_rand.rand(0 ps, 100 ps);
    rand_time := my_rand.rand(ONLY, (5 us, 10 us, 15 us, 20 us));
    rand_time := my_rand.rand(1 ns, 10 ns, ADD,(20 ns));
    rand_time := my_rand.rand(1 ns, 10 ns, EXCL,(5 ns, 6 ns));
    rand_time := my_rand.rand(1 ns, 10 ns, ADD,(20 ns), EXCL,(5 ns));
    rand_time := my_rand.rand(1 ns, 10 ns, ADD,(20 ns), EXCL,(5 ns, 6 ns));
    rand_time := my_rand.rand(1 ns, 10 ns, ADD,(20 ns, 30 ns, 40 ns), EXCL,(5 ns, 6 ns));


.. _rand_int_vec:

return integer_vector
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a vector of random integer values. ::

    integer_vector := rand(size, min_value, max_value, [uniqueness, [cyclic_mode, [msg_id_panel]]])
    integer_vector := rand(size, set_type, set_values, [uniqueness, [cyclic_mode, [msg_id_panel]]])
    integer_vector := rand(size, min_value, max_value, set_type, set_value, [uniqueness, [cyclic_mode, [msg_id_panel]]])
    integer_vector := rand(size, min_value, max_value, set_type, set_values, [uniqueness, [cyclic_mode, [msg_id_panel]]])
    integer_vector := rand(size, min_value, max_value, set_type1, set_value1, set_type2, set_value2, [uniqueness, [cyclic_mode, [msg_id_panel]]])
    integer_vector := rand(size, min_value, max_value, set_type1, set_value1, set_type2, set_values2, [uniqueness, [cyclic_mode, [msg_id_panel]]])
    integer_vector := rand(size, min_value, max_value, set_type1, set_values1, set_type2, set_values2, [uniqueness, [cyclic_mode, [msg_id_panel]]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | size               | in     | positive                     | The size of the vector to be returned                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | min_value          | in     | integer                      | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | integer                      | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_type           | in     | :ref:`t_set_type`            | Defines how to handle the set of values                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_value          | in     | integer                      | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_values         | in     | integer_vector               | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | uniqueness         | in     | :ref:`t_uniqueness`          | Whether the values in the vector should be unique or not      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | cyclic_mode        | in     | :ref:`t_cyclic`              | Whether cyclic mode is enabled or disabled                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
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
Returns a vector of random real values. ::

    real_vector := rand(size, min_value, max_value, [uniqueness, [msg_id_panel]])
    real_vector := rand(size, set_type, set_values, [uniqueness, [msg_id_panel]])
    real_vector := rand(size, min_value, max_value, set_type, set_value, [uniqueness, [msg_id_panel]])
    real_vector := rand(size, min_value, max_value, set_type, set_values, [uniqueness, [msg_id_panel]])
    real_vector := rand(size, min_value, max_value, set_type1, set_value1, set_type2, set_value2, [uniqueness, [msg_id_panel]])
    real_vector := rand(size, min_value, max_value, set_type1, set_value1, set_type2, set_values2, [uniqueness, [msg_id_panel]])
    real_vector := rand(size, min_value, max_value, set_type1, set_values1, set_type2, set_values2, [uniqueness, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | size               | in     | positive                     | The size of the vector to be returned                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | min_value          | in     | real                         | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | real                         | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_type           | in     | :ref:`t_set_type`            | Defines how to handle the set of values                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_value          | in     | real                         | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_values         | in     | real_vector                  | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | uniqueness         | in     | :ref:`t_uniqueness`          | Whether the values in the vector should be unique or not      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
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
Returns a vector of random time values. ::

    time_vector := rand(size, min_value, max_value, [uniqueness, [msg_id_panel]])
    time_vector := rand(size, set_type, set_values, [uniqueness, [msg_id_panel]])
    time_vector := rand(size, min_value, max_value, set_type, set_value, [uniqueness, [msg_id_panel]])
    time_vector := rand(size, min_value, max_value, set_type, set_values, [uniqueness, [msg_id_panel]])
    time_vector := rand(size, min_value, max_value, set_type1, set_value1, set_type2, set_value2, [uniqueness, [msg_id_panel]])
    time_vector := rand(size, min_value, max_value, set_type1, set_value1, set_type2, set_values2, [uniqueness, [msg_id_panel]])
    time_vector := rand(size, min_value, max_value, set_type1, set_values1, set_type2, set_values2, [uniqueness, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | size               | in     | positive                     | The size of the vector to be returned                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | min_value          | in     | time                         | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | time                         | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_type           | in     | :ref:`t_set_type`            | Defines how to handle the set of values                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_value          | in     | time                         | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_values         | in     | time_vector                  | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | uniqueness         | in     | :ref:`t_uniqueness`          | Whether the values in the vector should be unique or not      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
    rand_time_vec := my_rand.rand(rand_time_vec'length, 0 ps, 100 ps);
    rand_time_vec := my_rand.rand(rand_time_vec'length, ONLY, (5 us, 10 us, 15 us, 20 us, 25 us, 30 us));
    rand_time_vec := my_rand.rand(rand_time_vec'length, 1 ns, 10 ns, ADD,(20 ns));
    rand_time_vec := my_rand.rand(rand_time_vec'length, 1 ns, 10 ns, EXCL,(5 ns, 6 ns));
    rand_time_vec := my_rand.rand(rand_time_vec'length, 1 ns, 10 ns, ADD,(20 ns), EXCL,(5 ns));
    rand_time_vec := my_rand.rand(rand_time_vec'length, 1 ns, 10 ns, ADD,(20 ns), EXCL,(5 ns, 6 ns));
    rand_time_vec := my_rand.rand(rand_time_vec'length, 1 ns, 10 ns, ADD,(20 ns, 30 ns, 40 ns), EXCL,(5 ns, 6 ns), UNIQUE);


.. _rand_uns:

return unsigned
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random unsigned value. ::

    unsigned := rand(length, [cyclic_mode, [msg_id_panel]])
    unsigned := rand(length, min_value, max_value, [cyclic_mode, [msg_id_panel]])
    unsigned := rand(length, set_type, set_values, [cyclic_mode, [msg_id_panel]])
    unsigned := rand(length, min_value, max_value, set_type, set_value, [cyclic_mode, [msg_id_panel]])
    unsigned := rand(length, min_value, max_value, set_type, set_values, [cyclic_mode, [msg_id_panel]])
    unsigned := rand(length, min_value, max_value, set_type1, set_value1, set_type2, set_value2, [cyclic_mode, [msg_id_panel]])
    unsigned := rand(length, min_value, max_value, set_type1, set_value1, set_type2, set_values2, [cyclic_mode, [msg_id_panel]])
    unsigned := rand(length, min_value, max_value, set_type1, set_values1, set_type2, set_values2, [cyclic_mode, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | min_value          | in     | natural                      | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | natural                      | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_type           | in     | :ref:`t_set_type`            | Defines how to handle the set of values                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_value          | in     | natural                      | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_values         | in     | t_natural_vector             | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | cyclic_mode        | in     | :ref:`t_cyclic`              | Whether cyclic mode is enabled or disabled                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
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
The overload without the length parameter uses the max_value length for the return value. ::

    unsigned := rand(min_value, max_value, [msg_id_panel])
    unsigned := rand(length, min_value, max_value, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | min_value          | in     | unsigned                     | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | unsigned                     | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
    rand_uns := my_rand.rand(C_MIN_RANGE, v_max_range);
    rand_uns := my_rand.rand(rand_uns'length, C_MIN_RANGE, v_max_range);


.. _rand_sig:

return signed
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random signed value. ::

    signed := rand(length, [cyclic_mode, [msg_id_panel]])
    signed := rand(length, min_value, max_value, [cyclic_mode, [msg_id_panel]])
    signed := rand(length, set_type, set_values, [cyclic_mode, [msg_id_panel]])
    signed := rand(length, min_value, max_value, set_type, set_value, [cyclic_mode, [msg_id_panel]])
    signed := rand(length, min_value, max_value, set_type, set_values, [cyclic_mode, [msg_id_panel]])
    signed := rand(length, min_value, max_value, set_type1, set_value1, set_type2, set_value2, [cyclic_mode, [msg_id_panel]])
    signed := rand(length, min_value, max_value, set_type1, set_value1, set_type2, set_values2, [cyclic_mode, [msg_id_panel]])
    signed := rand(length, min_value, max_value, set_type1, set_values1, set_type2, set_values2, [cyclic_mode, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | min_value          | in     | integer                      | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | integer                      | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_type           | in     | :ref:`t_set_type`            | Defines how to handle the set of values                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_value          | in     | integer                      | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_values         | in     | integer_vector               | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | cyclic_mode        | in     | :ref:`t_cyclic`              | Whether cyclic mode is enabled or disabled                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
    rand_sig := my_rand.rand(rand_sig'length);
    rand_sig := my_rand.rand(rand_sig'length, -50, 50);
    rand_sig := my_rand.rand(rand_sig'length, ONLY, (-20,-10,0,10,20));
    rand_sig := my_rand.rand(rand_sig'length, -50, 50, ADD,(60));
    rand_sig := my_rand.rand(rand_sig'length, -50, 50, EXCL,(-25,25));
    rand_sig := my_rand.rand(rand_sig'length, -50, 50, ADD,(60), EXCL,(25));
    rand_sig := my_rand.rand(rand_sig'length, -50, 50, ADD,(60), EXCL,(-25,25));
    rand_sig := my_rand.rand(rand_sig'length, -50, 50, ADD,(-60,60,70,80), EXCL,(-25,25), CYCLIC);


.. _rand_sig_long:

return signed (long range)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random signed value. The signed constraints can be used for min and max values bigger than the integer's 32-bit range. 
The overload without the length parameter uses the max_value length for the return value. ::

    signed := rand(min_value, max_value, [msg_id_panel])
    signed := rand(length, min_value, max_value, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | min_value          | in     | signed                       | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | signed                       | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
    rand_sig := my_rand.rand(C_MIN_RANGE, v_max_range);
    rand_sig := my_rand.rand(rand_sig'length, C_MIN_RANGE, v_max_range);


.. _rand_slv:

return std_logic_vector
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random std_logic_vector value. Values are interpreted as unsigned and therefore constrained by the natural type. ::

    std_logic_vector := rand(length, [cyclic_mode, [msg_id_panel]])
    std_logic_vector := rand(length, min_value, max_value, [cyclic_mode, [msg_id_panel]])
    std_logic_vector := rand(length, set_type, set_values, [cyclic_mode, [msg_id_panel]])
    std_logic_vector := rand(length, min_value, max_value, set_type, set_value, [cyclic_mode, [msg_id_panel]])
    std_logic_vector := rand(length, min_value, max_value, set_type, set_values, [cyclic_mode, [msg_id_panel]])
    std_logic_vector := rand(length, min_value, max_value, set_type1, set_value1, set_type2, set_value2, [cyclic_mode, [msg_id_panel]])
    std_logic_vector := rand(length, min_value, max_value, set_type1, set_value1, set_type2, set_values2, [cyclic_mode, [msg_id_panel]])
    std_logic_vector := rand(length, min_value, max_value, set_type1, set_values1, set_type2, set_values2, [cyclic_mode, [msg_id_panel]])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | min_value          | in     | natural                      | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | natural                      | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_type           | in     | :ref:`t_set_type`            | Defines how to handle the set of values                       |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_value          | in     | natural                      | A single value used for the generation of the random number   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_values         | in     | t_natural_vector             | A set of values used for the generation of the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | cyclic_mode        | in     | :ref:`t_cyclic`              | Whether cyclic mode is enabled or disabled                    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
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
Returns a random std_logic_vector value. The std_logic_vector constraints can be used for min and max values bigger than the integer's 
32-bit range. The overload without the length parameter uses the max_value length for the return value. ::

    std_logic_vector := rand(min_value, max_value, [msg_id_panel])
    std_logic_vector := rand(length, min_value, max_value, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | min_value          | in     | std_logic_vector             | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | std_logic_vector             | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
    rand_slv := my_rand.rand(C_MIN_RANGE, v_max_range);
    rand_slv := my_rand.rand(rand_slv'length, C_MIN_RANGE, v_max_range);


.. _rand_sl:

return std_logic
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random std_logic value. ::

    std_logic := rand(VOID)
    std_logic := rand(msg_id_panel)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
    rand_sl := my_rand.rand(VOID);
    rand_sl := my_rand.rand(my_msg_id_panel);


.. _rand_bool:

return boolean
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a random boolean value. ::

    boolean := rand(VOID)
    boolean := rand(msg_id_panel)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
    rand_bool := my_rand.rand(VOID);
    rand_bool := my_rand.rand(my_msg_id_panel);


.. _rand_val_weight:

rand_val_weight()
----------------------------------------------------------------------------------------------------------------------------------
Returns a random value using a weighted distribution. Each given value has a weight which determines how often it is chosen during 
randomization. The sum of all weights need not be 100 since the probability is weight/sum_of_weights. ::

    integer          := rand_val_weight(weight_vector, [msg_id_panel])
    real             := rand_val_weight(weight_vector, [msg_id_panel])
    time             := rand_val_weight(weight_vector, [msg_id_panel])
    unsigned         := rand_val_weight(length, weight_vector, [msg_id_panel])
    signed           := rand_val_weight(length, weight_vector, [msg_id_panel])
    std_logic_vector := rand_val_weight(length, weight_vector, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | length             | in     | positive                     | The length of the value to be returned                        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | weight_vector      | in     | :ref:`t_val_weight_int_vec`  | A vector containing pairs of (value, weight)                  |
|          |                    |        |                              |                                                               |
|          |                    |        | :ref:`t_val_weight_real_vec` |                                                               |
|          |                    |        |                              |                                                               |
|          |                    |        | :ref:`t_val_weight_time_vec` |                                                               |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controls verbosity within a specified scope                   |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
    rand_int  := my_rand.rand_val_weight(((-5,10),(0,30),(5,60)));
    rand_real := my_rand.rand_val_weight(((-5.0,10),(0.0,30),(5.0,60)));
    rand_time := my_rand.rand_val_weight(((1 ns,10),(10 ns,30),(25 ns,60)));
    rand_uns  := my_rand.rand_val_weight(rand_uns'length, ((10,1),(20,3),(30,6)));
    rand_sig  := my_rand.rand_val_weight(rand_sig'length, ((-5,1),(0,2),(5,2)));
    rand_slv  := my_rand.rand_val_weight(rand_slv'length, ((10,5),(20,1),(30,1)));


.. _rand_range_weight:

rand_range_weight()
----------------------------------------------------------------------------------------------------------------------------------
Returns a random value using a weighted distribution. Each given range (min/max) has a weight which determines how often it is 
chosen during randomization. The sum of all weights need not be 100 since the probability is weight/sum_of_weights. 

The given weight is assigned to the range as a whole, i.e. each value within the range has a fraction of the given weight. This 
behavior can be changed to assigning the given weight equally to each value within the range by using 
``set_range_weight_default_mode(INDIVIDUAL_WEIGHT)`` (EXCEPT for the real and time types). ::

    integer          := rand_range_weight(weight_vector, [msg_id_panel])
    real             := rand_range_weight(weight_vector, [msg_id_panel])
    time             := rand_range_weight(weight_vector, [msg_id_panel])
    unsigned         := rand_range_weight(length, weight_vector, [msg_id_panel])
    signed           := rand_range_weight(length, weight_vector, [msg_id_panel])
    std_logic_vector := rand_range_weight(length, weight_vector, [msg_id_panel])

+----------+--------------------+--------+-------------------------------+---------------------------------------------------------------+
| Type     | Name               | Dir.   | Type                          | Description                                                   |
+==========+====================+========+===============================+===============================================================+
| constant | weight_vector      | in     | :ref:`t_range_weight_int_vec` | A vector containing sets of (min, max, weight). When using a  |
|          |                    |        |                               | single value it needs to be set equally for min and max.      |
|          |                    |        | :ref:`t_range_weight_real_vec`|                                                               |
|          |                    |        |                               |                                                               |
|          |                    |        | :ref:`t_range_weight_time_vec`|                                                               |
+----------+--------------------+--------+-------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel                | Controls verbosity within a specified scope                   |
+----------+--------------------+--------+-------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
    rand_int  := my_rand.rand_range_weight(((-5,-3,30),(0,0,20),(1,5,50)));
    rand_real := my_rand.rand_range_weight(((-5.0,-3.0,10),(0.0,0.0,30),(1.0,5.0,60)));
    rand_time := my_rand.rand_range_weight(((1 ns,5 ns,10),(10 ns,10 ns,30),(25 ns,50 ns,60)));
    rand_uns  := my_rand.rand_range_weight(rand_uns'length, ((10,15,1),(20,25,3),(30,35,6)));
    rand_sig  := my_rand.rand_range_weight(rand_sig'length, ((-5,-3,1),(0,0,2),(5,10,2)));
    rand_slv  := my_rand.rand_range_weight(rand_slv'length, ((10,15,5),(20,25,1),(30,35,1)));


.. _rand_range_weight_mode:

rand_range_weight_mode()
----------------------------------------------------------------------------------------------------------------------------------
Returns a random value using a weighted distribution. Each given range (min/max) has a weight which determines how often it is 
chosen during randomization. The sum of all weights need not be 100 since the probability is weight/sum_of_weights. 

The given weight can have two possible interpretations:

#. COMBINED_WEIGHT: The given weight is assigned to the range as a whole, i.e. each value within the range has a fraction of the 
   given weight.
#. INDIVIDUAL_WEIGHT: The given weight is assigned equally to each value within the range.

Note that the real and time weighted randomization functions only support the COMBINED_WEIGHT mode due to the very large number of 
values within a real/time range. ::

    integer          := rand_range_weight_mode(weight_vector, [msg_id_panel])
    real             := rand_range_weight_mode(weight_vector, [msg_id_panel])
    time             := rand_range_weight_mode(weight_vector, [msg_id_panel])
    unsigned         := rand_range_weight_mode(length, weight_vector, [msg_id_panel])
    signed           := rand_range_weight_mode(length, weight_vector, [msg_id_panel])
    std_logic_vector := rand_range_weight_mode(length, weight_vector, [msg_id_panel])

+----------+--------------------+--------+------------------------------------+---------------------------------------------------------------+
| Type     | Name               | Dir.   | Type                               | Description                                                   |
+==========+====================+========+====================================+===============================================================+
| constant | weight_vector      | in     | :ref:`t_range_weight_mode_int_vec` | A vector containing sets of (min, max, weight, mode). When    |
|          |                    |        |                                    | using a single value it needs to be set equally for min and   |
|          |                    |        | :ref:`t_range_weight_mode_real_vec`| max, and the mode to NA since it doesn't have any meaning.    |
|          |                    |        |                                    |                                                               |
|          |                    |        | :ref:`t_range_weight_mode_time_vec`|                                                               |
+----------+--------------------+--------+------------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel                     | Controls verbosity within a specified scope                   |
+----------+--------------------+--------+------------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
    rand_int  := my_rand.rand_range_weight_mode(((-5,-3,30,INDIVIDUAL_WEIGHT),(0,0,20,NA),(1,5,50,COMBINED_WEIGHT)));
    rand_real := my_rand.rand_range_weight_mode(((-5.0,-3.0,10,COMBINED_WEIGHT),(0.0,0.0,30,NA),(1.0,5.0,60,COMBINED_WEIGHT)));
    rand_time := my_rand.rand_range_weight_mode(((1 ns,5 ns,10,COMBINED_WEIGHT),(10 ns,10 ns,30,NA),(25 ns,50 ns,60,COMBINED_WEIGHT)));
    rand_uns  := my_rand.rand_range_weight_mode(rand_uns'length, ((10,15,1,INDIVIDUAL_WEIGHT),(20,20,3,NA),(30,35,6,COMBINED_WEIGHT)));
    rand_sig  := my_rand.rand_range_weight_mode(rand_sig'length, ((-5,-3,1,INDIVIDUAL_WEIGHT),(0,0,2,NA),(5,10,2,COMBINED_WEIGHT)));
    rand_slv  := my_rand.rand_range_weight_mode(rand_slv'length, ((10,15,5,INDIVIDUAL_WEIGHT),(20,20,1,NA),(30,35,1,COMBINED_WEIGHT)));
