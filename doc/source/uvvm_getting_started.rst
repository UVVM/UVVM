#######################################################################################################################
UVVM Getting Started
#######################################################################################################################

This is an introduction and step-by-step guide for beginning with UVVM, along with examples of common tasks that the
designers will have to carry out.


***********************************************************************************************************************	     
Introduction
***********************************************************************************************************************

UVVM (Universal VHDL Verification Methodology) is a free and open source methodology for making very structured
VHDL-based testbenches. UVVM has been released with two different complexity levels, a low complexity UVVM Light
repository with the Utility library and BFMs (Bus Functional Models), without advanced features such as VVCs and
command distribution system, and the complete UVVM repository with all features available.
The UVVM Light repository is a lightweight version of UVVM that can be used with simple testbenches and as a low-level
introduction to UVVM.
**Note** that UVVM and UVVM Light requires VHDL 2008 to compile.


***********************************************************************************************************************	     
Installation
***********************************************************************************************************************


UVVM can be downloaded as a zip file or cloned using git. We are continuously adding new features to UVVM and the
easiest way to receive the updates is by cloning UVVM with git.


.. image:: images/uvvm_getting_started/clone_download_instructions.png
  :width: 700
  :name: github
  :align: center

	  
#. Navigate to the UVVM repository on GitHub: https://github.com/UVVM/UVVM

#. Select “Clone or download” marked with a red circle:
   
   * Clone by copying the repository address (green circle) and from the project folder running the
     command: ``git clone https://github.com/UVVM/UVVM.git``
     
   * Or download everything as a zip (blue circle) and extract the downloaded file in the project folder.

#. After cloning or unzipping UVVM you have all that is needed to start using UVVM and all of its features with
   your testbench.



   
Updating UVVM
=============

The method for updating UVVM depends on the chosen installation method:

* **cloned using git:**
  run the following command in terminal inside the UVVM folder to receive the latest release changes: git pull

* **downloaded as a zip:**
  repeat step 2b in section 2 and replace the old UVVM version with the new downloaded version.
  Note that this will overwrite any local changes to UVVM, e.g. local changes in the adaptations_pkg.vhd


***********************************************************************************************************************	     
Testbench
***********************************************************************************************************************

Include ``uvvm_util_context`` and the VVCs or BFMs you will be using in your testbench to start using UVVM:

.. code-block:: vhdl
		
   library uvvm_util;
   context uvvm_util.uvvm_util_context;
   library uvvm_vvc_framework;
   use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;
   Library bitvis_vip_sbi;
   context bitvis_vip_sbi.vvc_context;


The context files will ensure that everything necessary are made available from within the testbench, e.g.
   
.. image:: images/uvvm_getting_started/testbench_with_sbi_vvc.png
  :width: 500
  :name: testbench_example
  :align: center



	  
