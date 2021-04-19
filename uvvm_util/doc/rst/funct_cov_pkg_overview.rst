##################################################################################################################################
Functional Coverage
##################################################################################################################################
All the functionality for coverage can be found in *uvvm_util/src/funct_cov_pkg.vhd*.

To start using functional coverage it is necessary to import the utility library, create a variable with the protected 
type *t_coverpoint* and call the ``add_bins()`` and ``sample_coverage()`` procedures from the variable.

.. code-block::

    library uvvm_util;
    context uvvm_util.uvvm_util_context;
    ...
    signal dut_size : natural;
    shared variable my_coverpoint : t_coverpoint;
    ...
    p_main : process
    begin
      -- Add bins to the coverpoint
      my_coverpoint.add_bins(bin(0), "bin_zero");
      my_coverpoint.add_bins(bin_range(1,254,1));
      my_coverpoint.add_bins(bin(255), "bin_max");

      -- Sample the data
      while not(my_coverpoint.coverage_completed(VOID)) loop
        dut_size <= my_coverpoint.rand;
        wait for C_CLK_PERIOD;
        my_coverpoint.sample_coverage(dut_size);
      end loop;
      
      -- Print the summary report
      my_coverpoint.print_summary(VOID);
      ...

**********************************************************************************************************************************
Concepts
**********************************************************************************************************************************
There are four main elements in the functional coverage data structure: bin, coverpoint, cross and covergroup.

* A bin associates a count with a value, a set of values or a transitions of values. The count is incremented when the coverpoint 
  or cross is sampled.
* A coverpoint represents a specification point to verify, e.g. a packet size or a memory address. It is associated with one or 
  several bins.
* A cross represents a combination of two or more coverpoints.
* A covergroup encapsulates coverpoints, crosses and coverage options.

Bins are implemented as record elements inside the protected type t_coverpoint, which represents both coverpoints and crosses. As 
for the covergroup, there is a single instance implemented as a shared variable which holds information about all the initialized 
coverpoints/crosses in the simulation.

**********************************************************************************************************************************
Creating and adding bins
**********************************************************************************************************************************
There are different ways of creating bins using the following :ref:`bin functions <bin_functions>`:

.. code-block::

    -- 1. Create a single bin using a single value
    bin(0)

    -- 2. Create a single bin using multiple values (the values are ORed)
    bin((2,4,6,8))

    -- 3. Create a single bin for each value in a given range
    bin_range(0, 5)

    -- 4. Create a number of bins from a range of values
    bin_range(1, 10, 1)  -- creates 1 bin:  1 to 10
    bin_range(1, 10, 2)  -- creates 2 bins: 1 to 5, 6 to 10

    -- 5. Create a single bin for each value in a vector's range
    bin_vector(addr)

    -- 6. Create a number of bins from a vector's range
    bin_vector(addr, 16) -- creates 16 bins

    -- 7. Create a single bin with a transition of values
    bin_transition((1,3,5,7))

With the functions above and the procedure ``add_bins()`` we can add bins to the coverpoint.

.. code-block::

    -- 1. Add a single bin using a single value
    my_coverpoint.add_bins(bin(0));

    -- 2. Add a single bin using multiple values (the values are ORed)
    my_coverpoint.add_bins(bin((2,4,6,8)));

    -- 3. Add a single bin for each value in a given range
    my_coverpoint.add_bins(bin_range(0, 5));

    -- 4. Add a number of bins from a range of values
    my_coverpoint.add_bins(bin_range(1, 10, 2));

    -- 5. Add a single bin for each value in a vector's range
    my_coverpoint.add_bins(bin_vector(addr));

    -- 6. Add a number of bins from a vector's range
    my_coverpoint.add_bins(bin_vector(addr, 16));

    -- 7. Add a single bin with a transition of values
    my_coverpoint.add_bins(bin_transition((1,3,5,7)));

The bin functions may be concatenated to add several bins at once.

.. code-block::

    my_coverpoint.add_bins(bin(0) & bin((2,4,6,8)) & bin_range(50, 100, 2));

Ignore bins
==================================================================================================================================
Specific values or transitions can be excluded from the coverage by using ignore bins. This can be useful when creating a big range 
or many bins automatically and want to discard one or several values.

