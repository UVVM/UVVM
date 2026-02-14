--================================================================================================================================
-- Copyright 2026 UVVM
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

entity apb_register is
  generic (
    GC_REG_ADDR           : natural;        -- Register address (must be addressable with GC_ADDR_WIDTH bits)
    GC_ADDR_WIDTH         : integer := 32;  -- Address width (default 32-bit)
    GC_DATA_WIDTH         : integer := 32   -- Data width (default 32-bit)
  );
  port (
    -- APB Interface
    pclk                  : in  std_logic;
    presetn               : in  std_logic;
    paddr                 : in  std_logic_vector(GC_ADDR_WIDTH-1 downto 0);
    pprot                 : in  std_logic_vector(2 downto 0);
    psel                  : in  std_logic;
    penable               : in  std_logic;
    pwrite                : in  std_logic;
    pwdata                : in  std_logic_vector(GC_DATA_WIDTH-1 downto 0);
    pstrb                 : in  std_logic_vector((GC_DATA_WIDTH/8)-1 downto 0);
    prdata                : out std_logic_vector(GC_DATA_WIDTH-1 downto 0);
    pready                : out std_logic;
    pslverr               : out std_logic;
    -- Control signals
    number_of_wait_states : in  integer := 0
  );
end entity apb_register;

architecture rtl of apb_register is

  constant C_REG_ADDR : std_logic_vector(GC_ADDR_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(GC_REG_ADDR, GC_ADDR_WIDTH));

  type t_pready_state is (WAIT_FOR_ACCESS_PHASE, WAIT_FOR_PREADY);

  signal reg                 : std_logic_vector(GC_DATA_WIDTH-1 downto 0);
  signal pready_state        : t_pready_state;
  signal pready_wait_counter : integer;

begin

  p_apb_reg : process (pclk, presetn)
  begin
    if presetn = '0' then
      reg     <= (others => '0');
      prdata  <= (others => '0');
      pslverr <= '0';
    elsif rising_edge(pclk) then
      -- Default values
      pslverr <= '0';

      -- Wait until slave is selected
      if psel = '1' then
        -- Block non-secure transactions PPROT[1] = '1'
        if pprot(1) = '1' then
          pslverr <= '1';
        -- Wait for access phase
        elsif penable = '1' then
          -- Read operation
          if pwrite = '0' then
            if paddr = C_REG_ADDR then
              prdata <= reg;
            else
              prdata <= (others => '0');
            end if;
            -- Write operation
          else
            if paddr = C_REG_ADDR then
              for i in 0 to (GC_DATA_WIDTH / 8) - 1 loop
                if pstrb(i) = '1' then
                  reg((i * 8) + 7 downto i * 8) <= pwdata((i * 8) + 7 downto i * 8);
                end if;
              end loop;
            end if;
          end if;
        end if;
      end if;

    end if;
  end process p_apb_reg;

  p_apb_pready: process (pclk, presetn)
  begin
    if presetn = '0' then
      pready_state        <= WAIT_FOR_ACCESS_PHASE;
      pready_wait_counter <= 0;
      pready              <= '0';
    elsif rising_edge(pclk) then
      -- Default values
      pready <= '0';

      case pready_state is
        when WAIT_FOR_ACCESS_PHASE =>
          if psel = '1' and penable = '1' then
            if number_of_wait_states = 0 then
              pready <= '1';
            else
              pready_state <= WAIT_FOR_PREADY;
            end if;
          end if;
        when WAIT_FOR_PREADY =>
          if pready_wait_counter >= number_of_wait_states-1 then
            pready              <= '1';
            pready_wait_counter <= 0;
            pready_state        <= WAIT_FOR_ACCESS_PHASE;
          else
            pready_wait_counter <= pready_wait_counter + 1;
          end if;
      end case;
    end if;
  end process p_apb_pready;

end architecture rtl;