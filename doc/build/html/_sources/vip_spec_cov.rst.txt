.. _vip_spec_cov:

##################################################################################################################################
Bitvis VIP Specification Coverage
##################################################################################################################################
The Specification Coverage feature (aka Requirements Coverage) is an efficient method for verifying the requirement specification.    

**Quick Access**

* `Requirement and Map files`_

  * `Requirement List file`_
  * `Requirement Map file (optional)`_
  * `Partial Coverage list file (optional)`_
  * `Script config file (optional)`_
  * `Partial Coverage file (generated)`_

* `Methods`_

  * `initialize_req_cov()`_
  * `tick_off_req_cov()`_
  * `finalize_req_cov()`_
  * `cond_tick_off_req_cov()`_
  * `disable_cond_tick_off_req_cov()`_
  * `enable_cond_tick_off_req_cov()`_

* `Post-processing script`_

  * `Output files`_

**********************************************************************************************************************************
Introduction
**********************************************************************************************************************************
An important step of design verification is to check that all requirements have been met. Requirements can be defined very differently 
depending on application, project management, quality requirements, etc. In some projects, requirements barely exist, and the 
functionality is based on a brief description. However, in projects where safety and reliability are key the requirement handling is an 
essential part of the project management flow. In some development standards the requirements and the corresponding testcases that 
verify the requirements need to be defined, reviewed and accepted by a third-party assessor before even starting the verification flow. 

This UVVM Verification IP is intended for projects where requirements are essential in the workflow but may also be used in a very 
simple way for projects with lower requirements. Examples of requirements can be seen in Table 1. It is in general a good idea to label 
the various requirements, and in many projects this would be mandatory. The example in Table 1 shows of course only a subset of all the 
requirements. 

.. list-table:: Table 1 Requirement examples. (Requirement labels are defined by the user)
   :widths: 20 80
   :header-rows: 1

   * - Requirement Label
     - Description
   * - UART_REQ_1
     - The device UART interface shall accept a baud rate of 9600 bps.
   * - UART_REQ_2
     - The device UART interface shall accept a baud rate of 19200 bps.
   * - UART_REQ_3
     - The device UART interface shall accept an odd parity.
   * - UART_REQ_4
     - The device reset shall be active low.

There are lots of acceptable approaches with respect to how much functionality is verified in each testcase and how these are 
organized. This VIP will allow various approaches from dead simple to advanced. In order to explain the concepts, we start with the 
simplest case and add step-by-step on that until we have built a full advanced Specification Coverage system.


Definitions
==================================================================================================================================

Testcase
----------------------------------------------------------------------------------------------------------------------------------
* A scenario or sequence of actions - controlled by the test sequencer.
* May test one or multiple features/requirements.
* Typically testing of related functionality, or a logical sequence of events, or an efficient sequence of events
* Important: The minimum sequence of events possible to run in a single simulation execution. Thus if there is an option to run one
  of multiple test sequences (A or B or C), a set of test sequences (A and B) or all sequences (A+B+C), then all of A, B and C are
  defined as individual testcases.

Specification Coverage
----------------------------------------------------------------------------------------------------------------------------------
A summary of how all the requirements in a complete Requirement Specification have been covered by the test suite (the complete
verification environment)

Partial Coverage
----------------------------------------------------------------------------------------------------------------------------------
* In this VIP a summary of how some (or all) requirements for a DUT have been covered by one specific testcase. There may be one or
  more testcases and Partial Coverage summaries for a DUT depending on complexity and approach.
* The accumulation (or merger) of all Partial Coverage summaries will yield the Specification Coverage. I.e. Testcase partial
  Specification Coverage -> 'Partial Coverage', and Test suite overall Specification Coverage -> 'Specification Coverage'

.. figure:: images/specification_coverage/workflow.png
   :alt: Workflow
   :width: 500pt
   :align: center

   Specification Coverage workflow

Compound requirement
----------------------------------------------------------------------------------------------------------------------------------   
A requirement consisting of one or more sub-requirements. The compound requirement is not tested directly, but rather through its
sub-requirements. The compound requirement is compliant if and only if all of its sub-requirement are compliant. 

Simplest possible usage, with a single testcase
==================================================================================================================================
For any FPGA / ASIC it is always important to properly specify the design requirements and check that they have all been tested. 
Normally it is often just ticked off somewhere that a particular requirement is tested – often only once during the development phase, 
and sometimes just as a mental exercise. It is always better to use a written, repeatable and automated approach. This VIP 
significantly simplifies such an approach. 

When feasible, the simplest structured approach would be to test all requirements in one single self-checking testcase. If so - all you 
want to do is the following - as illustrated in the diagram below:

#. List all DUT requirements in a Requirement List CSV file. (RL). This could mean anything from just writing down the requirements
   directly, to a fully automated requirement extraction from an existing Requirement Specification.
   **NOTE**: For Specification Coverage this list is mandatory, but a simplified mode of pure test reporting without the need for a prior 
   listing of the requirements is available (see more info in `Shortcut with no Requirement List`_ ).

#. Implement your testcase :samp:`(T)` with all tests required to verify the DUT.  (see `Methods`_)
   The test sequencer should initiate coverage using initialize_req_cov() :samp:`(T1)`, then for each verified requirement call 
   tick_off_req_cov() :samp:`(T2)` and then finalize coverage reporting using finalize_req_cov() :samp:`(T3)`.

#. When the testcase is executed (run), initialize_req_cov() :samp:`(T1)` (see `Methods`_) will read the given Requirement List 
   file (RL), the new Partial Coverage file :samp:`(PC)` is created, and the testcase name is stored. The header of the Partial 
   Coverage file - with NOTE, testcase-name and delimiter is written. The header is not shown in any of the examples, but is shown in 
   the file formats in the section `Requirement and Map files`_
   Then for each tick_off_req_cov() :samp:`(T2)` a separate line is written into the Partial Coverage file with a) the given 
   requirement label, b) the name of the testcase, and c) the result of the test. The result of the test will be PASS - unless marked 
   as FAIL in the procedure call or unexpected serious alerts (>= ERROR / TB_ERROR) have occurred, in which case it will be marked as 
   FAIL. 
   Finally when finalize_req_cov() :samp:`(T3)` is executed, a closing check of the alert counters is made. If ok, then 
   'SUMMARY, <Testcase name>, PASS' is written at the end of the Partial Coverage file. Otherwise FAIL rather than PASS 
   (provided testcase does not stop on the alert). If a testcase fails before reaching finalize_req_cov(), then no SUMMARY line will 
   be written. This is interpreted as FAIL. Note that a given requirement may be tested and reported several times, so that for 
   instance UART_REQ_3 may be listed multiple times in the Partial Coverage file :samp:`(PC)`.    