.. code-block::

    my_coverpoint.add_bins(ignore_bin(255));
    my_coverpoint.add_bins(ignore_bin_range(50, 60));
    my_coverpoint.add_bins(ignore_bin_transition((0,100,200)));

Illegal bins
==================================================================================================================================
Specific values or transitions can be marked as illegal which will exclude them from the coverage and generate an alert if they are 
sampled.

.. code-block::

    my_coverpoint.add_bins(illegal_bin(256));
    my_coverpoint.add_bins(illegal_bin_range(220, 250));
    my_coverpoint.add_bins(illegal_bin_transition((200,100,0)));

**********************************************************************************************************************************
Bin name
**********************************************************************************************************************************
Bins can be named by using the optional name parameter in the ``add_bins()`` procedure. This is useful when reading the reports.

.. code-block::

    my_coverpoint.add_bins(bin(255), "bin_max");

The maximum length of the name is determined by C_FC_MAX_NAME_LENGTH defined in adaptations_pkg.

**********************************************************************************************************************************
Minimum coverage
**********************************************************************************************************************************
By default all bins created have a minimum coverage of 1, i.e. they only need to be sampled once to be covered. This parameter 
in the ``add_bins()`` procedure specifies how many times the bin must be sampled so that it is marked as covered.

.. code-block::

    my_coverpoint.add_bins(bin(0), 1);
    my_coverpoint.add_bins(bin(2), 5);
    my_coverpoint.add_bins(bin(4), 10);

**********************************************************************************************************************************
Randomization
**********************************************************************************************************************************
Using the rand_pkg, random values can be generated out of the uncovered bins to reduce simulation time. Once all the bins have been 
covered, random values will be generated among all the valid bins. Note that ignore and illegal bins will never be selected for 
randomization. However, if an illegal or ignore bin contains overlapping values with a valid bin, they might be generated as there 
is no check to avoid this.

* The randomization seeds are initialized with the unique default name of the coverpoint.
* The ``rand()`` function does not need any parameters as it is constrained by the bins.

.. code-block::

    my_addr := my_coverpoint.rand;

**********************************************************************************************************************************
Randomization weights
**********************************************************************************************************************************
This parameter in the ``add_bins()`` procedure specifies the relative number of times a bin will be selected during randomization, 
it is not applicable for ignore or illegal bins since they are never selected for randomization. Default is 1.

Note that when a bin has been covered it will no longer be selected for randomization until all the bins have been covered.

.. code-block::

    my_coverpoint.add_bins(bin(0), 1, 1); -- Selected 10% of the time
    my_coverpoint.add_bins(bin(2), 1, 3); -- Selected 30% of the time
    my_coverpoint.add_bins(bin(4), 1, 6); -- Selected 60% of the time

**********************************************************************************************************************************
Cross coverage
**********************************************************************************************************************************
Whenever we need to track combinations of values from two or more coverpoints we can use cross coverage. This can be done in two 
different ways using the ``add_cross()`` procedure and :ref:`bin functions <bin_functions>`.

Using bins
==================================================================================================================================
This is a "faster" way of doing it and useful when we need specific combinations of values. The ``add_cross`` overloads support up 
to 5 crossed elements.

.. code-block::

    my_cross.add_cross(bin(10), bin_range(0,15,1));
    my_cross.add_cross(bin(20), bin_range(16,31,1));
    my_cross.add_cross(bin(30), bin_range(32,63,1));
    my_cross.add_cross(bin((10,20,30)), illegal_bin_range(64,127));

.. code-block:: none

    # UVVM:  --------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS     MIN_HITS     COVERAGE     RAND_WEIGHT     NAME       STATUS    
    # UVVM:     (10, 20, 30)x(64 to 127)      0         N/A          N/A            N/A                   ILLEGAL    
    # UVVM:          (10)x(0 to 15)           0          1          0.00%            1                   UNCOVERED   
    # UVVM:          (20)x(16 to 31)          0          1          0.00%            1                   UNCOVERED   
    # UVVM:          (30)x(32 to 63)          0          1          0.00%            1                   UNCOVERED   
    # UVVM:  ========================================================================================================

