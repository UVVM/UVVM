##################################################################################################################################
Advanced randomization
##################################################################################################################################
All the functionality for advanced randomization can be found in *uvvm_util/src/rand_pkg.vhd*.

To generate a random value using this package it is necessary to import the utility library, create a variable with the protected 
type *t_rand* and call the ``rand()`` function from the variable.

.. code-block::

    library uvvm_util;
    context uvvm_util.uvvm_util_context;
    ...
    p_main : process
      variable my_rand : t_rand;
    begin
      -- Generate a random value between 0 and 255
      addr := my_rand.rand(0, 255);
      ...

**********************************************************************************************************************************
Seeds
**********************************************************************************************************************************
Initializing the seeds to a unique value guarantees that two processes will not generate the same sequence of random values. They 
can be initialized using any string or two positive values.

.. code-block::

    my_rand.set_rand_seeds("my_rand");
    my_rand.set_rand_seeds(10, 100);

The current seeds can be printed out, in case there is a need to recreate a certain random sequence, by using ``get_rand_seeds()``.

**********************************************************************************************************************************
Constraints
**********************************************************************************************************************************
There are different ways of constraining the random value in a clear and consistent manner.

.. code-block::

    -- 1. min & max values
    addr := my_rand.rand(0, 99); -- Generates a value between 0 and 99

    -- 2. set of values
    addr := my_rand.rand(ONLY,(0,5,10)); -- Generates a value which is either 0, 5 or 10

    -- 3. min & max + set of values
    addr := my_rand.rand(0, 50, ADD,(60,70,80)); -- Generates a value between 0 and 50 and either 60, 70 or 80
    addr := my_rand.rand(0, 50, EXCL,(25));      -- Generates a value between 0 and 50 except for 25

    -- 4. min & max + two sets of values
    addr := my_rand.rand(0, 50, ADD,(60,70,80), EXCL,(25)); -- Generates a value between 0 and 50 and either 60, 70 or 80, except for 25

**********************************************************************************************************************************
Types
**********************************************************************************************************************************
The ``rand()`` function can return the following types:

    * :ref:`integer <rand_int>`
    * :ref:`integer_vector <rand_int_vec>`
    * :ref:`real <rand_real>`
    * :ref:`real_vector <rand_real_vec>`
    * :ref:`time <rand_time>`
    * :ref:`time_vector <rand_time_vec>`
    * :ref:`unsigned <rand_uns>`
    * :ref:`signed <rand_sig>`
    * :ref:`std_logic_vector <rand_slv>`
    * :ref:`std_logic <rand_sl>`
    * :ref:`boolean <rand_bool>`

