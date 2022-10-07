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

package ethernet_sbi_pkg is

  -- Register map
  constant C_ADDR_FIFO_PUT       : integer := 0;
  constant C_ADDR_FIFO_GET       : integer := 1;
  constant C_ADDR_FIFO_COUNT     : integer := 2;
  constant C_ADDR_FIFO_PEEK      : integer := 3;
  constant C_ADDR_FIFO_FLUSH     : integer := 4;
  constant C_ADDR_FIFO_MAX_COUNT : integer := 5;

end package ethernet_sbi_pkg;

package body ethernet_sbi_pkg is
end package body ethernet_sbi_pkg;