The bin functions may also be concatenated to add several bins at once.

.. code-block::

    my_cross.add_cross(bin(10), bin_range(0,7,1) & bin_range(8,15,1));
    my_cross.add_cross(bin(20), bin_range(16,23,1) & bin_range(24,31,1));
    my_cross.add_cross(bin(30), bin_range(32,47,1) & bin_range(48,63,1));
    my_cross.add_cross(bin((10,20,30)), illegal_bin_range(64,95) & illegal_bin_range(96,127));

.. code-block:: none

    # UVVM:  --------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS     MIN_HITS     COVERAGE     RAND_WEIGHT     NAME       STATUS    
    # UVVM:      (10, 20, 30)x(64 to 95)      0         N/A          N/A            N/A                   ILLEGAL    
    # UVVM:     (10, 20, 30)x(96 to 127)      0         N/A          N/A            N/A                   ILLEGAL    
    # UVVM:           (10)x(0 to 7)           0          1          0.00%            1                   UNCOVERED   
    # UVVM:          (10)x(8 to 15)           0          1          0.00%            1                   UNCOVERED   
    # UVVM:          (20)x(16 to 23)          0          1          0.00%            1                   UNCOVERED   
    # UVVM:          (20)x(24 to 31)          0          1          0.00%            1                   UNCOVERED   
    # UVVM:          (30)x(32 to 47)          0          1          0.00%            1                   UNCOVERED   
    # UVVM:          (30)x(48 to 63)          0          1          0.00%            1                   UNCOVERED   
    # UVVM:  ========================================================================================================

Using coverpoints
==================================================================================================================================
This alternative is useful when the coverpoints are already created and we don't want to repeat the declaration of the bins. The 
``add_cross`` overloads support up to 16 crossed elements.

.. code-block::

    my_coverpoint_addr.add_bins(bin_vector(addr));
    my_coverpoint_size.add_bins(bin_range(0,127,1));
    my_cross.add_cross(my_coverpoint_addr, my_coverpoint_size);

.. code-block:: none

    # UVVM:  --------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS     MIN_HITS     COVERAGE     RAND_WEIGHT     NAME       STATUS    
    # UVVM:          (0)x(0 to 127)           0          1          0.00%            1                   UNCOVERED   
    # UVVM:          (1)x(0 to 127)           0          1          0.00%            1                   UNCOVERED   
    # UVVM:          (2)x(0 to 127)           0          1          0.00%            1                   UNCOVERED   
    # UVVM:          (3)x(0 to 127)           0          1          0.00%            1                   UNCOVERED   
    # UVVM:  ========================================================================================================

Another benefit of this alternative is that we can cross already crossed coverpoints.

.. code-block::

    my_coverpoint_addr.add_bins(bin_vector(addr));
    my_coverpoint_size.add_bins(bin_range(0,127,1));
    my_cross_addr_size.add_cross(my_coverpoint_addr, my_coverpoint_size);

    my_coverpoint_mode.add_bins(bin(1000) & bin(2000) & bin(3000));
    my_cross_addr_size_mode.add_cross(my_cross_addr_size, my_coverpoint_mode);

.. code-block:: none

    # UVVM:  --------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS     MIN_HITS     COVERAGE     RAND_WEIGHT     NAME       STATUS    
    # UVVM:       (0)x(0 to 127)x(1000)       0          1          0.00%            1                   UNCOVERED   
    # UVVM:       (0)x(0 to 127)x(2000)       0          1          0.00%            1                   UNCOVERED   
    # UVVM:       (0)x(0 to 127)x(3000)       0          1          0.00%            1                   UNCOVERED   
    # UVVM:       (1)x(0 to 127)x(1000)       0          1          0.00%            1                   UNCOVERED   
    # UVVM:       (1)x(0 to 127)x(2000)       0          1          0.00%            1                   UNCOVERED   
    # UVVM:       (1)x(0 to 127)x(3000)       0          1          0.00%            1                   UNCOVERED   
    # UVVM:       (2)x(0 to 127)x(1000)       0          1          0.00%            1                   UNCOVERED   
    # UVVM:       (2)x(0 to 127)x(2000)       0          1          0.00%            1                   UNCOVERED   
    # UVVM:       (2)x(0 to 127)x(3000)       0          1          0.00%            1                   UNCOVERED   
    # UVVM:       (3)x(0 to 127)x(1000)       0          1          0.00%            1                   UNCOVERED   
    # UVVM:       (3)x(0 to 127)x(2000)       0          1          0.00%            1                   UNCOVERED   
    # UVVM:       (3)x(0 to 127)x(3000)       0          1          0.00%            1                   UNCOVERED   
    # UVVM:  ========================================================================================================

