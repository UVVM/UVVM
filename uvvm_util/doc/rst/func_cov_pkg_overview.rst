##################################################################################################################################
Functional Coverage
##################################################################################################################################
All the functionality for coverage can be found in *uvvm_util/src/func_cov_pkg.vhd*.

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
        dut_size <= my_coverpoint.rand(VOID);
        wait for C_CLK_PERIOD;
        my_coverpoint.sample_coverage(dut_size);
      end loop;
      
      -- Print the coverage report
      my_coverpoint.report_coverage(VOID);
      ...

.. note::

    The syntax for all methods is given in :ref:`func_cov_pkg`.

**********************************************************************************************************************************
Concepts
**********************************************************************************************************************************
There are three main elements in the functional coverage data structure: bin, coverpoint and cross.

* A bin associates a count with a value, a set of values or a transitions of values. The count is incremented when the coverpoint 
  or cross is sampled.
* A coverpoint represents a specification point to verify, e.g. a packet size or a memory address. It is associated with one or 
  several bins.
* A cross represents a combination of two or more coverpoints.

Bins are implemented as record elements inside the protected type t_coverpoint, which represents both coverpoints and crosses.

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
    bin_range(0, 5)      -- creates 6 bins: 0,1,2,3,4,5

    -- 4. Create a number of bins from a range of values
    bin_range(1, 10, 1)  -- creates 1 bin:  1 to 10
    bin_range(1, 10, 2)  -- creates 2 bins: 1 to 5, 6 to 10

    -- 5. Create a single bin for each value in a vector's range
    bin_vector(addr)     -- creates 2^(addr'length) bins

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

.. note::

    The maximum number of bins which can be added at once using a single ``add_bins()`` call is limited by C_FC_MAX_NUM_NEW_BINS 
    defined in adaptations_pkg.

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
sampled. The default severity of the alert is ERROR and can be configured using the ``set_illegal_bin_alert_level()`` procedure.

.. code-block::

    my_coverpoint.set_illegal_bin_alert_level(WARNING);
    my_coverpoint.add_bins(illegal_bin(256));
    my_coverpoint.add_bins(illegal_bin_range(220, 250));
    my_coverpoint.add_bins(illegal_bin_transition((200,100,0)));

Adding bins from separate process
==================================================================================================================================
In some cases there is one process that creates the coverpoint model and another process that samples the data, e.g. a sequencer 
adds the bins to the coverpoint and a VVC samples the data from the DUT. If for some reason the VVC receives some data and samples 
it before the sequencer has added the bins, the testbench will generate a TB_ERROR alert. In cases like this we can use the function 
``is_defined()`` to check if the coverpoint has any bins before sampling the data.

.. code-block::

    -- Process 1 (Sequencer)
    ...
    my_coverpoint.add_bins(bin_range(0,255,1));
    my_coverpoint.add_bins(illegal_bin(256));
    ...

    -- Process 2 (VVC)
    ...
    while not(my_coverpoint.is_defined(VOID)) loop
      wait for C_CLK_PERIOD;
    end loop;
    my_coverpoint.sample_coverage(read_addr);
    ...

Bin memory allocation
==================================================================================================================================
For users who want more control over the memory usage during simulation, it is possible to configure how large the bin list is and 
how much the size increments when the list becomes full, by using the constants C_FC_DEFAULT_INITIAL_NUM_BINS_ALLOCATED and 
C_FC_DEFAULT_NUM_BINS_ALLOCATED_INCREMENT defined in adaptations_pkg.

Moreover, the procedures ``set_num_allocated_bins()`` and ``set_num_allocated_bins_increment()`` can be used to reconfigure a 
coverpoint's respective values.

**********************************************************************************************************************************
Bin name
**********************************************************************************************************************************
Bins can be named by using the optional parameter *bin_name* in the ``add_bins()`` procedure. If no name is given to the bin, a 
default name will be automatically given. This is useful when reading the reports.

.. code-block::

    add_bins(bin, [bin_name])

    my_coverpoint.add_bins(bin(255), "bin_max");

The maximum length of the name is determined by C_FC_MAX_NAME_LENGTH defined in adaptations_pkg.

**********************************************************************************************************************************
Minimum coverage
**********************************************************************************************************************************
By default all bins created have a minimum coverage of 1, i.e. they only need to be sampled once to be covered. The parameter 
*min_hits* in the ``add_bins()`` procedure specifies how many times the bin must be sampled so that it is marked as covered.

.. code-block::

    add_bins(bin, min_hits, [bin_name])

    my_coverpoint.add_bins(bin(0), 1);
    my_coverpoint.add_bins(bin(2), 5);
    my_coverpoint.add_bins(bin(4), 10);

.. _optimized_randomization:

**********************************************************************************************************************************
Optimized Randomization
**********************************************************************************************************************************
Using General Randomization can be a little inefficient when trying to randomize several sets of values, especially with large 
and small ranges. Since the values in the large ranges will be generated more times than the ones in the small ranges in a Uniform 
distribution, this will cause the simulation to run longer in order to cover all the valid bins.

By using Optimized Randomization, the random values can be generated by using only the uncovered bins, thus reducing simulation 
time. Once all the bins have been covered, random values are generated again using all the valid bins.

* The randomization seeds are initialized with the unique default name of the coverpoint.
* The ``rand()`` function does not need any parameters as it is constrained by the bins.

.. code-block::

    my_addr := my_coverpoint.rand(VOID);

.. caution::
    Ignore and illegal bins will never be selected for randomization. However, if an illegal or ignore bin contains overlapping 
    values with a valid bin, they might be generated as there is no check to avoid this.

**********************************************************************************************************************************
Randomization weights
**********************************************************************************************************************************
The parameter *rand_weight* in the ``add_bins()`` procedure specifies the relative number of times a bin will be selected during 
randomization. It is not applicable for ignore or illegal bins since they are never selected for randomization.

Note that when a bin has been covered it will no longer be selected for randomization until all the bins have been covered.

.. code-block::

    add_bins(bin, min_hits, rand_weight, [bin_name])

    my_coverpoint.add_bins(bin(0), 1, 1); -- Selected 10% of the time
    my_coverpoint.add_bins(bin(2), 1, 3); -- Selected 30% of the time
    my_coverpoint.add_bins(bin(4), 1, 6); -- Selected 60% of the time

If a randomization weight is not specified, the bin will have a default weight equal to the minimum coverage. Moreover, this weight 
will be reduced by 1 every time the bin is sampled, thus balancing the randomization of the bins in an "adaptive" way. When all the 
bins have been covered, their respective randomization weights will be reset to their default value equal to the minimum coverage.

.. code-block::

    my_coverpoint.add_bins(bin(0), 10); -- Selected 50% of the time (rand_weight = 10)
    my_coverpoint.add_bins(bin(2), 5);  -- Selected 25% of the time (rand_weight = 5)
    my_coverpoint.add_bins(bin(4), 5);  -- Selected 25% of the time (rand_weight = 5)
    my_coverpoint.sample_coverage(0);   -- bin(0) Selected 47% of the time (rand_weight = 9)
    my_coverpoint.sample_coverage(0);   -- bin(0) Selected 44% of the time (rand_weight = 8)
    my_coverpoint.sample_coverage(0);   -- bin(0) Selected 41% of the time (rand_weight = 7)

**********************************************************************************************************************************
Cross coverage
**********************************************************************************************************************************
Whenever we need to track combinations of values from two or more coverpoints we can use cross coverage. This can be done in two 
different ways using the ``add_cross()`` procedure and :ref:`bin functions <bin_functions>`.

Using bins
==================================================================================================================================
This is a "faster" way of doing it and useful when we need specific combinations of values. The ``add_cross()`` overloads support 
up to 5 crossed elements.

.. code-block::

    add_cross(bin1, bin2, [bin_name])

    my_cross.add_cross(bin(10), bin_range(0,15,1));
    my_cross.add_cross(bin(20), bin_range(16,31,1));
    my_cross.add_cross(bin(30), bin_range(32,63,1));
    my_cross.add_cross(bin((10,20,30)), illegal_bin_range(64,127), "illegal_bin");

.. code-block:: none

    # UVVM:  --------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS      MIN_HITS      COVERAGE        NAME           STATUS    
    # UVVM:     (10, 20, 30)x(64 to 127)      0          N/A           N/A        illegal_bin      ILLEGAL    
    # UVVM:          (10)x(0 to 15)           0           1           0.00%          bin_0        UNCOVERED   
    # UVVM:          (20)x(16 to 31)          0           1           0.00%          bin_1        UNCOVERED   
    # UVVM:          (30)x(32 to 63)          0           1           0.00%          bin_2        UNCOVERED   
    # UVVM:  ========================================================================================================

The bin functions may also be concatenated to add several bins at once.

.. code-block::

    my_cross.add_cross(bin(10), bin_range(0,7,1) & bin_range(8,15,1));
    my_cross.add_cross(bin(20), bin_range(16,23,1) & bin_range(24,31,1));
    my_cross.add_cross(bin(30), bin_range(32,47,1) & bin_range(48,63,1));
    my_cross.add_cross(bin((10,20,30)), illegal_bin_range(64,95) & illegal_bin_range(96,127));

.. code-block:: none

    # UVVM:  --------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS      MIN_HITS      COVERAGE        NAME           STATUS    
    # UVVM:      (10, 20, 30)x(64 to 95)      0          N/A           N/A           bin_6         ILLEGAL    
    # UVVM:     (10, 20, 30)x(96 to 127)      0          N/A           N/A           bin_7         ILLEGAL    
    # UVVM:           (10)x(0 to 7)           0           1           0.00%          bin_0        UNCOVERED   
    # UVVM:          (10)x(8 to 15)           0           1           0.00%          bin_1        UNCOVERED   
    # UVVM:          (20)x(16 to 23)          0           1           0.00%          bin_2        UNCOVERED   
    # UVVM:          (20)x(24 to 31)          0           1           0.00%          bin_3        UNCOVERED   
    # UVVM:          (30)x(32 to 47)          0           1           0.00%          bin_4        UNCOVERED   
    # UVVM:          (30)x(48 to 63)          0           1           0.00%          bin_5        UNCOVERED   
    # UVVM:  ========================================================================================================

Using coverpoints
==================================================================================================================================
This alternative is useful when the coverpoints are already created and we don't want to repeat the declaration of the bins. The 
``add_cross()`` overloads support up to 16 crossed elements.

.. code-block::

    my_coverpoint_addr.add_bins(bin_vector(addr));
    my_coverpoint_size.add_bins(bin_range(0,127,1));
    my_cross.add_cross(my_coverpoint_addr, my_coverpoint_size);

.. code-block:: none

    # UVVM:  --------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS      MIN_HITS      COVERAGE        NAME           STATUS    
    # UVVM:          (0)x(0 to 127)           0           1           0.00%          bin_0        UNCOVERED   
    # UVVM:          (1)x(0 to 127)           0           1           0.00%          bin_1        UNCOVERED   
    # UVVM:          (2)x(0 to 127)           0           1           0.00%          bin_2        UNCOVERED   
    # UVVM:          (3)x(0 to 127)           0           1           0.00%          bin_3        UNCOVERED   
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
    # UVVM:               BINS               HITS      MIN_HITS      COVERAGE        NAME           STATUS    
    # UVVM:       (0)x(0 to 127)x(1000)       0           1           0.00%          bin_0        UNCOVERED   
    # UVVM:       (0)x(0 to 127)x(2000)       0           1           0.00%          bin_1        UNCOVERED   
    # UVVM:       (0)x(0 to 127)x(3000)       0           1           0.00%          bin_2        UNCOVERED   
    # UVVM:       (1)x(0 to 127)x(1000)       0           1           0.00%          bin_3        UNCOVERED   
    # UVVM:       (1)x(0 to 127)x(2000)       0           1           0.00%          bin_4        UNCOVERED   
    # UVVM:       (1)x(0 to 127)x(3000)       0           1           0.00%          bin_5        UNCOVERED   
    # UVVM:       (2)x(0 to 127)x(1000)       0           1           0.00%          bin_6        UNCOVERED   
    # UVVM:       (2)x(0 to 127)x(2000)       0           1           0.00%          bin_7        UNCOVERED   
    # UVVM:       (2)x(0 to 127)x(3000)       0           1           0.00%          bin_8        UNCOVERED   
    # UVVM:       (3)x(0 to 127)x(1000)       0           1           0.00%          bin_9        UNCOVERED   
    # UVVM:       (3)x(0 to 127)x(2000)       0           1           0.00%         bin_10        UNCOVERED   
    # UVVM:       (3)x(0 to 127)x(3000)       0           1           0.00%         bin_11        UNCOVERED   
    # UVVM:  ========================================================================================================

* Every type of bin (single value, multiple values, range, transition, ignore & illegal) can be crossed with each other.
* When crossing several transition bins, they must have the same number of transitions, e.g. ::

    my_cross.add_cross(bin_transition(0,7,15), bin_transition(64,128,256));
    my_cross.add_cross(bin_transition(0,7,15,32), bin_transition(64,128,256,512), bin(16384));

.. important::
    Once the number of crossed bins has been set in a coverpoint, by calling the first ``add_cross()``, it cannot be 
    changed anymore.

**********************************************************************************************************************************
Sampling coverage
**********************************************************************************************************************************
The procedure ``sample_coverage()`` is used to collect coverage in a coverpoint (using integer parameter) or a cross (using 
integer_vector parameter). This will increment the number of hits in the bin containing the sampled value. Once the number of hits 
in a bin has reached the minimum coverage, the bin will be marked as covered.

Overlapping bins
==================================================================================================================================
If a sampled value is contained in more than one valid bin (not ignore or illegal), all the valid bins will collect the coverage, 
i.e. increment the number of hits.

In case this in unintended behaviour in the testbench, an alert can be generated when overlapping valid bins are sampled by using 
the procedure ``set_bin_overlap_alert_level()`` to select the severity of the alert.

.. code-block::

    my_coverpoint.set_bin_overlap_alert_level(TB_WARNING);
    my_coverpoint.add_bins(bin_range(1, 16, 1), "valid_sizes");
    my_coverpoint.add_bins(bin_range(15, 20, 1), "big_sizes");
    my_coverpoint.sample_coverage(15);

However, if a sampled value is contained in both ignore or illegal and valid bins, the ignore/illegal bin will take precedence and 
the valid bin will be skipped.

Also, if a sampled value is contained in both ignore and illegal bins, then the illegal bin will take precedence.

.. _func_cov_pkg_coverage_status:

**********************************************************************************************************************************
Coverage status
**********************************************************************************************************************************
It is possible to track the current coverage in the coverpoint/cross with the function ``get_coverage()``, which returns a real  
number representing the percentage value. There are 2 coverage interpretations:

* **Bins Coverage**: represents the percentage of the number of bins which are covered *(covered_bins/total_bins)*
* **Hits Coverage**: represents the percentage of the number of hits in relation to the number of min_hits for all the bins in the 
  coverpoint *(bin1_hits/bin1_min_hits + bin2_hits/bin2_min_hits + ...)*

It is also possible to check if the bins and/or hits coverage is completed using the function ``coverage_completed()``. Normally, 
both the bins and the hits coverage are completed at the same time, except when they have a different coverage goal (explained in 
the next section).

.. code-block::

    log(ID_SEQUENCER, "Bins Coverage: " & to_string(my_coverpoint.get_coverage(BINS),2) & "%");
    log(ID_SEQUENCER, "Hits Coverage: " & to_string(my_coverpoint.get_coverage(HITS),2) & "%");

    -- Do something while the coverpoint's coverage is incomplete
    while not(my_coverpoint.coverage_completed(BINS_AND_HITS)) loop
    ...
    end loop;

TODO: rewrite rest of section

Similar functions for the overall status are ``fc_get_overall_coverage()`` and ``fc_overall_coverage_completed()``.

.. code-block::

    log(ID_SEQUENCER, "Overall Coverage: " & to_string(fc_get_overall_coverage(VOID),2) & "%");

    -- Do something while the overall coverage is incomplete
    while not(fc_overall_coverage_completed(VOID)) loop
    ...
    end loop;

**********************************************************************************************************************************
Coverage goal
**********************************************************************************************************************************
Defines a percentage of the total coverage to complete. This can be used to scale the simulation time without changing the minimum 
coverage for each bin. It must be set at the beginning of the testbench, before sampling any coverage. There are 2 types:

Bins coverage goal
==================================================================================================================================
This value defines the percentage of the number of bins which need to be covered and therefore the range is between 1 and 100. 
Default is 100.

.. code-block::

    -- Cover only 75% of the total number of bins
    my_coverpoint.set_bins_coverage_goal(75);

    -- Cover only 10% of the total number of bins
    my_coverpoint.set_bins_coverage_goal(10);

Hits coverage goal
==================================================================================================================================
This value defines the percentage of the min_hits which need to be covered for each bin in the coverpoint. Default is 100.

.. code-block::

    -- Cover only half the min_hits
    my_coverpoint.set_hits_coverage_goal(50);

    -- Cover twice the min_hits
    my_coverpoint.set_hits_coverage_goal(200);

TODO: rewrite rest of section

It can be set for a single coverpoint/cross or all the coverpoints/crosses in the testbench.

.. code-block::

    -- Set the overall coverage goal to 150%
    fc_set_overall_coverage_goal(150);

If both coverpoint and overall goals are set, they will be multiplied for that given coverpoint, e.g. coverage goal for 
my_coverpoint = 200*150/100=300.

**********************************************************************************************************************************
Coverage weight
**********************************************************************************************************************************
It specifies the weight of a coverpoint/cross used when calculating the overall coverage. It must be set at the beginning of the 
testbench, before sampling any coverage. Default is 1.

.. code-block::

    my_coverpoint_1.set_coverage_weight(3);  -- If only this coverpoint is covered, total coverage will be 75%
    my_coverpoint_2.set_coverage_weight(1);  -- If only this coverpoint is covered, total coverage will be 25%

**********************************************************************************************************************************
Coverpoint name
**********************************************************************************************************************************
A default name is automatically given to the coverpoint when it is configured or bins are added. The name can be modified by calling 
the ``set_name()`` procedure.

The maximum length of the name is determined by C_FC_MAX_NAME_LENGTH defined in adaptations_pkg.

.. _func_cov_pkg_coverage_report:

**********************************************************************************************************************************
Coverage report
**********************************************************************************************************************************
A detailed report for the coverage and the bins in the coverpoint/cross can be printed using the ``report_coverage()`` procedure.
By using the parameter verbosity, different types of bins can be printed out.

* *bins coverage* = bins_covered/num_bins (this value has a maximum of 100%)
* *hits coverage* = tot_hits/tot_min_hits (this value increments gradually and has a maximum equal to the coverage goal)

.. note::

    When the bin values don't fit under the BINS column, the bin name is printed instead and the values are printed at the bottom 
    of the report.

.. code-block::

    my_coverpoint.report_coverage(VERBOSE); -- Prints illegal, ignore and valid bins

.. code-block:: none

    # UVVM:  =================================================================================================================
    # UVVM:  0 ns *** COVERAGE SUMMARY REPORT (VERBOSE): TB seq. ***                                                          
    # UVVM:  =================================================================================================================
    # UVVM:  Coverpoint:     Covpt_1
    # UVVM:  Uncovered bins: 1
    # UVVM:  Illegal bins:   3
    # UVVM:  Coverage:       bins: 80.00% hits: 77.78% (goal: 100%)
    # UVVM:  -----------------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS      MIN_HITS      COVERAGE             NAME               STATUS           
    # UVVM:              (3000)               1          N/A           N/A            illegal_addr          ILLEGAL           
    # UVVM:           (256 to 511)            0          N/A           N/A            illegal_addr          ILLEGAL           
    # UVVM:        illegal_transition         0          N/A           N/A         illegal_transition       ILLEGAL           
    # UVVM:               (255)               0          N/A           N/A             ignore_addr           IGNORE           
    # UVVM:         ignore_transition         0          N/A           N/A          ignore_transition        IGNORE           
    # UVVM:           (0->1->2->3)            0           2           0.00%           transition_1         UNCOVERED          
    # UVVM:             (0 to 15)             6           2          100.00%          mem_addr_low          COVERED           
    # UVVM:               (127)               3           1          100.00%          mem_addr_mid          COVERED           
    # UVVM:           (248 to 254)            14          2          100.00%          mem_addr_high         COVERED           
    # UVVM:           transition_2            2           2          100.00%          transition_2          COVERED           
    # UVVM:  -----------------------------------------------------------------------------------------------------------------
    # UVVM:  illegal_transition: (2000->15->127->248->249->250->251->252->253->254)
    # UVVM:  ignore_transition: (1000->15->127->248->249->250->251->252->253->254)
    # UVVM:  transition_2: (0->15->127->248->249->250->251->252->253->254)
    # UVVM:  =================================================================================================================

.. code-block::

    my_coverpoint.report_coverage(VOID); -- Same as NON_VERBOSE. Prints illegal (when hits > 0) and valid bins

.. code-block:: none

    # UVVM:  =================================================================================================================
    # UVVM:  0 ns *** COVERAGE SUMMARY REPORT (NON_VERBOSE): TB seq. ***                                                      
    # UVVM:  =================================================================================================================
    # UVVM:  Coverpoint:     Covpt_1
    # UVVM:  Uncovered bins: 1
    # UVVM:  Illegal bins:   3
    # UVVM:  Coverage:       bins: 80.00% hits: 77.78% (goal: 100%)
    # UVVM:  -----------------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS      MIN_HITS      COVERAGE             NAME               STATUS           
    # UVVM:              (3000)               1          N/A           N/A            illegal_addr          ILLEGAL           
    # UVVM:           (0->1->2->3)            0           2           0.00%           transition_1         UNCOVERED          
    # UVVM:             (0 to 15)             6           2          100.00%          mem_addr_low          COVERED           
    # UVVM:               (127)               3           1          100.00%          mem_addr_mid          COVERED           
    # UVVM:           (248 to 254)            14          2          100.00%          mem_addr_high         COVERED           
    # UVVM:           transition_2            2           2          100.00%          transition_2          COVERED           
    # UVVM:  -----------------------------------------------------------------------------------------------------------------
    # UVVM:  transition_2: (0->15->127->248->249->250->251->252->253->254)
    # UVVM:  =================================================================================================================

.. code-block::

    my_coverpoint.report_coverage(HOLES_ONLY); -- Prints only the uncovered bins

.. code-block:: none

    # UVVM:  =================================================================================================================
    # UVVM:  0 ns *** COVERAGE HOLES REPORT: TB seq. ***                                                          
    # UVVM:  =================================================================================================================
    # UVVM:  Coverpoint:     Covpt_1
    # UVVM:  Uncovered bins: 1
    # UVVM:  Illegal bins:   3
    # UVVM:  Coverage:       bins: 80.00% hits: 77.78% (goal: 100%)
    # UVVM:  -----------------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS      MIN_HITS      COVERAGE             NAME               STATUS           
    # UVVM:           (0->1->2->3)            0           2           0.00%           transition_1         UNCOVERED          
    # UVVM:  -----------------------------------------------------------------------------------------------------------------
    # UVVM:  =================================================================================================================

A summary report for all the coverpoints in the testbench can be printed using the ``fc_report_overall_coverage()`` procedure. 
Only the main information is contained in the report, i.e. bins are not included.

* *total hits coverage* = tot_hits_across_covpoints/tot_min_hits_across_covpoints (this value increments gradually and has a maximum 
  equal to the coverage goal)

.. code-block::

    fc_report_overall_coverage(VOID);

.. code-block:: none

    # UVVM:  =================================================================================================================
    # UVVM:  0 ns *** OVERALL COVERAGE REPORT: TB seq. ***                                                          
    # UVVM:  Total Hits Coverage: 44.44% (goal: 100%)
    # UVVM:  =================================================================================================================
    # UVVM:  Coverpoint:      Covpt_1
    # UVVM:  Uncovered bins:  1
    # UVVM:  Illegal bins:    1
    # UVVM:  Coverage:        bins: 75.00% hits: 66.67% (goal: 100%)
    # UVVM:  Coverage weight: 1
    # UVVM:  -----------------------------------------------------------------------------------------------------------------
    # UVVM:  Coverpoint:      Covpt_2
    # UVVM:  Uncovered bins:  3
    # UVVM:  Illegal bins:    0
    # UVVM:  Coverage:        bins: 0.00% hits: 0.00% (goal: 100%)
    # UVVM:  Coverage weight: 1
    # UVVM:  -----------------------------------------------------------------------------------------------------------------
    # UVVM:  =================================================================================================================

.. _func_cov_pkg_config_report:

**********************************************************************************************************************************
Configuration report
**********************************************************************************************************************************
A report containing all the configuration parameters can be printed using the ``report_config()`` procedure.

.. code-block::

    my_coverpoint.report_config(VOID);

.. code-block:: none

    # UVVM:  =================================================================================================================
    # UVVM:  ***  REPORT OF COVERPOINT CONFIGURATION ***
    # UVVM:  =================================================================================================================
    # UVVM:            NAME                    :                        Covpt_1
    # UVVM:            SCOPE                   :                        TB seq.
    # UVVM:            ILLEGAL BIN ALERT LEVEL :                        WARNING
    # UVVM:            DETECT BIN OVERLAP      :                          false
    # UVVM:            COVERAGE WEIGHT         :                              1
    # UVVM:            COVERAGE GOAL           :                            100
    # UVVM:            OVERALL GOAL            :                            100
    # UVVM:            NUMBER OF BINS          :                             36
    # UVVM:            CROSS DIMENSIONS        :                              2
    # UVVM:  =================================================================================================================

**********************************************************************************************************************************
Coverage database
**********************************************************************************************************************************
In order to accumulate coverage by running several testcases we need to store the coverpoint model at the end of one testcase and 
load it at the beginning of the next. This can be done with ``write_coverage_db()`` which writes all the necessary information to 
a file and ``load_coverage_db()`` which reads it back into a new coverpoint. Note that this must be done for every coverpoint in 
the testbench and they must be written to separate files.

*Example 1: The testcases are in different files and are run in a specified order.*

#. TC_1 adds bins to a coverpoint, samples coverage and writes the database to "coverpoint_1.txt".
#. TC_2 loads the database from "coverpoint_1.txt", samples coverage and writes the updated database to "coverpoint_1.txt", which 
   overwrites the content of the file.
#. TC_3 does the same as TC_2.

.. note::

    * Loading a database into a coverpoint will overwrite all its information, therefore it is suggested to always load before 
      sampling coverage or adding any extra bins.
    * If a database is loaded into a coverpoint which is already initialized, a TB_WARNING will be generated.

*Example 2: There is a single testcase file which is run using different generics in a specified order.*

* Same as Example 1, but using the generics to identify the first TC and avoid loading the database.

.. note::

    If a file is not found when trying to load, a TB_WARNING will be generated.

*Example 3: The testcases are run in parallel.*

#. Each TC adds bins to a coverpoint, samples coverage and writes the database to a different file.
#. After all simulations are done, use a script to merge the database files.

.. note::

    The downside of this approach is that the accumulated coverage will not be visible in simulation.

Clearing coverage
==================================================================================================================================
A coverpoint's coverage status can be reset with ``clear_coverage()``. This might be useful for example when running several 
testcases in a single testbench and the coverage needs to be restarted after each testcase or when loading a coverpoint model 
and only want to keep the bin structure.

**********************************************************************************************************************************
Clearing a coverpoint
**********************************************************************************************************************************
A coverpoint's complete configuration and content (bins, coverage, etc.) can be reset with ``clear_coverpoint()``.

**********************************************************************************************************************************
Additional info
**********************************************************************************************************************************
Log messages within the procedures and functions in the *func_cov_pkg* use the following message IDs (disabled by default):

* ID_FUNC_COV: Used for logging functional coverage ``add_bins()`` and ``add_cross()`` methods. Note that each bin function within 
  the ``add_bins()`` and ``add_cross()`` log has a string length limited by C_FC_MAX_PROC_CALL_LENGTH defined in adaptations_pkg.
* ID_FUNC_COV_BINS:  Used for logging functional coverage ``add_bins()`` and ``add_cross()`` methods detailed information.
* ID_FUNC_COV_RAND:  Used for logging functional coverage "optimized randomization" values returned by rand().
* ID_FUNC_COV_SAMPLE: Used for logging functional coverage sampling.
* ID_FUNC_COV_CONFIG: Used for logging functional coverage configuration changes.

The default scope for log messages in the *func_cov_pkg* is C_TB_SCOPE_DEFAULT and it can be updated using the procedure 
``set_scope()``. The maximum length of the scope is defined by C_LOG_SCOPE_WIDTH. Both of these constants are defined in adaptations_pkg.

The maximum number of coverpoints that can be created is determined by C_FC_MAX_NUM_COVERPOINTS defined in adaptations_pkg.

.. _func_cov_pkg:

**********************************************************************************************************************************
func_cov_pkg
**********************************************************************************************************************************
The following links contain information regarding the API of the protected type *t_coverpoint*, the API for the general methods and 
all the type definitions inside *func_cov_pkg*.

.. toctree::
   :maxdepth: 1

   func_cov_pkg_t_coverpoint.rst
   func_cov_pkg_methods.rst
   func_cov_pkg_types.rst
