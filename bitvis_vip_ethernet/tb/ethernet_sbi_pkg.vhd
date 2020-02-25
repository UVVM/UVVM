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

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use bitvis_vip_sbi.sbi_bfm_pkg.all;

--=================================================================================================
package ethernet_sbi_pkg is

  --------------------------------
  -- SBI config
  --------------------------------
  -- Register map :
  constant C_ADDR_FIFO_PUT            : integer := 0;
  constant C_ADDR_FIFO_GET            : integer := 1;
  constant C_ADDR_FIFO_COUNT          : integer := 2;
  constant C_ADDR_FIFO_PEEK           : integer := 3;
  constant C_ADDR_FIFO_FLUSH          : integer := 4;
  constant C_ADDR_FIFO_MAX_COUNT      : integer := 5;

  constant C_ADDR_WIDTH_1 : integer := 8;
  constant C_DATA_WIDTH_1 : integer := 8;
  constant C_ADDR_WIDTH_2 : integer := 8;
  constant C_DATA_WIDTH_2 : integer := 8;

  constant C_SBI_BFM_CONFIG : t_sbi_bfm_config := (
    max_wait_cycles             => 1000,
    max_wait_cycles_severity    => failure,
    use_fixed_wait_cycles_read  => false,
    fixed_wait_cycles_read      => 0,
    clock_period                => 10 ns,
    clock_period_margin         => 0 ns,
    clock_margin_severity       => TB_ERROR,
    setup_time                  => 2.5 ns,
    hold_time                   => 2.5 ns,
    bfm_sync                    => SYNC_WITH_SETUP_AND_HOLD,
    id_for_bfm                  => ID_BFM,
    id_for_bfm_wait             => ID_BFM_WAIT,
    id_for_bfm_poll             => ID_BFM_POLL,
    use_ready_signal            => true
    );

end package ethernet_sbi_pkg;