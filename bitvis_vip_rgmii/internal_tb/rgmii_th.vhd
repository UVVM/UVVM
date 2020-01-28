--================================================================================================================================
-- Copyright (c) 2020 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
-- THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--================================================================================================================================

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_rgmii;
use bitvis_vip_rgmii.rgmii_bfm_pkg.all;


--=================================================================================================
-- Test harness entity
--=================================================================================================
entity test_harness is
  generic(
    GC_CLK_PERIOD      : time
  );
  port(
    signal clk         : in    std_logic;
    signal rgmii_tx_if : inout t_rgmii_tx_if;
    signal rgmii_rx_if : inout t_rgmii_rx_if
  );
end entity;

--=================================================================================================
-- Test harness architectures
--=================================================================================================
architecture struct_bfm of test_harness is
begin

  -- Delay the RX path
  rgmii_tx_if.txc    <= clk;
  rgmii_rx_if.rxc    <= clk;
  rgmii_rx_if.rxd    <= transport rgmii_tx_if.txd after GC_CLK_PERIOD*5;
  rgmii_rx_if.rx_ctl <= transport rgmii_tx_if.tx_ctl after GC_CLK_PERIOD*5;

end struct_bfm;


architecture struct_vvc of test_harness is
begin

  -- Instantiate VVC
  i_rgmii_vvc : entity work.rgmii_vvc
    generic map(
      GC_INSTANCE_IDX => 0
      )
    port map(
      rgmii_vvc_tx_if => rgmii_tx_if,
      rgmii_vvc_rx_if => rgmii_rx_if
    );

  rgmii_tx_if.txc    <= clk;
  rgmii_rx_if.rxc    <= clk;
  rgmii_rx_if.rxd    <= rgmii_tx_if.txd;
  rgmii_rx_if.rx_ctl <= rgmii_tx_if.tx_ctl;

end struct_vvc;