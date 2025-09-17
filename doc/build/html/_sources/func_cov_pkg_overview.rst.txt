.. _func_cov_pkg_overview:

##################################################################################################################################
Functional Coverage
##################################################################################################################################

**The Functional Coverage API is found in** :ref:`func_cov_pkg`.
All the functionality for coverage can be found in *uvvm_util/src/func_cov_pkg.vhd*.

**********************************************************************************************************************************
Introduction
**********************************************************************************************************************************
Functional Coverage is a method used to measure how thoroughly a design has been tested. The Functional Coverage tool can be configured
to monitor inputs, outputs or internal registers within the design, logging the values that occur. For example, it can track
package sizes and data fields sent over a communication interface, fill grades experienced by a FIFO, or configurations written
to an internal register during simulation.

Functional Coverage works very well in combination with randomized generation of input stimuli, where the testbench can
for instance be set up to keep generating randomized stimuli until the we have covered both all of the specified corner cases
and tested a defined amount of general random input values. The combination of Functional Coverage and randomization forms the basis
of UVVMs :ref:`optimized_randomization` functionality.

After tests have been run, the Functional Coverage package can generate reports documenting which scenarios have
been tested. This makes Functional Coverage a particularly useful tool for projects with stringent demands for documentation of 
compliance with requirements.

Coverpoints and bins
=================================================================================================================================
Each point of the design that we wish to test is referred to as a *coverpoint*. A coverpoint can for instance be an input port, 
output port or an internal register.

A coverpoint is added by creating a shared variable of the protected type t_coverpoint.

.. code-block::

    shared variable my_coverpoint : t_coverpoint;


Once a coverpoint for a particular part of the design has been defined, we need to set up containers to track which values have 
occurred on that coverpoint. These containers are called *bins*. Each bin will count the occurrences of either a specific value, 
a range of values or a given transition between values.

Bins are generated using the ``bin()`` function and added to the coverpoint using the ``add_bins()`` procedure. See the section 
`Creating and adding bins`_  for more information about how to generate bins.



In Figure 1, we can see a coverpoint named *memory_address* which contains six different bins: four bins with a single value each, 
one bin with a range of values and one bin with a transition of values. Each of the bins has a different counter value reflecting 
how many times the coverpoint has been sampled with the corresponding values of the bins.

.. figure:: images/functional_coverage/func_cov_coverpoint.png
   :alt: Coverpoint representation
   :width: 400pt
   :align: center

   Figure 1


Sometimes we want to monitor the values of multiple points of our design at the same time. In this case, we can create a coverpoint 
containing a *cross*. A cross is a type of container that can hold a combination of multiple bins or coverpoints, where every 
combination of the values covered by the crossed bins or coverpoints must have been sampled during testing for the cross to be covered. 


In Figure 2, we can see a cross named *src_addr_x_dst_addr* which contains eight different bins. Each bin contains different 
combinations of values for *src_addr* and *dst_addr*.

.. figure:: images/functional_coverage/func_cov_cross.png
   :alt: Cross representation
   :width: 400pt
   :align: center

   Figure 2


Once we have defined all our coverpoints with bins or crosses for the required scenarios, we can begin running tests on our 
design and tick off the tested coverpoint values. This is done by sampling all observed coverpoint values using the 
:ref:`sample_coverage` procedure.

Figure 3 illustrates an example scenario where we have created a coverpoint with three bins for the DUT input named "input1". 
Each value received through the input is sampled using the ``sample_coverage()`` procedure. In this example the input receives 
the value 255. This will increment the hit counter of the bin associated with that value by one. Since this bin has a 
min_hits requirement of 1, the hit coverage of the bin will reach 100% after a single hit. Once all the bins reach 100%
hit coverage, the coverpoint will have full coverage. 

.. figure:: images/functional_coverage/func_cov_sampling.png
   :alt: Sampling coverage
   :width: 400pt
   :align: center

   Figure 3


.. note::

    The bin values are represented as integer numbers. In order to use functional coverage for other types of values, such as 
    unsigned, enumerated, etc., they must be converted to integer values first.