#. After the testcase has been executed, the overall Specification Coverage :samp:`(SC)` can be found by executing the Python script 
   run_spec_cov.py (see `Post-processing script`_). This script traverses the Requirement List (RL) and Partial Coverage file  
   :samp:`(PC)` and from that generates the Specification Coverage :samp:`(SC)`.
   Each requirement is listed in the Specification Coverage file. If a requirement has one or more FAIL in a Partial Coverage file, 
   the result is NON_COMPLIANT for that requirement.
   For a simple scenario with a single testcase, the Partial Coverage :samp:`(PC)`  file and the Specification Coverage file 
   :samp:`(SC)` yield the same information, but the Specification Coverage potentially with fewer lines.

.. figure:: images/specification_coverage/concept.png
   :alt: Simplest possible Specification Coverage (note that Partial Coverage files only show the actual requirement coverage lines)
   :width: 1300pt
   :align: center
   :name: fig-overview


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
Simple usage
**********************************************************************************************************************************

Shortcut with no Requirement List
==================================================================================================================================
A shortcut is supported to allow all tested requirements to be reported to the Partial Coverage file - without the need for a prior
listing of the requirements. This shortcut does of course not yield any Specification Coverage, as no specification is given, but could
be useful for scenarios or early testing where only a list of executed tests is wanted. This shortcut mode is automatically applied
when no Requirement List is provided as an input to the initialize_req_cov() VHDL command in the test sequencer. If so, the Partial
Coverage files will be generated, but no Specification Coverage file (the Python script) shall be run.


Simple usage, with multiple testcases
==================================================================================================================================
Many verification systems will have multiple testcases per DUT. If so, the above simplest approach is not possible. However, if your
tests are split on multiple testcases, but with no requirement as to which testcase tests what, then you can apply almost the same
simple approach as the simplest case above.

For this scenario, there will be two or more testcases, and so you will have to run all relevant testcases. There will of course still
be only a single Requirement List. For every single testcase the same set of commands will be applied - with initialize_req_cov(), one
or more tick_off_req_cov(), and finalize_req_cov(). The only thing to remember here is that initialize_req_cov() has to specify
separate Partial Coverage files for each testcase. Hence, after simulation you should end up with as many Partial Coverage files as
testcases

.. note::

    It is possible inside a test sequencer to execute initialize_req_cov() multiple times, but only when the previous
    initialize_req_cov() has been terminated with finalize_req_cov().  If multiple initialize… & finalize… these should operate on
    different Partial Coverage files to avoid overwriting the previous section.
  
The Python script run_spec_cov.py will be run in the same way as before, but needs to be given a list of all the relevant Partial
Coverage files. Then the Specification Coverage is generated exactly as before.


Multiple testcases, with strict requirement vs testcase relation
==================================================================================================================================
For most applications where high quality and confidence is required it is mandatory to specify up front in which testcase a given
requirement will be tested. In these cases, the Requirement List must be extended to include the testcase in which a requirement will
be tested, - as shown below. The example now shows more testcases than just tc_basic. 

.. figure:: images/specification_coverage/requirement_list.png
   :alt: Requirement List
   :width: 500pt
   :align: center

|

Specifying a testcase name in the Requirement List will however not force a requirement vs testcase check by itself. In order to check
that a requirement is tested in the specified testcase the switch '-strictness 1' must be used when calling run_spec_cov.py (see 
`Strictness levels`_). If strictness is set to 1 then for example the requirement 'UART_REQ_3, Odd parity, tc_basic will be: 

  | a) Marked as COMPLIANT in the Specification Coverage file if UART_REQ_3 is checked positive in testcase tc_basic. UART_REQ_3 may 
    additionally also be checked elsewhere. 

  | b) Will be marked as NOT_TESTED in the Specification Coverage file if UART_REQ_3 is not checked in testcase tc_basic 
    (but for instance only in tc_19k2).

Default strictness is -strictness 0, i.e. neither of the above strict checking.  See the section about `Strictness levels`_ for 
various strictness settings.

Testcase names and Requirement labels are not case sensitive for any comparison. For any output report the names and labels from the
Requirement List will be used if available. If not provided via the Requirement List, then testcase name is taken from the
initialize_req_cov() and the requirement label from the tick_off_req_cov(). 


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
Advanced usage
**********************************************************************************************************************************

Only one of multiple testcases for a given requirement must pass
==================================================================================================================================
In the previous example all tests in all testcases had to pass for the overall Specification Coverage to pass. There may however be
situations where a given requirement is tested in multiple testcases and it is sufficient that only any one of these pass - given of
course that none of the others have failed, but just haven't been executed. A fail in any executed testcase will always result in a
summary fail. This approach could for instance be used to qualify for a lab test release. A requirement for this approach to work is to
remove all old Partial Coverage files before running your test suite generating new Partial Coverage files. The run_spec_cov.py option
-clean may be used for this.  

.. figure:: images/specification_coverage/requirement_list_or_listed.png
   :alt: Requirement List
   :width: 700pt
   :align: center

|

The example above shows that UART_REQ_3 is covered by both testcases tc_basic and tc_19k2, and that UART_REQ_4 may in fact be tested by
any of the three testcases.

This example also shows that testcase tc_reset is not required to be executed in order for all requirements to be tested. This *could*
be a sign that tc_reset should be removed (optimized away), but given that tc_reset is required for some special reason, then it could
for instance be left out of from a reduced test suite to qualify for lab test only.


All (or some) of multiple testcases for a given requirement must pass
==================================================================================================================================
This is basically the opposite of the above and is easy to achieve by just adding lines in the Requirement List for all wanted
combinations of requirements and testcases. The example below states that UART_REQ_3 must pass in both tc_basic and tc_19k2.

