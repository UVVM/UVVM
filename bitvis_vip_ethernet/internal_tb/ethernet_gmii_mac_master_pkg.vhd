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

library mac_master;
use mac_master.ethernet_types.all;

package ethernet_gmii_mac_master_pkg is

  type t_if_in is record
    tx_wr_en_i : std_ulogic;
    tx_data_i  : t_ethernet_data;
    rx_rd_en_i : std_ulogic;
  end record;

  type t_if_out is record
    clk                : std_logic;
    tx_reset_o         : std_ulogic;
    tx_full_o          : std_ulogic;
    rx_reset_o         : std_ulogic;
    rx_empty_o         : std_ulogic;
    rx_data_o          : t_ethernet_data;
  end record;

end package ethernet_gmii_mac_master_pkg;