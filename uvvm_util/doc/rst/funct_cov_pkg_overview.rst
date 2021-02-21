Functional Coverage
===================
The features for functional coverage can be found in *uvvm_util/src/funct_cov_pkg.vhd*.

To start using functional coverage it is necessary to import the utility library, create a variable with the protected 
type *t_cov_point* and call the ``add_bins()`` and ``sample_coverage()`` procedures from the variable.

.. code-block::
    :linenos:

    library uvvm_util;
    context uvvm_util.uvvm_util_context;

    p_main : process
      variable my_cov_point : t_cov_point;
      variable my_addr      : integer;
    begin
      -- Add bins to the coverage point
      my_cov_point.add_bins(bin(0), "bin_zero");
      my_cov_point.add_bins(bin_range(1,254,1));
      my_cov_point.add_bins(bin(255), "bin_max");

      -- Sample the data
      while not(my_cov_point.coverage_complete(VOID)) loop
        my_addr := my_cov_point.rand(VOID);
        my_cov_point.sample_coverage(my_addr);
      end loop;
      
      -- Print the summary report
      my_cov_point.print_summary(VOID);
      ...

Creating and adding bins
------------------------

There are different ways of creating bins using the following functions, allowing for flexibility and readability.

.. code-block::

    -- 1. Create a single bin using a single value
    bin(0)
    -- 2. Create a single bin using multiple values (the values are ORed)
    bin((2,4,6,8))
    -- 3. Divide a range of values into a number of bins
    bin_range(1, 10, 2)
    -- 4. Create a single bin for each value in a given range
    bin_range(0, 5)
    -- 5. Create a single bin for each value in a vector's range
    bin_vector(v_slv)
    -- 6. Create a single bin with a transition of values
    bin_transition((1,3,5,7))

With the functions above and the procedure ``add_bins()`` we can add as many bins we want to the coverpoint.

.. code-block::

    -- 1. Add a single bin using a single value
    my_cov_point.add_bins(bin(0));
    -- 2. Add a single bin using multiple values (the values are ORed)
    my_cov_point.add_bins(bin((2,4,6,8)));
    -- 3. Divide a range of values into a number of bins
    my_cov_point.add_bins(bin_range(1, 10, 2));
    -- 4. Add a single bin for each value in a given range
    my_cov_point.add_bins(bin_range(0, 5));
    -- 5. Add a single bin for each value in a vector's range
    my_cov_point.add_bins(bin_vector(v_slv));
    -- 6. Add a single bin with a transition of values
    my_cov_point.add_bins(bin_transition((1,3,5,7)));

The bin functions can also be concatenated and several sets of bins can be added in one line.

.. code-block::

    my_cov_point.add_bins(bin(0) & bin((2,4,6,8)) & bin_range(50, 100, 2));

Ignore bins
-----------

Specific values can be excluded from the coverage by using ignore bins.

.. code-block::

    my_cov_point.add_bins(ignore_bin(255));
    my_cov_point.add_bins(ignore_bin_range(50, 60));
    my_cov_point.add_bins(ignore_bin_transition((0,100,200)));

Illegal bins
------------

Specific values can be marked as illegal which will exclude them from the coverage and generate an alert if they occur.

.. code-block::

    my_cov_point.add_bins(illegal_bin(256));
    my_cov_point.add_bins(illegal_bin_range(220, 250));
    my_cov_point.add_bins(illegal_bin_transition((200,100,0)));

Bin names
---------

When creating bins, an optional name can be added. This is useful when reading the reports.

.. code-block::

    my_cov_point.add_bins(bin(255), "bin_max");

Minimum coverage
----------------

Specifies how many times a value in a bin must be sampled so that the bin is marked as covered. Default is 1.

.. code-block::

    my_cov_point.add_bins(bin(0), 1);
    my_cov_point.add_bins(bin(2), 5);
    my_cov_point.add_bins(bin(4), 5);

Randomization
-------------

Using the rand_pkg, random values can be generated within the coverage holes to reduce simulation time.

.. code-block::

    my_addr := my_cov_point.rand(VOID);

Randomization weights
---------------------

Specifies the relative number of times a bin will be selected during randomization. Default is 1.

.. code-block::

    my_cov_point.add_bins(bin(0), 1, 1);
    my_cov_point.add_bins(bin(2), 1, 3);
    my_cov_point.add_bins(bin(4), 1, 6);

Cross coverage
--------------

Coverage goal
--------------

Defines a percentage of the total coverage to complete. This can be used to scale the simulation time without changing the minimum
coverage for each bin by multiplying or dividing each minimum coverage. Default is 100.

.. code-block::

    -- Set the coverage goal to 50%
    my_cov_point.set_coverage_goal(50);

Coverage report
---------------

.. code-block:: none

    # UVVM:      ====================================================================================================================================================================
    # UVVM:      0 ns *** FUNCTIONAL COVERAGE SUMMARY: TB seq.(uvvm) ***                                                                                                             
    # UVVM:      ====================================================================================================================================================================
    # UVVM:      Coverpoint:     covpoint 1
    # UVVM:      Uncovered bins: 4/5
    # UVVM:      Illegal bins:   0
    # UVVM:      Coverage:       20.00% (accumulated: 20.00%)
    # UVVM:      --------------------------------------------------------------------------------------------------------------------------------------------------------------------
    # UVVM:                             BINS                         HITS          MIN_HITS        COVERAGE      RAND_WEIGHT           NAME              STATUS                      
    # UVVM:                             (50)                          0               1             0.00%             1                                UNCOVERED                     
    # UVVM:                        (100, 200, 300)                    0               1             0.00%             1                                UNCOVERED                     
    # UVVM:                          (50 to 74)                       0               1             0.00%             1                                UNCOVERED                     
    # UVVM:                          (75 to 100)                      0               1             0.00%             1                                UNCOVERED                     
    # UVVM:                              (3)                          1               1            100.00%            1                val3             COVERED                      
    # UVVM:      ====================================================================================================================================================================