.. figure:: images/specification_coverage/requirement_list_and_listed.png
   :alt: Requirement List
   :width: 300pt
   :align: center

|

Requirement mapping
==================================================================================================================================
Requirement mapping just maps one or more requirements to another requirement. This is intended for two different use cases: Mapping of
requirements to multiple sub-requirements, or mapping of project requirements to IP or legacy requirements. 

Mapping of project requirements to multiple sub-requirements
----------------------------------------------------------------------------------------------------------------------------------
Often the original requirements are too complex (or compound), so that it is difficult to tick off a requirement as checked until a
whole lot of different things are tested. An example of that could be a UART requirement like the one shown below - with a single
UART_REQ_GENERAL requirement. 

.. figure:: images/specification_coverage/super_req.png
   :alt: Requirement List
   :width: 350pt
   :align: center

|

If you want to split this into more specific requirements you have several options, with some potential options listed and illustrated
below. a) Rename the requirements b) Extend the names c) Extend the names using a record like notation

.. figure:: images/specification_coverage/requirement_split.png
   :alt: Requirement List
   :width: 800pt
   :align: center

|

All of these and more are of course possible, but the problem is that they don't show the relation to the original requirement.

Showing this relationship is quite simple in UVVM, by creating a Map file which maps the original requirement to a set of
sub-requirements. 

.. figure:: images/specification_coverage/mapping_long_name.png
   :alt: Mapping
   :width: 800pt
   :align: center

|

Or even simpler just name the sub-requirements A,B,C,…. 

.. figure:: images/specification_coverage/mapping_short_name.png
   :alt: Mapping
   :width: 800pt
   :align: center
 
|

This tells the Specification Coverage tool that the original (compound) requirement will be tested through these sub-requirements, and
that the compound requirement shall be compliant if and only if all the sub-requirements are compliant. 


Mapping of project requirements to IP or legacy requirements
----------------------------------------------------------------------------------------------------------------------------------
An alternative use case for requirement mapping is for IP or legacy requirements. Assuming you already have a UART IP, that has been
properly verified, and the provided UART testbench already has full UVVM Specification Coverage support, with a Requirement List file 
and testcases generating Partial Coverage files. Assuming you then have a project with its own UART requirements, that hopefully more 
or less matches that of the IP, but the requirement labels and combinations may be different. Then you don't want to modify the provided 
UART testbench in order just to get the "right" requirement labels. A much better approach is to map the project requirements to the 
UART IP requirements.

.. figure:: images/specification_coverage/requirement_list_ip.png
   :alt: Requirement List
   :width: 500pt
   :align: center

|

Now assume the already shown UART Requirement List is that of the IP, and that we have similar project UART requirements, we may have a
scenario as shown above. Here we can see that UART_REQ_B of the project matches that of UART_REQ_3 of the UART IP, and that UART_REQ_A
of the project is actually not covered by any single UART IP requirement, but in fact must include both UART_REQ_1 and UART_REQ_2. The
mapping would for this case be as shown below.

.. figure:: images/specification_coverage/requirement_mapping_ip.png
   :alt: Requirement List
   :width: 350pt
   :align: center

|

Making the Requirement Map file is of course a manual job, which could be simple or complex depending on how much the two requirement
lists differ in structure.

In this case, the legacy IP Requirement List will only be used as input for the legacy IP UART testbench, from which the PC files will 
be generated, while the project Requirement List will be used as input to the run_spec_cov.py Python script. The Requirement Map file 
is only used as an input to the run_spec_cov.py Python script, as is also the Partial Coverage file from the UART IP verification
using the IP (or legacy) testbench. The Python script will check that - For project requirement UART_REQ_A, both UART_REQ_1 and 
UART_REQ_2 have passed - For project requirement UART_REQ_B, UART_REQ_3 has passed - Etc…

The report from run_spec_cov.py will show compliance for the project requirement (e.g.UART_REQ_A), but also for the
"sub-requirement(s)" (e.g. UART_REQ_1 and UART_REQ_2).


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
Requirement and Map files
**********************************************************************************************************************************
The Requirement List file contains a list of requirements to be verified. As described in the section about `Mapping of project
requirements to multiple sub-requirements`_, some requirements from the specification may not be practical or possible to test
directly, and might therefore need to be divided into testable sub-requirements. This relationship between compound- and
sub-requirements is defined in the Requirement Map file. 

.. attention::
    In previous versions of UVVM (pre V2 2024.09.19), only requirements that could be ticked off directly (i.e. noncompound requirements
    and sub-requirements) would be listed in the Requirement List file. In the new format, described in this section, the Requirement 
    List file lists main requirements (i.e. compound and noncompound requirements), while sub-requirements are defined through the 
    Requirement Map file. The old input format is still supported, but this support may be removed in the future. 


Requirement List file
==================================================================================================================================
The Requirement List file is a CSV type file used as input both in the VHDL testcase and to the run_spec_cov.py script. The file
contains a list of the project requirements to be tested. The user may optionally also include specifications for which testcase
each requirement must be tested in. When multiple testcases are listed on the same line, the requirement only needs to be ticked off
in one of those testcases in order to be compliant. For testcases listed on a separate line, the requirement must be ticked off in
that testcase in order to be compliant. See `Advanced usage`_ for more information about testcase listing. 

============== ===========================================================================
**File**       Requirement List file
**Required?**  Required
**File type**  CSV
**Input to**   | run_spec_cov.py (*-r <req-list>.csv*)
               | VHDL testcase (*initialize_req_cov(<tc_name>, <req_list>, <pc_name>)*)
============== ===========================================================================


Syntax:

.. code-block:: none

    <Req. label>, <Description>[,<Testcase-name>, <Testcase-name>, ...]
    <Req. label>, <Description>[,<Testcase-name>, <Testcase-name>, ...]

Example:

.. code-block:: none

    UART_REQ_BR,    Baud-rate 9600 and 19k2, sub_requirement
    UART_REQ_ODD,   Odd parity,              tc_basic
    UART_REQ_RESET, Active low reset,        tc_reset, tc_basic

.. note::

    If tick-off is done on a requirement that was not listed in the Requirement List, a TB_WARNING will be issued during simulation.
    However, the requirement will still be included in the Partial Coverage file. The final compliance of the requirement will depend
    on the strictness level specified when running the run_spec_cov.py post-processing script.


