.. _rand_pkg_overview:

##################################################################################################################################
Enhanced Randomization
##################################################################################################################################
**********************************************************************************************************************************
Getting started
**********************************************************************************************************************************
All the functionality for **Enhanced Randomization**, using protected types, can be found in *uvvm_util/src/rand_pkg.vhd*.

For more simple functionality, not using protected types, refer to the :ref:`basic_randomization`.

For a more balanced randomization between small and large ranges/sets, the :ref:`optimized_randomization` under *uvvm_util/src/func_cov_pkg.vhd* 
may be used.

To generate a random value using Enhanced Randomization it is necessary to import the utility library, create a variable with the 
protected type *t_rand* and call either the ``rand()`` or the ``randm()`` function from the variable depending on which approach 
is being used:

**1. Single-method approach:** The ``rand()`` function is constrained by the parameters it receives plus additional configuration 
values. This approach is useful for simple constraints or constraints which are not repeated constantly throughout the code.

.. code-block::

    library uvvm_util;
    context uvvm_util.uvvm_util_context;
    ...
    p_main : process
      variable my_rand : t_rand;
    begin
      -- Generate a random value in the range [0:255]
      addr := my_rand.rand(0, 255);

      -- Generate a random value in the range [0:64] and either 128 or 256, except for 32
      size := my_rand.rand(0, 64, ADD,(128,256), EXCL,(32));
      ...

**2. Multi-method approach:** The constraints for the ``randm()`` function need to be previously configured by using different 
procedures. The benefit of this approach is that the constraints only need to be defined once, instead of being repeated on every 
``randm()`` call, resulting in a code which is more structured and easier to read for complex constraints. It also supports more 
combinations of different constraints, such as multiple ranges.

.. code-block::

    library uvvm_util;
    context uvvm_util.uvvm_util_context;
    ...
    p_main : process
      variable my_rand : t_rand;
    begin
      -- Generate a random value in the range [0:255] and [500:511]
      my_rand.add_range(0, 255);
      my_rand.add_range(500, 511);
      addr := my_rand.randm(VOID);

      -- Clear the constraints so we can reuse the random generator variable
      my_rand.clear_constraints(VOID);

      -- Generate a random value in the range [0:64] and either 128 or 256, except for 32
      my_rand.add_range(0, 64);
      my_rand.add_val((128,256));
      my_rand.excl_val(32);
      size := my_rand.randm(VOID);
      ...

.. note::

    The syntax for all methods is given in :ref:`rand_pkg`.

**********************************************************************************************************************************
Single-method approach
**********************************************************************************************************************************
Constraints
==================================================================================================================================
There are different ways of constraining the random value in a clear and consistent manner when using the ``rand()`` function.

.. code-block::

    -- 1. Range
    addr := my_rand.rand(0, 99); -- Generates a value in the range [0:99]

    -- 2. Set of values
    addr := my_rand.rand(ONLY,(0,5,10)); -- Generates a value which is either 0, 5 or 10

    -- 3. Range and set of values
    addr := my_rand.rand(0, 50, ADD,(100));      -- Generates a value in the range [0:50] or 100
    addr := my_rand.rand(0, 50, ADD,(60,70,80)); -- Generates a value in the range [0:50] and either 60, 70 or 80

    -- 4. Range and exclude values
    addr := my_rand.rand(0, 50, EXCL,(25));      -- Generates a value in the range [0:50] except for 25
    addr := my_rand.rand(0, 50, EXCL,(20,30));   -- Generates a value in the range [0:50] except for 20 and 30

    -- 5. Range, set of values and exclude values
    addr := my_rand.rand(0, 50, ADD,(100), EXCL,(25));         -- Generates a value in the range [0:50] or 100, except for 25
    addr := my_rand.rand(0, 50, ADD,(100), EXCL,(20,30));      -- Generates a value in the range [0:50] or 100, except for 20 and 30
    addr := my_rand.rand(0, 50, ADD,(60,70,80), EXCL,(20,30)); -- Generates a value in the range [0:50] and either 60, 70 or 80, except for 20 and 30

For more information on the probability distribution click :ref:`here <rand_pkg_distributions>`.

