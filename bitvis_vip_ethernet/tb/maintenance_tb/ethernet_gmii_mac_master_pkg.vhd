--================================================================================================================================
-- Copyright 2020 Bitvis
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================
-- Note : Any functionality not explicitly described in the documentation is subject to change at any time
----------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

package body ethernet_gmii_mac_master_pkg is
end package body ethernet_gmii_mac_master_pkg;