Requirement Map file (optional)
==================================================================================================================================
The Requirement Map file is an optional CSV type file used as input to the run_spec_cov.py script. This file maps compound requirements
to sub-requirements. A compound requirement is compliant if and only if all of its sub-requirements are compliant. Descriptions and
testcases for the sub-requirements can also be listed in the Requirement Map file. The sub-requirement definition lines must be placed
below the requirement/sub-requirement mapping lines. 

============== =====================================
**File**       Requirement Map file
**Required?**  Optional
**File type**  CSV
**Input to**   run_spec_cov.py (*-m <map_file>.txt*)
============== =====================================

Syntax:

.. code-block:: none

    <Req. label>, <Sub-req. label> [,<Sub-req. label>, <Sub-req. label>, ...]
    <Req. label>, <Sub-req. label> [,<Sub-req. label>, <Sub-req. label>, ...]

    <Sub-req. label>, <Description> [,<Testcase-name>, <Testcase-name>, ...]
    <Sub-req. label>, <Description> [,<Testcase-name>, <Testcase-name>, ...]

Example:

.. code-block:: none

    UART_REQ_BR, UART_REQ_BR_A, UART_REQ_BR_B

    UART_REQ_BR_A, Baud-rate 9600, tc_br_9600
    UART_REQ_BR_B, Baud-rate 19k2, tc_br_19k2


Partial Coverage List file (optional)
==================================================================================================================================
The Partial Coverage list file is an optional .txt type file used as input to the run_spec_cov.py script. This file provides a list of
all the Partial Coverage files to processed by the Specification Coverage post-processing script. 

============== ====================================
**File**       Partial Coverage List file
**Required?**  Optional
**File type**  .txt
**Input to**   run_spec_cov.py (*-p <pc_list>.txt*)
============== ====================================

Syntax:

.. code-block:: none

    <path-to-partial-coverage-file>
    <path-to-partial-coverage-file>
    ...

Example:

.. code-block:: none

    ../sim/pc_1.csv
    ../sim/pc_2.csv


Script config file (optional)
==================================================================================================================================
The script config file is an optional .txt type file used as input to the run_spec_cov.py script. This file can be used to list all the
arguments to run_spec_cov.py. All arguments shall be added on a new line. The config file will override all other arguments. 

============== =========================================
**File**       Configuration file
**Required?**  Optional
**File type**  .txt
**Input to**   run_spec_cov.py (*--config <config>.txt*)
============== =========================================

Example:

.. code-block::

    --requirement_list ../script/requirements.csv
    --partial_cov ../script/partial_cov_list.txt
    --spec_cov spec_cov.csv
    --strictness 0


Partial Coverage file (generated)
==================================================================================================================================
The Partial Coverage file is a CSV type file generated by the VHDL package when a testcase is run, and used as input to the
run_spec_cov.py script. This file lists the output from the testcase. 

Syntax:

.. code-block:: none

    NOTE: <note>
    TESTCASE_NAME: <name>
    DELIMITER: <delimiter-character>

    <Requirement>, <Testcase>, <PASS/FAIL>
    ...
    SUMMARY,<Testcase>,<PASS/FAIL>

Example:

.. code-block::

    NOTE: This coverage file is only valid when the last line is 'SUMMARY, TC_1, PASS'
    TESTCASE_NAME: TC_1
    DELIMITER: ,

    REQ_1A,TC_1,PASS
    REQ_1B,TC_1,PASS
    REQ_1C,TC_1,PASS
    SUMMARY,TC_1,PASS


Comments
==================================================================================================================================
Any line in the Requirement- or Map files beginning with '#' will be treated as a comment, meaning it will be ignored by the VHDL and
python scripts. Note that in-line comments are not supported. 

Example of valid and invalid usage in Requirement List file:

.. code-block:: none

    # This line will be treated as a comment
    REQ_1, Description 1, TC_1
    REQ_2, Description 2, TC_2 # This will NOT be interpreted as a comment!


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
VHDL Package
**********************************************************************************************************************************
A vital part of the Specification Coverage concept is the VHDL testbench methods. These are located inside the spec_cov_pkg.vhd 
file in the src/ directory of this VIP. 

Configuration record
==================================================================================================================================
**t_spec_cov_config**

This record is located in the spec_cov_pkg.vhd. The configuration record is applied as a shared_variable 'shared_spec_cov_config' 
to allow different configuration for different DUTs. Any test sequencer may then set the complete record as required - or even just 
parts of it like ``shared_spec_cov_config.csv_delimiter := ';';``. The default values of this record can be modified via the 
adaptations_pkg.

+------------------------------+------------------+------------+----------------------------------------------------------+
|      Record elements         |       Type       | Default    |                    Description                           |
+==============================+==================+============+==========================================================+
| missing_req_label_severity   | t_alert_level    | TB_WARNING | Alert level used when the tick_off_req_cov() procedure   |
|                              |                  |            | does not find the specified requirement label in the     |
|                              |                  |            | Requirement List, given that a Requirement List is given |
|                              |                  |            | in the initialize_req_cov() command.                     |
+------------------------------+------------------+------------+----------------------------------------------------------+
| compound_req_tickoff_severity| t_alert_level    | TB_WARNING | Alert level used when the tick_off_req_cov() procedure   |
|                              |                  |            | is called on a compound requirement (i.e. a requirement  |
|                              |                  |            | meant to be tested through sub-requirements).            |
+------------------------------+------------------+------------+----------------------------------------------------------+
| csv_delimiter                | character        | ','        | Character used as delimiter in the CSV files. This will  |
|                              |                  |            | also be written into all Partial Coverage files.         |
|                              |                  |            | run_spec_cov.py will find the delimiter there.           |
|                              |                  |            | NOTE: The '&' and ' ' (space) symbols can not be used as |
|                              |                  |            | delimiter.                                               |
+------------------------------+------------------+------------+----------------------------------------------------------+
| max_requirements             | natural          | 1000       | Maximum number of requirements in the req_map file used  |
|                              |                  |            | in initialize_req_cov(). Increase this number if the     |
|                              |                  |            | number of requirements exceeds 1000.                     |
+------------------------------+------------------+------------+----------------------------------------------------------+
| max_testcases_per_req        | natural          | 20         | Maximum number of testcases allowed per requirement.     |
|                              |                  |            | This is applicable when one requirement is verified by   |
|                              |                  |            | one or more testcases.                                   |
+------------------------------+------------------+------------+----------------------------------------------------------+
| csv_max_line_length          | positive         | 256        | Maximum length of each line in any CSV file. (i.e. max   |
|                              |                  |            | number of characters for all values and separators in    |
|                              |                  |            | total)                                                   |
+------------------------------+------------------+------------+----------------------------------------------------------+