.. code-block::

    rand_int      := my_rand.rand(-50, 50);
    rand_int_vec  := my_rand.rand(rand_int_vec'length, -50, 50);
    rand_real     := my_rand.rand(ONLY, (0.5,1.0,1.5,2.0));
    rand_real_vec := my_rand.rand(rand_real_vec'length, 0.0, 9.99);
    rand_time     := my_rand.rand(0 ps, 100 ps);
    rand_time_vec := my_rand.rand(rand_time_vec'length, 0 ps, 100 ps);
    rand_uns      := my_rand.rand(rand_uns'length, 0, 50, ADD,(60));
    rand_sig      := my_rand.rand(rand_sig'length, -50, 50, EXCL,(-25,25));
    rand_slv      := my_rand.rand(rand_slv'length, 0, 50, ADD,(60), EXCL,(25,35));
    rand_sl       := my_rand.rand(VOID);
    rand_bool     := my_rand.rand(VOID);

The unsigned, signed and std_logic_vector functions can return any size vector, however the min and max constraints are limited 
by the integer's 32-bit range. Additional overloads for these types using unsigned/signed/std_logic_vector corresponding min and 
max constraints are provided as well.

    * :ref:`unsigned <rand_uns_long>`
    * :ref:`signed <rand_sig_long>`
    * :ref:`std_logic_vector <rand_slv_long>`

.. code-block::

    rand_uns := my_rand.rand(C_MIN_RANGE, v_max_range);
    rand_uns := my_rand.rand(rand_uns'length, C_MIN_RANGE, v_max_range);
    rand_sig := my_rand.rand(C_MIN_RANGE, v_max_range);
    rand_sig := my_rand.rand(rand_sig'length, C_MIN_RANGE, v_max_range);
    rand_slv := my_rand.rand(C_MIN_RANGE, v_max_range);
    rand_slv := my_rand.rand(rand_slv'length, C_MIN_RANGE, v_max_range);

**********************************************************************************************************************************
Uniqueness
**********************************************************************************************************************************
When returning a vector type (integer, real or time) it is possible to generate unique random values for each element of the vector 
by setting the parameter *uniqueness = UNIQUE* in the ``rand()`` function.

.. code-block::

    addr_vec := my_rand.rand(addr_vec'length, 0, 50, UNIQUE);

If the constraints are not enough to generate unique values for the whole vector, an error will be reported.

**********************************************************************************************************************************
Cyclic generation
**********************************************************************************************************************************
By setting the parameter *cyclic_mode = CYCLIC* in the ``rand()`` function, it is possible to generate random values which will
not repeat until all the values within the constraints have been generated. Once this happens, the process starts over.

.. code-block::

    addr := my_rand.rand(0, 63, CYCLIC);

* The supported types are integer, integer_vector, unsigned, signed and std_logic_vector. Note that unsigned, signed and 
  std_logic_vector lengths bigger than 32 bits are not supported however.
* Cyclic generation cannot be combined with the uniqueness parameter in the vector types.
* The state of the cyclic generation (which values have been generated) will be reset every time a ``rand()`` function with 
  different constraints is called. It can also be manually reset with the ``clear_rand_cyclic()`` procedure.
* By default, a list is created to store the state of all the possible values to be generated. This list can require a lot of memory 
  for big ranges or even cause problems for the simulator. To avoid this, a different implementation using a dynamic queue will be 
  used instead when the range of values is greater than C_RAND_CYCLIC_LIST_MAX_NUM_VALUES defined in adaptations_pkg.

.. caution::
    When using the dynamic queue implementation, the simulation might slow down after a few thousand iterations due to the 
    parsing of the growing queue.

.. important::
    It is recommended to call ``clear_rand_cyclic()`` at the end of the testbench when using cyclic generation to deallocate the
    list/queue.

**********************************************************************************************************************************
Distributions
**********************************************************************************************************************************
By default, the Uniform distribution is used with the ``rand()`` function, however it is also possible to select other distributions
with the procedure ``set_rand_dist()``.

Gaussian (Normal)
==================================================================================================================================
* The supported types are integer, integer_vector, real, real_vector, unsigned, signed and std_logic_vector. Note that unsigned, 
  signed and std_logic_vector lengths bigger than 32 bits are not supported however.
* The types *time* and *time_vector* are not supported with this distribution. Use instead *integer* and multiply by time unit.
* Only the min/max constraints are supported when using this distribution, i.e. no set_of_values are supported.
* Cannot be combined with cyclic or uniqueness parameters.
* Cannot be combined with weighted randomization functions.
* To configure the mean and std_deviation use the ``set_rand_dist_mean()`` and ``set_rand_dist_std_deviation()`` procedures respectively.
* If not configured, the default mean will be (max-min)/2 and the default std_deviation will be (max-min)/6.
* To clear the configured mean and std_deviation and go back to the default, use ``clear_rand_dist_mean()`` and ``clear_rand_dist_std_deviation()`` 
  procedures respectively.

.. code-block::

    my_rand.set_rand_dist(GAUSSIAN);
    for i in 1 to 5000 loop
      addr := my_rand.rand(-10, 10);
    end loop;

Weighted
==================================================================================================================================
This distribution does NOT use the ``set_rand_dist()`` procedure, but instead uses different randomization functions with parameters
of (value + weight) or (range of values + weight). The function names contain the order of the parameters for better readability.

    * :ref:`rand_val_weight`
    * :ref:`rand_range_weight`
    * :ref:`rand_range_weight_mode`

.. note::
    The sum of all weights need not be 100 since the probability is equal to weight/sum_of_weights.

When specifying a weight for a range of values there are two possible scenarios:

#. Combined weight: The given weight is assigned to the range as a whole, i.e. each value within the range has a fraction of the 
   given weight.
#. Individual weight: The given weight is assigned equally to each value within the range.

The default mode is COMBINED_WEIGHT, however this can be changed using the ``set_range_weight_default_mode()`` procedure. Alternatively,
it is possible to explicitly define the mode in the ``rand_range_weight_mode()`` function.

.. code-block::

    -- 1. value, weight
    my_rand.rand_val_weight(((-5,10),(0,30),(5,60))); -- Generates a value which is either -5, 0 or 5 with their corresponding weights

    -- 2. range(min/max), weight
    my_rand.rand_range_weight(((-5,-3,30),(0,0,20),(1,5,50))); -- Generates a value between -5 and -3, 0 and between 1 and 5 with 
                                                               -- their corresponding weights and default mode

    -- 3. range(min/max), weight, weight mode
    my_rand.rand_range_weight_mode(((-5,-3,30,INDIVIDUAL_WEIGHT),(0,0,20,NA),(1,5,50,COMBINED_WEIGHT))); -- Generates a value between -5 and -3, 0 and between 
                                                                                                         -- 1 and 5 with their corresponding weights and explicit modes

The supported types are integer, real, time, unsigned, signed and std_logic_vector.

.. note::
    The real and time weighted randomization functions only support the COMBINED_WEIGHT mode due to the very large number of values 
    within a real/time range.

**********************************************************************************************************************************
Configuration report
**********************************************************************************************************************************
A report containing all the configuration parameters can be printed using the ``report_config()`` procedure.

A name can be given to the random generator by calling the ``set_name()`` procedure. This is useful when printing several reports.
The maximum length of the name is determined by C_RAND_MAX_NAME_LENGTH defined in adaptations_pkg.

.. code-block::

    my_rand.report_config(VOID);

.. code-block:: none

    # UVVM:  =================================================================================================================
    # UVVM:  ***  REPORT OF RANDOM GENERATOR CONFIGURATION ***
    # UVVM:  =================================================================================================================
    # UVVM:            NAME               :                    MY_RAND_GEN
    # UVVM:            SCOPE              :                       MY SCOPE
    # UVVM:            SEED 1             :                     1969513907
    # UVVM:            SEED 2             :                     1510976018
    # UVVM:            DISTRIBUTION       :                        UNIFORM
    # UVVM:            WEIGHT MODE        :                COMBINED_WEIGHT
    # UVVM:            MEAN CONFIGURED    :                          false
    # UVVM:            MEAN               :                           0.00
    # UVVM:            STD_DEV CONFIGURED :                          false
    # UVVM:            STD_DEV            :                           0.00
    # UVVM:  =================================================================================================================

**********************************************************************************************************************************
Additional info
**********************************************************************************************************************************
Log messages within the procedures and functions in the *rand_pkg* use the following message IDs (disabled by default):

* ID_RAND_GEN: Used for logging random generated values
* ID_RAND_CONF: Used for logging randomization configuration

The default scope for log messages in the *rand_pkg* is C_TB_SCOPE_DEFAULT and it can be updated using the procedure ``set_scope()``. 
The maximum length of the scope is defined by C_LOG_SCOPE_WIDTH. Both of these constants are defined in adaptations_pkg.

The number of decimal digits displayed in the real values logs can be adjusted with C_RAND_REAL_NUM_DECIMAL_DIGITS in adaptations_pkg.

**********************************************************************************************************************************
rand_pkg
**********************************************************************************************************************************
.. toctree::
   :maxdepth: 1

   rand_pkg_types.rst
   rand_pkg_t_rand.rst