.. code-block::

    -- Example 1
    my_coverpoint.add_bins(bin(t_state'pos(IDLE)));
    my_coverpoint.add_bins(bin(t_state'pos(RUNNING)));
    my_coverpoint.sample_coverage(t_state'pos(fsm_state));
    rand_state_int := my_coverpoint.rand(NO_SAMPLE_COV);
    rand_state     <= t_state'val(rand_state_int);

    -- Example 2
    my_coverpoint.add_bins(bin(to_integer(unsigned'(x"00"))));
    my_coverpoint.add_bins(bin(to_integer(unsigned'(x"FF"))));
    my_coverpoint.sample_coverage(to_integer(address));
    rand_addr_int := my_coverpoint.rand(NO_SAMPLE_COV);
    rand_addr     <= to_unsigned(rand_addr_int,rand_addr'length);

**********************************************************************************************************************************
Getting started
**********************************************************************************************************************************
All the functionality for coverage can be found in *uvvm_util/src/func_cov_pkg.vhd*.

To start using functional coverage it is necessary to import the utility library, create one or more shared variables with the protected 
type *t_coverpoint* and call the ``add_bins()`` and ``sample_coverage()`` procedures from the variable.

.. code-block::

    library uvvm_util;
    context uvvm_util.uvvm_util_context;
    ...
    signal bus_addr : natural;
    shared variable my_coverpoint : t_coverpoint;
    ...
    p_main : process
    begin
      -- Add bins to the coverpoint. (Default number of hits required is one per bin).
      my_coverpoint.add_bins(bin(0), "bin_zero");
      my_coverpoint.add_bins(bin_range(1,254)); -- Any value in the range 1 to 254 will increment the hit count by one
      my_coverpoint.add_bins(bin(255), "bin_max");

      -- Sample the data
      -- Loop will terminate when each of the bins above has been hit at least once
      while not(my_coverpoint.coverage_completed(BINS_AND_HITS)) loop
        bus_addr <= my_coverpoint.rand(SAMPLE_COV); -- Generates an integer from an uncovered bin and samples the integer
        configure_addr(bus_addr);
        wait for C_CLK_PERIOD;
      end loop;

      -- Print the coverage report
      my_coverpoint.report_coverage(VOID);
      ...

.. note::

    The syntax for all methods is given in :ref:`func_cov_pkg`.

**********************************************************************************************************************************
Creating and adding bins
**********************************************************************************************************************************
Bins are generated using one of the bin generation functions defined in the functional coverage package, and added to a coverpoint 
using the ``add_bins()`` procedure.
This is necessary for several reasons: better readability, avoiding conflicts with overloads which have similar parameters and 
supporting adding multiple types of bins in a single line.

By calling the ``add_bins()`` procedure with the ``bin()`` function as parameter, we can generate and add a bin in a single operation. 

The following code adds a bin for the value 1 to the coverpoint named *my_coverpoint*.

.. code-block::

    my_coverpoint.add_bins(bin(1));

Bins are implemented as record elements inside the protected type t_coverpoint, which represents both coverpoints and crosses.


Bins can be created using the following :ref:`bin functions <bin_functions>`:

.. code-block::

    -- 1. Create a single bin for a single value
    bin(0)

    -- 2. Create a single bin for multiple values (sample any of the values to increase the bin counter)
    bin((2,4,6,8))             -- Note the use of double parentheses due to the integer_vector parameter

    -- 3. Create a single bin for a range of values
    bin_range(0, 5)

    -- 4. Create a number of bins from a range of values
    bin_range(1, 8, 2)         -- creates 2 bins: 1 to 4, 5 to 8
    bin_range(1, 8, 3)         -- creates 3 bins: 1 to 2, 3 to 5, 6 to 8
    bin_range(1, 8, 0)         -- creates 8 bins: 1,2,3,4,5,6,7,8
    bin_range(1, 8, 8)         -- creates 8 bins: 1,2,3,4,5,6,7,8
    bin_range(1, 8, 20)        -- creates 8 bins: 1,2,3,4,5,6,7,8

    -- 5. Create a single bin for a vector's range
    bin_vector(addr)

    -- 6. Create a number of bins from a vector's range
    bin_vector(addr, 4)        -- creates 4 bins
    bin_vector(addr, 0)        -- creates 2^(addr'length) bins

    -- 7. Create a single bin for a transition of values
    bin_transition((1,3,5,7))  -- Note the use of double parentheses due to the integer_vector parameter

With the functions above and the procedure ``add_bins()``, bins can be added to the coverpoint.

.. code-block::

    -- 1. Add a single bin for a single value
    my_coverpoint.add_bins(bin(0));

    -- 2. Add a single bin for multiple values (sample any of the values to increase the bin counter)
    my_coverpoint.add_bins(bin((2,4,6,8)));

    -- 3. Add a single bin for a range of values
    my_coverpoint.add_bins(bin_range(0, 5));

    -- 4. Add a number of bins from a range of values
    my_coverpoint.add_bins(bin_range(1, 8, 2));

    -- 5. Add a single bin for a vector's range
    my_coverpoint.add_bins(bin_vector(addr));

    -- 6. Add a number of bins from a vector's range
    my_coverpoint.add_bins(bin_vector(addr, 4));

    -- 7. Add a single bin for a transition of values
    my_coverpoint.add_bins(bin_transition((1,3,5,7)));

The bin functions may be concatenated to add several bins at once.

.. code-block::

    my_coverpoint.add_bins(bin(0) & bin((2,4,6,8)) & bin_range(50, 100, 2));

.. note::

    * The maximum number of bins which can be added at once using a single ``add_bins()`` call is limited by C_FC_MAX_NUM_NEW_BINS 
      defined in adaptations_pkg.
    * If many bins are added at once using concatenation, there will be a temporary increase in memory usage due to the big array
      being created to hold all the bins. However, after ``add_bins()`` has finished, the memory will be released.

Ignore bins
==================================================================================================================================
Specific values or transitions can be excluded from the coverage by using ignore bins. This is useful to:

* Discard one or more values in a range
* Discard one or more values after automatically creating bins
* Discard complete or partial transitions

Note that the order in which the bins are added, both valid and ignore, does not matter.

.. code-block::

    -- Example 1
    my_coverpoint.add_bins(bin_range(0,99));
    my_coverpoint.add_bins(ignore_bin(50));
    my_coverpoint.add_bins(ignore_bin_range(25,30) & ignore_bin_range(75,80));

    -- Example 2
    my_coverpoint.add_bins(bin_vector(addr,0));
    my_coverpoint.add_bins(ignore_bin(0));

    -- Example 3
    my_coverpoint.add_bins(bin_transition((0,1,10))); --> Ignored
    my_coverpoint.add_bins(bin_transition((0,1,20)));
    my_coverpoint.add_bins(bin_transition((0,1,30)));
    my_coverpoint.add_bins(bin_transition((0,2,10)));
    my_coverpoint.add_bins(bin_transition((0,2,20)));
    my_coverpoint.add_bins(bin_transition((0,2,30))); --> Ignored
    my_coverpoint.add_bins(bin_transition((5,3,10))); --> Ignored
    my_coverpoint.add_bins(bin_transition((5,3,20))); --> Ignored
    my_coverpoint.add_bins(bin_transition((5,3,30))); --> Ignored
    my_coverpoint.add_bins(ignore_bin_transition((0,2,30))); -- Ignores all transitions which include 0,2,30
    my_coverpoint.add_bins(ignore_bin_transition((1,10)));   -- Ignores all transitions which include 1,10
    my_coverpoint.add_bins(ignore_bin(5));                   -- Ignores any bin which contains 5, including transitions

Illegal bins
==================================================================================================================================
Specific values or transitions can be marked as illegal which will exclude them from the coverage and generate an alert if they are 
sampled. The default severity of the alert is ERROR and can be configured using the ``set_illegal_bin_alert_level()`` procedure.

.. code-block::

    my_coverpoint.set_illegal_bin_alert_level(WARNING);
    my_coverpoint.add_bins(illegal_bin(256));
    my_coverpoint.add_bins(illegal_bin_range(220, 250));
    my_coverpoint.add_bins(illegal_bin_transition((200,100,0)));

Using predefined bins
==================================================================================================================================
Sometimes it is useful to define bins which have a particular meaning or which are used several times. A constant or a variable 
can be created using the type *t_new_bin_array(0 to 0)* which is returned by any of the bin functions. 

.. code-block::

    constant C_BIN_IDLE    : t_new_bin_array(0 to 0) := bin(0);
    constant C_BIN_RUNNING : t_new_bin_array(0 to 0) := bin(1);
    constant C_BIN_ILLEGAL : t_new_bin_array(0 to 0) := illegal_bin(2);
    ...
    variable v_bin_sequence : t_new_bin_array(0 to 0) := bin_transition((0,2,4,8,16,32,64,128));
    variable v_bin_ranges   : t_new_bin_array(0 to 0) := bin_range(0,255,2);
    ...
    my_coverpoint.add_cross(C_BIN_IDLE, v_bin_sequence & v_bin_ranges);
    my_coverpoint.add_cross(C_BIN_RUNNING, v_bin_sequence & v_bin_ranges);
    my_coverpoint.add_cross(C_BIN_ILLEGAL, v_bin_sequence & v_bin_ranges);

Adding bins from separate process
==================================================================================================================================
In some cases there is one process that creates the coverpoint model and another process that samples the data, e.g. a sequencer 
adds the bins to the coverpoint and a VVC samples the data from the DUT. If for some reason the VVC receives some data and samples 
it before the sequencer has added the bins, the testbench will generate a TB_ERROR alert. In cases like this we can use the function 
``is_defined()`` to check if the coverpoint has any bins before sampling the data.

.. code-block::

    -- Process 1 (Sequencer)
    ...
    my_coverpoint.add_bins(bin_range(0,255));
    my_coverpoint.add_bins(illegal_bin(256));
    ...

    -- Process 2 (VVC)
    ...
    while not(my_coverpoint.is_defined(VOID)) loop
      wait for C_CLK_PERIOD;
    end loop;
    my_coverpoint.sample_coverage(read_addr);
    ...

.. note::

    It is recommended to add all the bins at the beginning of the testbench (time 0 ns) to avoid adding any bins after the coverpoint 
    has been sampled. If this happens, a TB_WARNING alert will be generated because some bins might have incomplete coverage.

Bin memory allocation
==================================================================================================================================
For users who want more control over the memory usage during simulation, it is possible to configure how large the bin list is 
initially (C_FC_DEFAULT_INITIAL_NUM_BINS_ALLOCATED) and how much the size increments (C_FC_DEFAULT_NUM_BINS_ALLOCATED_INCREMENT) 
when the list becomes full. These constants are defined in adaptations_pkg.

Moreover, the procedures ``set_num_allocated_bins()`` and ``set_num_allocated_bins_increment()`` can be used to reconfigure a 
coverpoint's respective values.

.. _bin_name:

Bin name
==================================================================================================================================
Bins can be named by using the optional parameter *bin_name* in the ``add_bins()`` and ``add_cross()`` procedures. If no name is
given, a default name with an index appended will be given. The default bin name is *bin_<idx>* and is set by the
C_FC_DEFAULT_BIN_NAME constant in the adaptations_pkg. If multiple bins are given to ``add_bins()`` (by using ``bin_range()``,
``bin_vector()``, or concatenation), or if a call to ``add_cross()`` results in multiple cross bins, the bin name will be indexed
as shown in the examples below. All bin name indices starts from 1.

A warning is issued when duplicate bin names are detected. This warning can be turned off by setting the
C_FC_BIN_NAME_DUPLICATE_WARNING constant in the adaptations_pkg.vhd to ``false``.

Having bin names is useful when reading the reports.

.. code-block::

    coverpoint_1.add_bins(bin(0));                        -- bin name: bin_1
    coverpoint_1.add_bins(bin(255), "bin_max");           -- bin name: bin_max
    coverpoint_1.add_bins(bin_range(0, 32, 4), "addr");   -- bin names: addr[1], addr[2], addr[3], addr[4]
    coverpoint_1.add_bins(bin(0) & bin(100), "two_bins"); -- bin names: two_bins[1], two_bins[2]
    coverpoint_1.add_bins(bin(1000));                     -- bin name: bin_2
    coverpoint_1.add_bins(bin_range(0, 100, 4));          -- bin names: bin_3[1], bin_3[2], bin_3[3], bin_3[4]

    coverpoint_2.add_cross(bin(0), bin(10));                                    -- bin name: bin_1
    coverpoint_2.add_cross(bin(0), bin(100), "cross_bin_a");                    -- bin name: cross_bin_a
    coverpoint_2.add_cross(bin(0), bin(50), bin(100), "cross_bin_b");           -- bin name: cross_bin_b
    coverpoint_2.add_cross(bin(0) & bin(5) & bin(10), bin(100), "cross_bin_c"); -- bin names: cross_bin_c[1], cross_bin_c[2], cross_bin_c[3]
    coverpoint_2.add_cross(bin_range(0, 10, 3), bin(100), "cross_bin_d");       -- bin names: cross_bin_d[1], cross_bin_d[2], cross_bin_d[3]
    coverpoint_2.add_cross(bin(10), bin(10000));                                -- bin name: bin_2
    coverpoint_2.add_cross(bin(5), bin_range(0, 100, 3));                       -- bin names: bin_3[1], bin_3[2], bin_3[3]

The maximum length of the name is determined by C_FC_MAX_NAME_LENGTH defined in adaptations_pkg. Longer names will be truncated
without warning.

.. note::

   It is recommended not to use bin names that may be generated automatically as input to the ``add_bins()`` and ``add_cross()`` procedures.

Minimum coverage
==================================================================================================================================
By default all bins created have a minimum coverage of 1, i.e. they only need to be sampled once to be covered. The parameter 
*min_hits* in the ``add_bins()`` procedure specifies how many times the bin must be sampled in order to be marked as covered.

.. code-block::

    add_bins(bin, min_hits, [bin_name])

    my_coverpoint.add_bins(bin(0), 1);
    my_coverpoint.add_bins(bin(2), 5);
    my_coverpoint.add_bins(bin(4), 10);

**********************************************************************************************************************************
Cross coverage
**********************************************************************************************************************************
Cross coverage can be used to track combinations of values from two or more objects (variable/signal/coverpoint). 
For example, when certain combinations of source address and destination address of the Ethernet protocol need to be verified.
Crosses are made using the ``add_cross()`` procedure and can be made either between bins or between coverpoints. 


.. code-block::

    add_cross(bin1, bin2)
    
    add_cross(coverpoint1, coverpoint2)


* Every type of bin (single value, multiple values, range, transition, ignore & illegal) can be crossed with each other.
* When crossing several transition bins, they must have the same number of transitions, e.g. ::

    my_cross.add_cross(bin_transition(0,7,15), bin_transition(64,128,256));
    my_cross.add_cross(bin_transition(0,7,15,32), bin_transition(64,128,256,512), bin(16384));

.. important::
    Once the number of crossed bins has been set in a coverpoint, by calling the first ``add_cross()``, it cannot be 
    changed anymore.

Crossing bins
==================================================================================================================================
This is a "faster" way of creating the crosses and useful when we need specific combinations of values. A cross between bins is 
added to a coverpoint by calling the ``add_cross()`` procedure in combination with :ref:`bin functions <bin_functions>`. 
The ``add_cross()`` overloads support up to 5 crossed elements. 
The min_hits argument can be included to specify how many times the scenario given by the cross must be sampled for the cross to be 
marked as covered. The default value is one, meaning that the scenario only has to be sampled once for the cross to be covered.


.. code-block::

    add_cross(bin1, bin2, [min_hits], [bin_name])

    my_cross.add_cross(bin(10), bin_range(0,15));
    my_cross.add_cross(bin(20), bin_range(16,31));
    my_cross.add_cross(bin(30), bin_range(32,63));
    my_cross.add_cross(bin((10,20,30)), illegal_bin_range(64,127), "illegal_bin");

.. code-block:: none

    # UVVM:  --------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS      MIN HITS    HIT COVERAGE      NAME       ILLEGAL/IGNORE
    # UVVM:     (10, 20, 30)x(64 to 127)      0          N/A           N/A        illegal_bin      ILLEGAL    
    # UVVM:          (10)x(0 to 15)           0           1           0.00%          bin_0            -       
    # UVVM:          (20)x(16 to 31)          0           1           0.00%          bin_1            -       
    # UVVM:          (30)x(32 to 63)          0           1           0.00%          bin_2            -       
    # UVVM:  ========================================================================================================

The bin functions may also be concatenated to add several bins at once.

.. code-block::

    add_cross(bin1, bin2, bin3, [bin_name])

    my_cross.add_cross(bin(10) & bin(20) & bin(30), bin_range(0,7) & bin_range(8,15), bin(1000));

.. code-block:: none

    # UVVM:  --------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS      MIN HITS    HIT COVERAGE      NAME       ILLEGAL/IGNORE
    # UVVM:       (10)x(0 to 7)x(1000)        0           1           0.00%          bin_0            -       
    # UVVM:       (10)x(8 to 15)x(1000)       0           1           0.00%          bin_1            -       
    # UVVM:       (20)x(0 to 7)x(1000)        0           1           0.00%          bin_2            -       
    # UVVM:       (20)x(8 to 15)x(1000)       0           1           0.00%          bin_3            -       
    # UVVM:       (30)x(0 to 7)x(1000)        0           1           0.00%          bin_4            -       
    # UVVM:       (30)x(8 to 15)x(1000)       0           1           0.00%          bin_5            -       
    # UVVM:  ========================================================================================================

Crossing coverpoints
==================================================================================================================================
This alternative is useful when the coverpoints are already created and we don't want to repeat the declaration of the bins. The 
``add_cross()`` overloads support up to 16 crossed elements. **Beta release only supports up to 5 crossed elements.**

When crossing coverpoints, the resulting bins will all have a min_hits value of 1, unless another min_hits value is given as
a parameter to the ``add_cross()`` procedure.

.. code-block::

    my_coverpoint_addr.add_bins(bin_vector(addr,0));
    my_coverpoint_size.add_bins(bin_range(0,127));
    my_cross.add_cross(my_coverpoint_addr, my_coverpoint_size);

.. code-block:: none

    # UVVM:  --------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS      MIN HITS    HIT COVERAGE      NAME       ILLEGAL/IGNORE
    # UVVM:          (0)x(0 to 127)           0           1           0.00%          bin_0            -       
    # UVVM:          (1)x(0 to 127)           0           1           0.00%          bin_1            -       
    # UVVM:          (2)x(0 to 127)           0           1           0.00%          bin_2            -       
    # UVVM:          (3)x(0 to 127)           0           1           0.00%          bin_3            -       
    # UVVM:  ========================================================================================================

Another benefit of this alternative is that we can cross already crossed coverpoints.

.. code-block::

    my_coverpoint_addr.add_bins(bin_vector(addr,0));
    my_coverpoint_size.add_bins(bin_range(0,127));
    my_cross_addr_size.add_cross(my_coverpoint_addr, my_coverpoint_size);

    my_coverpoint_mode.add_bins(bin(1000) & bin(2000) & bin(3000));
    my_cross_addr_size_mode.add_cross(my_cross_addr_size, my_coverpoint_mode);

.. code-block:: none

    # UVVM:  --------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS      MIN HITS    HIT COVERAGE      NAME       ILLEGAL/IGNORE
    # UVVM:       (0)x(0 to 127)x(1000)       0           1           0.00%          bin_0            -       
    # UVVM:       (0)x(0 to 127)x(2000)       0           1           0.00%          bin_1            -       
    # UVVM:       (0)x(0 to 127)x(3000)       0           1           0.00%          bin_2            -       
    # UVVM:       (1)x(0 to 127)x(1000)       0           1           0.00%          bin_3            -       
    # UVVM:       (1)x(0 to 127)x(2000)       0           1           0.00%          bin_4            -       
    # UVVM:       (1)x(0 to 127)x(3000)       0           1           0.00%          bin_5            -       
    # UVVM:       (2)x(0 to 127)x(1000)       0           1           0.00%          bin_6            -       
    # UVVM:       (2)x(0 to 127)x(2000)       0           1           0.00%          bin_7            -       
    # UVVM:       (2)x(0 to 127)x(3000)       0           1           0.00%          bin_8            -       
    # UVVM:       (3)x(0 to 127)x(1000)       0           1           0.00%          bin_9            -       
    # UVVM:       (3)x(0 to 127)x(2000)       0           1           0.00%         bin_10            -       
    # UVVM:       (3)x(0 to 127)x(3000)       0           1           0.00%         bin_11            -       
    # UVVM:  ========================================================================================================

**********************************************************************************************************************************
Sampling coverage
**********************************************************************************************************************************
The procedure ``sample_coverage()`` is used to collect coverage in a coverpoint (using integer parameter) or a cross (using 
integer_vector parameter). This will increment the number of hits in the bin containing the sampled value. Once the number of hits 
in a bin has reached the minimum coverage, the bin will be marked as covered.

.. important::

    It is NOT recommended to add more bins to a given coverpoint after it has been sampled, since the new bins will be missing any 
    previous sampled coverage. A TB_WARNING alert is generated whenever this occurs.

Overlapping bins
==================================================================================================================================
If a sampled value is contained in more than one valid bin (not ignore or illegal), all the valid bins will collect the coverage, 
i.e. increment the number of hits.

In case this is unintended behavior in the testbench, an alert can be generated when overlapping valid bins are sampled, by using 
the procedure ``set_bin_overlap_alert_level()``, to select the severity of the alert.

.. code-block::

    my_coverpoint.set_bin_overlap_alert_level(TB_WARNING);
    my_coverpoint.add_bins(bin_range(1,16), "valid_sizes");
    my_coverpoint.add_bins(bin_range(15,20), "big_sizes");
    my_coverpoint.sample_coverage(15);

However, if a sampled value is contained in both ignore or illegal and valid bins, the ignore/illegal bin will take precedence and 
the valid bin will be skipped.

Also, if a sampled value is contained in both ignore and illegal bins, then the illegal bin will take precedence.

.. _func_cov_pkg_coverage_status:

**********************************************************************************************************************************
Coverage status
**********************************************************************************************************************************
It is possible to track the current coverage in the coverpoint with the function ``get_coverage()``, which returns a real  
number representing the percentage value. There are 2 coverage types:

* **Bins Coverage**: percentage of the number of bins which are covered in the coverpoint *(covered_bins/total_bins)*
* **Hits Coverage**: percentage of the number of hits in relation to the number of min_hits for all the bins in the 
  coverpoint *(bin1_hits/bin1_min_hits + bin2_hits/bin2_min_hits + ...)*

It is also possible to check if the bins and/or hits coverage is complete using the function ``coverage_completed()``. Normally, 
both the bins and the hits coverage are completed at the same time, except when they have a different coverage goal (explained in 
the next section).

.. code-block::

    log(ID_SEQUENCER, "Bins Coverage: " & to_string(my_coverpoint.get_coverage(BINS),2) & "%");
    log(ID_SEQUENCER, "Hits Coverage: " & to_string(my_coverpoint.get_coverage(HITS),2) & "%");

    -- Do something while the coverpoint's coverage is incomplete
    while not(my_coverpoint.coverage_completed(BINS_AND_HITS)) loop
    ...
    end loop;

Similar functions for the overall status of the coverpoints are ``fc_get_overall_coverage()`` and ``fc_overall_coverage_completed()``. 
Thus, an additional coverage type is defined:

* **Covpts Coverage**: percentage of the number of coverpoints which are covered *(covered_covpts/total_covpts)*

.. code-block::

    log(ID_SEQUENCER, "Covpts Overall Coverage: " & to_string(fc_get_overall_coverage(COVPTS),2) & "%");
    log(ID_SEQUENCER, "Bins Overall Coverage: " & to_string(fc_get_overall_coverage(BINS),2) & "%");
    log(ID_SEQUENCER, "Hits Overall Coverage: " & to_string(fc_get_overall_coverage(HITS),2) & "%");

    -- Do something while the overall coverage is incomplete
    while not(fc_overall_coverage_completed(VOID)) loop
    ...
    end loop;

**********************************************************************************************************************************
Coverage goal
**********************************************************************************************************************************
Defines a percentage of the total coverage to complete. This can be used to scale the simulation time without changing the minimum 
coverage for each bin. It must be set at the beginning of the testbench, before sampling any coverage. There are 3 types:

Bins coverage goal
==================================================================================================================================
This value defines the percentage of the number of bins which need to be covered in the coverpoint and therefore the range is 
between 1 and 100. Default value is 100 (as in 100%).

.. code-block::

    -- Cover only 75% of the total number of bins in the coverpoint
    my_coverpoint.set_bins_coverage_goal(75);

    -- Cover only 10% of the total number of bins in the coverpoint
    my_coverpoint.set_bins_coverage_goal(10);

Hits coverage goal
==================================================================================================================================
This value defines the percentage of the min_hits which need to be covered for each bin in the coverpoint. Default value is 100 
(as in 100%).

.. code-block::

    -- Cover only half the min_hits of each bin in the coverpoint
    my_coverpoint.set_hits_coverage_goal(50);

    -- Cover twice the min_hits of each bin in the coverpoint
    my_coverpoint.set_hits_coverage_goal(200);

Coverpoints coverage goal
==================================================================================================================================
This value defines the percentage of the number of coverpoints which need to be covered and therefore the range is between 1 and 100.
Default value is 100 (as in 100%).

.. code-block::

    -- Cover only 25% of the total number of coverpoints
    fc_set_covpts_coverage_goal(25);

    -- Cover only 80% of the total number of coverpoints
    fc_set_covpts_coverage_goal(80);

**********************************************************************************************************************************
Coverage weight
**********************************************************************************************************************************
It specifies the weight of a coverpoint used when calculating the overall coverage. It must be set at the beginning of the 
testbench, before sampling any coverage. If set to 0, the coverpoint will be excluded from the overall coverage calculation. 
Default value is 1.

.. code-block::

    my_coverpoint_1.set_overall_coverage_weight(3);  -- If only this coverpoint is covered, total coverage will be 75%
    my_coverpoint_2.set_overall_coverage_weight(1);  -- If only this coverpoint is covered, total coverage will be 25%
    my_coverpoint_3.set_overall_coverage_weight(0);  -- This coverpoint is excluded from the total coverage calculation

**********************************************************************************************************************************
Coverpoint name
**********************************************************************************************************************************
A default name is automatically given to the coverpoint when it is configured for the first time or the first bin is added. The 
name can be modified by calling the ``set_name()`` procedure.

The maximum length of the name is determined by C_FC_MAX_NAME_LENGTH defined in adaptations_pkg.

.. _func_cov_pkg_coverage_report:

**********************************************************************************************************************************
Coverage report
**********************************************************************************************************************************
A detailed report for the coverage and the bins in the coverpoint can be printed using the ``report_coverage()`` procedure.

An overall report for all the coverpoints in the testbench can be printed using the ``fc_report_overall_coverage()`` procedure. 
Note that only key information is contained in the report, i.e. bins are not included.

The amount of information can be adjusted by using the parameter verbosity.

.. note::

    * All coverage values are capped to 100%, unless otherwise noted.
    * When the bin values don't fit under the BINS column, the bin name is printed instead and the values are printed at the bottom 
      of the report.

Coverpoint Verbose
==================================================================================================================================

.. code-block::

    my_coverpoint.report_coverage(VERBOSE); -- Prints illegal, ignore and valid bins

.. code-block:: none

    # UVVM:  =================================================================================================================
    # UVVM:  0 ns *** COVERAGE SUMMARY REPORT (VERBOSE): TB seq. ***                                                          
    # UVVM:  =================================================================================================================
    # UVVM:  Coverpoint:              Covpt_1
    # UVVM:  Coverage (for goal 100): Bins: 60.00%,   Hits: 76.47%  
    # UVVM:  -----------------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS      MIN HITS    HIT COVERAGE            NAME            ILLEGAL/IGNORE     
    # UVVM:           (256 to 511)            1          N/A           N/A             illegal_addr           ILLEGAL         
    # UVVM:        illegal_transition         0          N/A           N/A          illegal_transition        ILLEGAL         
    # UVVM:               (100)               0          N/A           N/A              ignore_addr            IGNORE         
    # UVVM:         ignore_transition         0          N/A           N/A           ignore_transition         IGNORE         
    # UVVM:            (0 to 125)             6           8           75.00%           mem_addr_low              -            
    # UVVM:          (126, 127, 128)          3           1          100.00%           mem_addr_mid              -            
    # UVVM:           (129 to 255)            14          4          100.00%           mem_addr_high             -            
    # UVVM:           (0->1->2->3)            0           2           0.00%            transition_1              -            
    # UVVM:           transition_2            2           2          100.00%           transition_2              -            
    # UVVM:  -----------------------------------------------------------------------------------------------------------------
    # UVVM:  illegal_transition: (2000->15->127->248->249->250->251->252->253->254)
    # UVVM:  ignore_transition: (1000->15->127->248->249->250->251->252->253->254)
    # UVVM:  transition_2: (0->15->127->248->249->250->251->252->253->254)
    # UVVM:  =================================================================================================================

Coverpoint Non-Verbose
==================================================================================================================================

.. code-block::

    my_coverpoint.report_coverage(VOID); -- Same as using NON_VERBOSE. Prints illegal (only when hits > 0) and valid bins

.. code-block:: none

    # UVVM:  =================================================================================================================
    # UVVM:  0 ns *** COVERAGE SUMMARY REPORT (NON VERBOSE): TB seq. ***                                                      
    # UVVM:  =================================================================================================================
    # UVVM:  Coverpoint:              Covpt_1
    # UVVM:  Coverage (for goal 100): Bins: 60.00%,   Hits: 76.47%  
    # UVVM:  -----------------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS      MIN HITS    HIT COVERAGE            NAME            ILLEGAL/IGNORE     
    # UVVM:           (256 to 511)            1          N/A           N/A             illegal_addr           ILLEGAL         
    # UVVM:            (0 to 125)             6           8           75.00%           mem_addr_low              -            
    # UVVM:          (126, 127, 128)          3           1          100.00%           mem_addr_mid              -            
    # UVVM:           (129 to 255)            14          4          100.00%           mem_addr_high             -            
    # UVVM:           (0->1->2->3)            0           2           0.00%            transition_1              -            
    # UVVM:           transition_2            2           2          100.00%           transition_2              -            
    # UVVM:  -----------------------------------------------------------------------------------------------------------------
    # UVVM:  transition_2: (0->15->127->248->249->250->251->252->253->254)
    # UVVM:  =================================================================================================================

Coverpoint Holes
==================================================================================================================================

.. code-block::

    my_coverpoint.report_coverage(HOLES_ONLY); -- Prints only the uncovered bins

.. code-block:: none

    # UVVM:  =================================================================================================================
    # UVVM:  0 ns *** COVERAGE HOLES REPORT: TB seq. ***                                                                      
    # UVVM:  =================================================================================================================
    # UVVM:  Coverpoint:              Covpt_1
    # UVVM:  Coverage (for goal 100): Bins: 60.00%,   Hits: 76.47%  
    # UVVM:  -----------------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS      MIN HITS    HIT COVERAGE            NAME            ILLEGAL/IGNORE     
    # UVVM:            (0 to 125)             6           8           75.00%           mem_addr_low              -            
    # UVVM:           (0->1->2->3)            0           2           0.00%            transition_1              -            
    # UVVM:  -----------------------------------------------------------------------------------------------------------------
    # UVVM:  =================================================================================================================

Overall Verbose
==================================================================================================================================

.. code-block::

    fc_report_overall_coverage(VERBOSE); -- Prints all the coverpoints

.. code-block:: none

    # UVVM:  =================================================================================================================
    # UVVM:  0 ns *** OVERALL COVERAGE REPORT (VERBOSE): TB seq. ***                                                          
    # UVVM:  =================================================================================================================
    # UVVM:  Coverage (for goal 100): Covpts: 50.00%,   Bins: 73.68%,   Hits: 76.00%  
    # UVVM:  =================================================================================================================
    # UVVM:      COVERPOINT    COVERAGE WEIGHT   COVERED BINS    COVERAGE(BINS|HITS)   GOAL(BINS|HITS)   % OF GOAL(BINS|HITS) 
    # UVVM:        Covpt_1            1              3 / 5         60.00% | 76.47%       50% | 100%        100.00% | 76.47%   
    # UVVM:        Covpt_2            1              3 / 3        100.00% | 100.00%      100% | 100%       100.00% | 100.00%  
    # UVVM:        Covpt_3            1              6 / 6        100.00% | 100.00%      100% | 100%       100.00% | 100.00%  
    # UVVM:        Covpt_4            1              0 / 4          0.00% | 0.00%        100% | 100%         0.00% | 0.00%    
    # UVVM:        Covpt_5            1              0 / 1          0.00% | 0.00%        100% | 100%         0.00% | 0.00%    
    # UVVM:        Covpt_6            1              4 / 4        100.00% | 100.00%      100% | 100%       100.00% | 100.00%  
    # UVVM:        Covpt_7            1              0 / 3          0.00% | 0.00%        100% | 100%         0.00% | 0.00%    
    # UVVM:        Covpt_8            1             12 / 12       100.00% | 100.00%      100% | 100%       100.00% | 100.00%  
    # UVVM:  =================================================================================================================

Overall Non-Verbose
==================================================================================================================================

.. code-block::

    fc_report_overall_coverage(VOID); -- Same as using NON_VERBOSE. Prints only the summary

.. code-block:: none

    # UVVM:  =================================================================================================================
    # UVVM:  0 ns *** OVERALL COVERAGE REPORT (NON VERBOSE): TB seq. ***                                                      
    # UVVM:  =================================================================================================================
    # UVVM:  Coverage (for goal 100): Covpts: 50.00%,   Bins: 73.68%,   Hits: 76.00%  
    # UVVM:  =================================================================================================================

Overall Holes
==================================================================================================================================

.. code-block::

    fc_report_overall_coverage(HOLES_ONLY); -- Prints the uncovered coverpoints

.. code-block:: none

    # UVVM:  =================================================================================================================
    # UVVM:  0 ns *** OVERALL HOLES REPORT: TB seq. ***                                                                       
    # UVVM:  =================================================================================================================
    # UVVM:  Coverage (for goal 100): Covpts: 50.00%,   Bins: 73.68%,   Hits: 76.00%  
    # UVVM:  =================================================================================================================
    # UVVM:      COVERPOINT    COVERAGE WEIGHT   COVERED BINS    COVERAGE(BINS|HITS)   GOAL(BINS|HITS)   % OF GOAL(BINS|HITS) 
    # UVVM:        Covpt_1            1              3 / 5         60.00% | 76.47%       50% | 100%        100.00% | 76.47%   
    # UVVM:        Covpt_4            1              0 / 4          0.00% | 0.00%        100% | 100%         0.00% | 0.00%    
    # UVVM:        Covpt_5            1              0 / 1          0.00% | 0.00%        100% | 100%         0.00% | 0.00%    
    # UVVM:        Covpt_7            1              0 / 3          0.00% | 0.00%        100% | 100%         0.00% | 0.00%    
    # UVVM:  =================================================================================================================

Using goal
==================================================================================================================================
When either the bins goal, the hits goal or the coverpoints goal is configured with a value different than 100, the corresponding 
report shows 3 extra lines:

* **Goal** = configured goal value.
* **% of Goal** = percentage of the covered goal, stops at 100%.
* **% of Goal (uncapped)** = percentage of the covered goal without limits. This is useful to see if there are bins 
  which are over-sampled.

.. code-block:: none

    # UVVM: ==================================================================================================================
    # UVVM: 0 ns *** COVERAGE SUMMARY REPORT (NON VERBOSE): TB seq. ***                                                       
    # UVVM: ==================================================================================================================
    # UVVM: Coverpoint:              Covpt_1
    # UVVM: Goal:                    Bins: 50%,      Hits: 100%    
    # UVVM: % of Goal:               Bins: 100.00%,  Hits: 76.47%  
    # UVVM: % of Goal (uncapped):    Bins: 120.00%,  Hits: 147.06% 
    # UVVM: Coverage (for goal 100): Bins: 60.00%,   Hits: 76.47%  
    # UVVM: ------------------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS      MIN HITS    HIT COVERAGE            NAME            ILLEGAL/IGNORE     
    # UVVM:           (256 to 511)            1          N/A           N/A             illegal_addr           ILLEGAL         
    # UVVM:            (0 to 125)             6           8           75.00%           mem_addr_low              -            
    # UVVM:          (126, 127, 128)          3           1          100.00%           mem_addr_mid              -            
    # UVVM:           (129 to 255)            14          4          100.00%           mem_addr_high             -            
    # UVVM:           (0->1->2->3)            0           2           0.00%            transition_1              -            
    # UVVM:           transition_2            2           2          100.00%           transition_2              -            
    # UVVM: ------------------------------------------------------------------------------------------------------------------
    # UVVM: transition_2: (0->15->127->248->249->250->251->252->253->254)
    # UVVM: ==================================================================================================================

.. code-block:: none

    # UVVM:  =================================================================================================================
    # UVVM:  0 ns *** OVERALL COVERAGE REPORT (NON VERBOSE): TB seq. ***                                                      
    # UVVM:  =================================================================================================================
    # UVVM:  Goal:                    Covpts: 25%
    # UVVM:  % of Goal:               Covpts: 100.00%
    # UVVM:  % of Goal (uncapped):    Covpts: 200.00%
    # UVVM:  Coverage (for goal 100): Covpts: 50.00%,   Bins: 73.68%,   Hits: 76.00%  
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
    # UVVM:            BINS COVERAGE GOAL      :                            100
    # UVVM:            HITS COVERAGE GOAL      :                            100
    # UVVM:            COVERPOINTS GOAL        :                            100
    # UVVM:            NUMBER OF BINS          :                             36
    # UVVM:            CROSS DIMENSIONS        :                              2
    # UVVM:  =================================================================================================================

**********************************************************************************************************************************
Coverage database
**********************************************************************************************************************************
In order to accumulate coverage when running several testcases we need to store the coverpoint model, configuration and the 
accumulated counters at the end of one testcase and load it at the beginning of the next. This can be done with ``write_coverage_db()`` 
which writes all the necessary information to a file and ``load_coverage_db()`` which reads it back into a new coverpoint. Note 
that this must be done for every coverpoint in the testbench and they must be written to separate files.

When using ``load_coverage_db()``, the following applies for the given coverpoint:

    * The complete configuration is overwritten.
    * The bins matching with the loaded bins (same type, values, min_hits and rand_weight) are also overwritten.
    * Any loaded bins which are not found in the given coverpoint are added.
    * Any bins in the given coverpoint which are not found in the loaded coverpoint are kept. However, depending on the 
      *new_bins_acceptance* parameter, an alert can be generated whenever this occurs. The default behavior is to generate a 
      TB_WARNING alert to ensure that all the testcases collect coverage from the same bins. However, for instance when running 
      two testcases in a certain order, one might add extra bins in the second testcase which are irrelevant for the first one, 
      and in this case the alert can be removed.

.. important::

    * It is NOT recommended to add more bins to a given coverpoint after loading the database to avoid creating duplicate bins. A 
      TB_WARNING alert is generated whenever this occurs.
    * It is NOT recommended to sample a coverpoint before loading the database since that coverage will be overwritten. A 
      TB_WARNING alert is generated whenever this occurs.

When loading a database, the coverage report will be written to the log. In this case, it also contains the number of testcases 
that have accumulated coverage for the given coverpoint. This way one can see if there is a missing testcase for instance when 
setting the *alert_level_if_not_found* parameter in ``load_coverage_db()`` to TB_NOTE or NO_ALERT.

.. code-block:: none

    # UVVM:  =================================================================================================================
    # UVVM:  0 ns *** COVERAGE HOLES REPORT: TB seq. ***                                                                      
    # UVVM:  =================================================================================================================
    # UVVM:  Coverpoint:              Covpt_1    (accumulated over this and 2 previous testcases)
    # UVVM:  Coverage (for goal 100): Bins: 60.00%,   Hits: 76.47%  
    # UVVM:  -----------------------------------------------------------------------------------------------------------------
    # UVVM:               BINS               HITS      MIN HITS    HIT COVERAGE            NAME            ILLEGAL/IGNORE     
    # UVVM:            (0 to 125)             6           8           75.00%           mem_addr_low              -            
    # UVVM:           (0->1->2->3)            0           2           0.00%            transition_1              -            
    # UVVM:  -----------------------------------------------------------------------------------------------------------------
    # UVVM:  =================================================================================================================

The overall coverage report will also contain a new column NUM TESTCASES indicating the total number of testcases that have 
accumulated coverage for each coverpoint.

.. code-block:: none

    # UVVM:  ===================================================================================================================================
    # UVVM:  0 ns *** OVERALL HOLES REPORT: TB seq. ***                                                                       
    # UVVM:  ===================================================================================================================================
    # UVVM:  Coverage (for goal 100): Covpts: 50.00%,   Bins: 73.68%,   Hits: 76.00%  
    # UVVM:  ===================================================================================================================================
    # UVVM:      COVERPOINT    COVERAGE WEIGHT   COVERED BINS    COVERAGE(BINS|HITS)   GOAL(BINS|HITS)   % OF GOAL(BINS|HITS)   NUM TESTCASES 
    # UVVM:        Covpt_1            1              3 / 5         60.00% | 76.47%       50% | 100%        100.00% | 76.47%          3
    # UVVM:        Covpt_4            1              0 / 4          0.00% | 0.00%        100% | 100%         0.00% | 0.00%           1
    # UVVM:        Covpt_5            1              0 / 1          0.00% | 0.00%        100% | 100%         0.00% | 0.00%           1
    # UVVM:        Covpt_7            1              0 / 3          0.00% | 0.00%        100% | 100%         0.00% | 0.00%           1
    # UVVM:  ===================================================================================================================================

*Example 1: The testcases are run in a specified order.*

#. TC_1 adds bins to a coverpoint, samples coverage and writes the database to "coverpoint_1.txt".
#. TC_2 loads the database from "coverpoint_1.txt", samples coverage and writes the updated database to "coverpoint_1.txt", which 
   overwrites the content of the file.
#. TC_3 does the same as TC_2.

.. note::

    If the file to be loaded is not found, a TB_ERROR will be generated.

*Example 2: The testcases are run in a random sequence.*

#. Each TC adds bins to a coverpoint, loads the database from "coverpoint_1.txt", samples coverage and writes the updated database
   back to the same file "coverpoint_1.txt".

.. note::

    In this example, the first testcase run will not find any database file so the *alert_level_if_not_found* parameter in 
    ``load_coverage_db()`` must be set to TB_NOTE or NO_ALERT for every testcase so the simulation can complete successfully.

*Example 3: The testcases are run in parallel.*

#. Each TC adds bins to a coverpoint, samples coverage and writes the database to a different file.
#. After all simulations are done, use the :ref:`func_cov_pkg_coverage_merge_script` to merge the database files for the given 
   coverpoint.

.. note::

    The downside of this approach is that the accumulated coverage will not be visible in simulation.

Overall coverage accumulation
==================================================================================================================================
Since the ``write_coverage_db()`` procedure is defined in a protected type, every single coverpoint needs to call the procedure to 
store its corresponding database, which can be tedious with many coverpoints. One way to simplify this, could be to define the 
coverpoints in a global package as shared variables and create a procedure, e.g. ``write_overall_coverage_db()``, which calls the 
``write_coverage_db()`` from every coverpoint defined in the package. The same applies for ``load_coverage_db()``.

.. code-block::

    package global_fc_pkg is
      -- Global coverpoints
      shared variable shared_coverpoint1   : t_coverpoint;
      shared variable shared_coverpoint2   : t_coverpoint;
      shared variable shared_coverpoint3   : t_coverpoint;
      ...
      shared variable shared_coverpoint100 : t_coverpoint;

      procedure write_overall_coverage_db(
        constant VOID : in t_void
      );
      procedure load_overall_coverage_db(
        constant VOID : in t_void
      );
    end package global_fc_pkg;

    package body global_fc_pkg is
      procedure write_overall_coverage_db(
        constant VOID : in t_void) is
      begin
        shared_coverpoint1.write_coverage_db("covpt1.txt");
        shared_coverpoint2.write_coverage_db("covpt2.txt");
        shared_coverpoint3.write_coverage_db("covpt3.txt");
        ...
        shared_coverpoint100.write_coverage_db("covpt100.txt");
      end procedure;
      ...
    end package body global_fc_pkg;

Clearing coverage
==================================================================================================================================
A coverpoint's coverage counters can be reset with ``clear_coverage()``. This might be useful for example when running several 
testcases in a single testbench and the coverage needs to be restarted after each testcase or when loading a coverpoint database 
and only want to keep the model and configuration.

File format
==================================================================================================================================
The database for a coverpoint is stored using the following file format:

.. note::

    * The FILE_HEADER is a constant used to identify the functional coverage files created by UVVM.
    * The *for loops* and the leading spaces in the indented lines are only for better readability and not part of the data.

.. code-block::

    [FILE_HEADER]
    [coverpoint_name]
    [scope]
    [number_of_bins_crossed]
    [sampled_coverpoint]
    [num_tc_accumulated]
    [randomization_seed_1] [randomization_seed_2]
    [illegal_bin_alert_level]
    [bin_overlap_alert_level]
    [number_of_valid_bins]
    [number_of_covered_bins]
    [total_bin_min_hits]
    [total_bin_hits]
    [total_coverage_bin_hits]
    [total_goal_bin_hits]
    [covpt_coverage_weight]
    [bins_coverage_goal]
    [hits_coverage_goal]
    [covpts_coverage_goal]
    [bin_idx]
    for i in 0 to bin_idx-1 loop
      [bin(i).name]
      [bin(i).hits] [bin(i).min_hits] [bin(i).rand_weight]
      for j in 0 to number_of_bins_crossed-1 loop
        [bin(i).cross(j).bin_type] [bin(i).cross(j).num_values] [bin(i).cross(j).values_1] [bin(i).cross(j).values_2] ... [bin(i).cross(j).values_n]
      end loop;
    end loop;
    [invalid_bin_idx]
    for i in 0 to invalid_bin_idx-1 loop
      [invalid_bin(i).name]
      [invalid_bin(i).hits] [invalid_bin(i).min_hits] [invalid_bin(i).rand_weight]
      for j in 0 to number_of_bins_crossed-1 loop
        [invalid_bin(i).cross(j).bin_type] [invalid_bin(i).cross(j).num_values] [invalid_bin(i).cross(j).values_1] [invalid_bin(i).cross(j).values_2] ... [invalid_bin(i).cross(j).values_n]
      end loop;
    end loop;

The following values are constrained as: ::

    bin(i).cross(j).values_n         --> n = bin(i).cross(j).num_values
    invalid_bin(i).cross(j).values_n --> n = invalid_bin(i).cross(j).num_values

Most of the values are integer numbers except for a few:

+-----------------------------+------------------+--------------+
| Value                       | Original type    | Type in file |
+=============================+==================+==============+
| coverpoint_name             | string           | string       |
+-----------------------------+------------------+--------------+
| scope                       | string           | string       |
+-----------------------------+------------------+--------------+
| sampled_coverpoint          | boolean          | boolean      |
+-----------------------------+------------------+--------------+
| illegal_bin_alert_level     | t_alert_level    | integer      |
+-----------------------------+------------------+--------------+
| bin_overlap_alert_level     | t_alert_level    | integer      |
+-----------------------------+------------------+--------------+
| name                        | string           | string       |
+-----------------------------+------------------+--------------+
| bin_type                    | t_cov_bin_type   | integer      |
+-----------------------------+------------------+--------------+

Example of the file output:

.. code-block:: none

    --UVVM_FUNCTIONAL_COVERAGE_FILE--
    MY_CROSS
    NEW_SCOPE
    2
    TRUE
    0
    1082914553 1166884309
    4
    7
    5
    0
    38
    16
    16
    16
    8
    100
    200
    100
    5
    bin_0
    0 1 -1
    0 1 10 
    0 1 1010 
    single
    2 8 20
    0 1 20 
    0 1 1020 
    multiple
    3 9 30
    0 3 30 35 39 
    0 3 1030 1035 1039 
    range
    10 15 40
    3 2 40 49 
    3 2 1040 1049 
    transition
    1 5 50
    6 6 50 51 52 53 54 55 
    6 6 1050 1051 1052 1053 1054 1055 
    3
    ignore_single
    1 0 0
    1 1 110 
    1 1 1110 
    illegal_range
    4 0 0
    5 2 226 229 
    5 2 1226 1229 
    illegal_transition
    1 0 0
    8 3 231 237 237 
    8 3 1231 1237 1237 

.. _func_cov_pkg_coverage_merge_script:

Coverage merge script
==================================================================================================================================
A python script to accumulate coverage from different database files is provided in *uvvm_util/script/func_cov_merge.py*.

+------------------+--------------------+--------------------------------------------------+----------------------------+
| Arguments                             | Description                                      | Default value              |
+==================+====================+==================================================+============================+
| -h               | --help             | Help screen                                      |                            |
+------------------+--------------------+--------------------------------------------------+----------------------------+
| -d DIR           | --dir DIR          | Search directory                                 | Current directory          |
+------------------+--------------------+--------------------------------------------------+----------------------------+
| -f FILE          | --file FILE        | Coverage database file name/extension            | .txt                       |
+------------------+--------------------+--------------------------------------------------+----------------------------+
| -o OUTPUT        | --output OUTPUT    | Coverage database output file                    | func_cov_accumulated.txt   |
+------------------+--------------------+--------------------------------------------------+----------------------------+
| -r               | --recursive        | Recursive directory file search                  |                            |
+------------------+--------------------+--------------------------------------------------+----------------------------+
| -im              | --ignore_mismatch  | Do not report coverpoints with mismatching bins  |                            |
+------------------+--------------------+--------------------------------------------------+----------------------------+
| -nv              | --non_verbose      | Print non_verbose report                         | Print verbose report       |
+------------------+--------------------+--------------------------------------------------+----------------------------+
| -hl              | --holes            | Print coverage holes report                      | Print verbose report       |
+------------------+--------------------+--------------------------------------------------+----------------------------+

.. code-block::

    py ../script/func_cov_merge.py -f db_*.txt -o func_cov_report_holes.txt -r -hl

The script will print, both to the terminal and a file, the *coverage report* for each coverpoint and the *overall coverage
report* with a similar format to :ref:`func_cov_pkg_coverage_report`. The verbosity of the reports can be adjusted using the 
arguments -nv or -hl. Note that the output file path is relative to the directory where the script is run.

The following rules apply when merging a coverpoint from different files:

    * The coverpoint's name must match.
    * The coverpoint's number_of_bins_crossed must match.
    * The coverpoint's configuration, e.g. coverage_weight and coverage goals, is overwritten with the last loaded file. For this 
      reason it is recommended to ensure the same configuration is used in all the testcases for the given coverpoint.
    * The coverpoint's bins must match in: type, values, min_hits and rand_weight.
    * The matching bins' name is overwritten with the last loaded file. Again, it is recommended to use the same bin name in all 
      the testcases for the given coverpoint.
    * The matching bins' hits are accumulated.
    * Any non-matching bins are added to the merged coverpoint.
    * If a coverpoint has mismatching bins it will be reported at the end. This message can be disabled by using the -im argument.

**********************************************************************************************************************************
Clearing a coverpoint
**********************************************************************************************************************************
A coverpoint's complete model, configuration and counters can be reset with ``delete_coverpoint()``.

**********************************************************************************************************************************
Additional info
**********************************************************************************************************************************
Log messages within the procedures and functions in the *func_cov_pkg* use the following message IDs (disabled by default):

* ID_FUNC_COV_BINS: Used for logging functional coverage ``add_bins()`` and ``add_cross()`` methods. Note that each bin function within 
  the ``add_bins()`` and ``add_cross()`` log has a string length limited by C_FC_MAX_PROC_CALL_LENGTH defined in adaptations_pkg.
* ID_FUNC_COV_BINS_INFO: Used for logging functional coverage ``add_bins()`` and ``add_cross()`` methods detailed information.
* ID_FUNC_COV_RAND: Used for logging functional coverage "Optimized Randomization" values returned by rand().
* ID_FUNC_COV_SAMPLE: Used for logging functional coverage sampling.
* ID_FUNC_COV_CONFIG: Used for logging functional coverage configuration changes.

The default scope for log messages in the *func_cov_pkg* is C_TB_SCOPE_DEFAULT and it can be updated using the procedure 
``set_scope()``. The maximum length of the scope is defined by C_LOG_SCOPE_WIDTH. Both of these constants are defined in adaptations_pkg.

The maximum number of coverpoints that can be created is determined by C_FC_MAX_NUM_COVERPOINTS defined in adaptations_pkg.

.. note::

    Enhanced Randomization, Optimized Randomization and Functional Coverage were inspired by general statistics and similar 
    functionality in SystemVerilog and OSVVM.

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



.. include:: rst_snippets/ip_disclaimer.rst