The Specification Coverage implementation uses three new message IDs, as described in the table below. All message Ids are located in
uvvm_util adaptations package. The Specification Coverage implementation uses the shared message id panel for all logging.

+--------------------+-----------------------------------------------------------------------+
| Message Id         | Description                                                           |
+====================+=======================================================================+
| ID_FILE_OPEN_CLOSE | Id used for any file open and close operation                         |
+--------------------+-----------------------------------------------------------------------+
| ID_FILE_PARSER     | Id used for CSV parser messages.                                      |
+--------------------+-----------------------------------------------------------------------+
| ID_SPEC_COV        | Id used for all messages that are not directly related to CSV parsing.|
+--------------------+-----------------------------------------------------------------------+

Methods
==================================================================================================================================
* All parameters in brackets are optional.

initialize_req_cov()
----------------------------------------------------------------------------------------------------------------------------------
This procedure starts the requirement coverage process in a testcase. The Requirement List file is optional, but without it the 
Specification Coverage is of course not possible and run_spec_cov.py shall not be executed. The partial_coverage_file is created - 
and the header is written with NOTE, Testcase-name and Delimiter on the first three lines. If file already exists, it will be 
overwritten. ::

    initialize_req_cov(testcase, [req_list_file], partial_cov_file)

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | testcase           | in     | string                       | Testcase name.                                          |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | req_list_file      | in     | string                       | Requirement List file name.                             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | partial_cov_file   | in     | string                       | Partial Coverage output file name.                      |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | map_list_file      | in     | string                       | Optional. Requirement Map file.                         |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block:: 

    -- Example:
    initialize_req_cov("TC_UART_9k6", "c:/my_folder/requirements.csv", "./cov_9k6.csv");
    initialize_req_cov("TC_UART_9k6", "requirements.csv", "cov_9k6.csv");


tick_off_req_cov()
----------------------------------------------------------------------------------------------------------------------------------
This procedure evaluates and logs the specified requirement. The procedure checks the global alert mismatch status, and if an alert
mismatch is present on ERROR, FAILURE, TB_ERROR or TB_FAILURE the requirement will be marked as FAIL. If there are no such alert
mismatches, the requirement will be marked as PASS, unless the requirement_status is explicitly set to FAIL. The result is written to
both the transcript (and log) and the Partial Coverage file (specified in the initialize_req_cov() command). The tick_off_req_cov()
will look up the specified requirement and testcase in the Requirement List specified in initialize_req_cov(), and use the description
from this entry as a minimum log message. The procedure will also issue a TB_WARNING if the specified requirement was not found in the
Requirement List. ::

    tick_off_req_cov(requirement, [requirement_status, [msg, [tickoff_extent, [scope]]]])

.. note::

    If tick-off is performed on a requirement that was not listed in the Requirement List, a TB_WARNING will be issued. However, the
    requirement will still be included in the Partial Coverage file. The final compliance of the requirement will depend on the
    strictness level specified when running the run_spec_cov.py script.

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | requirement        | in     | string                       | String with the requirement label. Must as default      |
|          |                    |        |                              | match a requirement label in the given Requirement List.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | requirement_status | in     | :ref:`t_test_status`         | Enter FAIL to explicitly fail the requirement. Default  |
|          |                    |        |                              | value is NA.                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert.       |
|          |                    |        |                              | Defaut value is "".                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | tickoff_extent     | in     | :ref:`t_extent_tickoff`      | Whether to log every tickoff for this requirement or    |
|          |                    |        |                              | only once. Default value is LIST_SINGLE_TICKOFF.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_SCOPE ("TB seq.(uvvm)").             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block:: 

    -- Examples:
    -- Will pass if no unexpected alert occurred
    tick_off_req_cov("UART_REQ_1");

    -- Will fail since passed argument is set to false
    tick_off_req_cov("UART_REQ_1", FAIL);

    -- In order to include msg and scope requirement_status and tickoff_extent must be included
    tick_off_req_cov("UART_REQ_1", NA, "my_msg");
    -- or 
    tick_off_req_cov("UART_REQ_1", NA, "my_msg", LIST_EVERY_TICKOFF, "my_scope");


finalize_req_cov()
----------------------------------------------------------------------------------------------------------------------------------
This procedure ends the requirement coverage process in a test. 
If alert status is OK - it appends the following line to the Partial Coverage file: 'SUMMARY, <Testcase name>, PASS'
If alert status is not OK - it appends the following line to the Partial Coverage file: 'SUMMARY, <Testcase name>, FAIL'
This line is used later by the run_spec_cov.py script.
If the simulation never reached this command, e.g. if failed, then no summary line is written - indicating FAIL::

    finalize_req_cov(VOID)

+----------+--------------------+--------+------------------------------+-------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                           |
+==========+====================+========+==============================+=======================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax           |
+----------+--------------------+--------+------------------------------+-------------------------------------------------------+

.. code-block:: 

    -- Example:
    finalize_req_cov(VOID);


cond_tick_off_req_cov()
----------------------------------------------------------------------------------------------------------------------------------
This procedure will tick off the specified requirement in the same way as tick_off_req_cov(), except that any requirement disabled for
conditional tick off (through the disable_cond_tick_off_req_cov() procedure) will be ignored (no tick off will be performed). ::

    cond_tick_off_req_cov(requirement, [requirement_status, [msg, [tickoff_extent, [scope]]]])

