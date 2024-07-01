--================================================================================================================================
-- Copyright 2024 UVVM
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================
-- Note : Any functionality not explicitly described in the documentation is subject to change at any time
----------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ethernet_mac_pkg is

  -- Register map
  constant C_ETH_ADDR_INVALID  : unsigned(7 downto 0) := x"00";
  constant C_ETH_ADDR_MAC_DEST : unsigned(7 downto 0) := x"01";
  constant C_ETH_ADDR_MAC_SRC  : unsigned(7 downto 0) := x"02";
  constant C_ETH_ADDR_PAY_LEN  : unsigned(7 downto 0) := x"03";
  constant C_ETH_ADDR_PAYLOAD  : unsigned(7 downto 0) := x"04";
  constant C_ETH_ADDR_DUMMY    : unsigned(7 downto 0) := x"05";

  -- SBI config
  constant C_SBI_ADDR_WIDTH : integer := 8;
  constant C_SBI_DATA_WIDTH : integer := 8;

end package ethernet_mac_pkg;

package body ethernet_mac_pkg is
end package body ethernet_mac_pkg;
