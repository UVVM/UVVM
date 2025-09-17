##################################################################################################################################
UVVM
##################################################################################################################################

UVVM (Universal VHDL Verification Methodology) is a free and Open Source Methodology and Library for making very structured 
VHDL-based testbenches.

Overview, Readability, Maintainability, Extensibility and Reuse are all vital for FPGA development efficiency and quality.
UVVM VVC (VHDL Verification Component) Framework was released in 2016 to handle exactly these aspects.

UVVM consists currently of the following elements:

* :ref:`utility_library`
* :ref:`VVC (VHDL Verification Component) Framework <vvc_framework>` - Including Utility Library
* BFMs (Bus Functional Models) to be used with any part of UVVM (See below for currently supported interfaces from Bitvis)
* VVCs to be used with UVVM VVC Framework and may be combined with BFMs (see overview below)


.. toctree::
   :maxdepth: 2
   :hidden:
   :caption: Contents:

   uvvm_intro.rst
   uvvm_getting_started.rst
   utility_library.rst
   rand_pkg_overview.rst
   func_cov_pkg_overview.rst
   optimized_rand.rst
   uvvm_assertions.rst
   vvc_framework.rst
   fifo_collection.rst
   generic_queue.rst
   association_list.rst
   vip_avalon_mm.rst
   vip_avalon_st.rst
   vip_axi.rst
   vip_axilite.rst
   vip_axistream.rst
   vip_clock_generator.rst
   vip_error_injection.rst
   vip_ethernet.rst
   vip_gmii.rst
   vip_gpio.rst
   vip_hvvc_to_vvc_bridge.rst
   vip_i2c.rst
   vip_rgmii.rst
   vip_sbi.rst
   vip_scoreboard.rst
   vip_spec_cov.rst
   vip_spi.rst
   vip_uart.rst
   vip_wishbone.rst
   tool_compatibility.rst
   faq.rst