* Note that once the number of crossed elements has been set it cannot be changed.
* Crossing of valid, ignore, illegal and transition bins is supported.

**********************************************************************************************************************************
Sampling coverage
**********************************************************************************************************************************
The procedure ``sample_coverage()`` is used to collect coverage in a coverpoint (using integer parameter) or a cross (using 
integer_vector parameter). This will increment the number of hits in the bin containing the sampled value. Once the number of hits 
in a bin has reached the minimum coverage, the bin will be marked as covered.

Overlapping bins
==================================================================================================================================
If a sampled value is contained in more than one valid bin (not ignore or illegal), all the valid bins will collect the coverage, 
i.e. increment number of hits.

In case this in unintended behaviour in the testbench, a TB_WARNING alert can be generated when overlapping valid bins are sampled 
by using the procedure ``detect_bin_overlap()``.

.. code-block::

    my_coverpoint.detect_bin_overlap(true);
    my_coverpoint.add_bins(bin_range(1, 16, 1), "valid_sizes");
    my_coverpoint.add_bins(bin_range(15, 20, 1), "big_sizes");
    my_coverpoint.sample_coverage(15);

However, if a sampled value is contained in both ignore or illegal and valid bins, the ignore/illegal bin will take precedence and 
the valid bin will be skipped.

Also, if a sampled value is contained in both ignore and illegal bins, then the illegal bin will take precedence.

**********************************************************************************************************************************
Coverage goal
**********************************************************************************************************************************
Defines a percentage of the total coverage to complete. This can be used to scale the simulation time without changing the minimum 
coverage for each bin. It must be set at the beginning of the simulation, before sampling any coverage. Default is 100.

It can be set for a single coverpoint/cross or all coverpoints/crosses in the covergroup (simulation).

.. code-block::

    -- Set the coverpoint coverage goal to 200%
    my_coverpoint.set_coverage_goal(200);

    -- Set the covergroup coverage goal to 150%
    set_sim_coverage_goal(150);

If both coverpoint and covergroup goals are set, they will be multiplied, e.g. coverage goal for my_coverpoint = 200*150/100=300.

**********************************************************************************************************************************
Coverage weight
**********************************************************************************************************************************
It specifies the weight of a coverpoint/cross for computing the total coverage of the covergroup. It must be set at the beginning 
of the simulation, before sampling any coverage. Default is 1.

.. code-block::

    my_coverpoint_1.set_coverage_weight(3);  -- If only this coverpoint is covered, total coverage will be 75%
    my_coverpoint_2.set_coverage_weight(1);  -- If only this coverpoint is covered, total coverage will be 25%

**********************************************************************************************************************************
Get coverage
**********************************************************************************************************************************
It is possible to track the current coverage in the coverpoint/cross with the function ``get_coverage()`` and also determine if the 
coverage is completed with ``coverage_completed()``.

Similar functions for the covergroup are ``get_sim_coverage()`` and ``sim_coverage_completed()``.

**********************************************************************************************************************************
Coverpoint name and scope
**********************************************************************************************************************************
A default name and scope are generated based on the index the coverpoint has in the covergroup. Both the name and scope can be 
modified by calling the ``set_name()`` and ``set_scope`` procedures respectively.

The maximum length of the name is determined by C_FC_MAX_NAME_LENGTH defined in adaptations_pkg.

**********************************************************************************************************************************
Coverage report
**********************************************************************************************************************************
A detailed report for the coverage and the bins in the coverpoint/cross can be printed using the ``print_summary()`` procedure.

* *bins coverage* = bins_covered/num_bins (this value has a maximum of 100%)
* *hits coverage* = tot_hits/tot_min_hits (this value increments gradually and has a maximum equal to the coverage goal)
* The bins are printed in the following order: illegal, ignore, uncovered, covered.

