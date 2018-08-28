--========================================================================================================================
-- Copyright (c) 2017 by Bitvis AS.  All rights reserved.
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
--library uvvm_vvc_framework;

library bitvis_vip_sbi;
use bitvis_vip_sbi.sbi_bfm_pkg.all;

--=================================================================================================
entity test_harness is
  generic(
    GC_CLK_PERIOD : time
  );
end entity test_harness;


--=================================================================================================
--=================================================================================================

architecture struct of test_harness is

  --------------------------------
  -- SBI config
  --------------------------------
  constant C_ADDR_WIDTH_1 : integer := 8;
  constant C_DATA_WIDTH_1 : integer := 8;
  constant C_ADDR_WIDTH_2 : integer := 8;
  constant C_DATA_WIDTH_2 : integer := 8;

  signal sbi_if_1   : t_sbi_if(addr(C_ADDR_WIDTH_1-1 downto 0), wdata(C_DATA_WIDTH_1-1 downto 0), rdata(C_DATA_WIDTH_1-1 downto 0));
  signal sbi_if_2   : t_sbi_if(addr(C_ADDR_WIDTH_2-1 downto 0), wdata(C_DATA_WIDTH_2-1 downto 0), rdata(C_DATA_WIDTH_2-1 downto 0));
  signal clk        : std_logic;

begin

  -----------------------------
  -- INstantiate DUT
  -----------------------------
  i1_sbi_fifo : entity work.sbi_fifo
    generic map(
      GC_ADDR_WIDTH_1 => C_ADDR_WIDTH_1,
      GC_DATA_WIDTH_1 => C_DATA_WIDTH_1,
      GC_ADDR_WIDTH_2 => C_ADDR_WIDTH_2,
      GC_DATA_WIDTH_2 => C_DATA_WIDTH_2
      )
    port map(
      clk         => clk,
      sbi_if_1    => sbi_if_1,
      sbi_if_2    => sbi_if_2
    );


  -----------------------------
  -- vvc/executors
  -----------------------------
  i1_sbi_vvc : entity work.sbi_vvc
    generic map(
      GC_ADDR_WIDTH                           => C_ADDR_WIDTH_1,
      GC_DATA_WIDTH                           => C_DATA_WIDTH_1,
      GC_INSTANCE_IDX                         => 1,
      GC_SBI_CONFIG                           => C_SBI_BFM_CONFIG_DEFAULT,
      GC_CMD_QUEUE_COUNT_MAX                  => 500,
      GC_CMD_QUEUE_COUNT_THRESHOLD            => 450,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY   => WARNING
      )
    port map(
      clk                     => clk,
      sbi_vvc_master_if       => sbi_if_1
      );

  i2_sbi_vvc : entity work.sbi_vvc
    generic map(
      GC_ADDR_WIDTH   => C_ADDR_WIDTH_2,
      GC_DATA_WIDTH   => C_DATA_WIDTH_2,
      GC_INSTANCE_IDX => 2
      )
    port map(
      clk                     => clk,
      sbi_vvc_master_if       => sbi_if_2
      );

  p_clk : clock_generator(clk, GC_CLK_PERIOD);

end struct;


