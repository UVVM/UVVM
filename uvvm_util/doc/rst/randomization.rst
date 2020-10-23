Advanced randomization
======================
The functionality for advanced randomization is contained in *uvvm_util/src/rand_pkg.vhd*.

To generate random values using this package it is necessary to first create a variable with the protected type **t_rand**.

.. code-block::

    Example:
    variable my_rand : t_rand;
    addr := my_rand.rand(0,255);


Method descriptions
-------------------

set_rand_dist()
^^^^^^^^^^^^^^^
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


set_scope()
^^^^^^^^^^^
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


set_rand_seeds()
^^^^^^^^^^^^^^^^
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


get_rand_seeds()
^^^^^^^^^^^^^^^^
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
    my_rand.get_rand_seeds(seed1, seed2)
    seed_vector := my_rand.get_rand_seeds(VOID)


rand() {int}
^^^^^^^^^^^^
Returns a random integer value. ::

    integer := rand(min_value, max_value, [msg_id_panel])
    integer := rand(set_type, set_values, [msg_id_panel])
    integer := rand(min_value, max_value, set_type, set_values, [msg_id_panel])
    integer := rand(min_value, max_value, set_type1, set_values1, set_type2, set_values2, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | min_value          | in     | integer                      | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | integer                      | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_type           | in     | :ref:`t_set_type`            | Defines how to handle the set_values in relation to the range |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_values         | in     | integer_vector               | A set of values to generate the random number                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controlles verbosity within a specified scope                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
    rand_int := my_rand.rand(0, 50)
    rand_int := my_rand.rand(ONLY, (0,10,40,50))
    rand_int := my_rand.rand(0, 50, INCL,(60,70,80))
    rand_int := my_rand.rand(0, 50, EXCL,(25,35))
    rand_int := my_rand.rand(0, 50, INCL,(60,70,80), EXCL,(25,35))


rand() {real}
^^^^^^^^^^^^^
Returns a random real value. ::

    real := rand(min_value, max_value, [msg_id_panel])
    real := rand(set_type, set_values, [msg_id_panel])
    real := rand(min_value, max_value, set_type, set_values, [msg_id_panel])
    real := rand(min_value, max_value, set_type1, set_values1, set_type2, set_values2, [msg_id_panel])

+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| Type     | Name               | Dir.   | Type                         | Description                                                   |
+==========+====================+========+==============================+===============================================================+
| constant | min_value          | in     | real                         | The minimum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | max_value          | in     | real                         | The maximum value in the range to generate the random number  |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_type           | in     | :ref:`t_set_type`            | Defines how to handle the set_values in relation to the range |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | set_values         | in     | real_vector                  | A set of values to generate the random number                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+
| constant | msg_id_panel       | in     | t_msg_id_panel               | Controlles verbosity within a specified scope                 |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------------+

.. code-block::

    Examples:
    rand_real := my_rand.rand(0.0, 9.99)
    rand_real := my_rand.rand(ONLY, (0.0,1.0,1.5,2.0))
    rand_real := my_rand.rand(0, 9.99, INCL,(0.0,1.0,1.5,2.0))
    rand_real := my_rand.rand(0, 9.99, EXCL,(5.0,6.0))
    rand_real := my_rand.rand(0, 9.99, INCL,(0.0,1.0,1.5,2.0), EXCL,(5.0,6.0))