.. note::

    All requirements are by default enabled for conditional tick off, i.e. will act as being called using the tick_off_req_cov()
    procedure.

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | requirement        | in     | string                       | String with the requirement label. Must as default      |
|          |                    |        |                              | match a requirement label in the given Requirement List.|
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | requirement_status | in     | :ref:`t_test_status`         | Enter FAIL to explicitly fail the requirement. Default  |
|          |                    |        |                              | value is NA.                                            |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | msg                | in     | string                       | A custom message to be appended in the log/alert.       |
|          |                    |        |                              | Defaut value is "".                                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | tickoff_extent     | in     | :ref:`t_extent_tickoff`      | Whether to log every tickoff for this requirement or    |
|          |                    |        |                              | only once. Default value is LIST_SINGLE_TICKOFF.        |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | scope              | in     | string                       | Describes the scope from which the log/alert originates.|
|          |                    |        |                              | Default value is C_SCOPE ("TB seq.(uvvm)").             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    cond_tick_off_req_cov("UART_REQ_4");
    cond_tick_off_req_cov("UART_REQ_4", PASS, "Monitor", LIST_SINGLE_TICKOFF);


disable_cond_tick_off_req_cov()
----------------------------------------------------------------------------------------------------------------------------------
This procedure prevents the given requirement from being ticked off in the Partial Coverage file when ticked off using the
cond_tick_off_req_cov() procedure. ::

    disable_cond_tick_off_req_cov(requirement)

.. note::

    * The regular tick_off_req_cov() procedure is not affected by this disabling.
    * A TB_WARNING is raised if the requirement:
      * Is not listed in the Requirement List file.
      * Has already been disabled from conditional tick off.

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | requirement        | in     | string                       | Requirement to be disabled from conditional tick-off    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block:: 

    -- Example:
    disable_cond_tick_off_req_cov("UART_REQ_1");


enable_cond_tick_off_req_cov()
----------------------------------------------------------------------------------------------------------------------------------
This procedure permit the requirement to be ticked off in the Partial Coverage file when ticked off using cond_tick_off_req_cov()
procedure. ::

    enable_cond_tick_off_req_cov(requirement)

.. note::

    * All requirements are by default enabled for conditional requirement tick off.
    * A TB_WARNING is raised if the requirement: 
      * Is not listed in the Requirement List file.
      * Has not previously been disabled from conditional tick off.

+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | requirement        | in     | string                       | Requirement to be permitted for conditional tick-off    |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block:: 

    -- Example:
    enable_cond_tick_off_req_cov("UART_REQ_1");


Compilation
==================================================================================================================================
* This package may only be compiled with VHDL-2008 or newer. It is dependent on the :ref:`utility_library`, which is only 
  compatible with VHDL-2008 or newer.
* After UVVM-Util has been compiled, this package can be compiled into any desired library.
* See :ref:`Essential Mechanisms - Compile Scripts <vvc_framework_compile_scripts>` for information about compile scripts.

.. table:: Compile order for the Specification Coverage VIP

    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | Compile to library           | File                                           | Comment                                         |
    +==============================+================================================+=================================================+
    | bitvis_vip_spec_cov          | csv_file_reader_pkg.vhd                        | Package for reading and parsing of CSV input    |
    |                              |                                                | files                                           |
    +------------------------------+------------------------------------------------+-------------------------------------------------+
    | bitvis_vip_spec_cov          | spec_cov_pkg.vhd                               | Specification Coverage component implementation |
    +------------------------------+------------------------------------------------+-------------------------------------------------+


Simulator compatibility and setup
----------------------------------------------------------------------------------------------------------------------------------
.. include:: rst_snippets/simulator_compatibility.rst


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
Post-processing script
**********************************************************************************************************************************
The final step of the Specification Coverage usage is to run a post-processing script to evaluate all the simulation results. This
script is called run_spec_cov.py. The script requires Python 3.x. The script can be called with the arguments listed in the table below
from the command line. The CSV delimiter is fetched by the Python script from the Partial Coverage file headers.

.. note::

    All files may be referenced with absolute paths or relative to working directory.


.. _script_arguments_table:

.. list-table:: run_spec_cov.py script arguments
   :header-rows: 1
   :widths: 20 40 70

   * - Argument
     - Example
     - Description
   * - --requirement_list (-r)
     - --requirement_list path/requirements.csv
     - Points to the Requirement List. Mandatory. (This script is not used when running spec. cov. without a Requirement List)
   * - --partial_cov (-p)
     - --partial_cov my_testcase_cov.csv
       
       --partial_cov my_coverage_files.txt
     - Points to the Partial Coverage file generated by the VHDL simulation as input to the post processing.
       
       May also point to a file list including references to multiple Partial Coverage files. The format of such a file would be just
       
       each file on a separate line - potentially prefixed by a relative or absolute path.
   * - --requirement_map_list (-m)
     - --requirement_map_list path/subrequirements.csv
     - Optional: Points to the Requirement Map file, (see `Requirement mapping`_). If this argument is omitted, the
       
       script assumes that no sub-requirements exist.
   * - --spec_cov (-s)
     - --spec_cov uart_spec_cov.csv
     - Name (and optional path) of the specification_coverage file name, which is used to generate the following 3 files:
       
       * <specification_coverage_file_name>.req_vs_single_tc.csv
       
       * <specification_coverage_file_name>.tc_vs_reqs.csv
       
       * <specification_coverage_file_name>.req_vs_tcs.csv
       
       Note that the filename extension, i.e. .csv, will have to be part of the specified specification_coverage file name.
   * - --clean
     - --clean path/do/directory
     - Will clean any/all Partial Coverage files in the given directory. Directory path is optional. Default is current directory.
       
       Cannot be run in combination with other arguments. No short form defined here - to avoid unwanted clean.
   * - --strictness
     - --strictness 1
     - Default strictness is 0 (when not applied). 1 is stricter and 2 is much stricter (see `Strictness levels`_ and `Multiple
       testcases, with strict requirement vs testcase relation`_)).
       
       No short form defined here - to avoid wrong strictness.
   * - --config
     - --config path/config_file.txt
     - Optional configuration file where all the arguments can be placed. This argument will override all other arguments.
       
       The configuration file does not need to have the .txt extension. All arguments shall be added on a new line.
       
       Example configuration file contents:
       
       --requirement_list my_path/requirements.csv
       
       --partial_cov my_testcase_cov_files.txt
       
       --spec_cov my_spec_cov.csv
   * - --help (-h)
     - --help
     - Display the script argument options.