.. code-block::

    my_coverpoint.print_summary(VOID);

.. code-block:: none

    # UVVM:  =================================================================================================================
    # UVVM:  0 ns *** FUNCTIONAL COVERAGE SUMMARY: COVERPOINT_1 ***                                                           
    # UVVM:  =================================================================================================================
    # UVVM:  Coverpoint:     COVERPOINT_1
    # UVVM:  Uncovered bins: 1
    # UVVM:  Illegal bins:   1
    # UVVM:  Coverage:       bins: 75.00% hits: 66.67% (goal: 100%)
    # UVVM:  -----------------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS     MIN_HITS     COVERAGE     RAND_WEIGHT         NAME            STATUS    
    # UVVM:          ILL(80 to 100)           0         N/A          N/A            N/A         illegal_addr       ILLEGAL    
    # UVVM:              IGN(50)              0         N/A          N/A            N/A          ignore_addr        IGNORE    
    # UVVM:               (40)                0          2          0.00%            1          mem_addr_high     UNCOVERED   
    # UVVM:               (10)                1          1         100.00%           1          mem_addr_low       COVERED    
    # UVVM:               (20)                1          1         100.00%           1          mem_addr_low       COVERED    
    # UVVM:               (30)                2          2         100.00%           1          mem_addr_high      COVERED    
    # UVVM:  =================================================================================================================

A summary report for the covergroup can be printed using the ``print_sim_coverage_summary()`` procedure.

* *total hits coverage* = tot_hits_across_covpoints/tot_min_hits_across_covpoints (this value increments gradually and has a maximum equal to the coverage goal)

.. code-block::

    print_sim_coverage_summary;

.. code-block:: none

    # UVVM:  =================================================================================================================
    # UVVM:  0 ns *** FUNCTIONAL COVERAGE SUMMARY: TB seq.(uvvm) ***                                                          
    # UVVM:  Total Hits Coverage: 44.44% (goal: 100%)
    # UVVM:  =================================================================================================================
    # UVVM:  Coverpoint:      COVERPOINT_1
    # UVVM:  Uncovered bins:  1
    # UVVM:  Illegal bins:    1
    # UVVM:  Coverage:        bins: 75.00% hits: 66.67% (goal: 100%)
    # UVVM:  Coverage weight: 1
    # UVVM:  -----------------------------------------------------------------------------------------------------------------
    # UVVM:  Coverpoint:      COVERPOINT_2
    # UVVM:  Uncovered bins:  3
    # UVVM:  Illegal bins:    0
    # UVVM:  Coverage:        bins: 0.00% hits: 0.00% (goal: 100%)
    # UVVM:  Coverage weight: 1
    # UVVM:  -----------------------------------------------------------------------------------------------------------------
    # UVVM:  =================================================================================================================

**********************************************************************************************************************************
Coverage database
**********************************************************************************************************************************
In order to accumulate coverage by running several testcases we need to store the coverpoint model at the end of one testcase and 
load it at the beginning of the next. This can be done with ``write_coverage_db()`` which writes all the necessary information to 
a file and ``load_coverage_db()`` which reads it back into a new coverpoint.

**********************************************************************************************************************************
Additional info
**********************************************************************************************************************************
Log messages within the procedures and functions in the *funct_cov_pkg* use the following message IDs (disabled by default):

* ID_FUNCT_COV: Used for logging functional coverage add_bins and add_cross
* ID_FUNCT_COV_BINS:  Used for logging functional coverage add_bins and add_cross detailed information
* ID_FUNCT_COV_RAND:  Used for logging functional coverage randomization
* ID_FUNCT_COV_SAMPLE: Used for logging functional coverage sampling
* ID_FUNCT_COV_CONFIG: Used for logging functional coverage configuration

The maximum number of coverpoints that can be created is determined by C_FC_MAX_NUM_COVERPOINTS defined in adaptations_pkg.

**********************************************************************************************************************************
funct_cov_pkg
**********************************************************************************************************************************
.. toctree::
   :maxdepth: 1

   funct_cov_pkg_methods.rst
   funct_cov_pkg_t_coverpoint.rst