Return types
==================================================================================================================================
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
    rand_sign     := my_rand.rand(rand_sign'length, -50, 50, EXCL,(-25,25));
    rand_slv      := my_rand.rand(rand_slv'length, 0, 50, ADD,(60), EXCL,(25,35)); -- SLV is interpreted as unsigned
    rand_sl       := my_rand.rand(VOID);
    rand_bool     := my_rand.rand(VOID);

The unsigned, signed and std_logic_vector functions can return vectors of any length, however the min and max constraints are 
limited by the integer's 32-bit range. Additional overloads for these types using unsigned/signed/std_logic_vector corresponding 
min and max constraints are provided as well.

    * :ref:`unsigned <rand_uns_long>`
    * :ref:`signed <rand_sig_long>`
    * :ref:`std_logic_vector <rand_slv_long>`

.. code-block::

    rand_uns  := my_rand.rand(rand_uns'length, C_MIN_VALUE, v_max_value);
    rand_sign := my_rand.rand(rand_sign'length, C_MIN_VALUE, v_max_value);
    rand_slv  := my_rand.rand(rand_slv'length, C_MIN_VALUE, v_max_value);  -- SLV is interpreted as unsigned

    -- In the following overloads, the length of the return value is equal to the largest length of the 2 parameters
    rand_uns  := my_rand.rand(C_MIN_VALUE, v_max_value);
    rand_sign := my_rand.rand(C_MIN_VALUE, v_max_value);
    rand_slv  := my_rand.rand(C_MIN_VALUE, v_max_value); -- SLV is interpreted as unsigned

**********************************************************************************************************************************
Multi-method approach
**********************************************************************************************************************************
Using the single-method approach does not have any effect on the multi-method approach or vice-versa. However, for readability it 
is not recommended to mix them.

Constraints
==================================================================================================================================
By using the following procedures, different combinations of constraints can be added for the ``randm()`` function. Note that when 
reusing the same *my_rand* variable, the ``clear_constraints()`` procedure must be called to remove any previous constraints.

.. code-block::

    -- 1. Single range
    my_rand.add_range(0, 99);
    addr := my_rand.randm(VOID); -- Generates a value in the range [0:99]

    -- 2. Multiple ranges
    my_rand.clear_constraints(VOID);
    my_rand.add_range(0, 99);
    my_rand.add_range(200, 299);
    my_rand.add_range(400, 499);
    addr := my_rand.randm(VOID); -- Generates a value in the ranges [0:99], [200:299] and [400:499]

    -- 3. Set of values
    my_rand.clear_constraints(VOID);
    my_rand.add_val((0,5,10));
    addr := my_rand.randm(VOID); -- Generates a value which is either 0, 5 or 10

    -- 4. Exclude values (only for integer, unsigned, signed and std_logic_vector return types)
    my_rand.clear_constraints(VOID);
    my_rand.excl_val((0,10,15));
    addr     := my_rand.randm(VOID); -- Generates a value from the complete integer range except for 0, 10 and 15
    data_uns := my_rand.randm(4);    -- Generates a 4-bit unsigned random value except for 0, 10 and 15

    -- 5. Range and set of values
    my_rand.clear_constraints(VOID);
    my_rand.add_range(0, 50);
    my_rand.add_range(100, 150);
    my_rand.add_val((60));
    my_rand.add_val((160,170,180));
    addr := my_rand.randm(VOID); -- Generates a value in the ranges [0:50], [100:150] and either 60, 160, 170 or 180

    -- 6. Range and exclude values
    my_rand.clear_constraints(VOID);
    my_rand.add_range(0, 50);
    my_rand.add_range(100, 150);
    my_rand.excl_val((25));
    my_rand.excl_val((20,30));
    addr := my_rand.randm(VOID); -- Generates a value in the ranges [0:50], [100:150] except for 20, 25 and 30

    -- 7. Set of values and exclude values
    my_rand.clear_constraints(VOID);
    my_rand.add_val((10,20,30,40,50,60,70));
    my_rand.excl_val((20,40,60));
    addr := my_rand.randm(VOID); -- Generates a value which is either 10, 30, 50 or 70

    -- 8. Range, set of values and exclude values
    my_rand.clear_constraints(VOID);
    my_rand.add_range(0, 50);
    my_rand.add_range(100, 150);
    my_rand.add_val((60));
    my_rand.add_val((160,170,180));
    my_rand.excl_val((25));
    my_rand.excl_val((20,30));
    addr := my_rand.randm(VOID); -- Generates a value in the ranges [0:50], [100:150] and either 60, 160, 170 or 180, except for 20, 25 and 30

    -- 9. No constraints (only for integer, unsigned, signed and std_logic_vector return types)
    my_rand.clear_constraints(VOID);
    addr      := my_rand.randm(VOID); -- Generates a value in the complete integer range
    data_sign := my_rand.randm(16);   -- Generates a 16-bit signed random value

Similar procedures exist for real constraints: ``add_range_real()``, ``add_val_real()`` and ``excl_val_real()``, and for time 
constraints: ``add_range_time()``, ``add_val_time()`` and ``excl_val_time()``.

.. note::

    * There is no limit on the number of constraints which can be added.
    * The order in which the constraints are added does not matter.
    * If a value is repeated in different "add" constraints, the probability of that value being selected will increase.

.. caution::

    Constraints of different value types, e.g. integer/real/time, should not be mixed, otherwise a TB_ERROR alert will be 
    generated. The procedure ``clear_constraints()`` can be used to removed any previously added constraints.

For more information on the probability distribution click :ref:`here <rand_pkg_distributions>`.

Return types
==================================================================================================================================
The ``randm()`` function can return the following types:

    * :ref:`integer <randm_int>`
    * :ref:`integer_vector <randm_int_vec>`
    * :ref:`real <randm_real>`
    * :ref:`real_vector <randm_real_vec>`
    * :ref:`time <randm_time>`
    * :ref:`time_vector <randm_time_vec>`
    * :ref:`unsigned <randm_uns>`
    * :ref:`signed <randm_sig>`
    * :ref:`std_logic_vector <randm_slv>`

For *std_logic* and *boolean* types use the ``rand(VOID)`` function, since they do not require any constraints.

.. code-block::

    my_rand.add_range(-50, 50);
    my_rand.add_val((60,70));
    my_rand.excl_val(0);
    rand_int      := my_rand.randm(VOID);
    rand_int_vec  := my_rand.randm(rand_int_vec'length);

    my_rand.clear_constraints(VOID);
    my_rand.add_range_real(0.0,0.2);
    my_rand.add_val_real((0.5,1.0,1.5,2.0));
    my_rand.excl_val_real(0.1);
    rand_real     := my_rand.randm(VOID);
    rand_real_vec := my_rand.randm(rand_real_vec'length);

    my_rand.clear_constraints(VOID);
    my_rand.add_range_time(0 ps, 100 ps);
    my_rand.add_val_time((160 ps,170 ps));
    my_rand.excl_val_time(50 ps);
    rand_time     := my_rand.randm(VOID);
    rand_time_vec := my_rand.randm(rand_time_vec'length);

    my_rand.clear_constraints(VOID);
    my_rand.add_range(0, 50);
    my_rand.add_val((60,70));
    my_rand.excl_val(25);
    rand_uns      := my_rand.randm(rand_uns'length);
    rand_sign     := my_rand.randm(rand_sign'length);
    rand_slv      := my_rand.randm(rand_slv'length); -- SLV is interpreted as unsigned

The unsigned, signed and std_logic_vector functions can return vectors of any length, however the integer constraints are limited 
to a 32-bit range. Additional overloads for adding range constraints using unsigned/signed types are provided as well. The 
maximum length of these constraints is defined by C_RAND_MM_MAX_LONG_VECTOR_LENGTH in adaptations_pkg.

    * :ref:`unsigned <add_range_unsigned>`
    * :ref:`signed <add_range_signed>`

.. code-block::

    my_rand.add_range_unsigned(x"0000000000000000", x"FFFF000000000000"); -- [0:18446462598732840960]
    rand_uns  := my_rand.randm(rand_uns'length);

    my_rand.clear_constraints(VOID);
    my_rand.add_range_signed(x"F000000000000000", x"0000000000000005");   -- [-1152921504606846976:5]
    rand_sign := my_rand.randm(rand_sign'length);

    my_rand.clear_constraints(VOID);
    my_rand.add_range_unsigned(x"000000000000", x"FF0000000000"); -- [0:280375465082880]
    rand_slv  := my_rand.randm(rand_slv'length);  -- SLV is interpreted as unsigned

.. caution::

    When a return type is not compatible with the value type of the configured constraints a TB_ERROR alert will be generated.

**********************************************************************************************************************************
Seeds
**********************************************************************************************************************************
Initializing the seeds to a unique value guarantees that two processes will not generate the same sequence of random values. They 
can be initialized using any string or two positive integers (when using a string, it will be converted into two positive integers).

.. hint::

    It is recommended to set the seed to the path of the actual variable in order to ensure uniqueness throughout the testbench.

.. code-block::

    -- Example 1
    my_rand.set_rand_seeds(my_rand'instance_name);

    -- Example 2
    my_rand.set_rand_seeds(10, 100);

The current seeds can be printed out, for instance when needing to recreate a certain random sequence, by using ``get_rand_seeds()``. 
This method will return the seeds as two positive integers or a positive integer vector.

.. code-block::

    -- Example 1
    my_rand.get_rand_seeds(seed1, seed2);

    -- Example 2
    seed_vector := my_rand.get_rand_seeds(VOID);

.. _rand_pkg_uniqueness:

**********************************************************************************************************************************
Uniqueness
**********************************************************************************************************************************
When returning a vector type (integer_vector, real_vector or time_vector) it is possible to generate unique random values for each 
element of the vector by using *uniqueness = UNIQUE*. The uniqueness applies only within the values returned from a single 
``rand()/randm()`` call, i.e. unique values may not generated across two or more ``rand()/randm()`` calls.

.. code-block::

    -- Single-method approach
    unique_addresses := my_rand.rand(unique_addresses'length, 0, 50, UNIQUE);

    -- Multi-method approach
    my_rand.set_uniqueness(UNIQUE);
    my_rand.add_range(0, 50);
    unique_addresses := my_rand.randm(unique_addresses'length);

If the constraints are not enough to generate unique values for the whole vector, an error will be reported.

.. code-block::

    -- Single-method approach
    unique_addresses := my_rand.rand(63, 0, 50, UNIQUE);

    -- Multi-method approach
    my_rand.set_uniqueness(UNIQUE);
    my_rand.add_range(0, 50);
    unique_addresses := my_rand.randm(63);

* The supported types are integer_vector, real_vector and time_vector.
* Cannot be combined with unsigned/signed constraints.
* Cannot be combined with the CYCLIC configuration.

.. _rand_pkg_cyclic:

**********************************************************************************************************************************
Cyclic generation
**********************************************************************************************************************************
By using *cyclic_mode = CYCLIC*, it is possible to generate random values which will not repeat until all the values within the 
constraints have been generated. Once this happens, the process starts over.

.. code-block::

    -- Single-method approach
    for i in 0 to num_addr-1 loop
      addr := my_rand.rand(0, 63, CYCLIC);
      ...
    end loop;

    -- Multi-method approach
    my_rand.set_cyclic_mode(CYCLIC);
    my_rand.add_range(0, 63);
    for i in 0 to num_addr-1 loop
      addr := my_rand.randm(VOID);
      ...
    end loop;

* The supported types are integer, integer_vector, unsigned, signed and std_logic_vector. Note that unsigned, signed and 
  std_logic_vector lengths bigger than 32 bits are not supported however.
* Cannot be combined with unsigned/signed constraints.
* Cannot be combined with the UNIQUE configuration.
* The state of the cyclic generation (which values have been generated) will be reset every time a ``rand()/randm()`` function 
  with a different signature (constraints) is called. It can also be manually reset with the ``clear_rand_cyclic()`` procedure.
* By default, a list is created to store the state of all the possible values to be generated. This list can require a lot of 
  memory for big ranges or even cause problems for the simulator. To avoid this, a different implementation using a dynamic queue 
  will be used instead when the range of values is greater than C_RAND_CYCLIC_LIST_MAX_NUM_VALUES defined in adaptations_pkg.

.. caution::
    When using the dynamic queue implementation, the simulation might slow down after a few thousand iterations due to the 
    parsing of the growing queue.

.. important::
    It is recommended to call ``clear_rand_cyclic()`` at the end of the testbench when using cyclic generation to de-allocate the
    list/queue.

.. _rand_pkg_distributions:

**********************************************************************************************************************************
Distributions
**********************************************************************************************************************************
By default, the Uniform distribution is used with the ``rand()/randm()`` functions, however it is also possible to select other 
distributions with the procedure ``set_rand_dist()``.

Uniform
==================================================================================================================================
* Default distribution.
* The supported types are integer, integer_vector, real, real_vector, time, time_vector, unsigned, signed, std_logic_vector, 
  std_logic and boolean.
* No restrictions on configuration parameters.
* When combining a range with a set of values, the probability of generating any legal value is 1/(number of legal values). The 
  only exception to this rule is for real values.
* When combining a real range with a set of real values, the probability will be 50% for the range and 50% for the set of values, 
  hence any number in the set of values will have a higher probability than any single number within the range, otherwise the set 
  of values would be rarely generated due to the large number of values within a real range.

Gaussian (Normal)
==================================================================================================================================
* The supported types are integer, integer_vector, real, real_vector, unsigned, signed and std_logic_vector. Note that unsigned, 
  signed and std_logic_vector lengths bigger than 32 bits are not supported however.
* The types *time* and *time_vector* are not supported, use instead *integer* and multiply by the time unit.
* Only single range (min/max) constraints are supported, i.e. no multiple ranges or set of values are supported.
* Cannot be combined with CYCLIC or UNIQUE configurations.
* Cannot be combined with weighted randomization methods.
* To configure the mean and std_deviation use the ``set_rand_dist_mean()`` and ``set_rand_dist_std_deviation()`` procedures 
  respectively.
* If not configured, the default mean will be (max-min)/2 and the default std_deviation will be (max-min)/6. These two default 
  values have no special meaning other than giving a fair distribution curve.
* To clear the configured mean and std_deviation and go back to the default, use ``clear_rand_dist_mean()`` and 
  ``clear_rand_dist_std_deviation()`` procedures respectively.

.. code-block::

    -- Single-method approach
    my_rand.set_rand_dist(GAUSSIAN);
    for i in 1 to 5000 loop
      addr := my_rand.rand(-10, 10);
    end loop;

    -- Multi-method approach
    my_rand.set_rand_dist(GAUSSIAN);
    my_rand.add_range(-10, 10);
    for i in 1 to 5000 loop
      addr := my_rand.randm(VOID);
    end loop;

.. _rand_pkg_weighted:

Weighted
==================================================================================================================================
This distribution does NOT use the ``set_rand_dist()`` procedure, but instead uses different methods with parameters of 
(value + weight) or (range of values + weight). The method names contain the order of the parameters for better readability.

**Single-method approach**
    * :ref:`rand_val_weight`
    * :ref:`rand_range_weight`
    * :ref:`rand_range_weight_mode`

**Multi-method approach**
    * :ref:`add_val_weight`
    * :ref:`add_val_weight_real`
    * :ref:`add_val_weight_time`
    * :ref:`add_range_weight`
    * :ref:`add_range_weight_real`
    * :ref:`add_range_weight_time`

.. note::

    **For multi-method approach:**
        * Any non-weighted value and range constraints will have a default weight of 1.
        * Any exclude constraints will be ignored.
        * Cannot be combined with CYCLIC or UNIQUE configurations.

The supported types are integer, real, time, unsigned, signed and std_logic_vector.

.. important::
    The sum of all weights could be any value since each individual probability is equal to individual_weight/sum_of_weights.

When specifying a weight for a range of values there are two possible interpretations:

#. COMBINED_WEIGHT: The given weight is assigned to the range as a whole, i.e. each value within the range has an equal fraction 
   of the given weight.
#. INDIVIDUAL_WEIGHT: The given weight is assigned equally to each value within the range, hence the range will have a total 
   weight higher than the given weight.

The default mode is COMBINED_WEIGHT, however this can be changed using the ``set_range_weight_default_mode()`` procedure. 
Alternatively, it is possible to explicitly define the mode when using ``rand_range_weight_mode()`` or ``add_range_weight()``.

.. code-block::

    --------------------------------------------------------------------------------------------------------------------
    -- Example 1: value, weight
    -- Generate a value which is either -5, 0 or 5 with their corresponding weights
    --------------------------------------------------------------------------------------------------------------------
    -- Single-method approach
    addr := my_rand.rand_val_weight(((-5,1),(0,3),(5,1)));

    -- Multi-method approach
    my_rand.add_val_weight(-5,1);
    my_rand.add_val_weight(0,3);
    my_rand.add_val_weight(5,1);
    addr := my_rand.randm(VOID);

    --------------------------------------------------------------------------------------------------------------------
    -- Example 2: range(min/max), weight
    -- Generate a value in the range [-5:-3], 0 and the range [1:5] with their corresponding weights and default mode
    --------------------------------------------------------------------------------------------------------------------
    -- Single-method approach
    addr := my_rand.rand_range_weight(((-5,-3,30),(0,0,20),(1,5,50)));

    -- Multi-method approach
    my_rand.add_range_weight(-5,-3,30);
    my_rand.add_val_weight(0,20);
    my_rand.add_range_weight(1,5,50);
    addr := my_rand.randm(VOID);

    --------------------------------------------------------------------------------------------------------------------
    -- Example 3: range(min/max), weight, weight mode
    -- Generate a value in the range [-5:-3], 0 and the range [1:5] with their corresponding weights and explicit modes
    --------------------------------------------------------------------------------------------------------------------
    -- Single-method approach
    addr := my_rand.rand_range_weight_mode(((-5,-3,30,COMBINED_WEIGHT),(0,0,20,NA),(1,5,50,COMBINED_WEIGHT)));

    -- Multi-method approach
    my_rand.add_range_weight(-5,-3,30,COMBINED_WEIGHT);
    my_rand.add_val_weight(0,20);
    my_rand.add_range_weight(1,5,50,COMBINED_WEIGHT);
    addr := my_rand.randm(VOID);

.. note::
    While it is possible to use different weight modes for each range in the same randomization call, it is recommended to use the 
    same modes to avoid confusion regarding the distribution of the weights.

.. note::
    The real and time weighted randomization methods only support the COMBINED_WEIGHT mode due to the very large number of values 
    within a real/time range.

.. _rand_pkg_config_report:

**********************************************************************************************************************************
Configuration report
**********************************************************************************************************************************
A report containing all the configuration parameters can be printed using the ``report_config()`` procedure.

A name can be given to the random generator by calling the ``set_name()`` procedure. This is useful when printing reports for 
several random generator instances.
The maximum length of the name is determined by C_RAND_MAX_NAME_LENGTH defined in adaptations_pkg.

.. code-block::

    my_rand.report_config(VOID);

.. code-block:: none

    # UVVM:  =================================================================================================================
    # UVVM:  ***  REPORT OF RANDOM GENERATOR CONFIGURATION ***
    # UVVM:  =================================================================================================================
    # UVVM:           NAME               :                    MY_RAND_GEN
    # UVVM:           SCOPE              :                       MY_SCOPE
    # UVVM:           SEED 1             :                     1969513907
    # UVVM:           SEED 2             :                     1510976018
    # UVVM:           DISTRIBUTION       :                        UNIFORM
    # UVVM:           WEIGHT MODE        :                COMBINED_WEIGHT
    # UVVM:           MEAN CONFIGURED    :                          false
    # UVVM:           MEAN               :                           0.00
    # UVVM:           STD_DEV CONFIGURED :                          false
    # UVVM:           STD_DEV            :                           0.00
    # UVVM:  =================================================================================================================

In the case of the multi-method approach, the configured constraints will also be printed in the report:

.. code-block:: none

    # UVVM: ==================================================================================================================
    # UVVM: ***  REPORT OF RANDOM GENERATOR CONFIGURATION ***
    # UVVM: ==================================================================================================================
    # UVVM:           NAME               :                    MY_RAND_INT
    # UVVM:           SCOPE              :                        TB seq.
    # UVVM:           SEED 1             :                         400140
    # UVVM:           SEED 2             :                        4069200
    # UVVM:           DISTRIBUTION       :                        UNIFORM
    # UVVM:           WEIGHT MODE        :                COMBINED_WEIGHT
    # UVVM:           MEAN CONFIGURED    :                          false
    # UVVM:           MEAN               :                           0.00
    # UVVM:           STD_DEV CONFIGURED :                          false
    # UVVM:           STD_DEV            :                           0.00
    # UVVM: ------------------------------------------------------------------------------------------------------------------
    # UVVM:           MULTI-METHOD CONSTRAINTS
    # UVVM: ------------------------------------------------------------------------------------------------------------------
    # UVVM:           CYCLIC MODE             : CYCLIC
    # UVVM:           UNIQUENESS              : NON_UNIQUE
    # UVVM:           RANGE INTEGER VALUES    : [10:20],[30:40],[50:60]
    # UVVM:           INCLUDED INTEGER VALUES : (100)
    # UVVM:           EXCLUDED INTEGER VALUES : (15, 35, 55)
    # UVVM: ==================================================================================================================

.. code-block:: none

    # UVVM: ==================================================================================================================
    # UVVM: ***  REPORT OF RANDOM GENERATOR CONFIGURATION ***
    # UVVM: ==================================================================================================================
    # UVVM:           NAME               :                   MY_RAND_REAL
    # UVVM:           SCOPE              :                        TB seq.
    # UVVM:           SEED 1             :                      299323893
    # UVVM:           SEED 2             :                     1995729824
    # UVVM:           DISTRIBUTION       :                        UNIFORM
    # UVVM:           WEIGHT MODE        :                COMBINED_WEIGHT
    # UVVM:           MEAN CONFIGURED    :                          false
    # UVVM:           MEAN               :                           0.00
    # UVVM:           STD_DEV CONFIGURED :                          false
    # UVVM:           STD_DEV            :                           0.00
    # UVVM: ------------------------------------------------------------------------------------------------------------------
    # UVVM:           MULTI-METHOD CONSTRAINTS
    # UVVM: ------------------------------------------------------------------------------------------------------------------
    # UVVM:           CYCLIC MODE             : NON_CYCLIC
    # UVVM:           UNIQUENESS              : NON_UNIQUE
    # UVVM:           WEIGHTED REAL VALUES    : ([10.00:20.00],1,COMBINED),([30.00:40.00],5,COMBINED),(0.00,1),(1.00,8)
    # UVVM: ==================================================================================================================


**********************************************************************************************************************************
Clearing configuration
**********************************************************************************************************************************
To clear the complete configuration in the random generator use the ``clear_config()`` procedure.

**********************************************************************************************************************************
Additional info
**********************************************************************************************************************************
Log messages within the procedures and functions in the *rand_pkg* use the following message IDs (disabled by default):

* ID_RAND_GEN: Used for logging "Enhanced Randomization" values returned by ``rand()/randm()``.
* ID_RAND_CONF: Used for logging "Enhanced Randomization" configuration changes, except from name and scope.

The default scope for log messages in the *rand_pkg* is C_TB_SCOPE_DEFAULT and it can be updated using the procedure ``set_scope()``. 
The maximum length of the scope is defined by C_LOG_SCOPE_WIDTH. Both of these constants are defined in adaptations_pkg.

The number of decimal digits displayed in the real values logs can be adjusted with C_RAND_REAL_NUM_DECIMAL_DIGITS in adaptations_pkg.

.. note::

    Enhanced Randomization, Optimized Randomization and Functional Coverage were inspired by general statistics and similar 
    functionality in SystemVerilog and OSVVM.

.. _rand_pkg:

**********************************************************************************************************************************
rand_pkg
**********************************************************************************************************************************
The following links contain information regarding the API of the protected type *t_rand* and all the type definitions inside 
*rand_pkg*.

.. toctree::
   :maxdepth: 1

   rand_pkg_t_rand.rst
   rand_pkg_types.rst

.. include:: rst_snippets/ip_disclaimer.rst