Strictness levels
==================================================================================================================================
Strictness does not apply to VHDL testcases - only to the post processing Python script.
For all strictness levels, all requirements must be compliant for the complete specification to be compliant.
Default strictness is strictness 0.

Strictness 0
----------------------------------------------------------------------------------------------------------------------------------
This is the least strictness possible. Focus is only on the requirements, - with no concern at all as to in which testcase the various
requirements have been tested. Any requirement is compliant if executed as PASSed in any passing testcase, and not failing anywhere.
This is independent of whether one or more testcases are specified for a given requirement in the Requirement List. Testcases may still
be specified in the Requirement List, but these will ignored by the post-processing script.

Strictness 1
----------------------------------------------------------------------------------------------------------------------------------
For this strictness level a requirement is only compliant if executed in the testcase(s) specified in the Requirement List. The list
shown here is used as example for the cases below:

* If no testcase is specified for a given requirement, this requirement may be checked anywhere. Compliant if PASSed.
* If a requirement line is specified with a single testcase, this requirement (e.g. UART_REQ_1) is only compliant if executed by that
  testcase.
* If a requirement line is specified with multiple testcases (e.g. UART_REQ_4), this requirement is compliant if PASS in one or more
  of these testcases. There can be no FAIL in other testcases.
* If a requirement line is specified multiple times (like UART_REQ_3), every single line is mandatory. Hence UART_REQ_3 must PASS in
  both testcases (tc_basic and tc_19k2)

* A requirement may be checked in **any** testcase in addition to any specified testcase(s).
* **If a requirement status from any testcase is FAIL, that requirement is NON COMPLIANT, - even if PASS in other testcases.** 

.. code-block:: none

    UART_REQ_1, Baud-rate 9600, tc_basic
    UART_REQ_2, Baud-rate 19200, tc_19k2
    UART_REQ_3, Odd parity, tc_basic
    UART_REQ_3, Odd parity, tc_19k2
    UART_REQ_4, Active low reset, tc_reset, tc_basic, tc_19k2

Strictness 2
----------------------------------------------------------------------------------------------------------------------------------
With this strictness a requirement will be NON_COMPLIANT if it is tested (ticked off) in a testcase that in the Requirement List was
not specified as testcase for that requirement. In that case it will be NON_COMPLIANT even if it has passed in one or more testcases
specified for that requirement. E.g. if UART_REQ_1 is tested in testcase tc_basic, but also in tc_reset.

.. note::

    Strictness 2 requires that all requirements must be specified with at least one testcase.


Output files
==================================================================================================================================
The output of the post-processing script is a set of files with the name given by the \-\-spec_cov (-s) argument, followed by the name
of that particular file. 
The following five files are produced:
* <spec_cov_file>.req_compliance_minimal.csv - Lists requirements and their compliance with minimum of qualifying testcases
* <spec_cov_file>.req_compliance_extended.csv - Lists requirements and their compliance, with all qualifying testcases
* <spec_cov_file>.req_non_compliance.csv
COMPLIANT/NON_COMPLIANT/NOT_TESTED and PASS/FAIL/NOT_EXECUTED, respectively. This section lists the formats of the output
files.

.. note::
    The output file examples shown in this section have been column aligned for readability. This alignment is not present in the 
    generated files. 

Requirement compliance listing
----------------------------------------------------------------------------------------------------------------------------------

.req_compliance_minimal.csv
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The <spec_cov_file>.req_compliance_minimal.csv file will list each requirement once, with the minimum number of testcases qualifying 
that requirement for compliance. This means that if a requirement was tested in more testcases than required any superflous testcases
will be excluded. 

For example, in strictness 1 or 2, if a requirement was specified for testing in TC_1 as well as either TC_2 or TC_3, but the 
requirement was actually ticked off in all three testcases, the .req_compliance_minimal.csv file would list TC_1 and only one of TC_2 
or TC_3, as the other is superflous. 

This means that in strictness 0, only one testcase will be listed, since any tickoff in a passing testcase is enough to make the
requirement compliant in strictness 0. 

If a requirement is not compliant, no testcases will be listed, and the column for testcases will instead have the text 
"check \*.req_non_compliance.csv", to indicate that the user should check the .req_non_compliance.csv file for explanation of why
the requirement is not compliant.

The main compliance list of the .req_compliance_minimal.csv file will list only top level reuqirements (i.e. not sub-requirements).
Compliance and testcase listing for sub-requirements will be listed in a separate section below the main compliance list.

.. note::

    Requirements not listed in the Requirement List or Map file will not be listed in the .req_compliance_minimal file

Example:

.. code-block:: none

    Requirement, Qualifying testcases(minimum),   Compliance
    REQ_1,       TC_BASIC,                        COMPLIANT
    REQ_2,       TC_BASIC & TC_2A,                COMPLIANT
    REQ_3,       check *.req_non_compliance.csv,  NOT_TESTED
    REQ_4,       tested through sub-requirements, COMPLIANT


    Requirement, Sub-requirement, Qualifying testcases(minimum), Sub-req compliance
    REQ_4,       REQ_4A,          TC_BASIC & TC_4A,              COMPLIANT
    REQ_4,       REQ_4B,          TC_BASIC & TC_4B,              COMPLIANT


.req_compliance_extended.csv
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The <spec_cov_file>.req_compliance_extended.csv file is similar in format to the .req_compliance_minimal.csv file, except that it will
list *all* qualifying testcases for a requirement. For strictness 1 and 2, this means that the file will list all testcases which
the requirement was both *specified* for testing in and was *actually* tested in. 

For example, in strictness 1 or 2, if a requirement was specified for testing in TC_1 as well as either TC_2 or TC_3, but the
requirement was actually ticked off in all three testcases, the .req_compliance_extended.csv file would list all three testcases.

For AND-listed testcases, .req_compliance_extended.csv file will list each testcase on a separate line, while OR-listed testcases are
listed on the same line, mirroring the testcase listing format given in the Requirement file. 

In strictness 0, all testcases where a requirement is ticked off will be listed in the .req_compliance_extended.csv, since they are all
considered qualifying testcases. In this case, all testcases will be listed on a single line, since any AND/OR-listing of
testcases in the Requirement file will be ignored in strictness 0. 

