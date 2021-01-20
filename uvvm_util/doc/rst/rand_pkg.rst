rand_pkg
========

.. _set_rand_dist:

set_rand_dist()
---------------
Configures the randomization distribution to be used with the rand() functions. ::

    set_rand_dist(rand_dist)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | rand_dist          | in     | :ref:`t_rand_dist`           | Randomization distribution, e.g. UNIFORM, GAUSSIAN    |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_rand.set_rand_dist(GAUSSIAN);


.. _set_scope:

set_scope()
-----------
Configures the scope used in the log messages. ::

    set_scope(scope)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    Examples:
    my_rand.set_scope("MY_SCOPE");


.. _set_rand_seeds:

set_rand_seeds()
----------------
Configures the randomization seeds. ::

    set_rand_seeds(str)
    set_rand_seeds(seed1, seed2)
    set_rand_seeds(seeds)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | str                | in     | string                       | A unique string which will generate the seeds         |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | seed1              | in     | positive                     | A positive number representing seed 1                 |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | seed2              | in     | positive                     | A positive number representing seed 2                 |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| constant | seeds              | in     | :ref:`t_positive_vector`     | A 2-dimensional vector containing both seeds          |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block::

    Examples:
    my_rand.set_rand_seeds("STRING");
    my_rand.set_rand_seeds(10, 100);
    my_rand.set_rand_seeds(seed_vector);


.. _get_rand_seeds:

get_rand_seeds()
----------------
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


.. _rand_int:

rand() {int}
------------
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
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controlles verbosity within a specified scope                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
    rand_int := my_rand.rand(0, 50);
    rand_int := my_rand.rand(ONLY, (0,10,40,50));
    rand_int := my_rand.rand(0, 50, INCL,(60));
    rand_int := my_rand.rand(0, 50, EXCL,(25,35));
    rand_int := my_rand.rand(0, 50, INCL,(60), EXCL,(25));
    rand_int := my_rand.rand(0, 50, INCL,(60), EXCL,(25,35));
    rand_int := my_rand.rand(0, 50, INCL,(60,70,80), EXCL,(25,35), CYCLIC);


.. _rand_real:

rand() {real}
-------------
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
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controlles verbosity within a specified scope                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
    rand_real := my_rand.rand(0.0, 9.99);
    rand_real := my_rand.rand(ONLY, (0.0,1.0,1.5,2.0));
    rand_real := my_rand.rand(0.0, 9.99, INCL,(20.0));
    rand_real := my_rand.rand(0.0, 9.99, EXCL,(5.0,6.0));
    rand_real := my_rand.rand(0.0, 9.99, INCL,(20.0), EXCL,(5.0));
    rand_real := my_rand.rand(0.0, 9.99, INCL,(20.0), EXCL,(5.0,6.0));
    rand_real := my_rand.rand(0.0, 9.99, INCL,(20.0,30.0,40.0), EXCL,(5.0,6.0));
