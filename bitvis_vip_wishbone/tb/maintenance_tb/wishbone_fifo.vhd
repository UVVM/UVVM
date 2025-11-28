--================================================================================================================================
-- Copyright 2025 UVVM
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

entity wishbone_fifo is
  generic(
    GC_DATA_WIDTH : integer range 8 to 64 := 32
  );
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;
    -- Inputs
    cyc_i : in  std_logic;
    stb_i : in  std_logic;
    we_i  : in  std_logic;
    adr_i : in  std_logic_vector(1 downto 0);
    dat_i : in  std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    -- Outputs
    dat_o : out std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    ack_o : out std_logic
  );
end entity wishbone_fifo;

architecture behave of wishbone_fifo is

  -- Wishbone addresses
  constant C_ADDR_FIFO    : std_logic_vector(1 downto 0) := "00";
  constant C_ADDR_STATUS  : std_logic_vector(1 downto 0) := "01";
  constant C_ADDR_VERSION : std_logic_vector(1 downto 0) := "10";

  constant C_VERSION      : natural := 1;
  constant C_FIFO_DEPTH   : integer := 16;

  type t_fifo_mem is array (0 to C_FIFO_DEPTH-1) of std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
  signal fifo_mem : t_fifo_mem := (others => (others => '0'));

  signal wr_ptr   : integer range 0 to C_FIFO_DEPTH := 0;
  signal rd_ptr   : integer range 0 to C_FIFO_DEPTH := 0;
  signal fifo_cnt : integer range 0 to C_FIFO_DEPTH := 0;

  -- Status flags
  signal fifo_full  : std_logic;
  signal fifo_empty : std_logic;

begin

  fifo_full  <= '1' when fifo_cnt = C_FIFO_DEPTH else '0';
  fifo_empty <= '1' when fifo_cnt = 0 else '0';

  p_fifo : process(clk_i) is
  begin
    if rising_edge(clk_i) then
      ack_o <= '0';

      if cyc_i = '1' and stb_i = '1' then
        ack_o <= '1';

        case adr_i is
          when C_ADDR_FIFO =>
            if we_i = '1' then
              if fifo_cnt < C_FIFO_DEPTH then
                fifo_mem(wr_ptr) <= dat_i;
                wr_ptr           <= (wr_ptr + 1) mod C_FIFO_DEPTH;
                fifo_cnt         <= fifo_cnt + 1;
              end if;
            else
              if fifo_cnt > 0 then
                dat_o    <= fifo_mem(rd_ptr);
                rd_ptr   <= (rd_ptr + 1) mod C_FIFO_DEPTH;
                fifo_cnt <= fifo_cnt - 1;
              else
                dat_o <= (others => '0');
              end if;
            end if;

          when C_ADDR_STATUS =>
            dat_o <= std_logic_vector(to_unsigned(fifo_cnt, GC_DATA_WIDTH)) when we_i = '0' else (others => '0');

          when C_ADDR_VERSION =>
            dat_o <= std_logic_vector(to_unsigned(C_VERSION, GC_DATA_WIDTH)) when we_i = '0' else (others => '0');

          when others =>
            dat_o <= (others => '0');
        end case;
      end if;

      if rst_i = '1' then
        wr_ptr   <= 0;
        rd_ptr   <= 0;
        fifo_cnt <= 0;
        ack_o    <= '0';
        dat_o    <= (others => '0');
      end if;
    end if;
  end process p_fifo;

end architecture behave;
