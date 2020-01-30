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

library bitvis_vip_gmii;
use bitvis_vip_gmii.gmii_bfm_pkg.all;


--=================================================================================================
-- Test harness entity
--=================================================================================================
entity test_harness is
  generic(
    GC_CLK_PERIOD      : time
  );
  port(
    signal clk        : in    std_logic;
    signal gmii_tx_if : inout t_gmii_tx_if;
    signal gmii_rx_if : inout t_gmii_rx_if
  );
end entity;

--=================================================================================================
-- Test harness architectures
--=================================================================================================
architecture struct_bfm of test_harness is
begin

  -- Delay the RX path
  gmii_tx_if.gtxclk <= clk;
  gmii_rx_if.rxclk  <= clk;
  gmii_rx_if.rxd    <= transport gmii_tx_if.txd after GC_CLK_PERIOD*5;
  gmii_rx_if.rxdv   <= transport gmii_tx_if.txen after GC_CLK_PERIOD*5;

end struct_bfm;


--architecture struct_vvc of test_harness is
--begin

--  -- Instantiate VVC
--  i_gmii_vvc : entity work.gmii_vvc
--    generic map(
--      GC_INSTANCE_IDX => 0
--      )
--    port map(
--      gmii_vvc_tx_if => gmii_tx_if,
--      gmii_vvc_rx_if => gmii_rx_if
--    );

--  gmii_tx_if.gtxclk <= clk;
--  gmii_rx_if.rxclk  <= clk;
--  gmii_rx_if.rxd    <= gmii_tx_if.txd;
--  gmii_rx_if.rxdv   <= gmii_tx_if.txen;

--end struct_vvc;