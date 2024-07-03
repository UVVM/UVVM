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

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library bitvis_vip_error_injection;
use bitvis_vip_error_injection.error_injection_pkg.all;

entity error_injection_sl is
  generic(
    GC_START_TIME   : time    := 0 ns;
    GC_INSTANCE_IDX : natural := 1
  );
  port(
    ei_in  : in  std_logic;
    ei_out : out std_logic
  );
end entity error_injection_sl;

architecture behave of error_injection_sl is

  component error_injection_slv
    generic(
      GC_START_TIME   : time;
      GC_INSTANCE_IDX : natural
    );
    port(
      ei_in  : in  std_logic_vector(0 downto 0);
      ei_out : out std_logic_vector(0 downto 0)
    );
  end component;

begin

  error_injector_slv : error_injection_slv
    generic map(
      GC_START_TIME   => GC_START_TIME,
      GC_INSTANCE_IDX => GC_INSTANCE_IDX
    )
    port map(
      ei_in(0)  => ei_in,
      ei_out(0) => ei_out
    );

end behave;
