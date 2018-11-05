--========================================================================================================================
-- Copyright (c) 2018 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--========================================================================================================================

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_gmii;
context bitvis_vip_gmii.vvc_context;

library bitvis_vip_ethernet;
context bitvis_vip_ethernet.hvvc_context;

--=================================================================================================
entity gmii_test_harness is
  generic(
    GC_CLK_PERIOD : time
  );
end entity gmii_test_harness;


--=================================================================================================
--=================================================================================================

architecture struct of gmii_test_harness is

  signal clk        : std_logic;
  signal i1_gmii_if : t_gmii_if;
  signal i2_gmii_if : t_gmii_if;

begin

  -----------------------------
  -- vvc/executors
  -----------------------------
  i1_ethernet_vvc : entity bitvis_vip_ethernet.ethernet_vvc
    generic map(
      GC_INSTANCE_IDX     => 1,
      GC_INTERFACE        => GMII,
      GC_VVC_INSTANCE_IDX => 1
    );

  i2_ethernet_vvc : entity bitvis_vip_ethernet.ethernet_vvc
    generic map(
      GC_INSTANCE_IDX     => 2,
      GC_INTERFACE        => GMII,
      GC_VVC_INSTANCE_IDX => 2
    );


  i1_gmii_vvc : entity bitvis_vip_gmii.gmii_vvc
    generic map(
      GC_INSTANCE_IDX                       => 1,
      GC_GMII_BFM_CONFIG                    => C_GMII_BFM_CONFIG_DEFAULT,
      GC_CMD_QUEUE_COUNT_MAX                => 500,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => 450,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => WARNING
    )
    port map(
      gmii_to_dut_if   => i1_gmii_if.gmii_to_dut_if,
      gmii_from_dut_if => i1_gmii_if.gmii_from_dut_if
    );

  i2_gmii_vvc : entity bitvis_vip_gmii.gmii_vvc
    generic map(
      GC_INSTANCE_IDX                       => 2,
      GC_GMII_BFM_CONFIG                    => C_GMII_BFM_CONFIG_DEFAULT,
      GC_CMD_QUEUE_COUNT_MAX                => 500,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => 450,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => WARNING
    )
    port map(
      gmii_to_dut_if   => i2_gmii_if.gmii_to_dut_if,
      gmii_from_dut_if => i2_gmii_if.gmii_from_dut_if
    );

  p_clk : clock_generator(clk, GC_CLK_PERIOD);

  i1_gmii_if.gmii_from_dut_if.gtxclk <= clk;
  i1_gmii_if.gmii_to_dut_if.rxclk    <= clk;
  i1_gmii_if.gmii_from_dut_if.txen   <= i2_gmii_if.gmii_to_dut_if.rxdv;
  i1_gmii_if.gmii_from_dut_if.txd    <= i2_gmii_if.gmii_to_dut_if.rxd;
  i2_gmii_if.gmii_from_dut_if.gtxclk <= clk;
  i2_gmii_if.gmii_to_dut_if.rxclk    <= clk;
  i2_gmii_if.gmii_from_dut_if.txen   <= i1_gmii_if.gmii_to_dut_if.rxdv;
  i2_gmii_if.gmii_from_dut_if.txd    <= i1_gmii_if.gmii_to_dut_if.rxd;

end struct;