The main compliance list of the .req_compliance_minimal.csv file will list only top level reuqirements (i.e. not sub-requirements).
Compliance and testcase listing for sub-requirements will be listed in a separate section below the main compliance list.

.. note::

    Requirements not listed in the Requirement List or Map file will not be listed in the .req_compliance_extended file

Example:

.. code-block:: none

    Requirement, Qualifying testcases(minimum),   Compliance
    REQ_1,       TC_BASIC,                        COMPLIANT
    REQ_2,       TC_BASIC,                        COMPLIANT
    REQ_2,       TC_2A & TC_2B,                   COMPLIANT
    REQ_3,       check *.req_non_compliance.csv,  NOT_TESTED
    REQ_4,       tested through sub-requirements, COMPLIANT


    Requirement, Sub-requirement, Qualifying testcases(minimum), Sub-req compliance
    REQ_4,       REQ_4A,          TC_BASIC & TC_4A,              COMPLIANT
    REQ_4,       REQ_4B,          TC_BASIC & TC_4B,              COMPLIANT



.req_non_compliance.csv
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The <spec_cov_file>.req_non_compliance.csv file will list all requirements from the Requirement List that are either NON-COMPLIANT or
NOT_TESTED, along with the reason for their lack of compliance.

For example, if a requirement has been ticked off in some, but not all, of the specified testcases in strictness 1 or 2, the
requirement status will be NOT_TESTED, and the testcases in which the requirement is missing a tickoff will be listed. 

If a compound requirement is lacking compliance due to one or more sub-requirements not being compliant, the main non-compliance list
will specify which sub-requirements are keeping the compound requirement from being compliant. Non-compliance for sub-requirements will
then be listed in a separete section below the main non-compliance list. This is illustrated in the example below, where REQ_6A is a
sub-requirement of REQ_6. 

Example:

.. code-block:: none

    Requirement, Compliance status, Reason
    REQ_3,       NOT_TESTED,        No requirement tickoffs
    REQ_4,       NOT_TESTED,        Missing tickoff in TC_4B
    REQ_5,       NON_COMPLIANT,     TC_5 failed
    REQ_6,       NOT_TESTED,        Sub-req REQ_6A not tested


    Requirement, Sub-Requirement(s), Compliance
    REQ_6A,      NOT_TESTED,         Missing tickoff in TC_6A


Testcase listing and warning files
----------------------------------------------------------------------------------------------------------------------------------

.testcase_list.csv
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The <spec_cov_file>.testcase_list.csv file will list each testcase with its status (PASS/FAIL/NOT_EXECUTED), a list of all the
requirements that were ticked off in that testcase ("Actual tickoffs"), and a list of all the requirements that were specified for
testing in that testcase, but were not ticked off ("Missing tickoffs").

In the example below, REQ_1 and REQ_2 were ticked off in TC_BASIC. REQ_3 was specified in the Requirement List to be tested in
TC_BASIC, but was not actually ticked off.

.. code-block:: none

    Testcase, Testcase status, Actual tickoffs, Missing tickoffs
    TC_BASIC, PASS,            REQ_1 & REQ_2,   REQ_3
    TC_1,     PASS,            REQ_1
    TC_4A,    PASS,            REQ_4A,
    TC_4B,    PASS,            ,                REQ_4B
    TC_5,     FAIL,            REQ_5


.warnings.csv
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The <spec_cov_file>.warnings.csv file contains messages about issues detected by the post-processing script that the user should be
made aware of.

Types of issues reported in the .warnings.csv file:
 * Tickoff of requirements not found in the Requirement List
 * Requirement tickoff in testcases not specified for that requirement (strictness 1 and 2)
 * Tickoff of compund requirements (since these are specified for testing through sub-requirements, not direct tickoff)
 * No testcase specifications for requirement when using strictness 2

.. code-block:: none

    REQ_1A ticked off in non-specified testcase (TC_4)
    REQ_10 not found in input requirement list (ticked off in TC_1)
    REQ_4 specified for testing through sub-requirements. Ticked off directly in TC_1.


Reference tables: Compliance/result labels
----------------------------------------------------------------------------------------------------------------------------------
The following tables summarize the meanings of the various requirement compliance and testcase result labels in the Specification
Coverage output files. 

+------------------+------------------------+-------------------------------------+--------------------------------------------+
| Requirement      | Meaning when           | Meaning when                        | Meaning when                               |
| compliance label | Strictness = 0         | Strictness = 1                      | Strictness = 2                             |
+==================+========================+=====================================+============================================+
| COMPLIANT        | Ticked off in passing  | Ticked off in specified, passing    | Ticked off ONLY in specified, passing      |
|                  | testcase(s). No fails. | testcase(s).                        | testcase(s).                               |
+------------------+------------------------+-------------------------------------+--------------------------------------------+
| NON-COMPLIANT    | Ticked off in failing testcase and/or explicitly failed      | Ticked off in failing testcase and/or      |
|                  | at tick-off.                                                 | explicitly failed at tick-off and/or ticked|
|                  |                                                              | off in non-specified testcase.             |              
+------------------+------------------------+-------------------------------------+--------------------------------------------+
| NOT_TESTED       | Not ticked off in any  | Not ticked off in any specified     | Not ticked off in any testcase.            |
|                  | testcase.              | testcase.                           |                                            |                     
+------------------+------------------------+-------------------------------------+--------------------------------------------+


+------------------------+--------------------------------------------+
| Testcase result label  | Meaning                                    |
+========================+============================================+
| PASS                   | Testcase passed without unexpected alerts  | 
|                        |                                            |
+------------------------+--------------------------------------------+
| FAIL                   | Testcase failed                            | 
|                        |                                            |
+------------------------+--------------------------------------------+                          
| NOT_EXECUTED           | Testcase not executed                      |                                     
+------------------------+--------------------------------------------+


.. include:: rst_snippets/subtitle_1_division.rst

**********************************************************************************************************************************
Example demos
**********************************************************************************************************************************
There are two examples demos provided under the demo directory, one with the most basic usage and one with a more complete
functionality. 

.. include:: rst_snippets/ip_disclaimer.rst
